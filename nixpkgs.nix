let
  pin = builtins.fromJSON (builtins.readFile ./nixpkgs.json);
in
  import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/${pin.rev}.tar.gz";
    sha256 = pin.sha256;
  })
