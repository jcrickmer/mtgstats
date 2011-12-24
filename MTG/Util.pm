package MTG::Util;

use Exporter;
use base qw(Exporter);
@EXPORT_OK = qw(checkClass);

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

1;
