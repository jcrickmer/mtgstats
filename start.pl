#!/usr/bin/perl

use strict;
use Data::Dumper;
use MTG::Database;
use MTG::Card;
use MTG::Deck;

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

my $deckCount = 60.0;
my $redCount = 23.0;
my $whiteCount = 0.0;

# at least 1 out of 7 - I am pretty sure that this one is right
my $one = 1 - ((($deckCount - $redCount) / $deckCount)
			   * (($deckCount - $redCount -1) / ($deckCount-1))
			   * (($deckCount - $redCount -2) / ($deckCount-2))
			   * (($deckCount - $redCount -3) / ($deckCount-3))
			   * (($deckCount - $redCount -4) / ($deckCount-4))
			   * (($deckCount - $redCount -5) / ($deckCount-5))
			   * (($deckCount - $redCount -6) / ($deckCount-6)));
printf("At least 1 red: %.2f%%\n", 100*$one);

# at least 2 out of 7 - I am 60% sure that this one is right
my $two = 1 - (1 - $one)
            - (($redCount / $deckCount)
			   * (($deckCount - $redCount -1) / ($deckCount-1))
			   * (($deckCount - $redCount -2) / ($deckCount-2))
			   * (($deckCount - $redCount -3) / ($deckCount-3))
			   * (($deckCount - $redCount -4) / ($deckCount-4))
			   * (($deckCount - $redCount -5) / ($deckCount-5))
			   * (($deckCount - $redCount -6) / ($deckCount-6)));
printf("At least 2 red: %.2f%%\n", 100*$two);

# at least 3 out of 7 - I am pretty sure that this one is wrong.
my $three = 1 - (1 - $two)
            - (($redCount / $deckCount)
			   * (($redCount -1) / ($deckCount-1))
			   * (($deckCount - $redCount -2) / ($deckCount-2))
			   * (($deckCount - $redCount -3) / ($deckCount-3))
			   * (($deckCount - $redCount -4) / ($deckCount-4))
			   * (($deckCount - $redCount -5) / ($deckCount-5))
			   * (($deckCount - $redCount -6) / ($deckCount-6)));
printf("At least 3 red: %.2f%%\n", 100*$three);

