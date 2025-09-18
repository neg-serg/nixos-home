{
  pkgs,
  config,
  ...
}: {
  home.packages = config.lib.neg.pkgsList (with pkgs; [
    sqlite # self-contained, serverless, transactional SQL DB
    pgcli # PostgreSQL TUI client (client-only; no server)
    iredis # Redis enhanced CLI (client-only; no server)
  ]);
}
