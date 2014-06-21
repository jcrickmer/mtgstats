#!/usr/bin/perl

my $cards = {};

while (<STDIN>) {
	if (/^\d/ || /^SB:\d/) {
		chomp;
		my ($count, $card) = split(/\s+/, $_, 2);
		$count =~ s/SB:(\d+)/$1/gi;
		$cards->{$card} = ($cards->{$card} || 0) + $count;
	}
}

foreach my $g (keys %$cards) {
	printf('%03d %s' . "\n", $cards->{$g}, $g);
}
