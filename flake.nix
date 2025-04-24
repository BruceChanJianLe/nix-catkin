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

          buildInputs = with pkgs; [
            gcc
            micromamba
            cmake
            git
          ];

          buildPhase = ''
            micromamba activate noetic
            cmake -S ./catkin -B build
            # nothing to build actually
            cmake --build build
          '';

          installPhase = ''
            mkdir -p $out/bin/
            cp build/bin $out/bin/
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
            gcc
            cmake
            git

          ];
        };
      }
    );
  };
}
