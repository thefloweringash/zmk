let
  pkgs = import <nixpkgs> { };

  inherit (pkgs) newScope;
  inherit (pkgs.lib) makeScope;
in

makeScope newScope (self: with self; {
  zephyr = callPackage ./zephyr.nix { };

  zmk = callPackage ./zmk.nix { };
})
