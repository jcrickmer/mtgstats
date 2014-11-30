#!/usr/bin/perl

use strict;

use URI::Escape;
use Time::HiRes qw( usleep ualarm gettimeofday tv_interval nanosleep
                    clock_gettime clock_getres clock_nanosleep clock
                    stat );

my $agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_5_8) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/15.0.874.121 Safari/535.2';

my @multiverseids;
while (<STDIN>) { # read ids from STDIN
    chomp;
    if (/^\d+$/) {
	push @multiverseids, $_;
    }
}
my $stopper = 0;
foreach my $id (@multiverseids) {
    my $iurl = 'http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=' . $id . '&type=card';
    my $rurl = 'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=' . $id;
    my $cmd = 'curl -s -L -A ' . "'" . $agent . "' --referer '" . $rurl . "' '" . $iurl . "' > card_images/" . $id . '.jpg';
    if (! -e 'card_images/' . $id . '.jpg' || -s 'card_images/' . $id . '.jpg' < 100) {
		printf("%d (%03.2f%% - %d of %d)\n", $id, 100.0 * $stopper / (1.0 * scalar(@multiverseids)), $stopper, scalar(@multiverseids));
		#print "$cmd\n";
		`$cmd`;
		#usleep(7000000 + (rand() * 5000000)); # 7-12 seconds, nice and slow
		usleep(100000 + (rand() * 500000)); # fast!
    } else {
		print "skipping $id - I already have it.\n";
    }
    $stopper++;
    #last if ($stopper > 10);
}
