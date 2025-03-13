{ config, pkgs, lib, username, ... }:

{
  imports = [
    ./git.nix
    ./shell.nix
    # 他のホームマネージャーモジュール
  ];

  home.packages = with pkgs; [
    ripgrep
    fd
    jq
    gh
    # その他のユーザー固有のパッケージ
  ];

  home.stateVersion = "23.11";
}