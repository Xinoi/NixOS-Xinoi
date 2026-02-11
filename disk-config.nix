let
  # Define standard SSD + Btrfs optimizations once
  btrfsOpts = [ "compress=zstd:1" "noatime" "discard=async" "space_cache=v2" ];
in
{
  disko.devices = {
    disk = {
      main = {
        # TODO
        device = "/dev/[diskname]";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            swap = {
              size = "8G";
              content = {
                type = "swap";
                discardPolicy = "both";
                randomEncryption = true;
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                settings.allowDiscards = true;
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    "/" = { mountpoint = "/"; mountOptions = btrfsOpts; };
                    "/home" = { mountpoint = "/home"; mountOptions = btrfsOpts; };
                    "/nix" = { mountpoint = "/nix"; mountOptions = btrfsOpts; };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
