{ pkgs ? import <nixpkgs> {} }:

pkgs.callPackage ./zephyr.nix {}
