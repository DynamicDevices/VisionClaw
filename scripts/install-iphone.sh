#!/bin/bash
#
# Automated VisionClaw iPhone Installation Script
# Installs the latest IPA from GitHub Actions to your iPhone
#

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO="DynamicDevices/VisionClaw"
WORKSPACE="/home/ajlennon/data_drive/ai/VisionClaw"
ALTSERVER_DIR="$HOME/AltServer-Linux"
IPA_PATH="$WORKSPACE/CameraAccess.ipa"

echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
echo -e "${BLUE}  VisionClaw iPhone Installation Script${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install system dependencies
install_dependencies() {
    echo -e "${YELLOW}📦 Checking system dependencies...${NC}"
    
    DEPS_NEEDED=()
    
    # Check for required packages
    if ! dpkg -l | grep -q libimobiledevice-utils; then
        DEPS_NEEDED+=("libimobiledevice-utils")
    fi
    if ! dpkg -l | grep -q usbmuxd; then
        DEPS_NEEDED+=("usbmuxd")
    fi
    if ! dpkg -l | grep -q libplist-utils; then
        DEPS_NEEDED+=("libplist-utils")
    fi
    if ! dpkg -l | grep -q libavahi-compat-libdnssd-dev; then
        DEPS_NEEDED+=("libavahi-compat-libdnssd-dev")
    fi
    if ! command_exists python3; then
        DEPS_NEEDED+=("python3")
    fi
    if ! command_exists pip3; then
        DEPS_NEEDED+=("python3-pip")
    fi
    
    if [ ${#DEPS_NEEDED[@]} -gt 0 ]; then
        echo -e "${YELLOW}Installing dependencies: ${DEPS_NEEDED[*]}${NC}"
        sudo apt update
        sudo apt install -y "${DEPS_NEEDED[@]}"
        echo -e "${GREEN}✅ Dependencies installed${NC}"
    else
        echo -e "${GREEN}✅ All dependencies already installed${NC}"
    fi
}

# Function to setup AltServer-Linux
setup_altserver() {
    echo ""
    echo -e "${YELLOW}🔧 Setting up AltServer-Linux...${NC}"
    
    if [ -d "$ALTSERVER_DIR" ]; then
        echo -e "${GREEN}✅ AltServer-Linux already cloned${NC}"
        cd "$ALTSERVER_DIR"
        git pull --quiet || echo "Could not update, using existing version"
    else
        echo "Cloning AltServer-Linux..."
        git clone https://github.com/NyaMisty/AltServer-Linux.git "$ALTSERVER_DIR"
        cd "$ALTSERVER_DIR"
    fi
    
    # Install Python dependencies
    echo "Installing Python dependencies..."
    pip3 install -q -r requirements.txt 2>/dev/null || {
        echo -e "${YELLOW}⚠️  Some Python dependencies may have issues, continuing anyway...${NC}"
    }
    
    echo -e "${GREEN}✅ AltServer-Linux ready${NC}"
}

# Function to check iPhone connection
check_iphone() {
    echo ""
    echo -e "${YELLOW}📱 Checking for connected iPhone...${NC}"
    
    # Start usbmuxd if not running
    if ! pgrep -x "usbmuxd" > /dev/null; then
        echo "Starting usbmuxd..."
        sudo systemctl start usbmuxd 2>/dev/null || sudo usbmuxd &
        sleep 2
    fi
    
    # Check for connected devices
    DEVICE_ID=$(idevice_id -l 2>/dev/null | head -1)
    
    if [ -z "$DEVICE_ID" ]; then
        echo -e "${RED}❌ No iPhone detected${NC}"
        echo ""
        echo "Please:"
        echo "  1. Connect your iPhone via USB"
        echo "  2. Unlock your iPhone"
        echo "  3. Trust this computer (tap 'Trust' on iPhone)"
        echo "  4. Run this script again"
        exit 1
    fi
    
    echo -e "${GREEN}✅ iPhone detected: $DEVICE_ID${NC}"
    
    # Get device info
    DEVICE_NAME=$(ideviceinfo -k DeviceName 2>/dev/null || echo "Unknown")
    DEVICE_VERSION=$(ideviceinfo -k ProductVersion 2>/dev/null || echo "Unknown")
    echo "   Device: $DEVICE_NAME"
    echo "   iOS Version: $DEVICE_VERSION"
}

# Function to download latest IPA
download_ipa() {
    echo ""
    echo -e "${YELLOW}📥 Checking for IPA...${NC}"
    
    cd "$WORKSPACE"
    
    # Check if IPA already exists and is recent (less than 1 hour old)
    if [ -f "CameraAccess.ipa" ]; then
        IPA_AGE=$(($(date +%s) - $(stat -c %Y CameraAccess.ipa)))
        if [ $IPA_AGE -lt 3600 ]; then
            IPA_SIZE=$(du -h CameraAccess.ipa | cut -f1)
            echo -e "${GREEN}✅ Using existing IPA: $IPA_SIZE ($(($IPA_AGE/60)) minutes old)${NC}"
            return 0
        else
            echo "IPA is older than 1 hour, downloading fresh copy..."
            rm -f CameraAccess.ipa
        fi
    fi
    
    echo "Downloading latest IPA from GitHub Actions..."
    
    # Download latest successful build artifact
    echo "Fetching latest successful build..."
    LATEST_RUN=$(gh run list --workflow "ios-build.yml" --status success --limit 1 --json databaseId --jq '.[0].databaseId' 2>/dev/null)
    
    if [ -z "$LATEST_RUN" ]; then
        echo -e "${RED}❌ No successful builds found${NC}"
        exit 1
    fi
    
    echo "Downloading artifacts from run #$LATEST_RUN..."
    
    # Get artifact name
    ARTIFACT_NAME=$(gh run view "$LATEST_RUN" 2>/dev/null | grep "ARTIFACTS" -A 1 | tail -1 | xargs)
    
    if [ -z "$ARTIFACT_NAME" ]; then
        echo -e "${RED}❌ No artifacts found in latest build${NC}"
        exit 1
    fi
    
    echo "Artifact: $ARTIFACT_NAME"
    gh run download "$LATEST_RUN" --name "$ARTIFACT_NAME" 2>&1 | grep -v "^$"
    
    if [ ! -f "CameraAccess.ipa" ]; then
        echo -e "${RED}❌ IPA file not found after download${NC}"
        exit 1
    fi
    
    IPA_SIZE=$(du -h CameraAccess.ipa | cut -f1)
    echo -e "${GREEN}✅ IPA downloaded: $IPA_SIZE${NC}"
}

# Function to get Apple ID credentials
get_credentials() {
    echo ""
    echo -e "${YELLOW}🔑 Apple ID Credentials${NC}"
    echo ""
    echo "AltStore needs your Apple ID to sign the app."
    echo "Your credentials are NOT stored or sent anywhere except to Apple."
    echo ""
    
    # Check if credentials are already set
    if [ -n "$APPLE_ID" ] && [ -n "$APPLE_PASSWORD" ]; then
        echo -e "${GREEN}✅ Using credentials from environment variables${NC}"
        return
    fi
    
    # Prompt for Apple ID
    read -p "Apple ID (email): " APPLE_ID
    
    # Prompt for password (hidden)
    read -s -p "Apple Password: " APPLE_PASSWORD
    echo ""
    
    if [ -z "$APPLE_ID" ] || [ -z "$APPLE_PASSWORD" ]; then
        echo -e "${RED}❌ Credentials required${NC}"
        exit 1
    fi
    
    echo ""
    echo -e "${YELLOW}💡 Tip: To avoid entering credentials each time, set environment variables:${NC}"
    echo "   export APPLE_ID='your@email.com'"
    echo "   export APPLE_PASSWORD='your-password'"
}

# Function to install IPA
install_ipa() {
    echo ""
    echo -e "${YELLOW}📲 Installing VisionClaw on iPhone...${NC}"
    echo ""
    
    cd "$ALTSERVER_DIR"
    
    # Run altinstaller
    sudo -E python3 altinstaller.py \
        --appleid "$APPLE_ID" \
        --password "$APPLE_PASSWORD" \
        "$IPA_PATH" 2>&1 | tee /tmp/altserver.log
    
    # Check if installation succeeded
    if grep -q "Successfully installed" /tmp/altserver.log 2>/dev/null || \
       grep -q "Installation completed" /tmp/altserver.log 2>/dev/null; then
        echo ""
        echo -e "${GREEN}✅ Installation successful!${NC}"
        return 0
    else
        echo ""
        echo -e "${RED}❌ Installation may have failed${NC}"
        echo "Check the output above for errors"
        return 1
    fi
}

# Function to show next steps
show_next_steps() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
    echo -e "${GREEN}🎉 Installation Complete!${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
    echo ""
    echo "Next steps on your iPhone:"
    echo ""
    echo "1. 📱 Open: Settings → General → VPN & Device Management"
    echo "2. 👆 Tap your email address"
    echo "3. ✅ Tap 'Trust'"
    echo "4. 🚀 Launch VisionClaw from your home screen!"
    echo ""
    echo -e "${YELLOW}⚠️  Important Notes:${NC}"
    echo ""
    echo "• App expires in 7 days (free Apple ID limit)"
    echo "• Re-run this script weekly to refresh"
    echo "• App uses placeholder API keys - configure in Settings"
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
    echo ""
    echo "To reinstall or update, just run:"
    echo "  $0"
    echo ""
}

# Main execution
main() {
    # Change to workspace
    cd "$WORKSPACE"
    
    # Run installation steps
    install_dependencies
    setup_altserver
    check_iphone
    download_ipa
    get_credentials
    
    if install_ipa; then
        show_next_steps
    else
        echo ""
        echo -e "${RED}Installation encountered errors. Check the output above.${NC}"
        echo ""
        echo "Common issues:"
        echo "  - iPhone locked: Unlock and trust computer"
        echo "  - Wrong password: Check Apple ID credentials"
        echo "  - Network issues: Check GitHub access"
        echo ""
        exit 1
    fi
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo -e "${RED}❌ Please do not run this script as root${NC}"
    echo "The script will ask for sudo when needed"
    exit 1
fi

# Check if in workspace
if [ ! -d "$WORKSPACE/.git" ]; then
    echo -e "${RED}❌ Not in VisionClaw workspace${NC}"
    echo "Expected: $WORKSPACE"
    exit 1
fi

# Run main installation
main
