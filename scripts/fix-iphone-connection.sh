#!/bin/bash
#
# Complete iPhone Setup and Connection Fix Script
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
echo -e "${BLUE}  iPhone Connection Setup & Fix${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
echo ""
echo "This script will fix common iPhone connection issues."
echo "You'll need to enter your sudo password."
echo ""
read -p "Press Enter to continue..."

# Step 1: Create udev rule for iOS devices
echo ""
echo -e "${YELLOW}Step 1: Creating udev rule for iOS devices...${NC}"
sudo tee /etc/udev/rules.d/39-usbmuxd.rules > /dev/null << 'EOF'
# usbmuxd (Apple Mobile Device Muxer listening on /var/run/usbmuxd)
# systemd should start it as a service when iOS devices are connected

# Skip other vendors
ATTR{idVendor}!="05ac", GOTO="usbmuxd_rules_end"

# Attach device to usbmuxd
ACTION=="add", ENV{USBMUX_SUPPORTED}="1", ENV{SYSTEMD_WANTS}="usbmuxd.service"
ACTION=="add", RUN+="/bin/systemctl start usbmuxd.service"

# Exit
LABEL="usbmuxd_rules_end"
EOF

echo -e "${GREEN}✅ udev rule created${NC}"

# Step 2: Reload udev rules
echo ""
echo -e "${YELLOW}Step 2: Reloading udev rules...${NC}"
sudo udevadm control --reload-rules
sudo udevadm trigger
echo -e "${GREEN}✅ udev rules reloaded${NC}"

# Step 3: Stop usbmuxd
echo ""
echo -e "${YELLOW}Step 3: Stopping usbmuxd...${NC}"
sudo systemctl stop usbmuxd
sudo pkill -9 usbmuxd 2>/dev/null || true
sleep 1
echo -e "${GREEN}✅ usbmuxd stopped${NC}"

# Step 4: Clear pairing cache
echo ""
echo -e "${YELLOW}Step 4: Clearing pairing cache...${NC}"
sudo rm -rf /var/lib/lockdown/*
echo -e "${GREEN}✅ Pairing cache cleared${NC}"

# Step 5: Start usbmuxd
echo ""
echo -e "${YELLOW}Step 5: Starting usbmuxd...${NC}"
sudo systemctl start usbmuxd
sleep 2
echo -e "${GREEN}✅ usbmuxd started${NC}"

# Step 6: Instructions for user
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
echo -e "${YELLOW}📱 NOW ON YOUR iPHONE:${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
echo ""
echo "1. UNPLUG the USB cable"
echo "2. UNLOCK your iPhone (Face ID/Touch ID/passcode)"
echo "3. Stay on the HOME SCREEN"
echo "4. PLUG USB cable back in"
echo "5. You should see: 'Trust This Computer?'"
echo "6. TAP 'Trust'"
echo "7. ENTER your iPhone passcode"
echo "8. Keep iPhone UNLOCKED"
echo ""
read -p "Press Enter AFTER you've done the above steps..."

# Step 7: Check for device
echo ""
echo -e "${YELLOW}Step 7: Checking for iPhone...${NC}"
sleep 2

for i in {1..10}; do
    DEVICE_ID=$(idevice_id -l 2>/dev/null | head -1)
    if [ -n "$DEVICE_ID" ]; then
        echo -e "${GREEN}✅ iPhone detected!${NC}"
        echo "   UDID: $DEVICE_ID"
        
        # Get device info
        echo ""
        echo "📱 Device Information:"
        ideviceinfo -k DeviceName 2>/dev/null | sed 's/^/   Name: /'
        ideviceinfo -k ProductType 2>/dev/null | sed 's/^/   Model: /'
        ideviceinfo -k ProductVersion 2>/dev/null | sed 's/^/   iOS: /'
        
        echo ""
        echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
        echo -e "${GREEN}🎉 Success! iPhone is connected and paired!${NC}"
        echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
        echo ""
        echo "You can now install VisionClaw:"
        echo "  ./scripts/install-iphone.sh"
        echo ""
        exit 0
    fi
    
    echo "   Attempt $i/10: Not detected yet, waiting..."
    sleep 2
done

echo ""
echo -e "${RED}❌ iPhone still not detected after 20 seconds${NC}"
echo ""
echo "Please check:"
echo "  • iPhone is unlocked (not on lock screen)"
echo "  • You tapped 'Trust' when prompted"
echo "  • USB cable is properly connected"
echo ""
echo "Try running this script again: $0"
exit 1
