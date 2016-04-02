use strict;
use warnings;
use Test::More;
use String::Generator;

my $str_gen = String::Generator->new();
is( $str_gen->generate('a'), 'a' );
like( $str_gen->generate('ab?'), qr/ab?/ );
like( $str_gen->generate('ab+'), qr/ab+/ );
like( $str_gen->generate('a?'),  qr/a?/ );
like( $str_gen->generate('a+'),  qr/a+/ );
like( $str_gen->generate('a*'),  qr/a*/ );
is( $str_gen->generate('a{3}'), 'aaa' );
is( $str_gen->generate('ab{2}'), 'abb', 'ab{2}' );
like( $str_gen->generate('[ab]'),       qr/[ab]/,       '[ab]' );
like( $str_gen->generate('[ab]{3}'),    qr/[ab]{3}/,    '[ab]{3}' );
like( $str_gen->generate('(a|b)'),      qr/(a|b)/,      '(a|b)' );
like( $str_gen->generate('(a|b|c){3}'), qr/(a|b|c){3}/, '(a|b|c){3}' );
is( $str_gen->generate('(a){3}'), 'aaa',   '(a){3}' );
is( $str_gen->generate('\['),     '[',     '\[' );
is( $str_gen->generate('aa bb'),  'aa bb', 'aa bb' );
like( $str_gen->generate('[a-z]'), qr/[a-z]/, '[a-z]' );
like( $str_gen->generate('[0-9]'), qr/[0-9]/, '[0-9]' );
like( $str_gen->generate('a-z0-9'),     qr/[a-z0-9]/ );
like( $str_gen->generate('1-5'),        qr/[1-5]/, '[1-5]' );
like( $str_gen->generate('\d'),         qr/\d/, '\d' );
like( $str_gen->generate('\d{3}'),      qr/\d{3}/, '\d{3}' );
like( $str_gen->generate('(\d{3}){2}'), qr/\d{6}/, '(\d{3}){2}' );
like( $str_gen->generate('[1-2]\d{3}'), qr/[1-2]\d{3}/, '[1-2]\d{3}' );
like(
    $str_gen->generate('(Fall|Spring|Winter|Summer) [1-2]\d{3}'),
    qr/(Fall|Spring|Winter|Summer) [1-2]\d{3}/,
    '(Fall|Spring|Winter|Summer) [1-2]\d{3}'
);
like( $str_gen->generate('.'),    qr/./,    '.' );
like( $str_gen->generate('.{3}'), qr/.{3}/, '.{3}' );
like( $str_gen->generate('.?'),   qr/.?/,   '.?' );
like( $str_gen->generate('.+'),   qr/.+/,   '.+' );
done_testing();
