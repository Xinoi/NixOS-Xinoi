#!/bin/bash 

# This will create a UEFI NixOS install with my configuration

set -eo pipefail

DEVICE=0
PROFILE=1 
devices=()
profiles=("amdfull" "lite" "server")

function partition {
  echo "you chose ${profiles[$PROFILE - 1]} with device: $DEVICE"

  echo "WARNING: this will erase all data from $DEVICE."
  read -p "are you sure? (y/n): " CONFIRM_PART
  if [[ "$CONFIRM_PART" != "y" && "$CONFIRM_PART" != "Y" ]]; then 
    echo "aborting"
    exit  
  fi 

  #Partitioning
  echo "creating partition table..."
  parted /dev/"$DEVICE" -- mklabel gpt
  
  echo "partitioning drive..."
  parted /dev/"$DEVICE" -- mkpart root ext4 1GB -8GB > /dev/null 2>&1
  parted /dev/"$DEVICE" -- mkpart swap linux-swap -8GB 100% > /dev/null 2>&1
  parted /dev/"$DEVICE" -- mkpart ESP fat32 1MB 512MB > /dev/null 2>&1
  parted /dev/"$DEVICE" -- set 3 esp on > /dev/null 2>&1
  
  ROOT_PART=$(lsblk -ln -o NAME /dev/"$DEVICE" | grep -E "${DEVICE}(p)?1$")
  SWAP_PART=$(lsblk -ln -o NAME /dev/"$DEVICE" | grep -E "${DEVICE}(p)?2$")
  BOOT_PART=$(lsblk -ln -o NAME /dev/"$DEVICE" | grep -E "${DEVICE}(p)?3$")
  
  if [ -z "$ROOT_PART" ] || [ -z "$SWAP_PART" ] || [ -z "$BOOT_PART" ]; then 
    echo "Error: no Partitions found. Aborting!"
    exit 1
  fi
  echo "$ROOT_PART $SWAP_PART $BOOT_PART"

  #Formating
  echo "formating drive..."
  mkfs.ext4 -L nixos /dev/$ROOT_PART
  mkswap -L swap /dev/$SWAP_PART
  mkfs.fat -F 32 -n boot /dev/$BOOT_PART

  # Mount partitions 
  echo "mounting..."
  mount /dev/"$ROOT_PART" /mnt
  mkdir -p /mnt/boot
  mount -o umask=077 /dev/"$BOOT_PART" /mnt/boot
  swapon /dev/"$SWAP_PART"
  
  echo "finished formating. Please check if everything looks fine:"
  echo "Root:"
  df -h /mnt
  echo "Boot:"
  df -h /mnt/boot
  echo "Swap:"
  swapon --show
}

function install {
  echo "generating hardware configuration"
  nixos-generate-config --force --root /mnt
  echo "copy hardware-config.nix from /mnt/etc/nixos"
  mv /mnt/etc/nixos/hardware-configuration.nix ./hardware-configuration.nix
  git add .
  
  echo "Now installing NixOS!"
  
  if [ "$PROFILE" -eq "1" ]; then 
      nixos-install --flake .#${profiles[$PROFILE - 1]} > install.log
  elif [ "$PROFILE" -eq "2" ]; then 
    nixos-install --flake .#${profiles[$PROFILE - 1]} > install.log
  elif [ "$PROFILE" -eq "3" ];then 
    nixos-install --flake .#${profiles[$PROFILE - 1]} > install.log
  else
    echo "no configuration, aborting"
    exit 1
  fi

  if [ $? -eq 0 ]; then 
    echo "NixOS installation successfull."
  else 
    echo "NixOS istallation failed! Check log file."
    umount -R /mnt 
    swapoff -a
    exit 1
  fi

  # copy repo
  echo "Copying repository into installed system..."
  TARGET_HOME="/mnt/home/$(ls /mnt/home | head -n 1)"  # grab the first home user (usually the one created in flake)
  REPO_NAME="NixOS-Xinoi"

  if [ -d "$TARGET_HOME" ]; then
    mkdir -p "$TARGET_HOME/$REPO_NAME"
    cp -r . "$TARGET_HOME/$REPO_NAME"
    chown -R 1000:100 "$TARGET_HOME/$REPO_NAME" 2>/dev/null || true
    echo "Repository copied to $TARGET_HOME/$REPO_NAME"
  else
    echo "Warning: could not find user home. Copying to /mnt/root instead."
    mkdir -p /mnt/root/$REPO_NAME
    cp -r . /mnt/root/$REPO_NAME
  fi

  echo "If everything worked you can now reboot! Good Luck :)" 
}

# check if sudo rights
echo "Welcome to my NixOs Installer!"
if [ ! "$EUID" -eq 0 ]; then 
  echo "Please run the script with elevated Privileges!"
  exit 1
fi

#choose disk
counter=1
echo "Please choose the disk to install to, make sure its big enough!"
while read -r name size; do 
  echo "$counter. $name: $size"
  devices+=("$name")
  ((counter++))
done < <(lsblk -dn -o NAME,SIZE)
read -p "device: " selection
if [[ $selection -le $((counter-1)) && $selection -ge 1 ]]; then 
  DEVICE=${devices[$selection - 1]}
else 
  echo "ERROR: no such device!"
  exit 1
fi

#choose profile
echo -e "please choose a profile(default -> amdfull)" 
for ((i=0; i < ${#profiles[@]}; i++)); do 
  echo "$(($i + 1)). ${profiles[$i]}"
done
read -p "profile: " profile
if [ ! "$profile" -gt "${#profiles[@]}" ]; then 
  PROFILE="$profile"
else 
  echo "ERROR: no such profile!"
  exit 1
fi

partition
read -p "Continue with Installation? (y/n)" CONFIRM_INST
if [[ "$CONFIRM_INST" != "y" && "$CONFIRM_INST" != "Y" ]]; then
  echo "aborting!"
  exit
fi
install

exit
