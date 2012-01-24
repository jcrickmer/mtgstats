package MTG::Web::DeckController;

use strict;
use Data::Dumper;
use Template;
use MTG::ProbUtil;
use Encode qw(encode);

use parent 'MTG::Web::Controller';

sub new {
	my $class = shift;
	my $self = $class->SUPER::new(@_);
	bless($self, $class);
	return $self;
}

sub default {
	my $self = shift;
	return $self->list(@_);
}

sub list {
	my $self = shift;
	my $env = shift;
	my $decks = $self->{app}->{db}->listDecks();
	my $context = {decks => $decks};

	my $output = '';
	$self->{app}->{tt}->process('deck/list.tt', $context, \$output) || die $self->{app}->{tt}->error();
	my $properOut = encode("utf8", $output);

    return [
        # HTTP Status code
        200,
        # HTTP headers as arrayref
        [ 'Content-type' => 'text/html; charset=utf-8' ],
        # Response body as array ref
        [ $properOut ],
    ];

}

sub view {
	my $self = shift;
	my $env = shift;
	my $deck = $self->{app}->{db}->getDeckById($env->{'app.qs'}->{deckid});
	my $landCards = $deck->cardsByType('Land');
	my $creatureCards = $deck->cardsByType('Creature');
	my $spellCards = $deck->cardsByCode([sub { my $card = shift; $card->{type} ne 'Land';},
										 sub { my $card = shift; my $y = 1 * $card->{type} =~ /Creature/; return ! $y;}]);
	my $deckCount = $deck->cardCount('main');
	my $pu = MTG::ProbUtil->new();
	my $landProbs = {};
	my $spellProbs = {};
	my $manaCurve = {};

	{
        # probabilities for land in hand
		my @types = qw(generate_mana generate_white_mana generate_blue_mana generate_black_mana generate_green_mana generate_red_mana generate_colorless_mana);
		foreach my $tag (@types) {
			my $lcards = $deck->cardsByCode([sub { my $card = shift;
												   return $card->{type} eq 'Land' && $card->{tags}->{$tag};
											   },
										 ], 'ARRAY');
			my $landCount = scalar(@$lcards);

			for (my $w = 0; $w < 8; $w++) {
				my $nn = $pu->probability($landCount, $deckCount, $w, 7);
				$landProbs->{$tag}->[$w] = $nn;
			}
		}
	}
	{
        # probabilities for spells over different CMCs
		foreach my $cmc (0 .. 13) {
			my $scards = $deck->cardsByCode([sub { my $card = shift;
												   return $card->{CMC} == $cmc && $card->{tags}->{spell};
											   },
										 ], 'ARRAY');
			my $spellCount = scalar(@$scards);

			for (my $w = 0; $w < 8; $w++) {
				my $nn = $pu->probability($spellCount, $deckCount, $w, 7);
				$spellProbs->{$cmc}->[$w] = $nn;
			}
		}
	}
	{
		# mana curve
		my $types = {'All' => sub { my $card = shift;
									 return $card->{type} ne 'Land';
								 },
					 'Creatures' => sub { my $card = shift;
										   return $card->{type} eq 'Creature';
									   },
					 'Non-Creatures' => sub { my $card = shift;
											   return $card->{type} ne 'Creature' && $card->{type} ne 'Land';
										   },
				 };
		foreach my $run (keys %$types) {
			$manaCurve->{$run} = [];
			foreach my $cmc (0 .. 13) {
				my $ccards = $deck->cardsByCode([$types->{$run},
												 sub { my $card = shift;
													   return $card->{CMC} == $cmc;
												   },
											 ], 'ARRAY');
				$manaCurve->{$run}->[$cmc] = scalar @$ccards;
			}
		}
	}


	# supply and demand
	my $manaSupply = {all=>0,white=>0,blue=>0,black=>0,green=>0,red=>0,colorless=>0};
	my $manaDemand = {all=>0,white=>0,blue=>0,black=>0,green=>0,red=>0,any=>0};
	{
        # mana supply
		my @types = qw(generate_mana generate_white_mana generate_blue_mana generate_black_mana generate_green_mana generate_red_mana generate_colorless_mana generate_two_mana generate_three_mana generate_four_mana generate_five_mana generate_six_mana generate_seven_mana);
		my $gmcards = $deck->cardsByCode([sub { my $card = shift;
												return $card->{tags}->{generate_mana};
											},
									  ], 'ARRAY');

		foreach my $gmcard (@$gmcards) {
			my $caught = 0;
			my @colors = qw(white blue black green red colorless);
			foreach my $color (@colors) {
				if ($gmcard->{tags}->{'generate_' . $color . '_mana'}) {
					$manaSupply->{$color} = $manaSupply->{$color} + 1;
					$manaSupply->{all} = $manaSupply->{all} + 1;
					$caught = 1;
				}
			}
			if (! $caught) {
				$manaSupply->{colorless} = $manaSupply->{colorless} + 1;
				$manaSupply->{all} = $manaSupply->{all} + 1;
			}
		}

		my $dmcards = $deck->cardsByCode([sub { my $card = shift;
												return $card->{CMC} > 0;
											},
									  ], 'ARRAY');

		foreach my $dmcard (@$dmcards) {
			my @cost = @{$dmcard->{cost}};
			for (my $tg = 0; $tg < @cost; $tg++) {
## REVISIT - what to do about either/or costs?!
				$manaDemand->{@cost[$tg]} = $manaDemand->{@cost[$tg]} + 1;
				$manaDemand->{all} = $manaDemand->{all} + 1;
			}
		}
	}

	my $tags = $deck->getTags();
	my @tagKeys = sort(keys(%$tags));
	my $context = {deck => $deck,
				   deckCount => $deckCount,
				   landCards => $landCards,
				   creatureCards => $creatureCards,
				   spellCards => $spellCards,
				   tagKeys => \@tagKeys,
				   tags => $tags,
				   manaProbs => $landProbs,
				   spellProbs => $spellProbs,
				   manaCurve => $manaCurve,
				   manaSupply => $manaSupply,
				   manaDemand => $manaDemand,
			   };

	my $output = '';
	$self->{app}->{tt}->process('deck/view.tt', $context, \$output) || die $self->{app}->{tt}->error();

    return [
        # HTTP Status code
        200,
        # HTTP headers as arrayref
        [ 'Content-type' => 'text/html' ],
        # Response body as array ref
        [ $output ],
    ];
}

1;
