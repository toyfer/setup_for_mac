{ config, pkgs, lib, hostname, username, ... }:

{
  imports = [
    ./homebrew.nix
    ./system-defaults.nix
  ];
  
  # 基本的なシステム設定
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
  ];

  nix.settings.experimental-features = "nix-command flakes";
  nix.extraOptions = ''
    extra-platforms = x86_64-darwin aarch64-darwin
  '';
  
  system.configurationRevision = lib.mkIf (lib.hasAttr "rev" pkgs.stdenv) pkgs.stdenv.rev;
  system.stateVersion = 5;
}