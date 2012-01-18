#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';
use Time::HiRes qw(gettimeofday tv_interval);
  
use Test::More tests => 24;

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
