#!/usr/bin/env perl
# TODO: we should probably aquire some kind of lock before reading profiles and stores

use File::Basename;
use Getopt::Long;

my $NIXOS_PROFILE = "/nix/var/nix/profiles/system";

sub help() {
  print "nixos-generations v0.0.1
Usage: nixos-generations [subcommand]

Subcommands:
  --help             Shows this help.
  --list             Lists NixOS generations.
  --show-efi         Shows common culprits for full boot/EFI partitions.
                     Garbage-collecting all generations for a culprit frees space.
  --gc <generations> Garbage-collect and delete <generations> as specified 
                     for `nix-env --delete-generations` (e.g. '3 4', '+5', '30d').
                     WARNING: This garbage-collect may also delete other 
                     unreferenced nix-store items.
";
}

sub parse_args() {
  my $help = '';
  my $list = '';
  my $show_efi = '';
  my @gc;

  GetOptions('help' => \$help, 'list' => \$list, 'show-efi' => \$show_efi, 'gc=s{1,}' => \@gc) or die help();

  if ($help) {
    help();
  } elsif ($list) {
    list();
  } elsif ($show_efi) {
    show_efi();
  } elsif (@gc) {
    gc(@gc);
  } else {
    help();
    exit 1;
  }

  exit 0;
}

sub list {
  system("nix-env --list-generations --profile $NIXOS_PROFILE");
}

sub show_efi() {
  print "There are two types of big NixOS files on EFI partitions: initrd and kernels (bzImage).\n";
  print "\n# Initrds:\n\n";
  efi_sizes("initrd");
  print "\n\n# Kernels:\n\n";
  efi_sizes("kernel");
}

sub gc() {
  my $generations = join(" ", @_);
  my $cmd = "nix-env --delete-generations $generations --profile $NIXOS_PROFILE";
  print("# $cmd\n");
  system($cmd) == 0 or die "Deleting generations failed ($?).";
  $cmd = "nix-store --gc";
  print("# $cmd\n");
  system($cmd) == 0 or die "Collecting garbage failed ($?)";
  print("
Generations $generations deleted. To remove potentially deleted kernels from the boot/EFI partition, run:
sudo nixos-rebuild switch
");
}

# https://stackoverflow.com/a/7852925/4108673
sub get_filesize_str
{
    my $file = shift;

    my $size = (stat($file))[7] || die "stat($file): $!\n";

    if ($size > 1099511627776) {   #   TiB: 1024 GiB
        return sprintf("%.2f TiB", $size / 1099511627776);
    } elsif ($size > 1073741824) { #   GiB: 1024 MiB
        return sprintf("%.2f GiB", $size / 1073741824);
    } elsif ($size > 1048576) {    #   MiB: 1024 KiB
        return sprintf("%.2f MiB", $size / 1048576);
    } elsif ($size > 1024) {       #   KiB: 1024 B
        return sprintf("%.2f KiB", $size / 1024);
    } else {                       #   bytes
        return sprintf("%.2f bytes", $size);
    }
}

sub profile2generation {
  my $path = shift;
  my $generation = basename($path);
  $generation =~ s/system-// ;
  $generation =~ s/-link//;
  return $generation;
}

sub profile2label {
  my $path = shift;
  my $generation = profile2generation($path);
  my $description = $generation =~ s/system/(current)/r;
  return $description;
}

# $1 either "kernel" or "initrd"
sub efi_sizes {
  my $suffix = shift;

  my $profiles = "$NIXOS_PROFILE*";
  my @generations = glob( $profiles );

  my %linuxes; 
  for (my $g = 0; $g <= $#generations; $g++) {
    my $file = readlink( $generations[$g] . "/$suffix");
    push( @{ $linuxes{"$file"} }, $generations[$g]);
  }

  # multiline list
  for $linux ( keys %linuxes ) { # this dict is unsorted which results in top-level order to be random
    my $file_size = get_filesize_str($linux);
    my $labels = join(" ", map { profile2label($_) } @{ $linuxes{$linux} });
    print "$linux ($file_size): $labels\n";
    foreach(@{ $linuxes{$linux} }) {
      my $epoch_timestamp = (stat($_))[10];
      my $timestamp       = localtime($epoch_timestamp);
      my $label = profile2label($_);
      print "    - NixOS generation $label from $timestamp\n";
    }
  }
}

parse_args();
