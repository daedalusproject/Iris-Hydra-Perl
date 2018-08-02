#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More tests => 4;
use Test::Exception;

BEGIN {
    use_ok('Daedalus::Iris') || print "Bail out!\n";
}

diag("Testing Daedalus::Iris $Daedalus::Iris::VERSION, Perl $], $^X");
