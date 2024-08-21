{...}: {
  services.imapnotify.enable = true;
  accounts.email.accounts."gmail" = {
    passwordCommand = "pass show google|wc -1";
    userName = "serg.zorg@gmail.com";
    primary = true;
    imap = {
        host = "imap.gmail.com";
        port = 993;
        tls.enable = true;
    };
    imapnotify = {
      enable = true;
      boxes = ["INBOX"];
      extraConfig = {
        host = "imap.gmail.com";
        port = 993;
        tls = true;
        tlsOptions = {
          "rejectUnauthorized" = false;
        };
        password = "";
        passwordCmd = "pass show google/neomutt|head -n1";
        onNewMail = "~/.config/mutt/scripts/sync_mail";
        onNewMailPost = "";
      };
    };
  };
}
