#!/bin/sh
# Choose files to add
FILES=$(gum choose --no-limit $(git status --porcelain | awk '{print $2}'))

if [ -z "$FILES" ]; then
  echo "No files selected, exiting."
  exit 1
fi

# Add the files
echo "Selected files:"
for file in $FILES; do
  gum style --foreground 212 " - $file"
done
gum confirm "Add these files?" && git add $FILES

# Commit these changes
./git_commit.sh