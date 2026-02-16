#!/bin/bash
# Quick Windows ISO Download Instructions for Proxmox

cat << 'EOF'
════════════════════════════════════════════════
  Windows ISO Download for Proxmox
════════════════════════════════════════════════

The automated download failed because Microsoft download
links expire quickly and require browser-based download.

EASIEST METHOD: Proxmox Web UI Download
────────────────────────────────────────────────

1. Open browser: https://192.168.68.52:8006
   Login: root / decafbad00

2. Navigate to ISO storage:
   Datacenter → pve (your node) → local → ISO Images

3. Click "Download from URL" button

4. Get Windows 11 ISO URL:
   
   Option A - Official Microsoft (Recommended):
   • Go to: https://www.microsoft.com/software-download/windows11
   • Scroll to "Download Windows 11 Disk Image (ISO)"
   • Select: Windows 11 (multi-edition ISO)
   • Click Download
   • Select language: English
   • Click "64-bit Download" button
   • Right-click the download button → "Copy Link Address"
   • Paste into Proxmox "Download from URL" dialog
   • Filename: Win11_24H2_English_x64.iso
   • Click "Query URL" → "Download"
   
   Option B - Tiny11 (Lightweight, faster):
   • Use this direct link in Proxmox:
     https://ia801900.us.archive.org/2/items/tiny11-2311/tiny11%202311%20x64.iso
   • Or search "Tiny11 download" and find working mirror
   • Filename: Tiny11.iso
   
5. Wait for download:
   • Official Windows: ~6GB, takes 5-15 minutes
   • Tiny11: ~3.5GB, takes 3-8 minutes
   • Progress shows in Proxmox task list

6. Once complete, run:
   ./scripts/setup-windows-vm.sh

════════════════════════════════════════════════
  ALTERNATIVE: Upload from Your Machine
════════════════════════════════════════════════

If you have a Windows ISO already:

# From your Linux machine
scp /path/to/Windows.iso root@192.168.68.52:/var/lib/vz/template/iso/

════════════════════════════════════════════════

After ISO is downloaded, I'll automatically detect it
and create the VM for you!

EOF
