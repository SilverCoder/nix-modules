{ lib }:
{
  # Convert hex "#rrggbb" to COSMIC RGBA tuple (0.0-1.0 floats)
  hexToCosmicRgba = hex:
    let
      clean = lib.removePrefix "#" hex;
      r = lib.toInt "0x${builtins.substring 0 2 clean}";
      g = lib.toInt "0x${builtins.substring 2 2 clean}";
      b = lib.toInt "0x${builtins.substring 4 2 clean}";
      toFloat = n: toString (n / 255.0);
    in "(${toFloat r}, ${toFloat g}, ${toFloat b}, 1.0)";

  # Nix list to RON array
  toRonList = items:
    "[" + lib.concatMapStringsSep ", " (s: ''"${s}"'') items + "]";

  # RON tuple for panel wings (left, right applet lists)
  mkPanelWings = { left, right }:
    "Some((${lib.concatMapStringsSep ", " (s: ''"${s}"'') left}, ${lib.concatMapStringsSep ", " (s: ''"${s}"'') right}))";
}
