#!/bin/sh
# Choose the branch before pushing
BRANCH=$(gum choose $(git branch --show-current))

# Push the branch
gum confirm "Pull $BRANCH?" && git push origin $BRANCH