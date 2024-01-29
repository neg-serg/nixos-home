{ pkgs, ... }: {
    home.packages = with pkgs; [
        yubikey-manager # yubikey manager cli
    ];
}
