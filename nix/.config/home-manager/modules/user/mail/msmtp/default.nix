{...}: {
  programs.msmtp.enable = true;
  accounts.email.accounts."gmail".msmtp.enable = true;
}
