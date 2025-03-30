{pkgs, ...}:

{
  environment.systemPackages = with pkgs; [
    pyright
    clang-tools
    rust-analyzer
    lua-language-server
    nil
    texlab
  ];
}
