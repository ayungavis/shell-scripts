#!/bin/sh
TYPE=$(gum choose "🐛 fix" "⚡️ feat" "📝 docs" "🎨 style" "♻️ refactor" "🚀 perf" "🧪 test" "🔧 chore" "🗑 revert" "⚒️ build" "⚙️ ci" "✨ release" "🔥 initial")

# Pre-populate the input with the type(scope): so that the user may change it
SUMMARY=$(gum input --value "$TYPE: " --placeholder "Summary of this change")
DESCRIPTION=$(gum write --placeholder "Details of this change (CTRL+D to finish)")

# Commit these changes
gum confirm "Commit changes?" && git commit -m "$SUMMARY" -m "$DESCRIPTION"