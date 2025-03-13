{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "yourname";
    userEmail = "your.email@example.com";
    extraConfig = {
      init.defaultBranch = "main";
      # その他のGit設定
    };
  };
}