package String::Generator;

use strict;
use warnings;
use Regexp::Parser;
use Moose;
use feature qw/say unicode_strings/;
use Data::Dumper;

=head1 NAME

String::Generator - The great new String::Generator!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use String::Generator;

    my $foo = String::Generator->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 ATTRIBUTES

=head2 max_repeat
determines the max range of repition in patterns which use * or + quantifiers
Set in the contructor
	my $generator = String::Generator->new({max_repeat => 50});
	#or via accessor
	$generator->max_repeat(2);
=cut

has 'max_repeat' => (
    is      => 'rw',
    isa     => 'Int',
    default => '10',
);

=head2 unicode_low
To be used in conjunction with unicode_high attribute to specify a unicode
range to use when determining random values for patterns which use '.' or
negated character sets in their pattern.
=cut

has 'unicode_low' => (
    is      => 'rw',
    isa     => 'Int',
    default => 0,
);

=head2 unicode_high
Determines the max range in unicode to use for random patterns which random
values such those using the '.' or negated character sets like [^\d]{2}.
So if you only want ACSII values set this to 255
	my $generator = String::Generator->new({unicode_high => 255});
	#or via accessor
	$generator->unicode_high(255);
=cut

has 'unicode_high' => (
    is      => 'rw',
    isa     => 'Int',
    default => 65536,
);

=head1 SUBROUTINES/METHODS

=head2 generate

=cut

sub generate {
    my ( $self, $regex ) = @_;
    my $parser = Regexp::Parser->new();
    confess $parser->errmsg if !$parser->regex($regex);
    return $self->_gen_string( q//, $parser->walker );
}

sub _gen_string {
    my ( $self, $string, $iter ) = @_;

    # my $node = $iter->();
    # return q// if not defined $node;
    # my $type = '_' . $node->type();
    # return $current . $self->$type($node) if $self->can($type);
    while ( my $node = $iter->() ) {
        my $type = '_' . $node->family();
        say '_gen_string: ' . $type;
        $string .= $self->$type( $node, $iter );
    }
    return $string;
}

sub _exact {
    my ( $self, $node ) = @_;
    say '_exact: ' . $node->raw();
    return $node->data();
}

sub _quant {
    my ( $self, $node, $iter ) = @_;
    my $string   = q//;
    my $quantity = $self->_quantity_from_raw( $node->raw() );
    say '_quant: ' . $quantity;
    my $next          = $iter->();
    my $method        = '_' . $next->family();
    my $repeat_string = $self->$method( $next, $iter );
    for ( 1 .. $quantity ) {
        $string .= $repeat_string;
    }
    return $string;
}

sub _anyof {
    my ( $self, $node, $iter ) = @_;
    my $string  = q//;
    my $next    = $iter->();
    my @options = ();
    while ( $next->family() ne 'close' and $next->type() ne 'anyof_close' ) {
        my $method = '_' . $next->family();
        push @options, $self->$method( $next, $iter );
        $next = $iter->();
    }
    say '_anyof: ' . $#options;
    say 'pick: ' . $self->_rand_range( 0, 0 );
    $string = $options[ $self->_rand_range( 0, $#options ) ];
    return $string;
}

sub _anyof_char {
    my ( $self, $node ) = @_;
    return $node->data();
}

sub _anyof_range {
    my ( $self, $node ) = @_;
    say 'anyof_range';
    my $range_ref = $node->data();
    say 'anyof_range: ' . $range_ref->[0]->data();
    my $letter = chr(
        $self->_rand_range(
            ord( $range_ref->[0]->data() ),
            ord( $range_ref->[1]->data() )
        )
    );
    say 'anyof_range letter: ' . $letter;
    return $letter;
}

sub _reg_any {
    my ($self) = @_;
    return
        chr(
        $self->_rand_range( $self->unicode_low(), $self->unicode_high() ) );
}

sub _open {
    my ( $self, $node, $iter ) = @_;
    my $string  = q//;
    my $next    = $iter->();
    my @options = ();
    my ( undef, $capture_number ) = split( 'open', $node->type() );
    say "_open #" . $capture_number;
    while ( $next->family() ne 'close'
        and $next->type() ne 'close' . $capture_number )
    {
        if ( $next->family() eq 'branch' ) {
            $next = $iter->();
            next;
        }
        my $method = '_' . $next->family();
        push @options, $self->$method( $next, $iter );
        $next = $iter->();
    }
    $string = $options[ $self->_rand_range( 0, $#options ) ];
    return $string;
}

sub _branch {
    my ($self) = @_;
    return q//;
}

sub _digit {
    my ( $self, $node ) = @_;
    return $self->_rand_range( 0, 9 );
}

sub _quantity_from_raw {
    my ( $self, $raw ) = @_;
    if ( $raw =~ qr/\?/ ) {
        return rand(1);
    }
    elsif ( $raw =~ qr/^\{(\d),(\d)\}$/ ) {
        return $self->_rand_range( $1, $2 );
    }
    elsif ( $raw =~ qr/\{(\d)\}/ ) {
        return $1;
    }
    elsif ( $raw eq '+' ) {
        return $self->_rand_range( 1, $self->max_repeat() );
    }
    elsif ( $raw eq '*' ) {
        return $self->_rand_range( 0, $self->max_repeat() );
    }
    elsif ( $raw eq '?' ) {
        return $self->_rand_range( 0, 1 );
    }
    return;
}

sub _rand_range {
    my ( $self, $min, $max ) = @_;
    return $min if $min == $max;
    return $min + int( rand( $max - $min ) ) + 1;
}

=head1 AUTHOR

William F Wheeler II, C<< <wfwheele at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-string-generator at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=String-Generator>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc String::Generator


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=String-Generator>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/String-Generator>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/String-Generator>

=item * Search CPAN

L<http://search.cpan.org/dist/String-Generator/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2016 William F Wheeler.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1;    # End of String::Generator
