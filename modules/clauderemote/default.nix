{ pkgs, ... }:
let
  clauderemote = pkgs.runCommandLocal "clauderemote" { } ''
    mkdir -p $out/bin
    cp ${./clauderemote} $out/bin/clauderemote
    cp ${./clauderemote-ctl} $out/bin/clauderemote-ctl
    chmod +x $out/bin/*
  '';
in
{
  environment.systemPackages = [ clauderemote ]; # the packages in the systemd path are also implied here, but i'm evil so i omit them

  systemd.services.clauderemote = {
    description = "claude session in tmux -L clauderemote";
    # wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    path = [
      clauderemote
      pkgs.tmux
      pkgs.claude-code
      pkgs.bash
      pkgs.coreutils
      pkgs.procps
      pkgs.gawk
      pkgs.hostname-debian
    ];
    serviceConfig = {
      # clauderemote-ctl start returns after spawning the tmux server, which
      # keeps running in this unit's cgroup.
      Type = "oneshot";
      RemainAfterExit = true;
      User = "peter";
      WorkingDirectory = "/home/peter";
      ExecStart = "${clauderemote}/bin/clauderemote-ctl start";
      ExecStop = "${clauderemote}/bin/clauderemote-ctl stop";

      # Sandboxing. Deliberately NOT set:
      #  - PrivateTmp: the tmux socket lives in /tmp/tmux-<uid>/ and must be
      #    reachable from interactive shells for clauderemote-ctl attach/list
      #  - MemoryDenyWriteExecute: breaks the JS JIT of the claude binary
      #  - RestrictNamespaces: claude's own bash sandboxing uses bubblewrap
      #  - ProtectHome: /home/peter is claude's workspace
      NoNewPrivileges = true; # no sudo/setuid escalation
      # ProtectSystem = "strict"; # everything read-only except ReadWritePaths
      # ReadWritePaths = [
      #   "/home/peter"
      #   "/tmp"
      #   "/nix/var/nix/daemon-socket" # connect()ing to the nix daemon needs write
      # ];
      CapabilityBoundingSet = "";
      PrivateDevices = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      LockPersonality = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" "AF_NETLINK" ];
      SystemCallFilter = [ "@system-service" ];
      SystemCallErrorNumber = "EPERM";
    };
  };
}
