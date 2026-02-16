# SwiftLint Guide for VisionClaw

This guide explains the linting setup and how to use SwiftLint effectively.

---

## Overview

**SwiftLint** is a tool to enforce Swift style and conventions. It helps maintain code quality and consistency across the project.

**When it runs:**
- ✅ **Pre-commit**: Automatically before each git commit (if hook installed)
- ✅ **CI Pipeline**: On every push to GitHub
- ✅ **Manually**: Run `swiftlint` command anytime

---

## Installation

```bash
# Install via Homebrew (recommended)
brew install swiftlint

# Verify installation
swiftlint version
```

---

## Pre-Commit Hook Setup

### Install the Hook

```bash
# One-time setup
.github/scripts/install-hooks.sh
```

This installs a pre-commit hook that:
1. Runs SwiftLint on staged Swift files
2. Blocks commits if linting fails
3. Shows clear error messages
4. Suggests fixes

### How It Works

```bash
# Make changes to Swift files
vim samples/CameraAccess/CameraAccess/Gemini/GeminiConfig.swift

# Stage your changes
git add .

# Commit (hook runs automatically)
git commit -m "Update config"

# If linting passes: ✅ Commit succeeds
# If linting fails: ❌ Commit blocked with error details
```

### Bypass Hook (Emergency Only)

```bash
# Skip pre-commit checks (not recommended)
git commit --no-verify -m "Emergency fix"
```

**Warning**: CI will still run SwiftLint, so issues will surface anyway.

---

## Manual Usage

### Lint All Files

```bash
# From project root
swiftlint
```

### Lint Specific File

```bash
swiftlint lint --path samples/CameraAccess/CameraAccess/Gemini/GeminiLiveService.swift
```

### Auto-Fix Issues

```bash
# Fix issues that can be corrected automatically
swiftlint autocorrect

# Review what was changed
git diff
```

### Strict Mode

```bash
# Treat warnings as errors
swiftlint lint --strict
```

This is what CI uses - all warnings must be fixed.

---

## Configuration

### Configuration File

**Location**: `.swiftlint.yml` in project root

### Key Rules

| Rule | Warning | Error | Description |
|------|---------|-------|-------------|
| Line Length | 120 chars | 150 chars | Keep lines readable |
| File Length | 500 lines | 800 lines | Split large files |
| Function Length | 50 lines | 100 lines | Keep functions focused |
| Cyclomatic Complexity | 15 | 25 | Reduce nested logic |

### Custom Rules

**No print statements**:
```swift
// ❌ Bad
print("Debug info")

// ✅ Good
NSLog("[Debug] Info")
```

**Avoid force unwrapping**:
```swift
// ❌ Bad
let value = optional!

// ✅ Good
guard let value = optional else { return }
```

**Prefer isEmpty**:
```swift
// ❌ Bad
if array.count == 0 { }

// ✅ Good
if array.isEmpty { }
```

---

## Common Issues & Fixes

### Issue: Line Too Long

```
warning: Line Length Violation: Line should be 120 characters or less: currently 135 characters
```

**Fix**:
```swift
// Before (135 chars)
let message = "This is a very long message that exceeds the line length limit and should be broken up"

// After (< 120 chars per line)
let message = """
  This is a very long message that exceeds the line length limit \
  and should be broken up
  """
```

### Issue: Function Too Long

```
warning: Function Body Length Violation: Function body should span 50 lines or less
```

**Fix**: Extract helper functions
```swift
// Before (80 lines)
func processData() {
  // ... 80 lines of code
}

// After
func processData() {
  validateInput()
  transformData()
  saveResults()
}

private func validateInput() { /* ... */ }
private func transformData() { /* ... */ }
private func saveResults() { /* ... */ }
```

### Issue: Force Unwrap

```
warning: Avoid force unwrapping
```

**Fix**:
```swift
// Before
let url = URL(string: "https://example.com")!

// After
guard let url = URL(string: "https://example.com") else {
  return
}
```

### Issue: Unused Import

```
warning: Unused Import: 'UIKit' is not used
```

**Fix**: Remove unused imports
```swift
// Before
import UIKit      // Not actually used
import Foundation

// After
import Foundation
```

---

## CI Integration

### GitHub Actions

SwiftLint runs in CI as part of the build workflow:

```yaml
- name: Run SwiftLint
  run: |
    cd samples/CameraAccess/CameraAccess
    swiftlint lint --strict --reporter github-actions-logging
```

**Strict mode** means:
- All warnings treated as errors
- Build fails if any issues found
- Forces clean code before merging

### Viewing Results

1. Go to **GitHub Actions** tab
2. Click on the failed workflow
3. Expand **Run SwiftLint** step
4. See detailed error messages with file locations

---

## Best Practices

### 1. Fix Issues Incrementally

Don't try to fix all linting issues at once:
```bash
# Lint one file at a time
swiftlint lint --path File1.swift
swiftlint autocorrect --path File1.swift
git add File1.swift
git commit -m "Fix linting in File1"
```

### 2. Run Before Committing

```bash
# Check for issues before staging
swiftlint

# Auto-fix what you can
swiftlint autocorrect

# Stage and commit
git add .
git commit -m "Clean code changes"
```

### 3. Use Editor Integration

**Xcode**: SwiftLint integrates automatically if installed
- Issues show as yellow warnings in editor
- Build warnings include SwiftLint violations

**VS Code**: Install SwiftLint extension
```bash
code --install-extension vknabel.vscode-swiftlint
```

### 4. Disable Rules Sparingly

Only disable rules when absolutely necessary:
```swift
// swiftlint:disable force_cast
let value = json as! String  // Documented reason why this is safe
// swiftlint:enable force_cast
```

---

## Troubleshooting

### Hook Not Running

```bash
# Check if hook is installed
ls -la .git/hooks/pre-commit

# Reinstall if missing
.github/scripts/install-hooks.sh
```

### SwiftLint Not Found

```bash
# Install SwiftLint
brew install swiftlint

# Verify installation
which swiftlint
swiftlint version
```

### Too Many Violations

```bash
# See summary instead of all violations
swiftlint lint --quiet

# Focus on errors only
swiftlint lint --strict | grep "error:"
```

### Autocorrect Breaks Code

```bash
# Undo autocorrect changes
git checkout -- .

# Review changes before accepting
swiftlint autocorrect
git diff  # Review carefully
```

---

## Excluding Files

### Temporary Exclusion

```swift
// At top of file
// swiftlint:disable all

// Your code here

// swiftlint:enable all
```

### Permanent Exclusion

Edit `.swiftlint.yml`:
```yaml
excluded:
  - samples/CameraAccess/CameraAccess/LegacyCode.swift
  - samples/CameraAccess/CameraAccess/ThirdParty/
```

---

## Statistics

### View Project Stats

```bash
# Count violations by rule
swiftlint lint | grep -oE "[a-z_]+ Violation" | sort | uniq -c

# Total violation count
swiftlint lint --quiet | wc -l
```

### Track Progress

```bash
# Save current state
swiftlint lint --quiet > lint_before.txt

# Make improvements
# ...

# Compare
swiftlint lint --quiet > lint_after.txt
diff lint_before.txt lint_after.txt
```

---

## FAQ

**Q: Do I need SwiftLint to contribute?**  
A: No, but it's strongly recommended. CI will catch issues anyway.

**Q: Can I disable specific rules?**  
A: Yes, edit `.swiftlint.yml` and add to `disabled_rules`.

**Q: What if I disagree with a rule?**  
A: Open a PR to discuss changing the configuration.

**Q: Does SwiftLint slow down builds?**  
A: Minimal impact (~5-10 seconds). Pre-commit hook only checks staged files.

**Q: Can I run SwiftLint in Xcode?**  
A: Yes, add a Run Script build phase with: `swiftlint`

---

## Resources

- **SwiftLint Repo**: https://github.com/realm/SwiftLint
- **Rule Directory**: https://realm.github.io/SwiftLint/rule-directory.html
- **Configuration**: https://github.com/realm/SwiftLint#configuration
- **Editor Integration**: https://github.com/realm/SwiftLint#editor-integration

---

**Keep your code clean! 🧹✨**
