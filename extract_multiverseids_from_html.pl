#!/usr/bin/perl

while (<STDIN>) { # list of file names
	chomp;
	open(F, "<$_") || die ("blah.");
	while (<F>) {
		@parts = split(/&/, $_);
		foreach my $part (@parts) {
			if ($part =~ /multiverseid=(\d+)/gi) {
				print "" . $1 . "\n";
			}
		}
	}
	close F;
}
