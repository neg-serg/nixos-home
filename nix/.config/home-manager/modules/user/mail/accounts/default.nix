{...}: {
  accounts.email.accounts."gmail" = {
    passwordCommand = "pass show google";
    userName = "serg.zorg@gmail.com";
    realName = "Sergey Miroshnichenko";
    address = "serg.zorg@gmail.com";
    primary = true;
    imap = {
      host = "imap.gmail.com";
      port = 993;
      tls.enable = true;
    };
    smtp = {
      port = 587;
      tls.enable = true;
      host = "smtp.gmail.com";
    };
  };
}
