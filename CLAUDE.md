# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## overview

public nixos/home-manager modules. see README.md for full docs.

## development

no build/test/lint setup. validate manually:
- `nix flake check` - syntax validation
- `nix eval .#homeManagerModules.cli` - test module evaluation

## architecture quick-reference

**module pattern:** `config.modules.{category}.{feature}` namespace with `lib.mkEnableOption` defaulting true

**feature gating:** modules check `config.modules.machine.features.desktop` for conditional activation

**dual-mode:** desktop & machine export both nixosModule + homeManagerModule

**auto-enable:** bspwm enables dunst, picom, polybar, rofi, sxhkd

## implementation notes

**helix bg:** themes use bg one hex digit off base00 to prevent terminal transparency issues

**helix-gpt:** private flake input, requires ssh access
