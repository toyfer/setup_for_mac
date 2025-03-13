{ config, lib, ... }:

{
  system.defaults = {
    finder = {
      AppleShowAllExtensions = true;
      FXPreferredViewStyle = "clmv";
    };
    
    NSGlobalDomain = {
      AppleKeyboardUIMode = 3;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
    };

    dock = {
      autohide = true;
      mru-spaces = false;
      persistent-apps = [
        "/Applications/Safari.app"
      ];
    };
    
    # その他のシステム設定
  };
}