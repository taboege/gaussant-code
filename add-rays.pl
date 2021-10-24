#!/usr/bin/env perl

use Modern::Perl;
use CInet::Base;
use CInet::Cube::Polyhedral;
use CInet::Imset;

my $s = CInet::Imset->new(Cube(5));
for (<<>>) {
    my $h = CInet::Imset->new(Cube(5));
    my $i = 0; $h->[++$i] = $_ for split / /;
    $s += $h
}
say $s
