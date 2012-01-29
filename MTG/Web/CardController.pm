package MTG::Web::CardController;

use strict;
use utf8;
use parent 'MTG::Web::Controller';
use Encode qw(encode);
use Data::Dumper;
use JSON;
use MTG::GathererLoader;

sub new {
	my $class = shift;
	my $self = $class->SUPER::new(@_);
	bless($self, $class);
	return $self;
}

sub default {
	my $self = shift;
	return $self->main(@_);
}

sub add {
    my $self = shift;
    my $env = shift;

	my $out = 'I really wanted to send you somewhere.';

    my $value = $env->{'app.qs'}->{cardname} || '';
	$value =~ s/^\s*(.+)$/$1/;
	$value =~ s/(.*\S)\s*$/$1/;
	if (! defined $value || $value eq '' || $value =~ /^\s+$/) {
		return $self->relocate($env, '/card/',undef,undef,'');
	}
	my $loader = MTG::GathererLoader->new($self->{app}->{db});
	my $dataLoc = undef;
	my $cardid = undef;
	print STDERR "!!!!!!! Searching for \"$value\"\n";
	if ($value =~ /^\d+$/) {
		my $card = $self->{app}->{db}->getCardByMultiverseId($value);
		if (defined $card) {
			return $self->relocate($env, '/card/view', undef, undef, 'cardid=' . $card->getId());
		} else {
			$dataLoc = $loader->fetchCardByMId($value);
		}
	} else {
		my $card = $self->{app}->{db}->getCardByName($value);
		if (defined $card) {
			return $self->relocate($env, '/card/view', undef, undef, 'cardid=' . $card->getId());
		} else {
			$dataLoc = $loader->fetchCardByName($value);
		}
	}
	if (defined $dataLoc) {
		my $lr = $loader->readCard($dataLoc);
		if (defined $lr->{$dataLoc}->{cardid}) {
			# yay!
			return $self->relocate($env, '/card/view', undef, undef, 'cardid=' . $lr->{$dataLoc}->{cardid});
		} else {
			$out = Dumper($lr);
		}
	} else {
		$out = "Could not find or download a card from gatherer.wizards.com named \"$value\".\n";
	}
    return [
        # HTTP Status code
        200,
        # HTTP headers as arrayref
        [ 'Content-type' => 'text/html; charset=utf-8' ],
        # Response body as array ref
        [ $out ],
    ];
}

sub view {
    my $self = shift;
    my $env = shift;


    my $card = $self->{app}->{db}->getCardByOID($env->{'app.qs'}->{cardid});
    my $context = {card => $card};

    my $output = '';
    $self->{app}->{tt}->process('card/view.tt', $context, \$output) || die $self->{app}->{tt}->error();
	#utf8::downgrade($output);
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

sub main {
    my $self = shift;
    my $env = shift;
    my $context = {};

    # let's show cards that need some loving...
	my $cards_a = $self->{app}->{db}->getCardsByTag('needs_tag_review', $env->{'app.qs'}->{lp});
	$context->{cards} = $cards_a;

    my $output = '';
    $self->{app}->{tt}->process('card/main.tt', $context, \$output) || die $self->{app}->{tt}->error();
	#utf8::downgrade($output);
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

sub save {
	my $self = shift;
    my $env = shift;
    my $context = {status=>'No card specified'};

	my $cardId = $env->{'app.qs'}->{cardid};
	if (defined $cardId) {
		my $card = $self->{app}->{db}->getCardByOID($cardId);
		if (defined $card) {
			$context->{status} = 'Ok';
			my $modded = 0;
			if (defined $env->{'app.qs'}->{tags}) {
				$modded = 1;
				$card->replaceTags($env->{'app.qs'}->{tags});
			}
			if ($modded) {
				$self->{app}->{db}->saveCard($card);
			}
		} else {
			$context->{status} = 'Card not found';
		}
		print STDERR Dumper($card);
	}
	my $properOut = to_json($context,{utf8=>1});

    return [
        # HTTP Status code
        200,
        # HTTP headers as arrayref
        [ 'Content-type' => 'application/json' ],
        # Response body as array ref
        [ $properOut ],
    ];
}

1;
