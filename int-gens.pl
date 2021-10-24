#!/usr/bin/env perl

# Read a base file given as command-line argument.
# Then for each model on stdin check if it can be
# represented as an intersection of models in the
# base file and if yes, output the generators.

use Modern::Perl;
use bignum lib => 'GMP';

use List::Util qw(max reduce);
use Path::Tiny;

sub in {
    my $x = shift;
    return undef unless length $x;
    0+ "0b$x"
}

my $basefile = shift // die 'need base file';
my @models = map { in($_) } path($basefile)->lines;

sub out {
    # We have the all 1 model in there
    state $len = max map { length $_->to_bin } @models;
    sprintf "%0*s", $len, shift->to_bin
}

while (defined(my $m = readline)) {
    $m = in $m;
    # Get all supersets (note: zero means containment).
    my @S = grep { ($m & $_) == $_ } @models;
    # Check if their intersection is the model.
    my $s = reduce { $a | $b } 0, @S;
    print out($m), ': ';
    if ($m == $s) {
        say 'FOUND (', join(' ', map out($_), @S), ')';
    }
    else {
        say 'NOT FOUND (', out($s), ')';
    }
}
