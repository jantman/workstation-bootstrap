# Raspberry Pi 4 ArchLinuxARM Install

This is the process I used to install ArchLinuxARM on a Raspberry Pi 4 (4GB), for use as an "emergency" computer while my [Precision 5530 laptop](precision5530_install.md) was being serviced.

This process was very experimental for me, and is also complicated by wanting the same cryptsetup process as my laptop, so these notes are both circuitious and verbose.

## Preparation

* SanDisk Ultra class 10 8GB microSDHC in a USB SD reader
* WD Elements 2TB USB3 hard drive (WDBU6Y0020BBK-WESN)
* [Download](https://archlinuxarm.org/about/downloads) ArchLinuxARM ``ArchLinuxARM-rpi-4-latest.tar.gz`` and check MD5 and signature
* Installation is performed from an x86_64 ArchLinux machine.

## Step 1 - SD Installation

Follow the [ArchLinuxARM Raspberry Pi 4 instructions](https://archlinuxarm.org/platforms/armv8/broadcom/raspberry-pi-4#installation):

1. Plug in SD card in reader; don't mount. Note the drive - mine was ``/dev/sdg``
2. Format according to the instructions - first partition 100M type "c" (W95 FAT32 (LBA)) and the rest of the card Linux (type 83).
3. Format the first partition as vfat. Create a ``./boot`` directory and mount there.
4. Format the second partition as ext4. Create a ``./root`` directory and mount there.
5. Extract the tarball in root: ``bsdtar -xpf ArchLinuxARM-rpi-4-latest.tar.gz -C root; sync``
6. Move the boot files to the boot partition: ``mv root/boot/* boot``
7. Umount: ``umount boot root``
8. Insert SD card in Pi, connect wired Ethernet, power on.
9. Once it boots log in as ``alarm:alarm`` (root password is ``root``) via HDMI monitor and keyboard.
10. Initialize the pacman keyring and populate it: ``pacman-key --init && pacman-key --populate archlinuxarm``.
11. Find the IP address and log in via SSH.
12. ``su -`` to root and run ``passwd`` to set a new root password.
13. Perform basic [system configuration](https://wiki.archlinux.org/index.php/installation_guide#Configure_the_system) steps:
    3. Set the time zone, i.e. ``ln -sf /usr/share/zoneinfo/Region/City /etc/localtime``
    4. Edit ``/etc/locale.gen`` as needed, run ``locale-gen``, and create ``/etc/locale.conf``
    5. Create ``/etc/hostname``
14. ``pacman -S mkinitcpio``
15. [Configure mkinitcpio per the dm-crypt instructions](https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system#Configuring_mkinitcpio_2): change the ``HOOKS`` line from ``HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)`` to ``HOOKS=(base udev autodetect modconf block encrypt lvm2 filesystems keyboard fsck)``. Save the file and then run ``mkinitcpio -p linux-raspberrypi4``. Then power off the Pi.
16. Connect the USB hard drive to your computer (not the Pi) and note the device name (``/dev/sdf`` for me).
17. We'll now wipe the disk (``sdf``) according to [dm-crypt wipe on an empty disk or partition](https://wiki.archlinux.org/index.php/Dm-crypt/Drive_preparation#dm-crypt_wipe_on_an_empty_disk_or_partition):
   1. ``cryptsetup open --type plain -d /dev/urandom /dev/sdf to_be_wiped``
   2. ``lsblk`` and verify ``to_be_wiped`` exists
   3. do the wipe: ``dd if=/dev/zero of=/dev/mapper/to_be_wiped bs=1M status=progress`` - on my 477GB disk, this took about 14 minutes
   4. ``cryptsetup close to_be_wiped``
18. We'll now set up [LVM on LUKS](https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system#LVM_on_LUKS) and partition the disks (this setup was chosen for the ease of suspend):
   1. ``fdisk /dev/sdf``; create a new partition table and partition the whole disk as a single type 83 partition. Write and exit.
   2. Create the LUKS container for the system: ``cryptsetup luksFormat --type luks2 /dev/sdf1``
   3. Open the container: ``cryptsetup open /dev/sdf1 cryptlvm``
   4. Create the physical volume: ``pvcreate /dev/mapper/cryptlvm``
   5. Create the volume group: ``vgcreate LUKSvol /dev/mapper/cryptlvm``
   6. Because I'm old-school, create a swap volume twice the size of the RAM (32G): ``lvcreate -L 32G LUKSvol -n swap``
   7. Because I'm lazy and this is a laptop (don't hate me), use the rest of the disk for a single root partition: ``lvcreate -l 100%FREE LUKSvol -n root``
   8. Setup the filesystems: ``mkswap /dev/LUKSvol/swap && mkfs.ext4 /dev/LUKSvol/root``
   9. Mount the partition: ``mount /dev/LUKSvol/root root``
19. ``mkdir sdroot sdboot`` then plug in the Pi SD Card via the USB adapter. On my system this was ``/dev/sdh``. ``mount /dev/sdh1 sdboot && mount /dev/sdh2 sdroot``
20. Move everything from the SD root to the USB disk: ``mv -f sdroot/* root/ && sync && umount sdroot``
21. Edit ``sdboot/cmdline.txt``. The original should be ``root=/dev/mmcblk0p2 rw rootwait console=ttyAMA0,115200 console=tty1 selinux=0 plymouth.enable=0 smsc95xx.turbo_mode=N dwc_otg.lpm_enable=0 kgdboc=ttyAMA0,115200 elevator=noop``.
    1. Find the UUID of the partition that we ran cryptsetup on (i.e. in ``/dev/disk/by-uuid``).
    2. Prepend to the command line: ``cryptdevice=UUID=<partition uuid>:cryptlvm``
    3. Replace the existing root specifier with ``root=/dev/LUKSvol/root``
    4. Save the file and exit.
22. Unmount everything: ``sync && umount root && umount sdboot && vgchange -an LUKSvol && cryptsetup close cryptlvm`` and then unplug both the USB disk and the SD card.
23. Plug the USB disk and the SD card in to the Pi and power it on. You should be prompted for the LUKS passphrase, after which the system will boot and eventually give you a login prompt. At this point you should be able to log in over SSH again (and see lots of free space on your root disk).
24. Continue on with the Puppetized installation process per [Arch Linux in README.md](https://github.com/jantman/workstation-bootstrap/blob/master/README.md#arch-linux):
   1. Do a full update: ``pacman -Syu``
   2. ``pacman -S base-devel puppet git lsb-release ruby`` - when prompted, install the whole base-devel group and puppet.
   3. ``gem install --no-user-install r10k``
   4. If you're using a private GitHub repo for customization, generate SSH keys for root and add them as deploy keys on the repo.
   5. As root, in ``/root``: ``git clone https://github.com/jantman/workstation-bootstrap.git && cd workstation-bootstrap``
   6. ``./bin/run_r10k_puppet.sh | tee /root/puppet.$(date +%s)`` - run puppet and capture the output.
25. ``userdel alarm && groupdel alarm && rm -Rf /home/alarm``
26. Sync over my home directory and run Puppet again. Reboot.
