# 🎉 VisionClaw iPhone Installation - Ready!

## What You Have Now

✅ **IPA Built:** `CameraAccess.ipa` (11MB) - Ready to install  
✅ **Installation Script:** `scripts/install-iphone.sh` - One-command setup  
✅ **CI Pipeline:** Builds new IPA on every push automatically  
✅ **Complete Documentation:** Everything you need to know

## Install on Your iPhone Right Now

### Step 1: Connect iPhone

1. Plug iPhone into your Linux PC via USB
2. Unlock iPhone
3. When prompted "Trust This Computer?" → **Tap Trust**
4. Enter iPhone passcode if asked

### Step 2: Run the Installation Script

```bash
cd /home/ajlennon/data_drive/ai/VisionClaw
./scripts/install-iphone.sh
```

The script will:
- Install all needed dependencies automatically
- Setup AltServer-Linux
- Download latest IPA (or use existing)
- Ask for your Apple ID
- Sign and install the app

### Step 3: Trust on iPhone

After installation:
1. Open: **Settings → General → VPN & Device Management**
2. Tap your email address
3. Tap **Trust**

### Step 4: Launch VisionClaw! 🚀

The app icon will appear on your home screen.

---

## Important Notes

⚠️ **The current IPA has placeholder API keys!**

The app will launch, but won't connect to Gemini until you add real API keys.

### Quick Fix Options:

**Option A: Runtime Configuration (Coming Soon)**
I can add a Settings UI where you enter API keys at runtime.

**Option B: Build with Real Keys (~$2-3)**
1. Rent a cloud Mac for 1 hour
2. Build with real secrets
3. Install that IPA instead

For now, **Option A is recommended** - let me know if you want me to implement it!

---

## Development Workflow

Once you want to make changes:

```bash
# 1. Edit code on your Linux system
vim samples/CameraAccess/CameraAccess/SomeFile.swift

# 2. Push to GitHub
git add .
git commit -m "Add feature"
git push

# 3. CI builds new IPA automatically (wait ~2 minutes)

# 4. Reinstall on iPhone
./scripts/install-iphone.sh

# 5. Test!
```

---

## Troubleshooting

### "No iPhone detected"
```bash
# Check if usbmuxd is running
sudo systemctl status usbmuxd

# If not, start it
sudo systemctl start usbmuxd

# Check for devices
idevice_id -l
```

### "Command not found: idevice_id"
```bash
# Install libimobiledevice
sudo apt install libimobiledevice-utils usbmuxd
```

### "Installation failed"
- Make sure iPhone is unlocked
- Try unplugging and reconnecting iPhone
- Check Apple ID credentials are correct
- Disable 2FA temporarily if issues persist

### "App won't open / crashes immediately"
This is expected! The IPA has placeholder API keys. Either:
- Wait for Settings UI (I can add this)
- Build with real keys using cloud Mac

---

## Next Steps

Ready to try it? Just:

```bash
cd /home/ajlennon/data_drive/ai/VisionClaw
./scripts/install-iphone.sh
```

After installation, let me know:
1. Did it install successfully?
2. Do you want me to add the Settings UI for entering API keys at runtime?

---

**Files:**
- IPA: `/home/ajlennon/data_drive/ai/VisionClaw/CameraAccess.ipa`
- Script: `/home/ajlennon/data_drive/ai/VisionClaw/scripts/install-iphone.sh`
- Guide: `/home/ajlennon/data_drive/ai/VisionClaw/docs/INSTALL_FROM_LINUX.md`
