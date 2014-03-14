# phoenix install

"phoenix" is my new desktop machine, built specifically to be an inexpensive ($600
reusing an existing power supply and disks) machine capable of running many VMs and
utilizing [VT-d](http://en.wikipedia.org/wiki/VT-d#Intel-VT-d), Intel's [IOMMU](http://en.wikipedia.org/wiki/IOMMU).

* Gigabyte GA-Z77-D3H motherboard
* Intel i7 3770 (non-K) quad core processor
* initially, 2x 8G DDR3 RAM (waiting for me to decide if it's worth buying the other 16G)
* Cooler Master HAF-912 case
* 3.25TB of SATA rotating disk, pulled from my previous machine
* [Arch Linux](https://www.archlinux.org/) 2014-03-01, UEFI booting

*This document* is my personal reference for how I installed Arch on the machine, in case
I ever need to replicate it. It's being published because, well, there's a chance it could
be useful to someone else. And what's the point of keeping something like this private?
This is *not a tutorial*, it's *my notes*. It should make sense to someone who understands
the Arch install process.

## BIOS Setup

* MIT > PC Health Status
  * CPU Warning Temp: Disabled -> 90C
  * CPU Fan Fail Warning: Disabled -> Enabled
  * **tried this but it seemed to prevent boot**: 2nd Sys Fan Fail Warning: Disabled -> Enabled
  * **tried this but it seemed to prevent boot**: 3rd Sys Fan Fail Warning: Disabled -> Enabled
* BIOS Features
  * Intel Virtualization Technology: Disabled -> Enabled
  * CSM Support - Storage Boot Option Control: Legacy Only -> UEFI First
  * CSM Support - Display Boot Option Control: Legacy Only -> UEFI First
* Peripherals
  * SATA Mode Selection: IDE -> AHCI
  * **tried this but it seemed to prevent boot**: XHCI Hand-off: Enable -> Disabled
  * **tried this but it seemed to prevent boot**: Init Display First: Auto -> IGFX
  * Internal Graphics Memory Size: 64M -> 256M
* Power Management
  * Soft-Off by PWR-BTTN: Instant-Off -> Delay 4 Sec.
  * AC BACK: Always Off -> Memory

## Arch Installation

Disks:
* __/dev/sda__ - wwn-0x50014ee25a2ec62d / 1de43174-5eae-407f-bdc0-547acb961641
* __/dev/sdb__ - wwn-0x50014ee05674a5ad / 00053c0e
* __/dev/sdc__ - wwn-0x50014ee0abde23c5 / 0005d421
* __/dev/sdd__ - wwn-0x50014ee25702509d / 9043b14f

1. ``gdisk /dev/sda``
   1. sda1 - 4G ef00 EFI System partition (/boot)
   2. sda2 - 100G 8300 "slash" partition (/)
   3. sda3 - 100G 8300 "var" partition (/var)
2. Format partitions
   1. ``mkfs.fat -F32 /dev/sda1``
   2. ``mkfs.ext4 /dev/sda2``
   3. ``mkfs.reiserfs /dev/sda3``
3. Mount Partitions
   1. ``mount /dev/sda2 /mnt``
   2. ``cd /mnt; mkdir boot var home mnt``
   3. ``mount /dev/sda1 boot``
   4. ``mount /dev/sda3 var``
   5. ``mount /dev/sdb2 home``
   6. ``cd mnt`` (pwd is ``/mnt/mnt``)
   7. ``mkdir sparesys space1 backup temp``
   8. ``mount /dev/sdb1 sparesys``
   9. ``mount /dev/sdb3 space1``
   10. ``mount /dev/sdc1 backup``
4. ``vi /etc/pacman.d/mirrorlist`` - move gtlib to #1 and remove the german mirror at #2
5. ``pacstrap /mnt base``
6. ``genfstab -p /mnt >> /mnt/etc/fstab``
7. ``arch-chroot /mnt``
8. ``echo "phoenix.jasonantman.com" > /etc/hostname``
9. ``ln -s /usr/share/zoneinfo/America/New_York /etc/localtime``
10. ``vi /etc/locale.gen`` and uncomment the ``en_US.UTF-8`` line; ``locale-gen``
11. ``mkinitcpio -p linux``
12. ``passwd`` - set root password
13. ``pacman -S gummiboot``
14. ``gummiboot --path=/boot install``
15. Create ``/boot/loader/entries/arch.conf`` with the following contents, using the correct PARTUUID of your *root* partition:

```
title      Arch Linux
linux      /vmlinuz-linux
initrd     /initramfs-linux.img
options    root=PARTUUID=dd24758c-68a8-40ac-875c-df812b4b0e88 rw
```

16. Create ``/boot/loader/entries/archfallback.conf`` with the following contents, using the correct PARTUUID of your *root* partition:

```
title      Arch Linux Fallback
linux      /vmlinuz-linux
initrd     /initramfs-linux-fallback.img
options    root=PARTUUID=dd24758c-68a8-40ac-875c-df812b4b0e88 rw
```

17. ``exit`` to leave chroot
18. ``umount -R /mnt`` and then ``reboot``

### Troubleshooting Boot

I initially messed with a whole bunch of BIOS settings. This left me with an un-bootable
system. If you followed the above, it should work. If you did the same stuff I did initially
(i.e. mess with the BIOS a lot, and omit steps 15 and 16 above).

1. On the initial installation attempt, after step 16, the machine failed to boot
   and didn't even show the POST/splash screen. I used the reset button and got the same behavior,
   with what sounded like a long beep at power-on before the fans kicked in. The monitor light
   was on (i.e. getting signal) but screen was black. Resetting again and quickly hitting the
   "Del" key got me into BIOS config.

2. Going into the BIOS, in "MIT > PC Health Status", I reset "CPU Warning Temp",
   "CPU Fan Fail Warning", "2nd Sys Fan Fail Warning" and "3rd Sys Fan Fail Warning"
   back to their defaults of Disabled. This cleared up the long error beep/buzz at
   boot, but still left me at a black screen. 

3. Reset again with Arch USB key in place, once again seemed to be the same thing - sounded like
   a valid boot, but blank black monitor (but not showing no signal). This was strange since the
   monitor worked before with the USB key (maybe this has a BIOS that needs multiple reboots for
   some settings to take effect?).

4. Reset again, "del" into BIOS. On "Peripherals" screen, set "Init Display First" back to
   default of "Auto" from "IGFX". Save and Exit. No change.

5. BIOS again, on "Peripherals" screen, set "Internal Graphics Memory Size" from 256M
   back to default of 64M. Save and Exit.

6. Still no splash screen, still black monitor. BIOS again, "Save & Exit" screen,
   "Load Optimized Defaults". Save & Exit Setup. Reboots. Get splash screen, then
   "EFI Default Loader" on big bar in middle (gummiboot). 

```
No loader found. Configuration files in \loader\entries\*.conf are needed.
```

7. Ctrl+Alt+Del, "del" into BIOS. "Peripherals" screen, set "SATA Mode Selection" from default
   of "IDE" to "AHCI". Save and Exit. Reboots. Get splash screen, then "EFI Default Loader".
   Same "No loader found" error.

8. Boot to Arch USB again. Mount the /boot partition (sda1) and create the
   ``/boot/loader/entries/arch.conf`` and ``/boot/loader/entries/archfallback.conf``
   files per the [Gummiboot Wiki Page](https://wiki.archlinux.org/index.php/Gummiboot#Adding_boot_entries).

9. Now it boots, but I just see:

```
:: running early hook [udev]
:: running hook [udev]
:: Triggering uevents...
:: performing fsck on '/dev/sda1'
fsck: fsck.vfat: not found
fsck: error 2 while executing fsck.vfat for /dev/sda1
ERROR: fsck failed on '/dev/sda1'
:: mounting '/dev/sda1' in real root
:: running cleanup hook [udev]
ERROR: Root device mounted successfully, but /sbin/init does not exist.
Bailing out, you are on your own. Good luck.

sh: can't access tty; job control turned off
[rootfs /]#
```

10. By the time I finished typing this up, I realized that I'd added ``/boot``'s partuuid
    for the ``root`` line in the loader.conf entries. So, reboot, F12 at splash screen to get
    the boot menu, boot to the Arch USB stick again, mount /boot again, and correct the
    loader config entries with the right partuuid (sed is handy for this, as is using tab
    completion at the shell to get the paths onto the line).

11. Reboot. At this point I'm actually booted into the system. Login as root for the first time,
    ``reboot`` and "del" into BIOS. Update BIOS settings to what they should be, per above (i.e.
    undo the "Load Optimized Defaults" that I did earlier).

12. Exit saving changes. Splash screen doesn't show up, but we boot to the OS and fsck's start
    running. Let them run. Once we're booted to the OS, reboot again to make sure no BIOS changes
    had a delayed effect.

## Initial OS Configuration

1. Boot the installed system and login as root.
2. Continue with the initial OS setup as documented in [README.md](README.md).
