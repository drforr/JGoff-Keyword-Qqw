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

my @fac_1 = qqw ($n);
is_deeply [@fac_1], [qw(a b)];

#ok $id_1->(1), 'basic sanity';
#ok $id_2->(1), 'simple prototype';
##ok $id_3->(1), 'definition over multiple lines';
#is $add->(2, 2), 4, '2 + 2 = 4';
#is $add->(39, 3), 42, '39 + 3 = 42';
#is_deeply [$mymap->( sub { $_ * 2 }, 2, 3, 5, 9)], [4, 6, 10, 18], 'mymap works';
##is $fac_1->(5), 120, 'fac_1';
##is qqw ($x, $y) { $x . $y }->(qqw ($foo) { $foo + 1 }->(3), qqw ($bar) { $bar * 2 }->(1)), '42', 'anonyqqw';
