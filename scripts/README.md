# VisionClaw Scripts

Automation scripts for development and deployment.

## iPhone Installation

### `install-iphone.sh` - One-Command iPhone Installation ⭐

Automatically installs VisionClaw on your iPhone from Linux (no Mac required).

**Quick Start:**
```bash
./scripts/install-iphone.sh
```

The script will:
1. ✅ Install all required dependencies (libimobiledevice, usbmuxd, etc.)
2. ✅ Clone and setup AltServer-Linux
3. ✅ Detect your connected iPhone
4. ✅ Download the latest IPA from GitHub Actions
5. ✅ Sign and install using your Apple ID
6. ✅ Show next steps

**Requirements:**
- iPhone connected via USB
- iPhone unlocked and trusted
- Apple ID credentials (free)

**Environment Variables (Optional):**
```bash
# Set these to avoid entering credentials each time
export APPLE_ID='your@email.com'
export APPLE_PASSWORD='your-password'

./scripts/install-iphone.sh
```

**Troubleshooting:**

| Issue | Solution |
|-------|----------|
| "No iPhone detected" | Connect iPhone, unlock, tap "Trust" when prompted |
| "Permission denied" | Run `sudo systemctl start usbmuxd` |
| "Installation failed" | Check Apple ID credentials, ensure 2FA is not blocking |
| "App won't launch" | Settings → General → Device Management → Trust |

---

## Development Scripts

### `.github/scripts/setup-secrets.sh` - Interactive Secrets Setup

Creates your local `Secrets.swift` file with real API keys.

```bash
.github/scripts/setup-secrets.sh
```

### `.github/scripts/install-hooks.sh` - Install Git Hooks

Installs pre-commit hooks for SwiftLint.

```bash
.github/scripts/install-hooks.sh
```

---

## Workflow

**Typical development flow:**

1. **Make changes** to the code
2. **Push to GitHub** - CI builds new IPA automatically
3. **Run installation script** - updates app on your iPhone
   ```bash
   ./scripts/install-iphone.sh
   ```
4. **Test on iPhone** - your changes are live!

**Re-sign every 7 days:**
```bash
# Add to crontab for automatic weekly refresh
(crontab -l 2>/dev/null; echo "0 2 * * 0 cd /home/ajlennon/data_drive/ai/VisionClaw && ./scripts/install-iphone.sh") | crontab -
```

---

## Links

- **Installation Guide:** [docs/INSTALL_FROM_LINUX.md](../docs/INSTALL_FROM_LINUX.md)
- **Development Guide:** [docs/DEVELOPMENT.md](../docs/DEVELOPMENT.md)
- **CI Builds:** https://github.com/DynamicDevices/VisionClaw/actions
