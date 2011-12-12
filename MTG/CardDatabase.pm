package MTG::CardDatabase;

use strict;
use MongoDB::Connection;

sub new {
    my $class = shift;
    my $self = {config=>{}};
	eval {
		my $conn = MongoDB::Connection->new('host' => 'mongodb://' . ($self->{config}->{host} || 'localhost') . ':' . ($self->{config}->{port} || '27017'));
		my $db = $conn->get_database($self->{config}->{name} || 'mtg');

		# Add few more attributes
		$self->{connection} = $conn;
		$self->{db} = $db;
    }; if (defined $@ && $@ ne '') {
		$@ =~ /^(.+) at (\/?\w.+)$/;
		#IdApp::Exception::DAL->throw(message => $1, show_trace => 1);
		die($@);
    }

	bless($self, $class);

	return $self;
}

sub getById {
	my $self = shift;
	my $id = shift;

	my $cards = $self->{db}->get_collection('cards');
	my $res_doc;
	my $res_card;
	eval {
		$res_doc = $cards->find_one({'_id'=>$id});
		$res_card = MTG::Card->new($res_doc);
    };

    if ($@) {
		# we have a duplicate key on field $1;
		#my $ex = IdApp::Exception::DALUnique->new(message => $1 . ' must be unique', show_trace => 1);
		#$ex->{field} = $1;
		#$ex->throw();
		die($@);
    }

	return $res_card;
}


1;
