#!/bin/sh

# Choose the branch before pushing
BRANCH=$(git branch --show-current)

if [ "$1" = "-y" ]; then
  # Auto-confirm and push the branch
  git push origin "$BRANCH"
else
  # Prompt for confirmation before pushing
  gum confirm "Push $BRANCH?" && git push origin "$BRANCH"
fi