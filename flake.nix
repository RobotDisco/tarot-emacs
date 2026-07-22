{
  description = "A Tarot Card reader for Emacs";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;

      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = lib.genAttrs systems;
      pkgsFor = system: nixpkgs.legacyPackages."${system}";
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.mkShell {
            nativeBuildInputs = with pkgs; [
              just

              nixd
              nixfmt
            ];
          };
        }
      );

      packages = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.emacsPackages.melpaBuild {
            pname = "tarot";
            src = self;
            version = self.lastModifiedDate;

            meta = {
              license = lib.licenses.gpl3Plus;
              homepage = "https://github.com/RobotDisco/tarot-emacs";
              description = "A Tarot Card reader for Emacs";
            };
          };
        }
      );
    };
}
