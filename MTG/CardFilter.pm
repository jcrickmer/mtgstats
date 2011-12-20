# Filters cards that are within a deck.

package MTG::CardFilter;

use strict;
use Data::Dumper;

sub new {
	my $class = shift;
	my $self = {predicates => []};
	bless($self, $class);
	return $self;
}

# takes a MTG::Deck, returns a set of cards (as an array reference)
sub filter {
	my $self = shift;
	my $deck = shift;
	my $result = [];
	if (defined $deck
		&& ref($deck)
		&& $deck->isa('MTG::Deck')) {
		my $cards = $deck->getCards();
		foreach my $card (@$cards) {
			my $possible = 1;
			foreach my $pred (@{$self->{predicates}}) {
				my $cval = $card->{fields}->{$pred->{field}};
				my $r = 0;
				if ($pred->{comp} eq '=~') {
					# ok, it is a grep, for use on arrays ONLY at this point
					my $t = $pred->{value};
					my @u = grep(/$t/, @$cval);
					if (@u > 0) {
						$r = 1;
					}
				} else {
					# ok, this would seemingly support ne, eq, ==, >, <, != , >=, and <= (but we should test more!!)
					my $eq = '$r = $cval ' . $pred->{comp} . ' $pred->{value}';
					eval($eq);
				}
				$possible = $r && $possible;
			}
			if ($possible) {
				push(@$result, $card);
			}
		}
	} else {
		die("Cannot filter on undef.") if (! defined $deck);
		die("Cannot filter on $deck");
	}
	return $result;
}

sub addPredicate {
	my $self = shift;
	my $field = shift;
	my $comp = shift;
	my $value = shift;
	my $pred = MTG::FilterPredicate->new();
	$pred->{field} = $field;
	$pred->{comp} = $comp;
	$pred->{value} = $value;
	push(@{$self->{predicates}}, $pred);
	return;
}

package MTG::FilterPredicate;

sub new {
	my $class = shift;
	my $self = {field => undef,
				comp => undef,
				value => undef,
			};
	bless($self, $class);
	return $self;
}

1;
