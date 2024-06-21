#!/bin/bash

echo "WARNINIG: Run this in a 'Live CD', not the installed Ubuntu"
read -p "Continue (yY/nN)? " choice
case "$choice" in
  y|Y)
		echo ">>> Running swap increase"
		;;
  n|N)
		echo ">>> Stopping swap increase"
		exit 0
		;;
  *)
		echo ">>> Stopping swap increase"
		exit 0
		;;
esac

# Change swap size which is only 1G after installation
#  - [Unlock volume](https://bit.ly/3eyttxj)
#  - [Shrink LVM root](https://bit.ly/2S33zKt)
#  - [Shrink LVM root volume](https://bit.ly/2S33zKt)
#  - [Working with swap](https://bit.ly/3aICkLQ)

echo ">>> Current swap size"
free -th | grep -i swap

# Scan for LVM disks
sudo lvmdiskscan

if [[ "$(sudo lvmdiskscan | grep nvme0n1p3)" != "" ]]; then
	# Lenovo ThinkPad T480
	LVM_PARTITION=/dev/nvme0n1p3
else
	# Dell XPS
	LVM_PARTITION=/dev/sda3
fi

echo ">>> Unlocking LVM partition ${LVM_PARTITION}"
# Alternatively one can unlock it manually in Disk app
sudo udisksctl unlock -b "${LVM_PARTITION}"

# List logical volumes
sudo lvs

# Activate logical volumes
sudo vgchange -ay

# Chech if the root volume is ok
sudo e2fsck -f /dev/vgubuntu/root

# Resize root by -40G and swap by +40G

# Make free space by shrinking the root volume
# WARN: Reducing active volume is dangerous!
sudo lvresize -y --resizefs -L-40G /dev/vgubuntu/root

# Add 40G to the swap volume
sudo lvresize -y -L+40G /dev/vgubuntu/swap_1

sudo lvs

# Format new swap space to make it usable
sudo mkswap /dev/vgubuntu/swap_1

# Turn the swap volume back on
sudo swapon /dev/vgubuntu/swap_1

echo ">>> New swap size"
free -th | grep -i swap
