#!/bin/sh
# Get current date
CURRENT_DATE=$(date)

# Set the default time
TIME="10:19:19 WIB"

# Input the date in the format Mon 12 Aug 2022
DATE=$(gum input --placeholder "Insert the date (Current date: $CURRENT_DATE)")

# Change the date of the last commit
GIT_COMMITTER_DATE="$DATE $TIME" git commit --amend --date="$DATE $TIME"