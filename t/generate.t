use strict;
use warnings;
use Test::More;
use String::Generator;

my $str_gen = String::Generator->new();
is( $str_gen->generate('a'), 'a' );
like($str_gen->generate('ab?'), qr/ab?/);
like($str_gen->generate('ab+'), qr/ab+/);
like( $str_gen->generate('a?'), qr/a?/ );
like( $str_gen->generate('a+'), qr/a+/ );
like( $str_gen->generate('a*'), qr/a*/ );
is( $str_gen->generate('a{3}'), 'aaa' );
is( $str_gen->generate('ab{2}'), 'abb', 'ab{2}');
like($str_gen->generate('[ab]'), qr/[ab]/, '[ab]');
like($str_gen->generate('[ab]{3}'), qr/[ab]{3}/, '[ab]{3}');
is($str_gen->generate('[(a)]'), 'a', '[(a)]');
like($str_gen->generate('(a|b)'), qr/(a|b)/, '(a|b)');
done_testing();
