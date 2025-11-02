{ lib }:
{
  mkOpacity = alpha: color:
    let
      hex = lib.removePrefix "#" color;
      alphaHex = lib.toHexString (builtins.floor (alpha * 255));
      alphaPadded = if builtins.stringLength alphaHex == 1 then "0${alphaHex}" else alphaHex;
    in
    "#${alphaPadded}${hex}";
}
