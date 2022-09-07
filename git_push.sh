#!/bin/sh
# Choose the branch before pushing
BRANCH=$(gum choose $(git branch --show-current))

# Push the branch
gum confirm "Push $BRANCH?" && git push origin $BRANCH