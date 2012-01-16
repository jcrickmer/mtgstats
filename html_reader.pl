#!/usr/bin/perl

use strict;
use utf8;
use HTML::Parser;
use Data::Dumper;
use MTG::Database;
use MTG::Card;
use MTG::Util qw(trim html2Plain);

my $db = MTG::Database->new();

my @terms = qw(Islandwalk Forestwalk Swampwalk Plainswalk Moutainwalk indestructible Absorb Affinity Amplify Annihilator Attach Banding Bloodthirst Bury Bushido Buyback Cascade Champion Changeling Channel Chroma Clash Conspire Convoke Cycling Deathtouch Defender Delve Devour Domain Dredge Echo Enchant Entwine Epic Evoke Exalted Exile Fading Fateseal Fear Fight Flanking Flashback Flash Flip Flying Forecast Fortify Frenzy Graft Grandeur Gravestorm Haste Haunt Hellbent Hexproof Hideaway Horsemanship Imprint Infect Intimidate Kicker Kinship Landfall Landhome Landwalk Lifelink Madness Metalcraft Modular Morbid Morph Multikicker Ninjutsu Offering Persist Phasing Poisonous Protection Provoke Prowl Radiance Rampage Reach Rebound Recover Regenerate Reinforce Replicate Retrace Ripple Scry Shadow Shroud Soulshift Splice Storm Substance Sunburst Suspend Sweep Threshold Kicker Trample Transfigure Transform Transmute Unearth Vanishing Vigilance Wither);
push @terms, 'Aura swap', 'Bands with other', 'Double strike', 'First strike', 'Join forces', 'Level up', 'Split second', 'Cumulative upkeep', 'Totem armor';

my @files = ();
opendir DIR, 'card_html' || die("Cannot open diectory.");
while (my $file = readdir DIR){
	if ($file =~ /^\w.*\.html$/) {
		push @files, 'card_html/'.$file; 
	}
}

my $inLabelDiv = 0;
my $inValueDiv = 0;
my $lastLabel = undef;
my $result = {};
my $btext = '';
my $nest = 0;
sub start_handler {
    my $self = shift;
	my $tagname = shift;
	my $attr = shift;
	my $text = shift;
	if ($inLabelDiv || $inValueDiv) {
		$nest++;
		$btext = $btext . $text;
	} else {
		if ($tagname eq 'div') {
			$inLabelDiv = $attr->{class} =~ /label/;
			$inValueDiv = $attr->{class} =~ /value/;
		}
		if ($tagname eq 'form') {
			# going after multiverseid
			$attr->{action} =~ /Details\.aspx\?multiverseid=(\d+)/;
			if ($1) {
				$result->{multiverseid} = $1;
			}
		}
	}
}
sub text_handler {
    my $self = shift;
	my $dtext = shift;
	if ($inLabelDiv || $inValueDiv) {
		$btext = $btext . $dtext;
#		#print "'" . $dtext . "'\n";
#		if ($inLabelDiv) {
#			$lastLabel = $dtext;
#		}
#		if ($inValueDiv) {
#			$result->{$lastLabel} = $dtext;
#			$lastLabel = undef;
#		}
	}
}
sub end_handler {
    my $self = shift;
    my $tagname = shift;
	if ($tagname eq 'div' && $nest == 0) {
		if ($inLabelDiv) {
			$btext = trim($btext);
			$btext =~ s/(\S):?\s*$/$1/;
			#print "LABEL: " . $btext . "\n";
			$lastLabel = $btext;
			$btext = '';
			$inLabelDiv = 0;
		}
		if ($inValueDiv) {
			$btext = trim($btext);
			$btext =~ s/(\s)\s*/$1/gi;
			#print "VALUE: " . $btext . "\n";
			$result->{$lastLabel} = $btext;
			$lastLabel = undef;
			$btext = '';
			$inValueDiv = 0;
		}
	} else {
		if ($inLabelDiv || $inValueDiv) {
			$btext = $btext . '</' . $tagname . '>';
		}
		$nest = 0 > $nest - 1 ? 0 : $nest - 1;
	}
}


foreach my $file (@files) {
	$inLabelDiv = 0;
	$inValueDiv = 0;
	$lastLabel = undef;
	$result = {};
	$btext = '';
	$nest = 0;
	my $p = HTML::Parser->new(api_version => 3);
	$p->handler(start => \&start_handler, "self,tagname,attr,text");
	$p->handler(text => \&text_handler, "self,text");
	$p->handler(end => \&end_handler, "self,tagname");
	$p->empty_element_tags(1);
	open(my $fh, "<:utf8", $file) || die "...: $!";
	$p->parse_file($fh);
	
	my $card = MTG::Card->new();
	$card->{multiverseid} = [$result->{multiverseid}];

	{
		my $v = $result->{Types};
		$v =~ s/^.+>([^<]+)<.+$/$1/;
		my @mts = split (/[-—]/, $v);
		if (@mts > 1) {
			my $tttt = trim(@mts[0]);
			if ($tttt =~ /Legendary Creature/) {
				$card->{cardtype} = 'Legendary Creature';
				$card->{type} = 'Creature';
				$card->addTag('legendary');
			} elsif ($tttt =~ /Artifact Creature/) {
				$card->{cardtype} = 'Artifact Creature';
				$card->{type} = 'Creature';
				$card->addTag('artifact');
			} elsif ($tttt =~ /Basic Land/) {
				$card->{cardtype} = 'Basic Land';
				$card->{type} = 'Land';
				$card->addTag('generate_mana');
			} else {
				$card->{type} = $tttt;
				$card->{cardtype} = $tttt;
			}
			
			for (my $qq = 1; $qq < @mts; $qq++) {
				my $gfd = trim(@mts[$qq]);
				if (length($gfd) > 0) {
					push @{$card->{subtype}}, split(/\s/, $gfd);
				}
			}
		} else {
			if ($v =~ /Legendary Creature/) {
				$card->{cardtype} = 'Legendary Creature';
				$card->{type} = 'Creature';
				$card->addTag('legendary');
			} elsif ($v =~ /Artifact Creature/) {
				$card->{cardtype} = 'Artifact Creature';
				$card->{type} = 'Creature';
				$card->addTag('artifact');
			} elsif ($v =~ /Basic Land/) {
				$card->{cardtype} = 'Basic Land';
				$card->{type} = 'Land';
				$card->addTag('generate_mana');
			} else {
				$card->{type} = $v;
			}
		}
	}
	{
		my $v = $result->{Rarity};
		$v =~ s/^.+>([^<]+)<.+$/$1/;
		$card->{rarity} = $v;
	}
	{
		my $v = $result->{'Card Name'};
		$v =~ s/^<div.*>([^<]+)<\/div>$/$1/;
		$card->{name} = $v;
	}
	{
		my $v = $result->{'Card Text'};
		#$v =~ s/^<div.*>([^<]+)<\/div>$/$1/;
		$card->{'card_text_html'} = trim($v);

		$card->{'card_text'} = html2Plain($v);
	}
	{
		my $v = $result->{'Flavor Text'};

		#$v =~ s/^<div.*><i>([^<]+)<\/i><\/div>$/$1/;
		$card->{'flavor_text_html'} = trim($v);

		$v =~ s/<br[^>]*>/\n/gi;
		$v =~ s/<\/div>/\n\n/gi;
		$v =~ s/<[^>]+>//gi;
		$card->{'flavor_text'} = trim($v);
	}
	if ($card->{type} =~ /Creature/) {
		my $v = $result->{'P/T'};
		$v =~ /^\D*(\d+)\D*\/\D*(\d+)\D*$/;
		$card->{power} = $1;
		$card->{toughness} = $2;
	}
	{
		my $v = $result->{'Converted Mana Cost'};
		$v =~ s/^\D*(\d+)\D*$/$1/;
		$card->{'CMC'} = $v;
	}
	{
		my $v = $result->{'Mana Cost'};
		$v =~ s/<\/img>//g;
		my @cost = ();
		my @parts = split />/, $v;
		foreach my $part (@parts) {
			$part =~ /alt="([^"]+)"/;
			my $vv = $1;
			if ($vv =~ /^\d+$/) {
				for (my $uu = 0; $uu < $vv; $uu++) {
					push @cost, 'any';
				}
			} else {
				$vv =~ s/ or /|/g;
				push @cost, lc($vv);
			}
		}
		$card->{'cost'} = \@cost;
	}
	{
		## All Sets
		my @breaks = split(/>/, $result->{'All Sets'});
		foreach my $bb (@breaks) {
			if ($bb =~ /"Details\.aspx\?multiverseid=(\d+)"/) {
				my $newId = $1;
				if (! grep(/^$newId$/, @{$card->{multiverseid}})) {
					push @{$card->{multiverseid}}, $newId;
				}
			}
		}
	}
	{
		# abilities
		#my @lines = split(/<\/div>/, $card->{'card_text'});
		my $ct = $card->{'card_text_html'};
		foreach my $tterm (@terms) {
			my $ltterm = lc($tterm);
			if ($ct =~ />$tterm/) { $card->addTag($ltterm); }
			if ($ct =~ /, $ltterm/) { $card->addTag($ltterm); }
		}
	}
	if ($card->{type} eq 'Land') {
		$card->addTag('generate_mana');
		if ($card->getName() eq 'Plains') {
			$card->addTag('generate_white_mana');
		} elsif ($card->getName() eq 'Island') {
			$card->addTag('generate_blue_mana');
		} elsif ($card->getName() eq 'Swamp') {
			$card->addTag('generate_black_mana');
		} elsif ($card->getName() eq 'Forest') {
			$card->addTag('generate_green_mana');
		} elsif ($card->getName() eq 'Mountain') {
			$card->addTag('generate_red_mana');
		}
	}
	{
		$card->addTag('needs_tag_review');
	}
	if (! defined $card->{multiverseid}) {
		print "could not parse $file.  Maybe search results?\n";
	} else {
		#print Dumper($result);
		#print Dumper($card) if ($card->{name} =~ /Gyre/);
		#print $card->{name} . ":  " . join(', ', @{$card->{tags}}) . "\n";
		#my $mtgCard = MTG::Card->new($card);
		print $file . ":  " . Dumper($card) if ($card->{name} eq '');
		eval {
			print "inserted " . $card->getName() . ": " . $db->insertCard($card) . "\n";
		};
		if ($@ && ref($@) eq 'MTG::Exception::Unique') {
			print "skipped " . $card->getName() . ": " . $@->{message} . "\n";
		} elsif($@) {
			print Dumper($@);
		}
	}

	close $fh;
}

