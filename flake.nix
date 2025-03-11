{
	description = "mac configuration";

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

	outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, homebrew-core, homebrew-cask, home-manager }:

	let
		configuration = { pkgs, ... }: {
			environment.systemPackages = with pkgs; [
				gh
			];

			nix-homebrew = {
				enable = true;
				enableRosetta = true;
				user = "user";

				taps = {
					"homebrew/homebrew-core" = inputs.homebrew-core;
					"homebrew/homebrew-cask" = inputs.homebrew-cask;
				};
			};

			homebrew = {
				enable = true;
				onActivation.cleanup = "uninstall";
				taps = [];
				brews = [];
				casks = [ "firefox" "discord" ]; # casks (複数形) に修正
			};

			# services.nix-daemon.enable = true; # 削除: 不要になった設定

			nix.settings.experimental-features = "nix-command flakes";

			nix.extraOptions = ''
				extra-platforms = x86_64-darwin aarch64-darwin
			'';

			system.configurationRevision = self.rev or self.dirtyRev or null;

			system.stateVersion = 5;

			nixpkgs.hostPlatform = "aarch64-darwin";

			system.defaults = {
				finder.AppleShowAllExtensions = true;
				finder.FXPreferredViewStyle = "clmv";

				dock = {
					autohide = true;
					mru-spaces = false;
					persistent-apps = [
						"/Applications/Safari.app"
					];
				};
			};
		};
	in
	{
		darwinConfigurations."MacminiM4" = nix-darwin.lib.darwinSystem {
			modules = [
				nix-homebrew.darwinModules.nix-homebrew
				configuration
			];
		};

		darwinPackages = self.darwinConfigurations."MacminiM4".pkgs;
	};

}
