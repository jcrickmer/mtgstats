package MTG::JSONSerializable;

use protected qw(serializable);

sub new {
    my $class = shift;
    my $self = {};

    # This is the list of member fields that can be serialized to JSON
    $self->{serializable} => [];

    bless($self, $class);
    return $self;
}

sub TO_JSON {
    my $self = shift;

    # this is what we expect to change to JSON
    my $result = {};

    foreach my $attr (@{$self->{serializable}}) {
	# REVISIT - do something special for hash refs/objects?
	# Doesn't seem like it, as TO_JSON's recursiveness solves the
	# problem.  But maybe there is a performace problem here?
	if ($attr ne '') { # skip empty keys
	    $result->{$attr} = $self->{$attr};
	}
    }

    return $result;
}


1;
