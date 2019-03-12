# macbookpro11,4 install

What follows are my personal notes (circa March 2019) of setting up my new MacBook Pro 15,4 (A1990, 2018, Touch Bar / USB-C) for dual boot between MacOS and Arch Linux, with Arch Linux (2019.03.01) on a LUKS encrypted partition (single LUKS crypted / dm-crypt partition with LVM) and FileVault full disk encryption for the Mac side.

1. [Prerequisites](#prerequisites)
2. [Initial Setup](#initial-setup)
3. [Arch Linux Install](#arch-linux-install)
4. [Mac Setup - Boxen](#mac-setup---boxen)
5. [Linux Setup - Puppet](#linux-setup---puppet)

## Prerequisites

Here's what you'll need:

* Your new MacBook Pro 15.x
* A USB-C network adapter (wired Ethernet)
* A USB-C to USB-A adapter
* A USB (A) hub with at least two ports
* A USB keyboard
* A USB flash drive with the [Arch Linux installer](https://www.archlinux.org/download/) on it

## Initial Setup

__WARNING:__ This will completely purge your MacOS install. Proceed with caution (and, ideally, experience).

1. Boot into MacOS. Set up your user account and password.
2. Connect a USB-C Ethernet adapter to your network (with DHCP enabled).
3. Reboot into recovery mode by rebooting and holding Cmd + Option + R until the spinning globe comes up.
4. Navigate to Utilities -> Startup Security Utility. Authenticate as needed. Set "Secure Boot" to "No Security" and "External Boot" to "Allow booting from external media".
5. From the main macOS Utilities dialog, select Disk Utility.
6. From the top of the left menu under the "Internal" heading, select "Untitled". Click the "Erase" button at the top. Wait for it to finish erasing the disk.
7. Click back on "Untitled" on the left menu and click the "Partition" button at the top. When presented with the "Apple File System Space Sharing" dialog, click the "Partition" button.
8. Decide on a partition size for your new MacOS install. My laptop had a 500GB disk and I rarely use MacOS (except for watching movies when I travel) so I set it to 200GB. Create an APFS partition of the size chosen (200 GB for me) and leave it called "Untitled".
9. Click the remaining space (300GB for me), set a name of "Linux" and a type of "MS-DOS (FAT)".
10. Confirm the settings and click "Apply" and then "Partition". When complete, you should be sent back to the macOS Utilities dialog.
11. Select "Reinstall macOS" and "Continue".
12. Continue through the prompts until prompted for disk selection. Select the "Untitled" volume and click "Install". The installation should begin. It should take less than 15 minutes on a fast connection. When finished, it should boot to MacOS. _(Super controversial note: if your laptop was setup with Device Enrollment, at this point it will prompt you to allow Remote Management. If you disconnect from your network and reboot, and then when prompted to Select Your Wi-Fi Network click "Other Network Options" and then select "My computer does not connect to the Internet", you will be able to create a local account without enabling Device Enrollment. Thanks to [this SO comment](https://apple.stackexchange.com/questions/311052/why-do-i-get-a-remote-management-step-when-installing-high-sierra#comment394497_311054) for the info.)_
13. Boot into MacOS and make sure it works. Connect to your network and check for updates (there shouldn't be any).

## Arch Linux Install

_Note:_ These steps aren't in the exact order of what I did, for reasons that will become obvious...

1. Plug the USB-C to USB-A adapter in to the laptop, plug the hub into that, and plug the USB drive with the Arch installer (I used 2019.03.01) and the keyboard into the hub. Reboot, and hold the Option key (on the laptop's keyboard) while the laptop boots.
2. You should get a popup showing two choices: "Untitled" (hard disk icon) and "EFI Boot" (different icon). Select the "EFI Boot" option for the Arch installer.
3. At the boot menu, select the Arch Linux UEFI CD (should be default). After some boot messages, you should be dropped to an automatic root login and shell. (At this point, you'll notice that the laptop keyboard is completely non-functional.)
4. Attempt a ``ping archlinux.org`` - this should actually work.
5. Check that the date is relatively accurate with ``date``. If needed, set date and time via NTP with ``timedatectl set-ntp true``.
6. Check for recognized disks with ``fdisk -l``. Unfortunately, we'll only see the two partitions of our USB drive (``/dev/sda``). ``lsblk`` will show the same thing.
7. ``modprobe nvme && echo 106b 2005 > /sys/bus/pci/drivers/nvme/new_id`` from a number of comments on [Dunedan/mbp-2016-linux #71](https://github.com/Dunedan/mbp-2016-linux/issues/71#issuecomment-413020350).

Aaaand... nothing. That's it. It won't see the SSD. References:

* [MacBookPro 15,1/2? · Issue #71 · Dunedan/mbp-2016-linux](https://github.com/Dunedan/mbp-2016-linux/issues/71)
* [macintosh - How can you get any version of Linux to see the 2018 MacBook Pro SSD? - Unix & Linux Stack Exchange](https://unix.stackexchange.com/questions/463422/how-can-you-get-any-version-of-linux-to-see-the-2018-macbook-pro-ssd/479544)
* [Linux doesn't support T2 as a SSD controller Apple's T2 Secure Boot chip is blocking usage of Linux in T2 chip Macs - Software & Operating Systems / Mac - Level1Techs Forums](https://forum.level1techs.com/t/linux-doesnt-support-t2-as-a-ssd-controller-apples-t2-secure-boot-chip-is-blocking-usage-of-linux-in-t2-chip-macs/134832/36)
* [Apple iMac Pro and Secure Storage | Duo Security](https://duo.com/blog/apple-imac-pro-and-secure-storage)
