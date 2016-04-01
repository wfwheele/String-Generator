use strict;
use warnings;
use lib 'lib';
use String::Generator;
use feature qw/say/;

my $gen = String::Generator->new();
say $gen->generate('ab+');
