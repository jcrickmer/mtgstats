package MTG::Web::TagController;

use strict;
use utf8;
use parent 'MTG::Web::Controller';
use Encode qw(encode);
use Data::Dumper;
use JSON;

sub new {
	my $class = shift;
	my $self = $class->SUPER::new(@_);
	$self->{tags} = [];
	bless($self, $class);
	return $self;
}

sub default {
	my $self = shift;
    my $env = shift;
    my $context = {tags=> $self->{tags}};

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

sub init {
	my $self = shift;
	my $db = shift;
	$self->{tags} = $db->getAllTags();
	return;
}

1;
