package Spreadsheet::HTML::Presets::Calculator;
use strict;
use warnings FATAL => 'all';

use Spreadsheet::HTML::Presets;

eval "use JavaScript::Minifier";
our $NO_MINIFY = $@;

sub _javascript {
    my %args = @_;

    my $js = _js_tmpl();

    unless ($NO_MINIFY) {
        $js = JavaScript::Minifier::minify( input => $js );
    }

    return Spreadsheet::HTML::Presets::_html_tmpl( code => $js, %args );
}

sub _js_tmpl {
    return <<'END_JAVASCRIPT';

/* Copyright (C) 2015 Jeff Anderson */

var DISPLAY  = [ 0 ];
var OPERANDS = [];

$(document).ready(function(){

    $('#display').prop( 'readonly', 'readonly' );

    $('button').click( function( data ) {

        var html = $(this).html();
        var val  = $('<div/>').html(html).text();

        if (val === '.' && ( DISPLAY[0] === 0 || DISPLAY[0].indexOf('.') === -1 )) {

            DISPLAY[0] += val;

        } else if (+val === parseInt( val )) {

            if (DISPLAY[0] === "0.") {
                DISPLAY[0] += val;
            } else if (DISPLAY[0] == 0) {
                DISPLAY[0] = val;
            } else {
                DISPLAY[0] += val;
            }

        } else if (val === '+') {

            OPERANDS.unshift( '+' );
            DISPLAY.unshift( 0 );

        } else if (val.charCodeAt(0) == 8722) {

            OPERANDS.unshift( '-' );
            DISPLAY.unshift( 0 );

        } else if (val.charCodeAt(0) == 215) {

            OPERANDS.unshift( '*' );
            DISPLAY.unshift( 0 );

        } else if (val.charCodeAt(0) == 247) {

            OPERANDS.unshift( '/' );
            DISPLAY.unshift( 0 );

        } else if (val.charCodeAt(0) == 177) {

            DISPLAY[0] *= -1;

        } else if (val === '=') {

            var operand = OPERANDS.shift();
            var value = eval( DISPLAY[1] + operand + DISPLAY[0] );
            DISPLAY = [ value ];
            update();
            DISPLAY = [ 0 ];
            return;

        } else if (val === 'C') {

            DISPLAY = [ 0 ];
        }

        update();
    });

    update();
});

function update() { $('#display').val( DISPLAY[0] ) }

END_JAVASCRIPT
}

=head1 NAME

Spreadsheet::HTML::Presets::Calculator - Javascript implementation of a calculator.

See L<Spreadsheet::HTML::Presets>

=head1 AUTHOR

Jeff Anderson, C<< <jeffa at cpan.org> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2015 Jeff Anderson.

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

1;
