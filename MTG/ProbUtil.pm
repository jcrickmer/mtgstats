package MTG::ProbUtil;

use strict;

sub new {
	my $class = shift;
	my $self = {};
	bless($self, $class);
	return $self;
}

sub factorial {
	my $self = shift;
	my $num = shift;
	if ($num == 0) { return 1; }
	die ("Must be a positive integer, not $num") if ($num < 1);
	my $result = 1;
	for (my $t = 0; $num + $t != 0; $t--) {
		$result = $result * ($num + $t);
	}
	return $result;
}

sub probability {
	my $self = shift;
	my $cardCount = shift;
	my $cardsInDeck = shift;
	my $desired = shift;
	my $inChances = shift;
	my $res = 0;
	if ($inChances == 0
		|| $cardCount == 0) {
		return 0;
	}
	if ($desired == 0) {
		my $res = ($cardsInDeck - $cardCount) / $cardsInDeck;
		for (my $chance = 1; $chance < $inChances; $chance++) {
			# the nots
			$res = $res * ($cardsInDeck - $cardCount - $chance) / ($cardsInDeck - $chance);
		}
		return $res;
	} else {
		return 0 if ($desired > $inChances);
		# we have to multiple by the number of choices/possibilities for where our desired card shows up in the rawing of all of the cards.  http://mathforum.org/library/drmath/view/56507.html
		$res = $self->choose($desired, $inChances) * $cardCount / $cardsInDeck;
		# the matches
		for (my $chance = 1; $chance < $desired; $chance++) {
			$res = $res * ($cardCount - $chance) / ($cardsInDeck - $chance);
		}
		# the not matches
		for (my $chance = 0; $chance < $inChances-$desired; $chance++) {
			$res = $res * ($cardsInDeck - $cardCount - $chance) / ($cardsInDeck - $desired - $chance);
		}
		return $res;
	}
}

sub choose {
	my $self = shift;
	my $r = shift;
	my $n = shift;
	return 0 if ($r>$n);
	return 1 if ($n == 0);
	my $res = $self->factorial($n)/($self->factorial($r) * ($n-$r < 1 ? 1 : $self->factorial($n - $r)));
#	print "C($n, $r) = $res\n";
	return $res;
}

1;
