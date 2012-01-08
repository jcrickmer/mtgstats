#!/usr/bin/perl

use strict;
use Data::Dumper;
use MTG::Database;
use MTG::Card;
use MTG::Deck;
use MTG::ProbUtil;
use MTG::CardFilter;

my $pu = MTG::ProbUtil->new();
if (1) {
my $db = MTG::Database->new();

my $deck = MTG::Deck->new($db);
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
$deck->setOwnerId(1);
$deck->setName("Jason Red Punishment");
$deck->setFormat("Standard");
#$db->insertDeck($deck);
my $ttt = $deck->getTags();
#print Dumper($ttt);
#exit;

print "card count: " . $deck->cardCount() . "\n";
print "first card: " . $deck->getCard(0)->getName() . "\n";
print "shuffle... and first 10 after shuffle:\n";
$deck->shuffle();
for (my $i = 0; $i < 10; $i++) {
	my $card = $deck->getCard($i);
	printf("%2d:  %s %f\n", $i, $card->getName(), $card->{_place});
}
print "---------------\n";
print "card count: " . $deck->cardCount() . "\n";
print "first card: " . $deck->getCard(0)->getName() . "\n";
print "shuffle... and first 10 after shuffle:\n";
$deck->shuffle();
for (my $i = 0; $i < 10; $i++) {
	my $card = $deck->getCard($i);
	printf("%2d:  %s %f\n", $i, $card->getName(), $card->{_place});
}
print "---------------\n";
print "card count: " . $deck->cardCount() . "\n";
print "first card: " . $deck->getCard(0)->getName() . "\n";
print "shuffle... and first 10 after shuffle:\n";
$deck->shuffle();
for (my $i = 0; $i < 10; $i++) {
	my $card = $deck->getCard($i);
	printf("%2d:  %s %f\n", $i, $card->getName(), $card->{_place});
}
print "---------------\n";
#print Dumper($deck->{cards});


print "Mana probability in first 7 cards:\n";
print "  white: " . "\n";
print "  green: " . "\n";
print "  red: " . "\n";
print "  black: " . "\n";
print "  blue: " . "\n";
print "  colorless: " . "\n";

my $lands_a = $deck->cardsByType('Land');
foreach my $ll (@$lands_a) {
	print $ll->TO_JSON() . "\n";
}

}
#my $landCount = scalar(@$lands_a);
#my $deckCount = $deck->cardCount();
my $landCount = 8;
my $deckCount = 45;

for (my $w = 0; $w < 8; $w++) {
	my $nn = $pu->probability($landCount, $deckCount, $w, 7);
	printf("$w lands in 7: %.2f%%\n", 100*$nn);
}

