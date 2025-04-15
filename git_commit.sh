#!/bin/sh
# Check if the .env file exists
if [ ! -f .env ]; then
  echo "🚨 Error: .env file not found. Please create a .env file with the required environment variables."
  exit 1
fi

# Load environment variables from .env file
export $(grep -v '^#' .env | xargs)

# Function to handle manual input for commit message
manual_commit_input() {
  TYPE=$(cat ~/programming/tranity/shell/commit_type.txt | gum filter --limit 1)

  SCOPE=$(gum input --value "$TYPE" --placeholder "Scope of this change (e.g. 'api', 'ui', 'db')")
  if [ -n "$SCOPE" ]; then
    SUMMARY=$(gum input --value "$TYPE($SCOPE): " --placeholder "Summary of this change")
  else
    SUMMARY=$(gum input --value "$TYPE: " --placeholder "Summary of this change")
  fi

  DESCRIPTION=$(gum write --placeholder "Details of this change (CTRL+D to finish)")
}

# Function to validate and preprocess the API response
validate_and_preprocess_response() {
  local response="$1"

  # Preprocess the API response to escape control characters and handle backticks
  local cleaned_response=$(echo "$response" | tr -d '\000-\037' | sed 's/```//g' | jq -c . 2>/dev/null)

  # Check if the cleaned response is valid JSON
  if [ -z "$cleaned_response" ]; then
    echo "🚨 Error: Failed to parse the API response. Please check the API output."
    exit 1
  fi

  echo "$cleaned_response"
}

# Function to extract the generated text from the API response
extract_generated_text() {
  local response="$1"
  local summary=$(echo "$response" | jq -r '.candidates[0].content.parts[0].text')

  # Remove surrounding triple backticks from the generated text
  summary=$(echo "$summary" | sed 's/^```//;s/```$//')

  # Convert the summary to lowercase
  echo $(echo "$summary" | tr '[:upper:]' '[:lower:]')
}

# Ask if you want AI to generate the commit message
if gum confirm "Generate commit message with Gemini 2.5 AI?"; then
  # Check if the GEMINI_API_KEY environment variable is set
  if [ -z "${GEMINI_API_KEY}" ]; then
    echo "🚨 Error: GEMINI_API_KEY is not set. Please set it in your .env file or environment variables."
    exit 1
  fi

  # Ensure the correct git diff command is used
  if ! command -v git >/dev/null 2>&1; then
    echo "🚨 Error: Git is not installed or not available in the PATH."
    exit 1
  fi

  # Ensure the script is executed in the root of the Git repository
  if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
    echo "🚨 Error: Not inside a Git repository. Please navigate to a Git repository and try again."
    exit 1
  fi

  # Navigate to the root of the Git repository
  cd $(git rev-parse --show-toplevel)

  # Read the staged file changes explicitly using git diff
  STAGED_DIFF=$(git diff --cached)
  
  # Check if there are staged changes
  if [ -z "$STAGED_DIFF" ]; then
    echo "🚨 No staged changes detected. Add files to staged changes first!"
    exit 0
  fi

  # Compose the prompt including the diff details
  PROMPT=$(cat <<EOF
Generate a concise and informative git commit message in the format 'type(scope): summary' if a scope is provided or 'type: summary' if not.
The type must follow the conventional commit types: feat, fix, chore, docs, style, refactor, perf, test, build, ci, or revert.
Please respond with a single line commit message without any additional text or formatting.
The commit message should be based on the following staged changes:
$STAGED_DIFF
EOF
  )

  # Store the prompt in a log file for debugging
  LOG_DIR="logs"
  [ ! -d "$LOG_DIR" ] && mkdir -p "$LOG_DIR"
  LOG_FILE="$LOG_DIR/prompt.log"
  [ ! -f "$LOG_FILE" ] && touch "$LOG_FILE"

  TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
  echo "$TIMESTAMP - Prompt: $PROMPT" >> "$LOG_FILE"

  # Show a dynamic progress bar while calling the API
  spinner() {
    local delay=0.2
    local spinstr='|/-\'
    while true; do
      for c in $(echo "$spinstr" | fold -w1); do
        printf "\r⏳Generating commit message with Gemini 2.5 AI ($TIMESTAMP)...  %s" "$c"
        sleep "$delay"
      done
    done
  }
  spinner &
  SPINNER_PID=$!

  # Call the Gemini 2.5 API to generate a commit message using the prompt
  escaped_prompt=$(printf %s "$PROMPT" | jq -R -s .)
  AI_RESPONSE=$(curl -s "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-pro-exp-03-25:generateContent?key=${GEMINI_API_KEY}" \
    -H "Content-Type: application/json" \
    -X POST \
    -d "{
      \"contents\": [
        {
          \"parts\": [
            {
              \"text\": $escaped_prompt
            }
          ]
        }
      ]
    }")

  # The spinner will only show while the API call is running.
  # Once the API call completes, kill the spinner:
  # (Your API call follows here and after it completes, add:)
  kill "$SPINNER_PID" >/dev/null 2>&1
  wait "$SPINNER_PID" 2>/dev/null

  # Log the API response for debugging
  LOG_FILE="$LOG_DIR/api_response.log"
  [ ! -f "$LOG_FILE" ] && touch "$LOG_FILE"
  echo "$TIMESTAMP - API Response: $AI_RESPONSE" >> "$LOG_FILE"

  # Check if the API call was successful
  if [ $? -ne 0 ]; then
    echo "\n🚨 Error: Failed to call the Gemini 2.5 API. Please check your network connection and API key."
    exit 1
  fi

  # Check if the API response is empty
  if [ -z "$AI_RESPONSE" ]; then
    echo "\n🚨 Error: Empty response from Gemini 2.5 API. Please try again later."
    exit 1
  fi

  # Check if the API response contains an error
  if echo "$AI_RESPONSE" | grep -q '"error":'; then
    echo "\n🚨 Error: Gemini 2.5 API returned an error. Please check your API key and usage limits."
    exit 1
  fi

  # Validate and preprocess the API response
  CLEANED_AI_RESPONSE=$(validate_and_preprocess_response "$AI_RESPONSE")

  # Extract the generated text
  SUMMARY=$(extract_generated_text "$CLEANED_AI_RESPONSE")
  echo "✨ Gemini 2.5-generated commit message:"
  echo "$SUMMARY"

  # Allow editing the message
  SUMMARY=$(gum input --value "$SUMMARY" --placeholder "Edit the commit message if needed")
else
  manual_commit_input
fi

# Commit these changes
if gum confirm "Commit changes?"; then
  git commit -m "$SUMMARY" -m "$DESCRIPTION"

  # Change the commit date
  gum confirm "Do you want to change the date?" && gum style --foreground 212 '=====[Change the commit date]=====' && ~/programming/tranity/shell/git_change_commit_date.sh
fi