# Quick Start Guide - VisionClaw on iPhone

**Goal**: Get VisionClaw running on your iPhone in under 10 minutes.

## Prerequisites Checklist

- [ ] Mac with Xcode 15+ installed
- [ ] iPhone with iOS 17+ 
- [ ] USB cable to connect iPhone to Mac
- [ ] Apple ID (free, no paid account needed)
- [ ] Gemini API key from https://aistudio.google.com/apikey

---

## Step-by-Step Setup

### 1. Clone & Setup (2 minutes)

```bash
# Clone the repository
git clone git@github.com:DynamicDevices/VisionClaw.git
cd VisionClaw

# Install SwiftLint (for code quality)
brew install swiftlint

# Install git hooks (optional but recommended)
.github/scripts/install-hooks.sh

# Run the interactive setup script
.github/scripts/setup-secrets.sh
```

**What this does:**
- Copies `Secrets.swift.template` → `Secrets.swift`
- Prompts for your Gemini API key
- Optionally configures OpenClaw (skip for now if testing basic features)
- Sets up pre-commit linting (keeps code clean)

**Alternative (manual):**
```bash
cp samples/CameraAccess/CameraAccess/Secrets.swift.template \
   samples/CameraAccess/CameraAccess/Secrets.swift

# Edit and add your API key
nano samples/CameraAccess/CameraAccess/Secrets.swift
```

### 2. Open Project (30 seconds)

```bash
open samples/CameraAccess/CameraAccess.xcodeproj
```

Wait for Xcode to open and resolve Swift Package dependencies (~2-5 minutes first time).

### 3. Configure Signing (1 minute)

**In Xcode:**

1. Click on **CameraAccess** project (top of left sidebar)
2. Select **CameraAccess** target
3. Click **Signing & Capabilities** tab
4. Check **☑ Automatically manage signing**
5. Under **Team**, select **your Apple ID**
   - If not listed: Click **Add Account...** → Sign in with Apple ID

**Bundle ID**: Already set to `com.dynamicdevices.visionclaw` ✅

### 4. Connect iPhone (1 minute)

1. Connect iPhone to Mac via USB
2. Unlock iPhone
3. On iPhone: Tap **Trust** when "Trust This Computer?" appears
4. In Xcode: Select **your iPhone** from device dropdown (top toolbar)

### 5. Build & Run (2 minutes)

1. Click **Run ▶️** button (or press `Cmd+R`)
2. Wait for build to complete (~1-2 minutes)
3. **On iPhone**: Popup appears "Untrusted Developer"
   - Go to **Settings** → **General** → **VPN & Device Management**
   - Tap your Apple ID under "Developer App"
   - Tap **Trust "[Your Apple ID]"**
   - Tap **Trust** on confirmation
4. Back in Xcode: Click **Run ▶️** again
5. App launches on your iPhone! 🎉

---

## First Test: iPhone Camera Mode

**No glasses needed for this test!**

1. Launch VisionClaw on iPhone
2. Tap **"Start on iPhone"** button
3. Tap the **AI button** 🎤 (big circular button)
4. Point your iPhone camera at something interesting
5. Say: **"What am I looking at?"**
6. Wait 2-3 seconds
7. Gemini will respond with audio describing what it sees! 🎉

**Try these:**
- "What am I looking at?"
- "Describe this scene in detail"
- "What colors do you see?"
- "Read any text you can see"

---

## Troubleshooting

### "Secrets.swift not found"
```bash
# Run the setup script
.github/scripts/setup-secrets.sh
```

### "Gemini API key not configured"
- Open `samples/CameraAccess/CameraAccess/Secrets.swift`
- Replace `YOUR_GEMINI_API_KEY` with your real key from https://aistudio.google.com/apikey
- Rebuild (Cmd+R)

### "Signing requires a development team"
- Xcode → Signing & Capabilities
- Select your Apple ID under "Team"
- If not there: Add Account → Sign in

### "Untrusted Developer" on iPhone
- Settings → General → VPN & Device Management
- Trust your Apple ID certificate
- Try launching app again

### "Failed to install app"
- Try: Xcode → Product → Clean Build Folder (Cmd+Shift+K)
- Then: Run again (Cmd+R)

### Build takes forever
- First build downloads dependencies (~5-10 min)
- Subsequent builds much faster (~30 sec)

---

## Next Steps

### Add OpenClaw for Agentic Actions

Once basic testing works, enable OpenClaw to let the AI take actions:

1. **Setup OpenClaw** on your AI hardware:
   ```bash
   npm install -g @openclaw/cli
   openclaw gateway restart
   ```

2. **Update Secrets.swift** with your server details:
   ```swift
   static let openClawHost = "http://YOUR_SERVER_IP"
   static let openClawPort = 18789
   static let openClawGatewayToken = "your-token"
   ```

3. **Rebuild app** (Cmd+R)

4. **Test it**: "Add milk to my shopping list"

See [OpenClaw Setup](docs/DEVELOPMENT.md#openclaw-integration) for details.

### Test with Meta Ray-Ban Glasses

1. **Install Meta AI app** on iPhone
2. **Pair your glasses** in Meta AI app
3. **Enable Developer Mode**: Settings → App Info → Tap version 5 times
4. **In VisionClaw**: Tap "Connect Glasses" → "Start Streaming"
5. **AI sees through your glasses!** 👓

---

## Common Questions

**Q: Do I need to pay for Apple Developer Program?**  
A: No! Free Apple ID works for personal testing (7-day certificates).

**Q: Can I distribute this to others?**  
A: Not with free provisioning. Need paid Developer Program ($99/year) for TestFlight/App Store.

**Q: Why does it expire after 7 days?**  
A: Free provisioning limitation. Just rebuild when it expires.

**Q: Can I test without glasses?**  
A: Yes! Use "Start on iPhone" mode with your phone's camera.

**Q: Is OpenClaw required?**  
A: No, it's optional. App works without it (voice + vision only).

**Q: Where's my data stored?**  
A: Nowhere! Everything is real-time. No recording, no storage.

---

## Success Checklist

- [ ] App builds without errors
- [ ] App launches on iPhone
- [ ] "Start on iPhone" mode works
- [ ] AI button responds to voice
- [ ] Camera feed shows in preview
- [ ] Gemini responds to "What am I looking at?"
- [ ] Audio plays from iPhone speaker

**If all checked: You're ready to go! 🚀**

---

## Get Help

- **Full documentation**: [docs/DEVELOPMENT.md](DEVELOPMENT.md)
- **Main README**: [../README.md](../README.md)
- **GitHub Issues**: https://github.com/DynamicDevices/VisionClaw/issues
- **Gemini API**: https://ai.google.dev/gemini-api/docs/live
- **Meta DAT SDK**: https://wearables.developer.meta.com/docs/

---

**Build Time**: ~10 minutes  
**Difficulty**: Easy  
**Cost**: $0 (free API keys + free Apple ID)

Happy hacking! 🦞😎
