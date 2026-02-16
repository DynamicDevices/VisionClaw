# Installing VisionClaw IPA via Proxmox Windows VM

Perfect solution for your setup! You already have a Windows VM on Proxmox, so we can use that.

## Overview

1. Transfer IPA to Windows VM
2. Setup USB passthrough (one-time)
3. Install Sideloadly
4. Sign and install IPA

Total time: 5-10 minutes

## Step 1: Transfer the IPA to Windows VM

Your IPA is ready at: `/home/ajlennon/data_drive/ai/VisionClaw/CameraAccess.ipa` (11MB)

### Option A: Download from GitHub Actions (Easiest)
In Windows VM browser:
1. Go to: https://github.com/DynamicDevices/VisionClaw/actions
2. Click latest successful run: "Add iPhone connection diagnostic..."
3. Scroll down to "Artifacts"
4. Download: `VisionClaw-iPhone-5db9aab...`
5. Extract the IPA file

### Option B: Network Share/SCP
If you have network access between Linux and Windows VM:
```bash
# From Linux, if Windows has SSH:
scp /home/ajlennon/data_drive/ai/VisionClaw/CameraAccess.ipa user@WINDOWS_VM_IP:Desktop/

# Or use SMB/shared folder
```

### Option C: Via Proxmox Host
```bash
# Copy to a shared location on Proxmox host
scp /home/ajlennon/data_drive/ai/VisionClaw/CameraAccess.ipa root@192.168.68.52:/tmp/

# Then access from Windows VM
```

## Step 2: Setup USB Passthrough (One-time Setup)

This allows your iPhone to be seen by the Windows VM.

### In Proxmox Web Interface (https://192.168.68.52:8006):

1. **Login** with root credentials
2. **Select your Windows VM** from the left panel
3. **Go to "Hardware" tab**
4. **Click "Add"** → **"USB Device"**
5. **Select "Use USB Vendor/Device ID"**
6. **Find your iPhone:**
   - Look for "Apple Inc." (Vendor ID: `05ac`)
   - Or your specific iPhone model
7. **Click "Add"**
8. **Restart the Windows VM** (or hot-plug if supported)

### Verify in Windows:
- Plug in your iPhone
- Should see "Apple iPhone" in Device Manager
- If not detected, install **iTunes** (provides Apple USB drivers)

## Step 3: Install Sideloadly on Windows VM

**Download:** https://sideloadly.io/

1. Download the Windows version
2. Run the installer (it's very simple, ~10MB)
3. No configuration needed - it's ready to use!

**Alternative:** AltStore (https://altstore.io/) also works

## Step 4: Install the IPA

### In Sideloadly:

1. **Connect your iPhone** via USB
   - Should appear in the device dropdown at top
   - If not: Install iTunes, trust computer on iPhone

2. **Drag and drop** `CameraAccess.ipa` into Sideloadly window
   - Or click "IPA file" and browse

3. **Enter your Apple ID:**
   - Use your regular Apple ID (iCloud email)
   - Or create a new free Apple ID for development

4. **Enter password:**
   - Your Apple ID password
   - Or app-specific password if you have 2FA enabled

5. **Click "Start"**
   - Takes 2-3 minutes
   - Shows progress: Signing → Installing → Done

6. **Look for "Successfully installed"** message

## Step 5: Trust Developer Certificate on iPhone

1. On your iPhone: **Settings** → **General** → **VPN & Device Management**
2. Under "Developer App", find your Apple ID
3. Tap it → **"Trust [Your Apple ID]"**
4. Confirm

## Step 6: Launch VisionClaw!

Open the VisionClaw app on your iPhone. 

**Note:** The app currently has placeholder API keys. You'll need to:
- Set up your OpenClaw server
- Add your Anthropic Claude API key
- Rebuild and reinstall

But the app should launch and show the UI!

## Troubleshooting

### iPhone Not Detected in Windows

**Problem:** iPhone doesn't appear in Sideloadly

**Solutions:**
1. Install **iTunes** in Windows (provides Apple USB drivers)
2. Check USB passthrough in Proxmox is enabled
3. Try different USB port on host
4. Unplug/replug iPhone
5. On iPhone: Unlock → Trust this computer

### Sideloadly Errors

**"Lockdown error" / "Pairing failed"**
- Unplug iPhone
- Delete existing pairing: On iPhone, Settings → General → Reset → Reset Location & Privacy
- Replug, trust again

**"Provisioning profile error"**
- Apple ID/password incorrect
- For 2FA accounts: Use app-specific password (generate at appleid.apple.com)
- Free accounts limited to 3 apps (delete one if needed)

**"Maximum number of apps"**
- Free Apple ID can only install 3 apps at a time
- Delete an old sideloaded app

**"Developer Mode not enabled" (iOS 16+)**
- Settings → Privacy & Security → Developer Mode → Enable
- Restart iPhone

### 7-Day Expiry

**Free Apple ID apps expire after 7 days**

When app expires:
1. Re-run Sideloadly with same IPA
2. Takes 2 minutes
3. No need to delete old app

To avoid:
- Pay $99/year for Apple Developer Account (1-year certificates)
- Or use AltStore with AltServer running 24/7 (auto-refreshes)

## Summary

You now have a complete local development workflow:

1. **Code on Linux** (your main machine)
2. **CI builds on GitHub** (free macOS runners)
3. **Install via Windows VM** (your Proxmox box)
4. **Test on iPhone**

No cloud Macs needed, no complex Linux tools!

## Next Steps

Once you verify the app installs and launches:

1. Update API keys in `Secrets.swift`
2. Set up your OpenClaw server
3. Push changes → GitHub builds new IPA
4. Download and reinstall via Sideloadly

Happy coding! 🎉
