package MTG::Database;

# use mtg;
# db.createCollection('cards');
# db.createCollection('decks');
# db.decks.ensureIndex({name: 1, owernId: 1}, {unique: true});
#
use strict;
use MongoDB::Connection;
use Data::Dumper;
use MTG::Exception;
use MTG::Util qw(checkClass);
use MTG::CardCache;
use MTG::Card;
use MTG::Deck;

sub new {
    my $class = shift;
    my $self = {config=>{}};
	eval {
		my $conn = MongoDB::Connection->new('host' => 'mongodb://' . ($self->{config}->{host} || 'localhost') . ':' . ($self->{config}->{port} || '27017'));
		my $db = $conn->get_database($self->{config}->{name} || 'mtg');

		# Add few more attributes
		$self->{connection} = $conn;
		$self->{db} = $db;
		$self->{cardCache} = MTG::CardCache->new;
    }; if (defined $@ && $@ ne '') {
		$@ =~ /^(.+) at (\/?\w.+)$/;
		#IdApp::Exception::DAL->throw(message => $1, show_trace => 1);
		die($@);
    }
	eval {
        #db.cards.ensureIndex({multiverseid:1},{unique:true});
        #db.cards.ensureIndex({name:1},{unique:true});

		my $cards = $self->{db}->get_collection('cards');
		$cards->ensure_index({'name' => 1},{unique => 1});
		$cards->ensure_index({'multiverseid' => 1},{unique => 1});
    }; if (defined $@ && $@ ne '') {
		$@ =~ /^(.+) at (\/?\w.+)$/;
		#IdApp::Exception::DAL->throw(message => $1, show_trace => 1);
		die($@);
    }

	eval {
        #db.decks.ensureIndex({name:1, ownerId:1},{unique:true});
		my $decks = $self->{db}->get_collection('decks');
		$decks->ensure_index({'name' => 1,'ownerId' => 1},{unique => 1});
    }; if (defined $@ && $@ ne '') {
		$@ =~ /^(.+) at (\/?\w.+)$/;
		#IdApp::Exception::DAL->throw(message => $1, show_trace => 1);
		die($@);
    }

	bless($self, $class);

	return $self;
}

sub getCardByOID {
	my $self = shift;
	my $oid = shift;
	my $cacheOk = shift;

	my $res_card;
	if ($cacheOk) {
		$res_card = $self->{cardCache}->getCard($oid);
		if (defined $res_card) {
			return $res_card;
		}
	}

	my $cards = $self->{db}->get_collection('cards');
	my $res_doc;
	eval {
		$res_doc = $cards->find_one({'_id'=>$oid});
    };

    if ($@) {
		# we have a duplicate key on field $1;
		#my $ex = IdApp::Exception::Unique->new(message => $1 . ' must be unique', show_trace => 1);
		#$ex->{field} = $1;
		#$ex->throw();
		die($@);
    }

	if (defined $res_doc) {
		$res_card = MTG::Card->new($res_doc);
		$self->{cardCache}->addCard($res_card);
	}
	
	return $res_card;
}

sub getCardByMultiverseId {
	my $self = shift;
	my $id = shift;
	my $cacheOk = shift;

	my $res_card;
	if ($cacheOk) {
		$res_card = $self->{cardCache}->getCard($id);
		if (defined $res_card) {
			return $res_card;
		}
	}

	my $cards = $self->{db}->get_collection('cards');
	my $res_doc;
	eval {
		$res_doc = $cards->find_one({'multiverseid'=>"$id"});
    };

    if ($@) {
		# we have a duplicate key on field $1;
		#my $ex = IdApp::Exception::Unique->new(message => $1 . ' must be unique', show_trace => 1);
		#$ex->{field} = $1;
		#$ex->throw();
		die($@);
    }

	if (defined $res_doc) {
		$res_card = MTG::Card->new($res_doc);
		$self->{cardCache}->addCard($res_card);
	}
	
	return $res_card;
}

sub getCardByName {
	my $self = shift;
	my $name = shift;

	my $cards = $self->{db}->get_collection('cards');
	my $res_doc;
	my $res_card;
	eval {
		$res_doc = $cards->find_one({'name'=>$name});
    };

    if ($@) {
		# we have a duplicate key on field $1;
		#my $ex = IdApp::Exception::Unique->new(message => $1 . ' must be unique', show_trace => 1);
		#$ex->{field} = $1;
		#$ex->throw();
		die($@);
    }

	if (defined $res_doc) {
		$res_card = MTG::Card->new($res_doc);
	}

	return $res_card;
}

sub removeCard {
	my $self = shift;
	my $card = checkClass('MTG::Card', shift);
	my $res = $self->{db}->get_collection('cards')->remove({'_id'=>$card->getId()}, {safe=>1});
	$self->{cardCache}->removeCard($card->getId());
	#print STDERR Dumper($res);
	return $res->{n};
}

sub getCardsByTag {
	my $self = shift;
	my $tag = shift;
	my $pageNum = shift || 0;
	my $perPage = shift || 25;
	my $cursor = $self->{db}->get_collection('cards')->find({"tags.$tag"=>1})->skip($pageNum * $perPage)->limit($perPage);
	# revisit - maybe we could apply some caching...

	my @result;
	while (my $doc = $cursor->next()) {
		my $res_card = MTG::Card->new($doc);
		push(@result, $res_card);
	}
#	print STDERR Dumper @result;
	return \@result;
}

sub getDeckByNameAndOwnerId {
	my $self = shift;
	my $name = shift;
	my $ownerId = shift;

	my $decks = $self->{db}->get_collection('decks');
	my $res_doc;
	my $res_deck;
	eval {
		$res_doc = $decks->find_one({'name'=>$name, 'ownerId'=>$ownerId});
    };

    if ($@) {
		die($@);
    }

	if (defined $res_doc) {
		$res_deck = MTG::Deck->new($self, $res_doc);
	}

	return $res_deck;
}

sub getDeckById {
	my $self = shift;
	my $oid = shift;

	my $decks = $self->{db}->get_collection('decks');
	my $res_doc;
	my $res_deck;
	eval {
		$res_doc = $decks->find_one({'_id'=>$oid});
    };

    if ($@) {
		die($@);
    }

	if (defined $res_doc) {
		# REVISIT - need to move this to Deck to make it more encapsulated and reusable.
		$res_deck = MTG::Deck->new($self, $res_doc);
	}

	return $res_deck;
}

sub insertDeck {
	my $self = shift;
	my $deck = checkClass('MTG::Deck', shift);

	my $decks = $self->{db}->get_collection('decks');

	my $doc = $deck->toBSON();
	my $id;
	if (! defined $doc->{'_id'}) {
		$id = MongoDB::OID->new;
		$doc->{'_id'} = $id->to_string;
	}
    eval {
		#print STDERR Dumper($doc);
		$id = $decks->insert($doc, {safe => 1});
    };
    if ($@ =~ /^E11000 duplicate key error index:\s\w+\.decks\.\$(\w+)\s+dup key/) {
		# we have a duplicate key on field $1;
		my $ex = MTG::Exception::Unique->new(message => $1 . ' must be unique, _id = "' . $doc->{'_id'} . '"', show_trace => 1);
		$ex->{field} = $1;
		$ex->throw();
    } elsif ($@) {
		die ($@);
	}
	return $id;
}

# returns an array ref of MTG::Deck objects
sub listDecks {
	my $self = shift;
	my @result = ();
	my $cursor = $self->{db}->get_collection('decks')->find();
	while (my $doc = $cursor->next()) {
		my $res_deck = MTG::Deck->new($self, $doc);
		push(@result, $res_deck);
	}
	return \@result;
}

sub removeDeck {
	my $self = shift;
	my $deck = checkClass('MTG::Deck', shift);
	$self->{db}->get_collection('decks')->remove({name=>$deck->{name}, ownerId=>$deck->{ownerId}});
    # REVISIT - return real exceptions
	return;
}

# Insert an MTG::Card into the database.  Returns the OID (table id)
# of the new card.  Several exceptions could be thrown.
sub insertCard {
	my $self = shift;
	my $card = shift; # we need to pass something in, right?
	if (! defined $card) {
		die MTG::Exception::NullPointer->new();
	}
	checkClass('MTG::Card', $card);
	if (! $card->isComplete()) {
		my $ex = MTG::Exception::IncompleteObject->new();
		$ex->throw();
	}

	$card->broadenTags();

	my $cards = $self->{db}->get_collection('cards');

	#my $doc = {};
	#foreach my $kk (keys(%{$card->{fields}})) {
	#	if ($kk eq 'tags' ||
	#		$kk eq 'affinity_colors') {
	#		my @tt = keys(%{$card->{fields}->{$kk}});
	#		$doc->{$kk} = \@tt;
	#	} else {
	#		$doc->{$kk} = $card->{fields}->{$kk};
	#	}
	#}
	my $doc = $card->toBSON();
	my $id = MongoDB::OID->new;
	$doc->{'_id'} = $id->to_string;

	my $id;
    eval {
		$id = $cards->insert($doc, {safe => 1});
		$card->{'_id'} = $id;
    };
    if ($@ =~ /^E11000 duplicate key error index:\s\w+\.cards\.\$(\w+)\s+dup key/) {
		# we have a duplicate key on field $1;
		my $ex = MTG::Exception::Unique->new(message => $1 . ' must be unique, _id = "' . $doc->{'_id'} . '"',
											 show_trace => 1);
		$ex->{id} = $doc->{'_id'};
		$ex->{field} = $1;
		$ex->throw();
    }

	# stick it in cache for future performance
	$self->{cardCache}->addCard($card);

	return $id;
}

# Insert an MTG::Card into the database.  Returns the OID (table id)
# of the new card.  Several exceptions could be thrown.
sub saveCard {
	my $self = shift;
	my $card = shift; # we need to pass something in, right?
	if (! defined $card) {
		my $ex = MTG::Exception::NullPointer->new();
		$ex->throw();
	}
	checkClass('MTG::Card', $card);
	if (! $card->isComplete()) {
		my $ex = MTG::Exception::IncompleteObject->new();
		$ex->throw();
	}

	if (! defined $card->{'_id'}) {
		my $ex = MTG::Exception::NullPointer->new(message => '_id is not defined.');
		$ex->throw();
	}

	$card->broadenTags();

	my $cards = $self->{db}->get_collection('cards');

	my $doc = $card->toBSON();

    eval {
		$cards->update({'_id'=>$card->getId()}, $doc, {safe => 1});
    };
    if ($@ =~ /^E11000 duplicate key error index:\s\w+\.cards\.\$(\w+)\s+dup key/) {
		# we have a duplicate key on field $1;
		my $ex = MTG::Exception::Unique->new(message => $1 . ' must be unique, _id = "' . $doc->{'_id'} . '"', show_trace => 1);
		$ex->{field} = $1;
		$ex->throw();
    }

	# stick it in cache for future performance
	$self->{cardCache}->addCard($card);

	return 1;
}

# this could take a while.  Returns an array ref.
sub getAllTags {
	my $self = shift;
	my $cards = $self->{db}->get_collection('cards');

	my $kkeys = {};
	foreach my $k (keys(%{$MTG::TagMap::TAGS})) {
		$kkeys->{$k} = 1;
	}
	my $cursor = $cards->find({},{"tags"=>1});
	while (my $doc = $cursor->next()) {
		my $tags = $doc->{tags};
		foreach my $k (keys(%$tags)) {
			$kkeys->{$k} = 1;
		}
	}
	my @result = keys(%$kkeys);
	#print STDERR Dumper(\@result);
	return \@result;
}

1;
