# Complete Theme Color Coverage

**Date:** 2025-11-05
**Status:** Approved

## Problem

Rofi modules (launcher, powermenu) show generic purple colors when using dracula theme because:
1. Dracula theme missing 3 rofi colors: `background-alt`, `active`, `urgent`
2. Rofi scripts have hardcoded fallbacks: `or "#11092D"`, `or "#281657"`, etc.
3. Catppuccin themes all complete; dracula incomplete

Additional: lightdm module description hardcodes "Dracula theme" text.

## Solution

**Approach:** Direct fix (no fallbacks, mandatory colors)

Since theme collection is controlled, enforce complete color definitions:
1. Add 3 missing colors to dracula theme using base16 palette
2. Remove all `or "#..."` fallbacks from rofi modules
3. Update lightdm description to be theme-agnostic

## Implementation

### 1. Fix dracula theme colors

Add to `themes/dracula.nix` `modules.desktop.rofi.colors`:
```nix
background-alt = colors.base01;  # #44475a - lighter background
active = colors.base0C;          # #8be9fd - cyan
urgent = colors.base08;          # #ff5555 - red
```

### 2. Remove rofi fallbacks

**launcher.nix:29-34** - change from:
```nix
background: ${rofiCfg.colors.background or "#11092D"};
```
to:
```nix
background: ${rofiCfg.colors.background};
```

Apply to all 6 color fields (background, background-alt, foreground, selected, active, urgent).

**powermenu.nix:22-27** - same pattern.

### 3. Fix lightdm description

**modules/desktop/lightdm/default.nix:10** - change:
```nix
description = "Enable LightDM display manager with Dracula theme";
```
to:
```nix
description = "Enable LightDM display manager";
```

## Verification

All catppuccin variants (latte, frappe, macchiato, mocha) already provide complete colors. After changes:
- Dracula: complete ✓
- No fallback colors in any module
- Theme system enforces completeness implicitly (build fails if colors missing)

## Files Modified

- `themes/dracula.nix` - add 3 rofi colors
- `modules/desktop/rofi/launcher.nix` - remove 6 fallbacks
- `modules/desktop/rofi/powermenu.nix` - remove 6 fallbacks
- `modules/desktop/lightdm/default.nix` - fix description
