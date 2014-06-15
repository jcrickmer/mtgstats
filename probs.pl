#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';
use Time::HiRes qw(gettimeofday tv_interval);

use MTG::ProbUtil;

use Data::Dumper;

my $pu = MTG::ProbUtil->new();

my $cardCount = 60;
for (my $cardNumber = 1; $cardNumber < 26; $cardNumber++) {
    for (my $y = 0; $y < 8; $y++) { # number of chances?
	print $pu->probability($cardNumber, $cardCount, $y, 7), ",";
    }
    print "\n";
}
