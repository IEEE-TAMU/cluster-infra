{
  description = "";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    flake-parts.url = "github:hercules-ci/flake-parts";
    git-hooks.url = "github:gigamonster256/git-hooks.nix";
    git-hooks.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      nixpkgs,
      systems,
      flake-parts,
      git-hooks,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        git-hooks.flakeModule
      ];
      systems = import systems;
      perSystem =
        {
          config,
          pkgs,
          ...
        }:
        {
          formatter = pkgs.nixfmt-tree;

          pre-commit.settings.hooks = {
            yamlfmt.enable = true;
            yamlfmt.settings.lint-only = false;
            typos.enable = true;
            typos.args = [ "--force-exclude" ];
          };

          # install the shellHook and packages from git-hooks
          # as well as helpful tools for managing the cluster
          devShells.default = (import ./shell.nix { inherit pkgs; }).overrideAttrs {
            inputsFrom = [
              config.pre-commit.devShell
            ];
          };
        };
    };
}
