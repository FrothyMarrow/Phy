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

    # Zig compiler does not support the isysroot flag, and it is not needed
    removeSysroot = ''
      export NIX_CFLAGS_COMPILE=$(echo $NIX_CFLAGS_COMPILE | sed 's|-isysroot /nix/store/[^ ]*||')
    '';
    # Zig can't find the supporting libGL.tbd, we can add it to the linker flags
    nixLDFlags = "-L${pkgs.darwin.apple_sdk.frameworks.OpenGL}/Library/Frameworks/OpenGL.framework/Versions/A/Libraries";
  in {
    packages.${system}.default = pkgs.stdenv.mkDerivation {
      name = "phy";
      src = ./.;

      nativeBuildInputs = [pkgs.zig.hook];

      buildInputs = [pkgs.darwin.apple_sdk.frameworks.OpenGL pkgs.glfw];

      # The shader paths are hardcoded in the source code
      patchPhase = ''
        sed -i "s|./shader/vertex.glsl|$out/shader/vertex.glsl|" src/main.c
        sed -i "s|./shader/fragment.glsl|$out/shader/fragment.glsl|" src/main.c
      '';

      NIX_LDFLAGS = nixLDFlags;

      buildPhase = removeSysroot;

      postInstall = ''
        mkdir -p $out/shader
        cp shader/* $out/shader
      '';
    };

    devShells.${system}.default = pkgs.mkShell {
      packages = [
        pkgs.clangStdenv
        pkgs.glfw
        pkgs.zls
        pkgs.zig
        pkgs.darwin.apple_sdk.frameworks.OpenGL
      ];

      shellHook = ''
        export NIX_LDFLAGS=${nixLDFlags}$NIX_LDFLAGS
        ${removeSysroot}
      '';
    };

    formatter.${system} = pkgs.alejandra;
  };
}
