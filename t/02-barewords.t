#!perl

use Test::More tests => 2;

use warnings FATAL => 'all';
use strict;

use JGoff::Keyword::Qqw;

is_deeply [ qqw'a' ], [ 'a', 'b' ];
#is_deeply [ qqw'a b' ], [ 'a', 'b' ];

# {{{ Delimiters around 'a' in ASCII order
#
# Also, test balanced delimiters for nesting.
#
# Ignore ' ', we'll have plenty of those later.
#is_deeply [qqw!a!],   [ 'a' ];
#is_deeply [qqw"a"],   [ 'a' ];
#is_deeply [qqw#a#],   [ 'a' ];
#is_deeply [qqw$a$],   [ 'a' ];
#is_deeply [qqw%a%],   [ 'a' ];
#is_deeply [qqw&a&],   [ 'a' ];
#is_deeply [qqw´a´],   [ 'a' ];
#is_deeply [qqw(a)],   [ 'a' ]; # Balanced delimiter
#is_deeply [qqw((a))], ['(a)']; # Balanced delimiters can nest
#is_deeply [qqw)a)],   [ 'a' ]; # Make sure other side still behaves.
#is_deeply [qqw*a*],   [ 'a' ];
#is_deeply [qqw+a+],   [ 'a' ];
#is_deeply [qqw,a,],   [ 'a' ];
#is_deeply [qqw-a-],   [ 'a' ];
#is_deeply [qqw.a.],   [ 'a' ];
#is_deeply [qqw/a/],   [ 'a' ];

#is_deeply [qqw 0a0], ['a'];
#is_deeply [qqw 1a1], ['a'];
#is_deeply [qqw 2a2], ['a'];
#is_deeply [qqw 3a3], ['a'];
#is_deeply [qqw 4a4], ['a'];
#is_deeply [qqw 5a5], ['a'];
#is_deeply [qqw 6a6], ['a'];
#is_deeply [qqw 7a7], ['a'];
#is_deeply [qqw 8a8], ['a'];
#is_deeply [qqw 9a9], ['a'];
#is_deeply [qqw:a:],  ['a']; # XXX aiyee, rabbit hole here.
                             # XXX C< qw:a b c:; > is legitimate, but the
                             # XXX keyword interceptor won't work?
#is_deeply [qqw;a;],   [ 'a' ]; # Special case
#is_deeply [qqw<a>],   [ 'a' ]; # Another special case
#is_deeply [qqw<<a>>], ['<a>']; # Double secret special case
#is_deeply [qqw=a=],   [ 'a' ];
#is_deeply [qqw>a>],   [ 'a' ]; # Make sure unbalanced still works.
#is_deeply [qqw?a?],   [ 'a' ];

#is_deeply [qqw@a@],  ['a'];
#is_deeply [qqw AaA], ['a'];
#is_deeply [qqw BaB], ['a'];
#is_deeply [qqw CaC], ['a'];
#is_deeply [qqw DaD], ['a'];
#is_deeply [qqw EaE], ['a'];
#is_deeply [qqw FaF], ['a'];
#is_deeply [qqw GaG], ['a'];
#is_deeply [qqw HaH], ['a'];
#is_deeply [qqw IaI], ['a'];
#is_deeply [qqw JaJ], ['a'];
#is_deeply [qqw KaK], ['a'];
#is_deeply [qqw LaL], ['a'];
#is_deeply [qqw MaM], ['a'];
#is_deeply [qqw NaN], ['a'];
#is_deeply [qqw OaO], ['a'];

#is_deeply [qqw PaP],  [ 'a' ];
#is_deeply [qqw QaQ],  [ 'a' ];
#is_deeply [qqw RaR],  [ 'a' ];
#is_deeply [qqw SaS],  [ 'a' ];
#is_deeply [qqw TaT],  [ 'a' ];
#is_deeply [qqw UaU],  [ 'a' ];
#is_deeply [qqw VaV],  [ 'a' ];
#is_deeply [qqw WaW],  [ 'a' ];
#is_deeply [qqw XaX],  [ 'a' ];
#is_deeply [qqw YaY],  [ 'a' ];
#is_deeply [qqw ZaZ],  [ 'a' ];
#is_deeply [qqw[a]],   [ 'a' ]; # Balanced delimiter
#is_deeply [qqw[[a]]], ['[a]']; # Balanced delimiters can nest
# \\ doesn't work
#is_deeply [qqw]a]],   [ 'a' ]; # Make sure other side still behaves.
#is_deeply [qqw^a^],   [ 'a' ];
#is_deeply [qqw _a_],  [ 'a' ];

#is_deeply [qqw`a`],  ['a'];
#is_deeply [qqw aba], ['b']; # Not testing escaping just yet.
#is_deeply [qqw bab], ['a'];
#is_deeply [qqw cac], ['a'];
#is_deeply [qqw dad], ['a'];
#is_deeply [qqw eae], ['a'];
#is_deeply [qqw faf], ['a'];
#is_deeply [qqw gag], ['a'];
#is_deeply [qqw hah], ['a'];
#is_deeply [qqw iai], ['a'];
#is_deeply [qqw jaj], ['a'];
#is_deeply [qqw kak], ['a'];
#is_deeply [qqw lal], ['a'];
#is_deeply [qqw mam], ['a'];
#is_deeply [qqw nan], ['a'];
#is_deeply [qqw oao], ['a'];

#is_deeply [qqw pap],  [ 'a' ];
#is_deeply [qqw qaq],  [ 'a' ];
#is_deeply [qqw rar],  [ 'a' ];
#is_deeply [qqw sas],  [ 'a' ];
#is_deeply [qqw tat],  [ 'a' ];
#is_deeply [qqw uau],  [ 'a' ];
#is_deeply [qqw vav],  [ 'a' ];
#is_deeply [qqw waw],  [ 'a' ];
#is_deeply [qqw xax],  [ 'a' ];
#is_deeply [qqw yay],  [ 'a' ];
#is_deeply [qqw zaz],  [ 'a' ];
#is_deeply [qqw{a}],   [ 'a' ]; # Balanced delimiter
#is_deeply [qqw{{a}}], ['{a}']; # Balanced delimiters can nest
#is_deeply [qqw|a|],   [ 'a '];
#is_deeply [qqw}a}],   [ 'a ']; # Make sure the other side still behaves.
#is_deeply [qqw~a~],   [ 'a '];
#
# }}}

# {{{ Delimiters around their escaped version
#
# Also, test balanced delimiters for nesting.
#
# Ignore ' ', we'll have plenty of those later.
#is_deeply [qqw!\!!],   [ '!' ];
#is_deeply [qqw"\""],   [ '"' ];
#is_deeply [qqw#\##],   [ '#' ];
#is_deeply [qqw$\$$],   [ '$' ];
#is_deeply [qqw%\%%],   [ '%' ];
#is_deeply [qqw&\&&],   [ '&' ];
#is_deeply [qqw´\´´],   [ '`' ];
#is_deeply [qqw(\()],   [ '(' ]; # Balanced delimiter has two escapes
#is_deeply [qqw(\))],   [ ')' ];
#is_deeply [qqw(\(())], ['(()'];
#is_deeply [qqw(\))],   [')()']; # Balanced delimiters can nest
#is_deeply [qqw)\))],   [ ')' ];
#is_deeply [qqw*\**],   [ '*' ];
#is_deeply [qqw+\++],   [ '+' ];
#is_deeply [qqw,\,,],   [ ',' ];
#is_deeply [qqw-\--],   [ '-' ];
#is_deeply [qqw.\..],   [ '.' ];
#is_deeply [qqw/\//],   [ '/' ];
                       
#is_deeply [qqw 0\00], ['0'];
#is_deeply [qqw 1\11], ['1'];
#is_deeply [qqw 2\22], ['2'];
#is_deeply [qqw 3\33], ['3'];
#is_deeply [qqw 4\44], ['4'];
#is_deeply [qqw 5\55], ['5'];
#is_deeply [qqw 6\66], ['6'];
#is_deeply [qqw 7\77], ['7'];
#is_deeply [qqw 8\88], ['8'];
#is_deeply [qqw 9\99], ['9'];
#is_deeply [qqw:\::],  [':']; # XXX aiyee, rabbit hole here.
                              # XXX C< qw:a b c:; > is legitimate, but the
                              # XXX keyword interceptor won't work?
#is_deeply [qqw;\;;],   [ ';' ]; # Special case
#is_deeply [qqw<\<>],   [ '<' ];
#is_deeply [qqw<\>>],   [ '>' ]; # Special cases
#is_deeply [qqw<\<<>>], ['<<>'];
#is_deeply [qqw<\><>>], ['><>']; # Double secret special cases
#is_deeply [qqw=\==],   [ '=' ];
#is_deeply [qqw>\>>],   [ '>' ]; # Make sure unbalanced still works.
#is_deeply [qqw?\??],   [ '?' ];

#is_deeply [qqw@\@@],  ['@'];
#is_deeply [qqw A\AA], ['A'];
#is_deeply [qqw B\BB], ['B'];
#is_deeply [qqw C\CC], ['C'];
#is_deeply [qqw D\DD], ['D'];
#is_deeply [qqw E\EE], ['E'];
#is_deeply [qqw F\FF], ['F'];
#is_deeply [qqw G\GG], ['G'];
#is_deeply [qqw H\HH], ['H'];
#is_deeply [qqw I\II], ['I'];
#is_deeply [qqw J\JJ], ['J'];
#is_deeply [qqw K\KK], ['K'];
#is_deeply [qqw L\LL], ['L'];
#is_deeply [qqw M\MM], ['M'];
#is_deeply [qqw N\NN], ['N'];
#is_deeply [qqw O\OO], ['O'];

#is_deeply [qqw P\PP],  [ 'P' ];
#is_deeply [qqw Q\QQ],  [ 'Q' ];
#is_deeply [qqw R\RR],  [ 'R' ];
#is_deeply [qqw S\SS],  [ 'S' ];
#is_deeply [qqw T\TT],  [ 'T' ];
#is_deeply [qqw U\UU],  [ 'U' ];
#is_deeply [qqw V\VV],  [ 'V' ];
#is_deeply [qqw W\WW],  [ 'W' ];
#is_deeply [qqw X\XX],  [ 'X' ];
#is_deeply [qqw Y\YY],  [ 'Y' ];
#is_deeply [qqw Z\ZZ],  [ 'Z' ];
#is_deeply [qqw[\[]],   [ '[' ]; # Balanced delimiter
#is_deeply [qqw[\]]],   [ ']' ]; # Other side
#is_deeply [qqw[\[[]]], ['[[]']; # Balanced delimiters can nest
#is_deeply [qqw[\][]]], ['][]']; # Make sure other side still behaves.
# \\ doesn't work
#is_deeply [qqw]\]]],  [']']; # Non-balanced version
#is_deeply [qqw^\^^],  ['^'];
#is_deeply [qqw _\__], ['_'];

#is_deeply [qqw`\``],  ['`'];
#is_deeply [qqw a\aa], ['a'];
#is_deeply [qqw b\bb], ['b'];
#is_deeply [qqw c\cc], ['c'];
#is_deeply [qqw d\dd], ['d'];
#is_deeply [qqw e\ee], ['e'];
#is_deeply [qqw f\ff], ['f'];
#is_deeply [qqw g\gg], ['g'];
#is_deeply [qqw h\hh], ['h'];
#is_deeply [qqw i\ii], ['i'];
#is_deeply [qqw j\jj], ['j'];
#is_deeply [qqw k\kk], ['k'];
#is_deeply [qqw l\ll], ['l'];
#is_deeply [qqw m\mm], ['m'];
#is_deeply [qqw n\nn], ['n'];
#is_deeply [qqw o\oo], ['o'];

#is_deeply [qqw p\pp],  [ 'p' ];
#is_deeply [qqw q\qq],  [ 'q' ];
#is_deeply [qqw r\rr],  [ 'r' ];
#is_deeply [qqw s\ss],  [ 's' ];
#is_deeply [qqw t\tt],  [ 't' ];
#is_deeply [qqw u\uu],  [ 'u' ];
#is_deeply [qqw v\vv],  [ 'v' ];
#is_deeply [qqw w\ww],  [ 'w' ];
#is_deeply [qqw x\xx],  [ 'x' ];
#is_deeply [qqw y\yy],  [ 'y' ];
#is_deeply [qqw z\zz],  [ 'z' ];
#is_deeply [qqw{\{}],   [ '{' ]; # Balanced delimiter
#is_deeply [qqw{\}}],   [ '}' ]; # Other side
#is_deeply [qqw{\{{}}], ['{{}']; # Balanced delimiters can nest
#is_deeply [qqw{\}{}}], ['}{}']; # Make sure other side still behaves.
#is_deeply [qqw|\||], ['|'];
#is_deeply [qqw}\}}], ['}'];
#is_deeply [qqw~\~~], ['~'];
#
# }}}
