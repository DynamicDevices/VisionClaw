# GitHub CI Build Issue

## Status: ⚠️ BLOCKED - Requires Xcode Project Configuration

After 13 build attempts, we've identified the root cause preventing GitHub Actions CI from building this project.

## Root Cause

The Xcode project scheme `CameraAccess` is **not configured for iOS Simulator destinations**.

### Evidence

From Build #13 (`xcodebuild -showdestinations`):
```
Available destinations for the "CameraAccess" scheme:
	{ platform:iOS, id:dvtdevice-DVTiPhonePlaceholder-iphoneos:placeholder, 
	  name:Any iOS Device, 
	  error:iOS 18.1 is not installed. To use with Xcode, first download and install the platform }

xcodebuild: error: Found no destinations for the scheme 'CameraAccess' and action build-for-testing.
```

**Translation:** The scheme only knows about physical iOS devices, not simulators.

## Solution Required

Someone with **macOS + Xcode** needs to:

1. Open `samples/CameraAccess/CameraAccess.xcodeproj` in Xcode
2. Select **Product > Scheme > Edit Scheme...**
3. In the **Run** section, ensure destinations include iOS Simulator
4. **CRITICAL**: Edit the scheme to be "Shared" (checkbox in the scheme editor)
   - This creates `CameraAccess.xcscheme` in `xcshareddata/` folder
   - Without this, the scheme config stays local and won't be committed
5. Commit the scheme file:
   ```bash
   git add samples/CameraAccess/CameraAccess.xcodeproj/xcshareddata/
   git commit -m "Share CameraAccess scheme for CI builds"
   git push
   ```

## Alternative Workarounds

### Option A: Manual Testing Only
- Keep CI for linting/validation only (current state)
- Developers test compilation locally

### Option B: Use Upstream Scheme
- Check if upstream repository has a shared scheme
- If so, copy it over

### Option C: Create New Scheme
Create a CI-specific scheme via command line:
```bash
# This would need to be done on macOS
xcodebuild -project samples/CameraAccess/CameraAccess.xcodeproj \
  -scheme CameraAccess-CI \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -showBuildSettings > /dev/null
```

## What's Working Now

✅ **Implemented Successfully:**
- GitHub Actions workflow structure
- SwiftLint integration (informational, non-blocking)
- Secrets management with template
- Complete documentation
- Pre-commit hooks
- All infrastructure is in place

❌ **Blocked:**
- Actual compilation in CI
- Build validation

## Environment Details

- **Working Setup:** macOS-15, Xcode 16.1, iOS Simulator SDK 18.6
- **Project Created With:** Likely Xcode 16+ (incompatible with Xcode 15.2)
- **Issue:** Scheme configuration doesn't include simulator destinations

## Timeline

- Builds #1-7: Project file corruption issues (resolved by using upstream version + Xcode 16)
- Build #8: First successful package resolution (progress!)
- Builds #9-13: Destination resolution failures (root cause identified)

## Links

- [Build #13 Logs](https://github.com/DynamicDevices/VisionClaw/actions/runs/22036521068)
- [All CI Runs](https://github.com/DynamicDevices/VisionClaw/actions)
