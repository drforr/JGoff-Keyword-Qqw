#!perl

use Test::More tests => 90;

use warnings FATAL => 'all';
use strict;

use JGoff::Keyword::Qqw;

# Enumerate all possible qqw() delimiters, in ASCII order.
#
is_deeply [qqw!!], ['a', 'b'];
is_deeply [qqw""], ['a', 'b'];
#is_deeply [qqw##], ['a', 'b'];
is_deeply [qqw$$], ['a', 'b'];
is_deeply [qqw%%], ['a', 'b'];
is_deeply [qqw&&], ['a', 'b'];
#is_deeply [qqw´´], ['a', 'b'];
is_deeply [qqw()], ['a', 'b']; # Special case
is_deeply [qqw))], ['a', 'b']; # Make sure ')' still behaves.
is_deeply [qqw**], ['a', 'b'];
is_deeply [qqw++], ['a', 'b'];
is_deeply [qqw,,], ['a', 'b'];
is_deeply [qqw--], ['a', 'b'];
is_deeply [qqw..], ['a', 'b'];
is_deeply [qqw//], ['a', 'b'];

is_deeply [qqw 00], ['a', 'b'];
is_deeply [qqw 11], ['a', 'b'];
is_deeply [qqw 22], ['a', 'b'];
is_deeply [qqw 33], ['a', 'b'];
is_deeply [qqw 44], ['a', 'b'];
is_deeply [qqw 55], ['a', 'b'];
is_deeply [qqw 66], ['a', 'b'];
is_deeply [qqw 77], ['a', 'b'];
is_deeply [qqw 88], ['a', 'b'];
is_deeply [qqw 99], ['a', 'b'];
#is_deeply [qqw::], ['a', 'b']; # XXX aiyee, rabbit hole here.
                                # XXX C< qw:a b c:; > is legitimate, but the
                                # XXX keyword interceptor won't work?
is_deeply [qqw;;], ['a', 'b']; # Special case
is_deeply [qqw<>], ['a', 'b']; # Another special case
is_deeply [qqw==], ['a', 'b'];
is_deeply [qqw>>], ['a', 'b']; # Make sure unbalanced still works.
is_deeply [qqw??], ['a', 'b'];

is_deeply [qqw@@], ['a', 'b'];
is_deeply [qqw AA], ['a', 'b'];
is_deeply [qqw BB], ['a', 'b'];
is_deeply [qqw CC], ['a', 'b'];
is_deeply [qqw DD], ['a', 'b'];
is_deeply [qqw EE], ['a', 'b'];
is_deeply [qqw FF], ['a', 'b'];
is_deeply [qqw GG], ['a', 'b'];
is_deeply [qqw HH], ['a', 'b'];
is_deeply [qqw II], ['a', 'b'];
is_deeply [qqw JJ], ['a', 'b'];
is_deeply [qqw KK], ['a', 'b'];
is_deeply [qqw LL], ['a', 'b'];
is_deeply [qqw MM], ['a', 'b'];
is_deeply [qqw NN], ['a', 'b'];
is_deeply [qqw OO], ['a', 'b'];

is_deeply [qqw PP], ['a', 'b'];
is_deeply [qqw QQ], ['a', 'b'];
is_deeply [qqw RR], ['a', 'b'];
is_deeply [qqw SS], ['a', 'b'];
is_deeply [qqw TT], ['a', 'b'];
is_deeply [qqw UU], ['a', 'b'];
is_deeply [qqw VV], ['a', 'b'];
is_deeply [qqw WW], ['a', 'b'];
is_deeply [qqw XX], ['a', 'b'];
is_deeply [qqw YY], ['a', 'b'];
is_deeply [qqw ZZ], ['a', 'b'];
is_deeply [qqw[]], ['a', 'b']; # Special case
# \\ doesn't work
is_deeply [qqw]]], ['a', 'b']; # Non-balanced version
is_deeply [qqw^^], ['a', 'b'];
is_deeply [qqw __], ['a', 'b'];

is_deeply [qqw``], ['a', 'b'];
is_deeply [qqw aa], ['a', 'b'];
is_deeply [qqw bb], ['a', 'b'];
is_deeply [qqw cc], ['a', 'b'];
is_deeply [qqw dd], ['a', 'b'];
is_deeply [qqw ee], ['a', 'b'];
is_deeply [qqw ff], ['a', 'b'];
is_deeply [qqw gg], ['a', 'b'];
is_deeply [qqw hh], ['a', 'b'];
is_deeply [qqw ii], ['a', 'b'];
is_deeply [qqw jj], ['a', 'b'];
is_deeply [qqw kk], ['a', 'b'];
is_deeply [qqw ll], ['a', 'b'];
is_deeply [qqw mm], ['a', 'b'];
is_deeply [qqw nn], ['a', 'b'];
is_deeply [qqw oo], ['a', 'b'];

is_deeply [qqw pp], ['a', 'b'];
is_deeply [qqw qq], ['a', 'b'];
is_deeply [qqw rr], ['a', 'b'];
is_deeply [qqw ss], ['a', 'b'];
is_deeply [qqw tt], ['a', 'b'];
is_deeply [qqw uu], ['a', 'b'];
is_deeply [qqw vv], ['a', 'b'];
is_deeply [qqw ww], ['a', 'b'];
is_deeply [qqw xx], ['a', 'b'];
is_deeply [qqw yy], ['a', 'b'];
is_deeply [qqw zz], ['a', 'b'];
is_deeply [qqw{}], ['a', 'b'];
is_deeply [qqw||], ['a', 'b'];
is_deeply [qqw}}], ['a', 'b'];
is_deeply [qqw~~], ['a', 'b'];
