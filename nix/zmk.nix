{ stdenv, cmake, ninja, zephyr }:

stdenv.mkDerivation {
  name = "zmk";

  src = ./..;

  nativeBuildInputs = [ cmake ninja ];
  buildInputs = [ zephyr ];
}
