package MTG::Web::Controller;

sub new {
	my $class = shift;
	my $self = {app => shift};
	bless($self, $class);
	return $self;
}

1;
