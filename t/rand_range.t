use strict;
use warnings;
use Test::More;
use String::Generator;

my $str_gen = String::Generator->new();
for ( 0 .. 50 ) {
    my $int = $str_gen->_rand_range( 0, 1 );
    ok( 0 <= $int && $int <= 1 );
}
my $int = $str_gen->_rand_range( 0, 0 );
is( $int, 0, 'always zero when min and max are 0' );
done_testing();
