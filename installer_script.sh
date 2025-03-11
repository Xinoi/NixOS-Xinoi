#!/bin/bash 

# This will create a UEFI NixOS install with my configuration

DEVICE=0
PROFILE=1 
devices=()
profiles=("amdfull")

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
  parted /dev/"$DEVICE" -- mkpart root ext4 512MB -8GB
  parted /dev/"$DEVICE" -- mkpart swap linux-swap -8GB 100%
  parted /dev/"$DEVICE" -- mkpart ESP fat32 1MB 512MB 
  parted /dev/"$DEVICE" -- set 3 esp on
  
  ROOT_PART=$(lsblk -ln -o NAME /dev/"$DEVICE" | grep -E "${DEVICE}[^[:space:]]+1$")
  SWAP_PART=$(lsblk -ln -o NAME /dev/"$DEVICE" | grep -E "${DEVICE}[^[:space:]]+2$")
  BOOT_PART=$(lsblk -ln -o NAME /dev/"$DEVICE" | grep -E "${DEVICE}[^[:space:]]+3$")

  #Formating
  echo "formating drive..."
  mkfs.ext4 -L nixos /dev/"$ROOT_PART"
  mkswap -L swap /dev/"$SWAP_PART"
  mkfs.fat -F 32 -n boot /dev/"$BOOT_PART"

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
  nixos-generate-config --show-hardware-config > hardware-config.nix
  
  echo "Now installing NixOS!"
  nixos-install --flake .#${profiles[$PROFILE - 1]} --option 'extra-substituters' 'https://chaotic-nyx.cachix.org/' --option extra-trusted-public-keys "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12 WfF+Gqk6SonIT8=" | tee install.log

  echo "Enter password for User:"
  nixos-enter --root /mnt -c 'passwd xinoi'

  echo "If everything worked you can now reboot! Good Luck :)" 
}

# check if sudo rights
echo "Welcome to my NixOs Installer!"
if [ ! "$EUID" -eq 0 ]; then 
  echo "Please run the script with elevated Privileges!"
  exit
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
if [[ $selection -le $((counter-1)) && $selection -ge 1 ]] ; then 
  DEVICE=${devices[$selection - 1]}
else 
  echo "ERROR: no such device!"
  exit
fi

#choose profile
echo -e "please choose a profile(default -> amdfull)" 
for ((i=0; i < ${#profiles[@]}; i++)); do 
  echo "$(($p + 1)). ${profiles[$p]}"
done
read -p "profile: " profile
if [ "$profile" = "1" ]; then 
  PROFILE=1 
elif [ "$profile" = "" ]; then 
  PROFILE=1 
else 
  echo "ERROR: no such profile!"
  exit
fi

partition
read -p "Continue with Installation? (y/n)" CONFIRM_INST
if [[ "$CONFIRM_INST" != "y" && "$CONFIRM_INST" != "Y" ]]; then
  echo "aborting!"
  exit
fi
install

exit
