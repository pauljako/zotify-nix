{
  description = "Flake for the downstream fork of zotify";

  inputs = {
    # Latest stable Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/25.05";
    music-tag.url = "./music-tag";
  };

  outputs = {
    self,
    nixpkgs,
    music-tag,
  }: let
    pname = "zotify";

    version = "1.1.1";

    # Systems supported
    allSystems = [
      "x86_64-linux" # 64-bit Intel/AMD Linux
      "aarch64-linux" # 64-bit ARM Linux
      "x86_64-darwin" # 64-bit Intel macOS
      "aarch64-darwin" # 64-bit ARM macOS
    ];

    # Helper to provide system-specific attributes
    forAllSystems = f:
      nixpkgs.lib.genAttrs allSystems (system:
        f {
          pkgs = import nixpkgs {inherit system;};
        });
  in {
    packages = forAllSystems ({pkgs}: {
      default = let
        python = pkgs.python3;
      in
        python.pkgs.buildPythonApplication {
          src = builtins.fetchTarball {
            url = "https://github.com/DraftKinner/${pname}/archive/refs/tags/v${version}.tar.gz";
            sha256 = "1z0i65a4kyggrypczp15k0i61bgvdxx1iwmv0z1zb0v2hnqhjijn";
          };

          name = "zotify";

          format = "pyproject";

          env.PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION = "python";

          propagatedBuildInputs = with python.pkgs; [pip setuptools pillow librespot music-tag.packages.${pkgs.system}.default mutagen pkce tqdm limits ffmpy pwinput tabulate];

          pythonRelaxDeps = ["protobuf"];

          pythonImportsCheck = ["zotify"];

          postFixup = ''
            wrapProgram $out/bin/zotify --set PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION python
          '';
        };
    });
  };
}
