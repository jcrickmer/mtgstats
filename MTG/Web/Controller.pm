package MTG::Web::Controller;

use strict;
use utf8;

sub new {
	my $class = shift;
	my $self = {app => shift};
	bless($self, $class);
	return $self;
}

1;
