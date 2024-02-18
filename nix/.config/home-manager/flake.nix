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
        executor.url = "github:neg-serg/executor";
        stylix.url = "github:danth/stylix";
        sops-nix.url = "github:Mic92/sops-nix";
        nixos-generators = { url = "github:nix-community/nixos-generators"; inputs.nixpkgs.follows = "nixpkgs"; };
        nvfetcher= {url = "github:berberman/nvfetcher"; inputs.nixpkgs.follows = "nixpkgs"; };
    };

    outputs = { nixpkgs
        , chaotic
        , home-manager
        , nixpkgs-wayland
        , nixpkgs-stable
        , simple-osd-daemons
        , negwm
        , executor
        , stylix
        , sops-nix
        , nixos-generators
        , nvfetcher
        , ... } @inputs:
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
