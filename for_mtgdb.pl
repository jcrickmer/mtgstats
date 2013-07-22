#!/usr/bin/perl

use strict;
use utf8;

use Data::Dumper;

use MTG::Card;
use MTG::Deck;
use MTG::Database;
use MTG::Util qw(trim html2Plain);

use MTG::GathererLoader;

use DBI;

my $loader = MTG::GathererLoader->new(undef);

my $res = $loader->readCardDir(*STDOUT);
#my $filename = "card_html/Rampant_Growth.html";
#my $filename = "card_html/Animar__Soul_of_Elements.html";
#my $filename = "card_html/Garruk_Wildspeaker.html";
#my $res = $loader->readCard($filename, *STDOUT);

my $dbh = DBI->connect('DBI:mysql:mtgdb','mtgdb','password') || die "Could not connect to database: $DBI::errstr";
$dbh->{'mysql_enable_utf8'} = 1;
$dbh->do(qq{SET NAMES 'utf8';});

foreach my $fkey (keys %$res) {
    my $card = $res->{$fkey}->{card};
    print "+++++++++ thinking about \"" . $card->{name} . "\"\n";
    if ($card->{name} eq undef) {
	print Dumper($res->{$fkey});
    }
    if (1) {
# now that we have a card, we need to see if we have everything we need to insert it, if we don't already have it.
# Check:
#   1. expansion set
#   2. type
#   3. subtype
#   4. base card
#   5. card

my $rarity_id = undef;
{
    my $testSQL = "SELECT id FROM rarities WHERE rarity = " . $dbh->quote($card->{rarity}) . ";";
    my @row  = $dbh->selectrow_array($testSQL);
    if (@row == 0) {
	my $insertSQL = 'INSERT INTO rarities (rarity) VALUES (' . $dbh->quote($card->{rarity}) . ');';
	$dbh->do($insertSQL);
	@row = $dbh->selectrow_array($testSQL);
    }
    $rarity_id = $row[0];
}

my $expansionset_id = undef;
{
    my $testSQL = "SELECT id FROM expansionsets WHERE name = " . $dbh->quote($card->{expansion}) . ";";
    my @row  = $dbh->selectrow_array($testSQL);
    if (@row == 0) {
	my $insertSQL = 'INSERT INTO expansionsets (name) VALUES (' . $dbh->quote($card->{expansion}) . ');';
	$dbh->do($insertSQL);
	@row = $dbh->selectrow_array($testSQL);
    }
    $expansionset_id = $row[0];
}

my @type_ids = ();
foreach my $ctype (@{$card->{types}}) {
    my $testSQL = 'SELECT id FROM types WHERE type = ' . $dbh->quote($ctype) . ';';
    my @row  = $dbh->selectrow_array($testSQL);
    if (@row == 0) {
	my $insertSQL = 'INSERT INTO types (type) VALUES (' . $dbh->quote($ctype) . ');';
	$dbh->do($insertSQL);
	@row = $dbh->selectrow_array($testSQL);
    }
    push @type_ids, $row[0];
}
print Dumper(\@type_ids);

my @subtype_ids = ();
foreach my $csubtype (@{$card->{subtype}}) {
    my $testSQL = 'SELECT id FROM subtypes WHERE subtype = ' . $dbh->quote($csubtype) . ';';
    my @row  = $dbh->selectrow_array($testSQL);
    if (@row == 0) {
	my $insertSQL = 'INSERT INTO subtypes (subtype) VALUES (' . $dbh->quote($csubtype) . ');';
	$dbh->do($insertSQL);
	@row = $dbh->selectrow_array($testSQL);
    }
    push @subtype_ids, $row[0];
}
print Dumper(\@subtype_ids);

my $basecard_id = undef;
{ #basecard
    my $testSQL = 'SELECT id FROM basecards WHERE name = ' . $dbh->quote($card->{name}) . ';';
    my @row  = $dbh->selectrow_array($testSQL);
    if (@row == 0) {
	my $insertSQL = 'INSERT INTO basecards (name, rules_text, mana_cost, cmc, power, toughness, loyalty) VALUES (?, ?, ?, ?, ?, ?, ?)';
	my $sth = $dbh->prepare($insertSQL);
	$sth->execute($card->{name}, 
		      $card->{card_text},
		      join('', @{$card->{truecost}}),
		      $card->{CMC}, 
		      $card->{power},
		      $card->{toughness},
		      $card->{loyalty});
	@row = $dbh->selectrow_array($testSQL);
    }
    $basecard_id = $row[0];
}
print "Basecard id = $basecard_id\n";

{
    my $testSQL = 'SELECT multiverseid FROM cards WHERE multiverseid = ' . $card->{spec_multiverseid} . ';';
    my @row  = $dbh->selectrow_array($testSQL);
    if (@row == 0) {
	my $insertSQL = 'INSERT INTO cards (expansionset_id, basecard_id, rarity, multiverseid, flavor_text, card_number) VALUES (?, ?, ?, ?, ?, ?)';
	my $sth = $dbh->prepare($insertSQL);
	$sth->execute($expansionset_id,
		      $basecard_id,
		      $rarity_id,
		      $card->{spec_multiverseid}, 
		      $card->{flavor_text},
		      $card->{expansion_card_number});
	@row = $dbh->selectrow_array($testSQL);
    }
    print "I got it!  " . $row[0] . "\n";
}

for (my $pp = 0; $pp < @type_ids; $pp++) {
    my $insertSQL = 'INSERT INTO cardtypes (basecard_id, type_id, position) VALUES (?, ?, ?)';
    my $sth = $dbh->prepare($insertSQL);
    # I am ok with trying to do dup entries here.  MySQL will get over it... 
    $sth->execute($basecard_id,
		  $type_ids[$pp],
		  $pp);
}

for (my $pp = 0; $pp < @subtype_ids; $pp++) {
    my $insertSQL = 'INSERT INTO cardsubtypes (basecard_id, subtype_id, position) VALUES (?, ?, ?)';
    my $sth = $dbh->prepare($insertSQL);
    # I am ok with trying to do dup entries here.  MySQL will get over it... 
    $sth->execute($basecard_id,
		  $subtype_ids[$pp],
		  $pp);
}

{ #cardcolors
    foreach my $ccc (@{$card->{truecost}}) {
	$ccc =~ /z(zzzz)zz/;
	$ccc =~ /\{([wWuUbBrRgG])/;  # REVISIT - Hybrid mana cards!
	if ('w' eq lc($1)
	    || 'u' eq lc($1)
	    || 'b' eq lc($1)
	    || 'r' eq lc($1)
	    || 'g' eq lc($1)
	   ) {
	    # I am ok with trying to do dup entries here.  MySQL will get over it... 
	    #INSERT INTO cardcolors (basecard_id, color_id) VALUES (6, 'B');
	    my $insertSQL = 'INSERT INTO cardcolors (basecard_id, color_id) VALUES (?, ?)';
	    my $sth = $dbh->prepare($insertSQL);
	    $sth->execute($basecard_id,
			  uc($1));
	}
    }
}
}
}
