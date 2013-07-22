package MTG::Util;

use Exporter;
use base qw(Exporter);
@EXPORT_OK = qw(checkClass trim html2Plain);

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

1;
