package MTG::Util;

#use Unicode::CharName qw(uname ublock);
use Exporter;
use base qw(Exporter);
@EXPORT_OK = qw(checkClass trim html2Plain makeFilingName);

sub checkClass {
	my $className = shift;
	my $reference = shift;
	eval { $good = $reference->isa($className); };
	if (! $good) {
		my $ex = MTG::Exception::WrongClass->new(message => 'Not a ' . $className . ': ' . $reference, show_trace => 1);
		$ex->throw();
	}
	return $reference;
}

sub trim {
	my $text = shift;
	$text =~ s/^\s*(\S)/$1/;
	$text =~ s/(\S)\s*$/$1/;
	return $text;
}

sub html2Plain {
	my $html = shift;
	my $plain = $html;
	$plain =~ s/<img src="\/Handlers\/Image\.ashx\?size=small&amp;name=([^&]+)&amp;type=symbol"[^>]*>/{$1}/gi;
	$plain =~ s/<br[^>]*>\s*/\n/gi;
	$plain =~ s/\{[tT][aA][pP]\}/\{t\}/gi;
	$plain =~ s/\{[uU][nN][tT][aA][pP]\}/\{q\}/gi;
	$plain =~ s/\{W}/\{w\}/gi;
	$plain =~ s/\{U}/\{u\}/gi;
	$plain =~ s/\{B}/\{b\}/gi;
	$plain =~ s/\{R}/\{r\}/gi;
	$plain =~ s/\{G}/\{g\}/gi;
	$plain =~ s/<\/div>\s*/\n\n/gi;
	$plain =~ s/<i>/_IMARK_/gi;
	$plain =~ s/<\/i>/_ICMARK_/gi;
	$plain =~ s/<[^>]+>//gi;
	$plain =~ s/_IMARK_/<i>/gi;
	$plain =~ s/_ICMARK_/<\/i>/gi;

	return &trim($plain);
}

# Make a "Library of Congress"-adequate filing name.  Using Library of Congress Filing standards - http://www.loc.gov/catdir/cpso/G100.pdf

sub makeFilingName {
	my $text = shift;
	my $filingName = $text;
	sub numFix {
		my $q = shift;
		my $n = shift;
		$n =~ s/,//g;
		return sprintf($q . '%09s', $n);
	}

	my $aaa = \&numFix;
	my @ignored_punctuation = ('!','"','#','$','%',"'",'(',')','*','+',',','-','.','/',':',';','<','=','>','?','[',']','\\','^','_','{','|','}','~');
	for (my $u = 161; $u < 192; $u++) {
		push @ignored_punctuation, chr($u);
	}

	{
		# Rule 1 - General Principle
		#
		# This is standard alphetical order, which computers are good at. But,
		# let's lowercase everything to make sure that we are playing in the same space.
		$filingName = lc($filingName);

		# Rule 2 - Treat modified letters like their equivalents in the
		# English alphabet. Ignore diacritical marks and modifications of
		# recognizable English letters
		$filingName =~ s/\x{00c0}/a/gi; # LATIN CAPITAL LETTER A WITH GRAVE
		$filingName =~ s/\x{00c1}/a/gi; # LATIN CAPITAL LETTER A WITH ACUTE
		$filingName =~ s/\x{00c2}/a/gi; # LATIN CAPITAL LETTER A WITH CIRCUMFLEX
		$filingName =~ s/\x{00c3}/a/gi; # LATIN CAPITAL LETTER A WITH TILDE
		$filingName =~ s/\x{00c4}/a/gi; # LATIN CAPITAL LETTER A WITH DIAERESIS
		$filingName =~ s/\x{00c5}/a/gi; # LATIN CAPITAL LETTER A WITH RING ABOVE
		$filingName =~ s/\x{00c6}/ae/gi; # LATIN CAPITAL LETTER AE
		$filingName =~ s/\x{00c7}/c/gi; # LATIN CAPITAL LETTER C WITH CEDILLA
		$filingName =~ s/\x{00c8}/e/gi; # LATIN CAPITAL LETTER E WITH GRAVE
		$filingName =~ s/\x{00c9}/e/gi; # LATIN CAPITAL LETTER E WITH ACUTE
		$filingName =~ s/\x{00ca}/e/gi; # LATIN CAPITAL LETTER E WITH CIRCUMFLEX
		$filingName =~ s/\x{00cb}/e/gi; # LATIN CAPITAL LETTER E WITH DIAERESIS
		$filingName =~ s/\x{00cc}/i/gi; # LATIN CAPITAL LETTER I WITH GRAVE
		$filingName =~ s/\x{00cd}/i/gi; # LATIN CAPITAL LETTER I WITH ACUTE
		$filingName =~ s/\x{00ce}/i/gi; # LATIN CAPITAL LETTER I WITH CIRCUMFLEX
		$filingName =~ s/\x{00cf}/i/gi; # LATIN CAPITAL LETTER I WITH DIAERESIS
		$filingName =~ s/\x{00d0}/d/gi; # LATIN CAPITAL LETTER ETH
		$filingName =~ s/\x{00d1}/n/gi; # LATIN CAPITAL LETTER N WITH TILDE
		$filingName =~ s/\x{00d2}/o/gi; # LATIN CAPITAL LETTER O WITH GRAVE
		$filingName =~ s/\x{00d3}/o/gi; # LATIN CAPITAL LETTER O WITH ACUTE
		$filingName =~ s/\x{00d4}/o/gi; # LATIN CAPITAL LETTER O WITH CIRCUMFLEX
		$filingName =~ s/\x{00d5}/o/gi; # LATIN CAPITAL LETTER O WITH TILDE
		$filingName =~ s/\x{00d6}/o/gi; # LATIN CAPITAL LETTER O WITH DIAERESIS
		$filingName =~ s/\x{00d7}/ /gi; # MULTIPLICATION SIGN
		$filingName =~ s/\x{00d8}/o/gi; # LATIN CAPITAL LETTER O WITH STROKE
		$filingName =~ s/\x{00d9}/u/gi; # LATIN CAPITAL LETTER U WITH GRAVE
		$filingName =~ s/\x{00da}/u/gi; # LATIN CAPITAL LETTER U WITH ACUTE
		$filingName =~ s/\x{00db}/u/gi; # LATIN CAPITAL LETTER U WITH CIRCUMFLEX
		$filingName =~ s/\x{00dc}/u/gi; # LATIN CAPITAL LETTER U WITH DIAERESIS
		$filingName =~ s/\x{00dd}/y/gi; # LATIN CAPITAL LETTER Y WITH ACUTE
		$filingName =~ s/\x{00de}/th/gi; # LATIN CAPITAL LETTER THORN
		$filingName =~ s/\x{00df}/s/gi; # LATIN SMALL LETTER SHARP S
		$filingName =~ s/\x{00e0}/a/gi; # LATIN SMALL LETTER A WITH GRAVE
		$filingName =~ s/\x{00e1}/a/gi; # LATIN SMALL LETTER A WITH ACUTE
		$filingName =~ s/\x{00e2}/a/gi; # LATIN SMALL LETTER A WITH CIRCUMFLEX
		$filingName =~ s/\x{00e3}/a/gi; # LATIN SMALL LETTER A WITH TILDE
		$filingName =~ s/\x{00e4}/a/gi; # LATIN SMALL LETTER A WITH DIAERESIS
		$filingName =~ s/\x{00e5}/a/gi; # LATIN SMALL LETTER A WITH RING ABOVE
		$filingName =~ s/\x{00e6}/ae/gi; # LATIN SMALL LETTER AE
		$filingName =~ s/\x{00e7}/c/gi; # LATIN SMALL LETTER C WITH CEDILLA
		$filingName =~ s/\x{00e8}/e/gi; # LATIN SMALL LETTER E WITH GRAVE
		$filingName =~ s/\x{00e9}/e/gi; # LATIN SMALL LETTER E WITH ACUTE
		$filingName =~ s/\x{00ea}/e/gi; # LATIN SMALL LETTER E WITH CIRCUMFLEX
		$filingName =~ s/\x{00eb}/e/gi; # LATIN SMALL LETTER E WITH DIAERESIS
		$filingName =~ s/\x{00ec}/i/gi; # LATIN SMALL LETTER I WITH GRAVE
		$filingName =~ s/\x{00ed}/i/gi; # LATIN SMALL LETTER I WITH ACUTE
		$filingName =~ s/\x{00ee}/i/gi; # LATIN SMALL LETTER I WITH CIRCUMFLEX
		$filingName =~ s/\x{00ef}/i/gi; # LATIN SMALL LETTER I WITH DIAERESIS
		$filingName =~ s/\x{00f0}/d/gi; # LATIN SMALL LETTER ETH
		$filingName =~ s/\x{00f1}/n/gi; # LATIN SMALL LETTER N WITH TILDE
		$filingName =~ s/\x{00f2}/o/gi; # LATIN SMALL LETTER O WITH GRAVE
		$filingName =~ s/\x{00f3}/o/gi; # LATIN SMALL LETTER O WITH ACUTE
		$filingName =~ s/\x{00f4}/o/gi; # LATIN SMALL LETTER O WITH CIRCUMFLEX
		$filingName =~ s/\x{00f5}/o/gi; # LATIN SMALL LETTER O WITH TILDE
		$filingName =~ s/\x{00f6}/o/gi; # LATIN SMALL LETTER O WITH DIAERESIS
		$filingName =~ s/\x{00f7}/ /gi; # DIVISION SIGN
		$filingName =~ s/\x{00f8}/o/gi; # LATIN SMALL LETTER O WITH STROKE
		$filingName =~ s/\x{00f9}/u/gi; # LATIN SMALL LETTER U WITH GRAVE
		$filingName =~ s/\x{00fa}/u/gi; # LATIN SMALL LETTER U WITH ACUTE
		$filingName =~ s/\x{00fb}/u/gi; # LATIN SMALL LETTER U WITH CIRCUMFLEX
		$filingName =~ s/\x{00fc}/u/gi; # LATIN SMALL LETTER U WITH DIAERESIS
		$filingName =~ s/\x{00fd}/y/gi; # LATIN SMALL LETTER Y WITH ACUTE
		$filingName =~ s/\x{00fe}/th/gi; # LATIN SMALL LETTER THORN
		$filingName =~ s/\x{00ff}/y/gi; # LATIN SMALL LETTER Y WITH DIAERESIS
		$filingName =~ s/\x{0100}/a/gi; # LATIN CAPITAL LETTER A WITH MACRON
		$filingName =~ s/\x{0101}/a/gi; # LATIN SMALL LETTER A WITH MACRON
		$filingName =~ s/\x{0102}/a/gi; # LATIN CAPITAL LETTER A WITH BREVE
		$filingName =~ s/\x{0103}/a/gi; # LATIN SMALL LETTER A WITH BREVE
		$filingName =~ s/\x{0104}/a/gi; # LATIN CAPITAL LETTER A WITH OGONEK
		$filingName =~ s/\x{0105}/a/gi; # LATIN SMALL LETTER A WITH OGONEK
		$filingName =~ s/\x{0106}/c/gi; # LATIN CAPITAL LETTER C WITH ACUTE
		$filingName =~ s/\x{0107}/c/gi; # LATIN SMALL LETTER C WITH ACUTE
		$filingName =~ s/\x{0108}/c/gi; # LATIN CAPITAL LETTER C WITH CIRCUMFLEX
		$filingName =~ s/\x{0109}/c/gi; # LATIN SMALL LETTER C WITH CIRCUMFLEX
		$filingName =~ s/\x{010a}/c/gi; # LATIN CAPITAL LETTER C WITH DOT ABOVE
		$filingName =~ s/\x{010b}/c/gi; # LATIN SMALL LETTER C WITH DOT ABOVE
		$filingName =~ s/\x{010c}/c/gi; # LATIN CAPITAL LETTER C WITH CARON
		$filingName =~ s/\x{010d}/c/gi; # LATIN SMALL LETTER C WITH CARON
		$filingName =~ s/\x{010e}/d/gi; # LATIN CAPITAL LETTER D WITH CARON
		$filingName =~ s/\x{010f}/d/gi; # LATIN SMALL LETTER D WITH CARON
		$filingName =~ s/\x{0110}/d/gi; # LATIN CAPITAL LETTER D WITH STROKE
		$filingName =~ s/\x{0111}/d/gi; # LATIN SMALL LETTER D WITH STROKE
		$filingName =~ s/\x{0112}/e/gi; # LATIN CAPITAL LETTER E WITH MACRON
		$filingName =~ s/\x{0113}/e/gi; # LATIN SMALL LETTER E WITH MACRON
		$filingName =~ s/\x{0114}/e/gi; # LATIN CAPITAL LETTER E WITH BREVE
		$filingName =~ s/\x{0115}/e/gi; # LATIN SMALL LETTER E WITH BREVE
		$filingName =~ s/\x{0116}/e/gi; # LATIN CAPITAL LETTER E WITH DOT ABOVE
		$filingName =~ s/\x{0117}/e/gi; # LATIN SMALL LETTER E WITH DOT ABOVE
		$filingName =~ s/\x{0118}/e/gi; # LATIN CAPITAL LETTER E WITH OGONEK
		$filingName =~ s/\x{0119}/e/gi; # LATIN SMALL LETTER E WITH OGONEK
		$filingName =~ s/\x{011a}/e/gi; # LATIN CAPITAL LETTER E WITH CARON
		$filingName =~ s/\x{011b}/e/gi; # LATIN SMALL LETTER E WITH CARON
		$filingName =~ s/\x{011c}/g/gi; # LATIN CAPITAL LETTER G WITH CIRCUMFLEX
		$filingName =~ s/\x{011d}/g/gi; # LATIN SMALL LETTER G WITH CIRCUMFLEX
		$filingName =~ s/\x{011e}/g/gi; # LATIN CAPITAL LETTER G WITH BREVE
		$filingName =~ s/\x{011f}/g/gi; # LATIN SMALL LETTER G WITH BREVE
		$filingName =~ s/\x{0120}/g/gi; # LATIN CAPITAL LETTER G WITH DOT ABOVE
		$filingName =~ s/\x{0121}/g/gi; # LATIN SMALL LETTER G WITH DOT ABOVE
		$filingName =~ s/\x{0122}/g/gi; # LATIN CAPITAL LETTER G WITH CEDILLA
		$filingName =~ s/\x{0123}/g/gi; # LATIN SMALL LETTER G WITH CEDILLA
		$filingName =~ s/\x{0124}/h/gi; # LATIN CAPITAL LETTER H WITH CIRCUMFLEX
		$filingName =~ s/\x{0125}/h/gi; # LATIN SMALL LETTER H WITH CIRCUMFLEX
		$filingName =~ s/\x{0126}/h/gi; # LATIN CAPITAL LETTER H WITH STROKE
		$filingName =~ s/\x{0127}/h/gi; # LATIN SMALL LETTER H WITH STROKE
		$filingName =~ s/\x{0128}/i/gi; # LATIN CAPITAL LETTER I WITH TILDE
		$filingName =~ s/\x{0129}/i/gi; # LATIN SMALL LETTER I WITH TILDE
		$filingName =~ s/\x{012a}/i/gi; # LATIN CAPITAL LETTER I WITH MACRON
		$filingName =~ s/\x{012b}/i/gi; # LATIN SMALL LETTER I WITH MACRON
		$filingName =~ s/\x{012c}/i/gi; # LATIN CAPITAL LETTER I WITH BREVE
		$filingName =~ s/\x{012d}/i/gi; # LATIN SMALL LETTER I WITH BREVE
		$filingName =~ s/\x{012e}/i/gi; # LATIN CAPITAL LETTER I WITH OGONEK
		$filingName =~ s/\x{012f}/i/gi; # LATIN SMALL LETTER I WITH OGONEK
		$filingName =~ s/\x{0130}/i/gi; # LATIN CAPITAL LETTER I WITH DOT ABOVE
		$filingName =~ s/\x{0131}/i/gi; # LATIN SMALL LETTER DOTLESS I
		$filingName =~ s/\x{0132}/ij/gi; # LATIN CAPITAL LIGATURE IJ
		$filingName =~ s/\x{0133}/ij/gi; # LATIN SMALL LIGATURE IJ
		$filingName =~ s/\x{0134}/j/gi; # LATIN CAPITAL LETTER J WITH CIRCUMFLEX
		$filingName =~ s/\x{0135}/j/gi; # LATIN SMALL LETTER J WITH CIRCUMFLEX
		$filingName =~ s/\x{0136}/k/gi; # LATIN CAPITAL LETTER K WITH CEDILLA
		$filingName =~ s/\x{0137}/k/gi; # LATIN SMALL LETTER K WITH CEDILLA
		$filingName =~ s/\x{0138}/kr/gi; # LATIN SMALL LETTER KRA
		$filingName =~ s/\x{0139}/l/gi; # LATIN CAPITAL LETTER L WITH ACUTE
		$filingName =~ s/\x{013a}/l/gi; # LATIN SMALL LETTER L WITH ACUTE
		$filingName =~ s/\x{013b}/l/gi; # LATIN CAPITAL LETTER L WITH CEDILLA
		$filingName =~ s/\x{013c}/l/gi; # LATIN SMALL LETTER L WITH CEDILLA
		$filingName =~ s/\x{013d}/l/gi; # LATIN CAPITAL LETTER L WITH CARON
		$filingName =~ s/\x{013e}/l/gi; # LATIN SMALL LETTER L WITH CARON
		$filingName =~ s/\x{013f}/l/gi; # LATIN CAPITAL LETTER L WITH MIDDLE DOT
		$filingName =~ s/\x{0140}/l/gi; # LATIN SMALL LETTER L WITH MIDDLE DOT
		$filingName =~ s/\x{0141}/l/gi; # LATIN CAPITAL LETTER L WITH STROKE
		$filingName =~ s/\x{0142}/l/gi; # LATIN SMALL LETTER L WITH STROKE
		$filingName =~ s/\x{0143}/n/gi; # LATIN CAPITAL LETTER N WITH ACUTE
		$filingName =~ s/\x{0144}/n/gi; # LATIN SMALL LETTER N WITH ACUTE
		$filingName =~ s/\x{0145}/n/gi; # LATIN CAPITAL LETTER N WITH CEDILLA
		$filingName =~ s/\x{0146}/n/gi; # LATIN SMALL LETTER N WITH CEDILLA
		$filingName =~ s/\x{0147}/n/gi; # LATIN CAPITAL LETTER N WITH CARON
		$filingName =~ s/\x{0148}/n/gi; # LATIN SMALL LETTER N WITH CARON
		$filingName =~ s/\x{0149}/n/gi; # LATIN SMALL LETTER N PRECEDED BY APOSTROPHE
		$filingName =~ s/\x{014a}/n/gi; # LATIN CAPITAL LETTER ENG
		$filingName =~ s/\x{014b}/n/gi; # LATIN SMALL LETTER ENG
		$filingName =~ s/\x{014c}/o/gi; # LATIN CAPITAL LETTER O WITH MACRON
		$filingName =~ s/\x{014d}/o/gi; # LATIN SMALL LETTER O WITH MACRON
		$filingName =~ s/\x{014e}/o/gi; # LATIN CAPITAL LETTER O WITH BREVE
		$filingName =~ s/\x{014f}/o/gi; # LATIN SMALL LETTER O WITH BREVE
		$filingName =~ s/\x{0150}/o/gi; # LATIN CAPITAL LETTER O WITH DOUBLE ACUTE
		$filingName =~ s/\x{0151}/o/gi; # LATIN SMALL LETTER O WITH DOUBLE ACUTE
		$filingName =~ s/\x{0152}/oe/gi; # LATIN CAPITAL LIGATURE OE
		$filingName =~ s/\x{0153}/oe/gi; # LATIN SMALL LIGATURE OE
		$filingName =~ s/\x{0154}/r/gi; # LATIN CAPITAL LETTER R WITH ACUTE
		$filingName =~ s/\x{0155}/r/gi; # LATIN SMALL LETTER R WITH ACUTE
		$filingName =~ s/\x{0156}/r/gi; # LATIN CAPITAL LETTER R WITH CEDILLA
		$filingName =~ s/\x{0157}/r/gi; # LATIN SMALL LETTER R WITH CEDILLA
		$filingName =~ s/\x{0158}/r/gi; # LATIN CAPITAL LETTER R WITH CARON
		$filingName =~ s/\x{0159}/r/gi; # LATIN SMALL LETTER R WITH CARON
		$filingName =~ s/\x{015a}/s/gi; # LATIN CAPITAL LETTER S WITH ACUTE
		$filingName =~ s/\x{015b}/s/gi; # LATIN SMALL LETTER S WITH ACUTE
		$filingName =~ s/\x{015c}/s/gi; # LATIN CAPITAL LETTER S WITH CIRCUMFLEX
		$filingName =~ s/\x{015d}/s/gi; # LATIN SMALL LETTER S WITH CIRCUMFLEX
		$filingName =~ s/\x{015e}/s/gi; # LATIN CAPITAL LETTER S WITH CEDILLA
		$filingName =~ s/\x{015f}/s/gi; # LATIN SMALL LETTER S WITH CEDILLA
		$filingName =~ s/\x{0160}/s/gi; # LATIN CAPITAL LETTER S WITH CARON
		$filingName =~ s/\x{0161}/s/gi; # LATIN SMALL LETTER S WITH CARON
		$filingName =~ s/\x{0162}/t/gi; # LATIN CAPITAL LETTER T WITH CEDILLA
		$filingName =~ s/\x{0163}/t/gi; # LATIN SMALL LETTER T WITH CEDILLA
		$filingName =~ s/\x{0164}/t/gi; # LATIN CAPITAL LETTER T WITH CARON
		$filingName =~ s/\x{0165}/t/gi; # LATIN SMALL LETTER T WITH CARON
		$filingName =~ s/\x{0166}/t/gi; # LATIN CAPITAL LETTER T WITH STROKE
		$filingName =~ s/\x{0167}/t/gi; # LATIN SMALL LETTER T WITH STROKE
		$filingName =~ s/\x{0168}/u/gi; # LATIN CAPITAL LETTER U WITH TILDE
		$filingName =~ s/\x{0169}/u/gi; # LATIN SMALL LETTER U WITH TILDE
		$filingName =~ s/\x{016a}/u/gi; # LATIN CAPITAL LETTER U WITH MACRON
		$filingName =~ s/\x{016b}/u/gi; # LATIN SMALL LETTER U WITH MACRON
		$filingName =~ s/\x{016c}/u/gi; # LATIN CAPITAL LETTER U WITH BREVE
		$filingName =~ s/\x{016d}/u/gi; # LATIN SMALL LETTER U WITH BREVE
		$filingName =~ s/\x{016e}/u/gi; # LATIN CAPITAL LETTER U WITH RING ABOVE
		$filingName =~ s/\x{016f}/u/gi; # LATIN SMALL LETTER U WITH RING ABOVE
		$filingName =~ s/\x{0170}/u/gi; # LATIN CAPITAL LETTER U WITH DOUBLE ACUTE
		$filingName =~ s/\x{0171}/u/gi; # LATIN SMALL LETTER U WITH DOUBLE ACUTE
		$filingName =~ s/\x{0172}/u/gi; # LATIN CAPITAL LETTER U WITH OGONEK
		$filingName =~ s/\x{0173}/u/gi; # LATIN SMALL LETTER U WITH OGONEK
		$filingName =~ s/\x{0174}/w/gi; # LATIN CAPITAL LETTER W WITH CIRCUMFLEX
		$filingName =~ s/\x{0175}/w/gi; # LATIN SMALL LETTER W WITH CIRCUMFLEX
		$filingName =~ s/\x{0176}/y/gi; # LATIN CAPITAL LETTER Y WITH CIRCUMFLEX
		$filingName =~ s/\x{0177}/y/gi; # LATIN SMALL LETTER Y WITH CIRCUMFLEX
		$filingName =~ s/\x{0178}/y/gi; # LATIN CAPITAL LETTER Y WITH DIAERESIS
		$filingName =~ s/\x{0179}/z/gi; # LATIN CAPITAL LETTER Z WITH ACUTE
		$filingName =~ s/\x{017a}/z/gi; # LATIN SMALL LETTER Z WITH ACUTE
		$filingName =~ s/\x{017b}/z/gi; # LATIN CAPITAL LETTER Z WITH DOT ABOVE
		$filingName =~ s/\x{017c}/z/gi; # LATIN SMALL LETTER Z WITH DOT ABOVE
		$filingName =~ s/\x{017d}/z/gi; # LATIN CAPITAL LETTER Z WITH CARON
		$filingName =~ s/\x{017e}/z/gi; # LATIN SMALL LETTER Z WITH CARON
		$filingName =~ s/\x{017f}/s/gi; # LATIN SMALL LETTER LONG S
		$filingName =~ s/\x{0180}/b/gi; # LATIN SMALL LETTER B WITH STROKE
		$filingName =~ s/\x{0181}/b/gi; # LATIN CAPITAL LETTER B WITH HOOK
		$filingName =~ s/\x{0182}/b/gi; # LATIN CAPITAL LETTER B WITH TOPBAR
		$filingName =~ s/\x{0183}/b/gi; # LATIN SMALL LETTER B WITH TOPBAR
		# $filingName =~ s/\x{0184}/_/gi; # LATIN CAPITAL LETTER TONE SIX
		# $filingName =~ s/\x{0185}/_/gi; # LATIN SMALL LETTER TONE SIX
		# $filingName =~ s/\x{0186}/_/gi; # LATIN CAPITAL LETTER OPEN O
		# $filingName =~ s/\x{0187}/_/gi; # LATIN CAPITAL LETTER C WITH HOOK
		# $filingName =~ s/\x{0188}/_/gi; # LATIN SMALL LETTER C WITH HOOK
		# $filingName =~ s/\x{0189}/_/gi; # LATIN CAPITAL LETTER AFRICAN D
		# $filingName =~ s/\x{018a}/_/gi; # LATIN CAPITAL LETTER D WITH HOOK
		# $filingName =~ s/\x{018b}/_/gi; # LATIN CAPITAL LETTER D WITH TOPBAR
		# $filingName =~ s/\x{018c}/_/gi; # LATIN SMALL LETTER D WITH TOPBAR
		# $filingName =~ s/\x{018d}/_/gi; # LATIN SMALL LETTER TURNED DELTA
		# $filingName =~ s/\x{018e}/_/gi; # LATIN CAPITAL LETTER REVERSED E
		# $filingName =~ s/\x{018f}/_/gi; # LATIN CAPITAL LETTER SCHWA
		# $filingName =~ s/\x{0190}/_/gi; # LATIN CAPITAL LETTER OPEN E
		# $filingName =~ s/\x{0191}/_/gi; # LATIN CAPITAL LETTER F WITH HOOK
		# $filingName =~ s/\x{0192}/_/gi; # LATIN SMALL LETTER F WITH HOOK
		# $filingName =~ s/\x{0193}/_/gi; # LATIN CAPITAL LETTER G WITH HOOK
		# $filingName =~ s/\x{0194}/_/gi; # LATIN CAPITAL LETTER GAMMA
		# $filingName =~ s/\x{0195}/_/gi; # LATIN SMALL LETTER HV
		# $filingName =~ s/\x{0196}/_/gi; # LATIN CAPITAL LETTER IOTA
		# $filingName =~ s/\x{0197}/_/gi; # LATIN CAPITAL LETTER I WITH STROKE
		# $filingName =~ s/\x{0198}/_/gi; # LATIN CAPITAL LETTER K WITH HOOK
		# $filingName =~ s/\x{0199}/_/gi; # LATIN SMALL LETTER K WITH HOOK
		# $filingName =~ s/\x{019a}/_/gi; # LATIN SMALL LETTER L WITH BAR
		# $filingName =~ s/\x{019b}/_/gi; # LATIN SMALL LETTER LAMBDA WITH STROKE
		# $filingName =~ s/\x{019c}/_/gi; # LATIN CAPITAL LETTER TURNED M
		# $filingName =~ s/\x{019d}/_/gi; # LATIN CAPITAL LETTER N WITH LEFT HOOK
		# $filingName =~ s/\x{019e}/_/gi; # LATIN SMALL LETTER N WITH LONG RIGHT LEG
		# $filingName =~ s/\x{019f}/_/gi; # LATIN CAPITAL LETTER O WITH MIDDLE TILDE
		# $filingName =~ s/\x{01a0}/_/gi; # LATIN CAPITAL LETTER O WITH HORN
		# $filingName =~ s/\x{01a1}/_/gi; # LATIN SMALL LETTER O WITH HORN
		# $filingName =~ s/\x{01a2}/_/gi; # LATIN CAPITAL LETTER OI
		# $filingName =~ s/\x{01a3}/_/gi; # LATIN SMALL LETTER OI
		# $filingName =~ s/\x{01a4}/_/gi; # LATIN CAPITAL LETTER P WITH HOOK
		# $filingName =~ s/\x{01a5}/_/gi; # LATIN SMALL LETTER P WITH HOOK
		# $filingName =~ s/\x{01a6}/_/gi; # LATIN LETTER YR
		# $filingName =~ s/\x{01a7}/_/gi; # LATIN CAPITAL LETTER TONE TWO
		# $filingName =~ s/\x{01a8}/_/gi; # LATIN SMALL LETTER TONE TWO
		# $filingName =~ s/\x{01a9}/_/gi; # LATIN CAPITAL LETTER ESH
		# $filingName =~ s/\x{01aa}/_/gi; # LATIN LETTER REVERSED ESH LOOP
		# $filingName =~ s/\x{01ab}/_/gi; # LATIN SMALL LETTER T WITH PALATAL HOOK
		# $filingName =~ s/\x{01ac}/_/gi; # LATIN CAPITAL LETTER T WITH HOOK
		# $filingName =~ s/\x{01ad}/_/gi; # LATIN SMALL LETTER T WITH HOOK
		# $filingName =~ s/\x{01ae}/_/gi; # LATIN CAPITAL LETTER T WITH RETROFLEX HOOK
		# $filingName =~ s/\x{01af}/_/gi; # LATIN CAPITAL LETTER U WITH HORN
		# $filingName =~ s/\x{01b0}/_/gi; # LATIN SMALL LETTER U WITH HORN
		# $filingName =~ s/\x{01b1}/_/gi; # LATIN CAPITAL LETTER UPSILON
		# $filingName =~ s/\x{01b2}/_/gi; # LATIN CAPITAL LETTER V WITH HOOK
		# $filingName =~ s/\x{01b3}/_/gi; # LATIN CAPITAL LETTER Y WITH HOOK
		# $filingName =~ s/\x{01b4}/_/gi; # LATIN SMALL LETTER Y WITH HOOK
		# $filingName =~ s/\x{01b5}/_/gi; # LATIN CAPITAL LETTER Z WITH STROKE
		# $filingName =~ s/\x{01b6}/_/gi; # LATIN SMALL LETTER Z WITH STROKE
		# $filingName =~ s/\x{01b7}/_/gi; # LATIN CAPITAL LETTER EZH
		# $filingName =~ s/\x{01b8}/_/gi; # LATIN CAPITAL LETTER EZH REVERSED
		# $filingName =~ s/\x{01b9}/_/gi; # LATIN SMALL LETTER EZH REVERSED
		# $filingName =~ s/\x{01ba}/_/gi; # LATIN SMALL LETTER EZH WITH TAIL
		# $filingName =~ s/\x{01bb}/_/gi; # LATIN LETTER TWO WITH STROKE
		# $filingName =~ s/\x{01bc}/_/gi; # LATIN CAPITAL LETTER TONE FIVE
		# $filingName =~ s/\x{01bd}/_/gi; # LATIN SMALL LETTER TONE FIVE
		# $filingName =~ s/\x{01be}/_/gi; # LATIN LETTER INVERTED GLOTTAL STOP WITH STROKE
		# $filingName =~ s/\x{01bf}/_/gi; # LATIN LETTER WYNN
		# $filingName =~ s/\x{01c0}/_/gi; # LATIN LETTER DENTAL CLICK
		# $filingName =~ s/\x{01c1}/_/gi; # LATIN LETTER LATERAL CLICK
		# $filingName =~ s/\x{01c2}/_/gi; # LATIN LETTER ALVEOLAR CLICK
		# $filingName =~ s/\x{01c3}/_/gi; # LATIN LETTER RETROFLEX CLICK
		# $filingName =~ s/\x{01c4}/_/gi; # LATIN CAPITAL LETTER DZ WITH CARON
		# $filingName =~ s/\x{01c5}/_/gi; # LATIN CAPITAL LETTER D WITH SMALL LETTER Z WITH CARON
		# $filingName =~ s/\x{01c6}/_/gi; # LATIN SMALL LETTER DZ WITH CARON
		# $filingName =~ s/\x{01c7}/_/gi; # LATIN CAPITAL LETTER LJ
		# $filingName =~ s/\x{01c8}/_/gi; # LATIN CAPITAL LETTER L WITH SMALL LETTER J
		# $filingName =~ s/\x{01c9}/_/gi; # LATIN SMALL LETTER LJ
		# $filingName =~ s/\x{01ca}/_/gi; # LATIN CAPITAL LETTER NJ
		# $filingName =~ s/\x{01cb}/_/gi; # LATIN CAPITAL LETTER N WITH SMALL LETTER J
		# $filingName =~ s/\x{01cc}/_/gi; # LATIN SMALL LETTER NJ
		# $filingName =~ s/\x{01cd}/_/gi; # LATIN CAPITAL LETTER A WITH CARON
		# $filingName =~ s/\x{01ce}/_/gi; # LATIN SMALL LETTER A WITH CARON
		# $filingName =~ s/\x{01cf}/_/gi; # LATIN CAPITAL LETTER I WITH CARON
		# $filingName =~ s/\x{01d0}/_/gi; # LATIN SMALL LETTER I WITH CARON
		# $filingName =~ s/\x{01d1}/_/gi; # LATIN CAPITAL LETTER O WITH CARON
		# $filingName =~ s/\x{01d2}/_/gi; # LATIN SMALL LETTER O WITH CARON
		# $filingName =~ s/\x{01d3}/_/gi; # LATIN CAPITAL LETTER U WITH CARON
		# $filingName =~ s/\x{01d4}/_/gi; # LATIN SMALL LETTER U WITH CARON
		# $filingName =~ s/\x{01d5}/_/gi; # LATIN CAPITAL LETTER U WITH DIAERESIS AND MACRON
		# $filingName =~ s/\x{01d6}/_/gi; # LATIN SMALL LETTER U WITH DIAERESIS AND MACRON
		# $filingName =~ s/\x{01d7}/_/gi; # LATIN CAPITAL LETTER U WITH DIAERESIS AND ACUTE
		# $filingName =~ s/\x{01d8}/_/gi; # LATIN SMALL LETTER U WITH DIAERESIS AND ACUTE
		# $filingName =~ s/\x{01d9}/_/gi; # LATIN CAPITAL LETTER U WITH DIAERESIS AND CARON
		# $filingName =~ s/\x{01da}/_/gi; # LATIN SMALL LETTER U WITH DIAERESIS AND CARON
		# $filingName =~ s/\x{01db}/_/gi; # LATIN CAPITAL LETTER U WITH DIAERESIS AND GRAVE
		# $filingName =~ s/\x{01dc}/_/gi; # LATIN SMALL LETTER U WITH DIAERESIS AND GRAVE
		# $filingName =~ s/\x{01dd}/_/gi; # LATIN SMALL LETTER TURNED E
		# $filingName =~ s/\x{01de}/_/gi; # LATIN CAPITAL LETTER A WITH DIAERESIS AND MACRON
		# $filingName =~ s/\x{01df}/_/gi; # LATIN SMALL LETTER A WITH DIAERESIS AND MACRON
		# $filingName =~ s/\x{01e0}/_/gi; # LATIN CAPITAL LETTER A WITH DOT ABOVE AND MACRON
		# $filingName =~ s/\x{01e1}/_/gi; # LATIN SMALL LETTER A WITH DOT ABOVE AND MACRON
		# $filingName =~ s/\x{01e2}/_/gi; # LATIN CAPITAL LETTER AE WITH MACRON
		# $filingName =~ s/\x{01e3}/_/gi; # LATIN SMALL LETTER AE WITH MACRON
		# $filingName =~ s/\x{01e4}/_/gi; # LATIN CAPITAL LETTER G WITH STROKE
		# $filingName =~ s/\x{01e5}/_/gi; # LATIN SMALL LETTER G WITH STROKE
		# $filingName =~ s/\x{01e6}/_/gi; # LATIN CAPITAL LETTER G WITH CARON
		# $filingName =~ s/\x{01e7}/_/gi; # LATIN SMALL LETTER G WITH CARON
		# $filingName =~ s/\x{01e8}/_/gi; # LATIN CAPITAL LETTER K WITH CARON
		# $filingName =~ s/\x{01e9}/_/gi; # LATIN SMALL LETTER K WITH CARON
		# $filingName =~ s/\x{01ea}/_/gi; # LATIN CAPITAL LETTER O WITH OGONEK
		# $filingName =~ s/\x{01eb}/_/gi; # LATIN SMALL LETTER O WITH OGONEK
		# $filingName =~ s/\x{01ec}/_/gi; # LATIN CAPITAL LETTER O WITH OGONEK AND MACRON
		# $filingName =~ s/\x{01ed}/_/gi; # LATIN SMALL LETTER O WITH OGONEK AND MACRON
		# $filingName =~ s/\x{01ee}/_/gi; # LATIN CAPITAL LETTER EZH WITH CARON
		# $filingName =~ s/\x{01ef}/_/gi; # LATIN SMALL LETTER EZH WITH CARON
		# $filingName =~ s/\x{01f0}/_/gi; # LATIN SMALL LETTER J WITH CARON
		# $filingName =~ s/\x{01f1}/_/gi; # LATIN CAPITAL LETTER DZ
		# $filingName =~ s/\x{01f2}/_/gi; # LATIN CAPITAL LETTER D WITH SMALL LETTER Z
		# $filingName =~ s/\x{01f3}/_/gi; # LATIN SMALL LETTER DZ
		# $filingName =~ s/\x{01f4}/_/gi; # LATIN CAPITAL LETTER G WITH ACUTE
		# $filingName =~ s/\x{01f5}/_/gi; # LATIN SMALL LETTER G WITH ACUTE
		# $filingName =~ s/\x{01f6}/_/gi; # LATIN CAPITAL LETTER HWAIR
		# $filingName =~ s/\x{01f7}/_/gi; # LATIN CAPITAL LETTER WYNN
		# $filingName =~ s/\x{01f8}/_/gi; # LATIN CAPITAL LETTER N WITH GRAVE
		# $filingName =~ s/\x{01f9}/_/gi; # LATIN SMALL LETTER N WITH GRAVE
		# $filingName =~ s/\x{01fa}/_/gi; # LATIN CAPITAL LETTER A WITH RING ABOVE AND ACUTE
		# $filingName =~ s/\x{01fb}/_/gi; # LATIN SMALL LETTER A WITH RING ABOVE AND ACUTE
		# $filingName =~ s/\x{01fc}/_/gi; # LATIN CAPITAL LETTER AE WITH ACUTE
		# $filingName =~ s/\x{01fd}/_/gi; # LATIN SMALL LETTER AE WITH ACUTE
		# $filingName =~ s/\x{01fe}/_/gi; # LATIN CAPITAL LETTER O WITH STROKE AND ACUTE
		# $filingName =~ s/\x{01ff}/_/gi; # LATIN SMALL LETTER O WITH STROKE AND ACUTE
		# $filingName =~ s/\x{0200}/_/gi; # LATIN CAPITAL LETTER A WITH DOUBLE GRAVE
		# $filingName =~ s/\x{0201}/_/gi; # LATIN SMALL LETTER A WITH DOUBLE GRAVE
		# $filingName =~ s/\x{0202}/_/gi; # LATIN CAPITAL LETTER A WITH INVERTED BREVE
		# $filingName =~ s/\x{0203}/_/gi; # LATIN SMALL LETTER A WITH INVERTED BREVE
		# $filingName =~ s/\x{0204}/_/gi; # LATIN CAPITAL LETTER E WITH DOUBLE GRAVE
		# $filingName =~ s/\x{0205}/_/gi; # LATIN SMALL LETTER E WITH DOUBLE GRAVE
		# $filingName =~ s/\x{0206}/_/gi; # LATIN CAPITAL LETTER E WITH INVERTED BREVE
		# $filingName =~ s/\x{0207}/_/gi; # LATIN SMALL LETTER E WITH INVERTED BREVE
		# $filingName =~ s/\x{0208}/_/gi; # LATIN CAPITAL LETTER I WITH DOUBLE GRAVE
		# $filingName =~ s/\x{0209}/_/gi; # LATIN SMALL LETTER I WITH DOUBLE GRAVE
		# $filingName =~ s/\x{020a}/_/gi; # LATIN CAPITAL LETTER I WITH INVERTED BREVE
		# $filingName =~ s/\x{020b}/_/gi; # LATIN SMALL LETTER I WITH INVERTED BREVE
		# $filingName =~ s/\x{020c}/_/gi; # LATIN CAPITAL LETTER O WITH DOUBLE GRAVE
		# $filingName =~ s/\x{020d}/_/gi; # LATIN SMALL LETTER O WITH DOUBLE GRAVE
		# $filingName =~ s/\x{020e}/_/gi; # LATIN CAPITAL LETTER O WITH INVERTED BREVE
		# $filingName =~ s/\x{020f}/_/gi; # LATIN SMALL LETTER O WITH INVERTED BREVE
		# $filingName =~ s/\x{0210}/_/gi; # LATIN CAPITAL LETTER R WITH DOUBLE GRAVE
		# $filingName =~ s/\x{0211}/_/gi; # LATIN SMALL LETTER R WITH DOUBLE GRAVE
		# $filingName =~ s/\x{0212}/_/gi; # LATIN CAPITAL LETTER R WITH INVERTED BREVE
		# $filingName =~ s/\x{0213}/_/gi; # LATIN SMALL LETTER R WITH INVERTED BREVE
		# $filingName =~ s/\x{0214}/_/gi; # LATIN CAPITAL LETTER U WITH DOUBLE GRAVE
		# $filingName =~ s/\x{0215}/_/gi; # LATIN SMALL LETTER U WITH DOUBLE GRAVE
		# $filingName =~ s/\x{0216}/_/gi; # LATIN CAPITAL LETTER U WITH INVERTED BREVE
		# $filingName =~ s/\x{0217}/_/gi; # LATIN SMALL LETTER U WITH INVERTED BREVE
		# $filingName =~ s/\x{0218}/_/gi; # LATIN CAPITAL LETTER S WITH COMMA BELOW
		# $filingName =~ s/\x{0219}/_/gi; # LATIN SMALL LETTER S WITH COMMA BELOW
		# $filingName =~ s/\x{021a}/_/gi; # LATIN CAPITAL LETTER T WITH COMMA BELOW
		# $filingName =~ s/\x{021b}/_/gi; # LATIN SMALL LETTER T WITH COMMA BELOW
		# $filingName =~ s/\x{021c}/_/gi; # LATIN CAPITAL LETTER YOGH
		# $filingName =~ s/\x{021d}/_/gi; # LATIN SMALL LETTER YOGH
		# $filingName =~ s/\x{021e}/_/gi; # LATIN CAPITAL LETTER H WITH CARON
		# $filingName =~ s/\x{021f}/_/gi; # LATIN SMALL LETTER H WITH CARON
		# $filingName =~ s/\x{0220}/_/gi; # LATIN CAPITAL LETTER N WITH LONG RIGHT LEG
		# $filingName =~ s/\x{0221}/_/gi; # LATIN SMALL LETTER D WITH CURL
		# $filingName =~ s/\x{0222}/_/gi; # LATIN CAPITAL LETTER OU
		# $filingName =~ s/\x{0223}/_/gi; # LATIN SMALL LETTER OU
		# $filingName =~ s/\x{0224}/_/gi; # LATIN CAPITAL LETTER Z WITH HOOK
		# $filingName =~ s/\x{0225}/_/gi; # LATIN SMALL LETTER Z WITH HOOK
		# $filingName =~ s/\x{0226}/_/gi; # LATIN CAPITAL LETTER A WITH DOT ABOVE
		# $filingName =~ s/\x{0227}/_/gi; # LATIN SMALL LETTER A WITH DOT ABOVE
		# $filingName =~ s/\x{0228}/_/gi; # LATIN CAPITAL LETTER E WITH CEDILLA
		# $filingName =~ s/\x{0229}/_/gi; # LATIN SMALL LETTER E WITH CEDILLA
		# $filingName =~ s/\x{022a}/_/gi; # LATIN CAPITAL LETTER O WITH DIAERESIS AND MACRON
		# $filingName =~ s/\x{022b}/_/gi; # LATIN SMALL LETTER O WITH DIAERESIS AND MACRON
		# $filingName =~ s/\x{022c}/_/gi; # LATIN CAPITAL LETTER O WITH TILDE AND MACRON
		# $filingName =~ s/\x{022d}/_/gi; # LATIN SMALL LETTER O WITH TILDE AND MACRON
		# $filingName =~ s/\x{022e}/_/gi; # LATIN CAPITAL LETTER O WITH DOT ABOVE
		# $filingName =~ s/\x{022f}/_/gi; # LATIN SMALL LETTER O WITH DOT ABOVE
		# $filingName =~ s/\x{0230}/_/gi; # LATIN CAPITAL LETTER O WITH DOT ABOVE AND MACRON
		# $filingName =~ s/\x{0231}/_/gi; # LATIN SMALL LETTER O WITH DOT ABOVE AND MACRON
		# $filingName =~ s/\x{0232}/_/gi; # LATIN CAPITAL LETTER Y WITH MACRON
		# $filingName =~ s/\x{0233}/_/gi; # LATIN SMALL LETTER Y WITH MACRON
		# $filingName =~ s/\x{0234}/_/gi; # LATIN SMALL LETTER L WITH CURL
		# $filingName =~ s/\x{0235}/_/gi; # LATIN SMALL LETTER N WITH CURL
		# $filingName =~ s/\x{0236}/_/gi; # LATIN SMALL LETTER T WITH CURL
		# $filingName =~ s/\x{0237}/_/gi; # LATIN SMALL LETTER DOTLESS J
		# $filingName =~ s/\x{0238}/_/gi; # LATIN SMALL LETTER DB DIGRAPH
		# $filingName =~ s/\x{0239}/_/gi; # LATIN SMALL LETTER QP DIGRAPH
		# $filingName =~ s/\x{023a}/_/gi; # LATIN CAPITAL LETTER A WITH STROKE
		# $filingName =~ s/\x{023b}/_/gi; # LATIN CAPITAL LETTER C WITH STROKE
		# $filingName =~ s/\x{023c}/_/gi; # LATIN SMALL LETTER C WITH STROKE
		# $filingName =~ s/\x{023d}/_/gi; # LATIN CAPITAL LETTER L WITH BAR
		# $filingName =~ s/\x{023e}/_/gi; # LATIN CAPITAL LETTER T WITH DIAGONAL STROKE
		# $filingName =~ s/\x{023f}/_/gi; # LATIN SMALL LETTER S WITH SWASH TAIL
		# $filingName =~ s/\x{0240}/_/gi; # LATIN SMALL LETTER Z WITH SWASH TAIL
		# $filingName =~ s/\x{0241}/_/gi; # LATIN CAPITAL LETTER GLOTTAL STOP
		# $filingName =~ s/\x{0242}/_/gi; # 
		# $filingName =~ s/\x{0243}/_/gi; # 
		# $filingName =~ s/\x{0244}/_/gi; # 
		# $filingName =~ s/\x{0245}/_/gi; # 
		# $filingName =~ s/\x{0246}/_/gi; # 
		# $filingName =~ s/\x{0247}/_/gi; # 
		# $filingName =~ s/\x{0248}/_/gi; # 
		# $filingName =~ s/\x{0249}/_/gi; # 
		# $filingName =~ s/\x{024a}/_/gi; # 
		# $filingName =~ s/\x{024b}/_/gi; # 
		# $filingName =~ s/\x{024c}/_/gi; # 
		# $filingName =~ s/\x{024d}/_/gi; # 
		# $filingName =~ s/\x{024e}/_/gi; # 
		# $filingName =~ s/\x{024f}/_/gi; # 
		# $filingName =~ s/\x{0250}/_/gi; # LATIN SMALL LETTER TURNED A
		# $filingName =~ s/\x{0251}/_/gi; # LATIN SMALL LETTER ALPHA
		# $filingName =~ s/\x{0252}/_/gi; # LATIN SMALL LETTER TURNED ALPHA
		# $filingName =~ s/\x{0253}/_/gi; # LATIN SMALL LETTER B WITH HOOK
		# $filingName =~ s/\x{0254}/_/gi; # LATIN SMALL LETTER OPEN O
		# $filingName =~ s/\x{0255}/_/gi; # LATIN SMALL LETTER C WITH CURL
		# $filingName =~ s/\x{0256}/_/gi; # LATIN SMALL LETTER D WITH TAIL
		# $filingName =~ s/\x{0257}/_/gi; # LATIN SMALL LETTER D WITH HOOK
		# $filingName =~ s/\x{0258}/_/gi; # LATIN SMALL LETTER REVERSED E
		# $filingName =~ s/\x{0259}/_/gi; # LATIN SMALL LETTER SCHWA
		# $filingName =~ s/\x{025a}/_/gi; # LATIN SMALL LETTER SCHWA WITH HOOK
		# $filingName =~ s/\x{025b}/_/gi; # LATIN SMALL LETTER OPEN E
		# $filingName =~ s/\x{025c}/_/gi; # LATIN SMALL LETTER REVERSED OPEN E
		# $filingName =~ s/\x{025d}/_/gi; # LATIN SMALL LETTER REVERSED OPEN E WITH HOOK
		# $filingName =~ s/\x{025e}/_/gi; # LATIN SMALL LETTER CLOSED REVERSED OPEN E
		# $filingName =~ s/\x{025f}/_/gi; # LATIN SMALL LETTER DOTLESS J WITH STROKE
		# $filingName =~ s/\x{0260}/_/gi; # LATIN SMALL LETTER G WITH HOOK
		# $filingName =~ s/\x{0261}/_/gi; # LATIN SMALL LETTER SCRIPT G
		# $filingName =~ s/\x{0262}/_/gi; # LATIN LETTER SMALL CAPITAL G
		# $filingName =~ s/\x{0263}/_/gi; # LATIN SMALL LETTER GAMMA
		# $filingName =~ s/\x{0264}/_/gi; # LATIN SMALL LETTER RAMS HORN
		# $filingName =~ s/\x{0265}/_/gi; # LATIN SMALL LETTER TURNED H
		# $filingName =~ s/\x{0266}/_/gi; # LATIN SMALL LETTER H WITH HOOK
		# $filingName =~ s/\x{0267}/_/gi; # LATIN SMALL LETTER HENG WITH HOOK
		# $filingName =~ s/\x{0268}/_/gi; # LATIN SMALL LETTER I WITH STROKE
		# $filingName =~ s/\x{0269}/_/gi; # LATIN SMALL LETTER IOTA
		# $filingName =~ s/\x{026a}/_/gi; # LATIN LETTER SMALL CAPITAL I
		# $filingName =~ s/\x{026b}/_/gi; # LATIN SMALL LETTER L WITH MIDDLE TILDE
		# $filingName =~ s/\x{026c}/_/gi; # LATIN SMALL LETTER L WITH BELT
		# $filingName =~ s/\x{026d}/_/gi; # LATIN SMALL LETTER L WITH RETROFLEX HOOK
		# $filingName =~ s/\x{026e}/_/gi; # LATIN SMALL LETTER LEZH
		# $filingName =~ s/\x{026f}/_/gi; # LATIN SMALL LETTER TURNED M
		# $filingName =~ s/\x{0270}/_/gi; # LATIN SMALL LETTER TURNED M WITH LONG LEG
		# $filingName =~ s/\x{0271}/_/gi; # LATIN SMALL LETTER M WITH HOOK
		# $filingName =~ s/\x{0272}/_/gi; # LATIN SMALL LETTER N WITH LEFT HOOK
		# $filingName =~ s/\x{0273}/_/gi; # LATIN SMALL LETTER N WITH RETROFLEX HOOK
		# $filingName =~ s/\x{0274}/_/gi; # LATIN LETTER SMALL CAPITAL N
		# $filingName =~ s/\x{0275}/_/gi; # LATIN SMALL LETTER BARRED O
		# $filingName =~ s/\x{0276}/_/gi; # LATIN LETTER SMALL CAPITAL OE
		# $filingName =~ s/\x{0277}/_/gi; # LATIN SMALL LETTER CLOSED OMEGA
		# $filingName =~ s/\x{0278}/_/gi; # LATIN SMALL LETTER PHI
		# $filingName =~ s/\x{0279}/_/gi; # LATIN SMALL LETTER TURNED R
		# $filingName =~ s/\x{027a}/_/gi; # LATIN SMALL LETTER TURNED R WITH LONG LEG
		# $filingName =~ s/\x{027b}/_/gi; # LATIN SMALL LETTER TURNED R WITH HOOK
		# $filingName =~ s/\x{027c}/_/gi; # LATIN SMALL LETTER R WITH LONG LEG
		# $filingName =~ s/\x{027d}/_/gi; # LATIN SMALL LETTER R WITH TAIL
		# $filingName =~ s/\x{027e}/_/gi; # LATIN SMALL LETTER R WITH FISHHOOK
		# $filingName =~ s/\x{027f}/_/gi; # LATIN SMALL LETTER REVERSED R WITH FISHHOOK
		# $filingName =~ s/\x{0280}/_/gi; # LATIN LETTER SMALL CAPITAL R
		# $filingName =~ s/\x{0281}/_/gi; # LATIN LETTER SMALL CAPITAL INVERTED R
		# $filingName =~ s/\x{0282}/_/gi; # LATIN SMALL LETTER S WITH HOOK
		# $filingName =~ s/\x{0283}/_/gi; # LATIN SMALL LETTER ESH
		# $filingName =~ s/\x{0284}/_/gi; # LATIN SMALL LETTER DOTLESS J WITH STROKE AND HOOK
		# $filingName =~ s/\x{0285}/_/gi; # LATIN SMALL LETTER SQUAT REVERSED ESH
		# $filingName =~ s/\x{0286}/_/gi; # LATIN SMALL LETTER ESH WITH CURL
		# $filingName =~ s/\x{0287}/_/gi; # LATIN SMALL LETTER TURNED T
		# $filingName =~ s/\x{0288}/_/gi; # LATIN SMALL LETTER T WITH RETROFLEX HOOK
		# $filingName =~ s/\x{0289}/_/gi; # LATIN SMALL LETTER U BAR
		# $filingName =~ s/\x{028a}/_/gi; # LATIN SMALL LETTER UPSILON
		# $filingName =~ s/\x{028b}/_/gi; # LATIN SMALL LETTER V WITH HOOK
		# $filingName =~ s/\x{028c}/_/gi; # LATIN SMALL LETTER TURNED V
		# $filingName =~ s/\x{028d}/_/gi; # LATIN SMALL LETTER TURNED W
		# $filingName =~ s/\x{028e}/_/gi; # LATIN SMALL LETTER TURNED Y
		# $filingName =~ s/\x{028f}/_/gi; # LATIN LETTER SMALL CAPITAL Y
		# $filingName =~ s/\x{0290}/_/gi; # LATIN SMALL LETTER Z WITH RETROFLEX HOOK
		# $filingName =~ s/\x{0291}/_/gi; # LATIN SMALL LETTER Z WITH CURL
		# $filingName =~ s/\x{0292}/_/gi; # LATIN SMALL LETTER EZH
		# $filingName =~ s/\x{0293}/_/gi; # LATIN SMALL LETTER EZH WITH CURL
		# $filingName =~ s/\x{0294}/_/gi; # LATIN LETTER GLOTTAL STOP
		# $filingName =~ s/\x{0295}/_/gi; # LATIN LETTER PHARYNGEAL VOICED FRICATIVE
		# $filingName =~ s/\x{0296}/_/gi; # LATIN LETTER INVERTED GLOTTAL STOP
		# $filingName =~ s/\x{0297}/_/gi; # LATIN LETTER STRETCHED C
		# $filingName =~ s/\x{0298}/_/gi; # LATIN LETTER BILABIAL CLICK
		# $filingName =~ s/\x{0299}/_/gi; # LATIN LETTER SMALL CAPITAL B
		# $filingName =~ s/\x{029a}/_/gi; # LATIN SMALL LETTER CLOSED OPEN E
		# $filingName =~ s/\x{029b}/_/gi; # LATIN LETTER SMALL CAPITAL G WITH HOOK
		# $filingName =~ s/\x{029c}/_/gi; # LATIN LETTER SMALL CAPITAL H
		# $filingName =~ s/\x{029d}/_/gi; # LATIN SMALL LETTER J WITH CROSSED-TAIL
		# $filingName =~ s/\x{029e}/_/gi; # LATIN SMALL LETTER TURNED K
		# $filingName =~ s/\x{029f}/_/gi; # LATIN LETTER SMALL CAPITAL L
		# $filingName =~ s/\x{02a0}/_/gi; # LATIN SMALL LETTER Q WITH HOOK
		# $filingName =~ s/\x{02a1}/_/gi; # LATIN LETTER GLOTTAL STOP WITH STROKE
		# $filingName =~ s/\x{02a2}/_/gi; # LATIN LETTER REVERSED GLOTTAL STOP WITH STROKE
		# $filingName =~ s/\x{02a3}/_/gi; # LATIN SMALL LETTER DZ DIGRAPH
		# $filingName =~ s/\x{02a4}/_/gi; # LATIN SMALL LETTER DEZH DIGRAPH
		# $filingName =~ s/\x{02a5}/_/gi; # LATIN SMALL LETTER DZ DIGRAPH WITH CURL
		# $filingName =~ s/\x{02a6}/_/gi; # LATIN SMALL LETTER TS DIGRAPH
		# $filingName =~ s/\x{02a7}/_/gi; # LATIN SMALL LETTER TESH DIGRAPH
		# $filingName =~ s/\x{02a8}/_/gi; # LATIN SMALL LETTER TC DIGRAPH WITH CURL
		# $filingName =~ s/\x{02a9}/_/gi; # LATIN SMALL LETTER FENG DIGRAPH
		# $filingName =~ s/\x{02aa}/_/gi; # LATIN SMALL LETTER LS DIGRAPH
		# $filingName =~ s/\x{02ab}/_/gi; # LATIN SMALL LETTER LZ DIGRAPH
		# $filingName =~ s/\x{02ac}/_/gi; # LATIN LETTER BILABIAL PERCUSSIVE
		# $filingName =~ s/\x{02ad}/_/gi; # LATIN LETTER BIDENTAL PERCUSSIVE
		# $filingName =~ s/\x{02ae}/_/gi; # LATIN SMALL LETTER TURNED H WITH FISHHOOK
		# $filingName =~ s/\x{02af}/_/gi; # LATIN SMALL LETTER TURNED H WITH FISHHOOK AND TAIL
		# $filingName =~ s/\x{02b0}/_/gi; # MODIFIER LETTER SMALL H
		# $filingName =~ s/\x{02b1}/_/gi; # MODIFIER LETTER SMALL H WITH HOOK
		# $filingName =~ s/\x{02b2}/_/gi; # MODIFIER LETTER SMALL J
		# $filingName =~ s/\x{02b3}/_/gi; # MODIFIER LETTER SMALL R
		# $filingName =~ s/\x{02b4}/_/gi; # MODIFIER LETTER SMALL TURNED R
		# $filingName =~ s/\x{02b5}/_/gi; # MODIFIER LETTER SMALL TURNED R WITH HOOK
		# $filingName =~ s/\x{02b6}/_/gi; # MODIFIER LETTER SMALL CAPITAL INVERTED R
		# $filingName =~ s/\x{02b7}/_/gi; # MODIFIER LETTER SMALL W


		# Rule 3 - Order of fields with identical leading elements
		#
		# does not apply

		# Rule 4 - Place names
		#
		# does not apply

		# Rule 5 - Identical filing entries
		#
		# Interpretted as meaning do them in some other respectible order,
		# which I would use multiverse id for. However, since I am only
		# concerned with base cards at this time, muid does not exist. So
		# no-op.

		# Rule 6 - Abbreviations. File abbreviations exactly as written.
		#
		# No-op

		# Rule 7 - Trreat bracketed data as signifcant
		#
		# No-op

		# Rule 8 - Hyphenated words.
		# 
		# Treat words connected by a hyphen as separate words, regardless of
		# language.
		$filingName =~ s/-/ /gi;	  # dash
		$filingName =~ s/\x{2013}/ /gi; # endash
		$filingName =~ s/\x{2014}/ /gi; # emdash

		# Rule 9 and 10 - Initial articles.
		#
		# Don't include them at the start of a title, unless it is a
		# person or place. We will assume that all Cards are of a
		# Person or Place (although this isn't quite true).
		#$filingName =~ s/^a //gi;
		#$filingName =~ s/^an //gi; # dash
		#$filingName =~ s/^ye //gi; # dash
		#$filingName =~ s/^de //gi; # dash
		#$filingName =~ s/^d'//gi; # dash

		# Rule 11 - Initials and acronyms
		# 
		# Essentially, make periods and ellipses into spaces
		$filingName =~ s/\./ /gi;	  # dash
		$filingName =~ s/\x{2026}/ /gi; # emdash

		# Rule 12 - Names with a prefix. Treat a prefix that is part of a
		# name or place as a separate word unless it is joined to the rest
		# of the name directly or by an apostrophe without a space. File 
		# letter by letter. 
		$filingName =~ s/([a-z])'([a-z])/\1\2/gi;

		# Rule 12
		#
		# No op

		# Rule 13
		#
		# Not taking action on roman numeral interpretation as arabic

		# Rule 16  - Ignore all symbols except for "&"
		# 
		# Putting this rule before Rule 14 since comma can be used in nmbers and it is easier to process this first.

		foreach my $symb (@ignored_punctuation) {
			$filingName =~ s/\Q$symb//ge;
		}
		$filingName =~ s/\s+/ /gi;

		# Rule 14 - Numerals
		# 
		# Complicated, since there could be unknown number of digits. Assuming 9 digits
	
		# if it starts with a number, let's fix that number.
		$filingName =~ s/^([\d,]+)/$aaa->('',$1)/gie;
		# if there is a number in the middle, let's fix it
		$filingName =~ s/([^\.\d])([\d,]+)/$aaa->($1,$2)/gie;
	}
	return $filingName;
}

1;
