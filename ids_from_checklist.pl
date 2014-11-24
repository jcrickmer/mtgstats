#!/usr/bin/perl

$/ = '"';

while (<STDIN>) {
    if (/multiverseid=(\d+)/) {
	print $1;
	print "\n";
    }
}
