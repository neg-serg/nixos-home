{
    description = "Home Manager configuration of neg";
    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.05";
        chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
        nixpkgs-wayland = { url = "github:colemickens/nixpkgs-wayland"; flake = false; };
        simple-osd-daemons.url = "github:balsoft/simple-osd-daemons";
        schizofox = { url = "github:schizofox/schizofox"; inputs.nixpkgs.follows = "nixpkgs"; };
        home-manager = { url = "github:nix-community/home-manager"; inputs.nixpkgs.follows = "nixpkgs"; };
        negwm.url = "github:neg-serg/negwm";
        stylix.url = "github:danth/stylix";
    };

    outputs = { nixpkgs
        , chaotic
        , home-manager
        , nixpkgs-wayland
        , nixpkgs-stable
        , simple-osd-daemons
        , negwm
        , stylix
        , ... } @inputs:
    with rec {
        system = "x86_64-linux";
        pkgs = nixpkgs.legacyPackages.${system};
        stable = nixpkgs-stable.legacyPackages.${system};
        negwmPkg = negwm.packages.${system};
    }; {
        packages.${system}.default = nixpkgs.legacyPackages.${system}.zsh;
        homeConfigurations."neg" = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            extraSpecialArgs = {
                inherit stable;
                inherit negwmPkg;
            };
            modules = [
                ./home.nix
                chaotic.homeManagerModules.default # OUR DEFAULT MODULE
                stylix.homeManagerModules.stylix ./home.nix
            ];
        };
    };
}
