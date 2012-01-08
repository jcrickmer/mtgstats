package MTG::Web::App;

use strict;
use MTG::Database;
use MTG::Card;
use MTG::Web::DeckController;
use MTG::Web::CardController;
use Data::Dumper;

sub new {
	my $class = shift;
	my $self = {}; #$class->SUPER::new();
	$self->{db} = MTG::Database->new();

	$self->{tt} = Template->new({
		INCLUDE_PATH => '/home/jason/projects/mtgstats/views',
		INTERPOLATE  => 1,
	}) || die "$Template::ERROR\n";

	$self->{deck_controller} = MTG::Web::DeckController->new($self);
	$self->{card_controller} = MTG::Web::CardController->new($self);

	bless($self, $class);
	return $self;
}

sub call {
    # $env is the full PSGI environment
    my ($self, $env) = @_;

	my @qsp = split(/&/, $env->{QUERY_STRING});
	foreach my $part (@qsp) {
		$part =~ /^([^=]+)=?(.*)$/;
		$env->{'app.qs'}->{$1} = $2;
	}

	$env->{PATH_INFO} =~ /^\/([^\/]+)\/([^\/]+)/;
	my $contName = $1;
	my $actionName = $2 || 'list';

	my $controller = $self->{$contName . '_controller'} || $self->{deck_controller};

	if ($env->{PATH_INFO} eq '/deck' || $env->{PATH_INFO} eq '/') {
		return $self->relocate($env, '/deck/');
	}
	if ($env->{PATH_INFO} eq '/card') {
		return $self->relocate($env, '/card/');
	}

	my $result = $controller->$actionName($env);

	return $result;
}

sub relocate {
    my ($self, $env, $newPath) = @_;
	return [301,
			['Location' => $env->{'psgi.url_scheme'} . '://' . $env->{'HTTP_HOST'} . $newPath,],
			['',]
		];
}

1;
