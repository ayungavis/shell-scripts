#!/bin/sh
# Choose files to add
FILES=$(gum choose --no-limit $(git status --porcelain | awk '{print $2}'))

# Add the files
gum confirm "Add $FILES?" && git add $FILES

# Show the status
gum style --foreground 212 '=====[Git Status]=====' && git status

# Commit these changes
gum style --foreground 212 '=====[Commit the staging files]=====' && ./git_commit.sh