#!/usr/bin/env perl

use utf8::all;
use Modern::Perl 2018;
use Getopt::Long;

use CInet::Base;
use Algorithm::Combinatorics qw(subsets);
use List::SomeUtils qw(firstidx);
use List::UtilsBy qw(sort_by);

use Path::Tiny qw(tempfile);
use Tie::Select;
use IPC::Run qw(run timeout);

GetOptions(
    "n|dry-run" => \my $dry_run,
) or die 'failed to parse options';

my $cube = Cube(shift // die 'need dimension');
my $G = CInet::Relation->new($cube => shift // die 'need gaussoid');

my $x = 'a';
my (@vars, %vars);
for my $ij (subsets($cube->set, 2)) {
    my ($i, $j) = @$ij;
    push @vars, $x;
    $vars{"$i,$j"} = $vars{"$j,$i"} = $x;
    $x++;
}

sub unit_symmetric_matrix {
    my ($cube, $x) = @_;
    my @rows;
    for my $i ($cube->set->@*) {
        my @row;
        for my $j ($cube->set->@*) {
            push @row, ($i == $j ? 1 : $vars{"$i,$j"});
        }
        push @rows, "{ @{[ join(', ', @row) ]} }";
    }
    @rows
}

sub to_index {
    my ($i, $cube) = @_;
    firstidx { $_ eq $i } $cube->set->@*
}

sub minor {
    my ($cube, $X, $I, $J) = @_;
    my @I = map { to_index $_, $cube } @$I;
    my @J = map { to_index $_, $cube } @$J;
    "det ${X}_{@{[ join(',', @I) ]}}^{@{[ join(',', @J) ]}}"
}

sub vanishing_part {
    my ($cube, $G, $X) = @_;
    my @poly;
    for my $ijK (grep { $G->ci($_) } $cube->squares) {
        my ($ij, $K) = @$ijK;
        my ($i, $j) = @$ij;
        push @poly, minor($cube, $X, [$i, @$K], [$j, @$K]);
    }
    @poly
}

sub nonvanishing_part {
    my ($cube, $G, $X) = @_;
    my @poly;
    # Go from small to big determinants.
    my @sq = sort_by { $_->[1]->$#* } $cube->squares;
    for my $ijK (grep { not $G->ci($_) } @sq) {
        my ($ij, $K) = @$ijK;
        my ($i, $j) = @$ij;
        push @poly, minor($cube, $X, [$i, @$K], [$j, @$K]);
    }
    @poly
}

sub principal_minors {
    my ($cube, $X) = @_;
    my @pr;
    for my $k (1 .. (0+ $cube->set->@*)) {
        for my $I (subsets($cube->set, $k)) {
            push @pr, minor($cube, $X, $I, $I);
        }
    }
    @pr
}

sub colon {
    my $J = shift;
    my $expr = "$J";
    $expr = "($expr : $_)" for @_;
    $expr
}

my $file = tempfile;
for ($file->openw_utf8) {
    local $SELECT = $_;

    # Useful functions:
    # CI = N -> flatten(subsets(N, 2) / (ij -> (subsets(set(N) - ij) / (L -> (ij#0, ij#1, toList(L))))))
    # apr = (X, ijK) -> (I := flatten({ijK#0, ijK#2}); J := flatten({ijK#1, ijK#2}); det X_I^J)
    # X = matrix{{1, a, b, c, d}, {a, 1, e, f, g}, {b, e, 1, h, i}, {c, f, h, 1, j}, {d, g, i, j, 1}}
    #
    # Filter out all almost-principal minors which vanish on J:
    # select(CI{0,1,2,3,4}, ijK -> apr(X, ijK) % J == 0)

    say 'R = QQ[', join(', ', @vars), '];';
    say 'X = matrix {';
    say join ",\n", map "  $_", unit_symmetric_matrix($cube => 'a');
    say '};';
    say 'I = ideal(';
    say join ",\n", map "  $_", vanishing_part($cube => $G => 'X');
    say ');';
    say 'J = radical I;';
    # Since J is radical, we can saturate at the principal minors
    # just by a simple colon.
    say 'J = ', colon('J', principal_minors($cube => 'X'));

    # Now remove components of the other almost-principal minors
    # which should not vanish.
    say 'J = ', colon('J', nonvanishing_part($cube => $G => 'X'));

    # Now $G is algebraically realizable over CC if and only if
    # the ideal is not 1.
    say 'if J == 1 then exit 1;';
    say 'exit 0;';

    close;
}

if ($dry_run) {
    say $file->slurp_utf8;
}
else {
    my $ret = eval {
        run ['M2', $file], timeout(10);
        $? >> 8
    };
    exit($ret // 5); # 5 signals timeout
}
