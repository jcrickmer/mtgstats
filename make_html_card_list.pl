#!/usr/bin/perl

use strict;
use utf8;

use Data::Dumper;

use DBI;

my $dbh = DBI->connect('DBI:mysql:mtgdbpy','mtgdb','password', {RaiseError=>1, PrintError=>0}) || die "Could not connect to database: $DBI::errstr";
$dbh->{'mysql_enable_utf8'} = 1;
$dbh->do(qq{SET NAMES 'utf8';});

while (<STDIN>) {
	chomp;
	my $testSQL = "SELECT bc.id, c.multiverseid, bc.name FROM basecards AS bc, cards AS c, cardtypes AS ct WHERE c.basecard_id = bc.id AND bc.id = ct.basecard_id AND ct.type_id = 6 AND bc.name = ? ORDER BY c.multiverseid DESC";
	my $sth = $dbh->prepare($testSQL);
	$sth->execute($_);
	my $cards_aref = $sth->fetchall_arrayref();
	if (@$cards_aref) {
		my $card = $cards_aref->[0];
		print '<li><a class="card_name" href="/cards/' . $card->[1] . '/" onmouseover="cn.updateCard(\'cardarea\', ' . $card->[1] . ');">' . $card->[2] . "</a></li>\n";
	}
}
