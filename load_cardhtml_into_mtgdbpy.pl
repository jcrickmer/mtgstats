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
#my $filename = "card_html/370738.html";
#my $res = $loader->readCard('card_html/253606.html', *STDOUT);


my $dbh = DBI->connect('DBI:mysql:mtgdbpy','mtgdb','password') || die "Could not connect to database: $DBI::errstr";
$dbh->{'mysql_enable_utf8'} = 1;
$dbh->do(qq{SET NAMES 'utf8';});

my $rarities_hash;
{
    my $testSQL = "SELECT id, rarity FROM rarities;";
    my $sth = $dbh->prepare($testSQL);
    $sth->execute;
    $rarities_hash = $sth->fetchall_hashref('rarity');
}

my $expsets_hash;
{
    my $testSQL = "SELECT id, name, abbr FROM expansionsets;";
    my $sth = $dbh->prepare($testSQL);
    $sth->execute;
    $expsets_hash = $sth->fetchall_hashref('name');
}
#print Dumper($expsets_hash);

my $colors_hash;
{
    my $testSQL = "SELECT id, color FROM colors;";
    my $sth = $dbh->prepare($testSQL);
    $sth->execute;
    $colors_hash = $sth->fetchall_hashref('color');
}

my $marks_hash;
{
    my $testSQL = "SELECT id, mark FROM marks;";
    my $sth = $dbh->prepare($testSQL);
    $sth->execute;
    $marks_hash = $sth->fetchall_hashref('mark');
}

my $types_hash;
{
    my $testSQL = 'SELECT id, type FROM types;';
    my $sth = $dbh->prepare($testSQL);
    $sth->execute;
    $types_hash = $sth->fetchall_hashref('type');
}

my $subtypes_hash;
{
    my $testSQL = 'SELECT id, subtype FROM subtypes;';
    my $sth = $dbh->prepare($testSQL);
    $sth->execute;
    $subtypes_hash = $sth->fetchall_hashref('subtype');
}


foreach my $fkey (keys %$res) {
    my $card = $res->{$fkey}->{card};
    print "+++++++++ thinking about \"" . $card->{name} . "\"\n";
    #print Dumper($card);
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

my $mark_id = $marks_hash->{$card->{watermark}}->{id};
my $rarity_id = $rarities_hash->{$card->{rarity}}->{id};
my $expansionset_id = $expsets_hash->{$card->{expansion}}->{id};

my @type_ids;
foreach my $tn (@{$card->{types}}) {
    push @type_ids, $types_hash->{$tn}->{id};
}

my @subtype_ids;
foreach my $stn (@{$card->{subtype}}) {
    push @subtype_ids, $subtypes_hash->{$stn}->{id};
}

my $anyCount = 0;
foreach my $symb (@{$card->{cost}}) {
    if ($symb eq 'any') {
	$anyCount++;
    }
}

my @cardColors;
foreach my $ccc (@{$card->{truecost}}) {
    if ($ccc =~ /[wW]/) {
	push (@cardColors, 'W') if (! grep $_ eq 'W', @cardColors);
    }
    if ($ccc =~ /[uU]/) {
	push (@cardColors, 'U') if (! grep $_ eq 'U', @cardColors);
    }
    if ($ccc =~ /[bB]/) {
	push (@cardColors, 'B') if (! grep $_ eq 'B', @cardColors);
    }
    if ($ccc =~ /[rR]/) {
	push (@cardColors, 'R') if (! grep $_ eq 'R', @cardColors);
    }
    if ($ccc =~ /[gG]/) {
	push (@cardColors, 'G') if (! grep $_ eq 'G', @cardColors);
    }
}

# print "\nBASE CARD\n";
# print "name: " . $card->{name} . "\n";
# print "rules_text (card_text): " . $card->{card_text} . "\n";
# print "mana_cost: " . join("", @{$card->{truecost}}) . "\n";
# print "cmc: " . $card->{CMC} . "\n";
# print "power: " . $card->{power} . "\n";
# print "toughness: " . $card->{toughness} . "\n";
# print "loyalty: " . $card->{loyalty} . "\n";

# print "\nCARDCOLORS\n";
# print "cardcolors: " . join(",", @cardColors) . "\n";

# print "\nCARDTYPES\n";
# print "types: " . join(" ", @{$card->{types}}) . " => [" . join(",", @type_ids) . "]\n";
# print "\nCARDSUBTYPES\n";
# print "subtypes: " . join(" ", @{$card->{subtype}}) . " => [" . join(",", @subtype_ids) . "]\n";

# print "\nCARD\n";
# print "expansion: '" . $card->{expansion} . "' => " . $expansionset_id . "\n";
# print "rarity: " . $card->{rarity} . " => " .$rarity_id . "\n";
# print "multiverseid: " . $card->{spec_multiverseid} . "\n"; # we could iterate here with "multiverseid", but then it is not specific to the card.
# print "flavor_text: " . $card->{flavor_text} . "\n";
# print "card_number: " . $card->{expansion_card_number} . "\n";
# print "mark: " . $card->{watermark} . " => " . $mark_id . "\n";


### might come back to this - adding types and subtypes that the database does not know about
# my @type_ids;
# foreach my $ctype (@{$card->{types}}) {
#     my $testSQL = 'SELECT id FROM types WHERE type = ' . $dbh->quote($ctype) . ';';
#     my @row  = $dbh->selectrow_array($testSQL);
#     if (@row == 0) {
# 	my $insertSQL = 'INSERT INTO types (type) VALUES (' . $dbh->quote($ctype) . ');';
# 	$dbh->do($insertSQL);
# 	@row = $dbh->selectrow_array($testSQL);
#     }
#     push @type_ids, $row[0];
# }
# print Dumper(\@type_ids);

# my @subtype_ids = ();
# foreach my $csubtype (@{$card->{subtype}}) {
#     my $testSQL = 'SELECT id FROM subtypes WHERE subtype = ' . $dbh->quote($csubtype) . ';';
#     my @row  = $dbh->selectrow_array($testSQL);
#     if (@row == 0) {
# 	my $insertSQL = 'INSERT INTO subtypes (subtype) VALUES (' . $dbh->quote($csubtype) . ');';
# 	$dbh->do($insertSQL);
# 	@row = $dbh->selectrow_array($testSQL);
#     }
#     push @subtype_ids, $row[0];
# }
# print Dumper(\@subtype_ids);


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
	print "Inserted basecard for " . $card->{name} . "\n";
	@row = $dbh->selectrow_array($testSQL);
    }
    $basecard_id = $row[0];
}
print "Basecard id = $basecard_id\n";

{ #cardcolors
    foreach my $ccc (@cardColors) {
	# I am ok with trying to do dup entries here.  MySQL will get over it... 
	#INSERT INTO cardcolors (basecard_id, color_id) VALUES (6, 'B');
	eval {
	    my $insertSQL = 'INSERT INTO cardcolors (basecard_id, color_id) VALUES (?, ?)';
	    my $sth = $dbh->prepare($insertSQL);
	    $sth->execute($basecard_id, $ccc);
	}
    }
}

{ # types
    for (my $pp = 0; $pp < @type_ids; $pp++) {
	my $insertSQL = 'INSERT INTO cardtypes (basecard_id, type_id, position) VALUES (?, ?, ?)';
	my $sth = $dbh->prepare($insertSQL);
	# I am ok with trying to do dup entries here.  MySQL will get over it... 
	$sth->execute($basecard_id,
		      $type_ids[$pp],
		      $pp);
    }
}

{ # subtypes
    for (my $pp = 0; $pp < @subtype_ids; $pp++) {
	my $insertSQL = 'INSERT INTO cardsubtypes (basecard_id, subtype_id, position) VALUES (?, ?, ?)';
	my $sth = $dbh->prepare($insertSQL);
	# I am ok with trying to do dup entries here.  MySQL will get over it... 
	$sth->execute($basecard_id,
		      $subtype_ids[$pp],
		      $pp);
    }
}

my $cardId = undef;
{ #card
    my $testSQL = 'SELECT id FROM cards WHERE multiverseid = ' . $card->{spec_multiverseid} . ';';
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
	print "Inserted card for \"" . $card->{name} . "\" in \"" . $card->{expansion} . "\"\n";
	@row = $dbh->selectrow_array($testSQL);
    }
    $cardId = $row[0];
    print "Card Id is " . $cardId . "\n";
}

    }
}
