{ lib, ... }: {
  boot.kernelPatches = [ {
    name = "dax";
    patch = null;
    extraStructuredConfig.FS_DAX = lib.kernel.yes;
  }];
}
