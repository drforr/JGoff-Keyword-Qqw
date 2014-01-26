#!perl

use Test::More tests => 7;

use warnings FATAL => 'all';
use strict;

use JGoff::Keyword::Qqw;

my $id_1 = qqw ($x) { $x };

my $id_2 = qqw
 (
 	 $x
 )
 {@_ == 1 or return;
 	 $x
 };

my $id_3 = qqw ##
 (  $x ##
 ) ##AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 
 { ##
 	 $x ##
 }; ##

my $add = qqw ($x, $y) {
	$x + $y
};

my $mymap = qqw ($fun, @args) {
  my @res;
  for (@args) {
    push @res, $fun->($_);
  }
  @res
};

my $fac_1;
$fac_1 = qqw ($n) {
	$n < 2 ? 1 : $n * $fac_1->( $n - 1 )
};

ok $id_1->(1), 'basic sanity';
ok $id_2->(1), 'simple prototype';
ok $id_3->(1), 'definition over multiple lines';
is $add->(2, 2), 4, '2 + 2 = 4';
is $add->(39, 3), 42, '39 + 3 = 42';
is_deeply [$mymap->( sub { $_ * 2 }, 2, 3, 5, 9)], [4, 6, 10, 18], 'mymap works';
is $fac_1->(5), 120, 'fac_1';
#is qqw ($x, $y) { $x . $y }->(qqw ($foo) { $foo + 1 }->(3), qqw ($bar) { $bar * 2 }->(1)), '42', 'anonyqqw';
