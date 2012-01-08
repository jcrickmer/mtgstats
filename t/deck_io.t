#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';
use Time::HiRes qw(gettimeofday tv_interval);
  
use Test::More tests => 36;

use MTG::Database;
use MTG::Deck;

use Data::Dumper;


my $db = MTG::Database->new();

ok(defined $db, 'Database exists.');                # check that we got something

# try to load a deck that is not there.
{
	my $deck = $db->getDeckByNameAndOwnerId('foo grudge', 835439);
	ok(! defined $deck, 'Deck is undefined');
};

# add a deck with 1 card
{
	my $deck = MTG::Deck->new($db);
	my $nnnn = 'kldsfk lsfkfslflsg ss';
	$deck->setOwnerId(1);
	is($deck->getOwnerId(), 1, "owner id set/get");
	$deck->setName($nnnn);
	is($deck->getName(), $nnnn, "name set/get");
	$deck->setFormat('Modern');
	is($deck->getFormat(), 'Modern', "format set/get");
 
	## ASSUMING that the basic cards are in here!!
	$deck->addCard(277, 1);
	is($deck->cardCount(), 1, 'cardcount is right');

	$deck->addCard(277, 1, 'sideboard');
	is($deck->cardCount(), 2, 'cardcount is right with sideboard addition 1');
	is($deck->cardCount('main'), 1, 'cardcount is right with sideboard addition 2');
	is($deck->cardCount('sideboard'), 1, 'cardcount is right with sideboard addition 3');
	is($deck->cardCount(['main']), 1, 'cardcount is right with sideboard addition 4');
	is($deck->cardCount(['main','sideboard']), 2, 'cardcount is right with sideboard addition 5');
	$deck->addCard(277, 2, 'main');
	is($deck->cardCount(), 4, 'cardcount is right with sideboard addition 6');
	is($deck->cardCount('main'), 3, 'cardcount is right with sideboard addition 7');
	is($deck->cardCount('sideboard'), 1, 'cardcount is right with sideboard addition 8');
	is($deck->cardCount(['main']), 3, 'cardcount is right with sideboard addition 9');
	is($deck->cardCount(['foo']), 0, 'cardcount is right with sideboard addition 10');
	is($deck->cardCount(['main','sideboard']), 4, 'cardcount is right with sideboard addition 11');

	my $id = $db->insertDeck($deck);
	ok(defined $id, 'got back an id');
	my $comp = $db->getDeckByNameAndOwnerId($nnnn, 1);
	ok(defined $comp, 'something returned from database');
	is($deck->{name}, $comp->{name}, 'name eq');
	is($deck->getName(), $comp->getName(), 'name eq 2');
	is($deck->{ownerId}, $comp->{ownerId}, 'ownerId eq');
	is($deck->getOwnerId(), $comp->getOwnerId(), 'ownerId eq 2');
#	print STDERR Dumper($comp);
	is($deck->cardCount(), $comp->cardCount, 'card count eq');
	is($deck->cardCount(), 4, 'cardcount equality 2');
	is($deck->cardCount('main'), 3, 'cardcount equality 3');
	is($deck->cardCount('sideboard'), 1, 'cardcount equality 4');
	is($deck->cardCount(['main']), 3, 'cardcount equality 5');
	is($deck->cardCount(['foo']), 0, 'cardcount equality 6');
	is($deck->cardCount(['main','sideboard']), 4, 'cardcount equality 7');
	$db->removeDeck($deck);
}

# add a deck with a few cards
{
	my $deck = MTG::Deck->new($db);
	my $nnnn = 'kldsfk lsffstlftlstg tsst';
	$deck->setOwnerId(1);
	$deck->setName($nnnn);
	$deck->{format} = 'Standard';
    ## ASSUMING that the basic cards are in here!!
	$deck->addCard(277, 3);
	$deck->addCard(294, 1);
	$deck->addCard(290, 1);
	is($deck->cardCount(), 5, 'cardcount is right');
	my $id = $db->insertDeck($deck);
	ok(defined $id, 'got back an id');
	my $comp = $db->getDeckByNameAndOwnerId($nnnn, 1);
	ok(defined $comp, 'something returned from database');
	is($deck->{name}, $comp->{name}, 'name eq');
	is($deck->{ownerId}, $comp->{ownerId}, 'ownerId eq');
	is($deck->cardCount(), $comp->cardCount, 'card count eq');
	$db->removeDeck($deck);
}
