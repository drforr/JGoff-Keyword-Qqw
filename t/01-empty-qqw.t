#!perl

use Test::More tests => 91;

use warnings FATAL => 'all';
use strict;

use JGoff::Keyword::Qqw;

# Enumerate all possible qqw() delimiters, in ASCII order.
#
is_deeply [qqw!!], [ ];
is_deeply [qqw""], [ ];
#is_deeply [qqw##], [ ];
is_deeply [qqw$$], [ ];
is_deeply [qqw%%], [ ];
is_deeply [qqw&&], [ ];
#is_deeply [qqw´´], [ ];
is_deeply [qqw()], [ ]; # Special case
#is_deeply [qqw(())], [ ]; # Double secret special case
#is_deeply [qqw(()())], [ ]; # Double secret special case
is_deeply [qqw))], [ ]; # Make sure ')' still behaves.
                        # Also, notice that the backward versions don't nest
is_deeply [qqw**], [ ];
is_deeply [qqw++], [ ];
is_deeply [qqw,,], [ ];
is_deeply [qqw--], [ ];
is_deeply [qqw..], [ ];
is_deeply [qqw//], [ ];

is_deeply [qqw 00], [ ];
is_deeply [qqw 11], [ ];
is_deeply [qqw 22], [ ];
is_deeply [qqw 33], [ ];
is_deeply [qqw 44], [ ];
is_deeply [qqw 55], [ ];
is_deeply [qqw 66], [ ];
is_deeply [qqw 77], [ ];
is_deeply [qqw 88], [ ];
is_deeply [qqw 99], [ ];
#is_deeply [qqw::],  [ ]; # XXX aiyee, rabbit hole here.
                          # XXX C< qw:a b c:; > is legitimate, but the
                          # XXX keyword interceptor won't work?
is_deeply [qqw;;], [ ]; # Special case
is_deeply [qqw<>], [ ]; # Balanced delimiter
#is_deeply [qqw<<>>], [ ]; # Balanced delimiters can nest
#is_deeply [qqw<<<>>>], [ ]; # Go deeper
#is_deeply [qqw<<><>>], [ ]; # Nesting can occur twice
is_deeply [qqw==], [ ];
is_deeply [qqw>>], [ ]; # Make sure unbalanced still works.
is_deeply [qqw??], [ ];

is_deeply [qqw@@], [ ];
is_deeply [qqw AA], [ ];
is_deeply [qqw BB], [ ];
is_deeply [qqw CC], [ ];
is_deeply [qqw DD], [ ];
is_deeply [qqw EE], [ ];
is_deeply [qqw FF], [ ];
is_deeply [qqw GG], [ ];
is_deeply [qqw HH], [ ];
is_deeply [qqw II], [ ];
is_deeply [qqw JJ], [ ];
is_deeply [qqw KK], [ ];
is_deeply [qqw LL], [ ];
is_deeply [qqw MM], [ ];
is_deeply [qqw NN], [ ];
is_deeply [qqw OO], [ ];

is_deeply [qqw PP], [ ];
is_deeply [qqw QQ], [ ];
is_deeply [qqw RR], [ ];
is_deeply [qqw SS], [ ];
is_deeply [qqw TT], [ ];
is_deeply [qqw UU], [ ];
is_deeply [qqw VV], [ ];
is_deeply [qqw WW], [ ];
is_deeply [qqw XX], [ ];
is_deeply [qqw YY], [ ];
is_deeply [qqw ZZ], [ ];
is_deeply [qqw[]], [ ]; # Balanced delimiters
#is_deeply [qqw[[]]], [ ]; # Balanced delimiters can nest
#is_deeply [qqw[[[]]]], [ ]; # Doubly nested
#is_deeply [qqw[[][]]], [ ]; # Twin balanced
# \\ doesn't work
is_deeply [qqw]]], [ ]; # Non-balanced version
is_deeply [qqw^^], [ ];
is_deeply [qqw __], [ ];

is_deeply [qqw``], [ ];
is_deeply [qqw aa], [ ];
is_deeply [qqw bb], [ ];
is_deeply [qqw cc], [ ];
is_deeply [qqw dd], [ ];
is_deeply [qqw ee], [ ];
is_deeply [qqw ff], [ ];
is_deeply [qqw gg], [ ];
is_deeply [qqw hh], [ ];
is_deeply [qqw ii], [ ];
is_deeply [qqw jj], [ ];
is_deeply [qqw kk], [ ];
is_deeply [qqw ll], [ ];
is_deeply [qqw mm], [ ];
is_deeply [qqw nn], [ ];
is_deeply [qqw oo], [ ];

is_deeply [qqw pp], [ ];
is_deeply [qqw qq], [ ];
is_deeply [qqw rr], [ ];
is_deeply [qqw ss], [ ];
is_deeply [qqw tt], [ ];
is_deeply [qqw uu], [ ];
is_deeply [qqw vv], [ ];
is_deeply [qqw ww], [ ];
is_deeply [qqw xx], [ ];
is_deeply [qqw yy], [ ];
is_deeply [qqw zz], [ ];
is_deeply [qqw{}], [ ]; # Balanced delimiter
#is_deeply [qqw{{}}], [ ]; # Balanced delimiters can nest
#is_deeply [qqw{{{}}}], [ ]; # Go deeper
#is_deeply [qqw{{}{}}], [ ]; # Two nested pairs
is_deeply [qqw||], [ ];
is_deeply [qqw}}], [ ];
is_deeply [qqw~~], [ ];

is_deeply [qqw    99], [ ];
