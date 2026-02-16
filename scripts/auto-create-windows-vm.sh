#!/bin/bash
# Auto-create Windows VM once ISO is detected on Proxmox

PROXMOX_HOST="192.168.68.52"
PROXMOX_PASS="decafbad00"

# VM Configuration
VM_ID=201  # Using 201 since 200 is taken
VM_NAME="windows-dev"
VM_CORES=4
VM_RAM=8192
VM_DISK_SIZE=60G
STORAGE="local-lvm"

pve_exec() {
    sshpass -p "$PROXMOX_PASS" ssh -o StrictHostKeyChecking=no root@$PROXMOX_HOST "$@"
}

echo "════════════════════════════════════════════════"
echo "  Waiting for Windows ISO..."
echo "════════════════════════════════════════════════"
echo ""
echo "This script will:"
echo "  1. Monitor Proxmox for Windows ISO"
echo "  2. Automatically create VM when found"
echo "  3. Configure everything ready to start"
echo ""
echo "Meanwhile, download the ISO via Proxmox web UI:"
echo "  → https://192.168.68.52:8006"
echo "  → local → ISO Images → Download from URL"
echo ""
echo "Checking every 30 seconds..."
echo ""

while true; do
    # Check for Windows ISO
    ISO_PATH=$(pve_exec "ls /var/lib/vz/template/iso/{Win*,win*,Tiny*,tiny*}.iso 2>/dev/null | head -1" || echo "")
    
    if [ -n "$ISO_PATH" ]; then
        ISO_NAME=$(basename "$ISO_PATH")
        echo ""
        echo "✅ Found ISO: $ISO_NAME"
        echo ""
        
        # Check if VM already exists
        if pve_exec "qm status $VM_ID 2>/dev/null" >/dev/null 2>&1; then
            echo "⚠️  VM $VM_ID already exists, using ID $((VM_ID+1))..."
            VM_ID=$((VM_ID+1))
        fi
        
        echo "Creating Windows 11 VM (ID: $VM_ID)..."
        
        # Create VM
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
          --tpmstate0 $STORAGE:1,version=v2.0" && echo "✅ VM created" || exit 1
        
        # Add storage
        pve_exec "qm set $VM_ID \
          --scsi0 $STORAGE:$VM_DISK_SIZE,format=raw,discard=on,ssd=1 \
          --scsihw virtio-scsi-single \
          --ide2 $ISO_PATH,media=cdrom \
          --boot order=scsi0;ide2" && echo "✅ Storage configured" || exit 1
        
        # Configure display and USB
        pve_exec "qm set $VM_ID \
          --vga virtio \
          --agent enabled=1 \
          --tablet 1 \
          --usb0 host=spice,usb3=1" && echo "✅ Display and USB configured" || exit 1
        
        # Optimize
        pve_exec "qm set $VM_ID --balloon 0 --onboot 0" && echo "✅ Optimizations applied" || exit 1
        
        echo ""
        echo "════════════════════════════════════════════════"
        echo "  ✅ Windows VM Created Successfully!"
        echo "════════════════════════════════════════════════"
        echo ""
        echo "VM Details:"
        echo "  • ID: $VM_ID"
        echo "  • Name: $VM_NAME"
        echo "  • RAM: 8GB"
        echo "  • CPU: 4 cores"
        echo "  • Disk: 60GB"
        echo "  • ISO: $ISO_NAME"
        echo ""
        echo "Next Steps:"
        echo ""
        echo "1. Start the VM:"
        echo "   → https://192.168.68.52:8006"
        echo "   → Select VM $VM_ID → Start → Console"
        echo ""
        echo "2. Install Windows 11:"
        echo "   → Follow installer (~15 minutes)"
        echo "   → Skip Microsoft account (use local account)"
        echo "   → Username: dev"
        echo ""
        echo "3. After Windows boots:"
        echo "   → Install iTunes (for iPhone drivers)"
        echo "   → Install Sideloadly: https://sideloadly.io/"
        echo "   → Setup USB passthrough for iPhone"
        echo ""
        echo "4. Install VisionClaw:"
        echo "   → Download IPA from GitHub Actions"
        echo "   → Use Sideloadly to sign and install"
        echo ""
        echo "════════════════════════════════════════════════"
        
        exit 0
    fi
    
    echo -n "."
    sleep 30
done
