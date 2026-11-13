{ ... }: {
  flake.homeManagerModules.curseforge = { pkgs, ... }:
    let
      pname = "curseforge";
      version = "1.326.0-42377";
      src = pkgs.fetchurl {
        url = "https://curseforge.overwolf.com/electron/linux/CurseForge-${version}.AppImage";
        hash = "sha512-LpFsA2HGqhT6D3Q0/B3W8gWN320TD1eAziTXFp6sTQubrbfa1sUkTzkLyG5/vVzvr+lBHfzicyojl6lPg6ztFA==";
      };
      contents = pkgs.appimageTools.extract { inherit pname version src; };
      curseforge = pkgs.appimageTools.wrapType2 {
        inherit pname version src;
        extraInstallCommands = ''
          install -Dm444 ${contents}/curseforge.desktop $out/share/applications/curseforge.desktop
          substituteInPlace $out/share/applications/curseforge.desktop \
            --replace-fail 'Exec=AppRun --no-sandbox %U' 'Exec=curseforge --no-sandbox %U'
          cp -r ${contents}/usr/share/icons $out/share/
        '';
        meta = {
          description = "CurseForge mod manager";
          homepage = "https://www.curseforge.com";
          license = pkgs.lib.licenses.unfree;
          platforms = [ "x86_64-linux" ];
          mainProgram = "curseforge";
        };
      };
    in
    {
      home.packages = [ curseforge ];
    };
}
