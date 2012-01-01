package MTG::Deck;

use base qw(MTG::MongoObject);
use strict;
use MTG::MongoObject;

sub new {
	my $class = shift;
	my $self = {db => shift,
				cards=>[],
				name=>undef,
				format=>undef,
				owner=>undef,
				ownerId=>undef,
			};
	push(@{$self->{serializable}}, {name=>'cards', by_ref=>1}, 'name', 'format', 'ownerId');
	bless($self, $class);
	return $self;
}

sub addCard {
	my $self = shift;
	my $card = shift;
	my $count = shift || 1;
	if (defined $card && ref($card) && $card->isa('MTG::Card')) {
		#print "a card!\n";
		push(@{$self->{cards}}, $card);
	} elsif (defined $card) {
		my $card_o;
		if ($card * 1 eq $card) { # number check
			$card_o = $self->{db}->getCardByMultiverseId($card, 1);
		} else {
			$card_o = $self->{db}->getCardByName($card);
		}
		#print "something... a " . $card . "\n";
		if (defined $card_o) {
			for (my $yy = 0; $yy < $count; $yy++) {
				if ($yy == 0) {
					push(@{$self->{cards}}, $card_o);
				} else {
					push(@{$self->{cards}}, $card_o->clone());
				}
			}
		} else {
			die('Database does not contain a card with descriptor ' . $card);
		}
	} else {
		die('Cannot add card from undefined');
	}
}

sub cardCount {
	my $self = shift;
	return scalar(@{$self->{cards}});
}

# returns a MTG::Card, or undef
sub getCard {
	my $self = shift;
	my $place = shift || 0;
	return $self->{cards}->[$place];
}

# returns a MTG::Card, or undef
sub getCards {
	my $self = shift;
	return $self->{cards};
}

sub shuffle {
	my $self = shift;
	my $count = $self->cardCount();
	for (my $e = 0; $e < $count; $e++) {
		$self->{cards}->[$e]->{_place} = rand();
	}
	my @newOrder = sort {$a->{_place} <=> $b->{_place}} @{$self->{cards}};
	$self->{cards} = \@newOrder;
}

sub cardsByTag {
	my $self = shift;
	my $tag = shift;
	my @result = ();
	foreach my $card (@{$self->{cards}}) {
		push(@result, $card) if (grep(/^$tag$/,@{$card->getTags()}));
	}
	return \@result;
}

sub cardsByType {
	my $self = shift;
	my $type = shift;
	my @result = ();
	foreach my $card (@{$self->{cards}}) {
		push(@result, $card) if ($card->getType() eq $type);
	}
	return \@result;
}

sub setName {
	my $self = shift;
	my $name = shift;
	$self->{name} = $name;
	return;
}

sub setOwnerId {
	my $self = shift;
	my $ownerId = shift;
	$self->{ownerId} = $ownerId;
	return;
}

sub setFormat {
	my $self = shift;
	my $format = shift;
	$self->{format} = $format;
	return;
}

# go through all of the tags on the cards, organizing them into a list
# of tags in a hash array.  The keys are the tags, the value is a hash
# of the number of times it appears (an integer), and the percentage
# of the deck (a float from 0.0 to 1.0).
sub getTags {
	my $self = shift;
	my $result = {};
	my $cardCount = $self->cardCount();
	foreach my $card (@{$self->{cards}}) {
		my $tags = $card->getTags();
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

1;
