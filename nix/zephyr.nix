{ stdenv, lib, fetchgit }:
let
  manifestJSON = builtins.fromJSON (builtins.readFile ./manifest-hash.json);

  projects = lib.forEach manifestJSON ({ name, revision, url, sha256, ... }@args: {
    path = args.path or name;
    src = fetchgit {
      inherit name url sha256;
      rev = revision;
    };
  });
in

stdenv.mkDerivation {
  name =  "zephyr";

  dontUnpack = true;

  installPhase = ''
    mkdir $out

    link() {
      local path=$1 src=$2
      local container=$(dirname "$path")
      mkdir -p "$container"
      ln -s "$src" "$path"
    }
  '' + lib.concatMapStringsSep "\n" (p: ''
    link $out/${p.path} ${p.src}
  '') projects;
}
