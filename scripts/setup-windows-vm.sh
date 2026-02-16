#!/bin/bash
# Setup Windows 11 VM on Proxmox for iPhone Sideloading
# Run this on your local Linux machine (not on Proxmox)

set -e

PROXMOX_HOST="192.168.68.52"
PROXMOX_USER="root"
PROXMOX_PASS="decafbad00"

# VM Configuration
VM_ID=200
VM_NAME="windows-dev"
VM_CORES=4
VM_RAM=8192  # 8GB
VM_DISK_SIZE=60G
STORAGE="local-lvm"
ISO_STORAGE="local"

echo "════════════════════════════════════════════════"
echo "  Windows 11 VM Setup for Proxmox"
echo "════════════════════════════════════════════════"
echo ""
echo "This will create a Windows 11 VM optimized for:"
echo "  - iPhone sideloading with Sideloadly"
echo "  - Lightweight desktop use"
echo "  - USB passthrough for iPhone"
echo ""
echo "VM Configuration:"
echo "  - VM ID: $VM_ID"
echo "  - Name: $VM_NAME"
echo "  - CPU: $VM_CORES cores"
echo "  - RAM: ${VM_RAM}MB (8GB)"
echo "  - Disk: $VM_DISK_SIZE"
echo ""

# Function to run commands on Proxmox
pve_exec() {
    sshpass -p "$PROXMOX_PASS" ssh -o StrictHostKeyChecking=no "$PROXMOX_USER@$PROXMOX_HOST" "$@"
}

echo "Step 1: Checking if Windows 11 ISO exists..."
ISO_PATH=$(pve_exec "ls /var/lib/vz/template/iso/Win11*.iso 2>/dev/null | head -1" || echo "")

if [ -z "$ISO_PATH" ]; then
    echo "❌ Windows 11 ISO not found on Proxmox"
    echo ""
    echo "To download Windows 11 ISO, you have two options:"
    echo ""
    echo "OPTION A: Download directly on Proxmox (Recommended)"
    echo "  1. Access Proxmox web UI: https://192.168.68.52:8006"
    echo "  2. Click on 'local' storage"
    echo "  3. Click 'ISO Images' → 'Download from URL'"
    echo "  4. Use this URL (official Microsoft download):"
    echo "     https://software.download.prss.microsoft.com/dbazure/Win11_24H2_English_x64.iso?t=..."
    echo "     (You'll need to get the current URL from microsoft.com/software-download/windows11)"
    echo ""
    echo "OPTION B: Upload ISO from your machine"
    echo "  1. Download Windows 11 ISO from: https://www.microsoft.com/software-download/windows11"
    echo "  2. Run: scp -o StrictHostKeyChecking=no Win11*.iso root@192.168.68.52:/var/lib/vz/template/iso/"
    echo ""
    echo "After downloading, run this script again."
    exit 1
fi

echo "✅ Found Windows ISO: $(basename $ISO_PATH)"

echo ""
echo "Step 2: Checking if VM ID $VM_ID is available..."
if pve_exec "qm status $VM_ID 2>/dev/null" >/dev/null 2>&1; then
    echo "⚠️  VM $VM_ID already exists"
    read -p "Delete existing VM $VM_ID and recreate? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Deleting VM $VM_ID..."
        pve_exec "qm stop $VM_ID 2>/dev/null || true"
        pve_exec "qm destroy $VM_ID"
        echo "✅ VM deleted"
    else
        echo "❌ Cancelled"
        exit 1
    fi
fi

echo "✅ VM ID $VM_ID is available"

echo ""
echo "Step 3: Creating Windows 11 VM..."
pve_exec "qm create $VM_ID \
  --name $VM_NAME \
  --memory $VM_RAM \
  --cores $VM_CORES \
  --cpu host \
  --sockets 1 \
  --net0 virtio,bridge=vmbr0 \
  --ostype win11 \
  --bios ovmf \
  --machine q35 \
  --efidisk0 $STORAGE:1,format=raw,efitype=4m,pre-enrolled-keys=1 \
  --tpmstate0 $STORAGE:1,version=v2.0"

echo "✅ VM created"

echo ""
echo "Step 4: Adding disk and CD-ROM..."
pve_exec "qm set $VM_ID \
  --scsi0 $STORAGE:$VM_DISK_SIZE,format=raw,discard=on,ssd=1 \
  --scsihw virtio-scsi-single \
  --ide2 $ISO_PATH,media=cdrom \
  --boot order=scsi0;ide2"

echo "✅ Storage configured"

echo ""
echo "Step 5: Configuring display and USB..."
pve_exec "qm set $VM_ID \
  --vga virtio \
  --agent enabled=1 \
  --tablet 1 \
  --usb0 host=spice,usb3=1"

echo "✅ Display and USB configured"

echo ""
echo "Step 6: Optimizing for desktop use..."
pve_exec "qm set $VM_ID \
  --balloon 0 \
  --onboot 0 \
  --protection 0"

echo "✅ VM configuration complete!"

echo ""
echo "════════════════════════════════════════════════"
echo "  ✅ Windows 11 VM Created Successfully!"
echo "════════════════════════════════════════════════"
echo ""
echo "VM Details:"
echo "  - ID: $VM_ID"
echo "  - Name: $VM_NAME"
echo "  - Status: Ready to start"
echo ""
echo "Next Steps:"
echo ""
echo "1. Start the VM:"
echo "   - Web UI: https://192.168.68.52:8006"
echo "   - Select VM $VM_ID → Start"
echo "   - Click Console to see Windows installer"
echo ""
echo "2. Install Windows 11:"
echo "   - Follow Windows setup wizard (~15 minutes)"
echo "   - Choose 'Windows 11 Pro' edition"
echo "   - Select 'Custom: Install Windows only'"
echo "   - Install on the virtual disk"
echo "   - Skip Microsoft account (use local account)"
echo "   - Disable privacy settings for faster setup"
echo ""
echo "3. After Windows boots:"
echo "   - Install VirtIO drivers (for better performance)"
echo "   - Install Sideloadly: https://sideloadly.io/"
echo "   - Download your IPA from GitHub Actions"
echo ""
echo "4. Setup iPhone USB passthrough:"
echo "   - VM → Hardware → Add → USB Device"
echo "   - Select your iPhone (Apple Inc., vendor 05ac)"
echo ""
echo "5. Test installation:"
echo "   - Connect iPhone via USB"
echo "   - Open Sideloadly"
echo "   - Install CameraAccess.ipa"
echo ""
echo "════════════════════════════════════════════════"
echo ""
echo "Want to start the VM now? Run:"
echo "  sshpass -p 'decafbad00' ssh root@192.168.68.52 'qm start $VM_ID'"
echo ""
