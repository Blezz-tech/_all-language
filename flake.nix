{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    devenv.url = "github:cachix/devenv";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = { self, nixpkgs, devenv, systems, ... } @ inputs:
    let
      forEachSystem = nixpkgs.lib.genAttrs (import systems);
    in
    {
      packages = forEachSystem (system: {
        devenv-up = self.devShells.${system}.default.config.procfileScript;
      });

      devShells = forEachSystem
        (system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
          in
          {
            default = devenv.lib.mkShell {
              inherit inputs pkgs;
              modules = [
                {
                  # https://devenv.sh/reference/options/

                  packages = with pkgs; [
                    clang
                  ];

                  languages = {
                    javascript.enable = true;
                    typescript.enable = true;
                    rust.enable = true;
                    php.enable = true;
                    haskell.enable = true;
                    c.enable = true;
                    dotnet.enable = true;
                    python.enable = true;
                    nix.enable = true;
                    scala.enable = true;
                    java.enable = true;
                    shell.enable = true;
                  };
                }
              ];
            };
          });
    };
}
