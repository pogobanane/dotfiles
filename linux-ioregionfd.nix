{ buildLinux, fetchFromGitHub, pkgs, fetchurl, modDirVersionArg ? null, ... }@args:
buildLinux (args // rec {
  version = "5.16.2";
  modDirVersion = if (modDirVersionArg == null) then
    builtins.replaceStrings [ "-" ] [ ".0-" ] version
      else
    modDirVersionArg;
  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "linux";
    rev = "892dbc39579f6305bdc6f0c77c9247599a028d7b";
    sha256 = "sha256-k/xGMSdFjM4TwzrIsHsXcM+SLCWUVfUh8SOoAYVaCXU=";
  };

  kernelPatches = [{
    name = "enable-kvm-ioregion";
    patch = null;
    extraConfig = ''
      KVM_IOREGION y
    '';
  # 5.12 patch list has one fix we already have in our branch
  }]; # ++ pkgs.linuxPackages_5_13.kernel.kernelPatches;
  extraMeta.branch = "5.16";
  ignoreConfigErrors = true;
} // (args.argsOverride or { }))
