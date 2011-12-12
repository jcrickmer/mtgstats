package MTG::DBLoader;
use Data::Dumper;
use MTG::Card;

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
    my $self = {config=>{}};
	eval {
		my $conn = MongoDB::Connection->new('host' => 'mongodb://' . ($self->{config}->{host} || 'localhost') . ':' . ($self->{config}->{port} || '27017'));
		my $db = $conn->get_database($self->{config}->{name} || 'mtg');

		# Add few more attributes
		$self->{connection} = $conn;
		$self->{db} = $db;
    }; if (defined $@ && $@ ne '') {
		$@ =~ /^(.+) at (\/?\w.+)$/;
		#IdApp::Exception::DAL->throw(message => $1, show_trace => 1);
		die($@);
    }

	bless($self, $class);

	return $self;
}

sub add {
	my $self = shift;
	my $card = shift; # we need to pass something in, right?
	$self->broadenTags($card);

	my $cards = $self->{db}->get_collection('cards');

	my $doc = {};
	foreach my $kk (keys(%{$card->{fields}})) {
		if ($kk eq 'tags' ||
			$kk eq 'affinity_colors') {
			my @tt = keys(%{$card->{fields}->{$kk}});
			$doc->{$kk} = \@tt;
		} else {
			$doc->{$kk} = $card->{fields}->{$kk};
		}
	}

	#my $id = MongoDB::OID->new;
	$doc->{'_id'} = $doc->{multiverseid};

	my $id;
    eval {
		$id = $cards->insert($doc, {safe => 1});
    };
    if ($@ =~ /^E11000 duplicate key error index:\s\w+\.users\.\$(\w+)_\d+\s+dup key/) {
		# we have a duplicate key on field $1;
		#my $ex = IdApp::Exception::DALUnique->new(message => $1 . ' must be unique', show_trace => 1);
		#$ex->{field} = $1;
		#$ex->throw();
		die($@);
    }
}

# given a card, add new tags to that tag array ref
# that "broaden" the categorization of some of the tags.  For
# instance, "fetch_library_land" is also a "fetch_library" and a
# "fetch".
sub broadenTags {
	my $self = shift;
	my $card = shift;

	if ($card->{type} eq 'Enchantment') {
		$card->{fields}->{tags}->{spellt} = 1;
	}
	if ($card->{type} eq 'Creature') {
		$card->{fields}->{tags}->{spell} = 1;
	}
	if ($card->{type} eq 'Artifact') {
		$card->{fields}->{tags}->{permanent} = 1;
		$card->{fields}->{tags}->{spell} = 1;
	}
	if ($card->{type} eq 'Land') {
		$card->{fields}->{tags}->{permanent} = 1;
	}
	if ($card->{type} eq 'Instant') {
		$card->{fields}->{tags}->{immediate} = 1;
	}
	my $tags_ref = $card->{fields}->{tags};
	foreach my $kk (keys(%$tags_ref)) {
		#print "$kk...\n";
		if (grep(/^$kk$/, keys(%$TAG_EXP))) {
			foreach my $newt (@{$TAG_EXP->{$kk}}) {
				$card->{fields}->{tags}->{$newt} = 1;
				#print "adding $newt for $kk\n";
			}
		}
	}
}


1;
