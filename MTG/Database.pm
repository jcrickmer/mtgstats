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
		$res_doc = $cards->find_one({'multiverseid'=>$id});
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
		$res_deck = MTG::Deck->new($self);
		$res_deck->{format} = $res_doc->{format};
		$res_deck->{ownerId} = $res_doc->{ownerId};
		$res_deck->{name} = $res_doc->{name};
		#print Dumper($res_doc);
		foreach my $cid (@{$res_doc->{cards}}) {
			#print "adding card $cid\n";
			$res_deck->addCard($cid);
		}
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
		my $res_deck = MTG::Deck->new($self);
		$res_deck->{format} = $doc->{format};
		$res_deck->{ownerId} = $doc->{ownerId};
		$res_deck->{name} = $doc->{name};
		#print Dumper($res_doc);
		foreach my $cid (@{$doc->{cards}}) {
			#print "adding card $cid\n";
			$res_deck->addCard($cid);
		}
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

sub insertCard {
	my $self = shift;
	my $card = shift; # we need to pass something in, right?
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
    };
    if ($@ =~ /^E11000 duplicate key error index:\s\w+\.cards\.\$(\w+)\s+dup key/) {
		# we have a duplicate key on field $1;
		my $ex = MTG::Exception::Unique->new(message => $1 . ' must be unique, _id = "' . $doc->{'_id'} . '"', show_trace => 1);
		$ex->{field} = $1;
		$ex->throw();
    }
	return $id;
}

1;
