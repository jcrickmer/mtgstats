#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';
use Time::HiRes qw(gettimeofday tv_interval);
  
use Test::More tests => 52;

use MTG::ProbUtil;

use Data::Dumper;


my $pu = MTG::ProbUtil->new();
ok(defined $pu, 'ProbUtil exists.');                # check that we got something

# factorial
is($pu->factorial(0), 1, "0!");
is($pu->factorial(1), 1, "1!");
is($pu->factorial(2), 2, "2!");
is($pu->factorial(3), 6, "3!");
is($pu->factorial(4), 24, "4!");
is($pu->factorial(5), 120, "5!");
is($pu->factorial(66), 5.44344939077443e+92, "66!");

# combination
is($pu->choose(0,0),1, "C(0,0)");
is($pu->choose(0,1),1, "C(0,1)");
is($pu->choose(0,2),1, "C(0,2)");
is($pu->choose(0,9),1, "C(0,9)");

is($pu->choose(1,0),0, "C(1,0)");
is($pu->choose(1,1),1, "C(1,1)");
is($pu->choose(1,2),2, "C(1,2)");
is($pu->choose(1,3),3, "C(1,3)");
is($pu->choose(1,9),9, "C(1,9)");

is($pu->choose(7,0),0, "C(7,0)");
is($pu->choose(7,1),0, "C(7,1)");
is($pu->choose(7,2),0, "C(7,2)");

is($pu->choose(7,7),1, "C(7,7)");
is($pu->choose(7,9),36, "C(7,9)");
is($pu->choose(7,60),386206920, "C(7,60)");

is($pu->choose(34,112),5.90586340548099e+28, "C(34,112)");

# probability

my $redCount = 2;
my $cardCount = 4;
cmp_ok($pu->probability($redCount, $cardCount, 0, 1), '==', 0.5, '(2 in 4) pull 0 in 1 chance');
cmp_ok($pu->probability($redCount, $cardCount, 0, 2), '==', 1/6, '(2 in 4) pull 0 in 2 chances');
cmp_ok($pu->probability($redCount, $cardCount, 0, 3), '==', 0, '(2 in 4) pull 0 in 3 chances');
cmp_ok($pu->probability($redCount, $cardCount, 1, 1), '==', 0.5, '(2 in 4) pull 1 in 1 chance');
cmp_ok($pu->probability($redCount, $cardCount, 1, 2), '==', 2/3, '(2 in 4) pull 1 in 2 chances');
cmp_ok($pu->probability($redCount, $cardCount, 1, 3), '==', 0.5, '(2 in 4) pull 1 in 3 chances');
cmp_ok($pu->probability($redCount, $cardCount, 1, 4), '==', 0, '(2 in 4) pull 1 in 4 chances');
cmp_ok($pu->probability($redCount, $cardCount, 2, 1), '==', 0, '(2 in 4) pull 2 in 1 chance');
cmp_ok($pu->probability($redCount, $cardCount, 2, 2), '==', 1/6, '(2 in 4) pull 2 in 2 chances');
cmp_ok($pu->probability($redCount, $cardCount, 2, 3), '==', 0.5, '(2 in 4) pull 2 in 3 chances');
cmp_ok($pu->probability($redCount, $cardCount, 2, 4), '==', 1, '(2 in 4) pull 2 in 4 chance');
cmp_ok($pu->probability($redCount, $cardCount, 3, 4), '==', 0, '(2 in 4) pull 3 in 4 chance');



$redCount = 2;
$cardCount = 5;
cmp_ok($pu->probability($redCount, $cardCount, 0, 1), '==', 0.6, '(2 in 5) pull 0 in 1 chance');
cmp_ok($pu->probability($redCount, $cardCount, 0, 2), '==', 0.3, '(2 in 5) pull 0 in 2 chances');
cmp_ok($pu->probability($redCount, $cardCount, 0, 3), '==', 0.1, '(2 in 5) pull 0 in 3 chances');
cmp_ok($pu->probability($redCount, $cardCount, 0, 4), '==', 0, '(2 in 5) pull 0 in 4 chances');
cmp_ok($pu->probability($redCount, $cardCount, 0, 5), '==', 0, '(2 in 5) pull 0 in 5 chances');
cmp_ok($pu->probability($redCount, $cardCount, 1, 1), '==', 0.4, '(2 in 5) pull 1 in 1 chance');
cmp_ok($pu->probability($redCount, $cardCount, 1, 2), '==', 0.6, '(2 in 5) pull 1 in 2 chances');
cmp_ok($pu->probability($redCount, $cardCount, 1, 3), '==', 0.6, '(2 in 5) pull 1 in 3 chances');
cmp_ok($pu->probability($redCount, $cardCount, 1, 4), '==', 0.4, '(2 in 5) pull 1 in 4 chances');
cmp_ok($pu->probability($redCount, $cardCount, 1, 5), '==', 0, '(2 in 5) pull 1 in 5 chances');
cmp_ok($pu->probability($redCount, $cardCount, 2, 1), '==', 0, '(2 in 5) pull 2 in 1 chance');
cmp_ok($pu->probability($redCount, $cardCount, 2, 2), '==', 0.1, '(2 in 5) pull 2 in 2 chances');
cmp_ok($pu->probability($redCount, $cardCount, 2, 3), '==', 0.3, '(2 in 5) pull 2 in 3 chances');
cmp_ok($pu->probability($redCount, $cardCount, 2, 4), '==', 0.6, '(2 in 5) pull 2 in 4 chance');
cmp_ok($pu->probability($redCount, $cardCount, 2, 5), '==', 1, '(2 in 5) pull 2 in 5 chance');
cmp_ok($pu->probability($redCount, $cardCount, 3, 4), '==', 0, '(2 in 5) pull 3 in 4 chance');
