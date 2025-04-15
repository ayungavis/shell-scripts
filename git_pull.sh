#!/bin/sh
# Choose the branch before pulling
BRANCH=$(git branch --show-current)

if [ -z "$BRANCH" ]; then
  echo "🚨 Error: No branch detected. Are you in a git repository?"
  exit 1
fi

# Check command line argument for pull type
if [ "$1" = "--rebase" ]; then
  PULL_TYPE="rebase"
elif [ "$1" = "--ff" ]; then
  PULL_TYPE="ff"
else
  # Choose pull type: rebase or fast-forward using gum if no valid argument provided
  PULL_TYPE=$(gum choose "rebase" "ff")
fi

if gum confirm "Pull $BRANCH using $PULL_TYPE?"; then
  if [ "$PULL_TYPE" = "rebase" ]; then
    git pull origin "$BRANCH" --rebase
  else
    git pull origin "$BRANCH" --ff
  fi
fi