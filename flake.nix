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
