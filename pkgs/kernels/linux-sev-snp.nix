{ buildLinux, fetchFromGitHub, ... }@args:
let
  # the original 5.19-rc5 version (not work)
  # This failes to build due to binutils update
  # https://github.com/AMDESE/linux/tree/sev-snp-5.19-rc5-v2
  # snp_5_19_rc5 = {
  #   owner = "AMDESE";
  #   repo = "linux";
  #   rev = "8e4a0b83a7b0a312efc8a091c0d6d2d920049e5b";
  #   sha256 = "sha256-A6UYI+Xo0uJh+KfUcVR/2Bi+m269rikoDs0Snvnf0Rg=";
  #   version = "5.19";
  #   modDirVersionArg = "5.19.0-rc5-next-20220706";
  #   extraPatches = [];
  # };

  # 5.19-rc5 version, wich bunitls patches
  # https://github.com/mmisono/linux/tree/sev-snp-5.19-rc5-v2-dev
  snp_5_19_rc5 = {
    owner = "mmisono";
    repo = "linux";
    rev = "671ad6d15cf883ae29e8c9613aa4dbbdd71244d7";
    sha256 = "sha256-XzTXafyv/tIIhBLPp2KsBTYd5otVlWr1fgy736mAZLw=";
    version = "5.19";
    modDirVersionArg = "5.19.0-rc5-next-20220706";
    extraPatches = [ ];
  };

  # 5.19-rc6 version, with binutils patches
  # https://github.com/mmisono/linux/tree/sev-snp-iommu-avic_5.19-rc6_v4-dev
  snp_5_19_rc6 = {
    owner = "mmisono";
    repo = "linux";
    rev = "92221f6d4d09653d0a6787d0906958e6d884b85c";
    sha256 = "sha256-2gHPMA84dWBnxMvL4Bmky0c5onDizcr48sPpZpDU79g=";
    version = "5.19";
    modDirVersionArg = "5.19.0-rc6";
    extraPatches = [
      {
        # for some reaon, the BTF build fails, so just disable it
        name = "disable BTF";
        patch = null;
        extraConfig = ''
          DEBUG_INFO_BTF n
        '';
      }
    ];
  };

  # RFC v8 https://lwn.net/Articles/923844/
  # https://github.com/AMDESE/linux/tree/upmv10-host-snp-v8-rfc
  snp_6_1_rfc_v8 = {
    owner = "AMDESE";
    repo = "linux";
    rev = "90eb54a5140b430f4c20c25deadd59f04485d2b2";
    sha256 = "sha256-M/20L2gS8Mg3iLRq00PrlwXyxGD+IEzgcm8/GXWvIBw=";
    version = "6.1";
    modDirVersionArg = "6.1.0-rc4";
    extraPatches = [ ];
  };

  # snp host latest branch
  # https://github.com/AMDESE/linux/tree/snp-host-latest
  snp_latest_6_1 = {
    owner = "AMDESE";
    repo = "linux";
    rev = "db73108c4fd62c03ad57e0c7118e5623750898ee";
    sha256 = "sha256-HP2U6xtwqZQgzJd/RH2I3Ph5wKVkhXtVajNALf4R4HQ=";
    version = "6.1";
    modDirVersionArg = "6.1.0-rc4";
    extraPatches = [ ];
  };

  snp_latest = {
    owner = "AMDESE";
    repo = "linux";
    rev = "fea9b785bfa90e015c7d81526e36060da1bf01d1";
    sha256 = "sha256-AacpCzV0NtraPG4e/L/QDzKwUYveJA1YAaGRapnN/yg=";
    version = "6.3";
    modDirVersionArg = "6.3.0-rc2";
    extraPatches = [ ];
  };

  # change here to change kernel
  # snp_kernel = snp_5_19_rc6;
  # snp_kernel = snp_6_1_rfc_v8;
  snp_kernel = snp_latest;

in
with snp_kernel;
buildLinux (args // rec {
  inherit version;
  modDirVersion =
    if (snp_kernel.modDirVersionArg == null) then
      builtins.replaceStrings [ "-" ] [ ".0-" ] version
    else
      modDirVersionArg;

  src = fetchFromGitHub {
    inherit owner repo rev sha256;
  };

  kernelPatches = [
    {
      name = "amd_sme-config";
      patch = null;
      extraConfig = ''
        AMD_MEM_ENCRYPT y
        CRYPTO_DEV_CCP y
        CRYPTO_DEV_CCP_DD m
        CRYPTO_DEV_SP_PSP y
        KVM_AMD_SEV y
        MEMORY_FAILURE y
        EXPERT y
      '';
    }
  ] ++ extraPatches;
  extraMeta.branch = version;
  ignoreConfigErrors = true;
} // (args.argsOverride or { }))
