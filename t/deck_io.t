#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';
use Time::HiRes qw(gettimeofday tv_interval);
  
use Test::More tests => 14;

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
	$deck->setName($nnnn);
	$deck->{format} = 'Modern';
    ## ASSUMING that the basic cards are in here!!
	$deck->addCard(277, 1);
	is($deck->cardCount(), 1, 'cardcount is right');
	my $id = $db->insertDeck($deck);
	ok(defined $id, 'got back an id');
	my $comp = $db->getDeckByNameAndOwnerId($nnnn, 1);
	ok(defined $comp, 'something returned from database');
	is($deck->{name}, $comp->{name}, 'name eq');
	is($deck->{ownerId}, $comp->{ownerId}, 'ownerId eq');
	is($deck->cardCount(), $comp->cardCount, 'card count eq');
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
