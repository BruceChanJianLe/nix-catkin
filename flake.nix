{
  description = "Building catkin tool for ROS with Nix";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        my-catkin = (with pkgs; stdenv.mkDerivation {
          pname = "my-catkin";
          version = "0.8.11";
          src = fetchgit {
            url = "https://github.com/ros/catkin";
            rev = "0.8.11";
            sha256 = "4aZb7y24W6WY2dwOj33qf496xp9Sxx8RHvdsyG/OpAA=";
            fetchSubmodules = true;
          };

          nativeBuildInputs = [
            clang
            cmake
            micromamba
            glibc
            glibcLocales
          ];

          buildPhase = ''
            eval "$(micromamba shell hook --shell=posix)"
            micromamba activate noetic
            cmake -S catkin -B build
            # nothing to build actually
            cmake --build build
          '';

          installPhase = ''
            mkdir -p $out/bin
            mv build/bin/* $out/bin
          '';
        }
      );
    in rec {

      defaultApp = flake-utils.lib.mkApp {
        drv = defaultPackage;
      };

      defaultPackage = my-catkin;

      devShell = pkgs.mkShell {
        buildInputs = [
            pkgs.clang
            pkgs.cmake
            pkgs.micromamba
            pkgs.glibc
            pkgs.glibcLocales
        ];
      };
    }
  );
}

#   in {
#     # Define packages for each system
#     packages = forAllSystems (system:
#       let
#         pkgs = nixpkgs.legacyPackages.${system};
#       in
#       {
#         default = pkgs.stdenv.mkDerivation {
#           pname = "nix-catkin";
#           version = "0.8.11";
#
#           src = ./.;
#
#           # nativeBuildInputs = [ pkgs.cmake ];
#
#           # nativeBuildInputs = with pkgs; [
#           #   cmake
#           # ];
#
#           buildInputs = with pkgs; [
#             gcc
#             micromamba
#           ];
#
#           buildPhase = ''
#             eval "$(micromamba shell hook --shell=posix)"
#             # micromamba shell init --shell zsh --root-prefix=~/micromamba
#             # eval "$(micromamba shell hook --shell bash)"
#             # micromamba create -n noetic -c conda-forge -f environment.yaml -y
#             # micromamba activate noetic
#             cmake -S catkin -B build
#             # nothing to build actually
#             cmake --build build
#           '';
#
#           installPhase = ''
#             mkdir -p $out/bin/
#             # cp build/bin $out/bin/
#           '';
#         };
#
#         nativeBuildInputs = [ pkgs.cmake ];
#       }
#     );
#
#     # Development shells for each system
#     devShells = forAllSystems (system:
#       let
#         pkgs = nixpkgs.legacyPackages.${system};
#       in
#       {
#         default = pkgs.mkShell {
#           buildInputs = with pkgs; [
#
#             # Micromamba for Python environment management
#             micromamba
#
#             # Build tools
#             gcc
#             git
#
#           ];
#         };
#       }
#     );
#   };
# }
