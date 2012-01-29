package MTG::Web::Controller;

use strict;
use utf8;

sub new {
	my $class = shift;
	my $self = {app => shift};
	bless($self, $class);
	return $self;
}

sub relocate {
    my $self = shift;
	my $env = shift;
	my $newPath = shift || $env->{'PATH_INFO'};
	my $newScheme = shift || $env->{'psgi.url_scheme'};
	my $newHost = shift || $env->{'HTTP_HOST'};
	my $newQS = shift || $env->{'QUERY_STRING'};
	return [301,
			['Location' => $newScheme . '://' . $newHost . $newPath . (defined $newQS && length($newQS) ? '?' . $newQS : ''),],
			['',]
		];
}

1;
