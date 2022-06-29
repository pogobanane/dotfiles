#!/bin/perl

use File::Basename;

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

my $profiles = "/nix/var/nix/profiles/system*";
my @generations = glob( $profiles );

# $1 either "kernel" or "initrd"
sub efi_sizes {
  my $suffix = shift;

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

print "There are two types of big NixOS files on EFI partitions: initrd and kernels (bzImage).\n";
print "\n# Initrds:\n\n";
efi_sizes("initrd");
print "\n\n# Kernels:\n\n";
efi_sizes("kernel");
