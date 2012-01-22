package MTG::Deck;

use base qw(MTG::MongoObject);
use strict;
use MTG::MongoObject;
use Data::Dumper;

sub new {
	my $class = shift;
	my $self = {db => shift,
				'_id' => undef, # the Mongo OID
				cards=>{"main"=>{},"sideboard"=>{}}, # hash refs of the cards in the deck.
				name=>undef,
				format=>undef,
				owner=>undef,
				ownerId=>undef,
				date=>undef,
				_card_series=>[]
			};
	push(@{$self->{serializable}}, '_id', 'cards', 'name', 'format', 'ownerId','date');
	my $db_doc = shift;
	if (defined $db_doc) {
		$self->{'_id'} = $db_doc->{'_id'};
		$self->{format} = $db_doc->{format};
		$self->{ownerId} = $db_doc->{ownerId};
		$self->{name} = $db_doc->{name};
		$self->{cards} = $db_doc->{cards};
		$self->{date} = $db_doc->{date};
	}
	foreach my $cardId (keys(%{$self->{cards}->{main}})) {
		for (my $q = 0; $q < $self->{cards}->{main}->{$cardId}->{count}; $q++) {
			push @{$self->{_card_series}}, $cardId;
		}
	}
	bless($self, $class);
	return $self;
}

sub addCard {
	my $self = shift;
	my $card = shift;
	my $count = shift || 1;
	my $cardStatus = shift || "main"; # the default card status is that it is in the "main" set of the deck.

	# make sure that we have a bucket to stick cards into.
	if (! defined ($self->{cards}->{$cardStatus})) {
		$self->{cards}->{$cardStatus} = {};
	}
	my $card_o;
	if (defined $card && ref($card) && $card->isa('MTG::Card')) {
		$card_o = $card;
		#print "a card!\n";
		#push(@{$self->{cards}}, $card);
		my $deckcard_ref = $self->{cards}->{$cardStatus}->{$card->getId()};
		if (defined $deckcard_ref) {
			$self->{cards}->{$cardStatus}->{$card->getId()}->{count}++;
		} else {
			$self->{cards}->{$cardStatus}->{$card->getId()}->{count} = 1;
		}
	} elsif (defined $card) {
		if ($card =~ /^[0-9abcdefABCDEF]{9}/) { # looks like an OID?
			$card_o = $self->{db}->getCardByOID($card, 1);
		} elsif ($card * 1 eq $card) { # number check
			$card_o = $self->{db}->getCardByMultiverseId($card, 1);
		} else {
			$card_o = $self->{db}->getCardByName($card);
		}
		#print "something... a " . $card . "\n";
		if (defined $card_o) {
			$self->{cards}->{$cardStatus}->{$card_o->getId()}->{count} = $count + $self->{cards}->{$cardStatus}->{$card_o->getId()}->{count};
		} else {
			die('Database does not contain a card with descriptor ' . $card);
		}
	} else {
		die('Cannot add card from undefined');
	}
	# keep _card_series up-to-date
	if ($cardStatus eq 'main') {
		for (my $r = 0; $r < $count; $r++) {
			push @{$self->{_card_series}}, $card_o->getId();
		}
	}
}

# cardStatus can be an ARRAY ref, a string, or undefined.  undef means all card statuses.
sub cardCount {
	my $self = shift;
	my $cardStatus = shift;
	my $count = 0;
	if (! defined $cardStatus) {
		my @f = keys(%{$self->{cards}});
		$cardStatus = \@f;
	} elsif (ref($cardStatus) ne 'ARRAY') {
		$cardStatus = [$cardStatus];
	}
	foreach my $cs (@$cardStatus) {
		my @cardIds = keys(%{$self->{cards}->{$cs}});
		foreach my $cardId (@cardIds) {
			$count = $count + $self->{cards}->{$cs}->{$cardId}->{count};
		}
	}
	return $count;
}

# returns the string of the Mongo OID
sub getId {
	my $self = shift;
	return $self->{'_id'};
}

# returns a MTG::Card, or undef
sub getCard { ## REVISIT - does not know new data structure
	my $self = shift;
	my $place = shift || 0;
	die("FIX ME");
	return $self->{cards}->[$place];
}

# returns a hash ref of {cardId => {card => MTG::Card, count => x}}.
sub getCards {
	my $self = shift;
	my $cardStatus = shift || "main";
	my $result = {};
	foreach my $cardId (keys(%{$self->{cards}->{$cardStatus}})) {
		my $card_o = $self->{db}->getCardByOID($cardId, 1);
		$result->{$card_o->getId()} = {card=>$card_o, count=>$self->{cards}->{$cardStatus}->{$cardId}->{count}};
	}
	return $result;
}

# only "main" can be shuffled.
sub shuffle {
	my $self = shift;
	my %order;
	my $count = 0;
	foreach my $cardKey (@{$self->{_card_series}}) {
		$order{rand() + ($count / 10000000)} = $cardKey;
		$count++;
	}
	my @newOrder = sort {$a <=> $b} keys(%order);
	$count = 0;
	foreach my $place (@newOrder) {
		$self->{_card_series}->[$count] = $order{$place};
		$count++;
	}
	return 1;
}

sub cardsByTag {
	my $self = shift;
	my $tag = shift;
	my $result = {};
	foreach my $cardId (keys(%{$self->{cards}->{'main'}})) {
		my $card_o = $self->{db}->getCardByOID($cardId, 1);
		if (grep(/^$tag$/,@{$card_o->getTags()})) {
			$result->{$card_o->getId()} = {card=>$card_o, count=>$self->{cards}->{'main'}->{$cardId}->{count}};
		}
	}
	return $result;
}

# in main only
sub cardsByType {
	my $self = shift;
	my $type = shift;
	my $result = {};
	foreach my $cardId (keys(%{$self->{cards}->{'main'}})) {
		my $card_o = $self->{db}->getCardByOID($cardId, 1);
		if ($card_o->getType() eq $type) {
			$result->{$card_o->getId()} = {card=>$card_o, count=>$self->{cards}->{'main'}->{$cardId}->{count}};
		}
	}
	return $result;
}

# expects a code reference, or reference to an array of code
# references, that will see if a card matches.  The code references
# should take @_[0] as a MTG::Card.  If there are multiple code
# references in the array_ref, they will be treated as an
# intersection.  The return result of the code should be 0 or undef
# for DO NOT includes, and 1 (or something that evals to true) for DO
# include.
sub cardsByCode {
	my $self = shift;
	my $codes = shift;
	my $returnType = shift || 'HASH';
	if (ref($codes) eq 'CODE') {
		$codes = [$codes];
	}
	my $result = {};
	if ($returnType eq 'ARRAY') {
		$result = [];
	}
	foreach my $cardId (keys(%{$self->{cards}->{'main'}})) {
		my $card_o = $self->{db}->getCardByOID($cardId, 1);
		my $incl = 1;
		foreach my $cmp (@$codes) {
			$incl = $incl && &$cmp($card_o);
		}
		if ($incl) {
			if ($returnType eq 'ARRAY') {
				for (my $ppp = 0; $ppp < $self->{cards}->{'main'}->{$cardId}->{count}; $ppp++) {
					push @$result, $card_o;
				}
			} else {
				$result->{$card_o->getId()} = {card=>$card_o, count=>$self->{cards}->{'main'}->{$cardId}->{count}};
			}
		}
	}
	return $result;
}

sub setName {
	my $self = shift;
	my $name = shift;
	$self->{name} = $name;
	return;
}

sub getName {
	my $self = shift;
	return $self->{name};
}

sub setDate {
	my $self = shift;
	my $date = shift;
	$self->{date} = $date;
	return;
}

sub getDate {
	my $self = shift;
	return $self->{date};
}

sub setOwnerId {
	my $self = shift;
	my $ownerId = shift;
	$self->{ownerId} = $ownerId;
	return;
}

sub getOwnerId {
	my $self = shift;
	return $self->{ownerId};
}

# Set the format of the deck.  It should be a string.
sub setFormat {
	my $self = shift;
	my $format = shift;
	$self->{format} = $format;
	return;
}

# Get the format of the deck.  Undef if not set, otherwise a string.
sub getFormat {
	my $self = shift;
	return $self->{format};
}

# Go through all of the tags on the cards, organizing them into a list
# of tags in a hash array.  The keys are the tags, the value is a hash
# of the number of times it appears (an integer), and the percentage
# of the deck (a float from 0.0 to 1.0).
sub getTags {
	my $self = shift;
	my $result = {};
	my $cardCount = $self->cardCount();
	foreach my $cardId (keys(%{$self->{cards}->{'main'}})) {
		my $card_o = $self->{db}->getCardByOID($cardId, 1);
		my $tags = $card_o->getTags();
		foreach my $tag (@$tags) {
			my $pp = $result->{$tag};
			if (! defined $pp) {
				$result->{$tag} = {count=>1,percentage=>1.0/$cardCount};
			} else {
				$pp->{count}++;
				$pp->{percentage} = $pp->{count} / $cardCount;
			}
		}
	}
	return $result;
}

# expects a string of newline delimited "n Foo Card Name" entries
sub addCards {
	my $self = shift;
	my $text = shift;
	my $cardStatus = shift || 'main';
	my @lines = split(/\r?\n/,$text);
	foreach my $line (@lines) {
		#print "line: $line\n";
		if ($line =~ /^(\d+)\s+(.+)$/) {
			my $count = $1;
			my $card = $2;
			$self->addCard($card, $count, $cardStatus);
		} else {
			print STDERR "Could not parse \"$line\"\n";
		}
	}
}

1;
