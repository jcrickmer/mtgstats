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
	my $tt = Template->new({
		INCLUDE_PATH => '/home/jason/projects/mtgstats/views',
		INTERPOLATE  => 1,
	}) || die "$Template::ERROR\n";
	my $output = '';
	$tt->process('deck/list.tt', $context, \$output) || die $tt->error();
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
