let
  pkgs = import ./nixpkgs.nix { };
  ghc = pkgs.haskellPackages.ghcWithPackages(ps: [ ps.ghcid ]);
in
  pkgs.mkShell {
    buildInputs = with pkgs; [
      ansible
      docker-machine
      doctl
      s3cmd 
      ghc
    ];
  }
