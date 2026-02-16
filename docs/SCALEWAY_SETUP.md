# Setting Up Scaleway Mac Mini for iOS Development

Complete guide to setting up a Scaleway Mac mini for building and installing VisionClaw on your iPhone.

## Overview

**Scaleway Mac mini m1** is a cost-effective cloud Mac solution:
- **Price**: €0.10/hour (~€2.40 for a full day, €72/month if you keep it)
- **Hardware**: Apple M1 Mac mini (8-core CPU, 8GB RAM)
- **Use case**: Perfect for occasional iOS builds and sideloading
- **Location**: EU data centers (Paris/Amsterdam)

**Cost Optimization**:
- Pay-as-you-go: Only pay when running (~€2-3 per development session)
- Stop when not in use (still charged for storage: ~€0.12/hour when stopped)
- Delete when done (no ongoing costs)

## Prerequisites

- Scaleway account (free to create)
- Credit card for billing
- SSH key pair (we'll generate if needed)
- Your VisionClaw IPA ready

## Step 1: Create Scaleway Account

1. **Sign up**: Go to https://console.scaleway.com/register
   - Email and password
   - Verify email

2. **Add payment method**:
   - Console → Billing → Payment methods
   - Add credit card (required even for free tier)

3. **Verify identity**:
   - May require ID verification (photo of ID/passport)
   - Usually instant, sometimes takes a few hours

## Step 2: Generate SSH Key (if needed)

On your Linux machine:

```bash
# Check if you already have SSH keys
ls -la ~/.ssh/id_*.pub

# If not, generate new key pair
ssh-keygen -t ed25519 -C "your_email@example.com"
# Press Enter to use default location
# Set passphrase (optional but recommended)

# Display your public key (you'll need this)
cat ~/.ssh/id_ed25519.pub
```

## Step 3: Create Mac mini Instance

### Via Scaleway Console (Web UI)

1. **Login**: https://console.scaleway.com

2. **Navigate to Apple silicon**:
   - Left menu → "Apple silicon" (under Compute)
   - Or direct link: https://console.scaleway.com/apple-silicon/servers

3. **Click "Create Instance"**

4. **Choose availability zone**:
   - **PAR1** (Paris, France) - Usually more availability
   - **AMS1** (Amsterdam, Netherlands) - Alternative
   - Pick whichever is available (Mac minis often have waitlists)

5. **Select Mac mini type**:
   - **Mac mini m1** (recommended)
     - 8-core CPU, 8GB RAM
     - €0.10/hour when running
     - €0.12/hour when stopped
   - **Mac mini m2** (if available)
     - 8-core CPU, 16GB RAM
     - More expensive, probably overkill

6. **Choose OS image**:
   - **macOS Ventura** (recommended)
   - Or macOS Monterey / Sonoma if preferred
   - Fresh install, ready to use

7. **Configure instance**:
   - **Name**: `visionclaw-build`
   - **Tags**: `development`, `ios` (optional)
   - **Advanced options** (optional):
     - Can set hostnames, cloud-init scripts
     - Usually not needed

8. **Add SSH key**:
   - Click "Add SSH key"
   - Paste your public key (from `~/.ssh/id_ed25519.pub`)
   - Give it a name: `my-linux-machine`

9. **Review and create**:
   - Review configuration
   - Check estimated cost: ~€0.10/hour
   - Click "Create Instance"

10. **Wait for provisioning**:
    - Takes 2-5 minutes
    - Status changes: "Starting" → "Running"
    - Note the **Public IP address** (e.g., `51.158.123.45`)

### Via Scaleway CLI (Alternative)

Install Scaleway CLI:

```bash
# Install scw CLI
curl -s https://raw.githubusercontent.com/scaleway/scaleway-cli/master/scripts/get.sh | sh

# Configure
scw init
# Enter access key and secret key (from console.scaleway.com/iam/api-keys)

# Create Mac mini
scw apple-silicon server create \
  type=mac-mini-m1 \
  zone=fr-par-3 \
  name=visionclaw-build \
  os=macos_ventura

# Get server details
scw apple-silicon server list
```

## Step 4: Connect to Your Mac mini

### Get Connection Details

From Scaleway console:
- Click on your instance
- Note the **Public IPv4** (e.g., `51.158.123.45`)
- Default username: `m1` (or `admin` depending on image)

### SSH Connection

```bash
# Connect via SSH
ssh m1@51.158.123.45

# Or with specific key
ssh -i ~/.ssh/id_ed25519 m1@51.158.123.45

# First time: Accept host key fingerprint (type 'yes')
```

**If connection fails**:
- Wait 5 minutes after creation (Mac still booting)
- Check SSH key is correct
- Try username `admin` instead of `m1`
- Verify Mac is in "Running" state

### Enable VNC (Optional, for GUI access)

If you want graphical access:

```bash
# On the Mac mini (via SSH):
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart \
  -activate -configure -access -on \
  -restart -agent -privs -all

# Set VNC password
sudo /usr/bin/dscl . -passwd /Users/m1 YourPassword
```

Then connect with VNC client:
- Address: `51.158.123.45:5900`
- Password: (password you set)

## Step 5: Setup Development Environment

### Install Xcode Command Line Tools

```bash
# SSH to Mac
ssh m1@51.158.123.45

# Install Xcode CLI tools
xcode-select --install
# If GUI prompt: Click "Install"

# Verify installation
xcode-select -p
# Should output: /Library/Developer/CommandLineTools
```

### Install Homebrew (Optional but Recommended)

```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add to PATH (copy the commands shown after install)
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# Verify
brew --version
```

### Install GitHub CLI (for downloading artifacts)

```bash
brew install gh

# Authenticate with GitHub
gh auth login
# Follow prompts, choose HTTPS, authenticate via browser
```

## Step 6: Clone Your Project

```bash
# Clone VisionClaw repository
gh repo clone DynamicDevices/VisionClaw
cd VisionClaw

# Or with git directly:
git clone git@github.com:DynamicDevices/VisionClaw.git
cd VisionClaw
```

## Step 7: Open Project in Xcode

### Option A: Via Command Line

```bash
cd VisionClaw/samples/CameraAccess
open CameraAccess.xcodeproj
```

### Option B: Via VNC

1. Connect with VNC client
2. Navigate to project folder
3. Double-click `CameraAccess.xcodeproj`

### First-Time Setup in Xcode

1. **Trust project**: Click "Trust and Open"

2. **Install additional components** (if prompted)

3. **Configure signing**:
   - Select `CameraAccess` target
   - Go to "Signing & Capabilities" tab
   - **Team**: Select your Apple ID
     - If not listed: Xcode → Settings → Accounts → Add Account
     - Sign in with your Apple ID
   - **Bundle Identifier**: Change to unique ID (e.g., `com.yourdomain.visionclaw`)
   - Xcode will automatically create provisioning profile

4. **Verify build**:
   - Product → Build (⌘B)
   - Should succeed without errors

## Step 8: Connect iPhone and Install

### Option A: USB over Network (Recommended)

Xcode supports wireless iPhone connections:

1. **Enable on iPhone**:
   - Settings → General → Transfer or Reset iPhone → Reset
   - Actually: Use USB first time, then enable "Connect via network"

2. **Initial USB connection**:
   - You'll need to physically connect iPhone to Mac mini once
   - Or use USB/IP forwarding (complex)

**Problem**: Scaleway Mac minis don't have easy USB passthrough.

### Option B: Generate IPA and Install via Sideloadly (Easier!)

Instead of direct USB, build IPA and install from your Linux machine:

#### On Scaleway Mac:

```bash
# Navigate to project
cd ~/VisionClaw/samples/CameraAccess

# Build and archive
xcodebuild archive \
  -project CameraAccess.xcodeproj \
  -scheme CameraAccess \
  -configuration Release \
  -archivePath build/CameraAccess.xcarchive \
  CODE_SIGN_STYLE=Automatic \
  DEVELOPMENT_TEAM=YOUR_TEAM_ID

# Export IPA
xcodebuild -exportArchive \
  -archivePath build/CameraAccess.xcarchive \
  -exportPath build/ipa \
  -exportOptionsPlist ExportOptions.plist

# Create ExportOptions.plist if needed:
cat > ExportOptions.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>development</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
EOF
```

#### Download IPA to Linux:

```bash
# From your Linux machine
scp m1@51.158.123.45:~/VisionClaw/samples/CameraAccess/build/ipa/CameraAccess.ipa ~/
```

#### Install via Sideloadly:

Use your Windows VM (from earlier) or Linux tools to install the signed IPA.

### Option C: Use Apple Configurator (Requires second Mac)

If you have access to another Mac locally, you can use Apple Configurator 2.

## Step 9: Optimize Costs

### Stop Instance When Not In Use

```bash
# From your Linux machine
scw apple-silicon server stop <SERVER_ID>

# Or via web console: Instance → Stop
```

**Cost when stopped**: ~€0.12/hour (just storage)

### Start When Needed

```bash
scw apple-silicon server start <SERVER_ID>

# Or via web console: Instance → Start
```

Takes 2-3 minutes to boot.

### Delete Instance When Done

If you don't need it for a while:

```bash
scw apple-silicon server delete <SERVER_ID>

# Or via web console: Instance → More options → Delete
```

**Important**: 
- Delete terminates permanently
- Backup any important data first
- Can recreate anytime (takes 5 minutes)

### Snapshots (Optional)

Save your configured environment:

```bash
# Create snapshot of configured Mac
scw apple-silicon server create-snapshot <SERVER_ID>

# Create new instance from snapshot
scw apple-silicon server create \
  type=mac-mini-m1 \
  snapshot-id=<SNAPSHOT_ID>
```

**Cost**: ~€0.02/GB/month for snapshots

## Step 10: Automate Your Workflow

### Create Build Script

Save this on your Scaleway Mac:

```bash
cat > ~/build-visionclaw.sh << 'EOF'
#!/bin/bash
set -e

cd ~/VisionClaw
git pull origin main

cd samples/CameraAccess

xcodebuild clean archive \
  -project CameraAccess.xcodeproj \
  -scheme CameraAccess \
  -configuration Release \
  -archivePath build/CameraAccess.xcarchive \
  CODE_SIGN_STYLE=Automatic \
  DEVELOPMENT_TEAM=YOUR_TEAM_ID

xcodebuild -exportArchive \
  -archivePath build/CameraAccess.xcarchive \
  -exportPath build/ipa \
  -exportOptionsPlist ExportOptions.plist

echo "✅ IPA ready at: build/ipa/CameraAccess.ipa"
ls -lh build/ipa/CameraAccess.ipa
EOF

chmod +x ~/build-visionclaw.sh
```

### Run from Linux

Create a wrapper script on your Linux machine:

```bash
cat > ~/scaleway-build.sh << 'EOF'
#!/bin/bash
# Build VisionClaw on Scaleway Mac and download IPA

SCALEWAY_IP="51.158.123.45"  # Replace with your Mac IP
SCALEWAY_USER="m1"

echo "🚀 Starting build on Scaleway Mac..."
ssh ${SCALEWAY_USER}@${SCALEWAY_IP} "~/build-visionclaw.sh"

echo "📥 Downloading IPA..."
scp ${SCALEWAY_USER}@${SCALEWAY_IP}:~/VisionClaw/samples/CameraAccess/build/ipa/CameraAccess.ipa ~/

echo "✅ Done! IPA saved to: ~/CameraAccess.ipa"
EOF

chmod +x ~/scaleway-build.sh
```

## Comparison: Scaleway vs GitHub Actions vs Proxmox Windows VM

| Solution | Setup Time | Cost | Pros | Cons |
|----------|-----------|------|------|------|
| **GitHub Actions** | 0 min (done!) | Free | Automated, no maintenance | Can't install directly to iPhone |
| **Scaleway Mac** | 10 min | €0.10/hr | Full Mac access, easy iPhone connection | Costs money, need to manage |
| **Proxmox Windows VM** | 30 min | Free | Free, local control | Requires Windows + Sideloadly setup |

## Recommended Workflow

**For your use case, I recommend:**

1. **Primary**: Use **GitHub Actions** (already working!)
   - Builds IPA on every push
   - Free and automatic
   - Download artifact

2. **Installation**: Use **Proxmox Windows VM** (we just set up)
   - Free (no ongoing costs)
   - Local control
   - Use Sideloadly to install IPA

3. **Occasional**: Use **Scaleway Mac mini** when needed
   - When you need full Xcode features
   - Testing on Simulator
   - Debugging Xcode-specific issues
   - Just start/stop as needed (~€2 per session)

## Security Best Practices

1. **SSH Keys**: Always use SSH keys, never passwords
2. **Firewall**: Scaleway has good default firewall rules
3. **Updates**: Keep macOS and Xcode updated
4. **Secrets**: Never commit API keys (already using Secrets.swift.template)
5. **Billing Alerts**: Set up in Scaleway console (€10/month warning)

## Troubleshooting

### Can't Connect via SSH

- Wait 5 minutes after creation
- Check instance is "Running" in console
- Verify SSH key is added correctly
- Try username `admin` instead of `m1`
- Check firewall rules (should allow port 22)

### Xcode Build Fails

- Install command line tools: `xcode-select --install`
- Accept Xcode license: `sudo xcodebuild -license accept`
- Clear build folder: `xcodebuild clean`
- Check signing team ID is correct

### High Costs

- **Stop instance** when not in use (€0.12/hr vs €0.10/hr running)
- **Delete instance** if not needed for weeks
- **Set billing alerts** in console
- Consider using GitHub Actions instead (free)

### iPhone Not Detected

- Scaleway Macs don't have easy USB access
- Use IPA export method instead (Option B above)
- Or use local Windows VM for final installation

## Next Steps

1. **Try it out**: Create a Mac mini for 1 hour (~€0.10)
2. **Build your app**: Test the workflow
3. **Decide**: Keep it or use GitHub Actions + Windows VM
4. **Optimize**: If keeping, set up automated builds

## Summary

Scaleway Mac mini is great for:
- ✅ Full Xcode access
- ✅ Pay-as-you-go pricing
- ✅ Quick setup
- ✅ Professional development

But for your specific VisionClaw workflow:
- GitHub Actions (free) + Proxmox Windows VM (free) is probably better
- Use Scaleway only when you need full Xcode/Simulator access

**Cost estimate for occasional use**:
- 2 hours/week × €0.10/hr = €0.80/month
- Very affordable for occasional builds!
