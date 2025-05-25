{
  description = "Flake for the downstream fork of music-tag";

  inputs = {
    # Latest stable Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/25.05";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    pname = "music-tag";

    version = "0.4.7";

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
        python.pkgs.buildPythonPackage {
          src = builtins.fetchTarball {
            url = "https://github.com/DraftKinner/${pname}/archive/refs/tags/v${version}.tar.gz";
            sha256 = "17ddm46sjsrwb8kqhhgbl13v5d3mqyzrlvc3j5nlf73d7ymqfz0m";
          };

          name = pname;


          env.PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION = "python";

        };
    });
  };
}

