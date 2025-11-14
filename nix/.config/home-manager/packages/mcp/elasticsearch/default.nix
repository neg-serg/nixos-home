{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "elasticsearch-mcp";
  version = "0.4.6";

  src = fetchFromGitHub {
    owner = "elastic";
    repo = "mcp-server-elasticsearch";
    rev = "v${version}";
    hash = "sha256-caH1jW2Crrjp5KLWfR+MxIUmfW5tFunXPXV3K/eLaaA=";
  };

  cargoHash = lib.fakeHash;

  doCheck = false;

  meta = with lib; {
    description = "Elasticsearch MCP server";
    homepage = "https://github.com/elastic/mcp-server-elasticsearch";
    license = licenses.asl20;
    mainProgram = "elasticsearch-core-mcp-server";
    platforms = platforms.unix;
  };
}
