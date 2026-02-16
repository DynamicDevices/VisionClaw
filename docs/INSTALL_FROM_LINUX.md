# Installing VisionClaw on iPhone from Linux

Your IPA is built and ready! Here's how to install it on your iPhone from Linux.

## Prerequisites

- iPhone with iOS 17.0+
- USB cable
- Apple ID (free, no paid developer account needed)
- Linux PC (your current system)

## Method 1: AltStore (Recommended) ⭐

AltStore lets you sideload apps using your free Apple ID.

### Install AltServer on Linux

```bash
# Download AltServer-Linux
git clone https://github.com/NyaMisty/AltServer-Linux.git
cd AltServer-Linux

# Install dependencies
sudo apt install -y libimobiledevice-utils usbmuxd libplist-utils \
  libavahi-compat-libdnssd-dev python3-pip

# Install Python dependencies
pip3 install -r requirements.txt

# Run AltServer
sudo python3 altserver.py
```

### Install the App

1. **Connect iPhone via USB**
   ```bash
   # Check iPhone is detected
   idevice_id -l
   ```

2. **Install VisionClaw IPA**
   ```bash
   cd /home/ajlennon/data_drive/ai/VisionClaw
   
   # Sideload the IPA
   sudo python3 ~/AltServer-Linux/altinstaller.py \
     --appleid YOUR_APPLE_ID@EMAIL.COM \
     --password YOUR_APPLE_PASSWORD \
     CameraAccess.ipa
   ```

3. **Trust Developer on iPhone**
   - Settings → General → VPN & Device Management
   - Tap your email
   - Tap "Trust"

4. **Launch VisionClaw!**

### Important Notes

- App expires after **7 days** with free Apple ID
- Re-run AltServer weekly to refresh
- Or get Apple Developer account ($99/year) for 1-year validity

---

## Method 2: Sideloadly (GUI Alternative)

Easier if you prefer a graphical interface.

### Install Sideloadly

```bash
# Download from: https://sideloadly.io/
# Linux version available

# Or use Wine
sudo apt install wine
wine SideloadlySetup.exe
```

### Install Steps

1. Launch Sideloadly
2. Connect iPhone via USB
3. Drag `CameraAccess.ipa` into Sideloadly
4. Enter your Apple ID
5. Click "Start"
6. Trust developer on iPhone (Settings → General → Device Management)

---

## Method 3: Using Xcode on Remote Mac (Cloud)

If the above methods don't work, rent a Mac for 1 hour:

### Option A: Scaleway (Cheapest)

```bash
# ~€2.40 for a full session
# Sign up at: https://www.scaleway.com/en/bare-metal-apple-silicon/

# After creating instance:
ssh root@YOUR_MAC_IP

# On the Mac:
git clone https://github.com/DynamicDevices/VisionClaw.git
cd VisionClaw

# Create Secrets.swift (use your real API keys!)
.github/scripts/setup-secrets.sh

# Open in Xcode
open samples/CameraAccess/CameraAccess.xcodeproj

# In Xcode:
# 1. Select your connected iPhone
# 2. Sign with your Apple ID
# 3. Click Run ▶️
```

### Option B: AWS EC2 Mac

```bash
# ~$2-3 for a session
# Launch ec2-mac instance in AWS console
# Same steps as Scaleway
```

---

## Method 4: Self-Hosting IPA Server (Advanced)

Host your own iOS app distribution server.

### Setup nginx with HTTPS

```bash
# Install nginx
sudo apt install nginx certbot python3-certbot-nginx

# Get SSL certificate (required for iOS)
sudo certbot --nginx -d your-domain.com

# Copy IPA to web server
sudo cp CameraAccess.ipa /var/www/html/visionclaw.ipa
```

### Create manifest.plist

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>items</key>
    <array>
        <dict>
            <key>assets</key>
            <array>
                <dict>
                    <key>kind</key>
                    <string>software-package</string>
                    <key>url</key>
                    <string>https://your-domain.com/visionclaw.ipa</string>
                </dict>
            </array>
            <key>metadata</key>
            <dict>
                <key>bundle-identifier</key>
                <string>com.xiaoanliu.VisionClaw</string>
                <key>bundle-version</key>
                <string>1.0</string>
                <key>kind</key>
                <string>software</string>
                <key>title</key>
                <string>VisionClaw</string>
            </dict>
        </dict>
    </array>
</dict>
</plist>
```

### Install from Safari on iPhone

On your iPhone, open Safari and go to:
```
itms-services://?action=download-manifest&url=https://your-domain.com/manifest.plist
```

---

## Troubleshooting

### "Untrusted Developer"

- Settings → General → VPN & Device Management
- Tap your email → Trust

### "Unable to Install"

- Delete old VisionClaw if installed
- Restart iPhone
- Try again

### "App Keeps Crashing"

The IPA from CI has **placeholder API keys**. You need to:
1. Get a cloud Mac (Scaleway/AWS)
2. Build with real API keys
3. Or wait for proper code signing support

### Dependencies Not Working

The IPA needs:
- **Gemini API Key**: https://aistudio.google.com/apikey
- **OpenClaw Gateway**: Running on your network
- **Meta Ray-Ban Glasses**: Paired to iPhone

---

## Next Steps

Once installed:

1. **Configure Secrets** (if using cloud Mac build)
   - Open Settings in app
   - Enter Gemini API key
   - Configure OpenClaw endpoint

2. **Pair Meta Ray-Ban Glasses**
   - Open Meta View app
   - Pair your glasses
   - Switch to VisionClaw

3. **Test Connection**
   - Voice should stream to Gemini
   - Camera feed should work
   - Tool calls should route to OpenClaw

---

## Automated Refresh Script

To avoid 7-day expiry, create a weekly cron job:

```bash
# Create refresh script
cat > ~/refresh-visionclaw.sh << 'EOF'
#!/bin/bash
cd /home/ajlennon/data_drive/ai/VisionClaw

# Download latest IPA
gh run download --pattern "VisionClaw-iPhone-*" --dir /tmp

# Reinstall
sudo python3 ~/AltServer-Linux/altinstaller.py \
  --appleid YOUR_EMAIL \
  --password YOUR_PASSWORD \
  /tmp/CameraAccess.ipa
EOF

chmod +x ~/refresh-visionclaw.sh

# Add to crontab (runs every Sunday at 2 AM)
(crontab -l 2>/dev/null; echo "0 2 * * 0 /home/ajlennon/refresh-visionclaw.sh") | crontab -
```

---

## Links

- **AltServer-Linux**: https://github.com/NyaMisty/AltServer-Linux
- **Sideloadly**: https://sideloadly.io/
- **CI Builds**: https://github.com/DynamicDevices/VisionClaw/actions
- **Gemini API**: https://aistudio.google.com/apikey
- **OpenClaw**: https://github.com/nichochar/openclaw

---

**Current IPA Location:**
```
/home/ajlennon/data_drive/ai/VisionClaw/CameraAccess.ipa
```

**Size:** 11MB  
**Built:** 2026-02-15  
**Commit:** d46349e
