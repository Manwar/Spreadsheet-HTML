package Spreadsheet::HTML;
use strict;
use warnings FATAL => 'all';
our $VERSION = '0.11';

use Clone;
use HTML::Element;
use Math::Matrix;

use Spreadsheet::HTML::CSV;
use Spreadsheet::HTML::HTML;
use Spreadsheet::HTML::JSON;
use Spreadsheet::HTML::YAML;

sub portrait    { generate( @_ ) }
sub generate    { _make_table( process( @_ ) ) }

sub landscape   { transpose( @_ ) }
sub transpose   {
    my %args = process( @_ );
    $args{data} = [@{ Math::Matrix::transpose( $args{data} ) }];
    return _make_table( %args );
}

sub flip   {
    my %args = process( @_ );
    $args{data} = [ CORE::reverse @{ $args{data} } ];
    return _make_table( %args );
}

sub mirror   {
    my %args = process( @_ );
    $args{data} = [ map [ CORE::reverse @$_ ], @{ $args{data} } ];
    return _make_table( %args );
}

sub reverse   {
    my %args = process( @_ );
    $args{data} = [ map [ CORE::reverse @$_ ], CORE::reverse @{ $args{data} } ];
    return _make_table( %args );
}

sub process {
    my ($self,$data,$args) = _args( @_ );

    if ($self and $self->{is_cached}) {
        return wantarray ? ( data => $self->{data}, %$args ) : $data;
    }

    my $max_cols = scalar @{ $data->[0] };

    for my $i (0 .. $#$data) {

        push @{ $data->[$i] }, undef for 1 .. $max_cols - $#{ $data->[$i] } + 1;  # pad
        pop  @{ $data->[$i] } for $max_cols .. $#{ $data->[$i] };                 # truncate

        for my $j (0 .. $#{ $data->[$i] }) {
            my $tag = (!$i and !($args->{headless} or $args->{matrix})) ? 'th' : 'td';
            $data->[$i][$j] = _element( $tag => _scrub( $data->[$i][$j] ), $args->{$tag} );
        }
    }

    if ($args->{cache} and $self and !$self->{is_cached}) {
        $self->{data} = $data;
        $self->{is_cached} = 1;
    }

    shift @$data if $args->{headless};

    return wantarray ? ( data => $data, %$args ) : $data;
}

sub new {
    my $class = shift;
    my %attrs = ref($_[0]) eq 'HASH' ? %{+shift} : @_;
    return bless { %attrs }, $class;
}

sub _make_table {
    my %args = @_;
    $args{$_} ||= {} for qw( table tr );

    my $encodes = exists $args{encodes} ? $args{encodes} : '';

    my $table = HTML::Element->new_from_lol(
        [table => $args{table},
            map [tr => $args{tr}, @$_ ], @{ $args{data} }
        ],
    );

    chomp( my $html = $table->as_HTML( $encodes, $args{indent} ) );
    return $html;
}

sub _scrub {
    my $value = shift;
    do{ no warnings; $value =~ s/^\s*$/&nbsp;/g };
    $value =~ s/\n/<br \/>/g;
    return $value;
}

sub _element {
    my ($tag, $content, $attr) = @_;
    my $e = HTML::Element->new( $tag, %{ $attr || {} } );
    $e->push_content( $content );
    return $e;
}

sub _args {
    my ($self,$data,$args);
    $self = shift if UNIVERSAL::isa( $_[0], __PACKAGE__ );

    if (@_ > 1 && defined($_[0]) && !ref($_[0]) ) {
        my %args = @_;
        if (my $arg = delete $args{data}) {
            $data = $arg;
        }
        $args = {%args};
    } elsif (@_ > 1 && ref($_[0]) eq 'ARRAY') {
        $data = [ @_ ];
    } elsif (@_ == 1) {
        $data = $_[0];
    }

    if (ref($self)) {
        return ( $self, $self->{data}, $args ) if $self->{is_cached};
        $args = { %{ ref($self) ? $self : {} }, %{ $args || {} } };
        delete $args->{data};
        $data = $self->{data} unless $data or $args->{file};
    }

    if (my $file = $args->{file}) {
        if ($file =~ /\.csv$/) {
            $data = Spreadsheet::HTML::CSV::load( $file );
        } elsif ($file =~ /\.html?$/) {
            $data = Spreadsheet::HTML::HTML::load( $file );
        } elsif ($file =~ /\.jso?n$/) {
            $data = Spreadsheet::HTML::JSON::load( $file );
        } elsif ($file =~ /\.ya?ml$/) {
            $data = Spreadsheet::HTML::YAML::load( $file );
        }
    }

    $data = [ $data ] unless ref($data);
    $data = [ $data ] unless ref($data->[0]);
    $data = [ [undef] ] if !scalar @{ $data->[0] };

    return ( $self, Clone::clone($data), $args );
}

1;

__END__
=head1 NAME

Spreadsheet::HTML - Render HTML tables with ease.

=head1 THIS IS AN ALPHA RELEASE.

While most functionality for this module has been completed,
that final 10% takes 90% of the time ... there is still much
todo:

=over 4

=item * emit col, colgroup, thead, tbody and caption tags ... maybe ...

=item * map client functions to cells

=item * assign attrs to td tags by row

=item * do that nifty rotating attr value trick

=back

You are encouraged to try my older L<DBIx::XHTML_Table> during
the development of this module, which provides support for 
tags such as caption, col, colgroup, thead, and tbody.

=head1 SYNOPSIS

    use Spreadsheet::HTML;

    my $data = [
        [qw(header1 header2 header3)],
        [qw(a1 a2 a3)], [qw(b1 b2 b3)],
        [qw(c1 c2 c3)], [qw(d1 d2 d3)],
    ];

    my $table = Spreadsheet::HTML->new( data => $data );
    print $table->portrait;
    print $table->landscape;

    # non OO
    print Spreadsheet::HTML::portrait( $data );
    print Spreadsheet::HTML::landscape( $data );

    # load from files
    my $table = Spreadsheet::HTML->new( file => 'data.json', cache => 1 );

=head1 METHODS

=over 4

=item * new( key => 'value' )

  my $table = Spreadsheet::HTML->new;
  my $table = Spreadsheet::HTML->new( @data );
  my $table = Spreadsheet::HTML->new( $data );
  my $table = Spreadsheet::HTML->new( data => $data );
  my $table = Spreadsheet::HTML->new( { data => $data } );

Constructs object. Accepts named arguments (see ATTRIBUTES).
Unless you give it an array of array refs. Or an array ref
of array refs. Otherwise it expects named arguments. The
most favorite being 'data' which is exactly an array ref
of array refs. The first row will be treated as the headings
unless you specify otherwise (see ATTRIBUTES).

=item * generate( key => 'value' )

  my $html = $table->generate;
  my $html = $table->generate( indent => '    ' );
  my $html = $table->generate( encode => '<>&=' );
  my $html = $table->generate( table => { class => 'foo' } );

  my $html = Spreadsheet::HTML::generate( @data );
  my $html = Spreadsheet::HTML::generate( $data );
  my $html = Spreadsheet::HTML::generate(
      data   => $data,
      indent => "\t",
      encode => '<>&=',
      table  => { class => 'spreadsheet' },
  );

Returns a string that contains the rendered HTML table.
Currently (and subject to change if better ideas arise),
all data will:

=over 8

=item - be converted to &nbsp; if empty

=item - have any newlines converted to <br> tags

=back

These features are currently hard coded in (sorry). Plans
to make these transliterations configurable by the client
are planned. Plans planning plans.

=item * portrait( key => 'value' )

Alias for generate()

=item * transpose( key => 'value' )

Uses Math::Matrix to rotate the headings and data
90 degrees counter-clockwise.

=item * landscape( key => 'value' )

Alias for transpose()

=item * flip( key => 'value' )

Flips the headings and data upside down.

=item * mirror( key => 'value' )

Columns are rendered right to left.

=item * reverse( key => 'value' )

Combines flip and mirror: flips the headings and
data upside down and render columns right to left.

=item * process( key => 'value' )

Returns processed data.

=back

=head1 ATTRIBUTES

All methods/procedures accept named arguments.
If named arguments are detected: the data has to be
an array ref assigned to the key 'data'. If no
named args are detected then the parameter list is
treated as the data itself, either an array containing
array references or an array reference containing
array references.

=over 4

=item * data => [ [], [], [], ... ]

The data to be rendered into table cells.

=item * file => $str

The name of the data file to read. Supported formats
are CSV, JSON, YAML and HTML (first table found).
Support for Excel files is planned.

=item * indent => $str

Render the table with whitespace indention. Defaults to
undefined which produces no trailing whitespace to tags.
Useful values are some number of spaces or tabs.  (see
L<HTML::Element>::as_HTML).

=item * encode => $str

HTML Encode contents of td tags. Defaults to empty string
which performs no encoding of entities. Pass a string like
'<>&=' to perform encoding on any characters found. If the
value is 'undef' then all unsafe characters will be
encoded as HTML entites (see L<HTML::Element>::as_HTML).

=item * cache => 0 or 1

Preserve data after it has been processed (and loaded).

=item * matrix => 0 or 1

Render the table with only td tags, no th tags, if true.

=item * headless => 0 or 1

Render the table with without headings, if true.

=item * table => { key => 'value' }

=item * tr => { key => 'value' }

=item * th => { key => 'value' }

=item * td => { key => 'value' }

Supply attributes to the HTML tags that compose the table.
There is currently no support for col, colgroup, caption,
thead and tbody. See L<DBIx::XHTML_Table> for that, which
despite being a DBI extension, can accept an AoA and produce
an table with those tags, plus totals and subtotals. That
module cannot produce a transposed table, however.

=back

=head1 REQUIRES

=over 4

=item * L<HTML::Tree>

Used to generate HTML.

=item * L<Math::Matrix>

Used for transposing data.

=item * L<Clone>

Useful for preventing data from being clobbered.

=back

=head1 REQUIRES (optional)

These modules are used to load data from various
different file formats. They should be optional
but testing is still being conducted on this feature.
Attempting to parse a file when the necessary module
is not installed should prompt a clear error and
suggest action. This version may or may not reflect that. ;)

=over 4

=item * L<Text::CSV>

=item * L<Text::CSV_XS>

=item * L<HTML::TableExtract>

=item * L<JSON>

=item * L<YAML>

=back

=head1 SEE ALSO

=over 4

=item * L<DBIx::HTML>

Uses this module (Spreadsheet::HTML) to format SQL query results.

=item * L<DBIx::XHTML_Table>

The original since 2001. Can handle advanced grouping, individual cell
value contol, rotating attributes and totals/subtotals.

=back

=head1 BUGS

Please report any bugs or feature requests to either

=over 4

=item * C<bug-spreadsheet-html at rt.cpan.org>

  Send an email.

=item * L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Spreadsheet-HTML>

  Use the web interface.

=back

I will be notified, and then you'll automatically be notified of progress
on your bug as I make changes.

=head1 GITHUB

The Github project is L<https://github.com/jeffa/Spreadsheet-HTML>

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Spreadsheet::HTML

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Spreadsheet-HTML>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Spreadsheet-HTML>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Spreadsheet-HTML>

=item * Search CPAN

L<http://search.cpan.org/dist/Spreadsheet-HTML/>

=back

=head1 ACKNOWLEDGEMENTS

Thank you very much! :)

=over 4

=item * Neil Bowers

Helped with Makefile.PL suggestions and corrections.

=back

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
