#!/bin/sh
# Get current date
CURRENT_DATE=$(date)

# Input the date in the format Mon 12 Aug 2022
DATE=$(gum input --placeholder "Insert the date (Current date: $CURRENT_DATE)")

# Change the date of the last commit
git commit --amend --date="$DATE 10:19:19 WIB"