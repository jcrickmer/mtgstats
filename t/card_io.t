#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';
use Time::HiRes qw(gettimeofday tv_interval);
  
use Test::More tests => 182;

use MTG::Database;
use MTG::Deck;

use Data::Dumper;


{
	my $_at = MTG::Card->new();
	my @fields = qw(multiverseid name CMC cost type cardtype rarity tags expansion subtype toughness power card_text flavor_text card_text_html flavor_text_html);
	foreach my $field (@fields) {
		ok(grep(/multiverseid/, @{$_at->{serializable}}), "Tests know abut $field...  Fail means you need to add a test for $field.");
	}
}

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
			is($card->getCMC(), 3, "Basic get $field");
		} elsif ($field eq 'cost') {
			$card->setCost(['any','red','black']);
			my $cost = $card->getCost();
			is(shift @$cost, 'any', "Basic get $field 0");
			is(shift @$cost, 'red', "Basic get $field 1");
			is(shift @$cost, 'black', "Basic get $field 2");
		} elsif ($field eq 'cardtype') {
			$card->setCardType('Legendary Creature');
			is($card->getCardType(), 'Legendary Creature');
		} elsif ($field eq 'rarity') {
			$card->setRarity('Mythic Rare');
			is($card->getRarity(), 'Mythic Rare');
		} elsif ($field eq 'tags') {
			ok(! $card->isTagged('rad_tag'));
			$card->addTag('rad_tag');
			my $tags_a = $card->getTags();
			is(scalar @$tags_a, 1);
			is(shift @$tags_a, 'rad_tag', "Basic get $field 0");
			ok($card->isTagged('rad_tag'));
		} elsif ($field eq 'expansion') {
			$card->setExpansion('Toaster');
			is($card->getExpansion(),'Toaster');
		} elsif ($field eq 'subtype') {
			$card->setSubtype(['Human', 'Advisor']);
			my $st = $card->getSubtype();
			is(scalar @$st, 2);
			is(shift @$st, 'Human', "Basic get $field 0");
			is(shift @$st, 'Advisor', "Basic get $field 1");
		} elsif ($field eq 'toughness') {
			$card->setToughness(2);
			is($card->getToughness(),2);
		} elsif ($field eq 'power') {
			$card->setPower(2);
			is($card->getPower(),2);
		} elsif ($field eq 'card_text') {
			$card->setCardText('This card is the bomb');
			is($card->getCardText(), 'This card is the bomb');
		} elsif ($field eq 'card_text_html') {
			$card->setCardTextHTML('<b>This card is the bomb</b>');
			is($card->getCardTextHTML(), '<b>This card is the bomb</b>');
		} elsif ($field eq 'flavor_text') {
			$card->setFlavorText('"Be brave."');
			is($card->getFlavorText(), '"Be brave."');
		} elsif ($field eq 'flavor_text_html') {
			$card->setFlavorTextHTML('<i>"Be brave."</i>');
			is($card->getFlavorTextHTML(), '<i>"Be brave."</i>');
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
            # remember, saving causes a broadening of tags...  These
            # tests might need to be updated if instant starts to have
            # more default tags.
			my $tags_a = $card->getTags();
			is(scalar @$tags_a, 3);
			ok(grep(/rad_tag/, @$tags_a));
			ok(grep(/permanent/, @$tags_a));
			ok(grep(/spell/, @$tags_a));
			ok($card->isTagged('rad_tag'));
		} elsif ($field eq 'expansion') {
			is($card->getExpansion(),'Toaster');
		} elsif ($field eq 'subtype') {
			my $st = $card->getSubtype();
			is(scalar @$st, 2);
			is(shift @$st, 'Human', "Basic get $field 0");
			is(shift @$st, 'Advisor', "Basic get $field 1");
		} elsif ($field eq 'toughness') {
			is($card->getToughness(),2);
		} elsif ($field eq 'power') {
			is($card->getPower(),2);
		} elsif ($field eq 'card_text') {
			is($card->getCardText(), 'This card is the bomb');
		} elsif ($field eq 'card_text_html') {
			is($card->getCardTextHTML(), '<b>This card is the bomb</b>');
		} elsif ($field eq 'flavor_text') {
			is($card->getFlavorText(), '"Be brave."');
		} elsif ($field eq 'flavor_text_html') {
			is($card->getFlavorTextHTML(), '<i>"Be brave."</i>');
		}

		ok($db->removeCard($card), "Remove test " . $card->getId());
		$it++;
	}
}

{
	# add a tag and remove another tag.
	my $id;
	my $testName = 'Jason Tag Test Card';
	my $testType = 'Creature';
	my $testMvId = '9010011';
	my $card = MTG::Card->new();
	$card->setName($testName);
	$card->setType($testType);
	$card->setCardType($testType);
	$card->setSubtype(['Elemental']);
	$card->addMultiverseId($testMvId);
	$card->setPower(2);
	$card->setToughness(3);
	$card->setCMC(4);
	$card->setCost(['any','any','blue','blue']);
	$card->setRarity('Uncommon');
	$card->addTag('flying');
	$card->addTag('scry');
	$card->addTag('needs_tag_review');
	$id = $db->insertCard($card);

	my $ucard = $db->getCardByOID($id);
	ok($ucard->isTagged('permanent'));
	ok($ucard->isTagged('scry'));
	ok($ucard->isTagged('flying'));
	ok($ucard->isTagged('draw_card'));
	ok($ucard->isTagged('needs_tag_review'));

	$ucard->addTag('destroy_artifact');

	ok($db->saveCard($ucard));

	my $ycard = $db->getCardByOID($id);
	ok($ycard->isTagged('permanent'));
	ok($ycard->isTagged('scry'));
	ok($ycard->isTagged('flying'));
	ok($ycard->isTagged('draw_card'));
	ok($ycard->isTagged('removal'));
	ok($ycard->isTagged('destroy_artifact'));
	ok($ycard->isTagged('needs_tag_review'));

	ok($ycard->removeTag('needs_tag_review'));

	ok($db->saveCard($ycard));

	my $zcard = $db->getCardByOID($id);
	ok($zcard->isTagged('permanent'));
	ok($zcard->isTagged('scry'));
	ok($zcard->isTagged('flying'));
	ok($zcard->isTagged('draw_card'));
	ok($zcard->isTagged('removal'));
	ok($zcard->isTagged('destroy_artifact'));
	ok(! $zcard->isTagged('needs_tag_review'));

	ok($db->removeCard($zcard));
}
