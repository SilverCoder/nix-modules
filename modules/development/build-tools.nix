{ ... }: {
  flake.homeManagerModules.build-tools = { pkgs, ... }: {
    home.packages = with pkgs; [
      clang-tools
      cmake
      gcc
      gdb
      gnumake
      libxkbcommon
      lldb
      llvm
      meson
      openssl
      pkg-config
      tokei
      wabt
      zlib
    ];
  };
}
