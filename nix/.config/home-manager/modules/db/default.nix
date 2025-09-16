{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; config.lib.neg.pkgsList [
    sqlite # self-contained, serverless, transactional SQL DB
    pgcli # PostgreSQL TUI client (client-only; no server)
    iredis # Redis enhanced CLI (client-only; no server)
  ];
}
