# VisionClaw Development Guide

This guide covers everything you need to build and run VisionClaw on your iPhone for personal testing.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Detailed Setup](#detailed-setup)
- [Testing on Your iPhone](#testing-on-your-iphone)
- [OpenClaw Integration](#openclaw-integration)
- [Troubleshooting](#troubleshooting)
- [CI/CD Pipeline](#cicd-pipeline)

---

## Prerequisites

### Required
- **macOS** with Xcode 15.0+ installed
- **iPhone** running iOS 17.0+
- **Apple ID** (free, no paid Developer Program needed!)
- **Gemini API Key** (free from [Google AI Studio](https://aistudio.google.com/apikey))
- **Meta Ray-Ban smart glasses** (optional - can use iPhone camera for testing)

### Optional
- **OpenClaw** installed on your AI hardware for agentic actions
- **Meta AI app** on iPhone (for glasses connectivity)

---

## Quick Start

### 1. Clone the Repository

```bash
git clone git@github.com:DynamicDevices/VisionClaw.git
cd VisionClaw
```

### 2. Install Git Hooks (Recommended)

```bash
# Install pre-commit hook for code linting
.github/scripts/install-hooks.sh

# Install SwiftLint (required for pre-commit hook)
brew install swiftlint
```

This sets up automatic code quality checks before each commit.

### 3. Create Your Secrets Configuration

```bash
# Copy the template
cp samples/CameraAccess/CameraAccess/Secrets.swift.template \
   samples/CameraAccess/CameraAccess/Secrets.swift

# Edit with your real credentials
nano samples/CameraAccess/CameraAccess/Secrets.swift
```

**Minimum required configuration:**
```swift
enum Secrets {
  // Get this from: https://aistudio.google.com/apikey
  static let geminiAPIKey = "YOUR_ACTUAL_GEMINI_API_KEY"
  
  // Leave these as placeholders if not using OpenClaw yet
  static let openClawHost = "http://YOUR_MAC_HOSTNAME.local"
  static let openClawPort = 18789
  static let openClawHookToken = "YOUR_OPENCLAW_HOOK_TOKEN"
  static let openClawGatewayToken = "YOUR_OPENCLAW_GATEWAY_TOKEN"
  static let webrtcSignalingURL = "ws://localhost:8080"
}
```

### 3. Open in Xcode

```bash
open samples/CameraAccess/CameraAccess.xcodeproj
```

### 4. Configure Signing (First Time Only)

1. Select the **CameraAccess** project in the navigator
2. Select the **CameraAccess** target
3. Go to **Signing & Capabilities** tab
4. **Automatically manage signing**: ✅ Checked
5. **Team**: Select your personal Apple ID
   - If not listed, click "Add Account..." and sign in with your Apple ID
6. Xcode will automatically create a free provisioning profile

**Bundle Identifier**: Already set to `com.dynamicdevices.visionclaw`

### 5. Connect iPhone and Run

1. **Connect your iPhone** via USB
2. **Trust the computer** on your iPhone when prompted
3. In Xcode, select **your iPhone** from the device dropdown (top left)
4. Click **Run** ▶️ (or press Cmd+R)
5. **On your iPhone**: Go to Settings → General → VPN & Device Management
6. **Trust the developer certificate** for your Apple ID
7. Launch VisionClaw app on your iPhone

**Note**: Free provisioning builds expire after **7 days**. Just rebuild when needed!

---

## Detailed Setup

### Understanding Free Provisioning

Apple allows anyone with an Apple ID to:
- ✅ Build and run apps on **their own devices**
- ✅ Use **automatic signing** (no manual certificates needed)
- ✅ Test for **7 days** per build
- ❌ Cannot distribute to others
- ❌ Cannot use TestFlight
- ❌ Limited to 3 apps at a time per device

**This is perfect for personal testing!** No $99/year Developer Program required.

### Project Structure

```
VisionClaw/
├── samples/CameraAccess/
│   ├── CameraAccess.xcodeproj       # Xcode project
│   ├── CameraAccess/                # Source code
│   │   ├── Gemini/                  # Gemini Live API
│   │   ├── OpenClaw/                # Tool calling
│   │   ├── iPhone/                  # Fallback camera
│   │   ├── Views/                   # SwiftUI UI
│   │   ├── ViewModels/              # Business logic
│   │   ├── Settings/                # Config management
│   │   └── Secrets.swift            # YOUR credentials (git-ignored)
│   └── server/                      # WebRTC signaling (optional)
├── .github/workflows/               # CI/CD automation
└── docs/                            # Documentation
```

### Dependencies (Auto-Managed by SPM)

The project uses Swift Package Manager for dependencies:

1. **Meta Wearables DAT SDK** (`facebook/meta-wearables-dat-ios`)
   - Handles glasses connectivity and streaming
   - Auto-downloaded on first build

2. **WebRTC** (`stasel/WebRTC`)
   - For POV video streaming (optional feature)
   - Auto-downloaded on first build

**First build takes ~5-10 minutes** to download dependencies.

---

## Testing on Your iPhone

### Mode 1: iPhone Camera (No Glasses Needed)

**Use this for initial testing without glasses:**

1. Launch the app on your iPhone
2. Tap **"Start on iPhone"**
3. Tap the **AI button** 🎤
4. Point your phone's camera at something
5. Say "What am I looking at?"
6. Gemini will see through your camera and respond!

**Perfect for:**
- Testing the app works
- Verifying your Gemini API key
- Trying voice + vision features
- Developing without glasses hardware

### Mode 2: Meta Ray-Ban Glasses

**Requirements:**
- Meta Ray-Ban smart glasses
- Meta AI app on iPhone
- Developer Mode enabled in Meta AI app

**Enable Developer Mode:**
1. Open **Meta AI** app on iPhone
2. Go to **Settings** (gear icon, bottom left)
3. Tap **App Info**
4. Tap the **App version** number **5 times**
5. Go back to Settings → Enable **Developer Mode** toggle

**Use with glasses:**
1. Launch VisionClaw app
2. Tap **"Connect Glasses"** (if not auto-connected)
3. Tap **"Start Streaming"**
4. Tap the **AI button** 🎤
5. Gemini sees through your glasses camera!

---

## OpenClaw Integration

OpenClaw enables the AI to take real-world actions. **This is optional** - the app works without it (voice + vision only).

### What OpenClaw Enables

With OpenClaw, you can say:
- "Send a message to John saying I'll be late" → WhatsApp/iMessage/Telegram
- "Add milk to my shopping list" → Notes/Todoist/etc.
- "Search for coffee shops nearby" → Web search with spoken results
- "Turn off the living room lights" → Smart home control
- And much more (56+ integrated tools)

### Setup OpenClaw on Your AI Hardware

**Your scenario**: Internet-accessible AI hardware

1. **Install OpenClaw** on your server:
   ```bash
   # Follow: https://github.com/nichochar/openclaw
   npm install -g @openclaw/cli
   ```

2. **Configure the gateway** (`~/.openclaw/openclaw.json`):
   ```json
   {
     "gateway": {
       "port": 18789,
       "bind": "0.0.0.0",  // Listen on all interfaces (for internet access)
       "auth": {
         "mode": "token",
         "token": "your-secure-random-token-here"
       },
       "http": {
         "endpoints": {
           "chatCompletions": { "enabled": true }
         }
       }
     }
   }
   ```

3. **Start the gateway**:
   ```bash
   openclaw gateway restart
   ```

4. **Test from your iPhone's network**:
   ```bash
   curl http://YOUR_SERVER_IP:18789/health
   # Should return: {"status":"ok"}
   ```

5. **Update your Secrets.swift**:
   ```swift
   static let openClawHost = "http://YOUR_SERVER_IP"  // or domain
   static let openClawPort = 18789
   static let openClawGatewayToken = "your-secure-random-token-here"
   ```

6. **Rebuild the app** in Xcode

### Security Notes

- **Use HTTPS** in production (set up reverse proxy with SSL)
- **Use a strong token** (generate with `openssl rand -hex 32`)
- **Firewall rules** to limit access if needed
- The app checks OpenClaw connectivity on startup (green indicator = connected)

---

## Troubleshooting

### Build Issues

**"Secrets.swift not found"**
```bash
# You need to create this file from the template
cp samples/CameraAccess/CameraAccess/Secrets.swift.template \
   samples/CameraAccess/CameraAccess/Secrets.swift
```

**"Failed to resolve package dependencies"**
- Check internet connection
- Clean build folder: Xcode → Product → Clean Build Folder (Cmd+Shift+K)
- Try: Xcode → File → Packages → Reset Package Caches

**"Signing for 'CameraAccess' requires a development team"**
- Go to Signing & Capabilities
- Select your Apple ID under "Team"
- Enable "Automatically manage signing"

### Runtime Issues

**"Gemini API key not configured"**
- Open `Secrets.swift`
- Replace `YOUR_GEMINI_API_KEY` with your actual key
- Rebuild the app

**"Could not install the app on iPhone"**
- iPhone: Settings → General → VPN & Device Management
- Trust your developer certificate
- Try again

**"OpenClaw connection timeout"**
- Check your server is running: `curl http://YOUR_SERVER_IP:18789/health`
- Verify firewall allows port 18789
- Check token matches in both places
- Ensure your iPhone can reach the server (test with Safari: `http://YOUR_SERVER_IP:18789`)

**Echo/feedback in iPhone mode**
- This is normal with loudspeaker + mic
- The app mutes the mic while AI speaks
- Use headphones for better experience
- Glasses mode has no echo (remote mic)

**App expires after 7 days**
- This is normal with free provisioning
- Just rebuild and reinstall
- Or sign up for Apple Developer Program ($99/year) for 1-year certificates

### Glasses Issues

**Glasses not connecting**
- Enable Developer Mode in Meta AI app (see above)
- Ensure glasses are paired in Meta AI app first
- Try force-quit and relaunch VisionClaw app

**Video not streaming from glasses**
- Check glasses battery level
- Ensure glasses camera lens is clean
- Try: Meta AI app → Settings → Developer Mode → off/on toggle

---

## Code Quality & Linting

### SwiftLint Integration

The project uses SwiftLint to maintain code quality and consistency.

**Features**:
- Runs automatically in CI on every push
- Runs locally via pre-commit hook (if installed)
- Configuration in `.swiftlint.yml`
- Enforces Swift best practices

### Install SwiftLint

```bash
brew install swiftlint
```

### Setup Pre-Commit Hook

```bash
# Install the hook (one-time setup)
.github/scripts/install-hooks.sh

# Now SwiftLint runs automatically before each commit
```

### Manual Linting

```bash
# Lint all Swift files
swiftlint

# Lint specific file
swiftlint lint --path samples/CameraAccess/CameraAccess/Gemini/GeminiConfig.swift

# Auto-fix some issues
swiftlint autocorrect

# Strict mode (treats warnings as errors)
swiftlint lint --strict
```

### Bypass Hook (Not Recommended)

If you absolutely need to commit without linting:

```bash
git commit --no-verify -m "Emergency fix"
```

**Note**: CI will still run SwiftLint, so bypassing locally just delays the feedback.

### Common Lint Rules

Our configuration enforces:
- ✅ Line length: 120 chars (warning), 150 chars (error)
- ✅ Function length: 50 lines (warning), 100 lines (error)
- ✅ Cyclomatic complexity: 15 (warning), 25 (error)
- ✅ No print statements (use NSLog)
- ✅ Avoid force unwrapping (use optional binding)
- ✅ Prefer isEmpty over count == 0
- ✅ Use .first(where:) over .filter{}.first

See `.swiftlint.yml` for complete configuration.

---

## CI/CD Pipeline

### GitHub Actions Workflow

Every push to any branch triggers a build validation:

**What it does:**
- ✅ Installs SwiftLint
- ✅ Runs SwiftLint on all Swift files (strict mode)
- ✅ Builds the app for iOS Simulator
- ✅ Validates code compiles (no signing required)
- ✅ Resolves Swift Package dependencies
- ✅ Checks for warnings
- ✅ Uploads build logs

**What it doesn't do:**
- ❌ No code signing (can't sign with your Apple ID in CI)
- ❌ No TestFlight deployment (requires paid account)
- ❌ No unit tests yet (none exist currently)

**View build status:**
- GitHub → Actions tab
- Green ✅ = Build succeeded
- Red ❌ = Build failed (check logs)

### Running Locally Before Push

Always good to verify builds locally:

```bash
# Clean build
xcodebuild clean \
  -project samples/CameraAccess/CameraAccess.xcodeproj \
  -scheme CameraAccess

# Build for simulator
xcodebuild build \
  -project samples/CameraAccess/CameraAccess.xcodeproj \
  -scheme CameraAccess \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

---

## Development Workflow

### Typical Development Cycle

1. **Make code changes** in Xcode
2. **Test locally** on your iPhone (Cmd+R)
3. **Commit changes**: `git commit -am "Description"`
4. **Push to GitHub**: `git push origin main`
5. **GitHub Actions** validates the build automatically
6. **Check CI status** on GitHub (green = good to merge)

### Best Practices

- **Never commit `Secrets.swift`** (it's git-ignored, keep it that way!)
- **Test on real device** (simulators don't have camera/mic/glasses)
- **Check CI before merging** PRs
- **Use meaningful commit messages**
- **Test OpenClaw separately** before blaming the app

### Branch Strategy

- `main` - Stable, deployable code
- Feature branches for development
- CI runs on all branches (validates everything)

---

## Need Help?

1. **Check Troubleshooting** section above
2. **Review README.md** for general usage
3. **Check CI logs** if builds fail on GitHub
4. **Meta DAT SDK docs**: https://wearables.developer.meta.com/docs/
5. **Gemini Live API docs**: https://ai.google.dev/gemini-api/docs/live
6. **OpenClaw docs**: https://github.com/nichochar/openclaw

---

## Quick Reference

### Essential Files

| File | Purpose |
|------|---------|
| `Secrets.swift` | Your API keys (create from .template) |
| `GeminiConfig.swift` | Model and API configuration |
| `GeminiSessionViewModel.swift` | Main app logic |
| `OpenClawBridge.swift` | Tool execution client |

### Essential Commands

```bash
# Open project
open samples/CameraAccess/CameraAccess.xcodeproj

# Clean build
Cmd+Shift+K in Xcode

# Run on iPhone
Cmd+R in Xcode

# View git status
git status

# Push changes
git add . && git commit -m "message" && git push
```

### Build Configurations

- **Debug**: Full logging, larger binary (~150KB app)
- **Release**: Optimized, smaller binary (~100KB app)

For development: Always use **Debug** configuration.

---

**Happy developing! 🚀**
