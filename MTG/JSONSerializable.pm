package MTG::JSONSerializable;

use protected qw(serializable);
use JSON::XS;

sub new {
    my $class = shift;
    my $self = {};

    # This is the list of member fields that can be serialized to JSON
    $self->{serializable} => [];

    bless($self, $class);
    return $self;
}

# returns a HASH ref
sub toBSON {
    my $self = shift;

    # this is what we expect to change to JSON
    my $result = {};

    foreach my $attr (@{$self->{serializable}}) {
		# REVISIT - do something special for hash refs/objects?
		# Doesn't seem like it, as TO_JSON's recursiveness solves the
		# problem.  But maybe there is a performace problem here?
		if (ref($attr) eq 'HASH' && $attr->{by_ref}) {
			my $n = $attr->{name};
			if (ref($self->{$n}) eq 'ARRAY') {
				my @ra = ();
				foreach my $obj (@{$self->{$n}}) {
					push @ra, $obj->getId();
				}
				$result->{$n} = \@ra;
			} elsif (ref($self->{$n}) eq 'HASH') {
				my $rhr = {};
				foreach my $obj (keys %{$self->{$n}}) {
					$rhr->{$obj} = $self->{$n}->{$obj}->getId();
				}
				$result->{$n} = $rhr;
			} else {
				die ("what? " . $n);
			}
		} else {
			if ($attr ne '') { # skip empty keys
				$result->{$attr} = $self->{$attr};
			}
		}
    }

    return $result;
}

# returns a string of JSON
sub TO_JSON {
    my $self = shift;
	my $result = JSON::XS->new->utf8->encode($self->toBSON());
	return $result;
}

1;
