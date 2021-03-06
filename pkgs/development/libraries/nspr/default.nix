{ stdenv, fetchurl
, CoreServices ? null
, buildPackages }:

let version = "4.25"; in

stdenv.mkDerivation {
  pname = "nspr";
  inherit version;

  src = fetchurl {
    url = "mirror://mozilla/nspr/releases/v${version}/src/nspr-${version}.tar.gz";
    sha256 = "0mjjk2b7ika3v4y99cnaqz3z1iq1a50r1psn9i3s87gr46z0khqb";
  };

  patches = [
    ./0001-Makefile-use-SOURCE_DATE_EPOCH-for-reproducibility.patch
  ];

  outputs = [ "out" "dev" ];
  outputBin = "dev";

  preConfigure = ''
    cd nspr
  '' + stdenv.lib.optionalString stdenv.isDarwin ''
    substituteInPlace configure --replace '@executable_path/' "$out/lib/"
    substituteInPlace configure.in --replace '@executable_path/' "$out/lib/"
  '';

  HOST_CC = "cc";
  depsBuildBuild = [ buildPackages.stdenv.cc ];
  configureFlags = [
    "--enable-optimize"
    "--disable-debug"
  ] ++ stdenv.lib.optional stdenv.is64bit "--enable-64bit";

  postInstall = ''
    find $out -name "*.a" -delete
    moveToOutput share "$dev" # just aclocal
  '';

  buildInputs = [] ++ stdenv.lib.optionals stdenv.isDarwin [ CoreServices ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    homepage = "http://www.mozilla.org/projects/nspr/";
    description = "Netscape Portable Runtime, a platform-neutral API for system-level and libc-like functions";
    platforms = platforms.all;
    license = licenses.mpl20;
  };
}
