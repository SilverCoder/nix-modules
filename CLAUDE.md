# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## overview

public nixos/home-manager modules. see README.md for full docs.

## development

no build/test/lint setup. validate manually:
- `nix flake check` - syntax validation
- `nix eval .#homeManagerModules.cli` - test module evaluation

## implementation notes

**helix bg:** themes use bg one hex digit off base00 to prevent terminal transparency issues

**helix-gpt:** private flake input, requires ssh access
