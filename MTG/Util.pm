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
	$plain =~ s/<img src="\/Handlers\/Image\.ashx\?size=small&amp;name=([^&]+)&amp;type=symbol"[^>]*>/($1)/gi;
	$plain =~ s/<br[^>]*>/\n/gi;
	$plain =~ s/<\/div>/\n\n/gi;
	$plain =~ s/<[^>]+>//gi;

	return &trim($plain);
}

1;
