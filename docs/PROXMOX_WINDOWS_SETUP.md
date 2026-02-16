# Setting Up Windows VM on Proxmox for iPhone Sideloading

Complete guide to creating a Windows 11 VM on your Proxmox box for installing VisionClaw on your iPhone.

## Overview

We'll create a Windows 11 VM that:
- Runs on your Proxmox box (AMD Ryzen 9 5900X)
- Has USB passthrough for iPhone
- Runs Sideloadly for app installation
- Uses 8GB RAM, 4 CPU cores, 60GB disk

## Prerequisites

Your Proxmox box specs:
- ✅ AMD Ryzen 9 5900X (12 cores, 24 threads)
- ✅ 62GB RAM (plenty available)
- ✅ 3.4TB storage on local-lvm
- ✅ Network access from your Linux machine

## Step 1: Download Windows 11 ISO

You need to get the Windows 11 ISO onto Proxmox first.

### Option A: Download via Proxmox Web UI (Easiest)

1. **Access Proxmox**: Open https://192.168.68.52:8006
   - Username: `root`
   - Password: `decafbad00`

2. **Navigate to ISO storage:**
   - Left panel → Expand "Datacenter"
   - Click on your node → "local (your-node)"
   - Click "ISO Images" tab

3. **Download Windows 11:**
   - Click "Download from URL" button
   - Get the URL from Microsoft:
     - Go to https://www.microsoft.com/software-download/windows11
     - Click "Download Windows 11 (64-bit)"
     - Right-click the download button → "Copy Link Address"
   - Paste the URL into Proxmox
   - Filename: `Win11_24H2_English_x64.iso`
   - Click "Query URL" → "Download"
   - Wait ~5-10 minutes for 6GB download

### Option B: Upload from Your Machine

If you already have a Windows 11 ISO:

```bash
# Download from Microsoft (on your Linux machine)
wget -O Win11.iso "https://www.microsoft.com/software-download/windows11"

# Upload to Proxmox
scp Win11.iso root@192.168.68.52:/var/lib/vz/template/iso/
```

### Option C: Use Tiny11 (Lighter, Unofficial)

For a smaller Windows installation (~4GB vs 6GB):

```bash
# On Proxmox directly:
ssh root@192.168.68.52
cd /var/lib/vz/template/iso/
wget https://archive.org/download/tiny-11-NTDEV/tiny11%202311%20x64.iso -O Tiny11.iso
```

**Note**: Tiny11 is an unofficial lightweight Windows 11. Use official ISO for production.

## Step 2: Run the Automated Setup Script

We have a script that creates the entire VM automatically!

```bash
cd /home/ajlennon/data_drive/ai/VisionClaw
./scripts/setup-windows-vm.sh
```

The script will:
1. Check for Windows ISO
2. Create VM (ID: 200, Name: windows-dev)
3. Configure 8GB RAM, 4 CPU cores, 60GB disk
4. Enable UEFI + TPM 2.0 (required for Windows 11)
5. Setup network bridge
6. Configure display and USB

Takes ~30 seconds to run.

## Step 3: Install Windows 11

### Start the VM

**Via Web UI:**
1. Go to https://192.168.68.52:8006
2. Left panel → Select VM "200 (windows-dev)"
3. Click "Start" button (top right)
4. Click "Console" to open display

**Via SSH:**
```bash
ssh root@192.168.68.52 "qm start 200"
```

### Windows Installation Process

1. **Language/Region**: Select English (or your preference) → Next

2. **Install Now** → Click it

3. **Product Key**: Click "I don't have a product key"
   - You can activate later or use without activation
   - Most features work fine unactivated

4. **Edition**: Select "Windows 11 Pro" → Next
   - Pro edition is better for VM use

5. **License Agreement**: Accept → Next

6. **Installation Type**: Choose "Custom: Install Windows only (advanced)"

7. **Partition**: 
   - You'll see "Drive 0 Unallocated Space" (60GB)
   - Click "New" → "Apply" → "Next"
   - Windows will create system partitions automatically

8. **Wait for Installation**: ~10-15 minutes
   - VM will reboot automatically

9. **OOBE (Out of Box Experience)**:
   - **Region**: Select your region
   - **Keyboard**: Select your keyboard layout
   - **Network**: Click "I don't have internet" (skip for faster setup)
   - **Account**: 
     - Click "Skip for now" to avoid Microsoft account
     - Create local account: Username: `dev`, Password: (your choice)
   - **Privacy**: Disable everything (faster setup, can enable later)
   - **Cortana**: Skip

10. **First Boot**: Wait for desktop (~2 minutes)

## Step 4: Install Essential Software

### A. VirtIO Guest Drivers (Better Performance)

In Windows VM:

1. Open Edge browser (or download Chrome/Firefox first)
2. Go to: https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/
3. Download latest: `virtio-win-guest-tools.exe`
4. Run installer → Install all drivers
5. Reboot VM

### B. iTunes (Apple USB Drivers)

Required for iPhone detection:

1. Go to: https://www.apple.com/itunes/download/win64
2. Download iTunes installer (~250MB)
3. Install iTunes
4. Reboot VM

**Note**: You don't need to run iTunes, just need the drivers installed.

### C. Sideloadly (IPA Installer)

Main tool for installing IPAs:

1. Go to: https://sideloadly.io/
2. Download Windows version
3. Run installer (simple wizard)
4. Launch Sideloadly

## Step 5: Setup iPhone USB Passthrough

This allows Windows VM to see your iPhone.

### Find Your iPhone USB ID

On your Linux machine (with iPhone plugged in):

```bash
lsusb | grep Apple
```

Output example:
```
Bus 001 Device 005: ID 05ac:12a8 Apple Inc. iPhone
```

Note the vendor:product ID: `05ac:12a8`

### Add USB Device in Proxmox

**Via Web UI:**

1. Go to https://192.168.68.52:8006
2. Select VM "200 (windows-dev)"
3. Click "Hardware" tab
4. Click "Add" → "USB Device"
5. Select "Use USB Vendor/Device ID"
6. In dropdown, find "Apple Inc." or enter `05ac:12a8`
7. Check "USB3" for better performance
8. Click "Add"

**Via SSH:**

```bash
ssh root@192.168.68.52 "qm set 200 -usb1 host=05ac:12a8,usb3=1"
```

### Test iPhone Detection

1. **Unplug iPhone** from Linux machine
2. **Plug iPhone** back in
3. **In Windows VM**: 
   - Open Device Manager (Win+X → Device Manager)
   - Expand "Portable Devices"
   - Should see "Apple iPhone"

If not detected:
- Make sure iTunes is installed (provides drivers)
- Try different USB port on host
- Restart Windows VM
- On iPhone: Unlock → Trust this computer

## Step 6: Install VisionClaw IPA

### Get the IPA

**Option A**: Download in Windows VM:
1. Open browser in Windows VM
2. Go to: https://github.com/DynamicDevices/VisionClaw/actions
3. Click latest successful run
4. Download artifact: `VisionClaw-iPhone-...`
5. Extract `CameraAccess.ipa`

**Option B**: Transfer from Linux:
```bash
# If Windows has SSH enabled (or use SMB share)
scp /home/ajlennon/data_drive/ai/VisionClaw/CameraAccess.ipa user@WINDOWS_VM_IP:Desktop/
```

### Install with Sideloadly

1. **Open Sideloadly** in Windows VM

2. **Connect iPhone**:
   - Plug in via USB
   - Should appear in device dropdown at top
   - If not: Check USB passthrough, install iTunes

3. **Load IPA**:
   - Drag `CameraAccess.ipa` into Sideloadly
   - Or click "IPA file" and browse

4. **Enter Apple ID**:
   - Your Apple ID email
   - For 2FA: Use app-specific password (generate at appleid.apple.com)

5. **Advanced Options** (optional):
   - Bundle ID: Can customize or leave default
   - Device Name: Leave default

6. **Click "Start"**:
   - Sideloadly will:
     - Download certificates from Apple
     - Sign the IPA
     - Install to iPhone
   - Takes 2-3 minutes
   - Shows progress: "Signing... Installing... Done!"

7. **Success**: You'll see "Successfully installed CameraAccess"

### Trust Developer Certificate on iPhone

1. On iPhone: **Settings** → **General** → **VPN & Device Management**
2. Under "Developer App", tap your Apple ID
3. Tap "Trust [Your Apple ID]"
4. Confirm trust

### Launch VisionClaw!

Open VisionClaw app on iPhone. Should launch!

**Note**: App has placeholder API keys. You'll need to update and rebuild.

## Troubleshooting

### Windows Won't Install - TPM Error

**Error**: "This PC can't run Windows 11 - TPM 2.0"

**Fix**: VM already has TPM enabled. If you still see this:
- Press Shift+F10 during install
- Type: `regedit` and press Enter
- Navigate to: `HKEY_LOCAL_MACHINE\SYSTEM\Setup`
- Right-click Setup → New → Key → Name it "LabConfig"
- Inside LabConfig, create two DWORD values:
  - `BypassTPMCheck` = 1
  - `BypassSecureBootCheck` = 1
- Close regedit, go back to installer, click Back then Next

### iPhone Not Detected in Windows

**Problem**: iPhone doesn't appear in Sideloadly

**Solutions**:
1. Install iTunes (provides Apple USB drivers)
2. Verify USB passthrough in Proxmox (Hardware tab)
3. Try different USB port on Linux host
4. Restart Windows VM
5. On iPhone: Settings → Reset → Reset Location & Privacy
6. Unplug/replug, trust again

### Sideloadly Errors

**"Maximum apps reached"**
- Free Apple ID limited to 3 sideloaded apps
- Delete one app from iPhone
- Settings → General → VPN & Device Management → Delete old apps

**"Provisioning profile error"**
- Wrong Apple ID/password
- For 2FA: Use app-specific password (appleid.apple.com)
- Wait 5 minutes and try again (rate limit)

**"Developer mode not enabled" (iOS 16+)**
- Settings → Privacy & Security → Developer Mode → Enable
- Restart iPhone

### VM is Slow

**Improve performance**:
1. Install VirtIO guest drivers (Step 4A)
2. In Proxmox: VM → Hardware
   - Change CPU type to "host"
   - Enable "Use local CPU" checkbox
3. Allocate more RAM if needed: VM → Hardware → Memory → Edit

### Can't Access VM Console

**Use noVNC console**:
- Proxmox UI → VM → Console
- If blank: Reboot VM
- Alternative: Enable RDP in Windows, connect from Linux

## Windows 11 Activation

The VM will work fine without activation, but you'll see a watermark.

**Options**:
1. **Use without activation** (fully functional, just has watermark)
2. **Buy Windows 11 license** (~$139)
3. **Use existing Windows 10/11 key** (if you have one)
4. **Transfer license** from another PC (OEM keys don't transfer)

To activate: Settings → Activation → Enter product key

## Optimizations

### Reduce Disk Usage

After installation, Windows takes ~25-30GB. To free space:

1. **Disk Cleanup**:
   - Search "Disk Cleanup" → Run
   - Check all boxes
   - "Clean up system files"
   - Can free ~5-10GB

2. **Disable Hibernation**:
   ```cmd
   powercfg -h off
   ```
   Frees ~8GB (size of RAM)

3. **Disable Page File** (if you have plenty of RAM):
   - System → Advanced → Performance Settings
   - Advanced → Virtual Memory → Uncheck "Automatically manage"
   - Select "No paging file"
   - Frees 8GB

### Auto-Start with Proxmox

To start VM automatically when Proxmox boots:

```bash
ssh root@192.168.68.52 "qm set 200 -onboot 1"
```

### Snapshot Before Installing Apps

Good practice - take snapshot after clean Windows install:

```bash
ssh root@192.168.68.52 "qm snapshot 200 clean-install"
```

Restore later if needed:
```bash
ssh root@192.168.68.52 "qm rollback 200 clean-install"
```

## Summary

You now have:

1. ✅ Windows 11 VM on Proxmox
2. ✅ USB passthrough for iPhone
3. ✅ Sideloadly for IPA installation
4. ✅ Complete local development workflow

**Your Development Workflow**:
1. Code on Linux
2. Push to GitHub
3. CI builds IPA automatically
4. Download IPA
5. Install via Windows VM + Sideloadly
6. Test on iPhone

No cloud services, no monthly fees, full control!

## Next Steps

Once you verify VisionClaw installs:

1. Update API keys in `Secrets.swift`
2. Set up your OpenClaw server
3. Push → CI builds → Install → Test
4. Iterate!

Remember: Free Apple ID apps expire after 7 days, re-install as needed.

Happy developing! 🎉
