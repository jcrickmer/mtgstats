#!/usr/bin/perl

use strict;

use Data::Dumper;

use MTG::Card;
use MTG::DBLoader;

use MongoDB;
use MongoDB::OID;



my $dbl = MTG::DBLoader->new();
my $card = MTG::Card->new({multiverseid=>213799,
						   name=>'Go for the Throat',
						   CMC=>2,
						   cost=>['any', 'black'],
						   affinity_colors=>{},
						   type=>'Instant',
						   rarity=>'Uncommon',
						   tags=>{destroy_creature=>1},
					   });

#print Dumper($card);
$dbl->add($card);

$card = MTG::Card->new({multiverseid=>194106,
						name=>'Melt Terrain',
						CMC=>4,
						cost=>['any', 'any', 'red','red'],
						affinity_colors=>{},
						type=>'Sorcery',
						rarity=>'Common',
						tags=>{target_land=>1,target_player=>1,destroy_land=>1,opponent_player_damage=>1},
					});
$dbl->add($card);

$card = MTG::Card->new({multiverseid=>220010,
						name=>'Harvest Pyre',
						CMC=>2,
						cost=>['any', 'red'],
						affinity_colors=>{},
						type=>'Instant',
						rarity=>'Common',
						tags=>{additional_cost=>1,target_creature=>1, creature_damage=>1,exile_from_graveyard=>1},
					});
$dbl->add($card);

$card = MTG::Card->new({multiverseid=>291,
						name=>'Mountain',
						CMC=>0,
						cost=>[],
						affinity_colors=>{},
						type=>'Land',
						rarity=>'Common',
						tags=>{land=>1},
					});
$dbl->add($card);

$card = MTG::Card->new({multiverseid=>220294,
						name=>'Gorehorn Minotaurs',
						CMC=>4,
						cost=>['any','any','red','red'],
						affinity_colors=>{},
						type=>'Creature',
						subtype=>['Minotaur','Warrior'],
						rarity=>'Common',
						power=>3,
						toughness=>3,
						tags=>{creature=>1,bloodthirst=>1},
					});
$dbl->add($card);

$card = MTG::Card->new({multiverseid=>220959,
						name=>'Goblin Fireslinger',
						CMC=>1,
						cost=>['red'],
						affinity_colors=>{},
						type=>'Creature',
						subtype=>['Goblin','Warrior'],
						rarity=>'Common',
						power=>1,
						toughness=>1,
						tags=>{creature=>1,tap_ability=>1, target_player=>1,opponent_player_damage=>1},
					});
$dbl->add($card);

$card = MTG::Card->new({multiverseid=>220277,
						name=>'Stormblood Berserker',
						CMC=>2,
						cost=>['any','red'],
						affinity_colors=>{},
						type=>'Creature',
						subtype=>['Human','Berserker'],
						rarity=>'Uncommon',
						power=>1,
						toughness=>1,
						tags=>{creature=>1,bloodthirst=>1,only_multiple_creatures_can_block=>1},
					});
$dbl->add($card);

$card = MTG::Card->new({multiverseid=>14660,
						name=>'Volcanic Dragon',
						CMC=>6,
						cost=>['any','any','any','any','red','red'],
						affinity_colors=>{},
						type=>'Creature',
						subtype=>['Dragon'],
						rarity=>'Uncommon',
						power=>4,
						toughness=>4,
						tags=>{creature=>1,flying=>1,haste=>1},
					});
$dbl->add($card);

$card = MTG::Card->new({multiverseid=>230774,
						name=>'Balefire Dragon',
						CMC=>7,
						cost=>['any','any','any','any','any', 'red','red'],
						affinity_colors=>{},
						type=>'Creature',
						subtype=>['Dragon'],
						rarity=>'Mythic Rare',
						power=>6,
						toughness=>6,
						tags=>{creature=>1,flying=>1,affect_all_creatures=>1},
					});
$dbl->add($card);

$card = MTG::Card->new({multiverseid=>234568,
						name=>'Tectonic Rift',
						CMC=>4,
						cost=>['any','any','any','red'],
						affinity_colors=>{},
						type=>'Sorcery',
						rarity=>'Uncommon',
						tags=>{destroy_land=>1,destroy_land=>1,nonfliers_cant_block=>1},
					});
$dbl->add($card);

$card = MTG::Card->new({multiverseid=>14609,
						name=>'Shock',
						CMC=>1,
						cost=>['red'],
						affinity_colors=>{},
						type=>'Instant',
						rarity=>'Common',
						tags=>{target_player=>1,target_creature=>1, creature_damage=>1,opponent_player_damage=>1},
					});
$dbl->add($card);

$card = MTG::Card->new({multiverseid=>247419,
						name=>"Devil's Play",
						CMC=>1,
						cost=>['red'],
						affinity_colors=>{'red'=>1},
						type=>'Sorcery',
						rarity=>'Rare',
						tags=>{target_player=>1,target_creature=>1, creature_damage=>1,opponent_player_damage=>1,flashback=>1},
					});
$dbl->add($card);

$card = MTG::Card->new({multiverseid=>197,
						name=>'Fireball',
						CMC=>1,
						cost=>['red'],
						affinity_colors=>{},
						type=>'Sorcery',
						rarity=>'Uncommon',
						tags=>{target_player=>1,target_creature=>1, creature_damage=>1,opponent_player_damage=>1},
					});
$dbl->add($card);


$card = MTG::Card->new({multiverseid=>220273,
						name=>'Circle of Flame',
						CMC=>2,
						cost=>['any','red'],
						affinity_colors=>{},
						type=>'Enchantment',
						rarity=>'Uncommon',
						tags=>{creature_damage=>1,nonflier_defense=>1,},
					});
$dbl->add($card);

$card = MTG::Card->new({multiverseid=>214054,
						name=>'Slagstorm',
						CMC=>3,
						cost=>['any','red','red'],
						affinity_colors=>{},
						type=>'Enchantment',
						rarity=>'Uncommon',
						tags=>{creature_damage=>1,player_damage=>1,affects_all_players=>1,affect_all_creatures=>1},
					});
$dbl->add($card);

$card = MTG::Card->new({multiverseid=>234438,
						name=>'Traitorous Blood',
						CMC=>3,
						cost=>['any','red','red'],
						affinity_colors=>{},
						type=>'Sorcery',
						rarity=>'Common',
						tags=>{control_creature=>1,target_creature=>1,haste=>1,trample=>1,untap_creature=>1},
					});
$dbl->add($card);

$card = MTG::Card->new({multiverseid=>194383,
						name=>'Whipflare',
						CMC=>2,
						cost=>['any','red'],
						affinity_colors=>{},
						type=>'Sorcery',
						rarity=>'Uncommon',
						tags=>{affects_all_creatures=>1,pro_artifact=>1,creature_damage=>1}
					});
$dbl->add($card);


$card = MTG::Card->new({multiverseid=>249660,
						name=>'Rolling Tremblor',
						CMC=>3,
						cost=>['any','any','red'],
						affinity_colors=>{'red'},
						type=>'Sorcery',
						rarity=>'Uncommon',
						tags=>{affect_all_nonflying_creatures=>1,creature_damage=>1,flashback=>1}
					});
$dbl->add($card);


$card = MTG::Card->new({multiverseid=>245197,
						name=>'Past in Flames',
						CMC=>4,
						cost=>['any','any','red','red'],
						affinity_colors=>{'red'},
						type=>'Sorcery',
						rarity=>'Mythic Rare',
						tags=>{affect_graveyard=>1,flashback=>1,fetch_graveyard_instant=>1,fetch_graveyard_sorcery=>1}
					});
$dbl->add($card);

$card = MTG::Card->new({multiverseid=>218004,
						name=>'Geosurge',
						CMC=>4,
						cost=>['red','red','red','red'],
						affinity_colors=>{'red'},
						type=>'Sorcery',
						rarity=>'Uncommon',
						tags=>{generate_mana=>1}
					});
$dbl->add($card);













