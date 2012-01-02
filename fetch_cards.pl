#!/usr/bin/perl

use strict;

use URI::Escape;

my $agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_5_8) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/15.0.874.121 Safari/535.2';

my @multiverseids = (174808, 174922);

foreach my $id (@multiverseids) {
	my $url = 'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=' . $id;
	my $cmd = 'curl -s -L -A ' . "'" . 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_5_8) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/15.0.874.121 Safari/535.2' . "' " . $url . ' > card_html/' . $id . '.html';
	#print "$id";
	#`$cmd`;
	#`sleep 3`;
}

my @names = ("Animar, Soul of Elements",
"Forest",
"Island",
"Mountain",
"Novijen, Heart of Progress",
"Simic Growth Chamber",
"Valakut, the Molten Pinnacle",
"Rupture Spire",
"Kazandu Refuge",
"Izzet Boilerworks",
"Homeward Path",
"Gruul Turf",
"Evolving Wilds",
"Command Tower",
"Vivid Grove",
"Vivid Creek",
"Vivid Crag",
"Temple of the False God",
"Fungal Reaches",
"Garruk Wildspeaker",
"Hull Breach",
"Hunting Pack",
"Soul's Might",
"Colossal Might",
"Electropotence",
"Lead the Stampede",
"Strength of the Tajuru",
"Fastbond",
"Pemmin's Aura",
"Soul's Fire",
"Ruination",
"Ray of Command",
"Invert the Skies",
"Exclude",
"Essence Scatter",
"Dissipate",
"Fuel for the Cause",
"Negate",
"Cancel",
"Spellbook",
"Eldrazi Monument",
"Lightning Greaves",
"Intet, the Dreamer",
"Deadly Recluse",
"Inkwell Leviathan",
"Grozoth",
"Verdant Force",
"Borborygmos",
"Bringer of the Red Dawn",
"Liege of the Tangle",
"Fierce Empath",
"Artisan of Kozilek",
"Ulamog, the Infinite Gyre",
"Primordial Sage",
"Drumhunter",
"Lumberknot",
"Falkenrath Marauders",
"Scourge of Geier Reach",
"Murder of Crows",
"Bellowing Tanglewurm",
"Garruk's Packleader",
"Riku of Two Reflections",
"Rapacious One",
"Hydra Omnivore",
"Magmatic Force",
"Simic Sky Swallower",
"Carnage Wurm",
"Primordial Hydra",
"Palinchron",
"Jin-Gitaxias, Core Augur",
"Symbiotic Wurm",
"Stingerfling Spider",
"Grazing Gladehart",
"Ulamog's Crusher",
"Wall of Frost",
"Phyrexian Metamorph",
"Bringer of the Green Dawn",
"Experiment Kraj",
"Grim Lavamancer",
"Hellspark Elemental",
"Jackal Pup",
"Jaya Ballard, Task Mage",
"Keldon Champion",
"Keldon Marauders",
"Mogg Fanatic",
"Mogg Flunkies",
"Spark Elemental",
"Vulshok Sorcerer",
"Browbeat",
"Chain Lightning",
"Fireball",
"Fireblast",
"Flames of the Blood Hand",
"Hammer of Bogardan",
"Lightning Bolt",
"Pillage",
"Price of Progress",
"Reverberate",
"Sudden Impact",
"Thunderbolt",
);

my $search_url_base = 'http://gatherer.wizards.com/Pages/Search/Default.aspx?name=';

foreach my $name (@names) {
	my $fn = $name;
	$fn =~ s/(\W)/_/gi;
	if (! -e "card_html/$fn.html") {
		my $url = $search_url_base . &mkQuery($name);
		my $cmd = 'curl -g -s -L -A \'' . $agent . '\' ' . $url . " > card_html/$fn.html";
		print "$name - downloading...\n";
		`$cmd`;
		`sleep 2`;
	} else {
		print "$name - skipping...\n";
	}
}

sub mkQuery {
	my $term = shift;
	my @ts = split(/\s+/, $term);
	my $result = '';
	foreach my $t (@ts) {
		$result = $result . '+[' . uri_escape($t) . ']';
	}
	$result =~ s/'/\\'/gi;
	return $result;
}
