package MTG::Card;

use base qw(Clone MTG::MongoObject);
use strict;
use Clone;
use MTG::MongoObject;

my $TAG_EXP = {
	upkeep => [],
	endstep => [],
	permanent => [],
	tap_down => [],
	tap_creature => ['tap_down'],
	tap_artifact => ['tap_down'],
	untap => [],
	untap_artifact => ['untap'],
	untap_creature => ['untap'],
	haste => ['immediate'],
	flash => ['immediate'],
	immediate => [],
	protection => ['spell_protection'],
	spell_protection => [],
	shroud => ['spell_protection'],
	hexproof => ['spell_protection'],
	creature => ['spell', 'permanent'],
	spell => [],
	enchantment => ['spell'],
	emblem => ['permanent'],
	instant => ['spell', 'immediate'],
	leveler => [],
	removal => [],
	destroy_creature => ['removal'],
	destroy_artifact => ['removal'],
	destroy_enchantment => ['removal'],
	land => ['generate_mana', 'permanent'],
	generate_mana => [],
	generate_mana_multicolor => [],
	generate_mana_colorless => [],
	fetch => ['add_to_hand',],
	fetch_library => ['add_to_hand','fetch'],
	fetch_library_card => ['add_to_hand','fetch', 'fetch_library'],
	fetch_library_land => ['add_to_hand','fetch', 'fetch_library'],
	fetch_library_creature => ['add_to_hand','fetch', 'fetch_library'],
	fetch_library_enchantment => ['add_to_hand','fetch', 'fetch_library'],
	fetch_library_artifact => ['add_to_hand','fetch', 'fetch_library'],
	fetch_library_equipment => ['add_to_hand','fetch', 'fetch_library'],
	fetch_graveyard => ['add_to_hand','fetch'],
	fetch_graveyard_card => ['add_to_hand','fetch', 'fetch_graveyard'],
	fetch_graveyard_land => ['add_to_hand','fetch', 'fetch_graveyard'],
	fetch_graveyard_creature => ['add_to_hand','fetch', 'fetch_graveyard'],
	fetch_graveyard_enchantment => ['add_to_hand','fetch', 'fetch_graveyard'],
	fetch_graveyard_instant => ['add_to_hand','fetch', 'fetch_graveyard'],
	fetch_graveyard_sorcery => ['add_to_hand','fetch', 'fetch_graveyard'],
	library_to_battlefield => [],
	extra_land => [],
	mana_bank => ['generate_mana'],
	pump => [],
	sacrifice => [],
	opponent_sacrifice => [],
	flying => ['reach'],
	reach => [],
	fear => [],
	regenerate => [],
	bloodthirst => ['pump','morbid'],
	morbid => [],
	landfall => [],
	exile => [],
	affects_graveyard => [],
	exile_from_graveyard => ['exile', 'effects_graveyard'],
	additional_cost => [],
	aura => [],
	shuffle => ['affects_library'],
	affects_library => [],
	planeswalker => [],
	equipment_to_battlefield => [],
	land_to_creature => [],
	infect => [],
	enters_tapped => [],
	scry => ['add_to_hand','draw_card'],
	add_to_hand => [],
	pro_artifact => [],
	artifact => ['spell'],
	draw_card => ['add_to_hand'],
	'return' => [],
	from_graveyard => [],
	return_creature => ['return'],
	return_permanent => ['return'],
	return_battlefield_to_hand => ['return'],
	return_battlefield_to_library => ['return'],
	return_graveyard_to_library => ['return'],
	return_graveyard_to_hand => ['return'],
	return_graveyard_to_battlefield => ['return'],
	target_creature => [],
	target_player => [],
	kicker => [],
	counter => [],
	counter_creature => [],
	vigilance => [],
	trample => [],
	mill => [],
	library_to_graveyard => ['mill'],
	destroy_land => [],
	target_land => [],
	target_spell => [],
	affect_all => [],
	affect_all_players => ['affect_all'],
	affect_all_creatures => ['affect_all'],
	affect_all_nonflying_creatures => ['affect_all','affect_all_creatures'],
	opponent_player_damage => [],
	creature_damage => [],
	gain_life => [],
	lifelink => ['gain_life'],
	flashback => [],
	nonfliers_cant_block => [],
	tap_ability => [],
	nonflier_defense => ['creature_defense'],
	creature_defense => [],
	only_multiple_creatures_can_block => ['requires_special_blocking'],
	unblockable => ['requires_special_blocking'],
	requires_special_blocking => [],
};

sub new {
	my $class = shift;

	# Call the constructor of the parent class, Person.
    my $self = $class->SUPER::new({});
	my $test = shift;
	if (defined $test && ref($test) eq 'HASH') {
        # REVISIT - we should only copy out what we need, not just assign a reference
		foreach my $f (qw(multiverseid name CMC cost type rarity tags expansion subtype toughness power)) {
			$self->{$f} = $test->{$f};
		}
	}
	if (! defined $self->{multiverseid}) {
		$self->{multiverseid} = 1;
	}
	if (! defined $self->{name}) {
		$self->{name} = '';
	}
	if (! defined $self->{CMC}) {
		$self->{CMC} = 1;
	}
	if (! defined $self->{cost}) {
		$self->{cost} = [];
	}
	if (! defined $self->{type}) {
		$self->{type} = '';
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
		$self->{subtype} = '';
	}
	if (! defined $self->{toughness}) {
		$self->{toughness} = 0;
	}
	if (! defined $self->{power}) {
		$self->{power} = 0;
	}
	push(@{$self->{serializable}}, qw(multiverseid name CMC cost type rarity tags expansion subtype toughness power));
	bless($self, $class);
	return $self;
}

sub addTag {
	my $self = shift;
	my $tag = shift;
	$self->{tags}->{$tag} = 1;
}

sub getName {
	my $self = shift;
	return $self->{name};
}

sub getId {
	my $self = shift;
	return $self->{multiverseid};
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

# returns a string
sub getType {
	my $self = shift;
	return $self->{type};
}

# given a card, add new tags to that tag array ref
# that "broaden" the categorization of some of the tags.  For
# instance, "fetch_library_land" is also a "fetch_library" and a
# "fetch".
sub broadenTags {
	my $self = shift;

	if ($self->{type} eq 'Enchantment') {
		$self->addTag('spell');
	}
	if ($self->{type} eq 'Creature') {
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
	foreach my $kk (keys(%$tags_ref)) {
		#print "$kk...\n";
		if (grep(/^$kk$/, keys(%$TAG_EXP))) {
			foreach my $newt (@{$TAG_EXP->{$kk}}) {
				$self->{tags}->{$newt} = 1;
				#print "adding $newt for $kk\n";
			}
		}
	}
}

1;
