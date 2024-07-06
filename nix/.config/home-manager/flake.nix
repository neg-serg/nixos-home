{
  description = "Home Manager configuration of neg";
  inputs = {
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-shell = {
      url = "sourcehut:~dermetfan/home-manager-shell";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    nixpkgs-oldstable.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
    stylix.url = "github:danth/stylix";

    executor.url = "github:neg-serg/executor";
    negwm.url = "github:neg-serg/negwm";

    # nixos-generators = {
    #   url = "github:nix-community/nixos-generators";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # nixpkgs-wayland = {
    #   url = "github:colemickens/nixpkgs-wayland";
    #   flake = false;
    # };
    # nvfetcher = {
    #   url = "github:berberman/nvfetcher";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # simple-osd-daemons.url = "github:balsoft/simple-osd-daemons";
  };

  outputs = inputs @ {
    nixpkgs,
    chaotic,
    executor,
    home-manager,
    negwm,
    nixpkgs-master,
    nixpkgs-oldstable,
    nixpkgs-stable,
    sops-nix,
    stylix,
    # home-manager-shell,
    # nixos-generators,
    # nixpkgs-wayland,
    # nvfetcher,
    # simple-osd-daemons,
    ...
  }:
    with rec {
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      stable = nixpkgs-stable.legacyPackages.${system};
      oldstable = nixpkgs-oldstable.legacyPackages.${system};
      master = nixpkgs-master.legacyPackages.${system};
      negwmPkg = negwm.packages.${system};
      executorPkg = executor.packages.${system};
    }; {
      packages.${system}.default = nixpkgs.legacyPackages.${system}.zsh;
      homeConfigurations."neg" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit inputs;
          inherit oldstable;
          inherit master;
          inherit stable;
          inherit negwmPkg;
          inherit executorPkg;
        };
        modules = [
          ./home.nix
          chaotic.homeManagerModules.default
          stylix.homeManagerModules.stylix
          sops-nix.homeManagerModules.sops
        ];
      };
    };
}
