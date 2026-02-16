# Installing VisionClaw IPA on iPhone from Linux - Practical Workarounds

## The Problem

Installing unsigned IPAs on iPhone from Linux is technically complex because it requires:
1. Signing the IPA with an Apple ID (generating provisioning profiles)
2. Installing the signed IPA to the device

All Linux tools (AltServer-Linux, pymobiledevice3, etc.) have significant setup complexity.

## Recommended Solutions (Ranked by Practicality)

### Solution 1: Cloud Mac Service (Easiest, $1-5)

Use a cloud Mac service for a few minutes to sign and install:

**MacinCloud** (pay-as-you-go, ~$1/hour):
1. Go to https://www.macincloud.com
2. Rent a Mac for 1 hour (~$1)
3. Upload your IPA
4. Open Xcode → Window → Devices and Simulators
5. Connect your iPhone via USB (you'll need to set up USB passthrough)
6. Drag IPA to your device
7. Done!

**Alternative**: MacStadium, AWS EC2 Mac instances

### Solution 2: Windows VM + Sideloadly (Free, but slower)

If you have enough RAM on your Linux machine:

1. Install VirtualBox or QEMU
2. Create a Windows 10/11 VM
3. Pass through USB to VM (for iPhone connection)
4. Download Sideloadly: https://sideloadly.io/
5. Use Sideloadly GUI to sign and install (enter Apple ID)

**Time**: ~30 min setup, 5 min per install

### Solution 3: Friend with Mac (Easiest if available)

1. Send them the IPA
2. They use Xcode or Apple Configurator to install
3. Takes 2 minutes

### Solution 4: iOS App Installer Services (Easiest, but  security risk)

**WARNING**: These services require your Apple ID. Use with caution or create a throwaway Apple ID.

Services like:
- AppDB (requires account)
- AltStore Online services

**Not recommended** for production/sensitive apps.

### Solution 5: Complete Linux Setup (Complex, for reference)

For the truly determined, here's what a complete Linux setup requires:

1. Install AltServer-Linux dependencies:
```bash
sudo apt install clang++ cmake libboost-all-dev libssl-dev \
  libcpprest-dev libavahi-compat-libdnssd-dev
```

2. Build AltServer-Linux:
```bash
cd ~/AltServer-Linux
git submodule update --init --recursive
mkdir build && cd build
make -f ../Makefile -j$(nproc)
```

3. Run AltServer:
```bash
./AltServer -u <UDID> -a <AppleID> -p <Password> path/to/app.ipa
```

**Problem**: Complex build system, frequent API changes, maintenance burden.

## Our Recommendation

For one-time installation: **Use Cloud Mac** (MacinCloud for $1)

For frequent development: **Set up Windows VM** with Sideloadly

For convenience: **Find a friend with a Mac** ☺️

## Current Status

The VisionClaw IPA is ready at:
```
/home/ajlennon/data_drive/ai/VisionClaw/CameraAccess.ipa
```

Your iPhone is connected and paired. You just need a signing/installation method.

## 7-Day Expiry Note

Remember: Free provisioning profiles expire after 7 days. You'll need to:
- Re-sign and re-install the app every 7 days
- OR pay $99/year for Apple Developer account (1-year signing)

## Next Steps

1. Choose your preferred method above
2. Download the IPA from `CameraAccess.ipa`
3. Follow the chosen method to sign and install
4. Trust the developer certificate on your iPhone (Settings → General → VPN & Device Management)
5. Launch VisionClaw!

---

**Note**: Once installed, remember to update `Secrets.swift` with your actual API keys for OpenClaw and Anthropic Claude.
