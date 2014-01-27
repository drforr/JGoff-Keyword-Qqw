#!perl

use Test::More tests => 6;

use warnings FATAL => 'all';
use strict;

use JGoff::Keyword::Qqw;

my @id_1 = qqw ($x);
is_deeply [@id_1], [qw(a b)];

my @id_2 = qqw
 (
 	 $x
 );
is_deeply [@id_2], [qw(a b)];

my @id_3 = qqw ##
 (  $x ##
 ) ##AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 
;
is_deeply [@id_3], [qw(a b)];

my @add = qqw ($x, $y);
is_deeply [@add], [qw(a b)];

my @mymap = qqw ($fun, @args);
is_deeply [@mymap], [qw(a b)];

my @balanced_1 = qqw<$fun>;
is_deeply [@balanced_1], [qw(a b)];
