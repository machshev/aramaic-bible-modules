{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, poetry2nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        _poetry2nix = poetry2nix.lib.mkPoetry2Nix { inherit pkgs; };
        myEnv = _poetry2nix.mkPoetryEnv {
          projectDir = ./.;
          python = pkgs.python312;
          editablePackageSources = {
            myProject = "${builtins.getEnv "PWD"}/src";
          };
        };
      in {
        devShells.default = pkgs.mkShell {
          inputsFrom = [ myEnv.env ];
          packages = [
            pkgs.poetry
            pkgs.gnumake
          ];
        };
      });
}
