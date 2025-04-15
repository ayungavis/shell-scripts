# Git Helper Scripts

This repository contains a set of shell scripts to simplify common Git operations such as adding, committing, pushing, and pulling changes. These scripts also integrate with the Gemini 2.5 AI for generating commit messages.

## Prerequisites

1. **Install Dependencies**:

   - Ensure you have `git` installed and available in your PATH.
   - Install [Gum](https://github.com/charmbracelet/gum) for interactive prompts.
   - Install `jq` for JSON processing.

2. **Environment Variables**:

   - Create a `.env` file in the root directory of this repository.
   - Add your Gemini API key to the `.env` file. Use the `.env.example` file as a reference:
     ```bash
     GEMINI_API_KEY=your_api_key_here
     ```

3. **Set Up Aliases**:
   To run the scripts conveniently, set up the following aliases in your shell configuration file (e.g., `.bashrc`, `.zshrc`, or `.bash_profile`):

   ```bash
   alias git-add='sh <YOUR_LOCAL_DIRECTORY>/shell-scripts/git_add.sh'
   alias git-commit='sh <YOUR_LOCAL_DIRECTORY>/shell-scripts/git_commit.sh'
   alias git-push='sh <YOUR_LOCAL_DIRECTORY>/shell-scripts/git_push.sh'
   alias git-pull='sh <YOUR_LOCAL_DIRECTORY>/shell-scripts/git_pull.sh'
   alias git-change-date='sh <YOUR_LOCAL_DIRECTORY>/shell-scripts/git_change_commit_date.sh'
   ```

   After adding these aliases, reload your shell configuration:

   ```bash
   source ~/.zshrc  # or ~/.bashrc, depending on your shell
   ```

## Usage

1. **Add Files**:

   ```bash
   git-add
   ```

   Select files to stage interactively.

2. **Commit Changes**:

   ```bash
   git-commit
   ```

   Generate a commit message using AI or input it manually.

3. **Push Changes**:

   ```bash
   git-push
   ```

   Push the current branch to the remote repository.

4. **Pull Changes**:

   ```bash
   git-pull
   ```

   Pull changes from the remote repository with options for rebase or fast-forward.

5. **Change Commit Date**:
   ```bash
   git-change-date
   ```
   Amend the date of the last commit interactively.

## Logs

- Logs for prompts and API responses are stored in the `logs/` directory for debugging purposes.

## Notes

- Ensure you are in the root of a Git repository when running these scripts.
- The scripts rely on staged changes for generating commit messages and performing commits.
