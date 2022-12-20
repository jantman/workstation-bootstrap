# Dell Precision 5760 Install

This documents my installation process on my new Dell Precision 5760 laptop, which came factory installed with Dell's Ubuntu 20.04.2 LTS image (kernel 5.10.0-1020-oem).

The main goal is to install my standard Arch Linux desktop environment, along with UEFI Secure Boot and TCG/OPAL self-encrypting drive (SED) on the SSD. I originally purchased the laptop with (due to either confusion or a mis-click) a _non self-encrypting_ Kioxia KXG70ZNV1T02 NVMe SSD. After receiving the laptop and discovering this, I swapped it out for a Samsung 990 Pro 2TB Gen 4 NVMe SSD (MZ-V9P2T0B/AM) from MicroCenter that supports OPAL 2.

## Pre-Installation / Hardware Delivery

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
   1. `sedutil-cli --initialsetup debug /dev/nvme0` - this throws an error with `method status code NOT_AUTHORIZED` and `takeOwnership failed`. [this issue](https://github.com/Drive-Trust-Alliance/sedutil/issues/382) seems to indicate that the new Samsung disks are a bit messed up from the factory. Running `sedutil-cli --printDefaultPassword /dev/nvme0` shows an MSID of a very very long, random-looking string.
   1. `export PSWD=$(sedutil-cli --printDefaultPassword /dev/nvme0 | awk '{print $2}'); echo $PSWD`
   1. Try again: `sedutil-cli --initialsetup $PSWD /dev/nvme0` - same error.
   1. Aaaand... now find [sedutil-cli --initialsetup fails with “NOT\_AUTHORIZED” on uniniatilized drive when booting with UEFI. · Issue #291 · Drive-Trust-Alliance/sedutil](https://github.com/Drive-Trust-Alliance/sedutil/issues/291) which implies that I needed to capture the PSID off of the new SSD before installing it. So, after all that, I need to open the _brand_ new laptop up _again_.
1. Finally, provision our Secure Boot keys and enable Secure Boot and try to boot:
   1. TBD.
1. Try booting from the sedutil Rescue image; if we signed it correctly, it should work.
