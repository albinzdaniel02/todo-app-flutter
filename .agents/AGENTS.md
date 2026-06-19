# Agent Rules

## Branching & PR Guidelines
1. **No Direct Commits/Pushes to `main`**:
   - Never commit or push code directly to the `main` branch.
   - All bug fixes, features, and enhancements must be implemented on a separate feature or task branch (e.g., `fix/priority-vibration` or `P5-4`).
   - Push the feature branch to remote and create a Pull Request on GitHub.
   - Review and merge the PR, then return to `main` locally and pull the latest changes.

2. **Formatting & Testing Verification**:
   - Always run `dart format .` to format the code before pushing.
   - Always verify that all tests pass by running `flutter test`.

3. **Git Pre-Push Hook**:
   - A local `pre-push` hook is configured in `.git/hooks/pre-push` to reject direct pushes to the `main` branch. Do not bypass or disable this hook.
