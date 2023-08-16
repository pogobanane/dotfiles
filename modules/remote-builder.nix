# known working: 
#  - turn on VPN/be at uni
#  - `sudo nixos-rebuild build` to use a clean ssh config.
#  - untested: perms on ssh key?
#  - untested: does nixos cache knowledge about unsuable remotes builders?
{config, ...}: {
  nix.distributedBuilds = true;
  nix.extraOptions = ''
    builders-use-substitutes = true
  '';
  nix.buildMachines = [
    #{
    #  speedFactor = 0;
    #  hostName = "ryan.dse.in.tum.de";
    #  sshUser = "ssh-ng://nix";
    #  sshKey = "/home/peter/.ssh/doctorBuilder"; # TODO use sops
    #  #sshKey = "/tmp/doctorBuilder";
    #  system = "x86_64-linux";
    #  maxJobs = 64;
    #  supportedFeatures = [
    #    "big-parallel"
    #    "kvm"
    #    "nixos-test"
    #  ];
    #}
    {
      # note that this only works in the university network (jumphost missing)
      speedFactor = 0;
      hostName = "graham.dse.in.tum.de";
      protocol = "ssh-ng";
      sshUser = "nix";
      sshKey = "/home/peter/.ssh/doctorBuilder"; # TODO use sops
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSU1oeHJZeEhOZ092YUxINmZWR05HM0Y4L1RORFAxeHFVWHltUUJ5a1Y0YjAK";
      system = "x86_64-linux";
      maxJobs = 64;
      supportedFeatures = [
        "big-parallel"
        "kvm"
        "nixos-test"
      ];
    }
    {
      speedFactor = 0;
      hostName = "aarch64.nixos.community";
      maxJobs = 64;
      sshKey = "/home/peter/.ssh/doctorBuilder";
      sshUser = "pogobanane";
      # ssh-ed25519 public key:
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSU1VVHo1aTl1NUgyRkhOQW1aSnlvSmZJR3lVbS9IZkdoZnduYzE0MkwzZHMK";
      system = "aarch64-linux";
      supportedFeatures = [ "big-parallel" ];
    }
  ];
}
