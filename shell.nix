let
  pkgs = import ./nixpkgs.nix { };
in
  pkgs.mkShell {
    buildInputs = with pkgs; [
      ansible
      docker-machine
      terraform
    ];
  }
