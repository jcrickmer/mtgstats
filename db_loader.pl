#!/usr/bin/perl

use strict;

use Data::Dumper;

use MTG::Card;
use MTG::Deck;
use MTG::Database;
use MTG::Util qw(trim html2Plain);
use MongoDB;
use MongoDB::OID;


my @cards = ();
my $db = MTG::Database->new();

my $card = MTG::Card->new({multiverseid=>[294,205925],
						name=>'Plains',
						CMC=>0,
						cost=>[],
						affinity_colors=>{},
						type=>'Land',
						cardtype=>'Basic Land',
						rarity=>'Common',
						tags=>{land=>1,basic_land=>1,generate_white_mana=>1},
					});
#push @cards, $card;


$card = MTG::Card->new({multiverseid=>288,
						name=>'Forest',
						CMC=>0,
						cost=>[],
						affinity_colors=>{},
						type=>'Land',
						rarity=>'Common',
						tags=>{land=>1,basic_land=>1,generate_green_mana=>1},
					});
#push @cards, $card;

$card = MTG::Card->new({multiverseid=>277,
						name=>'Swamp',
						CMC=>0,
						cost=>[],
						affinity_colors=>{},
						type=>'Land',
						rarity=>'Common',
						tags=>{land=>1,basic_land=>1,generate_black_mana=>1},
					});
#push @cards, $card;

$card = MTG::Card->new({multiverseid=>292,
						name=>'Island',
						CMC=>0,
						cost=>[],
						affinity_colors=>{},
						type=>'Land',
						rarity=>'Common',
						tags=>{land=>1,basic_land=>1,generate_blue_mana=>1},
					});
#push @cards, $card;

$card = MTG::Card->new({multiverseid=>290,
						name=>'Mountain',
						CMC=>0,
						cost=>[],
						affinity_colors=>{},
						type=>'Land',
						rarity=>'Common',
						tags=>{land=>1,basic_land=>1,generate_red_mana=>1},
					});
#push @cards, $card;

$card = MTG::Card->new({multiverseid=>213799,
						   name=>'Go for the Throat',
						   CMC=>2,
						   cost=>['any', 'black'],
						   affinity_colors=>{},
						   type=>'Instant',
						   rarity=>'Uncommon',
						   tags=>{destroy_creature=>1},
					   });
push @cards, $card;

$card = MTG::Card->new({multiverseid=>194106,
						name=>'Melt Terrain',
						CMC=>4,
						cost=>['any', 'any', 'red','red'],
						affinity_colors=>{},
						type=>'Sorcery',
						rarity=>'Common',
						tags=>{target_land=>1,target_player=>1,destroy_land=>1,opponent_player_damage=>1},
					});
push @cards, $card;

$card = MTG::Card->new({multiverseid=>220010,
						name=>'Harvest Pyre',
						CMC=>2,
						cost=>['any', 'red'],
						affinity_colors=>{},
						type=>'Instant',
						rarity=>'Common',
						tags=>{additional_cost=>1,target_creature=>1, creature_damage=>1,exile_from_graveyard=>1},
					});
push @cards, $card;

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
push @cards, $card;

$card = MTG::Card->new({multiverseid=>227061,
						name=>'Bloodline Keeper',
						CMC=>4,
						cost=>['any','any','black','black'],
						affinity_colors=>{'black'},
						type=>'Creature',
						subtype=>['Vampire'],
						rarity=>'Rare',
						power=>3,
						toughness=>3,
						card_text_html => '<div class="cardtextbox">Flying</div><div class="cardtextbox"><img src="/Handlers/Image.ashx?size=small&amp;name=tap&amp;type=symbol" alt="Tap" align="absbottom">: Put a 2/2 black Vampire creature token with flying onto the battlefield.</div><div class="cardtextbox"><img src="/Handlers/Image.ashx?size=small&amp;name=B&amp;type=symbol" alt="Black" align="absbottom">: Transform Bloodline Keeper. Activate this ability only if you control five or more Vampires.</div>',
						card_text => html2Plain('<div class="cardtextbox">Flying</div><div class="cardtextbox"><img src="/Handlers/Image.ashx?size=small&amp;name=tap&amp;type=symbol" alt="Tap" align="absbottom">: Put a 2/2 black Vampire creature token with flying onto the battlefield.</div><div class="cardtextbox"><img src="/Handlers/Image.ashx?size=small&amp;name=B&amp;type=symbol" alt="Black" align="absbottom">: Transform Bloodline Keeper. Activate this ability only if you control five or more Vampires.</div>'),
						tags=>{creature=>1,flying=>1,transformer=>1,generate_token_creatures=>1,pump_by_affinity=>1},
					});
push @cards, $card;
$card = MTG::Card->new({multiverseid=>222186,
						name=>'Tormented Pariah',
						CMC=>4,
						cost=>['any','any','any','red'],
						affinity_colors=>{},
						type=>'Creature',
						subtype=>['Human','Warrior','Werewolf'],
						rarity=>'Common',
						power=>3,
						toughness=>2,
						card_text_html => '<div class="cardtextbox">At the beginning of each upkeep, if no spells were cast last turn, transform Tormented Pariah.</div>',
						card_text => html2Plain('<div class="cardtextbox">At the beginning of each upkeep, if no spells were cast last turn, transform Tormented Pariah.</div>'),
						flavor_text_html => '<div class="cardtextbox"><i>"Hey lads, the moon\'s rising. All the better to watch him beg for mercy."</i></div>',
						flavor_text_html => html2Plain('<div class="cardtextbox"><i>"Hey lads, the moon\'s rising. All the better to watch him beg for mercy."</i></div>'),
						tags=>{creature=>1,transformer=>1,generate_token_creatures=>1},
					});
push @cards, $card;

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
push @cards, $card;

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
push @cards, $card;

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
push @cards, $card;

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
push @cards, $card;

$card = MTG::Card->new({multiverseid=>234568,
						name=>'Tectonic Rift',
						CMC=>4,
						cost=>['any','any','any','red'],
						affinity_colors=>{},
						type=>'Sorcery',
						rarity=>'Uncommon',
						tags=>{destroy_land=>1,destroy_land=>1,nonfliers_cant_block=>1},
					});
push @cards, $card;

$card = MTG::Card->new({multiverseid=>14609,
						name=>'Shock',
						CMC=>1,
						cost=>['red'],
						affinity_colors=>{},
						type=>'Instant',
						rarity=>'Common',
						tags=>{target_player=>1,target_creature=>1, creature_damage=>1,opponent_player_damage=>1},
					});
push @cards, $card;

$card = MTG::Card->new({multiverseid=>247419,
						name=>"Devil's Play",
						CMC=>1,
						cost=>['red'],
						affinity_colors=>{'red'=>1},
						type=>'Sorcery',
						rarity=>'Rare',
						tags=>{target_player=>1,target_creature=>1, creature_damage=>1,opponent_player_damage=>1,flashback=>1},
					});
push @cards, $card;

$card = MTG::Card->new({multiverseid=>197,
						name=>'Fireball',
						CMC=>1,
						cost=>['red'],
						affinity_colors=>{},
						type=>'Sorcery',
						rarity=>'Uncommon',
						tags=>{target_player=>1,target_creature=>1, creature_damage=>1,opponent_player_damage=>1},
					});
push @cards, $card;


$card = MTG::Card->new({multiverseid=>220273,
						name=>'Circle of Flame',
						CMC=>2,
						cost=>['any','red'],
						affinity_colors=>{},
						type=>'Enchantment',
						rarity=>'Uncommon',
						tags=>{creature_damage=>1,nonflier_defense=>1,},
					});
push @cards, $card;

$card = MTG::Card->new({multiverseid=>214054,
						name=>'Slagstorm',
						CMC=>3,
						cost=>['any','red','red'],
						affinity_colors=>{},
						type=>'Enchantment',
						rarity=>'Uncommon',
						tags=>{creature_damage=>1,player_damage=>1,affects_all_players=>1,affect_all_creatures=>1},
					});
push @cards, $card;

$card = MTG::Card->new({multiverseid=>234438,
						name=>'Traitorous Blood',
						CMC=>3,
						cost=>['any','red','red'],
						affinity_colors=>{},
						type=>'Sorcery',
						rarity=>'Common',
						tags=>{control_creature=>1,target_creature=>1,haste=>1,trample=>1,untap_creature=>1},
					});
push @cards, $card;

$card = MTG::Card->new({multiverseid=>194383,
						name=>'Whipflare',
						CMC=>2,
						cost=>['any','red'],
						affinity_colors=>{},
						type=>'Sorcery',
						rarity=>'Uncommon',
						tags=>{affects_all_creatures=>1,pro_artifact=>1,creature_damage=>1}
					});
push @cards, $card;


$card = MTG::Card->new({multiverseid=>249660,
						name=>'Rolling Tremblor',
						CMC=>3,
						cost=>['any','any','red'],
						affinity_colors=>{'red'=>1},
						type=>'Sorcery',
						rarity=>'Uncommon',
						tags=>{affect_all_nonflying_creatures=>1,creature_damage=>1,flashback=>1}
					});
push @cards, $card;


$card = MTG::Card->new({multiverseid=>245197,
						name=>'Past in Flames',
						CMC=>4,
						cost=>['any','any','red','red'],
						affinity_colors=>{'red'=>1},
						type=>'Sorcery',
						rarity=>'Mythic Rare',
						tags=>{affect_graveyard=>1,flashback=>1,fetch_graveyard_instant=>1,fetch_graveyard_sorcery=>1}
					});
push @cards, $card;

$card = MTG::Card->new({multiverseid=>218004,
						name=>'Geosurge',
						CMC=>4,
						cost=>['red','red','red','red'],
						affinity_colors=>{'red'=>1},
						type=>'Sorcery',
						rarity=>'Uncommon',
						tags=>{generate_mana=>1}
					});
push @cards, $card;

$card = MTG::Card->new({multiverseid=>234737,
						name=>'Barbarian Ring',
						affinity_colors=>{'red'=>1},
						type=>'Land',
						rarity=>'Uncommon',
						tags=>{generate_mana=>1, generate_red_mana=>1, target_creature=>1, target_player=>1, creature_damage=>1, player_damage=>1, opponent_player_damage=>1}
					});
push @cards, $card;
$card = MTG::Card->new({multiverseid=>234698,
						name=>'Ghitu Encampment',
						affinity_colors=>{'red'=>1},
						type=>'Land',
						rarity=>'Uncommon',
						tags=>{generate_mana=>1, generate_red_mana=>1, land_to_creature=>1}
					});
push @cards, $card;
$card = MTG::Card->new({multiverseid=>177549,
						name=>'Teetering Peaks',
						affinity_colors=>{'red'=>1},
						type=>'Land',
						rarity=>'Common',
						tags=>{generate_mana=>1, generate_red_mana=>1, pump=>1}
					});
push @cards, $card;
$card = MTG::Card->new({multiverseid=>2259,
						name=>'Ball Lightning',
						CMC=>3,
						cost=>['red','red','red'],
						affinity_colors=>{},
						type=>'Creature',
						subtype=>['Elemental'],
						rarity=>'Rare',
						power=>6,
						toughness=>1,
						tags=>{creature=>1,haste=>1,trample=>1, sacrifice=>1},
					});
push @cards, $card;
$card = MTG::Card->new({multiverseid=>153970,
						name=>'Boggart Ram-Gang',
						CMC=>3,
						cost=>['red|green','red|green','red|green'],
						affinity_colors=>{'red'=>1, 'green'=>1},
						type=>'Creature',
						subtype=>['Goblin','Warrior'],
						rarity=>'Uncommon',
						power=>3,
						toughness=>3,
						tags=>{creature=>1,haste=>1,wither=>1},
					});
push @cards, $card;
$card = MTG::Card->new({multiverseid=>234717,
						name=>'Cinder Pyromancer',
						CMC=>3,
						cost=>['any','any','red'],
						affinity_colors=>{'red'=>1},
						type=>'Creature',
						subtype=>['Elemental','Shaman'],
						rarity=>'Common',
						power=>0,
						toughness=>1,
						tags=>{creature=>1,tap_ability=>1, target_player=>1,opponent_player_damage=>1,untap_creature=>1},
					});
push @cards, $card;
$card = MTG::Card->new({multiverseid=>158106,
						name=>'Figure of Destiny',
						CMC=>1,
						cost=>['red|white'],
						affinity_colors=>{'red'=>1,'white'=>1},
						type=>'Creature',
						subtype=>['Kithkin','Spirit','Warrior','Avatar'],
						rarity=>'Rare',
						power=>1,
						toughness=>1,
						tags=>{creature=>1,leveler=>1, flying=>1,first_strike=>1},
					});
push @cards, $card;
$card = MTG::Card->new({multiverseid=>234702,
						name=>'Fire Servant',
						CMC=>5,
						cost=>['any','any','any','red','red'],
						affinity_colors=>{'red'=>1},
						type=>'Creature',
						subtype=>['Elemental'],
						rarity=>'Uncommon',
						power=>4,
						toughness=>3,
						tags=>{creature=>1,double_damage=>1},
					});
push @cards, $card;



foreach my $cc (@cards) {
	eval {
		print "inserted " . $db->insertCard($cc) . "\n";
	};
	if ($@ && ref($@) eq 'MTG::Exception::Unique') {
		print "skipped " . $cc->getName() . ". " . $@->{message} . "\n";
	} elsif($@) {
		print Dumper($@);
	}
}

my $deck = MTG::Deck->new($db);
$deck->addCard("Harvest Pyre",2);
$deck->addCard("Mountain", 23);
$deck->addCard("Devil's Play",4);
$deck->addCard("Melt Terrain");
$deck->addCard("Balefire Dragon", 2);
$deck->addCard("Volcanic Dragon", 2);
$deck->addCard("Whipflare", 2);
$deck->addCard("Gorehorn Minotaurs",2);
$deck->addCard("Stormblood Berserker",2);
$deck->addCard("Fireball",3);
$deck->addCard("Shock",2);
$deck->addCard("Tectonic Rift",2);
$deck->addCard("Goblin Fireslinger",4);
$deck->addCard("Circle of Flame",2);
$deck->addCard("Slagstorm");
$deck->addCard("Past in Flames");
$deck->addCard("Traitorous Blood",2);
$deck->addCard("Rolling Tremblor",1);
$deck->addCard("Geosurge",2);
$deck->setOwnerId(1);
$deck->setName("Jason Red Punishment");
$deck->setFormat("Standard");
eval {
	$db->insertDeck($deck);
}; if ($@) { print STDERR Dumper($@); }

$deck = MTG::Deck->new($db);
$deck->addCard("Barbarian Ring", 1);
$deck->addCard("Ghitu Encampment", 1);
$deck->addCard("Mountain", 21);
$deck->addCard("Teetering Peaks", 2);
$deck->addCard("Ball Lightning", 1);
$deck->addCard("Boggart Ram-Gang", 1);
$deck->addCard("Cinder Pyromancer", 1);
$deck->addCard("Figure of Destiny", 1);
$deck->addCard("Fire Servant", 1);
$deck->addCard("Grim Lavamancer", 1);
$deck->addCard("Hellspark Elemental", 1);
$deck->addCard("Jackal Pup", 2);
$deck->addCard("Jaya Ballard, Task Mage", 1);
$deck->addCard("Keldon Champion", 1);
$deck->addCard("Keldon Marauders", 2);
$deck->addCard("Mogg Fanatic", 2);
$deck->addCard("Mogg Flunkies", 2);
$deck->addCard("Spark Elemental", 2);
$deck->addCard("Vulshok Sorcerer", 1);
$deck->addCard("Browbeat", 1);
$deck->addCard("Chain Lightning", 1);
$deck->addCard("Fireball", 1);
$deck->addCard("Fireblast", 1);
$deck->addCard("Flames of the Blood Hand", 1);
$deck->addCard("Hammer of Bogardan", 1);
$deck->addCard("Lightning Bolt", 4);
$deck->addCard("Pillage", 1);
$deck->addCard("Price of Progress", 1);
$deck->addCard("Reverberate", 1);
$deck->addCard("Sudden Impact", 1);
$deck->addCard("Thunderbolt", 1);
$deck->setOwnerId(2);
$deck->setName("Premium Deck Series: Fire and Lightning");
$deck->setFormat("Legacy");
eval {
	$db->insertDeck($deck);
}; if ($@) { print STDERR Dumper($@); }

$deck = MTG::Deck->new($db);
$deck->setOwnerId(1);
$deck->setName("APED");
$deck->setFormat("Commander");
$deck->addCard("Animar, Soul of Elements");
$deck->addCard("Forest", 8);
$deck->addCard("Island", 9);
$deck->addCard("Mountain", 8);
$deck->addCard("Novijen, Heart of Progress");
$deck->addCard("Simic Growth Chamber");
$deck->addCard("Valakut, the Molten Pinnacle");
$deck->addCard("Rupture Spire");
$deck->addCard("Kazandu Refuge");
$deck->addCard("Izzet Boilerworks");
$deck->addCard("Homeward Path");
$deck->addCard("Gruul Turf");
$deck->addCard("Evolving Wilds");
$deck->addCard("Command Tower");
$deck->addCard("Vivid Grove");
$deck->addCard("Vivid Creek");
$deck->addCard("Vivid Crag");
$deck->addCard("Temple of the False God");
$deck->addCard("Fungal Reaches");
$deck->addCard("Garruk Wildspeaker");
$deck->addCard("Hull Breach");
$deck->addCard("Hunting Pack");
$deck->addCard("Soul's Might");
$deck->addCard("Colossal Might");
$deck->addCard("Electropotence");
$deck->addCard("Lead the Stampede");
$deck->addCard("Strength of the Tajuru");
$deck->addCard("Fastbond");
$deck->addCard("Pemmin's Aura");
$deck->addCard("Soul's Fire");
$deck->addCard("Ruination");
$deck->addCard("Ray of Command");
$deck->addCard("Invert the Skies");
$deck->addCard("Exclude");
$deck->addCard("Essence Scatter");
$deck->addCard("Dissipate");
$deck->addCard("Fuel for the Cause");
$deck->addCard("Negate");
$deck->addCard("Cancel");
$deck->addCard("Spellbook");
$deck->addCard("Eldrazi Monument");
$deck->addCard("Lightning Greaves");
$deck->addCard("Intet, the Dreamer");
$deck->addCard("Deadly Recluse");
$deck->addCard("Inkwell Leviathan");
$deck->addCard("Grozoth");
$deck->addCard("Verdant Force");
$deck->addCard("Borborygmos");
$deck->addCard("Bringer of the Red Dawn");
$deck->addCard("Liege of the Tangle");
$deck->addCard("Fierce Empath");
$deck->addCard("Artisan of Kozilek");
$deck->addCard("Ulamog, the Infinite Gyre");
$deck->addCard("Primordial Sage");
$deck->addCard("Drumhunter");
$deck->addCard("Lumberknot");
$deck->addCard("Falkenrath Marauders");
$deck->addCard("Scourge of Geier Reach");
$deck->addCard("Murder of Crows");
$deck->addCard("Bellowing Tanglewurm");
$deck->addCard("Garruk's Packleader");
$deck->addCard("Riku of Two Reflections");
$deck->addCard("Rapacious One");
$deck->addCard("Hydra Omnivore");
$deck->addCard("Magmatic Force");
$deck->addCard("Simic Sky Swallower");
$deck->addCard("Carnage Wurm");
$deck->addCard("Primordial Hydra");
$deck->addCard("Palinchron");
$deck->addCard("Jin-Gitaxias, Core Augur");
$deck->addCard("Symbiotic Wurm");
$deck->addCard("Stingerfling Spider");
$deck->addCard("Grazing Gladehart");
$deck->addCard("Ulamog's Crusher");
$deck->addCard("Wall of Frost");
$deck->addCard("Phyrexian Metamorph");
$deck->addCard("Bringer of the Green Dawn");
$deck->addCard("Experiment Kraj");
eval {
	$db->insertDeck($deck);
}; if ($@) { print STDERR Dumper($@); }

$deck = MTG::Deck->new($db);
$deck->setOwnerId(4);
$deck->setName("Green-Blue Infect");
$deck->setFormat("Standard");
$deck->setDate("2011-07-01");
$deck->addCard("Forest",10);
$deck->addCard("Inkmoth Nexus",4);
$deck->addCard("Island",5);
$deck->addCard("Misty Rainforest",4);
$deck->addCard("Blighted Agent",4);
$deck->addCard("Glistener Elf",4);
$deck->addCard("Ichorclaw Myr",4);
$deck->addCard("Apostle's Blessing",3);
$deck->addCard("Distortion Strike",4);
$deck->addCard("Gitaxian Probe",3);
$deck->addCard("Groundswell",4);
$deck->addCard("Livewire Lash",3);
$deck->addCard("Mutagenic Growth",4);
$deck->addCard("Vines of Vastwood",4);
$deck->addCard("Nature's Claim",3,"sideboard");
$deck->addCard("Spell Pierce",4,"sideboard");
$deck->addCard("Spellskite",4,"sideboard");
$deck->addCard("Viridian Corrupter",4,"sideboard");
eval {
	$db->insertDeck($deck);
}; if ($@) { print STDERR Dumper($@); }

$deck = MTG::Deck->new($db);
$deck->setOwnerId(1);
$deck->setName("Vamps Innistrad FNM Booster Draft January 13, 2012");
$deck->setFormat("Booster Draft");
$deck->setDate("2012-01-13");
$deck->addCard("Mountain",7);
$deck->addCard("Swamp",9);
$deck->addCard("Shimmering Grotto",1);
$deck->addCard("Ghost Quarter",1);
$deck->addCard("Liliana of the Veil");
$deck->addCard("Bloodline Keeper");
$deck->addCard("Victim of Night");
$deck->addCard("Moan of the Unhallowed");
$deck->addCard("Vampiric Fury",2);
$deck->addCard("Galvanic Juggernaut");
$deck->addCard("Furor of the Bitten");
$deck->addCard("Ghoulraiser");
$deck->addCard("Infernal Plunge");
$deck->addCard("Feral Ridgewolf",2);
$deck->addCard("Manor Skeleton");
$deck->addCard("Walking Corpse");
$deck->addCard("Night Revelers",2);
$deck->addCard("Scourge of Geier Reach");
$deck->addCard("Stromkirk Patrol");
$deck->addCard("Geistflame");
$deck->addCard("Into the Maw of Hell");
$deck->addCard("Dead Weight");
$deck->addCard("Tribute to Hunger");
$deck->addCard("Manor Skeleton",);
$deck->addCard("Spectral Flight",1,"sideboard");
$deck->addCard("Wooden Stake",1,"sideboard");
$deck->addCard("Corpse Lunge",1,"sideboard");
$deck->addCard("Forbidden Alchemy",1,"sideboard");
$deck->addCard("Tormented Pariah",1,"sideboard");
$deck->addCard("Night Terrors",1,"sideboard");
$deck->addCard("Curse of Oblivion",1,"sideboard");
$deck->addCard("Gruesome Deformity",2,"sideboard");
$deck->addCard("Moonmist",1,"sideboard");
$deck->addCard("Cobbled Wings",1,"sideboard");
$deck->addCard("Kindercatch",1,"sideboard");
$deck->addCard("Past in Flames",1,"sideboard");
$deck->addCard("Rooftop Storm",1,"sideboard");
$deck->addCard("Heretic's Punishment",1,"sideboard");
$deck->addCard("Unburial Rites",1,"sideboard");
$deck->addCard("Frightful Delusion",1,"sideboard");
$deck->addCard("Memory's Journey",1,"sideboard");
$deck->addCard("Claustrophobia",1,"sideboard");
$deck->addCard("Burning Vengeance",1,"sideboard");
$deck->addCard("Island",3,"sideboard");
$deck->addCard("Swamp",1,"sideboard");
$deck->addCard("Mountain",1,"sideboard");
eval {
	$db->insertDeck($deck);
}; if ($@) { print STDERR Dumper($@); }
