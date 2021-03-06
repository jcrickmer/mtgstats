package MTG::GathererLoader;

use strict;
use utf8;
use HTML::Parser;
use Data::Dumper;
use MTG::Database;
use MTG::Card;
use MTG::TagMap;
use MTG::Util qw(trim html2Plain);
use URI::Escape;

sub new {
	my $class = shift;
	my $db = shift;
	my $self = {db=>$db};
	bless($self, $class);
	return $self;
}

sub readCardDir {
	my $self = shift;
	my $progress_glob = shift;
	my $startPos = shift || 0;
	my $limit = shift || 100000;
	my @files = ();
	opendir DIR, 'card_html' || die("Cannot open diectory.");
	while (my $file = readdir DIR){
	    if ($file =~ /^\w.*\.html$/) {
			push @files, 'card_html/'.$file; 
			#print "ADDING ". $file . "\n";
	    }
	}
	my @ordered_files  = (sort @files)[$startPos .. ($limit > @files ? @files : $limit)];
	$self->readCard(\@ordered_files, $progress_glob);
}

# takes a file name, or array ref of file names.  Returns a results
# hash with keys of the filenames you passed in, and a value that is a
# hash with keys "status", "cardid", and "msg".
sub readCard {
	my $self = shift;
	my $files_a;
	if (ref @_[0] eq '') {
		$files_a = [shift];
	} elsif (ref @_[0] eq 'ARRAY') {
		$files_a = shift;
	}
	my $progress_glob = shift;
	my $results = {};

	my @terms = qw(Islandwalk Forestwalk Swampwalk Plainswalk Moutainwalk indestructible Absorb Affinity Amplify Annihilator Attach Banding Bloodthirst Bury Bushido Buyback Cascade Champion Changeling Channel Chroma Clash Conspire Convoke Cycling Deathtouch Defender Delve Devour Domain Dredge Echo Enchant Entwine Epic Evoke Exalted Exile Fading Fateseal Fear Fight Flanking Flashback Flash Flip Flying Forecast Fortify Frenzy Graft Grandeur Gravestorm Haste Haunt Hellbent Hexproof Hideaway Horsemanship Imprint Infect Intimidate Kicker Kinship Landfall Landhome Landwalk Lifelink Madness Metalcraft Modular Morbid Morph Multikicker Ninjutsu Offering Persist Phasing Poisonous Protection Provoke Prowl Radiance Rampage Reach Rebound Recover Regenerate Reinforce Replicate Retrace Ripple Scry Shadow Shroud Soulshift Splice Storm Substance Sunburst Suspend Sweep Threshold Kicker Trample Transfigure Transform Transmute Unearth Vanishing Vigilance Wither);
	push @terms, 'Aura swap', 'Bands with other', 'Double strike', 'First strike', 'Join forces', 'Level up', 'Split second', 'Cumulative upkeep', 'Totem armor';

	my $inLabelDiv = 0;
	my $inValueDiv = 0;
	my $lastLabel = undef;
	my $cardCounter = 0;
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
            # This does not seem to work.  Cards that are retreived by
            # name instead of multiverseid seem to still match this
            # and set multiverseid to a text string instead of digits.
            # Very odd.
			if ($tagname eq 'form') {
				# going after multiverseid
				if ($attr->{action} =~ /Details\.aspx\?multiverseid=(\d+)/) {
					#print STDERR "78 - Setting multiverseid to $1\n";
					$result->{0}->{multiverseid} = $1;
				}
			}
			if ($tagname eq 'img') {
				# going after multiverseid
				if ($attr->{src} =~ /Image\.as.x\?multiverseid=(\d+)/) {
					#print STDERR "86 - Setting multiverseid to $1\n";
					$result->{0}->{multiverseid} = $1;
				}
			}
			if ($tagname eq 'td') {
				if ($attr->{class} =~ /cardComponentContainer/) {
					#print "THIS IS THE START OF A NEW CARD.\n";
					#print Dumper($result);
					if (defined $result->{$cardCounter}->{'Card Name'}) {
						$cardCounter++;
						$result->{$cardCounter}->{'multiverseid'} = $result->{0}->{'multiverseid'};
					}
				}
			}
		}
	}
	sub text_handler {
		my $self = shift;
		my $dtext = shift;
		if ($inLabelDiv || $inValueDiv) {
			$btext = $btext . $dtext;
			#print "'" . $dtext . "'\n";
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
				$result->{$cardCounter}->{$lastLabel} =+ $btext;
				$lastLabel = undef;
				$btext = '';
				$inValueDiv = 0;
			}
		} else {
			#print "======ELSE=====" . $tagname . "\n";
			if ($inLabelDiv || $inValueDiv) {
				$btext = $btext . '</' . $tagname . '>';
			}
			$nest = 0 > $nest - 1 ? 0 : $nest - 1;
		}
	}
	
	foreach my $file (@$files_a) {
		next if (! defined $file);
        # new card, reset all of these values.
		$inLabelDiv = 0;
		$inValueDiv = 0;
		$lastLabel = undef;
		$result = {};

		my $colorSymbs = {'white' => '{w}',
						  'blue' => '{u}',
						  'black' => '{b}',
						  'red' => '{r}',
						  'green' => '{g}',
						  'two or white' => '{2w}',
						  'two or blue' => '{2u}',
						  'two or black' => '{2b}',
						  'two or red' => '{2r}',
						  'two or green' => '{2g}',
						  'white or blue' => '{wu}',
						  'white or black' => '{wb}',
						  'blue or black' => '{ub}',
						  'blue or red' => '{ur}',
						  'black or red' => '{br}',
						  'black or green' => '{bg}',
						  'red or green' => '{rg}',
						  'red or white' => '{rw}',
						  'green or white' => '{gw}',
						  'green or blue' => '{gu}',
						  'phyrexian white' => '{wp}',
						  'phyrexian blue' => '{up}',
						  'phyrexian black' => '{bp}',
						  'phyrexian red' => '{rp}',
						  'phyrexian green' => '{gp}',
						  'variable colorless' => '{x}',
					  };

		$cardCounter = 0; # This counts the number of cards that show up on this one HTML page. It is for handling cards like "Beck // Call" and "Wear // Tear".
		$btext = '';
		$nest = 0;
		my $p = HTML::Parser->new(api_version => 3);
		$p->handler(start => \&start_handler, "self,tagname,attr,text");
		$p->handler(text => \&text_handler, "self,text");
		$p->handler(end => \&end_handler, "self,tagname");
		$p->empty_element_tags(1);
		open(my $fh, "<:utf8", $file) || die "cannot open file... \"$file\": $!";
		$p->parse_file($fh);
		#print Dumper($result); # if a field is missing, but it looks like it is in the HTML, this is a good place to take a peek.
		my $resultCards = $result;
		foreach my $cardIndex (keys %$resultCards) {
			my $result = $resultCards->{$cardIndex};
			my $card = MTG::Card->new();
			if (defined $result->{multiverseid} && $result->{multiverseid} ne '') {
				$card->addMultiverseId($result->{multiverseid});
			}
			if (! defined $result->{name}) {
				#print "BOGUS, MAN\n";
			}
			{
				my $v = $result->{Types};
				$v =~ s/^.+>([^<]+)<.+$/$1/;
				$v =~ s/\x{2019}/'/;
				my @mts = split (/[-—]/, $v, 2);
				if (@mts > 1) {
					my $tttt = trim(@mts[0]);
					my @yyyy = split(/\s/, $tttt);
					$card->{types} = \@yyyy;
					if ($tttt =~ /Legendary Creature/) {
						$card->{cardtype} = 'Legendary Creature';
						$card->{type} = 'Creature';
						$card->addTag('legendary');
					} elsif ($tttt =~ /Legendary Enchantment Creature/) {
						$card->{cardtype} = $tttt;
						$card->{type} = 'Creature';
						$card->addTag('enchantment');
						$card->addTag('legendary');
					} elsif ($tttt =~ /Legendary Artifact Creature/) {
						$card->{cardtype} = $tttt;
						$card->{type} = 'Creature';
						$card->addTag('artifact');
						$card->addTag('legendary');
					} elsif ($tttt =~ /Enchantment Creature/) {
						$card->{cardtype} = 'Enchantment Creature';
						$card->{type} = 'Creature';
						$card->addTag('enchantment');
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
					my @yyyy = split(/\s/, $v);
					$card->{types} = \@yyyy;
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
						$card->{cardtype} = $v; # added this on 2013-07-21.  Not ure if this is what teh Perl program needs or not, just eems to be missing.  REVISIT.  Not tested
					}
				}
			}
			{
				my $v = $result->{Expansion};
				#print STDOUT "$$$$$$$$$$$\n" . Dumper($result) . "%%%%%%%%%%\n";
				#print STDOUT Dumper($result);
				$v =~ s/^.+>([^<]+)<\/a.+$/$1/;

				$card->{expansion} = $v;
				if ($card->{expansion} =~ /Magic.+Conspiracy$/) {
                # These are hard-codings to deal with some ambiguity in Expansion Set names
					$card->{expansion} = 'Magic: The Gathering - Conspiracy';
				} elsif ($card->{expansion} =~ /Magic.+Commander$/) {
					$card->{expansion} = 'Magic: The Gathering - Commander';
				}
				$v = $result->{Expansion};
				$v =~ /"Details\.aspx\?multiverseid=(\d+)"/;
				$card->{spec_multiverseid} = $1;
			}
			{
				my $v = $result->{Rarity};
				$v =~ s/^.+>([^<]+)<.+$/$1/;
				$card->{rarity} = $v;
			}
			{
				my $v = $result->{'Card Name'};
				$v =~ s/^<div.*>([^<]+)<\/div>$/$1/;
				$card->setName($v);
			}
			{
				my $v = $result->{'Card Text'};
				#$v =~ s/^<div.*>([^<]+)<\/div>$/$1/;
				$card->setCardTextHTML(trim($v));
				
				$card->setCardText(html2Plain($v));
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
				if ($v eq '' || $v == undef) {
					# Gather website was putting bold around this as of July 21, 2013.  Just an HTML mistake that makes my job harder...
					$v = $result->{'<b>P/T:</b>'};
				}
				$v =~ /^\D*(\d+)\D*\/\D*(\d+)\D*$/;
				$card->{power} = $1;
				$card->{toughness} = $2;
			}
			if ($card->{type} =~ /Planeswalker/) {
				my $v = $result->{'Loyalty'};
				$v =~ /^\D*(\d+)\D*$/;
				$card->{loyalty} = $1;
			}
			{
				my $v = $result->{'Converted Mana Cost'};
				$v =~ s/^\D*(\d+)\D*$/$1/;
				$card->{'CMC'} = $v;
			}
			{
				my $v = $result->{'Card #'};
				$v =~ s/^\D*(\d+[aAbBcCdD]?)\D*$/$1/;
				$card->{'expansion_card_number'} = $v;
			}
			{
				my $v = $result->{'Card Number'};
				$v =~ s/^\D*(\d+[aAbBcCdD]?)\D*$/$1/;
				$card->{'expansion_card_number'} = $v;
			}
			{
				my $v = $result->{'Watermark'};
				$v =~ s/^.+>([^<]+)<.+$/$1/;
				$card->{watermark} = $v;
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
						push @cost, lc($vv); ## OLD CODE before trying to get this data into Java/MySQL
					}
				}
				$card->{'cost'} = \@cost;
			}
			{
				my $v = $result->{'Mana Cost'}; # For the Java/MySQL version...
				$v =~ s/<\/img>//g;
				my @cost = ();
				my @parts = split />/, $v;
				foreach my $part (@parts) {
					$part =~ /alt="([^"]+)"/;
					my $vv = $1;
					if ($vv =~ /^\d+$/) {
						push @cost, '{' . $vv . '}';
					} else {
						$vv = lc($vv);
						#$vv =~ s/ or /|/g;
						push @cost, $colorSymbs->{$vv};
					}
				}
				$card->{'truecost'} = \@cost;
			}
			{
				## All Sets
				my @breaks = split(/>/, $result->{'All Sets'});
				foreach my $bb (@breaks) {
					if ($bb =~ /"Details\.aspx\?multiverseid=(\d+)"/) {
						my $newId = $1;
						if (! grep(/^$newId$/, @{$card->{multiverseid}})) {
							#print STDERR "267 - adding id $newId\n";
							$card->addMultiverseId($newId);
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
					my $ultterm = $ltterm;
					$ultterm =~ s/(\W)/_/gi;
					if ($ct =~ />$tterm/) { $card->addTag($ultterm); }
					if ($ct =~ /, $ltterm/) { $card->addTag($ultterm); }
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
				print $progress_glob "could not parse $file.  Maybe search results?\n" if (defined $progress_glob);
				$results->{$file} = {status=>'error', msg=>"Could not parse $file.  Maybe search results?"};
			} else {
				#print Dumper($result);
				#print Dumper($card);
				#print Dumper($card) if ($card->{name} =~ /Gyre/);
				#print $card->{name} . ":  " . join(', ', @{$card->{tags}}) . "\n";
				#my $mtgCard = MTG::Card->new($card);
				if ($card->{name} eq '') {
					#print $progress_glob $file . ":  " . Dumper($card) if (defined $progress_glob);
					$results->{$file} = {status=>'error', msg=>"Could not parse $file.  Possibly a two-faced card?"};
				} else {
					#print "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n";
					#print Dumper($results->{$file});
					#print "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n";
				if (! defined $results->{$file}) {
					$results->{$file} = {status=>'success', cardid=>undef, msg=> "NO DATABASE"};
				}
				my $cardArray = $results->{$file}->{cards};
				if (! defined $cardArray) {
					$cardArray = $results->{$file}->{cards} = [];
				}
				push @{$cardArray}, $card;
## June 14, 2014 - NOT USING the MTG::Database object to do inserts. Just want to get the $results object back.
			    if (0) {
					eval {
						my $oid = $self->{db}->insertCard($card);
						print $progress_glob "inserted " . $card->getName() . ": " . $oid . "\n" if (defined $progress_glob);
						$results->{$file} = {status=>'success', cardid=>$oid, msg=> "Inserted " . $card->getName() . ": " . $oid, card=>$card};
					};
					if ($@ && ref($@) eq 'MTG::Exception::Unique') {
						print $progress_glob "skipped " . $card->getName() . ": " . $@->{message} . "\n" if (defined $progress_glob);
						$results->{$file} = {status=>'skipped',
											 msg=> "Skipped " . $card->getName() . ": " . $@->{message},
											 cardid=>$@->{id},
										 };
					} elsif($@) {
						if (ref($@) eq '') {
							print $progress_glob "ERROR 1. Could not load " . $card->getName() . ": " . $@ . "\n" if (defined $progress_glob);
						} else {
							print $progress_glob "ERROR 2. Could not load " . $card->getName() . ": " . $@->{message} . "\n" if (defined $progress_glob);
						}
						$results->{$file} = {status=>'error', card=>$card, msg=> "Could not load " . $card->getName() . ": " . Dumper($@)};
						#print Dumper($@);
					}
				}
			}
		}
		}
		close $fh;
	}
	return $results;
}

sub fetchCardByName {
	my $self = shift;
	my $name = shift;
	my $filename = shift;
	my $overwrite = shift;
	#my $search_url_base = 'http://gatherer.wizards.com/Pages/Search/Default.aspx?name=';
	my $search_url_base = 'http://gatherer.wizards.com/Pages/Card/Details.aspx?name=';
	my $agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_5_8) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/15.0.874.121 Safari/535.2';
	my $result = 0;

	my $fn = $name;
	$fn =~ s/(\W)/_/gi;
	my $outname = $filename || "card_html/$fn.html";
	if (! -e $outname || $overwrite) {
		my $url = $search_url_base . uri_escape($name); #$self->mkQuery($name);
		my $cmd = 'curl -g -s -L -A \'' . $agent . '\' ' . $url . " > $outname";
		print STDERR "$name - downloading...\n";
		`$cmd`;
		$result = $outname;
	} else {
		print STDERR "$name - skipping...\n";
	}
	return $result;
}

# get a card by multiverseid.  The preferred way to do it.
sub fetchCardByMId {
	my $self = shift;
	my $mid = shift;
	my $filename = shift;
	my $overwrite = shift;
	my $search_url_base = 'http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=';
	my $agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_5_8) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/15.0.874.121 Safari/535.2';
	my $result = undef;

	my $outname = $filename || "card_html/$mid.html";
	if (! -e $outname || $overwrite) {
		my $url = $search_url_base . uri_escape($mid);
		my $cmd = 'curl -g -s -L -A \'' . $agent . '\' ' . $url . " > $outname";
		#print "$name - downloading...\n";
		`$cmd`;
		$result = $outname;
	} else {
		#print "$name - skipping...\n";
	}
	return $result;
}

# sub mkQuery {
# 	my $term = shift;
# 	my @ts = split(/\s+/, $term);
# 	my $result = '';
# 	foreach my $t (@ts) {
# 		$result = $result . '+[' . uri_escape($t) . ']';
# 	}
# 	$result =~ s/'/\\'/gi;
# 	return $result;
# }

1;
