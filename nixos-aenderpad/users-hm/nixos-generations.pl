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
my @dirs = glob( $profiles );
my @generations;
foreach(@dirs) {
  push(@generations, $_);
}

my %linuxes; 
for (my $g = 0; $g <= $#generations; $g++) {
  my $initrd = readlink( $generations[$g] . "/initrd");
  my $kernel = readlink( $generations[$g] . "/kernel");
  push( @{ $linuxes{"$initrd"} }, $generations[$g]);
  #push( @{ $linuxes{"$kernel"} }, $generations[$g][2]);
}

# oneliners
#for $linux ( keys %linuxes ) { 
#  my $initrd_size = get_filesize_str($linux);
#  print "$linux ($initrd_size)-> @{ $linuxes{$linux} }\n"; 
#}

# multiline list
for $linux ( keys %linuxes ) { # this dict is unsorted which results in top-level order to be random
  my $initrd_size = get_filesize_str($linux);
  print "$linux ($initrd_size): \n"; #@{ $linuxes{$linux} }\n"; 
  foreach(@{ $linuxes{$linux} }) {
    my $epoch_timestamp = (stat($_))[10];
    my $timestamp       = localtime($epoch_timestamp);
    my $label = profile2label($_);
    print "    - NixOS generation $label from $timestamp\n";
  }
}
