use strict;
use warnings;
use lib 'lib';
use String::Generator;
use feature qw/say/;

my $gen = String::Generator->new();
for( 0 .. 10){
		say "START";
		say $gen->generate('[(a)]');
		say "END";
}
