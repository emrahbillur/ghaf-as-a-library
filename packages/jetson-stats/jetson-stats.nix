
{ lib
, fetchFromGitHub
, python3 ? pkgs.python311
, makeWrapper
, pkgs ? import <nixpkgs> {}
}:

let
  py = python3.pkgs;
in
py.buildPythonApplication rec {
  pname = "jetson-stats";
  version = "7.1.5";

  src = fetchFromGitHub {
    owner = "rbonghi";
    repo  = "jetson_stats";
    rev   = "7.1.5";
    sha256 = "sha256-LWGi5bdrYilWDGvqL9xFGwoCHdawtQR3g0h2WFM6CwM=";
  };
  #src = "github://rbonghi/jetson_stats/7b8d204fe3cd48eba7a7c27f74b13407d27597d0";
  format = "setuptools";

  nativeBuildInputs = [ makeWrapper pkgs.buildPackages.python3 ];

  patchPhase = ''
    ${pkgs.buildPackages.python3}/bin/python - <<'PY'
import io, os, re, sys

cfg_path = "jtop/core/config.py"
src = io.open(cfg_path, "r", encoding="utf-8").read()

m = re.search(r"(?ms)^def\s+make_config_service\s*\([^)]*\):.*?(?=^\S)", src)
if not m:
    m = re.search(r"(?ms)^def\s+make_config_service\s*\([^)]*\):.*\Z", src)
if not m:
    sys.exit("ERROR: make_config_service() not found in %s" % cfg_path)

replacement = (
    "def make_config_service():\n"
    "    import os\n"
    "    path = os.environ.get(\"JTOP_STATE_DIR\", \"/var/lib/jtop\")\n"
    "    os.makedirs(path, exist_ok=True)\n"
    "    return path\n"
)

patched = src[:m.start()] + replacement + src[m.end():]
io.open(cfg_path, "w", encoding="utf-8").write(patched)

sp = "setup.py"
s = io.open(sp, "r", encoding="utf-8").read()
s2, n = re.subn(r"cmdclass\s*=\s*\{[^}]*\}", "cmdclass={}", s, count=1, flags=re.S)
if n:
    io.open(sp, "w", encoding="utf-8").write(s2)
PY
  '';

  propagatedBuildInputs = with py; [
    psutil
    numpy
    smbus2
    distro
    unicurses
  ];

  doCheck = false;

  postInstall = ''
    wrapProgram $out/bin/jtop \
      --set-default JTOP_SOCKET /run/jtop.sock \
      --prefix PATH : ${pkgs.cudaPackages.cuda_nvcc}/bin
  '';

  meta = with lib; {
    description = "Interactive monitor (jtop) for NVIDIA Jetson boards";
    homepage    = "https://github.com/rbonghi/jetson_stats";
    licenses    = [ licenses.agpl3Only ];
    platforms   = platforms.linux;
    mainProgram = "jtop";
  };
}