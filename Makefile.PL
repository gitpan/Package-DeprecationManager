
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "Manage deprecation warnings for your distribution",
  "AUTHOR" => "Dave Rolsky <autarch\@urth.org>",
  "BUILD_REQUIRES" => {
    "Test::Fatal" => 0,
    "Test::More" => "0.88",
    "Test::Requires" => 0
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Package-DeprecationManager",
  "EXE_FILES" => [],
  "LICENSE" => "artistic_2",
  "NAME" => "Package::DeprecationManager",
  "PREREQ_PM" => {
    "Carp" => 0,
    "List::MoreUtils" => 0,
    "Params::Util" => 0,
    "Sub::Install" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "VERSION" => "0.13",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



