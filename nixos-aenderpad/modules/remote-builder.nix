{config, ...}: {
  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      hostName = "ryan.r";
      sshUser = "ssh-ng://nix";
      sshKey = "/home/peter/.ssh/doctorBuilder";
      system = "x86_64-linux";
      maxJobs = 64;
      supportedFeatures = [
        "big-parallel"
        "kvm"
        "nixos-test"
      ];
    }
  ];
}
