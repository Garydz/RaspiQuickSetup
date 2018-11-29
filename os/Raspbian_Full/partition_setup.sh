#!/bin/sh

set -ex

if [ -z "$part1" ] || [ -z "$part2" ]; then
  printf "Error: missing environment variable part1 or part2\n" 1>&2
  exit 1
fi

mkdir -p /tmp/1 /tmp/2

mount "$part1" /tmp/1
mount "$part2" /tmp/2

sed /tmp/1/cmdline.txt -i -e "s|root=[^ ]*|root=${part2}|"
sed /tmp/2/etc/fstab -i -e "s|^.* / |${part2}  / |"
sed /tmp/2/etc/fstab -i -e "s|^.* /boot |${part1}  /boot |"

post_fix=$(date +%H%M%S)
piName=$(cat /tmp/2/etc/hostname)
sed -i "s/${piName}/Raspi${post_fix}/g" /tmp/2/etc/hostname
sed -i "s/^\(127\.\(.*\)\)[[:space:]]${piName}$/\1\tRaspi${post_fix}/g" /tmp/2/etc/hosts
if [ -d /mnt/setup/ ]; then
  cp -r /mnt/setup/ /tmp/2/home/pi/
fi
if [ -d /mnt/bin/ ]; then
  cp -r /mnt/bin/ /tmp/2/home/pi/
fi
if [ -f /mnt/setup/ref/authorized_keys ]; then
  mkdir /tmp/2/home/pi/.ssh/
  cp /mnt/setup/ref/authorized_keys /tmp/2/home/pi/.ssh/authorized_keys
fi
if [ -f /mnt/setup/ref/dhcpcd.conf ]; then
  cp /mnt/setup/ref/dhcpcd.conf /tmp/2/etc/dhcpcd.conf
fi
if [ -f /mnt/setup/ref/HDMIconfig.txt ]; then
  cp /mnt/setup/ref/HDMIconfig.txt /tmp/1/config.txt
fi

if [ -f /mnt/ssh ]; then
  cp /mnt/ssh /tmp/1/
fi

if [ -f /mnt/ssh.txt ]; then
  cp /mnt/ssh.txt /tmp/1/
fi

if [ -f /settings/wpa_supplicant.conf ]; then
  cp /settings/wpa_supplicant.conf /tmp/1/
fi

if ! grep -q resize /proc/cmdline; then
  sed -i 's| init=/usr/lib/raspi-config/init_resize.sh||;s| quiet||2g' /tmp/1/cmdline.txt
fi

umount /tmp/1
umount /tmp/2
