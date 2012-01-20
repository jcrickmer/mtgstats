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
$card = MTG::Card->new({multiverseid=>'226749',
						name=>'Delver of Secrets',
						CMC=>1,
						cost=>['blue'],
						affinity_colors=>{},
						type=>'Creature',
						subtype=>['Human','Wizard'],
						rarity=>'Common',
						power=>1,
						toughness=>1,
						card_text_html => '<div class="cardtextbox">At the beginning of your upkeep, look at the top card of your library. You may reveal that card. If an instant or sorcery card is revealed this way, transform Delver of Secrets.</div>',
						card_text => html2Plain('<div class="cardtextbox">At the beginning of your upkeep, look at the top card of your library. You may reveal that card. If an instant or sorcery card is revealed this way, transform Delver of Secrets.</div>'),
						flavor_text_html => '',
						flavor_text => html2Plain(''),
						tags=>{creature=>1,transformer=>1,flying=>1,peek=>1},
					});
push @cards, $card;
$card = MTG::Card->new({multiverseid=>['222112'],
						name=>'Village Ironsmith',
						CMC=>2,
						cost=>['nay','red'],
						affinity_colors=>{},
						type=>'Creature',
						subtype=>['Human','Werewolf'],
						rarity=>'Common',
						power=>1,
						toughness=>1,
						card_text_html => '
                        <div class="cardtextbox">First strike</div><div class="cardtextbox">At the beginning of each upkeep, if no spells were cast last turn, transform Village Ironsmith.</div>',
						card_text => html2Plain('
                        <div class="cardtextbox">First strike</div><div class="cardtextbox">At the beginning of each upkeep, if no spells were cast last turn, transform Village Ironsmith.</div>'),
						flavor_text_html => '<div class="cardtextbox"><i>Each night, he abandons the trappings of civilization.</i></div>',
						flavor_text => html2Plain('<div class="cardtextbox"><i>Each night, he abandons the trappings of civilization.</i></div>'),
						tags=>{creature=>1,transformer=>1,first_strike=>1},
					});
push @cards, $card;
$card = MTG::Card->new({multiverseid=>'221212',
						name=>['Cloistered Youth'],
						CMC=>2,
						cost=>['any','white'],
						affinity_colors=>{'black'},
						type=>'Creature',
						subtype=>['Human','Horror'],
						rarity=>'Uncommon',
						power=>1,
						toughness=>1,
						card_text_html => '<div class="cardtextbox">At the beginning of your upkeep, you may transform Cloistered Youth.</div>',
						card_text => html2Plain('<div class="cardtextbox">At the beginning of your upkeep, you may transform Cloistered Youth.</div>'),
						flavor_text_html => '<div class="cardtextbox"><i>"I heard her talking in her sleep&mdash;pleading, shrieking, snarling. It was not my daughter\'s voice. That is not my daughter."</i></div>',
						flavor_text => html2Plain('<div class="cardtextbox"><i>"I heard her talking in her sleep&mdash;pleading, shrieking, snarling. It was not my daughter\'s voice. That is not my daughter."</i></div>'),
						tags=>{creature=>1,transformer=>1,drain_life=>1},
					});
push @cards, $card;
$card = MTG::Card->new({multiverseid=>['221211'],
						name=>'Screeching Bat',
						CMC=>3,
						cost=>['any','any','black'],
						affinity_colors=>{'black'},
						type=>'Creature',
						subtype=>['Human','Horror'],
						rarity=>'Uncommon',
						power=>2,
						toughness=>2,
						card_text_html => '<div class="cardtextbox">Flying</div><div class="cardtextbox">At the beginning of your upkeep, you may pay <img src="/Handlers/Image.ashx?size=small&amp;name=2&amp;type=symbol" alt="2" align="absbottom"><img src="/Handlers/Image.ashx?size=small&amp;name=B&amp;type=symbol" alt="Black" align="absbottom"><img src="/Handlers/Image.ashx?size=small&amp;name=B&amp;type=symbol" alt="Black" align="absbottom">. If you do, transform Screeching Bat.</div>',
						card_text => html2Plain('<div class="cardtextbox">Flying</div><div class="cardtextbox">At the beginning of your upkeep, you may pay <img src="/Handlers/Image.ashx?size=small&amp;name=2&amp;type=symbol" alt="2" align="absbottom"><img src="/Handlers/Image.ashx?size=small&amp;name=B&amp;type=symbol" alt="Black" align="absbottom"><img src="/Handlers/Image.ashx?size=small&amp;name=B&amp;type=symbol" alt="Black" align="absbottom">. If you do, transform Screeching Bat.</div>'),
						flavor_text_html => '<div class="cardtextbox"><i>The bat has such clarity of hearing that simple sounds become symphonies.</i></div>',
						flavor_text => html2Plain('<div class="cardtextbox"><i>The bat has such clarity of hearing that simple sounds become symphonies.</i></div>'),
						tags=>{creature=>1,transformer=>1,flying=>1},
					});
push @cards, $card;

$card = MTG::Card->new({multiverseid=>['222016'],
						name=>'Thraben Sentry',
						CMC=>4,
						cost=>['any','any','any','white'],
						affinity_colors=>{},
						type=>'Creature',
						subtype=>['Human','Soldier'],
						rarity=>'Common',
						power=>2,
						toughness=>2,
						card_text_html => '<div class="cardtextbox">Vigilance</div><div class="cardtextbox">Whenever another creature you control dies, you may transform Thraben Sentry.</div>',
						card_text => html2Plain('<div class="cardtextbox">Vigilance</div><div class="cardtextbox">Whenever another creature you control dies, you may transform Thraben Sentry.</div>'),
						flavor_text_html => '<div class="cardtextbox"><i>"Looks like it\'s going to be a quiet night."</i></div>',
						flavor_text => html2Plain('<div class="cardtextbox"><i>"Looks like it\'s going to be a quiet night."</i></div>'),
						tags=>{creature=>1,transformer=>1,vigilance=>1},
					});
push @cards, $card;

$card = MTG::Card->new({multiverseid=>['221209'],
						name=>'Civilized Scholar',
						CMC=>3,
						cost=>['any','any','blue'],
						affinity_colors=>{'red'},
						type=>'Creature',
						subtype=>['Human','Advisor','Mutant'],
						rarity=>'Uncommon',
						power=>0,
						toughness=>1,
						card_text_html => '<div class="cardtextbox"><img src="/Handlers/Image.ashx?size=small&amp;name=tap&amp;type=symbol" alt="Tap" align="absbottom">: Draw a card, then discard a card. If a creature card is discarded this way, untap Civilized Scholar, then transform it.</div>',
						card_text => html2Plain('<div class="cardtextbox"><img src="/Handlers/Image.ashx?size=small&amp;name=tap&amp;type=symbol" alt="Tap" align="absbottom">: Draw a card, then discard a card. If a creature card is discarded this way, untap Civilized Scholar, then transform it.</div>'),
						flavor_text_html => '<div class="cardtextbox"><i>"Me, angry? Of course not. Thanks to my research, I\'m above such petty emotions now."</i></div>',
						flavor_text => html2Plain('<div class="cardtextbox"><i>"Me, angry? Of course not. Thanks to my research, I\'m above such petty emotions now."</i></div>'),
						tags=>{creature=>1,transformer=>1,draw_card=>1,discard=>1,self_mill=>1},
					});
push @cards, $card;

$card = MTG::Card->new({multiverseid=>['222915'],
						name=>'Villagers of Estwald',
						CMC=>3,
						cost=>['any','any','green'],
						affinity_colors=>{},
						type=>'Creature',
						subtype=>['Human','Werewolf'],
						rarity=>'Common',
						power=>2,
						toughness=>3,
						card_text_html => '<div class="cardtextbox">At the beginning of each upkeep, if no spells were cast last turn, transform Villagers of Estwald.</div>',
						card_text => html2Plain('<div class="cardtextbox">At the beginning of each upkeep, if no spells were cast last turn, transform Villagers of Estwald.</div>'),
						flavor_text_html => '<div class="cardtextbox"><i>You can spot a werewolf-infested town by its lack of butcher shops.</i></div>',
						flavor_text => html2Plain('<div class="cardtextbox"><i>You can spot a werewolf-infested town by its lack of butcher shops.</i></div>'),
						tags=>{creature=>1,transformer=>1},
					});
push @cards, $card;

$card = MTG::Card->new({multiverseid=>['222124'],
						name=>'Grizzled Outcasts',
						CMC=>5,
						cost=>['any','any','any','any','green'],
						affinity_colors=>{},
						type=>'Creature',
						subtype=>['Human','Werewolf'],
						rarity=>'Common',
						power=>4,
						toughness=>4,
						card_text_html => '<div class="cardtextbox">At the beginning of each upkeep, if no spells were cast last turn, transform Grizzled Outcasts.</div>',
						card_text => html2Plain('<div class="cardtextbox">At the beginning of each upkeep, if no spells were cast last turn, transform Grizzled Outcasts.</div>'),
						flavor_text_html => '<div class="cardtextbox"><i>Seen as unsavory, the hunters were never allowed in town&mdash;until one night they vanished.</i></div>',
						flavor_text => html2Plain('<div class="cardtextbox"><i>Seen as unsavory, the hunters were never allowed in town&mdash;until one night they vanished.</i></div>'),
						tags=>{creature=>1,transformer=>1},
					});
push @cards, $card;

$card = MTG::Card->new({multiverseid=>['227084'],
						name=>'Kruin Outlaw',
						CMC=>3,
						cost=>['any','red','red'],
						affinity_colors=>{},
						type=>'Creature',
						subtype=>['Human','Rogue','Werewolf'],
						rarity=>'Rare',
						power=>2,
						toughness=>2,
						card_text_html => '<div class="cardtextbox">First strike</div><div class="cardtextbox">At the beginning of each upkeep, if no spells were cast last turn, transform Kruin Outlaw.</div>',
						card_text => html2Plain('<div class="cardtextbox">First strike</div><div class="cardtextbox">At the beginning of each upkeep, if no spells were cast last turn, transform Kruin Outlaw.</div>'),
						flavor_text_html => '<div class="cardtextbox"><i>"Hold tight. I\'ve got a surprise for them."</i></div>',
						flavor_text => html2Plain('<div class="cardtextbox"><i>"Hold tight. I\'ve got a surprise for them."</i></div>'),
						tags=>{creature=>1,transformer=>1,first_strike=>1,double_strike=>1,only_multiple_creatures_can_block=>1,affect_all_your_creatures=>1},
					});
push @cards, $card;

$card = MTG::Card->new({multiverseid=>['222105'],
						name=>'Ulvenwald Mystics',
						CMC=>4,
						cost=>['any','any','green','green'],
						affinity_colors=>{},
						type=>'Creature',
						subtype=>['Human','Shaman','Werewolf'],
						rarity=>'Uncommon',
						power=>3,
						toughness=>3,
						card_text_html => '<div class="cardtextbox">At the beginning of each upkeep, if no spells were cast last turn, transform Ulvenwald Mystics.</div>',
						card_text => html2Plain('<div class="cardtextbox">At the beginning of each upkeep, if no spells were cast last turn, transform Ulvenwald Mystics.</div>'),
						flavor_text_html => '<div class="cardtextbox"><i>"With this ritual, we cast aside our fragile humanity . . ."</i></div>',
						flavor_text => html2Plain('<div class="cardtextbox"><i>"With this ritual, we cast aside our fragile humanity . . ."</i></div>'),
						tags=>{creature=>1,transformer=>1,regenerate=>1},
					});
push @cards, $card;

$card = MTG::Card->new({multiverseid=>['222189'],
						name=>'Mayor of Avabruck',
						CMC=>2,
						cost=>['any','green'],
						affinity_colors=>{},
						type=>'Creature',
						subtype=>['Human','Advisor','Werewolf'],
						rarity=>'Rare',
						power=>1,
						toughness=>1,
						card_text_html => '<div class="cardtextbox">Other Human creatures you control get +1/+1.</div><div class="cardtextbox">At the beginning of each upkeep, if no spells were cast last turn, transform Mayor of Avabruck.</div>',
						card_text => html2Plain('<div class="cardtextbox">Other Human creatures you control get +1/+1.</div><div class="cardtextbox">At the beginning of each upkeep, if no spells were cast last turn, transform Mayor of Avabruck.</div>'),
						flavor_text_html => '<div class="cardtextbox"><i>He can deny his true nature for only so long.</i></div>',
						flavor_text => html2Plain('<div class="cardtextbox"><i>He can deny his true nature for only so long.</i></div>'),
						tags=>{creature=>1,transformer=>1,pump_by_affinity=>1,generate_token_creatures=>1},
					});
push @cards, $card;

$card = MTG::Card->new({multiverseid=>['227409'],
						name=>'Gatstaf Shepherd',
						CMC=>2,
						cost=>['any','green'],
						affinity_colors=>{},
						type=>'Creature',
						subtype=>['Human','Werewolf'],
						rarity=>'Uncommon',
						power=>2,
						toughness=>2,
						card_text_html => '<div class="cardtextbox">At the beginning of each upkeep, if no spells were cast last turn, transform Gatstaf Shepherd.</div>',
						card_text => html2Plain('<div class="cardtextbox">At the beginning of each upkeep, if no spells were cast last turn, transform Gatstaf Shepherd.</div>'),
						flavor_text_html => '<div class="cardtextbox"><i>"What is worse than a wolf in sheep\'s clothing?"</i></div><div class="cardtextbox">&mdash;Wolfhunter\'s riddle</div>',
						flavor_text => html2Plain('<div class="cardtextbox"><i>"What is worse than a wolf in sheep\'s clothing?"</i></div><div class="cardtextbox">&mdash;Wolfhunter\'s riddle</div>'),
						tags=>{creature=>1,transformer=>1,intimidate=>1},
					});
push @cards, $card;

$card = MTG::Card->new({multiverseid=>['221179'],
						name=>'Ludevic\'s Test Subject',
						CMC=>2,
						cost=>['any','blue'],
						affinity_colors=>{},
						type=>'Creature',
						subtype=>['Lizard','Horror'],
						rarity=>'Rare',
						power=>0,
						toughness=>3,
						card_text_html => '<div class="cardtextbox">Defender</div><div class="cardtextbox"><img src="/Handlers/Image.ashx?size=small&amp;name=1&amp;type=symbol" alt="1" align="absbottom"><img src="/Handlers/Image.ashx?size=small&amp;name=U&amp;type=symbol" alt="Blue" align="absbottom">: Put a hatchling counter on Ludevic\'s Test Subject. Then if there are five or more hatchling counters on it, remove all of them and transform it.</div>',
						card_text => html2Plain('<div class="cardtextbox">Defender</div><div class="cardtextbox"><img src="/Handlers/Image.ashx?size=small&amp;name=1&amp;type=symbol" alt="1" align="absbottom"><img src="/Handlers/Image.ashx?size=small&amp;name=U&amp;type=symbol" alt="Blue" align="absbottom">: Put a hatchling counter on Ludevic\'s Test Subject. Then if there are five or more hatchling counters on it, remove all of them and transform it.</div>'),
						flavor_text_html => '',
						flavor_text => html2Plain(''),
						tags=>{creature=>1,transformer=>1,trample=>1},
					});
push @cards, $card;

$card = MTG::Card->new({multiverseid=>['222111'],
						name=>'Reckless Waif',
						CMC=>1,
						cost=>['red'],
						affinity_colors=>{},
						type=>'Creature',
						subtype=>['Human','Werewolf'],
						rarity=>'Uncommon',
						power=>1,
						toughness=>1,
						card_text_html => '<div class="cardtextbox">At the beginning of each upkeep, if no spells were cast last turn, transform Reckless Waif.</div>',
						card_text => html2Plain('<div class="cardtextbox">At the beginning of each upkeep, if no spells were cast last turn, transform Reckless Waif.</div>'),
						flavor_text_html => '<div class="cardtextbox"><i>"Yes, I\'m alone. No, I\'m not worried."</i></div>',
						flavor_text => html2Plain('<div class="cardtextbox"><i>"Yes, I\'m alone. No, I\'m not worried."</i></div>'),
						tags=>{creature=>1,transformer=>1,},
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
						tags=>{generate_mana=>1, generate_red_mana=>1}
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


$deck = MTG::Deck->new($db);
$deck->setOwnerId(1);
$deck->setName("Innistrad WG Humans");
$deck->setFormat("Standard");
$deck->setDate("2011-12-10");
$deck->addCard("Forest",10);
$deck->addCard("Plains",11);
$deck->addCard("Shimmering Grotto",1);
$deck->addCard("Gavony Township",1);
$deck->addCard("Avacyn's Pilgrim",4);
$deck->addCard("Elite Inquisitor",2);
$deck->addCard("Gideon's Lawkeeper",4);
$deck->addCard("Serra Angel",2);
$deck->addCard("Suture Priest",4);
$deck->addCard("Hero of Bladehold",2);
$deck->addCard("Tree of Redemption",1);
$deck->addCard("Mirran Crusader",3);
$deck->addCard("Caravan Vigil",2);
$deck->addCard("Guardians' Pledge",3);
$deck->addCard("Sickleslicer",1);
$deck->addCard("Honor of the Pure",1);
$deck->addCard("Shrine of Loyal Legions",3);
$deck->addCard("Travel Preparations",2);
$deck->addCard("Bonds of Faith",1);
$deck->addCard("Mask of Avacyn",1);
$deck->addCard("Timely Reinforcements",1);
eval {
	$db->insertDeck($deck);
}; if ($@) { print STDERR Dumper($@); }


$deck = MTG::Deck->new($db);
$deck->setOwnerId(11);
$deck->setName("Levy WU GP Austin Innistrad Draft");
$deck->setFormat("Booster Draft");
$deck->setDate("2012-01-07");
$deck->addCard("Island",8);
$deck->addCard("Plains",9);
$deck->addCard("Abbey Griffin",2);
$deck->addCard("Champion of the Parish",1);
$deck->addCard("Chapel Geist",1);
$deck->addCard("Delver of Secrets",1);
$deck->addCard("Doomed Traveler",1);
$deck->addCard("Elder Cathar",2);
$deck->addCard("Geist-Honored Monk",1);
$deck->addCard("Invisible Stalker",1);
$deck->addCard("Selfless Cathar",1);
$deck->addCard("Spectral Rider",1);
$deck->addCard("Stitcher's Apprentice",2);
$deck->addCard("Unruly Mob",1);
$deck->addCard("Voiceless Spirit",1);
$deck->addCard("Dissipate",1);
$deck->addCard("Feeling of Dread",2);
$deck->addCard("Grasp of Phantoms",1);
$deck->addCard("Lost in the Mist",1);
$deck->addCard("Silver-Inlaid Dagger",1);
$deck->addCard("Smite the Monstrous",1);
$deck->addCard("Abbey Griffin",1,"sideboard");
$deck->addCard("Cobbled Wings",1,"sideboard");
$deck->addCard("Furor of the Bitten",1,"sideboard");
$deck->addCard("Ghostly Possession",2,"sideboard");
$deck->addCard("Gruesome Deformity",1,"sideboard");
$deck->addCard("Heartless Summoning",1,"sideboard");
$deck->addCard("Hysterical Blindness",1,"sideboard");
$deck->addCard("Infernal Plunge",1,"sideboard");
$deck->addCard("Nevermore",1,"sideboard");
$deck->addCard("Night Terrors",1,"sideboard");
$deck->addCard("Nightbird's Clutches",1,"sideboard");
$deck->addCard("Sensory Deprivation",1,"sideboard");
$deck->addCard("Somberwald Spider",1,"sideboard");
$deck->addCard("Spare from Evil",1,"sideboard");
$deck->addCard("Thraben Purebloods",1,"sideboard");
$deck->addCard("Urgent Exorcism",1,"sideboard");
$deck->addCard("Wooden Stake",1,"sideboard");
eval {
	$db->insertDeck($deck);
}; if ($@) { print STDERR Dumper($@); }


########
$deck = MTG::Deck->new($db);
$deck->setOwnerId(6);
$deck->setName("Downing RUw GP Austin Innistrad Draft");
$deck->setFormat("Booster Draft");
$deck->setDate("2012-01-07");
$deck->addCard("Island",5);
$deck->addCard("Mountain",9);
$deck->addCard("Plains",1);
$deck->addCard("Shimmering Grotto",1);
$deck->addCard("Ashmouth Hound",2);
$deck->addCard("Bloodcrazed Neonate",1);
$deck->addCard("Delver of Secrets",1);
$deck->addCard("Feral Ridgewolf",1);
$deck->addCard("Kessig Wolf",1);
$deck->addCard("Lantern Spirit",1);
$deck->addCard("Rage Thrower",1);
$deck->addCard("Rakish Heir",2);
$deck->addCard("Skirsdag Cultist",1);
$deck->addCard("Village Ironsmith",1);
$deck->addCard("Brimstone Volley",1);
$deck->addCard("Butcher's Cleaver",1);
$deck->addCard("Feeling of Dread",1);
$deck->addCard("Forbidden Alchemy",1);
$deck->addCard("Geistflame",2);
$deck->addCard("Into the Maw of Hell",1);
$deck->addCard("Silent Departure",1);
$deck->addCard("Think Twice",1);
$deck->addCard("Traitorous Blood",1);
$deck->addCard("Traveler's Amulet",2);
$deck->addCard("Altar's Reap",1,"sideboard");
$deck->addCard("Frightful Delusion",1,"sideboard");
$deck->addCard("Furor of the Bitten",1,"sideboard");
$deck->addCard("Ghost Quarter",1,"sideboard");
$deck->addCard("Gnaw to the Bone",1,"sideboard");
$deck->addCard("Kessig Wolf",1,"sideboard");
$deck->addCard("Maw of the Mire",1,"sideboard");
$deck->addCard("Mulch",1,"sideboard");
$deck->addCard("Orchard Spirit",1,"sideboard");
$deck->addCard("Purify the Grave",1,"sideboard");
$deck->addCard("Skeletal Grimace",1,"sideboard");
$deck->addCard("Spare from Evil",1,"sideboard");
$deck->addCard("Spider Spawning",1,"sideboard");
$deck->addCard("Spidery Grasp",1,"sideboard");
$deck->addCard("Vampire Interloper",1,"sideboard");
$deck->addCard("Vampiric Fury",1,"sideboard");
$deck->addCard("Wreath of Geists",1,"sideboard");
eval {
	$db->insertDeck($deck);
}; if ($@) { print STDERR Dumper($@); }


########
$deck = MTG::Deck->new($db);
$deck->setOwnerId(5);
$deck->setName("Ochao WB GP Austin Innistrad Draft");
$deck->setFormat("Booster Draft");
$deck->setDate("2012-01-07");
$deck->addCard("Plains",8);
$deck->addCard("Swamp", 9);
$deck->addCard("Bloodgift Demon",1);
$deck->addCard("Bloodline Keeper", 1);
$deck->addCard("Cloistered Youth", 2);
$deck->addCard("Diregraf Ghoul");
$deck->addCard("Doomed Traveler");
$deck->addCard("Markov Patrician");
$deck->addCard("Screeching Bat");
$deck->addCard("Skirsdag High Priest");
$deck->addCard("Stromkirk Patrol");
$deck->addCard("Thraben Purebloods");
$deck->addCard("Thraben Sentry");
$deck->addCard("Unruly Mob");
$deck->addCard("Walking Corpse",2);
$deck->addCard("Altar's Reap");
$deck->addCard("Curse of Death's Hold");
$deck->addCard("Ghoulcaller's Chant");
$deck->addCard("Midnight Haunting");
$deck->addCard("Moment of Heroism");
$deck->addCard("Smite the Monstrous",2);
$deck->addCard("Unburial Rites");
$deck->addCard("Civilized Scholar",1, "sideboard");
$deck->addCard("Creeping Renaissance",1, "sideboard");
$deck->addCard("Curse of the Bloody Tome",1, "sideboard");
$deck->addCard("Dream Twist",1, "sideboard");
$deck->addCard("Frightful Delusion",1, "sideboard");
$deck->addCard("Ghostly Possession",1, "sideboard");
$deck->addCard("Hysterical Blindness",2, "sideboard");
$deck->addCard("Infernal Plunge",1, "sideboard");
$deck->addCard("Intangible Virtue",1, "sideboard");
$deck->addCard("Invisible Stalker",1, "sideboard");
$deck->addCard("Memory's Journey",1, "sideboard");
$deck->addCard("Moonmist",1, "sideboard");
$deck->addCard("Nightbird's Clutches",1, "sideboard");
$deck->addCard("Paraselene",1, "sideboard");
$deck->addCard("Runic Repetition",1, "sideboard");
$deck->addCard("Spare from Evil",1, "sideboard");
$deck->addCard("Woodland Sleuth",1, "sideboard");
eval {
	$db->insertDeck($deck);
}; if ($@) { print STDERR Dumper($@); }

########
$deck = MTG::Deck->new($db);
$deck->setOwnerId(7);
$deck->setName("Edwards GW GP Austin Innistrad Draft");
$deck->setFormat("Booster Draft");
$deck->setDate("2012-01-07");
$deck->addCard("Forest",8);
$deck->addCard("Plains",8);
$deck->addCard("Ambush Viper",1);
$deck->addCard("Avacynian Priest",1);
$deck->addCard("Darkthicket Wolf",1);
$deck->addCard("Festerhide Boar",1);
$deck->addCard("Fiend Hunter",1);
$deck->addCard("Galvanic Juggernaut",1);
$deck->addCard("Hamlet Captain",1);
$deck->addCard("Lumberknot",1);
$deck->addCard("Selfless Cathar",1);
$deck->addCard("Village Bell-Ringer",1);
$deck->addCard("Villagers of Estwald",2);
$deck->addCard("Voiceless Spirit",1);
$deck->addCard("Woodland Sleuth",1);
$deck->addCard("Blazing Torch",2);
$deck->addCard("Bonds of Faith",1);
$deck->addCard("Prey Upon",1);
$deck->addCard("Ranger's Guile",1);
$deck->addCard("Rebuke",2);
$deck->addCard("Sharpened Pitchfork",1);
$deck->addCard("Smite the Monstrous",1);
$deck->addCard("Spidery Grasp",1);
$deck->addCard("Ancient Grudge",1,"sideboard");
$deck->addCard("Doomed Traveler",1,"sideboard");
$deck->addCard("Gnaw to the Bone",1,"sideboard");
$deck->addCard("Grizzled Outcasts",1,"sideboard");
$deck->addCard("Inquisitor's Flail",1,"sideboard");
$deck->addCard("Kindercatch",1,"sideboard");
$deck->addCard("Make a Wish",1,"sideboard");
$deck->addCard("Manor Skeleton",1,"sideboard");
$deck->addCard("Maw of the Mire",1,"sideboard");
$deck->addCard("Moonmist",1,"sideboard");
$deck->addCard("Paraselene",1,"sideboard");
$deck->addCard("Rooftop Storm",1,"sideboard");
$deck->addCard("Thraben Purebloods",1,"sideboard");
$deck->addCard("Urgent Exorcism",1,"sideboard");
$deck->addCard("Woodland Sleuth",1,"sideboard");
eval {
	$db->insertDeck($deck);
}; if ($@) { print STDERR Dumper($@); }


########
$deck = MTG::Deck->new($db);
$deck->setOwnerId(8);
$deck->setName("Saylor RB GP Austin Innistrad Draft");
$deck->setFormat("Booster Draft");
$deck->setDate("2012-01-07");
$deck->addCard("Mountain",9);
$deck->addCard("Swamp",8);
$deck->addCard("Ashmouth Hound",1);
$deck->addCard("Bloodcrazed Neonate",1);
$deck->addCard("Geistcatcher's Rig",1);
$deck->addCard("Kruin Outlaw",1);
$deck->addCard("Markov Patrician",1);
$deck->addCard("Pitchburn Devils",1);
$deck->addCard("Rage Thrower",1);
$deck->addCard("Riot Devils",1);
$deck->addCard("Scourge of Geier Reach",1);
$deck->addCard("Skirsdag Cultist",1);
$deck->addCard("Stromkirk Noble",1);
$deck->addCard("Village Cannibals",1);
$deck->addCard("Village Ironsmith",1);
$deck->addCard("Army of the Damned",1);
$deck->addCard("Blazing Torch",1);
$deck->addCard("Bump in the Night",1);
$deck->addCard("Butcher's Cleaver",1);
$deck->addCard("Corpse Lunge",1);
$deck->addCard("Dead Weight",1);
$deck->addCard("Harvest Pyre",1);
$deck->addCard("Heretic's Punishment",1);
$deck->addCard("Moan of the Unhallowed",1);
$deck->addCard("Tribute to Hunger",1);
$deck->addCard("Victim of Night",1);
$deck->addCard("Ambush Viper",1,"sideboard");
$deck->addCard("Ancient Grudge",2,"sideboard");
$deck->addCard("Boneyard Wurm",2,"sideboard");
$deck->addCard("Ghoulraiser",1,"sideboard");
$deck->addCard("Graveyard Shovel",1,"sideboard");
$deck->addCard("Moldgraf Monstrosity",1,"sideboard");
$deck->addCard("Night Terrors",1,"sideboard");
$deck->addCard("Rally the Peasants",1,"sideboard");
$deck->addCard("Ranger's Guile",1,"sideboard");
$deck->addCard("Selfless Cathar",1,"sideboard");
$deck->addCard("Shimmering Grotto",1,"sideboard");
$deck->addCard("Spider Spawning",1,"sideboard");
$deck->addCard("Stromkirk Patrol",1,"sideboard");
$deck->addCard("Tree of Redemption",1,"sideboard");
$deck->addCard("Ulvenwald Mystics",1,"sideboard");
$deck->addCard("Vampiric Fury",1,"sideboard");
eval {
	$db->insertDeck($deck);
}; if ($@) { print STDERR Dumper($@); }


########
$deck = MTG::Deck->new($db);
$deck->setOwnerId(9);
$deck->setName("Howden GUr GP Austin Innistrad Draft");
$deck->setFormat("Booster Draft");
$deck->setDate("2012-01-07");
$deck->addCard("Forest",8);
$deck->addCard("Island",6);
$deck->addCard("Mountain",1);
$deck->addCard("Shimmering Grotto",1);
$deck->addCard("Armored Skaab",1);
$deck->addCard("Avacyn's Pilgrim",1);
$deck->addCard("Darkthicket Wolf",1);
$deck->addCard("Gatstaf Shepherd",1);
$deck->addCard("Hollowhenge Scavenger",1);
$deck->addCard("Ludevic's Test Subject",1);
$deck->addCard("Makeshift Mauler",1);
$deck->addCard("Mayor of Avabruck",1);
$deck->addCard("Moon Heron",2);
$deck->addCard("Murder of Crows",1);
$deck->addCard("One-Eyed Scarecrow",1);
$deck->addCard("Orchard Spirit",1);
$deck->addCard("Pitchburn Devils",1);
$deck->addCard("Selhoff Occultist",1);
$deck->addCard("Brimstone Volley",1);
$deck->addCard("Caravan Vigil",2);
$deck->addCard("Harvest Pyre",1);
$deck->addCard("Prey Upon",1);
$deck->addCard("Ranger's Guile",1);
$deck->addCard("Spectral Flight",1);
$deck->addCard("Spidery Grasp",1);
$deck->addCard("Travel Preparations",1);
$deck->addCard("Altar's Reap",1,"sideboard");
$deck->addCard("Brain Weevil",1,"sideboard");
$deck->addCard("Cobbled Wings",1,"sideboard");
$deck->addCard("Curse of Oblivion",2,"sideboard");
$deck->addCard("Curse of the Nightly Hunt",1,"sideboard");
$deck->addCard("Feral Ridgewolf",1,"sideboard");
$deck->addCard("Grave Bramble",1,"sideboard");
$deck->addCard("Grizzled Outcasts",1,"sideboard");
$deck->addCard("Mask of Avacyn",1,"sideboard");
$deck->addCard("Naturalize",2,"sideboard");
$deck->addCard("Sharpened Pitchfork",1,"sideboard");
$deck->addCard("Thraben Sentry",1,"sideboard");
$deck->addCard("Traitorous Blood",2,"sideboard");
$deck->addCard("Wooden Stake",1,"sideboard");
eval {
	$db->insertDeck($deck);
}; if ($@) { print STDERR Dumper($@); }


########
$deck = MTG::Deck->new($db);
$deck->setOwnerId(10);
$deck->setName("Bursavich URb GP Austin Innistrad Draft");
$deck->setFormat("Booster Draft");
$deck->setDate("2012-01-07");
$deck->addCard("Island",10);
$deck->addCard("Mountain",6);
$deck->addCard("Swamp",1);
$deck->addCard("Ashmouth Hound",1);
$deck->addCard("Battleground Geist",1);
$deck->addCard("Fortress Crab",1);
$deck->addCard("One-Eyed Scarecrow",1);
$deck->addCard("Selhoff Occultist",1);
$deck->addCard("Sturmgeist",1);
$deck->addCard("Tormented Pariah",1);
$deck->addCard("Burning Vengeance",1);
$deck->addCard("Claustrophobia",2);
$deck->addCard("Curse of the Bloody Tome",2);
$deck->addCard("Desperate Ravings",1);
$deck->addCard("Dissipate",1);
$deck->addCard("Dream Twist",2);
$deck->addCard("Forbidden Alchemy",1);
$deck->addCard("Ghoulcaller's Bell",1);
$deck->addCard("Into the Maw of Hell",1);
$deck->addCard("Sensory Deprivation",3);
$deck->addCard("Think Twice",1);
$deck->addCard("Avacynian Priest",1,"sideboard");
$deck->addCard("Back from the Brink",1,"sideboard");
$deck->addCard("Bramblecrush",2,"sideboard");
$deck->addCard("Curse of the Pierced Heart",1,"sideboard");
$deck->addCard("Ghoulcaller's Chant",1,"sideboard");
$deck->addCard("Hollowhenge Scavenger",1,"sideboard");
$deck->addCard("Intangible Virtue",1,"sideboard");
$deck->addCard("Laboratory Maniac",1,"sideboard");
$deck->addCard("Lumberknot",1,"sideboard");
$deck->addCard("Memory's Journey",1,"sideboard");
$deck->addCard("Night Revelers",1,"sideboard");
$deck->addCard("Past in Flames",1,"sideboard");
$deck->addCard("Reckless Waif",1,"sideboard");
$deck->addCard("Scourge of Geier Reach",1,"sideboard");
$deck->addCard("Tormented Pariah",1,"sideboard");
$deck->addCard("Typhoid Rats",1,"sideboard");
$deck->addCard("Vampiric Fury",1,"sideboard");
$deck->addCard("Witchbane Orb",1,"sideboard");
eval {
	$db->insertDeck($deck);
}; if ($@) { print STDERR Dumper($@); }


########

$deck = MTG::Deck->new($db);
$deck->setOwnerId(12);
$deck->setName("Cox BU GP Austin Innistrad Draft");
$deck->setFormat("Booster Draft");
$deck->setDate("2012-01-07");
$deck->addCard("Island",8);
$deck->addCard("Swamp",9);
$deck->addCard("Abattoir Ghoul",1);
$deck->addCard("Armored Skaab",2);
$deck->addCard("Battleground Geist",1);
$deck->addCard("Deranged Assistant",2);
$deck->addCard("Fortress Crab",1);
$deck->addCard("Makeshift Mauler",1);
$deck->addCard("Skaab Goliath",1);
$deck->addCard("Snapcaster Mage",1);
$deck->addCard("Stitched Drake",1);
$deck->addCard("Stromkirk Patrol",1);
$deck->addCard("Typhoid Rats",1);
$deck->addCard("Vampire Interloper",1);
$deck->addCard("Walking Corpse",1);
$deck->addCard("Cackling Counterpart",1);
$deck->addCard("Corpse Lunge",1);
$deck->addCard("Curiosity",1);
$deck->addCard("Dead Weight",1);
$deck->addCard("Ghoulcaller's Chant",1);
$deck->addCard("Grasp of Phantoms",1);
$deck->addCard("Victim of Night",2);
$deck->addCard("Bitterheart Witch",1,"sideboard");
$deck->addCard("Brain Weevil",1,"sideboard");
$deck->addCard("Creepy Doll",1,"sideboard");
$deck->addCard("Fortress Crab",1,"sideboard");
$deck->addCard("Ghoulcaller's Bell",1,"sideboard");
$deck->addCard("Graveyard Shovel",1,"sideboard");
$deck->addCard("Inquisitor's Flail",1,"sideboard");
$deck->addCard("Intangible Virtue",1,"sideboard");
$deck->addCard("Manor Skeleton",1,"sideboard");
$deck->addCard("Moment of Heroism",1,"sideboard");
$deck->addCard("Night Revelers",2,"sideboard");
$deck->addCard("Nightbird's Clutches",1,"sideboard");
$deck->addCard("Rebuke",1,"sideboard");
$deck->addCard("Silverchase Fox",1,"sideboard");
$deck->addCard("Typhoid Rats",1,"sideboard");
$deck->addCard("Voiceless Spirit",1,"sideboard");
$deck->addCard("Woodland Cemetery",1,"sideboard");
eval {
	$db->insertDeck($deck);
}; if ($@) { print STDERR Dumper($@); }
