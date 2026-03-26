{ ... }:
{
  disko.devices = {
    disk = {
      usb = {
        type   = "disk";
        device = "/dev/CHANGEME"; # e.g. /dev/sda — your USB stick
        content = {
          type = "gpt";
          partitions = {

            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type         = "filesystem";
                format       = "vfat";
                mountpoint   = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };

            root = {
              size = "100%";
              content = {
                type         = "filesystem";
                format       = "ext4";
                mountpoint   = "/";
                # noatime + nodiratime: skip access-time writes — critical for flash longevity
                mountOptions = [ "noatime" "nodiratime" ];
              };
            };

          };
        };
      };
    };
  };
}
