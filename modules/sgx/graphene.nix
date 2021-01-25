{ pkgs, config, ... }:

let
  graphene-sgx-driver = (pkgs.nixpkgs-unstable.callPackage ../../pkgs/graphene-sgx-driver {
    inherit (config.boot.kernelPackages) kernel;
  });
in {
  imports = [ ./. ];
  boot.extraModulePackages = [ graphene-sgx-driver ];
}
