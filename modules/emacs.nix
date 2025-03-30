{pkgs, ...}:

{

  services.emacs = {
    enable = true;
    package = pkgs.emacs;
    defaultEditor = true;
  };
    
  environment.systemPackages = with pkgs; [
    emacs
    isync
    pass
    pyright
    clang-tools
    rust-analyzer
    lua-language-server
    nil
    texlab
    shellcheck
    nixfmt-classic
  ];
}
