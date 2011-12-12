package MTG::Card;

use strict;
use Clone;
use base 'Clone';

sub new {
	my $class = shift;
	my $self = {fields=>{}};
	my $test = shift;
	if (defined $test && ref($test) eq 'HASH') {
        # REVISIT - we should only copy out what we need, not just assign a reference
		$self->{fields} = $test;
	}
	my $fields = $self->{fields};
	if (! defined $fields->{multiverseid}) {
		$fields->{multiverseid} = 1;
	}
	if (! defined $fields->{name}) {
		$fields->{name} = '';
	}
	if (! defined $fields->{CMC}) {
		$fields->{CMC} = 1;
	}
	if (! defined $fields->{cost}) {
		$fields->{cost} = [];
	}
	if (! defined $fields->{type}) {
		$fields->{type} = '';
	}
	if (! defined $fields->{rarity}) {
		$fields->{rarity} = 'Common';
	}
	if (! defined $fields->{tags}) {
		$fields->{tags} = {};
	}
	if (! defined $fields->{expansion}) {
		$fields->{expansion} = '';
	}
	if (! defined $fields->{subtype}) {
		$fields->{subtype} = '';
	}
	if (! defined $fields->{toughness}) {
		$fields->{toughness} = 0;
	}
	if (! defined $fields->{power}) {
		$fields->{power} = 0;
	}
	bless($self, $class);
	return $self;
}

sub addTag {
	my $self = shift;
	my $tag = shift;
	$self->tags->{$tag} = 1;
}

sub getName {
	my $self = shift;
	return $self->{fields}->{name};
}


1;
