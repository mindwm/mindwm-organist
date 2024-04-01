{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
#  inputs.nixpkgs.url = "github:nixos/nixpkgs/23.11";
  inputs.fenix.url = "github:nix-community/fenix";
  inputs.nickel_src.url = "github:tweag/nickel?ref=1.5.0";
  inputs.organist.url = "github:nickel-lang/organist";
  inputs.organist.inputs.nixpkgs.follows = "nixpkgs";
  inputs.organist.inputs.nickel_src.follows = "nickel_src";
#inputs.organist.inputs.nickel_src.flake = true;

  nixConfig = {
    extra-substituters = ["https://organist.cachix.org" "https://nix-community.cachix.org"];
    extra-trusted-public-keys = ["organist.cachix.org-1:GB9gOx3rbGl7YEh6DwOscD1+E/Gc5ZCnzqwObNH2Faw=" "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="];
  };

  outputs = {organist, ...} @ inputs:
    organist.flake.outputsFromNickel ./. inputs {};
}
