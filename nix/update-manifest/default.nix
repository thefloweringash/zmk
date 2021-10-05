{ runCommand, lib, makeWrapper, west, remarshal, nix-prefetch-git }:

runCommand "update-manifest" {
  nativeBuildInputs = [ makeWrapper ];
} ''
  mkdir -p $out/bin $out/libexec
  cp ${./update-manifest.sh} $out/libexec/update-manifest.sh
  makeWrapper $out/libexec/update-manifest.sh $out/bin/update-manifest \
   --prefix PATH : ${lib.makeBinPath [ west remarshal nix-prefetch-git ]}
''
