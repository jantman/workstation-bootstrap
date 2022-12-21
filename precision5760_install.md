# Dell Precision 5760 Install

This documents my installation process on my new Dell Precision 5760 laptop, which came factory installed with Dell's Ubuntu 20.04.2 LTS image (kernel 5.10.0-1020-oem).

The main goal is to install my standard Arch Linux desktop environment, along with UEFI Secure Boot and TCG/OPAL self-encrypting drive (SED) on the SSD. I originally purchased the laptop with (due to either confusion or a mis-click) a _non self-encrypting_ Kioxia KXG70ZNV1T02 NVMe SSD. After receiving the laptop and discovering this, I swapped it out for a Samsung 990 Pro 2TB Gen 4 NVMe SSD (MZ-V9P2T0B/AM) from MicroCenter that supports OPAL 2.

## IMPORTANT - Aftermarket Samsung SSD

Before installing a self-encrypting SSD, make **sure** to record the PSID from the label on the drive. This is needed for some (e.g. my Samsung 990 Pro) drives to enable encryption, and if you don't record it first, you'll have to open the laptop up again to get the PSID.

## Step 1 - Pre-Installation / Hardware Delivery

1. Power up the laptop and boot into the default Ubuntu install, configure it. Do this connected to isolated guest WiFi.
1. Test hardware - speakers, mic, webcam, bluetooth (for some reason, scan doesn't show any devices).
1. Create a recovery image on USB drive, following [How to create a Dell-Ubuntu Image on your Dell PC](https://www.dell.com/support/kbdoc/en-us/000152096/how-to-create-a-dell-ubuntu-image-on-your-dell-pc)
1. Also download the official Dell hosted recovery image and burn to USB drive: [How to recover a Dell-Ubuntu Image on your Dell PC](https://www.dell.com/support/kbdoc/en-us/000131480/how-to-recover-a-dell-ubuntu-image-on-your-dell-pc)
1. Gather information on the configured repositories and factory-installed packages, and [magic-wormhole](https://magic-wormhole.readthedocs.io/) it to my desktop:
   1. `sudo su -`
   1. `mkdir /tmp/data && cd /tmp/data`
   1. `cp /etc/apt/sources.list . && cp /etc/apt/sources.list.d/* .`
   1. `apt list --installed > apt-list-installed`
   1. `apt update`
   1. `cp /var/lib/apt/lists/oem.archive.canonical.com* .`
   1. `cp /var/lib/apt/lists/dell* .`
   1. `for i in oem-fix-misc-cnl-tlp-estar-conf oem-release oem-somerville-factory-meta oem-somerville-factory-stantler-meta oem-somerville-meta oem-somerville-partner-archive-keyring oem-somerville-stantler-meta ubuntu-oem-keyring; do echo $i; apt show $i >> oem-package-info.txt; done`
   1. `for i in $(dpkg-query -l | grep '^ii' | awk '{print $2}'); do apt-cache madison $i; done | tee packages.txt`
   1. `apt install magic-wormhole`
   1. Send those to my desktop via `wormhole`
1. Run the Ubuntu Software app and update everything; we're especially interested in updates to the Dell software and any firmware. **Note** that running the update seems to trigger Secure Boot errors, which is sort of troubling. Disable Secure Boot for now.
1. Ok... I'm pretty sure that the Ubuntu update was _trying_ to update the BIOS ("Dell Firmware") and that is what triggered the Secure Boot failure, but that it was a one-time thing (i.e. update the package in Ubuntu and reboot into the BIOS updater). So, disable Secure Boot and update the BIOS using the [USB drive procedure](https://www.dell.com/support/kbdoc/en-us/000131486/update-the-dell-bios-in-a-linux-or-ubuntu-environment). This updates the BIOS from 1.11.0 to 1.14.0. Reboot into Ubuntu and make sure it still works.
1. Reboot and press F12 at the Dell splash screen to enter BIOS setup. We'll set an Admin password (which supposedly unlocks some additional settings) and change some defaults.
   1. BIOS SETUP -> Passwords -> Admin Password. Set an Admin password. Apply Changes. EXIT and re-enter setup.
   1. BIOS SETUP -> enter Admin Password
   1. Boot Configuration -> Boot Sequence -> un-check `UEFI HTTPs Boot`
   1. Boot Configuration -> Secure Boot Mode -> Audit Mode. Should have been set this way from firmware update.
   1. Storage -> SMART Reporting -> Enable SMART Reporting.
   1. Connection -> Enable UEFI Network Stack -> Disabled.
   1. Power -> Battery Configuration -> Standard.
   1. Power -> USB Wake Support -> Wake on Dell USB-C Dock -> Off.
   1. Power -> Block Sleep -> Block Sleep -> ON.
   1. Power -> Lid Switch -> Power On Lid Open -> off.
   1. Security -> Intel Total Memory Encryption -> ON.
   1. Update,Recovery -> BIOS Recovery from Hard Drive -> off.
   1. System Management -> Asset Tag -> set to my email address and hostname of this laptop
   1. Pre-boot Behavior -> Fastboot -> Thorough
   1. Pre-boot Behavior -> Extend BIOS POST Time -> 5 seconds
   1. Pre-boot Behavior -> MAC Address Pass-Through -> Disabled
   1. Apply changes and exit; allow to boot into Ubuntu.
1. Shut down/reboot.
1. On a working machine, [download](https://archlinux.org/download/) the latest Arch Linux install media, verify the checksum and signature, and write it to a USB drive.

## Step 2 - Self-Encrypting Drive (SED) Setup

1. Prepare for setting up the self-encrypting drive (SED) with Secure Boot support per the instructions in [Drive-Trust-Alliance/sedutil issue #259: HowTo SecureBoot support](https://github.com/Drive-Trust-Alliance/sedutil/issues/259)
   1. Create a temporary directory on a computer with `openssl`, `efitools`, `fatresize` and `sbsigntool`.
   1. Generate your Secure Boot signing keys for the new computer: `openssl req -new -x509 -newkey rsa:2048 -sha256 -days 3650 -subj "/CN=Platform Key" -keyout PK.key -out PK.pem -nodes && openssl req -new -x509 -newkey rsa:2048 -sha256 -days 3650 -subj "/CN=Key Exchange Key" -keyout KEK.key -out KEK.pem -nodes && openssl req -new -x509 -newkey rsa:2048 -sha256 -days 3650 -subj "/CN=Image Signing Key" -keyout ISK.key -out ISK.pem -nodes`
   1. Convert the keys to ESL format: `cert-to-efi-sig-list -g "$(uuidgen)" PK.pem PK.esl && cert-to-efi-sig-list -g "$(uuidgen)" KEK.pem KEK.esl && cert-to-efi-sig-list -g "$(uuidgen)" ISK.pem ISK.esl`
   1. In order for UEFI drivers and option ROMS to work, obtain [Microsoft's UEFI driver signing CA key](http://go.microsoft.com/fwlink/?LinkId=321194) and then convert it to a PEM and ESL: `openssl x509 -in MicCorUEFCA2011_2011-06-27.crt -inform DER -out UEFI.pem -outform PEM && cert-to-efi-sig-list -g "$(uuidgen)" UEFI.pem UEFI.esl`
   1. Create db.esl: `cat ISK.esl UEFI.esl > db.esl`
   1. Sign everything (PK by itself, then KEK by PK, then db by KEK): `sign-efi-sig-list -k PK.key -c PK.pem PK PK.esl PK.auth && sign-efi-sig-list -k PK.key -c PK.pem KEK KEK.esl KEK.auth && sign-efi-sig-list -k KEK.key -c KEK.pem db db.esl db.auth`
   1. Download Drive-Trust-Alliance's [UEFI64.img.gz](https://github.com/Drive-Trust-Alliance/sedutil/wiki/Executable-Distributions) (in this case I'm using the [1.20.0](https://github.com/Drive-Trust-Alliance/exec/releases/tag/1.20.0) version), gunzip it, and then sign its components:
      1. `fdisk -l UEFI64.img` - verify 512-byte sectors and partition start of 2048. If different, adjust the offset below
      1. `mount -t msdos -o loop,rw,uid=$(id -u),gid=$(id -g),offset=1048576 UEFI64.img /mnt/temp`
      1. `cp /mnt/temp/efi/boot/bootx64.efi .`
      1. `sbsign --key ISK.key --cert ISK.pem bootx64.efi && rm bootx64.efi && mv bootx64.efi.signed bootx64.efi`
      1. `cp bootx64.efi /mnt/temp/efi/boot/bootx64.efi`
      1. Now we add the fix for https://github.com/Drive-Trust-Alliance/sedutil/issues/404
         1. `cp /mnt/temp/efi/boot/syslinux.cfg .`
         1. `vim syslinux.cfg` and remove `acpi=off noapic`
         1. `cp syslinux.cfg /mnt/temp/efi/boot/syslinux.cfg`
      1. `sync ; sync ; umount /mnt/temp`
      1. `rm bootx64.efi`
   1. Write the resulting `UEFI64.img` to a USB flash drive.
1. Continue on to the actual SED setup per the [Drive-Trust-Alliance wiki](https://github.com/Drive-Trust-Alliance/sedutil/wiki/Encrypting-your-drive):
   1. Download Drive-Trust-Alliance's [RESCUE64.img.gz](https://github.com/Drive-Trust-Alliance/sedutil/wiki/Executable-Distributions) (in this case I'm using the [1.20.0](https://github.com/Drive-Trust-Alliance/exec/releases/tag/1.20.0) version), gunzip it, and write it to a USB flash drive with: `dd bs=4M conv=fsync status=progress oflag=direct if=RESCUE64.img of=/dev/sdX; sync; sync`
   1. Power up, enter BIOS, ensure that SecureBoot is disabled.
   1. Plug the rescue image USB flash drive in and exit BIOS. On reboot, press F12 for the one-time boot menu, select the UEFI USB 3.0 drive, and enter admin password to boot from it.
   1. We get a DriveTrust login prompt. Log in as `root` and get dropped into a shell. Plug in the other USB drive and `mount /dev/sdb1 /mnt/temp`
   1. `sedutil-cli --scan` and confirm that the drive is OPAL2 compliant (`12` in the second column, indicating OPAL 1.0 and 2.0).
   1. `linuxpba` and verify that in the output, the drive is listed as `is OPAL NOT LOCKED`
   1. `sedutil-cli --initialsetup debug /dev/nvme0` - this throws an error with `method status code NOT_AUTHORIZED` and `takeOwnership failed`. [this issue](https://github.com/Drive-Trust-Alliance/sedutil/issues/382) seems to indicate that the new Samsung disks are a bit messed up from the factory and [sedutil-cli --initialsetup fails with “NOT\_AUTHORIZED” on uniniatilized drive when booting with UEFI. · Issue #291 · Drive-Trust-Alliance/sedutil](https://github.com/Drive-Trust-Alliance/sedutil/issues/291) which implies that the drive needs a PSID revert before it can be encrypted.
   1. `sedutil-cli -–yesIreallywanttoERASEALLmydatausingthePSID <YOURPSID> /dev/nvme0` - this reports `revertTper completed successfully`
   1. `sedutil-cli --initialsetup debug /dev/nvme0` - this completes successfully and says initial setup complete
   1. `sedutil-cli --enablelockingrange 0 debug /dev/nvme0`
   1. `sedutil-cli --setlockingrange 0 lk debug /dev/nvme0`
   1. `sedutil-cli --setmbrdone off debug /dev/nvme0`
   1. Plug in the other USB drive with our `UEFI64.img` on it, `mkdir /mnt/temp && mount /dev/sdb1 /mnt/temp && ls /mnt/temp`
   1. `sedutil-cli --loadpbaimage debug /mnt/temp/UEFI64.img /dev/nvme0`
   1. `umount /mnt/temp`
   1. `sedutil-cli --query /dev/nvme0` - this should report the drive as locked
   1. `linuxpba` and enter `debug` as the passphrase. This should unlock the drive (in the command's own output)
   1. set the real passphrase
      1. `sedutil-cli --setsidpassword debug REAL-PASS /dev/nvme0`
      1. `sedutil-cli --setadmin1pwd debug REAL-PASS /dev/nvme0`
   1. `sedutil-cli --setmbrdone on REAL-PASS /dev/nvme0`
   1. Hard power-off the laptop by holding down the power button until it shuts off.
   1. Unplug both USB drives, plug in the Arch install media, and then power the laptop on again. If all goes well, we'll get a Dell splash screen and then the PBA unlock prompt. Enter the password and it will show the drive unlocking and then "Starting OS" and then after a few seconds it will reboot and show the Arch live media bootloader menu. Select "System shutdown" and the system will power off.

## Step 3 - Arch Installation

Beginning from the previous steps, we have the Arch live media in the USB port. Power on, unlock the drive via PBA prompt, boot into the Arch installer.

If not already done, set up a fixed IP lease for a USB-C Ethernet adapter, and set up internal DNS for it (`myprecious-wired`). Plug in to the laptop and wired network and turn it on. This ends up booting directly to the Arch installation media without unlocking the drive. Select "System restart" and F12 for the one-time boot menu. Select the UEFI Samsung disk to trigger the PBA, unlock the drive, and then continue into the Arch live installer.

1. Install according to the [Arch Installation Guide](https://wiki.archlinux.org/title/installation_guide):
   1. We can skip the keymap setup (ours is US default) and checking boot mode (this laptop only supports UEFI).
   1. `ip link` shows our USB ethernet interface has link; `ip addr` shows that we have a valid and correct IP.
   1. `timedatectl status` reports the correct date and time.
   1. Set up for installation over SSH according to [Install Arch Linux via SSH - ArchWiki](https://wiki.archlinux.org/title/Install_Arch_Linux_via_SSH):
      1. `passwd` to set a temporary root password in the live environment; assuming you've got a relatively secure LAN, use something easy like `foobarbaz`
      1. `grep PermitRootLogin /etc/ssh/sshd_config` and ensure it's set to `yes`
      1. `ssh -o StrictHostKeyChecking=no -o "UserKnownHostsFile /dev/null" root@192.168.0.30` and **perform the rest of these steps via SSH for easy copy/paste**
   1. Partition the disks:
      1. `fdisk -l` reports the 1.82TB Samsung SSD on `/dev/nvme0n1`
      1. `fdisk /dev/nvme0n1` and set up partitions:
         1. `g` to create new GPT partition table
         1. `n` to add partition 1; default start sector of 2048, size `+1G`
         1. `t` to change type of partition 1; change to `1`, `EFI System`
         1. `n` to add partition 2; default start sector, size `+70G`
         1. `t` to chanve type of partition 2; change to `19`, `Linux swap`
         1. `n` to add partiton 3; default start sector, use all available space
         1. `t` to change type of partition 3; change to `23`, `Linux root (x86-64)`
         1. `p` to verify the partition layout; it should look like this:

               Disk /dev/nvme0n1: 1.82 TiB, 2000398934016 bytes, 3907029168 sectors
               Disk model: Samsung SSD 990 PRO 2TB                 
               Units: sectors of 1 * 512 = 512 bytes
               Sector size (logical/physical): 512 bytes / 512 bytes
               I/O size (minimum/optimal): 512 bytes / 512 bytes
               Disklabel type: gpt
               Disk identifier: E4676A78-F194-4A4E-A5D1-F9A330B88555

               Device             Start        End    Sectors  Size Type
               /dev/nvme0n1p1      2048    2099199    2097152    1G EFI System
               /dev/nvme0n1p2   2099200  148899839  146800640   70G Linux swap
               /dev/nvme0n1p3 148899840 3907028991 3758129152  1.8T Linux root (x86-64)

         1. `w` to write table to disk
   1. Format the partitions:
      1. `mkfs.fat -F 32 /dev/nvme0n1p1`
      1. `mkswap /dev/nvme0n1p2`
      1. `mkfs.ext4 /dev/nvme0n1p3`
   1. Mount the partitions:
      1. `mount /dev/nvme0n1p3 /mnt`
      1. `mount --mkdir /dev/nvme0n1p1 /mnt/boot`
      1. `swapon /dev/nvme0n1p2`
   1. `less /etc/pacman.d/mirrorlist` - make sure the top 20 look sane
   1. Update the archlinux-keyring in our live environment: `pacman -Sy && pacman -S archlinux-keyring`
   1. Install the minimum required packages, plus the ones we'll need: `pacstrap -K /mnt base linux linux-firmware vim dhcpcd efitools sbsigntools openssl openssh puppet r10k networkmanager intel-ucode efibootmgr lsb-release git`
   1. generate fstab: `genfstab -U /mnt >> /mnt/etc/fstab && cat /mnt/etc/fstab` and make sure it looks right
   1. chroot into the new system: `arch-chroot /mnt`
      1. set the timezone: `ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime`
      1. `hwclock --systohc`
      1. `vim /etc/locale.gen` and uncomment `en_US.UTF-8 UTF-8` and then run `locale-gen`
      1. `echo 'LANG=en_US.UTF-8' > /etc/locale.conf`
      1. set hostname: `echo myprecious > /etc/hostname`
      1. Enable NetworkManager at boot: `systemctl enable NetworkManager.service`
      1. Set the root password via `passwd` and store it where I store passwords.
      1. We'll eventually want to use a unified kernel image with Secure Boot, but for now, we'll just use EFISTUB booting via `efibootmgr`:
         1. Get [auto-UEFI-entry](https://github.com/de-arl/auto-UEFI-entry) to create the entries: `curl -o /root/aufii https://raw.githubusercontent.com/de-arl/auto-UEFI-entry/1647c60e4b4fe6ab85d87074230f4aef35322991/aufii`
         1. `bash /root/aufii` and answer as appropriate, but abort after it creates the commands and run them manually in the next two steps
         1. `efibootmgr --disk /dev/nvme0n1 --part 1 --create --label "Arch-Fallback" --loader /vmlinuz-linux --unicode 'root=UUID=2d94451b-9dd7-4be3-8475-b2ba420face8 resume=UUID=f4021375-be08-4aea-8538-fef65d4881d7 rw initrd=\intel-ucode.img initrd=\initramfs-linux-fallback.img'`
         1. `efibootmgr --disk /dev/nvme0n1 --part 1 --create --label "Arch" --loader /vmlinuz-linux --unicode 'root=UUID=2d94451b-9dd7-4be3-8475-b2ba420face8 resume=UUID=f4021375-be08-4aea-8538-fef65d4881d7 rw initrd=\intel-ucode.img initrd=\initramfs-linux.img'`
         1. The output of that second command now becomes:

               BootCurrent: 0001
               Timeout: 0 seconds
               BootOrder: 0005,0000,0001,0004,0002,0003
               Boot0000* Arch-Fallback HD(1,GPT,0ff51f6d-e5cf-1849-b047-12fb1ad3437d,0x800,0x200000)/File(\vmlinuz-linux)root=UUID=2d94451b-9dd7-4be3-8475-b2ba420face8 resume=UUID=f4021375-be08-4aea-8538-fef65d4881d7 rw initrd=\intel-ucode.img initrd=\initramfs-linux-fallback.img
               Boot0001* UEFI USB DISK 3.0 071C2A29A51FEB16    PciRoot(0x0)/Pci(0xd,0x0)/USB(4,0)/USB(0,0)/HD(2,MBR,0x9af9df7e,0x191800,0x7800)/File(\EFI\Boot\BootX64.efi)걎脈鼑䵙຅᫢ⱒ뉙
               Boot0002* PEBOOT        HD(1,GPT,6324d913-bef4-405b-90ce-2787b3518557,0x800,0x1a9000)/File(\EFI\PEBoot\bootx64.efi)
               Boot0003* Linux Firmware Updater        HD(1,GPT,6324d913-bef4-405b-90ce-2787b3518557,0x800,0x1a9000)/File(\EFI\ubuntu\shimx64.efi) File(.\fwupdx64.efi)
               Boot0004* UEFI USB DISK 3.0 071C2A29A51FEB16 2  PciRoot(0x0)/Pci(0xd,0x0)/USB(4,0)/USB(0,0)/CDROM(1,0x191800,0x1e000)/File(\EFI\Boot\BootX64.efi)걎脈鼑䵙຅᫢ⱒ뉙
               Boot0005* Arch  HD(1,GPT,0ff51f6d-e5cf-1849-b047-12fb1ad3437d,0x800,0x200000)/File(\vmlinuz-linux)root=UUID=2d94451b-9dd7-4be3-8475-b2ba420face8 resume=UUID=f4021375-be08-4aea-8538-fef65d4881d7 rw initrd=\intel-ucode.img initrd=\initramfs-linux.img

      1. Exit the chroot with `exit`
   1. Unmount all partitions with `umount -R /mnt`
   1. `reboot` to reboot the system
1. F12 at the splash screen; enter BIOS Setup, unlock with Admin password, and in Boot Configuration move `PEBOOT` to the top and then after that should be "Arch" and then "Arch-Fallback". Apply changes and exit, and **unplug the Arch installer media**.
1. Let the machine boot. If all is well so far we'll boot into the PBA, unlock our drive, and then boot into the new Arch system. Note that just like the live media, we get about 30 seconds of constantly-scrolling `nouveau` errors; we'll deal with that later.
   1. Log in as root.
   1. `ip link && ip addr` - we should have DHCP on the wired interface
   1. Start sshd so we can SSH in for the rest: `echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && systemctl start sshd`
   1. SSH in as root again, and log out on the console to keep things simple.
   1. To keep things sane, edit `init.pp` in my private puppet module to exempt this host from all of my puppet customization (just a single host-specific module), commit and push.
   1. Generate SSH keys for root: `ssh-keygen`
   1. `cat /root/.ssh/id_rsa.pub` and add that as a deploy key on my private puppet repo
   1. `echo -e "Host github.com\n  StrictHostKeyChecking no\n  UserKnownHostsFile /dev/null\n" >> ~/.ssh/config && chmod 0600 ~/.ssh/config`
   1. `cd /root && git clone https://github.com/jantman/workstation-bootstrap.git && cd workstation-bootstrap`
   1. `./bin/run_r10k_puppet.sh --noop` and ensure that it's not going to do more than setting up iptables, my user account and group, and the `/root/bin` puppet stuff
   1. Run again without the `--noop`
1. At this point, the rest of installation and configuration (other than actually setting up Secure Boot) is done via puppet. Run puppet until it succeeds and I'm happy. For a history of changes, see the commits in my private puppet repo subsequent to `7d2a48f`.

## Step 4 - Secure Boot Setup

1. Finally, provision our Secure Boot keys and enable Secure Boot and try to boot:
   1. TBD.
