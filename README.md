# How to find a multilinear but non-algebraic gaussoid

This repository accompanies a remark in my paper [arXiv:2010.11914](https://arxiv.org/abs/2010.11914).

## Preparation

You will need to install a recent Perl, Julia and the required packages.
In particular, install my [CInet::Base](https://github.com/CInet/CInet-Base)
and [CInet::Polyhedral](https://github.com/CInet/CInet-Polyhedral) modules.

## Finding the non-algebraic gaussoid

Download the list of 5-gaussoids modulo hyperoctahedral group and run
a complex realizability test in Macaulay2 on each of them, timing out
the computation after a few seconds:

``` console
$ curl -O https://gaussoids.de/gaussoids/cnf5-mod-Bn.txt
$ cut -f1 cnf5-mod-Bn.txt | while read G;
> do perl realiz.pl 5 $G 2>/dev/null;
> if [[ "$?" -eq "1" ]]; then echo $G; fi;
> done
```

```
…
11111111111111111111010110101111111111101110111111110111101111110111111111111111
…
```

To see the gaussoid behind this binary coding:

``` console
$ perl -MCInet::Base -E 'say FACE for CInet::Relation->new(Cube(5) => shift)->independences' \
> 11111111111111111111010110101111111111101110111111110111101111110111111111111111
```

```
14|23
14|35
15|2
15|4
23|145
24|5
25|13
34|1
35|
```

Verification that this gaussoid is not algebraically realizable is quick
using Macaulay2 with this explicit proof:

``` macaulay2
R = QQ[a,b,c,d,e,f,g,h,i,j]
X = matrix{{1,a,b,c,d}, {a,1,e,f,g}, {b,e,1,h,i}, {c,f,h,1,j}, {d,g,i,j,1}}
-- CI ideal
I = ideal(
  det X_{0,1,2}^{3,1,2},     -- 14|23
  det X_{0,2,4}^{3,2,4},     -- 14|35
  det X_{0,1}^{4,1},         -- 15|2
  det X_{0,3}^{4,3},         -- 15|4
  det X_{1,0,3,4}^{2,0,3,4}, -- 23|145
  det X_{1,4}^{3,4},         -- 24|5
  det X_{1,0,2}^{4,0,2},     -- 25|13
  det X_{2,0}^{3,0},         -- 34|1
  det X_{2}^{4}              -- 35|
)
-- All entries but i do not vanish:
K = radical(I) : a*b*c*d*e*f*g*h*j
-- It turns out that (34|125) is in K (but not in I):
det(X_{2,0,1,4}^{3,0,1,4}) % K --> 0
```

This shows that (34|125) is implied on the algebraic realization space
and thus that the above gaussoid is not realizable.

## Proving multilinearity

First download the rays5 from Zeger's website and obtain the semimatroids
of their rank functions:

``` console
$ curl -O http://code.ucsd.edu/zeger/linrank/rays5
$ perl rays.pl rays5 | sort | uniq >rays.txt
```

The gaussoid found above is a semimatroid. Finding the extreme polymatroids
in the multilinear cone computed by Dougherty-Freiling-Zeger which span its
corresponding face is a routine linear programming task.

``` console
$ perl int-gens.pl rays.txt <<<"11111111111111111111010110101111111111101110111111110111101111110111111111111111" |
> perl -anE '/\((.*)\)/; say for split / /, $1' |
> perl reduce-gens.pl 5 |
> perl find-rays.pl rays5
```

```
0 0 0 0 1 1 0 0 1 1 0 1 1 1 1 1 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
0 0 0 1 1 1 0 1 1 1 1 1 1 2 2 2 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2
0 1 0 1 0 1 1 2 1 2 1 0 1 1 2 1 2 1 2 2 2 2 1 2 1 2 2 2 2 2 2 2
0 1 0 1 1 0 1 1 1 1 1 1 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
0 1 0 1 0 0 1 1 1 1 1 0 0 1 1 0 1 1 1 1 1 1 1 1 0 1 1 1 1 1 1 1
0 1 1 1 1 2 2 2 2 3 2 2 3 2 3 3 3 3 4 3 3 4 3 4 4 4 4 4 4 4 4 4
0 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 3 3 3 3 2 3 2 3 3 3 3 3 3 3 3 3
0 1 1 2 1 2 2 3 2 3 2 2 3 3 4 3 3 3 4 4 4 4 3 4 4 4 4 4 4 4 4 4
0 1 1 1 1 1 2 1 2 2 2 2 2 2 2 2 2 3 3 2 2 3 3 3 3 3 3 3 3 3 3 3
0 1 1 2 2 1 2 2 3 2 3 3 2 4 3 3 3 4 3 4 3 4 4 4 4 4 4 4 4 4 4 4
0 1 1 2 1 1 2 2 2 2 2 2 2 3 3 2 2 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3
0 1 1 0 1 1 2 1 2 2 1 2 2 1 1 2 2 3 3 2 2 3 2 2 3 2 3 3 3 3 3 3
0 1 1 1 1 0 2 1 2 1 2 2 1 2 1 1 2 2 2 2 1 2 2 2 2 2 2 2 2 2 2 2
0 1 1 1 1 1 2 2 1 2 2 2 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2
0 2 1 3 2 3 3 5 3 5 4 3 4 5 6 5 5 4 6 6 6 6 5 6 6 6 6 6 6 6 6 6
0 2 1 3 2 2 3 4 3 4 4 3 3 5 5 4 4 4 5 5 5 5 5 5 5 5 5 5 5 5 5 5
0 3 2 4 3 2 5 5 5 5 6 5 4 7 6 5 6 7 7 7 6 7 7 7 7 7 7 7 7 7 7 7
0 1 1 1 0 1 2 2 1 2 2 1 1 1 2 1 2 2 2 2 2 2 2 2 1 2 2 2 2 2 2 2
0 1 2 1 1 2 3 2 2 3 3 3 3 2 3 3 3 4 4 3 3 4 4 4 4 4 4 4 4 4 4 4
0 1 1 2 1 2 2 3 2 3 3 2 3 3 4 3 3 3 4 4 4 4 4 4 4 4 4 4 4 4 4 4
0 1 2 2 2 2 3 3 3 3 4 4 3 4 4 4 4 5 4 5 4 5 5 5 5 5 5 5 5 5 5 5
0 2 3 3 2 3 5 5 4 5 6 5 5 5 6 5 6 7 7 7 6 7 7 7 7 7 7 7 7 7 7 7
0 1 2 2 1 2 3 3 2 3 3 3 3 3 4 3 3 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4
0 2 2 3 2 2 4 4 4 4 5 4 4 5 5 4 5 6 6 6 5 6 6 6 6 6 6 6 6 6 6 6
0 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 3 3 3 3 3 3 3 3 2 3 3 3 3 3 3
0 1 2 1 1 1 3 2 2 2 3 3 2 2 2 2 3 3 3 3 2 3 3 3 3 3 3 3 3 3 3 3
0 2 2 3 2 3 4 5 4 5 5 4 5 5 6 5 6 5 7 7 6 7 6 7 7 7 7 7 7 7 7 7
0 2 2 2 2 2 4 4 4 4 4 4 4 4 4 4 5 5 6 6 5 6 5 6 6 5 6 6 6 6 6 6
0 1 1 1 0 0 1 1 1 1 1 1 1 1 1 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
0 1 1 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
0 2 1 2 1 1 2 3 2 3 3 2 2 3 3 2 3 2 3 3 3 3 3 3 3 3 3 3 3 3 3 3
0 3 2 3 2 1 4 4 4 4 5 4 3 5 4 3 5 5 5 5 4 5 5 5 5 5 5 5 5 5 5 5
0 1 1 1 0 1 1 2 1 2 2 1 2 1 2 1 2 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2
0 1 2 1 0 1 2 2 1 2 2 2 2 1 2 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2
0 2 3 2 1 2 4 4 3 4 5 4 4 3 4 3 5 5 5 5 4 5 5 5 5 5 5 5 5 5 5 5
0 2 2 2 1 1 3 3 3 3 4 3 3 3 3 2 4 4 4 4 3 4 4 4 4 4 4 4 4 4 4 4
0 1 1 0 0 0 1 1 1 1 1 1 1 0 0 0 1 1 1 1 1 1 1 1 1 0 1 1 1 1 1 1
```

Their sum equals

``` console
$ !! | perl add-rays.pl
0 48 47 58 41 49 86 91 81 96 100 87 86 98 107 88 108 115 125 124 111 128 120 127 125 124 128 128 128 128 128 128
```

and the semimatroid of this polymatroid is exactly equal to our
9-element gaussoid:

``` console
$ perl -MCInet::Base -MCInet::Cube::Polyhedral -MCInet::Imset -E 'my $h = CInet::Imset->new(Cube(5)); for (split / /, shift) { state $i; $h->[++$i] = $_ }; say $h->relation' '0 48 47 58 41 49 86 91 81 96 100 87 86 98 107 88 108 115 125 124 111 128 120 127 125 124 128 128 128 128 128 128'
11111111111111111111010110101111111111101110111111110111101111110111111111111111
```

It suffices to verify the result of Dougherty-Freiling-Zeger that every one
of the above 37 rays above is multilinear over every field. Get the indices
of the rays in their file:

``` console
$ perl int-gens.pl rays.txt <<<"11111111111111111111010110101111111111101110111111110111101111110111111111111111" |
> perl -anE '/\((.*)\)/; say for split / /, $1' |
> perl reduce-gens.pl 5 |
> perl find-rays-idx.pl rays5
```

```
2 2 2 2 2 2 2 2 2 2 2 2
6 6 6 6 6 6 6 6 6 6 6 6
6 6 6 6 6 6 6 6 6 6 6 6
3 3 3 3 3 3 3 3 3 3 3 3
2 2 2 2 2 2 2 2 2 2 2 2
40 40 40 40
24 24 24 24 24 24 24 24
44 44
19 19 19 19 19 19 19 19 19 19 19 19
44 44
27 27 27 27
17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17
7 7 7 7
10 10 10 10 10 10 10 10
127 127
85
145 145
7 7 7 7
42 42 42 42
46 46
84 84
144 144
51
120 120
24 24 24 24 24 24 24 24
22 22
137
110 110
3 3 3 3 3 3 3 3 3 3 3 3
4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4
31 31
96 96
7 7 7 7
9 9 9 9 9 9
92 92
51
2 2 2 2 2 2 2 2 2 2 2 2
```

This lists for each input ray the line in the file in which it appears.
It is good that each line lists only one number. The amount of repetition
depends on the automorphism group of the semimatroid and is immaterial.
The fact that numbers are repeated on different lines means that isomorphic
semimatroids appear among the generators, which is normal.

Based on the indices, one can extract the subspace arrangements from
Dougherty-Freiling-Zeger's Matlab code. The script `check-rays.jl` contains
all these arrangements and computes their rank functions, also verifying
that each rank is obtained by a ±1 determinant (hence the same rank over
every field):

``` console
$ julia check-rays.jl | perl -ape 's/Any//; s/\[|\]//g; s/,//g' >rays-1.txt
$ cat rays5 | perl -e 'my @ind = map $_-1, @ARGV; my @lines = <STDIN>; print for @lines[@ind]' \
> 2 3 4 6 7 9 10 17 19 22 24 27 31 40 42 44 46 51 84 85 92 96 110 120 127 137 144 145 |
> perl -ape 's/^ 0 //' >rays-2.txt
$ diff -u rays-1.txt rays-2.txt
```

The output is empty. These are exactly the required rays modulo isomorphy.

# Author and License

This document is (C) 2021 by Tobias Boege <post@taboege.de>

This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License.
