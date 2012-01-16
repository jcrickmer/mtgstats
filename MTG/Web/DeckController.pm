package MTG::Web::DeckController;

use strict;
use Data::Dumper;
use Template;
use MTG::ProbUtil;

use parent 'MTG::Web::Controller';

sub new {
	my $class = shift;
	my $self = $class->SUPER::new(@_);
	bless($self, $class);
	return $self;
}

sub list {
	my $self = shift;
	my $env = shift;
	my $decks = $self->{app}->{db}->listDecks();
	my $context = {decks => $decks};

	my $output = '';
	$self->{app}->{tt}->process('deck/list.tt', $context, \$output) || die $self->{app}->{tt}->error();

    return [
        # HTTP Status code
        200,
        # HTTP headers as arrayref
        [ 'Content-type' => 'text/html' ],
        # Response body as array ref
        [ $output ],
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
