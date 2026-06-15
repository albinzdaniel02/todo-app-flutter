# Recovery Guidelines: Resuming Work After Network Interruption or Server Restarts

This guide details the procedure for resuming development work when a network issue, server restart, API quota limit, or subagent disconnection occurs. Follow these steps to restore the workspace state and progress without repeating completed tasks.

---

## 1. Verify Current Local Branch & Workspace Status
Check the current branch name and any unstaged or untracked changes:
```bash
git branch
git status
```
- The active branch name generally maps directly to the active Task ID (e.g., branch `P6-2` corresponds to task `P6-2`).
- Check `git status` to see what files were modified or created locally.

## 2. Inspect Pull Requests (PRs)
Determine if a Pull Request has already been opened for the task branch:
```bash
gh pr list --state all
```
If a PR is open:
- View the PR details, status, and any review comments:
  ```bash
  gh pr view <pr-number>
  gh pr status
  ```
- Run the local test suite to verify code compilation and correctness:
  ```bash
  flutter test
  ```

## 3. Identify where the Interruption Occurred
Depending on the state discovered in the previous steps, handle recovery as follows:

### Case A: Code Implementation Incomplete
- Look at modified files in `git status`.
- **CRITICAL**: Do NOT waste time reading the entire codebase. Focus only on files listed in `git status`, or run `git diff main...HEAD` to review what was already implemented.
- Continue implementation and testing.

### Case B: Implementation Complete but PR Review Interrupted
- If the PR is open and all tests pass locally:
  - Define and invoke a newly created unbiased code reviewer subagent (`pr-reviewer`).
  - Provide it with the PR diff and context (e.g., "all existing tests are passing").
  - Do not waste time having the reviewer perform redundant global checks.
  - Address reviewer feedback, commit, and push.

### Case C: PR Merged but Tracking/Checklist Unfinished
- If the branch is merged (check `git log` or `gh pr list --state merged`):
  - Switch back to `main` and pull: `git checkout main && git pull origin main`
  - Update `todo.md` to check off the task.
  - Update `todo_progress.md` in the artifacts directory.
  - Commit and push `todo.md` changes.

---

## 4. Redeploying the Subagent
To redeploy a subagent to resume a task:
1. Identify the task specifications (e.g., from `todo.md` or previous task contexts).
2. Spawn a new subagent of type `todo-executor` (or appropriate executor).
3. Explicitly instruct the new subagent in its prompt:
   - *“Your predecessor was interrupted due to a network disconnection/restart.”*
   - *“PR #<number> is already open on branch <branch-name> with passing tests.”*
   - *“Resume the work from the PR review and merge steps. Do not read the entire codebase; only inspect the files changed in the PR.”*
