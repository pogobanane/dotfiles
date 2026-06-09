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
    wantedBy = [ "multi-user.target" ];
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
    };
  };
}
