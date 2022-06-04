{config, ...}: {
  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      hostName = "ryan.r";
      sshUser = "ssh-ng://nix";
      sshKey = "/home/peter/.ssh/doctorBuilder"; # TODO use sops
      system = "x86_64-linux";
      maxJobs = 64;
      supportedFeatures = [
        "big-parallel"
        "kvm"
        "nixos-test"
      ];
    }
    {
      hostName = "graham.r";
      sshUser = "ssh-ng://nix";
      sshKey = "/home/peter/.ssh/doctorBuilder"; # TODO use sops
      system = "x86_64-linux";
      maxJobs = 64;
      supportedFeatures = [
        "big-parallel"
        "kvm"
        "nixos-test"
      ];
    }
    {
      hostName = "aarch64.nixos.community";
      maxJobs = 64;
      sshKey = "/home/peter/.ssh/doctorBuilder";
      sshUser = "pogobanane";
      system = "aarch64-linux";
      supportedFeatures = [ "big-parallel" ];
    }
  ];
}
