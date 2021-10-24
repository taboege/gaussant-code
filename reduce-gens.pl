#!/usr/bin/env perl

# Read a number of binary vectors and print a subset which is
# minimal with respect to inclusion (where 0 means inside and
# 1 means outside). That is, they generate the same intersection
# and none is contained in another.

use Modern::Perl;
use bignum lib => 'GMP';

use List::Util qw(max reduce);

sub in {
    my $x = shift;
    return undef unless length $x;
    0+ "0b$x"
}

my $dim = shift // die 'need dimension';
my $length = $dim*($dim-1) * 2**($dim-3);

sub out {
    sprintf "%0*s", $length, shift->to_bin
}

my @models = map in($_), <>;
my @res;
OUTER: for my $m (@models) {
    for my $n (@models) {
        next if $m == $n;
        # Discard $m is it is a superset of $n.
        next OUTER if ($m & $n) == $m;
    }
    push @res, $m; # survived
}
say out($_) for @res;
