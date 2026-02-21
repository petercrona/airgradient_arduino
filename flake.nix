{
  description = "AirGradient Arduino development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        platformioEnv = ''
          export PYTHONPATH="${pkgs.python3Packages.pip}/${pkgs.python3.sitePackages}''${PYTHONPATH:+:}''${PYTHONPATH:-}"
        '';
        flashScript = pkgs.writeShellApplication {
          name = "flash";
          runtimeInputs = [ pkgs.platformio ];
          text = ''
            ${platformioEnv}
            platformio run -e esp32-c3 -t upload
          '';
        };

        monitorScript = pkgs.writeShellApplication {
          name = "monitor";
          runtimeInputs = [ pkgs.platformio ];
          text = ''
            ${platformioEnv}
            platformio run -e esp32-c3 -t monitor
          '';
        };
      in
      {
        devShells.default = pkgs.mkShellNoCC {
          packages = [ pkgs.platformio flashScript monitorScript ];
        };

        apps.flash = {
          type = "app";
          program = "${flashScript}/bin/flash";
        };

        apps.monitor = {
          type = "app";
          program = "${monitorScript}/bin/monitor";
        };
      });
}
