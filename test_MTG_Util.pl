#!/usr/bin/perl

use strict;
use utf8;
use Data::Dumper;
use MTG::Util qw(trim html2Plain);

{
    my $a = {test => undef, expected => undef};
    $a->{result} = html2Plain($a->{test});
    die ("test 1 - " . Dumper($a)) if ($a->{result} ne $a->{expected});
}

{
    my $a = {test => '', expected => ''};
    $a->{result} = html2Plain($a->{test});
    die ("test 2 - " . Dumper($a)) if ($a->{result} ne $a->{expected});
}

{
    my $a = {test => 'Hello, World!', expected => 'Hello, World!'};
    $a->{result} = html2Plain($a->{test});
    die ("test 3 - " . Dumper($a)) if ($a->{result} ne $a->{expected});
}

{
    my $a = {test => 'Hello<div>,</div> World!', expected => "Hello,\n\nWorld!"};
    $a->{result} = html2Plain($a->{test});
    die ("test 4 - " . Dumper($a)) if ($a->{result} ne $a->{expected});
}

{
    my $a = {test => 'Hello,<br> World!', expected => "Hello,\nWorld!"};
    $a->{result} = html2Plain($a->{test});
    die ("test 5 - " . Dumper($a)) if ($a->{result} ne $a->{expected});
}

{
    my $a = {test => '¥ · £ · € · $ · ¢ · ₡ · ₢ · ₣ · ₤ · ₥ · ₦ · ₧ · ₨ · ₩ · ₪ · ₫ · ₭ · ₮ · ₯', expected => '¥ · £ · € · $ · ¢ · ₡ · ₢ · ₣ · ₤ · ₥ · ₦ · ₧ · ₨ · ₩ · ₪ · ₫ · ₭ · ₮ · ₯'};
    $a->{result} = html2Plain($a->{test});
    die ("test 6 - " . Dumper($a)) if ($a->{result} ne $a->{expected});
}

{
    my $a = {test => 'Hello, <i>World</i>!', expected => "Hello, <i>World</i>!"};
    $a->{result} = html2Plain($a->{test});
    die ("test 7 - " . Dumper($a)) if ($a->{result} ne $a->{expected});
}

{
    my $a = {test => 'Hello, <i>Wor<br/>ld</i>!', expected => "Hello, <i>Wor\nld</i>!"};
    $a->{result} = html2Plain($a->{test});
    die ("test 8 - " . Dumper($a)) if ($a->{result} ne $a->{expected});
}

{
    my $a = {test => '<img src="/Handlers/Image.ashx?size=small&amp;name=tap&amp;type=symbol" alt="Tap" align="absbottom" />: Hello, World!', expected => '{t}: Hello, World!'};
    $a->{result} = html2Plain($a->{test});
    die ("test 9 - " . Dumper($a)) if ($a->{result} ne $a->{expected});
}

{
    my $a = {test => '<img src="/Handlers/Image.ashx?size=small&amp;name=G&amp;type=symbol" alt="Green" align="absbottom" />: Hello, World!', expected => '{g}: Hello, World!'};
    $a->{result} = html2Plain($a->{test});
    die ("test 10 - " . Dumper($a)) if ($a->{result} ne $a->{expected});
}

{
    my $a = {test => qq{
                            <div class="cardtextbox"><img src="/Handlers/Image.ashx?size=small&amp;name=tap&amp;type=symbol" alt="Tap" align="absbottom" />: Add <img src="/Handlers/Image.ashx?size=small&amp;name=G&amp;type=symbol" alt="Green" align="absbottom" /> to your mana pool.</div></div>}, expected => '{t}: Add {g} to your mana pool.'};
    $a->{result} = html2Plain($a->{test});
    die ("test 11 - " . Dumper($a)) if ($a->{result} ne $a->{expected});
}

{
    my $a = {test => qq{
                            <div class="cardtextbox"><img src="/Handlers/Image.ashx?size=small&amp;name=U&amp;type=symbol" alt="Blue" align="absbottom" />: Exile Ætherling. Return it to the battlefield under its owner's control at the beginning of the next end step.</div><div class="cardtextbox"><img src="/Handlers/Image.ashx?size=small&amp;name=U&amp;type=symbol" alt="Blue" align="absbottom" />: Ætherling can't be blocked this turn.</div><div class="cardtextbox"><img src="/Handlers/Image.ashx?size=small&amp;name=1&amp;type=symbol" alt="1" align="absbottom" />: Ætherling gets +1/-1 until end of turn.</div><div class="cardtextbox"><img src="/Handlers/Image.ashx?size=small&amp;name=1&amp;type=symbol" alt="1" align="absbottom" />: Ætherling gets -1/+1 until end of turn.</div></div>
                    }};
    $a->{expected} = "{u}: Exile Ætherling. Return it to the battlefield under its owner's control at the beginning of the next end step.\n\n{u}: Ætherling can't be blocked this turn.\n\n{1}: Ætherling gets +1/-1 until end of turn.\n\n{1}: Ætherling gets -1/+1 until end of turn.";
    $a->{result} = html2Plain($a->{test});
    die ("test 12 - " . Dumper($a)) if ($a->{result} ne $a->{expected});
}

