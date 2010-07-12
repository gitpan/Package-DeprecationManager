package Package::DeprecationManager;
BEGIN {
  $Package::DeprecationManager::VERSION = '0.01';
}

use strict;
use warnings;

use Carp qw( croak );
use Params::Util qw( _HASH );
use Sub::Install;

sub import {
    shift;
    my %args = @_;

    croak
        'You must provide a hash reference -deprecations parameter when importing Package::DeprecationManager'
        unless $args{-deprecations} && _HASH( $args{-deprecations} );

    my %registry;

    my $import = _build_import( \%registry );
    my $warn = _build_warn( \%registry, $args{-deprecations} );

    my $caller = caller();

    Sub::Install::install_sub(
        {
            code => $import,
            into => $caller,
            as   => 'import',
        }
    );

    Sub::Install::install_sub(
        {
            code => $warn,
            into => $caller,
            as   => 'deprecated',
        }
    );

    return;
}

sub _build_import {
    my $registry = shift;

    return sub {
        my $class = shift;
        my %args  = @_;

        $args{-api_version} ||= delete $args{-compatible};

        $registry->{ caller() } = $args{-api_version}
            if $args{-api_version};

        return;
    };
}

sub _build_warn {
    my $registry      = shift;
    my $deprecated_at = shift;

    my %warned;

    return sub {
        my ( $package, undef, undef, $sub ) = caller(1);

        my $compat_version = $registry->{$package};

        my $deprecated_at = $deprecated_at->{$sub};

        return
            if defined $compat_version
                && defined $deprecated_at
                && $compat_version lt $deprecated_at;

        return if $warned{$package}{$sub};

        if ( ! @_ ) {
            my $msg = "$sub has been deprecated";
            $msg .= " since version $deprecated_at"
                if defined $deprecated_at;

            @_ = $msg;
        }

        $warned{$package}{$sub} = 1;

        goto &Carp::cluck;
    };
}

1;

# ABSTRACT: Manage deprecation warnings for your distribution



=pod

=head1 NAME

Package::DeprecationManager - Manage deprecation warnings for your distribution

=head1 VERSION

version 0.01

=head1 SYNOPSIS

  package My::Class;

  use Package::DeprecationManager
      -deprecations => {
          'My::Class::foo' => '0.02',
          'My::Class::bar' => '0.05',
      };

  sub foo {
      deprecated( 'Do not call foo!' );

      ...
  }

  sub bar {
      deprecated();

      ...
  }

  package Other::Class;

  use My::Class -api_version => '0.04';

  My::Class->new()->foo(); # warns
  My::Class->new()->bar(); # does not warn
  My::Class->new()->far(); # does not warn again

=head1 DESCRIPTION

This module allows you to manage a set of deprecations for one or more modules.

When you import C<Package::DeprecationManager>, you must provide a set of
C<-deprecations> as a hash ref. The keys are fully qualified sub/method names,
and the values are the version when that subroutine was deprecated.

As part of the import process, C<Package::DeprecationManager> will export two
subroutines into its caller. It proves an C<import()> sub for the caller and a
C<deprecated()> sub.

The C<import()> sub allows callers of I<your> class to specify an C<-api_version>
parameter. If this is supplied, then deprecation warnings are only issued for
deprecations for api versions earlier than the one specified.

You must call C<deprecated()> sub in each deprecated subroutine. When called,
it will issue a warning using C<Carp::cluck()>. If you do not pass an explicit
warning message, one will be generated for you.

Deprecation warnings are only issued once for a given package, regardless of
how many times the deprecated sub/method is called.

=head1 BUGS

Please report any bugs or feature requests to
C<bug-package-deprecationmanager@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.  I will be notified, and then you'll automatically be
notified of progress on your bug as I make changes.

=head1 DONATIONS

If you'd like to thank me for the work I've done on this module, please
consider making a "donation" to me via PayPal. I spend a lot of free time
creating free software, and would appreciate any support you'd care to offer.

Please note that B<I am not suggesting that you must do this> in order
for me to continue working on this particular software. I will
continue to do so, inasmuch as I have in the past, for as long as it
interests me.

Similarly, a donation made in this way will probably not make me work on this
software much more, unless I get so many donations that I can consider working
on free software full time, which seems unlikely at best.

To donate, log into PayPal and send money to autarch@urth.org or use the
button on this page: L<http://www.urth.org/~autarch/fs-donation.html>

=head1 CREDITS

The idea for this functionality and some of its implementation was originally
created as L<Class::MOP::Deprecated> by Goro Fuji.

=head1 AUTHOR

  Dave Rolsky <autarch@urth.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2010 by Dave Rolsky.

This is free software, licensed under:

  The Artistic License 2.0

=cut


__END__

