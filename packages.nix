{}:
  let
    nixpkgs = import (builtins.fetchTarball {
      name = "nixpkgs-unstable-2020-01-26";
      url = https://github.com/NixOS/nixpkgs-channels/archive/0c960262d159d3a884dadc3d4e4b131557dad116.tar.gz;
      sha256 = "sha256:0d7ms4dxbxvd6f8zrgymr6njvka54fppph1mrjjlcan7y0dhi5rb";
    }) { inherit config; };

    config = {
      allowBroken = true;
      packageOverrides = pkgs:
        let
          hl = pkgs.haskell.lib;
          t = pkgs.lib.trivial;
          dontAndDisable = (t.flip t.pipe)
            [hl.dontCheck
             hl.dontCoverage
             hl.dontHaddock
            ];
        in rec {
          haskellPackages = pkgs.haskellPackages.override {
            overrides = self: super: {
              bloodhound = dontAndDisable 
                (self.callCabal2nix "bloodhound" (builtins.fetchGit {
                  url = "https://github.com/naglalakk/bloodhound";
                  rev = "afdebd027dacae5ded03215e2b085daf6fd77b59";
                }) {});
                imagemagick = 
                (pkgs.haskell.lib.appendConfigureFlags
                  (dontAndDisable
                    (self.callCabal2nix "imagemagick" (builtins.fetchGit {

                      url = "https://github.com/naglalakk/imagemagick";
                      rev = "f76dab6c7489b382af36aaad48e6d36564720573";

                    }) { 
                      imagemagick = pkgs.imagemagick; 
                    })
                  )
                  [ "--extra-include-dirs=${pkgs.imagemagick.dev}/include/ImageMagick"
                  ]
                );
            };
          };
        };
    };
  in nixpkgs
