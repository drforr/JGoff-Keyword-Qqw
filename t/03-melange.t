#!perl

use Test::More tests => 1;

use warnings FATAL => 'all';
use strict;

use JGoff::Keyword::Qqw;

{ my $x = 'b';
  my @start = qqw(a $x);
  is_deeply [ @start ], [ 'a', 'b' ];
}

# Two copies of the same variable, shouldn't cause a problem but who knows?
#
#{ my $x = 'a';
#  my @start = qqw($x b $x);
#  is_deeply [@start], [qw(a b a)];
#}

#{ my $x = 'b';
#  my $y = 'c';
#  my @start = qqw(a $x $y d);
#  is_deeply [@start], [qw(a b c d)];
#}

#{ my @x = qw(b c);
#  my @start = qqw(a @x d);
#  is_deeply [@start], [qw(a b c d)];
#}

# Test just one hash pair
#
#{ my %x = qw(b c);
#  my @start = qqw(a %x d);
#  is_deeply [@start], [qw(a b c d)];
#}

#my @id_2 = qqw
# (
# 	 $x
# );
#is_deeply [@id_2], [qw(a b)];
#
#my @id_3 = qqw ##
# (  $x ##
# ) ##AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 
#;
#is_deeply [@id_3], [qw(a b)];
#
#my @add = qqw ($x $y);
#is_deeply [@add], [qw(a b)];
#
#my @mymap = qqw ($fun @args);
#is_deeply [@mymap], [qw(a b)];
#
#my @balanced_1 = qqw<$fun>;
#is_deeply [@balanced_1], [qw(a b)];
#
#my @balanced_2 = qqw[$fun];
#is_deeply [@balanced_2], [qw(a b)];
