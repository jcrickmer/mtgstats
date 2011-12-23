package MTG::MongoObject;
use base 'MTG::JSONSerializable';
use strict;
use Carp;

sub new {
    my $class = shift;
    my $oh = shift;
    my $self = $class->SUPER::new();
    foreach my $k (keys(%$oh)) {
		$self->{$k} = $oh->{$k};
		push(@{$self->{serializable}}, $k);
    }
    bless $self, $class;
    return $self;
}

# sub AUTOLOAD {
#     my $self = shift;
#     my $type = ref ($self) || croak "$self is not an object";
#     my $field = $AUTOLOAD;
#     $field =~ s/.*://;
#     unless (exists $self->{$field}) {
# 	croak "$field does not exist in object/class $type";
#     }
#     if (@_) {
# 	return $self->($name) = shift;
#     } else {
# 	return $self->($name);
#     }
# }

1;
