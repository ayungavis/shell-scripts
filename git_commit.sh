#!/bin/sh
TYPE=$(cat ~/programming/tranityproject/shell/commit_type.txt | gum filter --limit 1)

# Pre-populate the input with the type(scope): so that the user may change it
SUMMARY=$(gum input --value "$TYPE: " --placeholder "Summary of this change")
DESCRIPTION=$(gum write --placeholder "Details of this change (CTRL+D to finish)")

# Commit these changes
gum confirm "Commit changes?" && git commit -m "$SUMMARY" -m "$DESCRIPTION"

# Change the commit date
gum confirm "Do you want to change the date?" && gum style --foreground 212 '=====[Change the commit date]=====' && ~/programming/tranityproject/shell/git_change_commit_date.sh