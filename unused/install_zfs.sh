#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

function yesno() {
    local prompt="$1"

    while true; do
        read -rp "$prompt [y/n] " yn
        case $yn in
            [Yy]* ) echo "y"; return;;
            [Nn]* ) echo "n"; return;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

cat << Introduction
The *entire* disk will be formatted with a 1GB boot partition
(labelled NIXBOOT), and the rest allocated to ZFS.

The following ZFS datasets will be created:
    - zroot/root (mounted at / with blank snapshot)
    - zroot/nix (mounted at /nix)
    - zroot/tmp (mounted at /tmp)
    - zroot/persist (mounted at /persist)
    - zroot/cache (mounted at /cache)

** IMPORTANT **
This script assumes that the relevant "fileSystems" are declared within the
NixOS config to be installed. It does not create any hardware configuration
or modify the NixOS config to be installed in any way. If you have not done
so, you will need to add the necessary zfs options and filesystems before
proceeding or your install WILL NOT BOOT.

Introduction

# in a vm, special case
if [[ -b "/dev/vda" ]]; then
    DISK="/dev/vda"
else
    # listing with the standard lsblk to help with viewing partitions
    lsblk

    # Get the list of disks
    mapfile -t disks < <(lsblk -ndo NAME,SIZE,MODEL)

    echo -e "\nAvailable disks:\n"
    for i in "${!disks[@]}"; do
        printf "%d) %s\n" $((i+1)) "${disks[i]}"
    done

    # Get user selection
    while true; do
        echo ""
        read -rp "Enter the number of the disk to install to: " selection
        if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le ${#disks[@]} ]; then
            break
        else
            echo "Invalid selection. Please try again."
        fi
    done

    # Get the selected disk
    DISK="/dev/$(echo "${disks[$selection-1]}" | awk '{print $1}')"
fi

# if disk contains "nvme", append "p" to partitions
if [[ "$DISK" =~ "nvme" ]]; then
    BOOTDISK="${DISK}p2"
    ZFSDISK="${DISK}p1"
else
    BOOTDISK="${DISK}2"
    ZFSDISK="${DISK}1"
fi

echo "Boot Partiton: $BOOTDISK"
echo "ZFS Partiton: $ZFSDISK"

echo ""
do_format=$(yesno "This irreversibly formats the entire disk. Are you sure?")
if [[ $do_format == "n" ]]; then
    exit
fi

echo "Creating partitions"
sudo blkdiscard -f "$DISK"
sudo sgdisk --clear"$DISK"

sudo sgdisk -n2:1M:+1G -t2:EF00 "$DISK"
sudo sgdisk -n1:0:0 -t1:BF01 "$DISK"

# notify kernel of partition changes
sudo sgdisk -p "$DISK" > /dev/null
sleep 5

echo "Creating Boot Disk"
sudo mkfs.fat -F 32 "$BOOTDISK" -n NIXBOOT

# setup encryption
use_encryption=$(yesno "Use encryption? (Encryption must also be enabled within host config.)")
if [[ $use_encryption == "y" ]]; then
    encryption_options=(-O encryption=aes-256-gcm -O keyformat=passphrase -O keylocation=prompt)
else
    encryption_options=()
fi

echo "Creating base zpool"
sudo zpool create -f \
    -o ashift=12 \
    -o autotrim=on \
    -O compression=zstd \
    -O acltype=posixacl \
    -O atime=off \
    -O xattr=sa \
    -O normalization=formD \
    -O mountpoint=none \
    "${encryption_options[@]}" \
    zroot "$ZFSDISK"

echo "Creating /"
sudo zfs create -o mountpoint=legacy zroot/root
sudo zfs snapshot zroot/root@blank
sudo mount -t zfs zroot/root /mnt

# create the boot parition after creating root
echo "Mounting /boot (efi)"
sudo mount --mkdir "$BOOTDISK" /mnt/boot

echo "Creating /nix"
sudo zfs create -o mountpoint=legacy zroot/nix
sudo mount --mkdir -t zfs zroot/nix /mnt/nix

echo "Creating /tmp"
sudo zfs create -o mountpoint=legacy zroot/tmp
sudo mount --mkdir -t zfs zroot/tmp /mnt/tmp

echo "Creating /cache"
sudo zfs create -o mountpoint=legacy zroot/cache
sudo mount --mkdir -t zfs zroot/cache /mnt/cache

# handle persist, possibly from snapshot
restore_snapshot=$(yesno "Do you want to restore from a persist snapshot?")
if [[ $restore_snapshot == "y" ]]; then
    echo "Enter full path to snapshot: "
    read -r snapshot_file_path
    echo

    echo "Creating /persist"
    # disable shellcheck (sudo doesn't affect redirects)
    # shellcheck disable=SC2024
    sudo zfs receive -o mountpoint=legacy zroot/persist < "$snapshot_file_path"

else
    echo "Creating /persist"
    sudo zfs create -o mountpoint=legacy zroot/persist
fi
sudo mount --mkdir -t zfs zroot/persist /mnt/persist


# Get repo to install from
read -rp "Enter flake URL (default: github:Sumelan/wolborg): " repo
repo="${repo:-github:Sumelan/wolborg}"

# wolborg
if [[ $repo == "github:Sumelan/wolborg" ]]; then
    hosts=("acer" "sakura")

    echo "Available hosts:"
    for i in "${!hosts[@]}"; do
        printf "%d) %s\n" $((i+1)) "${hosts[i]}"
    done

    while true; do
        echo ""
        read -rp "Enter the number of the host to install: " selection
        if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le ${#hosts[@]} ]; then
            host="${hosts[$selection-1]}"
            break
        else
            echo "Invalid selection. Please enter a number between 1 and ${#hosts[@]}."
        fi
    done
else
    read -rp "Which host to install?" host
fi

read -rp "Enter git rev for flake (default: main): " git_rev

echo "Installing NixOS"
if [[ $repo == "github:Sumelan/wolborg" ]]; then
    # root password is irrelevant if initialPassword is set in the config
    sudo nixos-install --no-root-password --flake "$repo/${git_rev:-main}#$host" --option tarball-ttl 0
else
    sudo nixos-install --flake "$repo/${git_rev:-main}#$host" --option tarball-ttl 0
fi

echo "Installation complete. It is now safe to reboot."
