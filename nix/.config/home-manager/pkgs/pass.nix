{
  pkgs,
  stable,
  ...
}: {
  home.packages = with pkgs; [
    # password manager via gpg
    (stable.pass.withExtensions (ext:
      with ext; [
        pass-audit # extension for auditing your password repository
        pass-otp # one time passwords integration
        pass-tomb # encrypt all password tree inside a tomb
      ]))
  ];
}
