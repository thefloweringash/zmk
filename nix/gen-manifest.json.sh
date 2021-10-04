#!/usr/bin/env bash
west manifest --freeze | nix run nixpkgs.remarshal -c yaml2json | jq > manifest.json
