#!/usr/bin/perl -CS

use strict;
use utf8;
#use diagnostics;
use JSON::XS;
use DBI;
use Data::Dumper;
use MTG::Util qw(makeFilingName);

my $dbh = DBI->connect('DBI:mysql:mtgdbpy','mtgdb','password', {RaiseError=>1, PrintError=>0}) || die "Could not connect to database: $DBI::errstr";
$dbh->{'mysql_enable_utf8'} = 1;
$dbh->do(qq{SET NAMES 'utf8';});

my $filename = $ARGV[0];
my $fix = $ARGV[1]; # should I do things in the database?

#open(my $fh, "<:encoding(UTF-8)", $filename)
open(my $fh, "<", $filename)
    || die "can't open UTF-8 encoded file \"$filename\": $!";

my $json_string = do { local $/; <$fh> };

my $sets_hash = JSON::XS->new->utf8->decode($json_string);

my $types_hash = loadTypes();
my $subtypes_hash = loadSubtypes();
my $colors_hash = loadColors();
my $rarities_hash = loadRarities();
my $marks_hash = loadMarks();
my $expansionsets_hash = {};

foreach my $set (keys %$sets_hash) {
	#foreach my $cc (@{$sets_hash->{$set}->{cards}}) {
	#	print $cc->{multiverseid},"\n";
	#}
	#next;
	print $set, ":: ";
	{
		my $setName = $sets_hash->{$set}->{name};
		my $testSQL = "SELECT id, name, abbr FROM expansionsets WHERE abbr = ? OR name = ?;";
		my $sth = $dbh->prepare($testSQL);
		$sth->execute($set, $setName);
		my ($id, $name, $abbr) = $sth->fetchrow_array()	and $sth->finish();
		if (! defined $id) {
			print "missing!";
			if ($fix) {
				eval {
					my $insertSQL = 'INSERT INTO expansionsets (name, abbr) VALUES (?, ?)';
					my $sth = $dbh->prepare($insertSQL);
					$sth->execute($setName, $set);
				};
				if ($@) {
					print "\n";
					die("Unable to insert expansionset: " . $@);
				} else {
					$id = $dbh->{mysql_insertid};
					print " added as id=$id\n";
				}
			} else {
				print " ignored...\n";
			}
		} else {
			my $prob = undef;
			if ($setName ne $name) {
				$prob = 1;
				print "!! name mismatch json=\"" . $setName . "\", db=\"$name\"";
			}
			if ($set ne $abbr) {
				$prob = 1;
				print "!! abbr for name \"$name\" mismatch json=\"" . $set . "\", db=\"$abbr\"";
			}
			if ($prob) {
				if ($fix) {
					eval {
						my $updateSQL = 'UPDATE expansionsets SET name = ?, abbr = ? WHERE id = ?';
						my $sth = $dbh->prepare($updateSQL);
						$sth->execute($setName, $set, $id);
					};
					if ($@) {
						print "\n";
						die("Unable to update expansionset: " . $@);
					} else {
						my $db_id = $dbh->{mysql_insertid};
						print " updated id $id\n";
					}
				} else {
					print " ignored...\n";
				}
			} else {
				print "ok\n";
			}
		}
		$expansionsets_hash->{$abbr} = $id;
	}

	# now let's get to the cards.
	if ($set ne "UGL" && $set ne "UNH") {
		my $cards = $sets_hash->{$set}->{cards};
		
		# loop through all of the cards
		foreach my $card (@{$cards}) {
			print "-> ", $card->{name}, " (", $card->{multiverseid} , "):\n";
			
			# first of all, we are ONLY doing basic cards...
			if (defined $card->{multiverseid}) {
				#print Dumper($card);

				my $basecard_id = doBasecard($card);

				#doCardColors($card, $basecard_id);

				#doCardTypes($card, $basecard_id);

				#doCardSubtypes($card, $basecard_id);

				#doCard($card, $basecard_id, $set);

				doRulings($card, $basecard_id);

			} else {
				print " skipping " . $card->{layout} . " cards.\n";
			}
		}
	}
}

sub doBasecard {
	my $card = shift;

	# grab the basecard
	my ($id, $name, $rules_text, $cmc, $power, $toughness, $loyalty, $physicalcard_id, $cardposition);
	eval {
		my $testSQL = "SELECT id, name, rules_text, cmc, power, toughness, loyalty, physicalcard_id FROM basecards WHERE name = ?";
		my $sth = $dbh->prepare($testSQL);
		$sth->execute($card->{name});
		($id, $name, $rules_text, $cmc, $power, $toughness, $loyalty, $physicalcard_id, $cardposition) = $sth->fetchrow_array() and $sth->finish();
	};
	if ($@) {
		die("Unable to fetch card \"" . $card->{name} . "\": " . $@);
	}

	my $pos = 'F';
	if ($card->{layout} eq 'double-faced') {
		if ($card->{number} =~ /b$/) {
			$pos = 'B';
		}
	} elsif ($card->{layout} eq 'split') {
		if ($card->{number} =~ /b$/) {
			$pos = 'R';
		} else {
			$pos = 'L';
		}
	} elsif ($card->{layout} eq 'flip') {
		if ($card->{number} =~ /a$/) {
			$pos = 'U';
		} else {
			$pos = 'D';
		}
	}

	if (! defined $id) {
		# basecard doesn't exist - let's add it
		if ($fix) {
			# we need a physical card
			my $physicalcard_id = undef;
			eval {
				my $insertSQL = 'INSERT INTO physicalcards (layout) VALUES (?)';
				my $sth = $dbh->prepare($insertSQL);
				$sth->execute($card->{layout} || 'normal');
			};
			if ($@) {
				print "\n";
				die("Unable to insert physicalcard: " . $@);
			} else {
				$physicalcard_id = $dbh->{mysql_insertid};
				if (! defined $physicalcard_id) {
					die("Seems like a physical card was added, but we didn't get an id.");
				}
			}
			
			# we need a base card
			eval {
				# Fix for planeswalkers with the wrong minus sign:
				$card->{text} =~ s/\x{2212}(\d)/-$1/g;
				
				my $insertSQL = 'INSERT INTO basecards (physicalcard_id, name, filing_name, rules_text, mana_cost, cmc, power, toughness, loyalty, created_at, updated_at, cardposition) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW(), ?)';
				my $sth = $dbh->prepare($insertSQL);
				$sth->execute($physicalcard_id,
							  $card->{name}, 
							  makeFilingName($card->{name}),
							  $card->{text} || '',
							  lc($card->{manaCost}),
							  $card->{cmc} || 0,
							  $card->{power},
							  $card->{toughness},
							  $card->{loyalty},
							  $pos
						  );
				$id = $dbh->{mysql_insertid};
			};
			if ($@) {
				print "\n";
				print "!!!!!! Database Error! Card follows...\n";
				print Dumper($card);
				die("basecard database error: " . $@);
			}
			print "     added, basecard_id=$id\n";
		} else {
			print "     missing and ignored!\n";
		}
	} else {
		if ($fix) {
			eval {
				my $updateSQL = 'UPDATE physicalcards SET layout = ? WHERE id = ?';
				my $sth = $dbh->prepare($updateSQL);
				$sth->execute($card->{layout} || 'normal', $physicalcard_id);
				print " Updated physical card. ";
			};
			if ($@) {
				print "!!!!!! Database Error on physicalcards update! Card follows...\n";
				print Dumper($card);
				die("physicalcards database error: " . $@);
			}

			if ($card->{name} ne $name
				|| $card->{text} ne $rules_text
				|| lc($card->{manaCost}) ne lc($cmc)
				|| $card->{power} != $power
				|| $card->{toughness} ne $toughness
				|| $card->{loyalty} ne $loyalty
				|| $pos ne $cardposition) {
				print " updating basecard... ";
				eval {
					# Fix for planeswalkers with the wrong minus sign:
					$card->{text} =~ s/\x{2212}(\d)/-$1/g;
					
					my $updateSQL = 'UPDATE basecards SET name = ?, filing_name = ?, rules_text = ?, mana_cost = ?, cmc = ?, power = ?, toughness = ?, loyalty = ?, updated_at = NOW(), cardposition = ? WHERE id = ?';
					my $sth = $dbh->prepare($updateSQL);
					$sth->execute($card->{name}, 
								  makeFilingName($card->{name}),
								  $card->{text} || '',
								  lc($card->{manaCost}),
								  $card->{cmc} || 0,
								  $card->{power},
								  $card->{toughness},
								  $card->{loyalty},
								  $pos,
								  $id,
							  );
					print " ok.\n";
				};
				if ($@) {
					print "\n";
					print "!!!!!! Database Error updating basecard! Card follows...\n";
					print Dumper($card);
					die("basecard update database error: " . $@);
				}
			}

		}
		print "     ok, basecard_id=$id\n";
	}
	return $id;
}

sub doCardColors {
	my $card = shift;
	my $basecard_id = shift;

	if ($fix) { # REVISIT - we won't find any cards with the wrong colors!
		if (! defined $card->{colors} || scalar @{$card->{colors}} == 0) {
			push @{$card->{colors}}, 'Colorless';
		}
		foreach my $ccc (@{$card->{colors}}) {
			# I really want to make sure that we are properly cased. Call me anal...
			$ccc = lc($ccc);
			$ccc =~ s/^(.)/uc($1)/e;
			
			eval {
				#INSERT INTO cardcolors (basecard_id, color_id) VALUES (6, 'B');
				my $insertSQL = 'INSERT INTO cardcolors (basecard_id, color_id) VALUES (?, ?)';
				my $sth = $dbh->prepare($insertSQL);
				$sth->execute($basecard_id, $colors_hash->{$ccc}->{id});
			};
			if ($@) {
				if ($@ =~ /Duplicate entry/) {
					# I am ok with trying to do dup entries here.  MySQL will get over it... 
				} else {
					print "!!!!!! Database Error! Card follows...\n";
					print Dumper($card);
					die("color table insert error: " . $@);
				}
			}
		}
	}
}


sub doCardTypes {
	my $card = shift;
	my $basecard_id = shift;

	# jsonmtg has the idea of supertypes in addition to types. We just elide the two.
	my @jtypes;
	foreach my $st (@{$card->{supertypes}}) { push @jtypes, $st; }
	foreach my $t (@{$card->{types}}) { push @jtypes, $t; }

	my $db_result = undef;
	eval {
		my $selectSQL = 'SELECT type FROM cardtypes ct JOIN types t ON ct.type_id = t.id WHERE ct.basecard_id = ? ORDER BY position ASC';
		my $sth = $dbh->prepare($selectSQL);
		$sth->execute($basecard_id);
		$db_result = $sth->fetchall_arrayref();
	};
	if ($@) {
		die("Unable to get card types: " . $@);
	}
	my $type_string = join(' ', map {$_->[0]} @$db_result);
	my $card_type_string = join(' ', @jtypes);
	print "     types:";
	if ($type_string eq $card_type_string) {
		# all good!
		print " ok\n";
	} else {
		if (@$db_result) {
			print "     types: mismatch (db=\"$type_string\" != json=\"$card_type_string\")... ";
			if ($fix) {
				eval {
					my $delSQL = 'DELETE FROM cardtypes WHERE basecard_id = ?';
					my $sth = $dbh->prepare($delSQL);
					$sth->execute($basecard_id);
					print "cleaned old... ";
				};
				if ($@) {
					die("Unable to remove old card types: " . $@);
				}
			} else {
				print " ignored!\n";
			}
		}

		# now let's add the new types, if we are fixing things
		if ($fix) {
			my $pos = 0;
			foreach my $jtype (@jtypes) {
				# do we know about this type?
				if (! defined $types_hash->{$jtype}) {
					$types_hash = addType($jtype);
				}
				my $tid = $types_hash->{$jtype}->{id};
				eval {
					my $insertSQL = 'INSERT INTO cardtypes (basecard_id, type_id, position) VALUES (?, ?, ?)';
					my $sth = $dbh->prepare($insertSQL);
					$sth->execute($basecard_id,
								  $tid,
								  $pos);
				};
			   	if ($@) {
					die("cardtype table insert error on type \"$jtype\" ($tid): " . $@);
				}
				$pos++;
			}
			print " added!\n";
		} else {
			print " ignored!\n";
		}
	}
}


sub doCardSubtypes {
	my $card = shift;
	my $basecard_id = shift;

	my $db_result = undef;
	eval {
		my $selectSQL = 'SELECT subtype FROM cardsubtypes cs JOIN subtypes s ON cs.subtype_id = s.id WHERE cs.basecard_id = ? ORDER BY position ASC';
		my $sth = $dbh->prepare($selectSQL);
		$sth->execute($basecard_id);
		$db_result = $sth->fetchall_arrayref();
	};
	if ($@) {
		die("Unable to get card subtypes: " . $@);
	}
	my $subtype_string = join(' ', map {$_->[0]} @$db_result);
	my $card_subtype_string = '';
	if (defined $card->{subtypes}) {
		$card_subtype_string = join(' ', @{$card->{subtypes}});
		$card_subtype_string =~ s/’/'/gi;
	}
	print "     subtypes:";
	if ($subtype_string eq $card_subtype_string) {
		# all good!
		print " ok\n";
	} else {
		if (@$db_result) {
			print " mismatch (db=\"$subtype_string\" != json=\"$card_subtype_string\")... ";
			if ($fix) {
				eval {
					my $delSQL = 'DELETE FROM cardsubtypes WHERE basecard_id = ?';
					my $sth = $dbh->prepare($delSQL);
					$sth->execute($basecard_id);
					print "cleaned old... ";
				};
				if ($@) {
					die("Unable to remove old card subtypes: " . $@);
				}
			} else {
				print " ignored!\n";
			}
		}

		# now let's add the new subtypes, if we are fixing things
		if ($fix) {
			my $pos = 0;
			foreach my $jsubtype (@{$card->{subtypes}}) {
				$jsubtype =~ s/’/'/gi; # fixes issue with this unicode apostrophe in the mtgjson data
				# do we know about this subtype?
				if (! defined $subtypes_hash->{$jsubtype}) {
					$subtypes_hash = addSubtype($jsubtype);
				}
				my $stid = $subtypes_hash->{$jsubtype}->{id};
				eval {
					my $insertSQL = 'INSERT INTO cardsubtypes (basecard_id, subtype_id, position) VALUES (?, ?, ?)';
					my $sth = $dbh->prepare($insertSQL);
					$sth->execute($basecard_id,
								  $stid,
								  $pos);
				};
			   	if ($@) {
					die("cardsubtype table insert error on type \"$jsubtype\" ($stid): " . $@);
				}
				$pos++;
			}
			print " added!\n";
		} else {
			print " ignored!\n";
		}
	}
}

sub doCard {
	my $card = shift;
	my $basecard_id = shift;
	my $set = shift;

	print "     card: ";
	my ($card_id, $expansionset_abbr, $rarity, $multiverseid, $flavor_text, $card_number, $mark);
	eval {
		my $testSQL = 'SELECT c.id, e.abbr, c.rarity, c.multiverseid, c.flavor_text, c.card_number, m.mark FROM cards c JOIN expansionsets e ON c.expansionset_id = e.id LEFT JOIN marks m ON c.mark_id = m.id WHERE basecard_id = ? AND c.expansionset_id = ? AND c.card_number = ? AND multiverseid = ?';
		my $sth = $dbh->prepare($testSQL);
		$sth->execute($basecard_id, $expansionsets_hash->{$set}, $card->{number}, $card->{multiverseid});
		($card_id, $expansionset_abbr, $rarity, $multiverseid, $flavor_text, $card_number, $mark) = $sth->fetchrow_array() and $sth->finish();
	};
	if ($@) {
		die ("Could not select a card for basecard_id $basecard_id: " . $@);
	}

	# rarities should be good.
	# expansion set should be good too.
	# but check the mark...
	my $mark_id = undef;
	if (defined $card->{watermark}) {
		if (! defined $marks_hash->{$card->{watermark}}) {
			$marks_hash = addMark($card->{watermark});
		}
		$mark_id = $marks_hash->{$card->{watermark}};
	}

	if (defined $card_id) {
		print "exists... ";
		if ($expansionset_abbr ne $set
			|| $rarity ne $rarities_hash->{$card->{rarity}}->{id}
			|| $multiverseid != $card->{multiverseid}
			|| $flavor_text ne $card->{flavor}
			|| $card_number ne $card->{number}
			|| $mark ne $card->{watermark}) {
			print "mismatch (",
			                  $expansionset_abbr, " != ", $set, ", ",
							  $rarity, " != ", $rarities_hash->{$card->{rarity}}->{id}, ", ",
							  $multiverseid, " != ", $card->{multiverseid}, ", ",
							  $flavor_text, " != ", $card->{flavor}, ", ",
							  $card_number, " != ", $card->{number}, ", ",
							  $mark, " != ", $card->{watermark},
							  ")... ";

			my $updateSQL = 'UPDATE cards SET expansionset_id = ?, rarity = ?, flavor_text = ?, card_number = ?, mark_id = ?, updated_at = NOW(), multiverseid = ? WHERE id = ?';
			eval {
			 	my $sth = $dbh->prepare($updateSQL);
				$sth->execute($expansionsets_hash->{$set},
							  $rarities_hash->{$card->{rarity}}->{id},
							  $card->{flavor},
							  $card->{number},
							  $mark_id,
							  $card->{multiverseid}, 
							  $card_id);
				print " updated!\n";
			};
			if ($@) {
				print "!!!!!! Database Error! Card follows...\n";
				print Dumper($card);
				die("card table update error: " . $@);
			}
		} else {
			print "ok\n";
		}
	} else {
		# nothing there...
		print "missing... ";
		if ($fix) {
			my $insertSQL = 'INSERT INTO cards (created_at, updated_at, expansionset_id, basecard_id, rarity, multiverseid, flavor_text, card_number, mark_id) VALUES (NOW(), NOW(), ?, ?, ?, ?, ?, ?, ?)';
			eval {
				my $sth = $dbh->prepare($insertSQL);
				$sth->execute($expansionsets_hash->{$set},
							  $basecard_id,
							  $rarities_hash->{$card->{rarity}}->{id},
							  $card->{multiverseid}, 
							  $card->{flavor},
							  $card->{number},
							  $mark_id);
				$card_id = $sth->{mysql_insertid};
				print " added card $card_id for \"" . $card->{name} . "\" in \"" . $set . "\"\n";
			};
			if ($@) {
				print "!!!!!! Database Error! Card follows...\n";
				print Dumper($card);
				die("card table insert error: " . $@);
			}
		} else {
			print " ignored\n";
		}
	}
}

sub doRulings {
	my $card = shift;
	my $basecard_id = shift;

	print "    Rulings: ";
	my @rulings_db = ();
	my $jsonC = 0;
	if (defined $card->{rulings} && scalar @{$card->{rulings}} > 0) {
		$jsonC = scalar @{$card->{rulings}};
		foreach my $ruling (@{$card->{rulings}}) {
			# no updates in here...
			# REVISIT - we need to do deletes too!
			my ($ruling_id, $ruling_date, $ruling_text);
			eval {
				my $selectSQL = 'SELECT id, ruling_date, ruling_text FROM mtgdbapp_ruling WHERE basecard_id = ? and ruling_text = ?';
				my $sth = $dbh->prepare($selectSQL);
				$sth->execute($basecard_id, $ruling->{text});
				($ruling_id, $ruling_date, $ruling_text) = $sth->fetchrow_array() and $sth->finish();
				push @rulings_db, $ruling_id;
			};
			if ($@) {
				print "!!!!!! Database Error! Card follows...\n";
				print Dumper($card);
				die("select rulings database error: " . $@);
			}
			if (! defined $ruling_id) {
				if (! $fix) {
					print " Missing \"" . substr($ruling->{text}, 15) . "\"... ";
				} else {
					print " Adding \"" . substr($ruling->{text}, 15) . "\"... ";
					eval {
						my $insertSQL = 'INSERT INTO mtgdbapp_ruling (basecard_id, ruling_date, ruling_text) VALUES (?, ?, ?)';
						my $sth = $dbh->prepare($insertSQL);
						$sth->execute($basecard_id, $ruling->{date}, $ruling->{text});
						push @rulings_db, $dbh->{mysql_insertid};
					};
					if ($@) {
						print "!!!!!! Database Error! Card follows...\n";
						print Dumper($card);
						die("card mtgdbapp_ruling table insert error: " . $@);
					}
				}
			}
		}
	}
	print " [db has " . @rulings_db . ", json has " . $jsonC . "]\n";
}


sub loadTypes {
	my $result = {};
	eval {
		my $selectSQL = 'SELECT id, type FROM types';
		my $sth = $dbh->prepare($selectSQL);
		$sth->execute();
		$result = $sth->fetchall_hashref('type');
	};
	if ($@) {
		die("Unable to load types: " . $@);
	}
	return $result;
}

sub loadSubtypes {
	my $result = {};
	eval {
		my $selectSQL = 'SELECT id, subtype FROM subtypes';
		my $sth = $dbh->prepare($selectSQL);
		$sth->execute();
		$result = $sth->fetchall_hashref('subtype');
	};
	if ($@) {
		die("Unable to load subtypes: " . $@);
	}
	return $result;
}

sub loadRarities {
	my $result = {};
	eval {
		my $selectSQL = 'SELECT id, rarity FROM rarities';
		my $sth = $dbh->prepare($selectSQL);
		$sth->execute();
		$result = $sth->fetchall_hashref('rarity');
	};
	if ($@) {
		die("Unable to load rarities: " . $@);
	}
	return $result;
}

sub loadColors {
	my $result = {};
	eval {
		my $selectSQL = 'SELECT id, color FROM colors';
		my $sth = $dbh->prepare($selectSQL);
		$sth->execute();
		$result = $sth->fetchall_hashref('color');
	};
	if ($@) {
		die("Unable to load colors: " . $@);
	}
	return $result;
}

sub loadMarks {
	my $result = {};
	eval {
		my $selectSQL = 'SELECT id, mark FROM marks';
		my $sth = $dbh->prepare($selectSQL);
		$sth->execute();
		$result = $sth->fetchall_hashref('mark');
	};
	if ($@) {
		die("Unable to load marks: " . $@);
	}
	return $result;
}



sub addMark {
	my $mark = shift;
	eval {
		my $insertSQL = 'INSERT INTO marks (mark) VALUES ?';
		my $sth = $dbh->prepare($insertSQL);
		$sth->execute($mark);
		print "{added mark \"$mark\"}";
	};
	if ($@) {
		die("Unable to add mark \"$mark\": " . $@);
	}
	return loadMarks();
}


sub addType {
	my $type = shift;
	eval {
		my $insertSQL = 'INSERT INTO types (type) VALUES (?)';
		my $sth = $dbh->prepare($insertSQL);
		$sth->execute($type);
		print "{added type \"$type\"}";
	};
	if ($@) {
		die("Unable to add type \"$type\": " . $@);
	}
	return loadTypes();
}


sub addSubtype {
	my $subtype = shift;
	$subtype =~ s/’/'/gi; # fixes issue with this unicode apostrophe in the mtgjson data
	eval {
		my $insertSQL = 'INSERT INTO subtypes (subtype) VALUES (?)';
		my $sth = $dbh->prepare($insertSQL);
		$sth->execute($subtype);
		print "{added subtype \"$subtype\"}";
	};
	if ($@) {
		die("Unable to add subtype \"$subtype\": " . $@);
	}
	return loadSubtypes();
}
