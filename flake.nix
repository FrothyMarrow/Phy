{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs:
  let
    system = "aarch64-darwin";
    pkgs = import nixpkgs {
      inherit system;
    };
  in
  {
    packages.${system}.default = pkgs.stdenv.mkDerivation {
        name = "phy";
        src = ./.;

        nativeBuildInputs = [pkgs.cmake];

        buildInputs = [pkgs.darwin.apple_sdk.frameworks.OpenGL pkgs.glfw];

        installPhase = ''
            mkdir -p $out/shader
            cp -r $src/shader $out/shader
            mkdir $out/bin
            cp phy $out/bin
        '';
   };

    devShells.${system}.default = pkgs.mkShell {
      packages = [
        pkgs.clangStdenv
        pkgs.clang-tools
        pkgs.cmake
        pkgs.glfw
        pkgs.darwin.apple_sdk.frameworks.OpenGL
      ];
    };
    
    formatter.${system} = pkgs.alejandra;
  };
}
