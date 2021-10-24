#!/usr/bin/env perl

use utf8::all;
use Modern::Perl 2018;
use Carp::Always;

use CInet::Base;
use CInet::Imset;
use CInet::Cube::Polyhedral;

use List::UtilsBy qw(zip_by);
use Algorithm::Combinatorics qw(subsets permutations);
use Path::Tiny;

my $cube = Cube(5);
# NOTE: reverse subsets implements the right order that
# Dougherty-Freiling-Zeger's files use too!
my @P = reverse subsets($cube->set);
my $infile = shift // die 'need base file';

my %rays;
for (path($infile)->lines_utf8) {
    my @C = m/-?\d+/g;
    die 'bad number of elements' unless @P == @C;
    my $h = CInet::Imset->new($cube);
    zip_by { $h->[$cube->pack([ [], $_[0] ])] = $_[1] } \@P, \@C;
    my $A = $h->relation;
    $rays{$A->permute($_)} = $h->permute($_)
        for permutations($cube->set);
}

while (<<>>) {
    chomp;
    say $rays{$_} // die "could not find '$_'";
}
