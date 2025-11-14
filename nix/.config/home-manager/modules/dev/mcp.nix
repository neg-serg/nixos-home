{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfgDev = config.features.dev.enable or false;
in
lib.mkIf cfgDev (lib.mkMerge [
  # Central MCP servers config written to $XDG_CONFIG_HOME/mcp/mcp.json
  {
    programs.mcp = let
      repoRoot = "${config.neg.dotfilesRoot}/nix/.config/home-manager";
      fsBinary = "${pkgs.neg.mcp_server_filesystem}/bin/mcp-server-filesystem";
      rgBinary = "${pkgs.neg.mcp_ripgrep}/bin/mcp-ripgrep";
      gitBinary = "${pkgs.neg.mcp_server_git}/bin/mcp-server-git";
      memoryBinary = "${pkgs.neg.mcp_server_memory}/bin/mcp-server-memory";
      fetchBinary = "${pkgs.neg.mcp_server_fetch}/bin/mcp-server-fetch";
      seqBinary = "${pkgs.neg.mcp_server_sequential_thinking}/bin/mcp-server-sequential-thinking";
      timeBinary = "${pkgs.neg.mcp_server_time}/bin/mcp-server-time";
      docsearchBinary = "${pkgs.neg.docsearch_mcp}/bin/docsearch-mcp";
      browserBinary = "${pkgs.neg.mcp_server_browserbase}/bin/mcp-server-browserbase";
      postgresBinary = "${pkgs.neg.postgres_mcp}/bin/simple-postgres-mcp";
      redisBinary = "${pkgs.neg.redis_mcp}/bin/mcp-server-redis";
    in {
      enable = true;
      servers = {
        # Kitchen‑sink demo server with many tools; runs via npx
        everything = {
          command = "npx";
          args = [
            "-y"
            "@modelcontextprotocol/server-everything"
          ];
        };

        # Remote HTTP server (requires CONTEXT7_API_KEY in env)
        context7 = {
          url = "https://mcp.context7.com/mcp";
          headers = { CONTEXT7_API_KEY = "{env:CONTEXT7_API_KEY}"; };
        };

        filesystem-local = {
          command = fsBinary;
          args = [repoRoot];
        };

        rg-index = {
          command = rgBinary;
          env = { MCP_RIPGREP_ROOT = repoRoot; };
        };

        git-local = {
          command = gitBinary;
          args = [
            "--repository"
            repoRoot
          ];
        };

        memory-local = {
          command = memoryBinary;
        };

        fetch-http = {
          command = fetchBinary;
        };

        sequential-thinking = {
          command = seqBinary;
        };

        time-local = {
          command = timeBinary;
        };

        docsearch-local = {
          command = docsearchBinary;
        };

        browserbase = {
          command = browserBinary;
          env = {
            BROWSERBASE_API_KEY = "{env:BROWSERBASE_API_KEY}";
            STAGEHAND_API_KEY = "{env:STAGEHAND_API_KEY}";
          };
        };

        postgres-local = {
          command = postgresBinary;
          env = {
            POSTGRES_DSN = "{env:POSTGRES_DSN}";
            POSTGRES_READ_ONLY = "{env:POSTGRES_READ_ONLY}";
          };
        };

        redis-local = {
          command = redisBinary;
          env = {
            REDIS_URL = "{env:REDIS_URL}";
          };
        };
      };
    };

    home.packages = [
      pkgs.neg.mcp_server_filesystem
      pkgs.neg.mcp_ripgrep
      pkgs.neg.mcp_server_git
      pkgs.neg.mcp_server_memory
      pkgs.neg.mcp_server_fetch
      pkgs.neg.mcp_server_sequential_thinking
      pkgs.neg.mcp_server_time
      pkgs.neg.docsearch_mcp
      pkgs.neg.mcp_server_browserbase
      pkgs.neg.postgres_mcp
      pkgs.neg.redis_mcp
    ];
  }

  # Optional integrations: OpenCode and VS Code consume the central MCP list
  {
    programs.opencode = {
      enable = true;
      enableMcpIntegration = true;
      # Keep default package (pkgs.opencode) if available; do not force extra settings
    };
    # VSCode MCP integration can be enabled later if needed;
    # it may introduce extra evaluation edges in some environments.
    # programs.vscode.profiles.default.enableMcpIntegration = true;
  }
])
