package MTG::Web::App;

use strict;
use MTG::Database;
use MTG::Card;
use MTG::Web::DeckController;
use MTG::Web::CardController;
use MTG::Web::TagController;
use Data::Dumper;

sub new {
	my $class = shift;
	my $self = {}; #$class->SUPER::new();
	$self->{db} = MTG::Database->new();

	$self->{tt} = Template->new({
		INCLUDE_PATH => '/home/jason/projects/mtgstats/views',
		INTERPOLATE  => 0,
	}) || die "$Template::ERROR\n";

	$self->{deck_controller} = MTG::Web::DeckController->new($self);
	$self->{card_controller} = MTG::Web::CardController->new($self);
	$self->{tag_controller} = MTG::Web::TagController->new($self);
	$self->{tag_controller}->init($self->{db});

	bless($self, $class);
	return $self;
}

sub call {
    # $env is the full PSGI environment
    my ($self, $env) = @_;

	if ($env->{PATH_INFO} eq '/deck' || $env->{PATH_INFO} eq '/') {
		return $self->relocate($env, '/deck/');
	} elsif ($env->{PATH_INFO} eq '/card') {
		return $self->relocate($env, '/card/');
	} elsif ($env->{PATH_INFO} eq '/tag') {
		return $self->relocate($env, '/tag/');
	} elsif ($env->{PATH_INFO} =~ /^\/Handler/) {
		return $self->relocate($env, $env->{'PATH_INFO'}, 'http', 'gatherer.wizards.com');
	}

	# as a convenience, go ahead and split out the quert string.
	my @qsp = split(/&/, $env->{QUERY_STRING});
	foreach my $part (@qsp) {
		$part =~ /^([^=]+)=?(.*)$/;
		my $k = $1;
		my $v = $2;
		$k =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;
		$v =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;
		if ($k =~ /^([^\[]+)\[\]$/) {
			my $kname = $1;
			if (! defined $env->{'app.qs'}->{$kname}) {
				$env->{'app.qs'}->{$kname} = [];
			} elsif (ref $env->{'app.qs'}->{$kname} eq '') {
				$env->{'app.qs'}->{$kname} = [$env->{'app.qs'}->{$kname}];
			}
			push @{$env->{'app.qs'}->{$kname}}, $v;
		} else {
			$env->{'app.qs'}->{$k} = $v;
		}
	}

	$env->{PATH_INFO} =~ /^\/([^\/]+)/;
	my $contName = $1 || 'deck';
	my $actionName = 'default';
	if ($env->{PATH_INFO} =~ /^\/[^\/]+\/([^\/]+)/) {
		$actionName = $1;
	}

	my $controller = $self->{$contName . '_controller'} || $self->{deck_controller};

	my $result = $controller->$actionName($env);

	return $result;
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
