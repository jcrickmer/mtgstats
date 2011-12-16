package MTG::Deck;

use strict;

sub new {
	my $class = shift;
	my $self = {db => shift,
				cards=>[],
			};
	bless($self, $class);
	return $self;
}

sub addCard {
	my $self = shift;
	my $card = shift;
	my $count = shift || 1;
	if (defined $card && ref($card) && $card->isa('MTG::Card')) {
		print "a card!\n";
		push(@{$self->{cards}}, $card);
	} elsif (defined $card) {
		my $card_o;
		if ($card * 1 eq $card) { # number check
			$card_o = $self->{db}->getCardById($card);
		} else {
			$card_o = $self->{db}->getCardByName($card);
		}
		print "something... a " . $card . "\n";
		if (defined $card_o) {
			for (my $yy = 0; $yy < $count; $yy++) {
				if ($yy == 0) {
					push(@{$self->{cards}}, $card_o);
				} else {
					push(@{$self->{cards}}, $card_o->clone());
				}
			}
		} else {
			die('Database does not contain a card with id ' . $card);
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

1;
