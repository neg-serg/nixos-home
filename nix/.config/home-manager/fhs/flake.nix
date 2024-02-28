{
  inputs.nixpkgs.url = "github:nixos/nixpkgs";
  outputs = { self, nixpkgs }: {
    devShells.x86_64-linux.default = with nixpkgs.legacyPackages.x86_64-linux;
      (buildFHSEnv { name = "foo"; targetPkgs = pkgs: with pkgs; [hello]; }).env;
  };
}
