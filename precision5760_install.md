# Dell Precision 5760 Install

This documents my installation process on my new Dell Precision 5760 laptop, which came factory installed with Dell's Ubuntu 20.04.2 LTS image (kernel 5.10.0-1020-oem).

The main goal is to install my standard Arch Linux desktop environment, along with enabling TCG/OPAL self-encrypting of the Kioxia KXG70ZNV1T02 NVMe SSD and UEFI Secure Boot.

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
