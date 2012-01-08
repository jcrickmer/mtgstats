package MTG::Web::CardController;

use parent 'MTG::Web::Controller';

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
