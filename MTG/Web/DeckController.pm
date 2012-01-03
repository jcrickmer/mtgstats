package MTG::Web::DeckController;

use strict;
use Data::Dumper;
use Template;

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
	my $context = {deck => $deck};

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
