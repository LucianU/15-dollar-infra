let
  pkgs = import ./nixpkgs.nix { };
  ghc = pkgs.haskellPackages.ghcWithPackages(p: with p; [
    ghcid
    pureMD5
    text
    turtle
  ]);
in
  pkgs.mkShell {
    buildInputs = with pkgs; [
      ansible
      docker-machine
      doctl
      s3cmd
      ghc
      terraform
    ];
  }
