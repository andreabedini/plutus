{ inputs, cell }:

_: {
  
  import = [
    cell.devshellProfiles.common
  ];

  packages = [
    cell.packages.cabal-install
    cell.packages.cardano-repo-tool
    cell.packages.fix-png-optimization
    cell.packages.fix-stylish-haskell
    cell.packages.fix-cabal-fmt
    cell.packages.haskell-language-server
    cell.packages.hie-bios
    cell.packages.hlint
    cell.packages.stylish-haskell
    cell.packages.nix-flakes-alias
    cell.packages.cabal-fmt
    cell.packages.nixpkgs-fmt 

    # inputs.nixpkgs.ghcid # TODO(std) why was this originally in the shell?

    inputs.nixpkgs.awscli2 # TODO(std) move these 3 into devops shell or script when we have one
    inputs.nixpkgs.bzip2 
    inputs.nixpkgs.cacert

    inputs.nixpkgs.editorconfig-core-c
    inputs.nixpkgs.editorconfig-checker 
    inputs.nixpkgs.jq 
    inputs.nixpkgs.pre-commit 
    inputs.nixpkgs.shellcheck 
    inputs.nixpkgs.yq 
    inputs.nixpkgs.zlib 
  ] 
  ++ inputs.nixpkgs.lib.optionals (!stdenv.isDarwin) [ 
    cell.packages.r-packages.plotly 
    cell.packages.r-lang 
  ];
}
