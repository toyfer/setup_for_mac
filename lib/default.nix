{ inputs }:

let
  inherit (inputs) nixpkgs nix-darwin home-manager nix-homebrew;
in rec {
  # システム（アーキテクチャ）ごとの関数を生成
  forAllSystems = nixpkgs.lib.genAttrs [ "aarch64-darwin" "x86_64-darwin" ];

  # Darwinシステムのビルド関数
  mkDarwinSystem = { hostname, system, username }: nix-darwin.lib.darwinSystem {
    inherit system;
    specialArgs = {
      inherit inputs hostname username system;
    };
    modules = [
      # モジュールをインポート
      ../modules/darwin
      home-manager.darwinModules.home-manager
      {
        # ホスト固有の設定をインポート
        imports = [ ../hosts/${hostname} ];
        nixpkgs.hostPlatform = system;
        users.users.${username}.home = "/Users/${username}";
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.${username} = import ../modules/home;
          extraSpecialArgs = {
            inherit username hostname;
          };
        };
      }
      # nix-homebrewモジュール
      nix-homebrew.darwinModules.nix-homebrew
    ];
  };
}