#!/bin/bash
#
# iPhone Connection Diagnostic Script
#

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}  iPhone Connection Diagnostics${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo ""

# Check 1: USB Detection
echo -e "${YELLOW}1. USB Hardware Detection${NC}"
APPLE_USB=$(lsusb | grep -i apple)
if [ -n "$APPLE_USB" ]; then
    echo -e "${GREEN}✅ iPhone detected via USB${NC}"
    echo "   $APPLE_USB"
else
    echo -e "${RED}❌ No Apple device found via USB${NC}"
    echo "   → Plug in iPhone via USB cable"
    exit 1
fi
echo ""

# Check 2: libimobiledevice installed
echo -e "${YELLOW}2. libimobiledevice Tools${NC}"
if command -v idevice_id >/dev/null 2>&1; then
    echo -e "${GREEN}✅ libimobiledevice-utils installed${NC}"
    idevice_id --version 2>&1 | head -1
else
    echo -e "${RED}❌ libimobiledevice-utils not installed${NC}"
    echo "   → Run: sudo apt install libimobiledevice-utils usbmuxd"
    exit 1
fi
echo ""

# Check 3: usbmuxd service
echo -e "${YELLOW}3. usbmuxd Service${NC}"
if systemctl is-active --quiet usbmuxd; then
    echo -e "${GREEN}✅ usbmuxd is running${NC}"
    echo "   PID: $(pgrep usbmuxd)"
else
    echo -e "${RED}❌ usbmuxd is not running${NC}"
    echo "   → Starting usbmuxd..."
    sudo systemctl start usbmuxd
    sleep 2
fi
echo ""

# Check 4: usbmuxd socket
echo -e "${YELLOW}4. usbmuxd Socket${NC}"
if [ -S /var/run/usbmuxd ]; then
    echo -e "${GREEN}✅ Socket exists${NC}"
    ls -la /var/run/usbmuxd
else
    echo -e "${RED}❌ Socket not found${NC}"
    exit 1
fi
echo ""

# Check 5: Device pairing
echo -e "${YELLOW}5. Device Pairing Status${NC}"
DEVICE_ID=$(idevice_id -l 2>/dev/null | head -1)

if [ -z "$DEVICE_ID" ]; then
    echo -e "${RED}❌ No paired device found${NC}"
    echo ""
    echo -e "${YELLOW}📱 Troubleshooting Steps:${NC}"
    echo ""
    echo "On your iPhone:"
    echo "  1. Make sure iPhone is UNLOCKED (not on lock screen)"
    echo "  2. If you see 'Trust This Computer?' → Tap TRUST"
    echo "  3. Enter your iPhone passcode"
    echo "  4. Wait 5 seconds"
    echo "  5. Run this script again"
    echo ""
    echo "If already trusted:"
    echo "  1. Unplug iPhone"
    echo "  2. Restart usbmuxd: sudo systemctl restart usbmuxd"
    echo "  3. Plug iPhone back in"
    echo "  4. Run this script again"
    echo ""
    exit 1
else
    echo -e "${GREEN}✅ Device paired successfully!${NC}"
    echo "   UDID: $DEVICE_ID"
fi
echo ""

# Check 6: Get device info
echo -e "${YELLOW}6. Device Information${NC}"
DEVICE_NAME=$(ideviceinfo -k DeviceName 2>/dev/null || echo "Unknown")
DEVICE_VERSION=$(ideviceinfo -k ProductVersion 2>/dev/null || echo "Unknown")
DEVICE_MODEL=$(ideviceinfo -k ProductType 2>/dev/null || echo "Unknown")

echo -e "${GREEN}✅ Connected to:${NC}"
echo "   Name: $DEVICE_NAME"
echo "   Model: $DEVICE_MODEL"
echo "   iOS: $DEVICE_VERSION"
echo "   UDID: $DEVICE_ID"
echo ""

# Success!
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${GREEN}🎉 iPhone is ready for installation!${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo ""
echo "You can now run:"
echo "  ./scripts/install-iphone.sh"
echo ""
