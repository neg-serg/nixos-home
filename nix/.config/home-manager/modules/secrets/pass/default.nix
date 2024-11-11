{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    keepass # password manager with strong cryptography
    # password manager via gpg
    (pass.withExtensions (ext:
      with ext; [
        pass-audit # extension for auditing your password repository
        pass-otp # one time passwords integration
        pass-tomb # encrypt all password tree inside a tomb
      ]))
  ];
}
