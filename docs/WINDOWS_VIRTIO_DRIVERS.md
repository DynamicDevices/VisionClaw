# Windows 11 Installation - Load VirtIO Drivers

## Problem
Windows installer can't see the disk because it needs VirtIO drivers.

## Solution
The VirtIO drivers ISO is being downloaded to Proxmox automatically.
Once complete (~2 minutes), follow these steps:

## Steps to Load Drivers in Windows Installer

### 1. Wait for VirtIO ISO Download to Complete
The download is currently at ~88%. I'll attach it to your VM automatically when done.

### 2. In the Windows Installer

When you see "Where do you want to install Windows?" with no drives shown:

1. **Click "Load driver"** (bottom left)

2. **Click "Browse"**

3. **You'll see two drives:**
   - Drive with Windows ISO (Drive 0)
   - **VirtIO drivers ISO (Drive 1)** ← Select this one

4. **Navigate to:**
   ```
   Drive 1 (virtio-win) → vioscsi → w11 → amd64
   ```

5. **Click "OK"**

6. **Driver will load:** "Red Hat VirtIO SCSI controller"

7. **Click "Next"**

8. **Now you'll see the disk:** "Drive 0 Unallocated Space 60.0 GB"

9. **Click "Next"** to begin installation!

## Alternative: If Browse Doesn't Work

1. **In Proxmox console, eject and re-add the VirtIO ISO:**
   - Hardware tab → CD/DVD Drive (ide3)
   - Detach → Re-attach with virtio-win.iso

2. **In Windows installer:**
   - Click "Rescan" button
   - Then "Load driver" again

## What I'm Doing

I'm:
1. ✅ Downloading VirtIO drivers ISO (currently 88%)
2. ⏳ Will attach it to your VM as second CD drive
3. ⏳ Will notify you when ready

Stay on the Windows installer screen. Once download completes (~2 min),
I'll tell you to proceed with the steps above!
