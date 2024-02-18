{
    description = "Home Manager configuration of neg";
    inputs = {
        chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
        executor.url = "github:neg-serg/executor";
        home-manager = { url = "github:nix-community/home-manager"; inputs.nixpkgs.follows = "nixpkgs"; };
        negwm.url = "github:neg-serg/negwm";
        nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.05";
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        sops-nix.url = "github:Mic92/sops-nix";
        stylix.url = "github:danth/stylix";
        # nixos-generators = { url = "github:nix-community/nixos-generators"; inputs.nixpkgs.follows = "nixpkgs"; };
        # nixpkgs-wayland = { url = "github:colemickens/nixpkgs-wayland"; flake = false; };
        # nvfetcher= {url = "github:berberman/nvfetcher"; inputs.nixpkgs.follows = "nixpkgs"; };
        # schizofox = { url = "github:schizofox/schizofox"; inputs.nixpkgs.follows = "nixpkgs"; };
        # simple-osd-daemons.url = "github:balsoft/simple-osd-daemons";
    };

    outputs = { nixpkgs
        , chaotic
        , executor
        , home-manager
        , negwm
        , nixpkgs-stable
        , sops-nix
        , stylix
        # , nixos-generators
        # , nixpkgs-wayland
        # , nvfetcher
        # , schizofox
        # , simple-osd-daemons
        , ... }:
    with rec {
        system = "x86_64-linux";
        pkgs = nixpkgs.legacyPackages.${system};
        stable = nixpkgs-stable.legacyPackages.${system};
        negwmPkg = negwm.packages.${system};
        executorPkg = executor.packages.${system};
    }; {
        packages.${system}.default = nixpkgs.legacyPackages.${system}.zsh;
        homeConfigurations."neg" = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            extraSpecialArgs = {
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
