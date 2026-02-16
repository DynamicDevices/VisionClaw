# QR Code Configuration - Quick Start Guide

## What Was Added

VisionClaw now supports **in-app QR code configuration** - you can install the pre-built IPA from GitHub Actions and configure your API keys by scanning a QR code. No rebuild required!

## How to Use

### 1. Generate Your QR Code

You have several options:

#### Option A: Online QR Generator (Easiest)
1. Go to https://www.qr-code-generator.com/
2. Paste your Gemini API key: `AIzaSyDf8m5H1vV5xR8J2qK3pN7wL4mT9sY6uX0`
3. Download the QR code image

#### Option B: Use the Python Script
```bash
cd VisionClaw

# Install dependencies (one time)
pip3 install qrcode pillow

# Generate QR code
./scripts/generate-config-qr.py --key "AIzaSyDf8m5H1vV5xR8J2qK3pN7wL4mT9sY6uX0"
```

This will create `visionclaw_config.png` with your API key.

#### Option C: Full JSON Configuration
For multiple settings (OpenClaw, WebRTC, etc):

```bash
./scripts/generate-config-qr.py
# Follow the interactive prompts
```

### 2. Install VisionClaw IPA

Wait for the CI build to complete (check: https://github.com/DynamicDevices/VisionClaw/actions)

Download the latest IPA artifact: `VisionClaw-iPhone-XXXXXX.zip`

Install via Sideloadly on your Windows VM (as before).

### 3. Configure via QR Code

1. Open VisionClaw on your iPhone
2. Tap the **Settings** icon (gear icon)
3. Tap **"Scan QR Code for Config"**
4. Point your iPhone camera at the QR code
5. The app will automatically detect and import your API key
6. Tap **"Save"**

Done! Your API key is now configured.

### 4. Test It

1. Tap "Start on iPhone" 
2. Tap the AI button
3. Talk to Gemini - it should work!

## What Gets Configured

The QR code can contain:
- **Gemini API Key** (required for AI features)
- **OpenClaw settings** (optional - for tool calling)
- **WebRTC settings** (optional)
- **Custom system prompts** (optional)

### Simple Format (Just API Key)
Just the API key string:
```
AIzaSyDf8m5H1vV5xR8J2qK3pN7wL4mT9sY6uX0
```

### JSON Format (Multiple Settings)
```json
{
  "geminiAPIKey": "AIzaSyDf8m5H1vV5xR8J2qK3pN7wL4mT9sY6uX0",
  "openClawHost": "http://192.168.1.100",
  "openClawPort": 18789
}
```

## Security Notes

⚠️ **Important:**
- QR codes are **readable by anyone** who can see them
- **Don't share** QR code images publicly
- **Delete** QR code images after scanning
- Store QR codes in a password manager if you need to keep them

## Advantages of This Approach

✅ **No rebuild needed** - just scan to configure
✅ **No Xcode required** - works with pre-built IPA
✅ **Easy key rotation** - generate new QR, scan, done
✅ **Portable** - same IPA works for everyone, configure individually
✅ **GitHub Secrets not needed** - keys stay on your device only

## Files Changed

- `samples/CameraAccess/CameraAccess/Settings/QRCodeScannerView.swift` - New QR scanner
- `samples/CameraAccess/CameraAccess/Settings/SettingsView.swift` - Added scan button
- `scripts/generate-config-qr.py` - QR code generator script
- `docs/QR_CODE_CONFIG.md` - Full documentation
- `README.md` - Updated with QR setup instructions

## Next Steps

Once the CI build completes (~3-5 minutes), you can:

1. Download the IPA artifact from GitHub Actions
2. Install on your iPhone via Sideloadly
3. Generate a QR code with your real Gemini API key
4. Scan it in the app
5. Start using VisionClaw!

No more rebuilding every time you need to change an API key! 🎉
