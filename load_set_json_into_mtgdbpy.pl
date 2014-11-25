#!/usr/bin/perl -CS

use strict;
use utf8;
#use diagnostics;
use JSON::XS;
use DBI;

my $dbh = DBI->connect('DBI:mysql:mtgdbpy','mtgdb','password', {RaiseError=>1, PrintError=>0}) || die "Could not connect to database: $DBI::errstr";
$dbh->{'mysql_enable_utf8'} = 1;
$dbh->do(qq{SET NAMES 'utf8';});

my $filename = $ARGV[0];
my $fix = $ARGV[1]; # should I do things in the database?

#open(my $fh, "<:encoding(UTF-8)", $filename)
open(my $fh, "<", $filename)
    || die "can't open UTF-8 encoded file \"$filename\": $!";

my $json_string = do { local $/; <$fh> };

my $sets_hash = JSON::XS->new->utf8->decode($json_string);

foreach my $set (keys %$sets_hash) {
	print $set, ":: ";
	{
		my $setName = $sets_hash->{$set}->{name};
		my $testSQL = "SELECT id, name, abbr FROM expansionsets WHERE abbr = ? OR name = ?;";
		my $sth = $dbh->prepare($testSQL);
		$sth->execute($set, $setName);
		my ($id, $name, $abbr) = $sth->fetchrow_array()	and $sth->finish();
		if (! defined $id) {
			print "missing!";
			if ($fix) {
				eval {
					my $insertSQL = 'INSERT INTO expansionsets (name, abbr) VALUES (?, ?)';
					my $sth = $dbh->prepare($insertSQL);
					$sth->execute($setName, $set);
				};
				if ($@) {
					print "\n";
					die("Unable to insert expansionset: " . $@);
				} else {
					my $db_id = $dbh->{mysql_insertid};
					print " added as id=$db_id\n";
				}
			} else {
				print " ignored...\n";
			}
		} else {
			my $prob = undef;
			if ($setName ne $name) {
				$prob = 1;
				print "!! name mismatch json=\"" . $setName . "\", db=\"$name\"";
			}
			if ($set ne $abbr) {
				$prob = 1;
				print "!! abbr for name \"$name\" mismatch json=\"" . $set . "\", db=\"$abbr\"";
			}
			if ($prob) {
				if ($fix) {
					eval {
						my $updateSQL = 'UPDATE expansionsets SET name = ?, abbr = ? WHERE id = ?';
						my $sth = $dbh->prepare($updateSQL);
						$sth->execute($setName, $set, $id);
					};
					if ($@) {
						print "\n";
						die("Unable to update expansionset: " . $@);
					} else {
						my $db_id = $dbh->{mysql_insertid};
						print " updated id $id\n";
					}
				} else {
					print " ignored...\n";
				}
			} else {
				print "ok\n";
			}
		}
	}
	if ($set eq "RTR") {
		foreach my $n (keys %{$sets_hash->{$set}}) {
			print "-> ", $n, "\n";
		}
	}
}
