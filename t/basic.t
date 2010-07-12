use strict;
use warnings;

use Test::Exception;
use Test::More;
use Test::Warn;

{
    throws_ok {
        eval 'package Foo; use Package::DeprecationManager;';
        die $@ if $@;
    }
    qr/^\QYou must provide a hash reference -deprecations parameter when importing Package::DeprecationManager/,
        'must provide a set of deprecations when using Package::DeprecationManager';
}

{
    package Foo;

    use Package::DeprecationManager -deprecations => {
        'Foo::foo' => '0.02',
        'Foo::bar' => '0.03',
        'Foo::baz' => '1.21',
    };

    sub foo {
        deprecated('foo is deprecated');
    }

    sub bar {
        deprecated('bar is deprecated');
    }

    sub baz {
        deprecated();
    }
}

{
    package Bar;

    Foo->import();

    ::warning_is{ Foo::foo() }
        { carped => 'foo is deprecated' },
        'deprecation warning for foo';

    ::warning_is{ Foo::bar() }
        { carped => 'bar is deprecated' },
        'deprecation warning for bar';

    ::warning_is{ Foo::baz() }
        { carped => 'Foo::baz has been deprecated since version 1.21' },
        'deprecation warning for baz, and message is generated by Package::DeprecationManager';

    ::warning_is{ Foo::foo() } q{}, 'no warning on second call to foo';

    ::warning_is{ Foo::bar() } q{}, 'no warning on second call to bar';

    ::warning_is{ Foo::baz() } q{}, 'no warning on second call to baz';
}

{
    package Baz;

    Foo->import( -api_version => '0.01' );

    ::warning_is{ Foo::foo() }
        q{},
        'no warning for foo with api_version = 0.01';

    ::warning_is{ Foo::bar() }
        q{},
        'no warning for bar with api_version = 0.01';

    ::warning_is{ Foo::baz() }
        q{},
        'no warning for baz with api_version = 0.01';
}


{
    package Quux;

    Foo->import( -api_version => '1.17' );

    ::warning_is{ Foo::foo() }
        { carped => 'foo is deprecated' },
        'deprecation warning for foo with api_version = 1.17';

    ::warning_is{ Foo::bar() }
        { carped => 'bar is deprecated' },
        'deprecation warning for bar with api_version = 1.17';

    ::warning_is{ Foo::baz() }
        q{},
        'no warning for baz with api_version = 1.17';
}

done_testing();