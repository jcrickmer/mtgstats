#!/usr/bin/perl

use strict;
use utf8;

use Data::Dumper;

use MTG::Card;
use MTG::Deck;
use MTG::Util qw(trim html2Plain);

use DBI;

my @existingCards;
open(IN, '</home/jason/cards.xml') || die ("Cannot open existing cards database");
while(<IN>) {
    if (/<name>([^<]+)</) {
	push @existingCards, $1;
    }
}
close IN;

my $dbh = DBI->connect('DBI:mysql:mtgdb','mtgdb','password') || die "Could not connect to database: $DBI::errstr";
$dbh->{'mysql_enable_utf8'} = 1;
$dbh->do(qq{SET NAMES 'utf8';});

my $sql = qq{SELECT basecards.name, basecards.mana_cost, cards.multiverseid, basecards.rules_text, exp.abbr, basecards.power, basecards.toughness, t0.type AS type0, t1.type AS type1, t2.type AS type2, st0.subtype AS subtype0, st1.subtype AS subtype1, st2.subtype AS subtype2, basecards.id
FROM basecards 
JOIN cards ON basecards.id = cards.basecard_id
JOIN expansionsets AS exp ON cards.expansionset_id = exp.id
JOIN cardtypes AS ct0 ON basecards.id = ct0.basecard_id AND ct0.position = 0
JOIN types AS t0 ON ct0.type_id = t0.id
LEFT JOIN cardtypes AS ct1 ON basecards.id = ct1.basecard_id AND ct1.position = 1
LEFT JOIN types AS t1 ON ct1.type_id = t1.id
LEFT JOIN cardtypes AS ct2 ON basecards.id = ct2.basecard_id AND ct2.position = 2
LEFT JOIN types AS t2 ON ct2.type_id = t2.id
LEFT JOIN cardsubtypes AS cst0 ON basecards.id = cst0.basecard_id AND cst0.position = 0
LEFT JOIN subtypes AS st0 ON cst0.subtype_id = st0.id
LEFT JOIN cardsubtypes AS cst1 ON basecards.id = cst1.basecard_id AND cst1.position = 1
LEFT JOIN subtypes AS st1 ON cst1.subtype_id = st1.id
LEFT JOIN cardsubtypes AS cst2 ON basecards.id = cst2.basecard_id AND cst2.position = 2
LEFT JOIN subtypes AS st2 ON cst2.subtype_id = st2.id
WHERE exp.id = 52;
};

my $cards = $dbh->selectall_arrayref($sql);

my $example = qq{  <card>
            <name>Devoted Retainer</name>
            <set picURL="http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=50440&amp;type=card" picURLHq="" picURLSt="">CHK</set>
            <color>W</color>
            <manacost>W</manacost>
            <type>Creature - Human Samurai</type>
            <pt>1/1</pt>
            <tablerow>2</tablerow>
            <text>Bushido 1 (When this blocks or becomes blocked, it gets +1/+1 until end of turn.)</text>
        </card>
};

foreach my $card (@$cards) {
    if (grep {$_ eq $card->[0]} @existingCards) {
    } else {
    print "  <card>\n";
    print "    <name>" . $card->[0] . "</name>\n";
    print "    <set picURL=\"http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=" . $card->[2] . '&amp;type=card" picURKHq="" picURLSt="">' . $card->[4] . "</set>\n";
    my $colors_aref = $dbh->selectall_arrayref("SELECT color_id FROM cardcolors WHERE basecard_id = " . $card->[13]);
    foreach my $color (@$colors_aref) {
	print "    <color>" . $color->[0] . "</color>\n";
    }
    my $cost = $card->[1];
    $cost =~ s/\{(.)\}/$1/gi;
    $cost =~ s/\{(..)\}/($1)/gi;
    $cost =~ s/\{(...)\}/($1)/gi;
    print "    <manacost>" . uc($cost) . "</manacost>\n";
    print "    <type>";
    print $card->[7];
    if ($card->[8]) { print " " . $card->[8]; }
    if ($card->[9]) { print " " . $card->[9]; }
    if ($card->[10]) { print " - " . $card->[10]; }
    if ($card->[11]) { print " " . $card->[11]; }
    if ($card->[12]) { print " " . $card->[12]; }
    print "</type>\n";
    if ($card->[7] eq 'Creature' || $card->[8] eq 'Creature' || $card->[9] eq 'Creature') {
	print "    <pt>" . $card->[5] . '/' . $card->[6] . "</pt>\n"
    }
    my $text = $card->[3];
    $text =~ s/<[\/]i>//gi;
    $text =~ s/&/&amp;/gi;
    $text =~ s/</&lt;/gi;
    print "    <text>" . $text . "</text>\n";
    print "  </card>\n";
    }
}
