#!/usr/bin/perl

use strict;
use utf8;
use MTG::GathererLoader;

my $db = MTG::Database->new();
my $loader = MTG::GathererLoader->new($db);

#$loader->readCardDir(*STDOUT);
$loader->readCard("card_html/45190.html", *STDOUT);
