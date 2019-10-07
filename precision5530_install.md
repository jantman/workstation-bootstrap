# Precision 5530 Laptop Install

This is the process I used for installing Arch Linux on my work-issued Dell Precision 5530 laptop.

## References

* [Dell XPS 15 - ArchWiki](https://wiki.archlinux.org/index.php/Dell_XPS_15)
* [Laptop/Dell - ArchWiki](https://wiki.archlinux.org/index.php/Laptop/Dell#Precision)

## Installation Notes

After some initial problems with video, this has been fixed in current package versions.

## Initial Installation

1. Plug in power, wired Ethernet (via USB-C adapter). DO NOT PLUG IN Arch installation USB stick.
2. Power on the system. At the Dell splash screen, hold down the F12 key until you get to the one-time boot menu.
   * Other Options -> Change Boot Mode Settings
     * Change boot mode to: 2) UEFI Boot Mode, Secure Boot OFF. Proceed and apply the changes.
   * System will reboot. At the Dell splash screen, press F12.
   * Other Options -> BIOS Setup
     * System Configuration -> SATA Operation - set to "AHCI" (not RAID / Intel Rapid Restore)
     * Exit. System will reboot.
  * System will reboot. At the Dell splash screen, press F12.
     * Other Options -> BIOS Setup
       * Maintenance -> Data Wipe. Check "Wipe on Next Boot". Verify that USB stick is NOT plugged in, click OK and then No to _not_ cancel.
       * Click Exit. The laptop will reboot. You'll get a Dell logo with a progress bar and then a data wipe prompt. Select "Continue" and then "Erase", and you'll eventually get a success message.
3. Plug in the Arch Installer USB stick and press Enter to reboot.
4. At the Dell splash screen, hold down the F12 key until you get to the one-time boot menu. **Do not** select the "USB Storage Device" option - this will boot in BIOS mode. Select one of the first two UEFI Boot options (they both seemed to give the same thing for me).
5. Select "Arch Linux archiso x86_64 UEFI CD". You should eventually boot to a ``root@archiso ~ #`` prompt.
6. We'll now wipe the disk (``nvme0``) according to [dm-crypt wipe on an empty disk or partition](https://wiki.archlinux.org/index.php/Dm-crypt/Drive_preparation#dm-crypt_wipe_on_an_empty_disk_or_partition):
   1. ``cryptsetup open --type plain -d /dev/urandom /dev/nvme0n1 to_be_wiped``
   2. ``lsblk`` and verify ``to_be_wiped`` exists
   3. do the wipe: ``dd if=/dev/zero of=/dev/mapper/to_be_wiped bs=1M status=progress`` - on my 477GB disk, this took about 14 minutes
   4. ``cryptsetup close to_be_wiped``
7. If you want the convenience of running the installation remotely over SSH, follow [Install from SSH - ArchWiki](https://wiki.archlinux.org/index.php/Install_from_SSH):
   1. Ensure the machine is on your network (``ip addr``).
   2. Ensure that ``PermitRootLogin yes`` is present and uncommented in ``/etc/ssh/sshd_config``
   3. Set a temporary root password: ``passwd``
   4. Start the SSH daemon: ``systemctl start sshd``
8. Follow the initial steps of the [Arch Installation Guide](https://wiki.archlinux.org/index.php/installation_guide#Set_the_keyboard_layout) prior to partitioning: set the keyboard layout if needed, verify UEFI boot with ``ls /sys/firmware/efi/efivars``, connect to your LAN, and set the system clock. _(Note: verifying UEFI is important; the first time I did this, I inadvertantly booted into legacy/BIOS mode.)_
9. We'll now set up [LVM on LUKS](https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system#LVM_on_LUKS) and partition the disks (this setup was chosen for the ease of suspend):
   1. ``cgdisk /dev/nvme0n1``
      * Create a 550M partition of type ``EF00`` (``EFI System``) called ``ESP`` (this will become the EFI System Partition, ``/dev/nvme0n1p1``)
      * Create a 300M partition of type 8300 called ``BOOT`` (this will become ``/dev/nvme0n1p2``)
      * Use the rest of the disk (476GB for me) for a partition of type 8300 called ``SYSTEM`` (this will become ``/dev/nvme0n1p3``)
      * Write to disk and quit
   2. Create the LUKS container for the system: ``cryptsetup luksFormat --type luks2 /dev/nvme0n1p3``
   3. Open the container: ``cryptsetup open /dev/nvme0n1p3 cryptlvm``
   4. Create the physical volume: ``pvcreate /dev/mapper/cryptlvm``
   5. Create the volume group: ``vgcreate LUKSvol /dev/mapper/cryptlvm``
   6. Because I'm old-school, create a swap volume twice the size of the RAM (32G): ``lvcreate -L 32G LUKSvol -n swap``
   7. Because I'm lazy and this is a laptop (don't hate me), use the rest of the disk for a single root partition: ``lvcreate -l 100%FREE LUKSvol -n root``
   8. Setup the filesystems: ``mkswap /dev/LUKSvol/swap && mkfs.ext4 /dev/LUKSvol/root``
   9. Mount the partitions: ``mount /dev/LUKSvol/root /mnt; swapon /dev/LUKSvol/swap``
   10. Create the ESP filesystem on the ESP partition: ``mkfs.fat -F32 /dev/nvme0n1p1`` (if that isn't installed, ``pacman -S dosfstools``) and mount it: ``mkdir /mnt/efi && mount /dev/nvme0n1p1 /mnt/efi``
   11. Create the boot filesystem on the BOOT partition: ``mkfs.ext4 /dev/nvme0n1p2``
   12. Create the boot directory and mount the partition: ``mkdir /mnt/boot && mount /dev/nvme0n1p2 /mnt/boot``
   13. We're done with this for now, but we'll come back to finish it later.
10. Back in the Installation Guide, pick up at the [Installation](https://wiki.archlinux.org/index.php/installation_guide#Installation) process:
   1. Edit ``/etc/pacman.d/mirrorlist`` as desired.
   2. Install the base packages: ``pacstrap /mnt base``
11. Continue on with the [Configure System](https://wiki.archlinux.org/index.php/installation_guide#Configure_the_system) steps:
    1. ``genfstab -U /mnt >> /mnt/etc/fstab`` and check the resulting file
    2. chroot into the system: ``arch-chroot /mnt``
    3. Set the time zone, i.e. ``ln -sf /usr/share/zoneinfo/Region/City /etc/localtime`` and run ``hwclock --systohc``
    4. Edit ``/etc/locale.gen`` as needed, run ``locale-gen``, and create ``/etc/locale.conf``
    5. Create ``/etc/hostname`` and set ``/etc/hosts`` entries accordingly.
    6. Install intel microcode: ``pacman -S intel-ucode``
    7. Install other dependencies: ``pacman -S linux nvidia nvidia-utils nvidia-settings lvm2 dhcpcd openssh``
12. [Configure mkinitcpio per the dm-crypt instructions](https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system#Configuring_mkinitcpio_2): edit the ``HOOKS`` line to match what's given in those instructions (order matters A LOT). Also ensure that after ``lvm2`` you add ``resume``. If you're using ``en_US.UTF-8`` you can leave out ``keymap`` and ``consolefont``. The final line should read: ``HOOKS=(base udev autodetect keyboard modconf block encrypt lvm2 resume filesystems keyboard fsck)``. For the Precision 5530 laptop, also set ``MODULES=(intel_agp i915)``. Save the file and then run ``mkinitcpio -P``.
13. Run ``passwd`` to create the root password.
14. Install the GRUB bootloader:
    1. ``pacman -S grub efibootmgr``
    2. Ensure the ESP is mounted at ``/efi``
    3. Install GRUB: ``grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB``
    4. Edit ``/etc/default/grub``
       * In the kernel parameters, set ``resume=/dev/LUKSvol/swap``
       * In the kernel parameters, set ``cryptdevice=UUID=device-UUID:cryptlvm root=/dev/LUKSvol/root`` (replacing ``device-UUID`` with the UUID of the device, i.e. the ``/dev/disk/by-uuid`` symlink that points to ``/dev/nvme0n1p3``)
       * If you're like me, you'll want to remove the default ``quiet``
       * To work around some video issues, add ``nomodeset``.
       * The final line should read: ``GRUB_CMDLINE_LINUX_DEFAULT="resume=/dev/LUKSvol/swap cryptdevice=UUID=d6982ada-e991-4682-8966-ddb87c1d4882:cryptlvm root=/dev/LUKSvol/root nomodeset"``
    5. Run ``grub-mkconfig -o /boot/grub/grub.cfg`` to generate the new GRUB configuration
15. The installation should be complete. ``exit`` then ``umount -R /mnt`` and ``reboot``.
16. Press F12 at the Dell splash screen.
    * Other Options -> BIOS Setup
      * Settings -> General -> Boot Sequence
      * Click "Add Boot Option"
        * Boot Option Name: "GRUB"
        * Leave File System List as-is
        * File Name: click "..." to browse, browse to ``\EFI\GRUB\grubx64.efi``
        * OK
      * Click the "GRUB" entry in the boxes at the top right, and move it to be the first option (using the arrow buttons).
17. "Apply" then "Exit". System will reboot.
18. If all went well, you should get a GRUB menu and then the beginning of Arch boot. You'll be prompted for the LUKS passphrase; enter it and you should boot into Arch.
19. Connect to your network and get DHCP (``systemctl start dhcpcd@INTERFACE-NAME``). If you want to continue with the following steps over ssh, ``echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && systemctl start sshd``.
20. Continue on with the Puppetized installation process per [Arch Linux in README.md](https://github.com/jantman/workstation-bootstrap/blob/master/README.md#arch-linux):
    1. Do a full update: ``pacman -Syu``
    2. ``pacman -S base-devel puppet git lsb-release ruby`` - when prompted, install the whole base-devel group
    3. ``gem install --no-user-install r10k``
    4. If you're using a private GitHub repo for customization, generate SSH keys for root and add them as deploy keys on the repo.
    5. As root, in ``/root``: ``git clone https://github.com/jantman/workstation-bootstrap.git && cd workstation-bootstrap``
    6. ``./bin/run_r10k_puppet.sh | tee /root/puppet.$(date +%s)`` - run puppet and capture the output.
21. Install some packages for the graphics: ``pacman -S linux-headers xf86-video-intel nvidia-dkms nvidia-settings xorg-xrandr tlp``
