#!/bin/sh
# Choose the branch before pushing
BRANCH=$(gum choose $(git branch --format='%(refname:short)'))

# Push the branch
gum confirm "Push $BRANCH?" && git push origin $BRANCH