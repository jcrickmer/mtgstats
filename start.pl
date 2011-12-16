#!/usr/bin/perl

use strict;
use Data::Dumper;
use MTG::Database;
use MTG::Card;
use MTG::Deck;
use MTG::ProbUtil;
if (0) {
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
}
my $pu = MTG::ProbUtil->new();

if (1) {
	my $redCount = 2;
	my $cardCount = 4;
	print "2 matching cards in a stack of 4\n";
	print "pull one chances: " . $pu->probability($redCount, $cardCount, 1, 1) . "\n";
	print "-----\n";
	print "pull one for 2 chances: " . $pu->probability($redCount, $cardCount, 1, 2) . "\n";
	print "-----\n";
	print "pull one for 3 chances: " . $pu->probability($redCount, $cardCount, 1, 3) . "\n";
	print "-----\n";
	print "pull one for 4 chances: " . $pu->probability($redCount, $cardCount, 1, 4) . "\n";
	print "-----\n";
	
	print "pull two for 2 chances: " . $pu->probability($redCount, $cardCount, 2, 2) . "\n";
	print "-----\n";
	print "pull two for 3 chances: " . $pu->probability($redCount, $cardCount, 2, 3) . "\n";
	print "-----\n";
	print "pull two for 4 chances: " . $pu->probability($redCount, $cardCount, 2, 4) . "\n";
	print "----------\n";
}
if (1) {
	my $redCount = 2;
	my $cardCount = 5;
	print "2 matching cards in a stack of 5\n";
	print "pull 0 in 1 chance: " . $pu->probability($redCount, $cardCount, 0, 1) . "\n";
	print "pull 0 in 2 chances: " . $pu->probability($redCount, $cardCount, 0, 2) . "\n";
	print "pull 0 in 3 chances: " . $pu->probability($redCount, $cardCount, 0, 3) . "\n";
	print "pull 0 in 4 chances: " . $pu->probability($redCount, $cardCount, 0, 4) . "\n";
	print "pull 0 in 5 chances: " . $pu->probability($redCount, $cardCount, 0, 5) . "\n";
	print "-----\n";
	print "pull one in 1 chance: " . $pu->probability($redCount, $cardCount, 1, 1) . "\n";
	print "pull one for 2 chances: " . $pu->probability($redCount, $cardCount, 1, 2) . "\n";
	print "pull one for 3 chances: " . $pu->probability($redCount, $cardCount, 1, 3) . "\n";
	print "pull one for 4 chances: " . $pu->probability($redCount, $cardCount, 1, 4) . "\n";
	print "pull one for 5 chances: " . $pu->probability($redCount, $cardCount, 1, 5) . "\n";
	print "------------------\n";
	print "pull 2 for 1 chances: " . $pu->probability($redCount, $cardCount, 2, 1) . "\n";
	print "pull 2 for 2 chances: " . $pu->probability($redCount, $cardCount, 2, 2) . "\n";
	print "pull 2 for 3 chances: " . $pu->probability($redCount, $cardCount, 2, 3) . "\n";
	print "pull 2 for 4 chances: " . $pu->probability($redCount, $cardCount, 2, 4) . "\n";
	print "pull 2 for 5 chances: " . $pu->probability($redCount, $cardCount, 2, 5) . "\n";

}
#my $redCount = 23.0;
#my $deckCount = 60.0;
my $redCount = 23.0;
my $deckCount = 60.0;

my $onDraw = $pu->probability($redCount, $deckCount, 1, 1);
print "probability of pulling a mountain on 1 draw: " . $onDraw . "\n";

my $zero = $pu->probability($redCount, $deckCount, 0, 7);
printf("0 reds in 7: %.2f%%\n", 100*$zero);

my $one = $pu->probability($redCount, $deckCount, 1, 7);
printf("1 red in 7: %.2f%%\n", 100*$one);

my $two = $pu->probability($redCount, $deckCount, 2, 7);
printf("2 reds in 7: %.2f%%\n", 100 * $two);

my $three = $pu->probability($redCount, $deckCount, 3, 7);
printf("3 reds in 7: %.2f%%\n", 100*$three);

my $four = $pu->probability($redCount, $deckCount, 4, 7);
printf("4 reds in 7: %.2f%%\n", 100*$four);

my $five = $pu->probability($redCount, $deckCount, 5, 7);
printf("5 reds in 7: %.2f%%\n", 100*$five);


#print "4! is " . $pu->factorial(60) . "\n";
