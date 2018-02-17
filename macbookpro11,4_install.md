# macbookpro11,4 install

What follows are my personal notes (circa September 2015) of setting up my new MacBook Pro 11,4 ("Mid-2015", third generation/Retina) for dual boot between MacOS and Arch Linux, with Arch Linux on a LUKS encrypted partition (single LUKS crypted / dm-crypt partition with LVM) and FileVault full disk encryption for the Mac side.

1. [Initial Setup](#initial-setup)
2. [rEFInd](#refind)
3. [Arch Linux Install](#arch-linux-install)
4. [Mac Setup - Boxen](#mac-setup---boxen)
5. [Linux Setup - Puppet](#linux-setup---puppet)

## Important Notes 2 Years Later

1. Note that these instructions were written in 2015 and (hopefully) I won't be redoing them until either I switch jobs or my laptop comes up on our 4-year refresh cycle. Some details may have changed since then, but the gist should be the same.
2. I originally setup LVM partitions on my ~92GB LUKS-crypted Linux partition for a 17G swap, 20G root and 55.5GB home volume. As I've been relying heavily on Docker lately this became problematic. Not wanting to mess with resizing the LVM volumes and partitions, I've moved ``/var/lib/docker`` to the home partition, so that I can manage the balance between data in my home directory and Docker.

## Initial Setup

1. Boot machine, setup my user (jantman) and set a password, and setup WiFi. When prompted, setup my existing Apple ID.
2. Drag Applications/Utilities/Terminal to the launcher.
3. Decine on a hostname ("exodus-mac" for the first one) and set it: ``sudo scutil --set HostName exodus-mac``; open a new terminal to refresh.
4. Shrink the Mac partition ([special instructions](http://apple.stackexchange.com/a/181898/43696) for 10.10 Yosemite with CoreStorage):
   1. Shut down the machine; reboot into Internet Recovery Mode holding ``alt`` + ``cmd`` + ``R`` (release when it shows the spinning globe and "Starting Internet Recovery")
   2. Open Utilities/Terminal in the menubar
   3. Run ``diskutil list`` to get the partition layout, and possibly photograph this. On my machine, ``/dev/disk1`` is the main SSD (with GUID partitioning, a 209 MB EFI partition (``disk1s1``), a 650MB Recovery HD (``disk1s3``), and a 250GB CoreStorage volume (``disk1s2``)), and ``/dev/disk2`` is the "Macintosh HD" 249GB volume (a logical volume on ``disk1s2``).
   4. Run ``diskutil cs list`` to list CoreStorage volumes
   5. Get the UUID of the 'Macintosh HD' Logical Volume
   6. Shrink it to 150GB: ``diskutil cs resizeStack <UUID> 150g``; this should also automatically move "Recovery HD" to the end of the partition
   7. When this finishes, ``exit`` and quit Terminal
   8. Open "Disk Utility" and run "Verify Disk" on "Macintosh HD", and verify that it shows as 150GB
   9. Quit Disk Utility, Reboot. It should boot to the normal disk, and your Mac OS install; login.
5. ``ssh-keygen``
6. Launch the "App Store" app; search for and install XCode (full version).
7. Enable FileVault Full Disk Encryption:
   1. ``Apple Menu -> System Preferences -> Security and Privacy``; Select the ``FileVault`` tab, unclick the padlock icon to enable changes, and click the "Turn On FileVault..." button.
   2. Select "Create a recovery key and do not use my iCloud account"
   3. Transcribe the recovery key onto a piece of paper, and store in fireproof safe.
   4. Restart computer to begin encryption process.
   5. Wait for disk encryption to finish, and then close System Preferences.

rEFInd
-------

Before we go any further with setting up Mac OS, we want to at least make sure that we can get Arch and the bootloader setup and working; it's better to do this now than later, as there's a chance we might need to reinstall OS X.

1. Download the [Arch Linux Image](https://www.archlinux.org/download/), verify checksums and signatures.
2. Verify PGP signatures and sha1 sums.
3. write to USB flash drive: ``dd bs=4M if=/path/to/archlinux.iso of=/dev/sdx && sync``
4. Open Safari and [download rEFInd](http://www.rodsbooks.com/refind/getting.html)
5. Open a terminal and navigate to the rEFInd download directory.
6. ``./install.sh`` (``--esp`` is now default in rEFInd 0.8.4+; some [posts](http://unix.stackexchange.com/a/167777/7234) recommend ``--alldrivers``, but the docs warn against this).
7. if unmount failed: ``diskutil unmount /Volumes/ESP``
8. Copy the ext drivers:
   1. ``diskutil list`` - find the partition ID of the ``EFI`` partition (``disk0s1`` on my Mac)
   2. ``sudo su -``
   3. ``mkdir /Volumes/ESP``
   4. ``mount -t msdos /dev/disk0s1 /Volumes/ESP``
   5. ``mkdir /Volumes/ESP/EFI/refind/drivers_x64``
   6. cd to the rEFInd download directory
   7. ``cp refind/drivers_x64/ext4_x64.efi /Volumes/ESP/EFI/refind/drivers_x64/``
   8. ``cd ~/``
   9. ``diskutil unmount /Volumes/ESP``

Arch Linux Install
-------------------

1. Plug in the Arch Linux flash drive and reboot
2. If all went well, you should get the rEFInd bootloader almost immediately; select the ``Boot EFI\boot\loader.efi from ARCHISO_EFI``entry; let it choose and boot the Arch option. If that goes right, you should end up at a ``root@archiso ~ #`` prompt.
3. Partitioning - we're going to go for full system encryption using dm-crypt and [LVM on LUKS](https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system#LVM_on_LUKS) with [suspend-to-disk support](https://wiki.archlinux.org/index.php/Dm-crypt/Swap_encryption#LVM_on_LUKS)
   1. ``cgdisk`` to create partitons (92.9G free at start)
   2. create a first partition, start of ``+128M``, size 250M, type ``8300``, name ``boot``
   3. create a LUKS partition, start of next block, size all remaining, type ``8E00``, name ``arch``
   4. write the partition table
   5. Determine an encryption password, and record it on paper; store in fireproof safe.
   6. ``cryptsetup luksFormat /dev/sda5`` (use the LVM device)
   7. ``cryptsetup open --type luks /dev/sda5 lvm``
   8. ``pvcreate /dev/mapper/lvm``
   9. ``vgcreate arch /dev/mapper/lvm``
   10. ``lvcreate -L 17G arch -n swapvol`` - 17G swap volume
   11. ``lvcreate -L 20G arch -n rootvol`` - 20G root volume
   12. ``lvcreate -l +100%FREE arch -n homevol`` - 55.5G home volume
   13. ``mkfs.ext4 /dev/mapper/arch-rootvol``
   14. ``mkfs.ext4 /dev/mapper/arch-homevol``
   15. ``mkswap /dev/mapper/arch-swapvol``
   16. ``mount /dev/arch/rootvol /mnt``
   17. ``mkdir /mnt/home``
   18. ``mount /dev/arch/homevol /mnt/home``
   19. ``swapon /dev/arch/swapvol``
   20. ``mkfs.ext4 /dev/sda4``
   21. ``mkdir /mnt/boot``
   22. ``mount /dev/sda4 /mnt/boot``
   23. Continue installation process up to mkinitcpio configuration.
4. Time setup
   1. check hardware clock with ``timedatectl`` - ensure that it's correct and hardware is set to UTC
   2. set the timezone: ``timedatectl set-timezone America/New_York``
   3. ``date`` should now display the correct local time
5. Set mirrors - per https://wiki.archlinux.org/index.php/Mirrors#List_by_speed
   1. ``cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup``
   2. ``vim /etc/pacman.d/mirrorlist.backup`` - make sure the US mirrors are un-commented
   3. ``rankmirrors -n 6 /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist``
6. ``pacstrap /mnt base base-devel``
7. ``genfstab -p /mnt >> /mnt/etc/fstab``
8. ``arch-chroot /mnt``
9. ``echo "exodus.jasonantman.com" > /etc/hostname``
10. ``ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime``
11. ``vi /etc/locales.gen`` and uncomment ``en_US.UTF-8 UTF-8`` and then ``locale-gen``
12. ``echo LANG=en_US.UTF-8 > /etc/locale.conf``
13. ``echo KEYMAP=qwerty > /etc/vconsole.conf``
14. Skip networking for now; we're already connected, and we'll setup [NetworkManager](https://wiki.archlinux.org/index.php/NetworkManager) later.
15. So we can work a bit easier, ``pacman -S vim``
16. ``vim /etc/mkinitcpio.conf``; set the ``HOOKS=`` line to ``HOOKS="base udev autodetect usbinput modconf block keymap encrypt lvm2 resume filesystems keyboard fsck shutdown"`` per [dm-crypt/Encrypting an entire system - ArchWiki](https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system#Configuring_mkinitcpio_2), [dm-crypt/Swap encryption - ArchWiki](https://wiki.archlinux.org/index.php/Dm-crypt/Swap_encryption#LVM_on_LUKS), [MacBook - ArchWiki](https://wiki.archlinux.org/index.php/MacBook#Installation) and http://iocrunch.com/2014/02/linux-dual-boot-on-mac-with-full-disk-encryption/
17. mkinitcpio -p linux
18. set the root password: ``passwd`` (and record it somewhere secure)
19. rEFInd configuration (most of this came from [here](http://iocrunch.com/2014/02/linux-dual-boot-on-mac-with-full-disk-encryption/) even though it conflicts with the [dm-crypt instructions](https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system#Configuring_the_boot_loader_2), with some additions from [dm-crypt/Swap encryption - ArchWiki](https://wiki.archlinux.org/index.php/Dm-crypt/Swap_encryption#LVM_on_LUKS) and [dm-crypt/Specialties - ArchWiki](https://wiki.archlinux.org/index.php/Dm-crypt/Specialties#Discard.2FTRIM_support_for_solid_state_drives_.28SSD.29)):
   1. ``echo '# This manipulates the linux kernel options in the refind boot loader' > /boot/refind_linux.conf``
   2. ``echo '"Crypt Boot"                 "cryptdevice=/dev/sda5:arch:allow-discards root=/dev/mapper/arch-rootvol rw resume=/dev/mapper/arch-swapvol"' >> /boot/refind_linux.conf``
   3. ``echo '"Crypt Boot with nomodeset"  "cryptdevice=/dev/sda5:arch:allow-discards root=/dev/mapper/arch-rootvol rw resume=/dev/mapper/arch-swapvol nomodeset"' >> /boot/refind_linux.conf``
   4. ``echo '"Crypt Boot Text Mode"       "cryptdevice=/dev/sda5:arch:allow-discards root=/dev/mapper/arch-rootvol rw resume=/dev/mapper/arch-swapvol systemd.unit=multi-user.target"' >> /boot/refind_linux.conf``
20. exit the chroot: ``exit``
21. ``reboot``
22. remove the USB key
23. Boot Arch; enter the LUKS password when prompted
24. Login as root and confirm that you can.
25. ``ip addr`` shows no addresses; find your wired interface name (mine was ``enp0s20u1``) and start DHCP (``systemctl start dhcpcd@enp0s20u1``). ``ip addr`` should now show an address and ``ping www.google.com`` should resolve the address and ping.
26. ``reboot`` and boot into OS X. You should be able to log in as your user.

Mac Setup - Boxen
-----------------

1. Get your Mac user's SSH key onto a working machine, and add it to your GitHub account.
2. Setup Boxen on the Mac - https://github.com/jantman/boxen#distributing and run ``./script/boxen``; authenticate to GitHub when prompted
3. ``cd ~/``
4. ``boxen --env`` - make sure it works
5. ``boxen`` until it works with no changes

Linux Setup - Puppet
--------------------

1. Boot into Arch and login as ``root``
2. ``ip addr`` shows no addresses; find your wired interface name (mine was ``enp0s20u1``) and start DHCP (``systemctl start dhcpcd@enp0s20u1``). ``ip addr`` should now show an address and ``ping www.google.com`` should resolve the address and ping.
3. ``pacman -Syu``
4. follow the instructions in the [workstation-bootstrap README](https://github.com/jantman/workstation-bootstrap/tree/hiera_rewrite)
5. Login as your user
6. Use the Network Manager Plasmoid in the system tray; click the little settings icon to the right of the airplane mode checkbox, and add a DHCP connection on your Ethernet interface. You'll likely want to set it to activate automatically.
