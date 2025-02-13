{
  nixpkgs.overlays = [
    (self: super: {
      SDL2 = super.SDL2.overrideAttrs (oldAttrs: {
        udevSupport = true;
      });
    })
  ];
}
