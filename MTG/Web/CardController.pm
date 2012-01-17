package MTG::Web::CardController;

use strict;
use utf8;
use parent 'MTG::Web::Controller';
use Encode qw(encode);

sub new {
	my $class = shift;
	my $self = $class->SUPER::new(@_);
	bless($self, $class);
	return $self;
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


1;
