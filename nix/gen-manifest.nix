#!/usr/bin/env nix-shell
#!nix-shell -p nix-prefetch-git -i bash

set -x
set -euo pipefail

jq -c '.manifest.projects[]' < manifest.json | while read -r p; do
  sha256=$(nix-prefetch-git \
    --quiet \
    --fetch-submodules \
    --url "$(jq -r .url <<< "$p")" \
    --rev "$(jq -r .revision <<< "$p")" \
    | jq -r .sha256)
  jq --arg sha256 "$sha256" '. + $ARGS.named' <<< "$p"
done | jq --slurp

