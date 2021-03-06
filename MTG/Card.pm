package MTG::Card;

use base qw(Clone MTG::MongoObject);
use strict;
use Clone;
use MTG::MongoObject;
use MTG::TagMap;
use Data::Dumper;
use MTG::Util qw(makeFilingName);

sub new {
	my $class = shift;

	# Call the constructor of the parent class, Person.
    my $self = $class->SUPER::new({});
	my $test = shift;
	if (defined $test && ref($test) eq 'HASH') {
        # REVISIT - we should only copy out what we need, not just assign a reference
		foreach my $f (qw(_id multiverseid name filing_name CMC cost type cardtype types rarity tags expansion subtype toughness loyalty power card_text flavor_text card_text_html flavor_text_html watermark)) {
			if ($f eq 'multiverseid' && ref($test->{$f}) ne 'ARRAY') {
				$self->{$f} = [$test->{$f}];
			} else {
				$self->{$f} = $test->{$f};
			}
		}
	}
	if (! defined $self->{_id}) {
		$self->{_id} = undef;
	}
	if (! defined $self->{multiverseid}) {
		$self->{multiverseid} = [];
	}
	#if (! defined $self->{name}) {
	#	$self->{name} = undef;
	#}
	if (! defined $self->{CMC}) {
		$self->{CMC} = 0;
	}
	if (! defined $self->{cost}) {
		$self->{cost} = [];
	}
	if (! defined $self->{type}) {
		$self->{type} = undef;
	}
	if (! defined $self->{cardtype}) {
		$self->{cardtype} = undef;
	}
	if (! defined $self->{rarity}) {
		$self->{rarity} = 'Common';
	}
	if (! defined $self->{tags}) {
		$self->{tags} = {};
	}
	if (! defined $self->{expansion}) {
		$self->{expansion} = '';
	}
	if (! defined $self->{subtype}) {
		$self->{subtype} = [];
	}
	if (! defined $self->{types}) {
		$self->{types} = [];
	}
	if (! defined $self->{toughness}) {
		$self->{toughness} = undef;
	}
	if (! defined $self->{power}) {
		$self->{power} = undef;
	}
	push(@{$self->{serializable}}, qw(_id multiverseid name filing_name CMC cost type types cardtype rarity tags expansion subtype toughness loyalty power card_text flavor_text card_text_html flavor_text_html watermark));
	bless($self, $class);
	return $self;
}

sub isComplete {
	my $self = shift;
	return defined $self->{name}
	       && defined $self->{filing_name}
	       && defined $self->{type}
		   && defined $self->{multiverseid}
		   && scalar(@{$self->{multiverseid}}) > 0;
}

sub addTag {
	my $self = shift;
	my $tag = shift;
	$self->{tags}->{$tag} = 1;
}

sub removeTag {
	my $self = shift;
	my $tag = shift;
	delete $self->{tags}->{$tag};
}

# takes an array reference of tags and removes all of the current tags.
sub replaceTags {
	my $self = shift;
	my $tags = shift;
	$self->{tags} = {};
	foreach my $tag (@$tags) {
		print STDERR "adding tag $tag\n";
		$self->addTag($tag);
	}
	return;
}

sub getName {
	my $self = shift;
	return $self->{name};
}

sub setName {
	my $self = shift;
	$self->{name} = shift;
	$self->{filing_name} = makeFilingName($self->{name});
	return;
}

sub getCMC {
	my $self = shift;
	return $self->{CMC};
}

sub setCMC {
	my $self = shift;
	$self->{CMC} = shift;
	return;
}

sub getId {
	my $self = shift;
	return $self->{_id};
}

sub getColor {
	my $self = shift;
	my $added = {};
	foreach my $c (@{$self->{cost}}) {
		if ($c ne 'any' && ! defined $added->{$c}) {
			$added->{$c} = 1;
		}
	}
	return join(', ', keys(%$added));
}

# Adds a multiverseid to the set of multiverseids.  Returns true if it
# was added, false if it was not (i.e., it was already present).
sub addMultiverseId {
	my $self = shift;
	my $toAdd = shift;
	my $found = 0;
	die ("MultiverseId mustbe in the format of \"\\d+[a-z]?\".  \"$toAdd\" does not match.") if (! ($toAdd =~ /^\d+[a-z]?$/));
	foreach my $mvid (@{$self->{multiverseid}}) {
		$found = $found || $mvid eq $toAdd;
	}
	if (! $found) {
		push @{$self->{multiverseid}}, $toAdd;
	}
	return $found;
}

# Returns a multiverse id number (typically the highest).
sub getMultiverseId {
	my $self = shift;
	my $result = -1;
	foreach my $mvid (@{$self->{multiverseid}}) {
		$result = $mvid > $result ? $mvid : $result;
	}
	return $result;
}

# Returns an array of multiverse id numbers.
sub getMultiverseIds {
	my $self = shift;
	my @result = ();
	foreach my $id (@{$self->{multiverseid}}) {
		push @result, $id;
	}
	return \@result;
}

# returns a reference to an array of tags
sub getTags {
	my $self = shift;
	my $result = [];
	foreach my $t (keys(%{$self->{tags}})) {
		if ($self->{tags}->{$t}) {
			push @$result, $t;
		}
	}
	return $result;
}

sub isTagged {
	my $self = shift;
	my $tagcmp = shift;
	return $self->{tags}->{$tagcmp} > 0;
}

# returns a string
sub getType {
	my $self = shift;
	return $self->{type};
}

# returns a string
sub setType {
	my $self = shift;
	$self->{type} = shift;
	if (! defined $self->{cardtype}) {
		$self->{cardtype} = $self->{type};
	}
	return;
}

# returns a string
sub getRarity {
	my $self = shift;
	return $self->{rarity};
}

# sets a string
sub setRarity {
	my $self = shift;
	$self->{rarity} = shift;
	return;
}

# returns a string
sub getPower {
	my $self = shift;
	return $self->{power};
}

# sets a string
sub setPower {
	my $self = shift;
	$self->{power} = shift;
	return;
}

# returns a string
sub getToughness {
	my $self = shift;
	return $self->{toughness};
}

# sets a string
sub setToughness {
	my $self = shift;
	$self->{toughness} = shift;
	return;
}

# returns a string
sub getLoyalty {
	my $self = shift;
	return $self->{loyalty};
}

# sets a string
sub setLoyalty {
	my $self = shift;
	$self->{loyalty} = shift;
	return;
}

# returns a string
sub getWatermark {
	my $self = shift;
	return $self->{watermark};
}

# sets a string
sub setWatermark {
	my $self = shift;
	$self->{watermark} = shift;
	return;
}

# returns a string
sub getExpansion {
	my $self = shift;
	return $self->{expansion};
}

# sets a string
sub setExpansion {
	my $self = shift;
	$self->{expansion} = shift;
	return;
}

# returns a string
sub setCardType {
	my $self = shift;
	$self->{cardtype} = shift;
	return;
}

# returns an array ref that is a copy of the cost (thus it is safe for
# modification without impact to the card object).
sub getCost {
	my $self = shift;
	my @result = @{$self->{cost}};
	return \@result;
}

# expects an array reference
sub setCost {
	my $self = shift;
	my $ar = shift;
	my @a = @$ar; # we want a copy of it so that it is not inadvertently edited later.
	$self->{cost} = \@a;
	return;
}

# returns an array ref that is a copy of the cost (thus it is safe for
# modification without impact to the card object).
sub getSubtype {
	my $self = shift;
	my @result = @{$self->{subtype}};
	return \@result;
}

# expects an array reference
sub setSubtype {
	my $self = shift;
	my $ar = shift;
	my @a = @$ar; # we want a copy of it so that it is not inadvertently edited later.
	$self->{subtype} = \@a;
	return;
}

# returns an array ref that is a copy of the cost (thus it is safe for
# modification without impact to the card object).
sub getTypes {
	my $self = shift;
	my @result = @{$self->{types}};
	return \@result;
}

# expects an array reference
sub setTypes {
	my $self = shift;
	my $ar = shift;
	my @a = @$ar; # we want a copy of it so that it is not inadvertently edited later.
	$self->{types} = \@a;
	return;
}

# returns a string
sub getCardType {
	my $self = shift;
	return $self->{cardtype};
}

# returns a string
sub getCardText {
	my $self = shift;
	return $self->{card_text};
}

# sets a string
sub setCardText {
	my $self = shift;
	$self->{card_text} = shift;
	$self->{card_text} =~ s/\x{2212}(\d)/-$1/g;
	return;
}

# returns a string
sub getCardTextHTML {
	my $self = shift;
	return $self->{card_text_html};
}

# sets a string
sub setCardTextHTML {
	my $self = shift;
	$self->{card_text_html} = shift;
	$self->{card_text_html} =~ s/\x{2212}(\d)/-$1/g;
	return;
}

# returns a string
sub getFlavorText {
	my $self = shift;
	return $self->{flavor_text};
}

# sets a string
sub setFlavorText {
	my $self = shift;
	$self->{flavor_text} = shift;
	return;
}

# returns a string
sub getFlavorTextHTML {
	my $self = shift;
	return $self->{flavor_text_html};
}

# sets a string
sub setFlavorTextHTML {
	my $self = shift;
	$self->{flavor_text_html} = shift;
	return;
}

# given a card, add new tags to that tag array ref
# that "broaden" the categorization of some of the tags.  For
# instance, "fetch_library_land" is also a "fetch_library" and a
# "fetch".
sub broadenTags {
	my $self = shift;

	if ($self->{type} eq 'Enchantment') {
		$self->addTag('permanent');
		$self->addTag('spell');
	}
	if ($self->{type} eq 'Creature') {
		$self->addTag('creature');
		$self->addTag('permanent');
		$self->addTag('spell');
	}
	if ($self->{type} eq 'Artifact') {
		$self->addTag('permanent');
		$self->addTag('spell');
	}
	if ($self->{type} eq 'Land') {
		$self->addTag('land');
	}
	if ($self->{type} eq 'Instant') {
		$self->addTag('immediate');
		$self->addTag('spell');
	}
	my $tags_ref = $self->{tags};
	#foreach my $kk (keys(%$tags_ref)) {
	#	#print "$kk...\n";
	#	if (grep(/^$kk$/, keys(%$TAG_EXP))) {
	#		foreach my $newt (@{$TAG_EXP->{$kk}}) {
	#			$self->{tags}->{$newt} = 1;
	#			#print "adding $newt for $kk\n";
	#		}
	#	}
	#}
	foreach my $kk (keys(%$tags_ref)) {
		#print STDERR "$kk...\n";
		if (grep(/^$kk$/, keys(%$MTG::TagMap::TAGS))) {
			foreach my $newt (@{$MTG::TagMap::TAGS->{$kk}}) {
				$self->{tags}->{$newt} = 1;
				#print STDERR "adding $newt for $kk\n";
			}
		}
	}
}

1;
