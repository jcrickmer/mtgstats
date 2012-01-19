#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';
use Time::HiRes qw(gettimeofday tv_interval);
  
use Test::More tests => 109;

use MTG::Database;
use MTG::Deck;

use Data::Dumper;


my $db = MTG::Database->new();

ok(defined $db, 'Database exists.');                # check that we got something

# try to load a card that is not there by OID
{
	my $card = $db->getCardByOID('5jgj48j49d9gkg9k');
	ok(! defined $card, 'Try to load a non-existant card by OID and get null');
};

# try to load a card that is not there by name
{
	my $card = $db->getCardByName('Jason rocks the house');
	ok(! defined $card, 'Try to load a non-existant card by name and get null');
};

# try to load a card that is not there by multiverseid
{
	my $card = $db->getCardByMultiverseId('9999999b');
	ok(! defined $card, 'Try to load a non-existant card by multiverseid and get null');
};

# insert an incomplete card
{
	my $card = MTG::Card->new();
	eval {
		$db->insertCard($card);
	};
	isa_ok($@, 'MTG::Exception::IncompleteObject', 'Try to insert and incomplete card, no fields.');
}

# insert an incomplete card
{
	my $card = MTG::Card->new();
	$card->setName('Foo Card');
	eval {
		$db->insertCard($card);
	};
	isa_ok($@, 'MTG::Exception::IncompleteObject', 'Try to insert and incomplete card, name.');
}

# insert an incomplete card
{
	my $card = MTG::Card->new();
	$card->addMultiverseId('45654');
	eval {
		$db->insertCard($card);
	};
	isa_ok($@, 'MTG::Exception::IncompleteObject', 'Try to insert and incomplete card, multiverseid.');
}

# insert an incomplete card
{
	my $card = MTG::Card->new();
	$card->setType('Enchantment');
	eval {
		$db->insertCard($card);
	};
	isa_ok($@, 'MTG::Exception::IncompleteObject', 'Try to insert and incomplete card, type.');
}

{
	# insert a basic card
	my $id;
	my $testName = 'Jason Test Card 1';
	my $testType = 'Instant';
	my $testMvId = '9000001';
	{
		my $card = MTG::Card->new();
		$card->setName($testName);
		$card->setType($testType);
		$card->addMultiverseId($testMvId);
		eval {
			$id = $db->insertCard($card);
		};
		is(ref $@, '', 'Basic insert - no error.');
		is($@, '', 'Basic insert - no error.');
		ok(defined $id, "Basic insert - id defined - $id");
		#print STDERR Dumper($@);
	}

	# get back that basic card.
	{
		my $card;
		eval {
			$card = $db->getCardByOID($id);
		};
		is(ref $@, '', 'Basic getCardById - no error.');
		is($@, '', 'Basic getCardById - no error.');

		is($card->getName(), $testName, 'Basic read, name');
		is($card->getType(), $testType, 'Basic read, type');
		my $mvids = $card->getMultiverseIds();
		ok(ref $mvids eq 'ARRAY');
		is(scalar @$mvids, 1);
		my $mvid = pop @$mvids;
		is($mvid, $testMvId, 'Basic read, mvid from array');
		$mvid = $card->getMultiverseId();
		is($mvid, $testMvId, 'Basic read, mvid as only mvid on Card');
	}

	# delete the card, by card
	{
		my $card = $db->getCardByOID($id);
		my $success = 0;
		eval {
			$success = $db->removeCard($card);
		};
		is(ref $@, '', 'Basic removeCard - no error.');
		is($@, '', 'Basic removeCard - no error.');

		# note that $card is still around.  It was just deleted from
		# the database, not from memory.  It's presence in memory is
		# "undefined" (from a spec perspective).

		ok($success, 'Removed');

		my $testCard = $db->getCardByOID($id);
		ok(! defined $testCard, "Card is gone.");

		my $testCard2 = $db->getCardByOID($id, 1);
		ok(! defined $testCard2, "Card is gone from cache too.");
	}
}

{
	# insert a basic card, each field.
	my @fields = qw(CMC cost cardtype rarity tags expansion subtype toughness power card_text flavor_text card_text_html flavor_text_html);
	my $it = 2;
	foreach my $field (@fields) {
		my $id;
		my $testName = 'Jason Test Card ' . $it;
		my $testType = 'Creature';
		my $testMvId = '' . (9000000 + $it);
		my $card = MTG::Card->new();
		$card->setName($testName);
		$card->setType($testType);
		$card->addMultiverseId($testMvId);

		if ($field eq 'CMC') {
			$card->setCMC(3);
		} elsif ($field eq 'cost') {
			$card->setCost(['any','red','black']);
		} elsif ($field eq 'cardtype') {
			$card->setCardType('Legendary Creature');
			is($card->getCardType(), 'Legendary Creature');
		} elsif ($field eq 'rarity') {
			$card->setRarity('Mythic Rare');
		} elsif ($field eq 'tags') {
			$card->addTag('rad_tag');
		} elsif ($field eq 'expansion') {
			$card->setExpansion('Toaster');
		} elsif ($field eq 'subtype') {
			$card->setSubtype(['Human', 'Avisor']);
		} elsif ($field eq 'toughness') {
			$card->setToughness(2);
		} elsif ($field eq 'power') {
			$card->setPower(2);
		} elsif ($field eq 'card_text') {
			$card->setCardText('This card is the bomb');
		} elsif ($field eq 'card_text_html') {
			$card->setCardTextHTML('<b>This card is the bomb</b>');
		} elsif ($field eq 'flavor_text') {
			$card->setFlavorText('"Be brave."');
		} elsif ($field eq 'flavor_text_html') {
			$card->setFlavorTextHTML('<i>"Be brave."</i>');
		}
		eval {
			$id = $db->insertCard($card);
		};
		is(ref $@, '', "Basic insert with $field - no error.");
		is($@, '', "Basic insert with $field - no error.");
		ok(defined $id, "Basic insert with $field - id defined - $id");
		$card = 0;
		eval {
			$card = $db->getCardByOID($id);
		};
		is(ref $@, '', "Basic getCardById with $field - no error.");
		is($@, '', "Basic getCardById with $field - no error.");

		if ($field eq 'CMC') {
			is($card->getCMC(), 3, "Basic get $field");
		} elsif ($field eq 'cost') {
			my $cost = $card->getCost();
			is(shift @$cost, 'any', "Basic get $field 0");
			is(shift @$cost, 'red', "Basic get $field 1");
			is(shift @$cost, 'black', "Basic get $field 2");
		} elsif ($field eq 'cardtype') {
			is($card->getCardType(), 'Legendary Creature', "Basic get $field");
		} elsif ($field eq 'rarity') {
			is($card->getRarity, 'Mythic Rare', "Basic get $field");
		} elsif ($field eq 'tags') {
			$card->addTag('rad_tag');
		} elsif ($field eq 'expansion') {
			$card->setExpansion('Toaster');
		} elsif ($field eq 'subtype') {
			$card->setSubtype(['Human', 'Avisor']);
		} elsif ($field eq 'toughness') {
			$card->setToughness(2);
		} elsif ($field eq 'power') {
			$card->setPower(2);
		} elsif ($field eq 'card_text') {
			$card->setCardText('This card is the bomb');
		} elsif ($field eq 'card_text_html') {
			$card->setCardTextHTML('<b>This card is the bomb</b>');
		} elsif ($field eq 'flavor_text') {
			$card->setFlavorText('"Be brave."');
		} elsif ($field eq 'flavor_text_html') {
			$card->setFlavorTextHTML('<i>"Be brave."</i>');
		}

		ok($db->removeCard($card), "Remove test " . $card->getId());
		$it++;
	}
}
