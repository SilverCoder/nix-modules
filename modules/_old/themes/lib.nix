{ lib }:
let
  hexToInt = hex:
    let
      chars = lib.stringToCharacters (lib.toLower hex);
      charToVal = c:
        if c == "a" then 10
        else if c == "b" then 11
        else if c == "c" then 12
        else if c == "d" then 13
        else if c == "e" then 14
        else if c == "f" then 15
        else lib.toInt c;
    in
    lib.foldl (acc: c: acc * 16 + charToVal c) 0 chars;
in
{
  # AARRGGBB format (for polybar, Android-style)
  mkOpacity = alpha: color:
    let
      hex = lib.removePrefix "#" color;
      alphaHex = lib.toHexString (builtins.floor (alpha * 255));
      alphaPadded = if builtins.stringLength alphaHex == 1 then "0${alphaHex}" else alphaHex;
    in
    "#${alphaPadded}${hex}";

  # CSS rgba() format (for waybar, GTK CSS)
  mkOpacityCss = alpha: color:
    let
      hex = lib.removePrefix "#" color;
      r = hexToInt (builtins.substring 0 2 hex);
      g = hexToInt (builtins.substring 2 2 hex);
      b = hexToInt (builtins.substring 4 2 hex);
    in
    "rgba(${toString r}, ${toString g}, ${toString b}, ${toString alpha})";
}
