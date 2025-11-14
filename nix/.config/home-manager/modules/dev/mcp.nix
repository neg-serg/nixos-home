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
      };
    };

    home.packages = [
      pkgs.neg.mcp_server_filesystem
      pkgs.neg.mcp_ripgrep
      pkgs.neg.mcp_server_git
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
