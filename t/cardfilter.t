#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';
use Time::HiRes qw(gettimeofday tv_interval);
  
use Test::More tests => 14;

use Data::Dumper;

use MTG::Database;
use MTG::Card;
use MTG::Deck;
use MTG::ProbUtil;
use MTG::CardFilter;

# test 1
my $cf = MTG::CardFilter->new();
ok(defined $cf, 'Instantiation');

# test 2 - don't filter on undef
eval {
	$cf->filter();
};
ok(defined $@, 'no args 1');

# test 3 - don't filter on undef
eval {
	$cf->filter(undef);
};
ok(defined $@, 'no args 2');

# test 4 - don't filter on something that is not a deck
eval {
	my $ccc = MTG::Card->new();
	$cf->filter($ccc);
};
ok(defined $@, 'wrong args');

my $db = MTG::Database->new();

# test 5-7 - empty deck, empty response
my $deck = MTG::Deck->new($db);
my $test5 = $cf->filter($deck);
ok(defined $test5);
is(ref($test5), 'ARRAY');
is(@$test5, 0);

# test 8 - add a predicate
$cf->addPredicate('name', 'eq', 'Mountain');
my $test8 = $cf->filter($deck);
is(@$test8, 0);


### SETUP

$deck = MTG::Deck->new($db);
$deck->addCard("Harvest Pyre",2);
$deck->addCard("Mountain", 23);
$deck->addCard("Devil's Play",4);
$deck->addCard("Melt Terrain");
$deck->addCard("Balefire Dragon", 2);
$deck->addCard("Volcanic Dragon", 2);
$deck->addCard("Whipflare", 2);
$deck->addCard("Gorehorn Minotaurs",2);
$deck->addCard("Stormblood Berserker",2);
$deck->addCard("Fireball",3);
$deck->addCard("Shock",2);
$deck->addCard("Tectonic Rift",2);
$deck->addCard("Goblin Fireslinger",4);
$deck->addCard("Circle of Flame",2);
$deck->addCard("Slagstorm");
$deck->addCard("Past in Flames");
$deck->addCard("Traitorous Blood",2);
$deck->addCard("Rolling Tremblor",1);
$deck->addCard("Geosurge",2);

# test 9 - valid 1 eq predicate, with cards
my $test9 = $cf->filter($deck);
is(@$test9, 23);

# test 10 - valid 1 > predicate, with cards
$cf = MTG::CardFilter->new();
$cf->addPredicate('CMC', '>', 5);
my $test10 = $cf->filter($deck);
is(@$test10, 4);

# test 11 - valid 1 ne predicate, with cards
$cf = MTG::CardFilter->new();
$cf->addPredicate('type', 'ne', 'Land');
my $test11 = $cf->filter($deck);
is(@$test11, 37);

# test 12 - valid 2 predicates, with cards
$cf = MTG::CardFilter->new();
$cf->addPredicate('type', 'eq', 'Creature');
$cf->addPredicate('CMC', '<=', 3);
my $test12 = $cf->filter($deck);
is(@$test12, 6);

# test 13 - filter tags, with cards
$cf = MTG::CardFilter->new();
$cf->addPredicate('tags', '=~', 'target');
my $test13 = $cf->filter($deck);
is(@$test13, 18);

#test 14 - no lands, spells <= 2 CMC
$cf = MTG::CardFilter->new();
$cf->addPredicate('type', 'ne', 'Land');
$cf->addPredicate('CMC', '<=', 2);
my $test14 = $cf->filter($deck);
is(@$test14, 21);

