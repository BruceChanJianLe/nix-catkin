{
  description = "Building catkin tool for ROS with Nix";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
  };

  outputs = { self, nixpkgs }:
  let
    # System types to support
    supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

    # Helper function to generate an attrset
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
  in {
    # Define packages for each system
    packages = forAllSystems (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        default = pkgs.stdenv.mkDerivation {
          pname = "nix-catkin";
          version = "0.8.11";

          src = ./.;

          buildInputs = [ pkgs.gcc ];

          buildPhase = ''
            $CC -o hello ./src/hello.c
          '';

          installPhase = ''
            mkdir -p $out/bin/
            cp hello $out/bin/
          '';
        };
      }
    );

    # Development shells for each system
    devShells = forAllSystems (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Micromamba for Python environment management
            micromamba

            # Build tools
            cmake
            git
            # pkg-config

            # ROS dependencies
            # boost
            # cppcheck
            # gtest
            # log4cxx
            # lz4
            # tinyxml
            # tinyxml2
            # eigen

            # Additional dependencies
            # libGL
            # gtk3
            # libusb1

            # Compression libraries
            # bzip2
            # zlib

            # Network libraries
            # curl
            # openssl
          ];
        };
      }
    );
  };
}
