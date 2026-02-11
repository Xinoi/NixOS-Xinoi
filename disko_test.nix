{
  disko.devices = {
    disk = {
      myDisk = {
        # CHANGE
        device = "/dev/vda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "512MiB";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              size = "90%";
              content = {
                type = "filesystem";
                format = "btrfs";
                mountpoint = "/";
                subvolumes = {
                  "@": {};
                  "@home": {};
                  "@nix": {};
                };
                options = "compress=zstd:3,ssd,discard=async";
              };
            };
            swap = {
              size = "8GiB";
              content = {
                type = "swap";
              };
            };
          };
        };
      };
    };
  };
}
