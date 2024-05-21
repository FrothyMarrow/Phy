{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    system = "aarch64-darwin";
    pkgs = import nixpkgs {
      inherit system;
    };
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = [
        pkgs.clangStdenv
        pkgs.glfw
        pkgs.zls
        pkgs.zig
        pkgs.darwin.apple_sdk.frameworks.OpenGL
      ];

      shellHook = ''
        # Zig compiler does not support the -isysroot flag and treats it as an error
        export NIX_CFLAGS_COMPILE=$(echo $NIX_CFLAGS_COMPILE | sed 's|-isysroot /nix/store/[^ ]*||')
      '';
    };

    formatter.${system} = pkgs.alejandra;
  };
}
