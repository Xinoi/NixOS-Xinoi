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
    maim
    graphviz
    pyright
    clang-tools
    rust-analyzer
    lua-language-server
    nil
    gopls
    gore
    gomodifytags
    gotests
    html-tidy
    stylelint
    texlab
    shellcheck
    nixfmt-classic
  ];
}
