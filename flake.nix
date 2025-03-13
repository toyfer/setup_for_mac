{
  description = "macOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    nix-darwin.url = "github:lnl7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, nix-homebrew, ... }:
    let
      lib = import ./lib { inherit inputs; };
    in {
      darwinConfigurations."MacminiM4" = lib.mkDarwinSystem {
        hostname = "MacminiM4";
        system = "aarch64-darwin";
        username = "user"; # あなたのユーザー名
      };

      # 他のホスト設定があれば追加可能
      # darwinConfigurations."MacBook" = ...

      # 開発用のシェル設定（オプション）
      devShells = lib.forAllSystems (system: {
        default = import ./lib/devshell.nix { pkgs = nixpkgs.legacyPackages.${system}; };
      });
    };
}