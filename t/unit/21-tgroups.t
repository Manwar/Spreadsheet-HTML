#!perl -T
use strict;
use warnings FATAL => 'all';
use Test::More tests => 17;

use Spreadsheet::HTML;

my $data = [
    [qw(header1 header2 header3 header4 )],
    [qw(foo1 bar1 baz1 qux1)],
    [qw(foo2 bar2 baz2 qux2)],
    [qw(foo3 bar3 baz3 qux3)],
    [qw(foo4 bar4 baz4 qux4)],
];

my $table = Spreadsheet::HTML->new( data => $data, tgroups => 2 );

is $table->generate,
    '<table><thead><tr><th>header1</th><th>header2</th><th>header3</th><th>header4</th></tr></thead><tfoot><tr><td>foo4</td><td>bar4</td><td>baz4</td><td>qux4</td></tr></tfoot><tbody><tr><td>foo1</td><td>bar1</td><td>baz1</td><td>qux1</td></tr><tr><td>foo2</td><td>bar2</td><td>baz2</td><td>qux2</td></tr><tr><td>foo3</td><td>bar3</td><td>baz3</td><td>qux3</td></tr></tbody></table>',
    "tgroup tags present from generate()";

is $table->north,
    '<table><thead><tr><th>header1</th><th>header2</th><th>header3</th><th>header4</th></tr></thead><tfoot><tr><td>foo4</td><td>bar4</td><td>baz4</td><td>qux4</td></tr></tfoot><tbody><tr><td>foo1</td><td>bar1</td><td>baz1</td><td>qux1</td></tr><tr><td>foo2</td><td>bar2</td><td>baz2</td><td>qux2</td></tr><tr><td>foo3</td><td>bar3</td><td>baz3</td><td>qux3</td></tr></tbody></table>',
    "tgroup tags present from north()";

is $table->landscape,
    '<table><tr><th>header1</th><td>foo1</td><td>foo2</td><td>foo3</td><td>foo4</td></tr><tr><th>header2</th><td>bar1</td><td>bar2</td><td>bar3</td><td>bar4</td></tr><tr><th>header3</th><td>baz1</td><td>baz2</td><td>baz3</td><td>baz4</td></tr><tr><th>header4</th><td>qux1</td><td>qux2</td><td>qux3</td><td>qux4</td></tr></table>',
    "tgroup tags never present from landscape()";

is $table->west,
    '<table><tr><th>header1</th><td>foo1</td><td>foo2</td><td>foo3</td><td>foo4</td></tr><tr><th>header2</th><td>bar1</td><td>bar2</td><td>bar3</td><td>bar4</td></tr><tr><th>header3</th><td>baz1</td><td>baz2</td><td>baz3</td><td>baz4</td></tr><tr><th>header4</th><td>qux1</td><td>qux2</td><td>qux3</td><td>qux4</td></tr></table>',
    "tgroup tags never present from west()";

is $table->south,
    '<table><tr><td>foo1</td><td>bar1</td><td>baz1</td><td>qux1</td></tr><tr><td>foo2</td><td>bar2</td><td>baz2</td><td>qux2</td></tr><tr><td>foo3</td><td>bar3</td><td>baz3</td><td>qux3</td></tr><tr><td>foo4</td><td>bar4</td><td>baz4</td><td>qux4</td></tr><tr><th>header1</th><th>header2</th><th>header3</th><th>header4</th></tr></table>',
    "tgroup tags never present from south()";

is $table->east,
    '<table><tr><td>foo1</td><td>foo2</td><td>foo3</td><td>foo4</td><th>header1</th></tr><tr><td>bar1</td><td>bar2</td><td>bar3</td><td>bar4</td><th>header2</th></tr><tr><td>baz1</td><td>baz2</td><td>baz3</td><td>baz4</td><th>header3</th></tr><tr><td>qux1</td><td>qux2</td><td>qux3</td><td>qux4</td><th>header4</th></tr></table>',
    "tgroup tags never present from east()";

is $table->generate( tgroups => 1 ),
    '<table><thead><tr><th>header1</th><th>header2</th><th>header3</th><th>header4</th></tr></thead><tbody><tr><td>foo1</td><td>bar1</td><td>baz1</td><td>qux1</td></tr><tr><td>foo2</td><td>bar2</td><td>baz2</td><td>qux2</td></tr><tr><td>foo3</td><td>bar3</td><td>baz3</td><td>qux3</td></tr><tr><td>foo4</td><td>bar4</td><td>baz4</td><td>qux4</td></tr></tbody></table>',
    "tfoot ommited when tgroups is 1";

is $table->generate( matrix => 1, tgroups => 1 ),
    '<table><tbody><tr><td>header1</td><td>header2</td><td>header3</td><td>header4</td></tr><tr><td>foo1</td><td>bar1</td><td>baz1</td><td>qux1</td></tr><tr><td>foo2</td><td>bar2</td><td>baz2</td><td>qux2</td></tr><tr><td>foo3</td><td>bar3</td><td>baz3</td><td>qux3</td></tr><tr><td>foo4</td><td>bar4</td><td>baz4</td><td>qux4</td></tr></tbody></table>',
    "thead and tfoot ommited for matrix when tgroups is 1";

is $table->generate( matrix => 1, tgroups => 2 ),
    '<table><tbody><tr><td>header1</td><td>header2</td><td>header3</td><td>header4</td></tr><tr><td>foo1</td><td>bar1</td><td>baz1</td><td>qux1</td></tr><tr><td>foo2</td><td>bar2</td><td>baz2</td><td>qux2</td></tr><tr><td>foo3</td><td>bar3</td><td>baz3</td><td>qux3</td></tr><tr><td>foo4</td><td>bar4</td><td>baz4</td><td>qux4</td></tr></tbody></table>',
    "thead and tfoot ommited for matrix when tgroups is 2";

is $table->generate( group => 2 ),
    '<table><thead><tr><th>header1</th><th>header2</th><th>header3</th><th>header4</th></tr></thead><tfoot><tr><td>foo4</td><td>bar4</td><td>baz4</td><td>qux4</td></tr></tfoot><tbody><tr><td>foo1</td><td>bar1</td><td>baz1</td><td>qux1</td></tr><tr><td>foo2</td><td>bar2</td><td>baz2</td><td>qux2</td></tr></tbody><tbody><tr><td>foo3</td><td>bar3</td><td>baz3</td><td>qux3</td></tr></tbody></table>',
    "group chunks and wraps chunks in tbody tags (strict)";


is $table->generate( tgroups => 1, group => 2 ),
    '<table><thead><tr><th>header1</th><th>header2</th><th>header3</th><th>header4</th></tr></thead><tbody><tr><td>foo1</td><td>bar1</td><td>baz1</td><td>qux1</td></tr><tr><td>foo2</td><td>bar2</td><td>baz2</td><td>qux2</td></tr></tbody><tbody><tr><td>foo3</td><td>bar3</td><td>baz3</td><td>qux3</td></tr><tr><td>foo4</td><td>bar4</td><td>baz4</td><td>qux4</td></tr></tbody></table>',
    "group chunks and wraps chunks in tbody tags (loose)";


is $table->generate( matrix => 1, tgroups => 1, group => 2 ),
    '<table><tbody><tr><td>header1</td><td>header2</td><td>header3</td><td>header4</td></tr><tr><td>foo1</td><td>bar1</td><td>baz1</td><td>qux1</td></tr></tbody><tbody><tr><td>foo2</td><td>bar2</td><td>baz2</td><td>qux2</td></tr><tr><td>foo3</td><td>bar3</td><td>baz3</td><td>qux3</td></tr></tbody><tbody><tr><td>foo4</td><td>bar4</td><td>baz4</td><td>qux4</td></tr></tbody></table>',
    "group chunks and wraps chunks in tbody tags (matrix)";

is $table->generate( tgroups => 0, tr => { class => [qw(odd even)] } ),
    '<table><tr class="odd"><th>header1</th><th>header2</th><th>header3</th><th>header4</th></tr><tr class="even"><td>foo1</td><td>bar1</td><td>baz1</td><td>qux1</td></tr><tr class="odd"><td>foo2</td><td>bar2</td><td>baz2</td><td>qux2</td></tr><tr class="even"><td>foo3</td><td>bar3</td><td>baz3</td><td>qux3</td></tr><tr class="odd"><td>foo4</td><td>bar4</td><td>baz4</td><td>qux4</td></tr></table>',
    "styles applying to tr impact all rows when thead 0";

is $table->generate( tgroups => 1, tr => { class => [qw(odd even)] } ),
    '<table><thead><tr><th>header1</th><th>header2</th><th>header3</th><th>header4</th></tr></thead><tbody><tr class="odd"><td>foo1</td><td>bar1</td><td>baz1</td><td>qux1</td></tr><tr class="even"><td>foo2</td><td>bar2</td><td>baz2</td><td>qux2</td></tr><tr class="odd"><td>foo3</td><td>bar3</td><td>baz3</td><td>qux3</td></tr><tr class="even"><td>foo4</td><td>bar4</td><td>baz4</td><td>qux4</td></tr></tbody></table>',
    "styles applying to tr do not impact thead when thead 1";

is $table->generate( tgroups => 2, tr => { class => [qw(odd even)] } ),
    '<table><thead><tr><th>header1</th><th>header2</th><th>header3</th><th>header4</th></tr></thead><tfoot><tr><td>foo4</td><td>bar4</td><td>baz4</td><td>qux4</td></tr></tfoot><tbody><tr class="odd"><td>foo1</td><td>bar1</td><td>baz1</td><td>qux1</td></tr><tr class="even"><td>foo2</td><td>bar2</td><td>baz2</td><td>qux2</td></tr><tr class="odd"><td>foo3</td><td>bar3</td><td>baz3</td><td>qux3</td></tr></tbody></table>',
    "styles applying to tr do not impact thead and tfoot when thead 1";

is $table->generate( tgroups => 1, tr => { class => [qw(odd even)] }, 'thead.tr' => { class => "thead" } ),
    '<table><thead><tr class="thead"><th>header1</th><th>header2</th><th>header3</th><th>header4</th></tr></thead><tbody><tr class="odd"><td>foo1</td><td>bar1</td><td>baz1</td><td>qux1</td></tr><tr class="even"><td>foo2</td><td>bar2</td><td>baz2</td><td>qux2</td></tr><tr class="odd"><td>foo3</td><td>bar3</td><td>baz3</td><td>qux3</td></tr><tr class="even"><td>foo4</td><td>bar4</td><td>baz4</td><td>qux4</td></tr></tbody></table>',
    "thead.tr impacts thead rows";

is $table->generate( tgroups => 2, tr => { class => [qw(odd even)] }, 'tfoot.tr' => { class => "tfoot" } ),
    '<table><thead><tr><th>header1</th><th>header2</th><th>header3</th><th>header4</th></tr></thead><tfoot><tr class="tfoot"><td>foo4</td><td>bar4</td><td>baz4</td><td>qux4</td></tr></tfoot><tbody><tr class="odd"><td>foo1</td><td>bar1</td><td>baz1</td><td>qux1</td></tr><tr class="even"><td>foo2</td><td>bar2</td><td>baz2</td><td>qux2</td></tr><tr class="odd"><td>foo3</td><td>bar3</td><td>baz3</td><td>qux3</td></tr></tbody></table>',
    "tfoot.tr impacts thead rows";
