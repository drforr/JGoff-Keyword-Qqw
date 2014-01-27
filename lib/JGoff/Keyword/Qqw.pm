package JGoff::Keyword::Qqw;

use v5.14.0;
use warnings;

use Carp qw(confess);

use XSLoader;
BEGIN {
	our $VERSION = '1.0401';
	XSLoader::load;
}

sub _assert_valid_identifier {
	my ($name, $with_dollar) = @_;
	my $bonus = $with_dollar ? '\$' : '';
	$name =~ /^${bonus}[^\W\d]\w*\z/
		or confess qq{"$name" doesn't look like a valid identifier};
}

sub _assert_valid_attributes {
	my ($attrs) = @_;
	$attrs =~ m{
		^ \s*+
		: \s*+
		(?&ident) (?! [^\s:(] ) (?&param)?+ \s*+
		(?:
			(?: : \s*+ )?
			(?&ident) (?! [^\s:(] ) (?&param)?+ \s*+
		)*+
		\z

		(?(DEFINE)
			(?<ident>
				[^\W\d]
				\w*+
			)
			(?<param>
				\(
				[^()\\]*+
				(?:
					(?:
						\\ .
					|
						(?&param)
					)
					[^()\\]*+
				)*+
				\)
			)
		)
	}sx or confess qq{"$attrs" doesn't look like valid attributes};
}

sub _reify_type_default {
	require Moose::Util::TypeConstraints;
	Moose::Util::TypeConstraints::find_or_create_isa_type_constraint($_[0])
}

sub _delete_default {
	my ($href, $key, $default) = @_;
	exists $href->{$key} ? delete $href->{$key} : $default
}

my @bare_arms = qw( function );
my %type_map = (
	function           => {},  # all default settings
	function_strict    => {
		defaults   => 'function',
		strict     => 1,
	},
);

our @type_reifiers = \&_reify_type_default;

sub import {
	my $class = shift;

	if (!@_) {
		@_ = { qqw => 'function' };
	}
	if (@_ == 1 && $_[0] eq ':strict') {
		@_ = { qqw => 'function_strict' };
	}
	if (@_ == 1 && ref($_[0]) eq 'HASH') {
		@_ = map [$_, $_[0]{$_}], keys %{$_[0]};
	}

	my %spec;

	my $bare = 0;
	for my $proto (@_) {
		my $item = ref $proto
			? $proto
			: [$proto, $bare_arms[$bare++] || confess(qq{Don't know what to do with "$proto"})]
		;
		my ($name, $proto_type) = @$item;
		_assert_valid_identifier $name;

		$proto_type = {defaults => $proto_type} unless ref $proto_type;

		my %type = %$proto_type;
		while (my $defaults = delete $type{defaults}) {
			my $base = $type_map{$defaults}
				or confess qq["$defaults" doesn't look like a valid type (one of ${\join ', ', sort keys %type_map})];
			%type = (%$base, %type);
		}

		my %clean;

		$clean{name} = delete $type{name} // 'optional';
		$clean{name} =~ /^(?:optional|required|prohibited)\z/
			or confess qq["$clean{name}" doesn't look like a valid name attribute (one of optional, required, prohibited)];

		$clean{shift} = delete $type{shift} // '';
		_assert_valid_identifier $clean{shift}, 1 if $clean{shift};

		$clean{attrs} = join ' ', map delete $type{$_} // (), qw(attributes attrs);
		_assert_valid_attributes $clean{attrs} if $clean{attrs};
		
		$clean{default_arguments} = _delete_default \%type, 'default_arguments', 1;
		$clean{named_parameters}  = _delete_default \%type, 'named_parameters',  1;
		$clean{types}             = _delete_default \%type, 'types',             1;

		$clean{invocant}             = _delete_default \%type, 'invocant',             0;
		$clean{runtime}              = _delete_default \%type, 'runtime',              0;
		$clean{check_argument_count} = _delete_default \%type, 'check_argument_count', 0;
		$clean{check_argument_types} = _delete_default \%type, 'check_argument_types', 1;
		$clean{check_argument_count} = $clean{check_argument_types} = 1 if delete $type{strict};

		if (my $rt = delete $type{reify_type}) {
			ref $rt eq 'CODE' or confess qq{"$rt" doesn't look like a type reifier};

			my $index;
			for my $i (0 .. $#type_reifiers) {
				if ($type_reifiers[$i] == $rt) {
					$index = $i;
					last;
				}
			}
			unless (defined $index) {
				$index = @type_reifiers;
				push @type_reifiers, $rt;
			}

			$clean{reify_type} = $index;
		}

		%type and confess "Invalid keyword property: @{[keys %type]}";

		$spec{$name} = \%clean;
	}
	
	for my $kw (keys %spec) {
		my $type = $spec{$kw};

		my $flags =
			$type->{name} eq 'prohibited' ? FLAG_ANON_OK                :
			$type->{name} eq 'required'   ? FLAG_NAME_OK                :
			                                FLAG_ANON_OK | FLAG_NAME_OK
		;
		$flags |= FLAG_DEFAULT_ARGS if $type->{default_arguments};
		$flags |= FLAG_CHECK_NARGS  if $type->{check_argument_count};
		$flags |= FLAG_CHECK_TARGS  if $type->{check_argument_types};
		$flags |= FLAG_INVOCANT     if $type->{invocant};
		$flags |= FLAG_NAMED_PARAMS if $type->{named_parameters};
		$flags |= FLAG_TYPES_OK     if $type->{types};
		$flags |= FLAG_RUNTIME      if $type->{runtime};
		$^H{HINTK_FLAGS_ . $kw} = $flags;
		$^H{HINTK_SHIFT_ . $kw} = $type->{shift};
		$^H{HINTK_ATTRS_ . $kw} = $type->{attrs};
		$^H{HINTK_REIFY_ . $kw} = $type->{reify_type} // 0;
		$^H{+HINTK_KEYWORDS} .= "$kw ";
	}
}

sub unimport {
	my $class = shift;

	if (!@_) {
		delete $^H{+HINTK_KEYWORDS};
		return;
	}

	for my $kw (@_) {
		$^H{+HINTK_KEYWORDS} =~ s/(?<![^ ])\Q$kw\E //g;
	}
}


our %metadata;

sub _register_info {
	my (
		$key,
		$declarator,
		$invocant,
		$invocant_type,
		$positional_required,
		$positional_optional,
		$named_required,
		$named_optional,
		$slurpy,
		$slurpy_type,
	) = @_;

	my $info = {
		declarator => $declarator,
		invocant => defined $invocant ? [$invocant, $invocant_type] : undef,
		slurpy   => defined $slurpy   ? [$slurpy  , $slurpy_type  ] : undef,
		positional_required => $positional_required,
		positional_optional => $positional_optional,
		named_required => $named_required,
		named_optional => $named_optional,
	};

	$metadata{$key} = $info;
}

sub _mkparam1 {
	my ($pair) = @_;
	my ($v, $t) = @{$pair || []} or return undef;
	JGoff::Keyword::Qqw::Param->new(
		name => $v,
		type => $t,
	)
}

sub _mkparams {
	my @r;
	while (my ($v, $t) = splice @_, 0, 2) {
		push @r, JGoff::Keyword::Qqw::Param->new(
			name => $v,
			type => $t,
		);
	}
	\@r
}

sub info {
	my ($func) = @_;
	my $key = _cv_root $func or return undef;
	my $info = $metadata{$key} or return undef;
	require JGoff::Keyword::Qqw::Info;
	JGoff::Keyword::Qqw::Info->new(
		keyword  => $info->{declarator},
		invocant => _mkparam1($info->{invocant}),
		slurpy   => _mkparam1($info->{slurpy}),
		(map +("_$_" => _mkparams @{$info->{$_}}), glob '{positional,named}_{required,optional}')
	)
}

'ok'

__END__

=encoding UTF-8

=head1 NAME

JGoff::Keyword::Qqw - Interpolating version of qw() operator

=head1 SYNOPSIS

 use JGoff::Keyword::Qqw qw(:strict);

 # Simple use
 $x = 'c';
 @foo = qqw( a b $x d );
 # @foo now contains ( 'a', 'b', 'c', 'd' );
 $x = { };
 @foo = qqw/ a b $x d /;
 # @foo now contains ( 'a', 'b', 'HASH(0x12345678)', 'd' );

 # Array argument
 @foo = qw( a b );
 @bar = qqw{ @foo c d };
 # @bar now contains ( 'a', 'b', 'c', 'd' );

 # Hash argument
 %foo = ( a => 'b', c => 'd' );
@bar = qqw< %foo e f >;
 # @bar now contains either:
 # ( 'a', 'b', 'c', 'd', 'e', 'f' );
 # or
 # ( 'c', 'd', 'a', 'b', 'e', 'f' );
 # depending upon the internal bucket allocation.

 # Scalar dereference
 $foo = 'a';
 $bar = \$foo;
 @baz = qqw" $$foo b c d ";
 # @baz now contains ( 'a', 'b', 'c', 'd' );

 # And so on.

=head1 DESCRIPTION

This module extends Perl with the C<qqw()> operator, an interpolating version
of the C<qw()> operator. It does this using Perl's
L<keyword plugin|perlapi/PL_keyword_plugin> and inspiration from
mauke's L<Function::Parameters> module to work reliably, without a source
filter.

=head2 Arguments

The same arguments accepted by the C<qw()> operator are allowed within the
C<qqw()> operator, along with scalar variables, array variables and hash
variables. Put differently, you can use any combination of bareword values,
scalars, arrays and hashes inside a C<qqw()> operator, subject to the same
constraints as regular perl.

=head2 Delimiters

All delimiters that are legal in C<qw()> (including the balanced delimiters such
as C<qqw()>, C<< qqw<> >>, C<qqw{}> and C<qqw[]> are allowed in C<qqw()>, and
the special cases of C<qqw qwq> should be catered for as well.

=head2 Interpolation

Arguments are evaluated at runtime, and directly copied into the array contents.

 $x = 3;
 $y = { a => 4 };
 @y = qqw( 1 2 $x $y->{a} );
 $x++;
 $y->{a}++;
 print $y[2]; # Yields '3', not 4
 print $y[3]; # Yields '4', not 5

The value is directly copied into the array, and cannot be altered by
manipulating either the variable or the dereferenced scalar.

=head2 Strictures

If possible, the module will check to see whether C<use strict;> is enabled and
throw the appropriate warnings at compile-time if any variable in the C<qqw()>
statement is used but not declared.

=head2 How it works

The module is actually written in L<C|perlxs> and uses
L<C<PL_keyword_plugin>|perlapi/PL_keyword_plugin> to generate opcodes directly.
However, you can run L<C<perl -MO=Deparse ...>|B::Deparse> on your code to see
what happens under the hood

  $x = 3; @x = qqw( 1 2 $x );
  # ... turns into ...
  $x = 3; @x = ( 1, 2, 3 );

=head1 BUGS AND INCOMPATIBILITIES

=head1 SUPPORT AND DOCUMENTATION

After installing, you can find documentation for this module with the
perldoc command.

    perldoc JGoff::Keyword::Qqw

You can also look for information at:

=over

=item MetaCPAN

L<https://metacpan.org/module/JGoff%3A%3AKeyword%3A%3AQqw>

=item RT, CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=JGoff-Keyword-Qqw>

=item AnnoCPAN, Annotated CPAN documentation

L<http://annocpan.org/dist/JGoff-Keyword-Qqw>

=item CPAN Ratings

L<http://cpanratings.perl.org/d/JGoff-Keyword-Qqw>

=item Search CPAN

L<http://search.cpan.org/dist/JGoff-Keyword-Qqw/>

=back

=head1 SEE ALSO

L<JGoff::Keyword::Qqw::Info>

=head1 AUTHOR

Lukas Mai, C<< <l.mai at web.de> >>

=head1 COPYRIGHT & LICENSE

Copyright 2010-2013 Lukas Mai.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut
