package MTG::Exception;

use Exception::Class (
	MTG::Exception::NullPointer => {},
		      
	MTG::Exception::WrongClass => {},

	MTG::Exception::Configuration => {},
		      
	MTG::Exception::SystemIO => {},
		      
	MTG::Exception::FieldValidation => {
		field => ''
	},
		      
	MTG::Exception::Unique => {
		field => ''
	},
		      
	MTG::Exception::Registration => {
		exceptions => (),
	},
		      
	MTG::Exception::DAL => {
		description => 'DAL Exception',
		method => undef,
		where => undef,
	},
		      
	MTG::Exception::Senses => {
		description => 'foo',
		field => ''
	},
		      
	MTG::Exception::Smell => {
		isa         => 'MTG::Exception::Senses',
		fields      => 'odor',
		description => 'stinky!'
	},
		      
	MTG::Exception::Taste => {
		isa         => 'MTG::Exception::Senses',
		fields      => [ 'taste', 'bitterness' ],
		description => 'like, gag me with a spoon!'
	},
);

1;
