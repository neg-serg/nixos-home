{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; config.lib.neg.pkgsList [
    sqlite # self-contained, serverless, zero-configuration, transactional SQL database engine
    postgresql # PostgreSQL server and client tools (psql, initdb, etc.)
  ];
}
