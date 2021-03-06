Preflight
=========

Arch Linux Full Configuration

Inspired by: https://github.com/NoviceLive/unish/blob/master/doc/v2-arch-install.rst

Installation Instructions
-------------------------

Prepare an Arch USB Stick, then begin.


Securely Erase Disks
++++++++++++++++++++

- Identify block devices with ``lsblk``.

  ::

     lsblk

- Wipe disks.

  Suppose that we are going to install Arch on ``/dev/sdX``,
  and the boot partition (USB Header) on ``/dev/sdY``.
  We'll want to wipe them to prevent unintended data recovery,
  as suggested by `dm-crypt/Drive preparation`_.

  Note that this might consume several hours.
  See ``shred --help`` for more details.
    ::

       cryptsetup --key-file /dev/random open --type plain /dev/sdX one
       dd if=/dev/zero of=/dev/mapper/one
       cryptsetup close one

       cryptsetup --key-file /dev/random open --type plain /dev/sdY two
       dd if=/dev/zero of=/dev/mapper/two
       cryptsetup close two


Perform Some Boring Routines
++++++++++++++++++++++++++++

See the `Installation guide`_ or `Beginners' guide`_
for more details.

- Check the UEFI mode.

  ::

     ls /sys/firmware/efi/efivars

- Load necessary key maps and set console fonts if needed.

  ::

     # loadkeys skipped
     # setfont skipped

- Check or configure the network.

  ::

     # network configuration skipped

     # You may want to ping google.com instead.
     ping -c4 google.com

- Update the system clock.

  ::

     timedatectl status
     timedatectl set-ntp true
     timedatectl status


Prepare Partitions a.k.a Interesting Part I
+++++++++++++++++++++++++++++++++++++++++++

Choose algorithms
*****************

Running benckmarks may help you choose the algorithms.

Also, see `Encryption options for LUKS mode`_
and `Ciphers and modes of operation`_ for more information.

I will take ``serpent-xts-plain64`` and ``whirlpool`` for example.

Tips
@@@@

``serpent-xts-plain64`` reads that
the encryption algorithm is `serpent`_,
other candidates being `twofish`_ and `aes`_,
the `chain mode`_ is `xts`_,
and the `intialization vector`_ generator is plain64.

::

   cryptsetup benchmark

An example output.

::

   PBKDF2-sha1       439838 iterations per second for 256-bit key
   PBKDF2-sha256     571742 iterations per second for 256-bit key
   PBKDF2-sha512     385505 iterations per second for 256-bit key
   PBKDF2-ripemd160  263726 iterations per second for 256-bit key
   PBKDF2-whirlpool  177845 iterations per second for 256-bit key
   #  Algorithm | Key |  Encryption |  Decryption
        aes-cbc   128b   342.3 MiB/s  1650.5 MiB/s
    serpent-cbc   128b    56.6 MiB/s   225.1 MiB/s
    twofish-cbc   128b   139.1 MiB/s   266.4 MiB/s
        aes-cbc   256b   336.1 MiB/s  1237.0 MiB/s
    serpent-cbc   256b    65.1 MiB/s   225.8 MiB/s
    twofish-cbc   256b   140.7 MiB/s   266.3 MiB/s
        aes-xts   256b  1356.6 MiB/s  1360.4 MiB/s
    serpent-xts   256b   225.0 MiB/s   221.4 MiB/s
    twofish-xts   256b   258.8 MiB/s   261.8 MiB/s
        aes-xts   512b  1056.4 MiB/s  1066.3 MiB/s
    serpent-xts   512b   232.8 MiB/s   221.4 MiB/s
    twofish-xts   512b   260.0 MiB/s   261.6 MiB/s


Prepare Root
************

Tips
@@@@

**There is no need to partition the root disk**.

- Setup LUKS using a remote header.

  ::

     truncate -s 2M root.header

     cryptsetup --header root.header \
     --cipher serpent-xts-plain64 --key-size 512 \
     --hash whirlpool --iter-time 5000 --use-random \
     luksFormat /dev/sdX

     cryptsetup --header root.header open /dev/sdX root

- Setup LVM in the encrypted container.

  Note that you will want to make necessary adaptation.

  ::

     pvcreate /dev/mapper/root
     vgcreate vga /dev/mapper/root
     lvcreate -n swap -L 4G vga
     lvcreate -n root -L 96G vga
     lvcreate -n home -l 100%FREE vga

- Create the swap and file systems.

  ::

     mkswap /dev/vga/swap
     mkfs.ext4 /dev/vga/root
     mkfs.ext4 /dev/vga/home


Prepare Boot
************

Prepare partition and setup LUKS.

Feel free to use your own preferences.

In the following example, ``/boot/efi`` will get 56 MiB,
and ``/boot`` 200 MiB.

::

   lsblk
   parted /dev/sdY
   (parted) p
   (parted) mktable gpt
   (parted) p
   (parted) mkpart primary 1MiB 57MiB
   (parted) p
   (parted) set 1 boot on
   (parted) p
   (parted) mkpart primary 58MiB 258MiB
   (parted) p
   (parted) q

   cryptsetup --cipher serpent-xts-plain64 --key-size 512 \
   --hash whirlpool --iter-time 5000 --use-random \
   luksFormat /dev/sdY2
   cryptsetup open /dev/sdY2 boot
   mkfs.fat -F32 /dev/sdY1
   mkfs.ext4 /dev/mapper/boot

Activate The Swap And Mount File Systems
****************************************

Also, move the header into boot,
we will configure ``mkinitcpio`` to copy the header into the initramfs.

::

   swapon /dev/vga/swap
   mount /dev/vga/root /mnt
   mkdir /mnt/{home,boot}
   mount /dev/vga/home /mnt/home
   mount /dev/mapper/boot /mnt/boot
   mkdir /mnt/boot/efi
   mount /dev/sdY1 /mnt/boot/efi

   mv root.header /mnt/boot


Follow Some More Boring Routines
++++++++++++++++++++++++++++++++

Perform System Installation
***************************

- Install the base system.

  ::

     pacstrap -i /mnt base base-devel zsh grml-zsh-config

- Generate ``fstab`` and check it.

  ::

     genfstab -U /mnt >> /mnt/etc/fstab
     nano /mnt/etc/fstab

- Change root.

  ::

     arch-chroot /mnt /bin/zsh


Configure Some Boring Stuff For The Freshly Installed System
************************************************************

- Choose locales and generate them and
  set the locale, which shall be the first chosen entry and
  in my case, it's the following: ``LANG=en_US.UTF-8``.

  ::

     nano /etc/loacle.gen
     locale-gen

     nano /etc/locale.conf

- Configure ``/etc/vconsole.conf`` if necessary.

  ::

     # /etc/vconsole.conf configuration skipped

- Select and set the time zone.

  ::

     tzselect
     ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

- Set or update the hardware clock.

  ::

     hwclock --systohc --utc

- Again, check or configure the network.

  ::

     # network configuraion skipped
     # I will simply use ``systemctl enable dhcpcd@enp4s0f2``

     # You may want to ping google.com instead.
     ping -c4 google.com


- Set the hostname and add it to ``/etc/hosts``.

  ::

     nano /etc/hostname
     nano /etc/hosts


Configure For Disk-Encryption a.k.a Interesting Part II
+++++++++++++++++++++++++++++++++++++++++++++++++++++++

Configure The Kernel
********************

- Edit ``/etc/fstab``.

  Add ``noauto`` to options of ``/boot`` and ``/boot/efi``
  so as to unplug the pendrive after loading the kernel.

  We will need to mount it when there are kernel updates or
  we want to regenerate the initramfs.

- Create ``/etc/crypttab.initramfs``

  In our example, add the following line.

  - **Tips**

    It's strongly recommended to use persistent device naming,
    e.g., using ``/dev/disk/by-id/``, e.g.,
    ``anon /dev/disk/by-id/ata-HGST_HTS721010A9E630_JR10006PH244KE /boot/keyfile header=/boot/header``.

  ::

     vga /dev/sdX none header=/boot/root.header

- Edit ``/etc/mkinitcpio.conf``

  Add the header to ``FILES``.

  ::

     FILES="/boot/root.header"

  As a result, the header will be copied into the initramfs.

  As for ``HOOKS``, replace ``udev`` with ``systemd``,
  and add ``sd-encrypt`` and ``sd-lvm2``
  between ``block`` and ``filesystems``.

  In my example, it reads.

  ::

     HOOKS="base systemd autodetect modconf block sd-encrypt sd-lvm2 filesystems keyboard fsck"

- Regenerate initramfs.

  ::

     mkinitcpio -p linux


Configure The Bootloader
************************

- Install GRUB and efibootmgr.

  ::

     pacman -S grub efibootmgr

  For Intel CPU, it's advised to install ``intel-ucode``.

  ::

     pacman -S intel-ucode

  The following packages are also suggested to be installed,
  if not previously installed,
  at this stage for systems mainly depending on Wi-Fi.

  ::

     pacman -S dialog wpa_supplicant


- Edit ``/etc/default/grub``.

  Add the line,
  ``GRUB_ENABLE_CRYPTODISK=y``,
  and add necessary kernel parameters.

  - **Tips**

    It's strongly recommended to use persistent device naming,
    e.g., using ``/dev/disk/by-id/``, e.g.,
    ``/dev/disk/by-id/ata-HGST_HTS721010A9E630_JR10006PH244KE``
    .

  In this example, it looks like the following.

  ::

     GRUB_CMDLINE_LINUX_DEFAULT="cryptdevice=/dev/sdX:root:header"

  Note that ``root`` is the mapped name of our encrypted container.

  Also, I removed the ``quiet`` parameter.

- Generate ``grub.cfg``.

  ::

     grub-mkconfig -o /boot/grub/grub.cfg

- Install GRUB to the pendrive.

  Notice: Don't forget ``--removable``.

  ::

     grub-install --target=x86_64-efi --efi-directory=/boot/efi --recheck --removable


Perform Some Most Boring Post Installation Tasks
++++++++++++++++++++++++++++++++++++++++++++++++

Configure users
***************

- Set the root password.

  ::

     passwd


Cleanup And Reboot
******************

Exit chroot, do some cleanup and reboot.

::

   exit

   umount -R /mnt
   swapoff /dev/vga/swap

   vgchange -an vga

   cryptsetup close root
   cryptsetup close boot

   reboot


Bootstrap with Preflight
++++++++++++++++++++++++

Run Preflight

::
  git clone https://github.com/seanherron/preflight.git ~/.preflight
  cd ~/.preflight
  sudo ./preflight.sh
