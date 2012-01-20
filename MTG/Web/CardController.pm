package MTG::Web::CardController;

use strict;
use utf8;
use parent 'MTG::Web::Controller';
use Encode qw(encode);
use Data::Dumper;

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

1;
