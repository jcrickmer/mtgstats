#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';
use Time::HiRes qw(gettimeofday tv_interval);

use MTG::ProbUtil;

use Data::Dumper;

my $pu = MTG::ProbUtil->new();

my $htmlOutput = 1;

my $cardCount = 99;
my $drawCount = 8;

if (! $htmlOutput) {
    print "card count,";
    for (my $y = 0; $y < ($drawCount + 1); $y++) { # number of chances?
	print $y . ',';
    }
    print "\n";
    
    for (my $cardNumber = 1; $cardNumber < ($cardCount / 2); $cardNumber++) {
	print $cardNumber . ',';
	for (my $y = 0; $y < ($drawCount+1); $y++) { # number of chances?
	    print $pu->probability($cardNumber, $cardCount, $y, $drawCount), ',';
	}
	print "\n";
    }
} else {
    print "<table>\n";
    print "<caption>Probabilities for drawing <i>x</i> number of cards in the next $drawCount cards when <i>y</i> cards are present in the deck.</caption>\n";
    print "<thead>\n";
    print "<tr>\n";
    print '<th rowspan="2">Number of Specific Card in the Deck</th>';
    print '<th colspan="' . ($drawCount + 1) . '">% Probability for Number of Cards Drawn</th>';
    print "</tr>\n";
    print "<tr>\n";
    for (my $y = 0; $y < ($drawCount + 1); $y++) { # number of chances?
	print '<th>' . $y . '</th>';
    }
    print "</tr>\n";
    print "<thead>\n";
    print "<tbody>\n";
    
    for (my $cardNumber = 1; $cardNumber < ($cardCount / 2); $cardNumber++) {
	print '<tr><td>' . $cardNumber . '</td>';
	for (my $y = 0; $y < ($drawCount + 1); $y++) { # number of chances?
	    my $prob = (100* $pu->probability($cardNumber, $cardCount, $y, $drawCount));
	    if ($prob == 0.0) {
		print '<td>-</td>';
	    } else {
		print '<td>' . sprintf("%.2f", (100* $pu->probability($cardNumber, $cardCount, $y, $drawCount))) .  '%</td>';
	    }
	}
	print "</tr>\n";
    }
    print "</tbody>\n";
    print "</table>\n";
}

