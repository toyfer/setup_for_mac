{ config, pkgs, lib, ... }:

{
  # MacminiM4固有の設定
  networking.hostName = "MacminiM4";
  
  # このホストだけに適用したい特別な設定
  environment.systemPackages = with pkgs; [
    # MacminiM4に特有のパッケージ
  ];
  
  # 他のホスト固有の設定
}