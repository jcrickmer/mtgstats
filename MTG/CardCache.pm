package MTG::CardCache;

use strict;
use MTG::Util qw(checkClass);

sub new {
	my $class = shift;
	my $self = {cards=>{}};
	return bless $self, $class;
}

sub addCard {
	my $self = shift;
	my $card = checkClass('MTG::Card', shift);
	if (! defined $self->{cards}->{$card->getId()}) {
		$self->{cards}->{$card->getId()} = $card;
	}
}

sub getCard {
	my $self = shift;
	my $id = shift;
	return $self->{cards}->{id};
}

sub removeCard {
	my $self = shift;
	my $id = shift;
	delete $self->{cards}->{id};
}

1;
