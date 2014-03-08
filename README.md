etcpuppet
=========

/etc/puppet on my personal boxes

Setup
-----

### Arch Linux

1. Do a default, base install of Arch (i.e. see instructions in
   [puppet-archlinux-macbookretina](https://github.com/jantman/puppet-archlinux-macbookretina),
   though I now recommend making ``/boot`` and the ESP the same partition).
2. ``dhcpcd <interface name>`` to get minimally-working DHCP.
3. ``pacman -S openssh && systemctl start sshd`` so you can work remotely...
4. ``vi /etc/pacman.conf`` and add the [archlinuxfr](http://archlinux.fr/yaourt-en) repository,
   then ``pacman -Sy yaourt``
5. Make sure everything is up to date: ``pacman -Syu``
6. ``pacman -S base-devel`` for required packages to build puppet, ruby, etc.
7. Install Puppet via yaourt: ``yaourt -S puppet ruby-augeas``
8. If you're using r10k to manage puppet modules, ``yaourt -S ruby-r10k``
