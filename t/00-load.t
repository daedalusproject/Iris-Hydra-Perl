#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok('Daedalus::Iris::Hydra') || print "Bail out!\n";
}

diag(
"Testing Daedalus::Iris::Hydra $Daedalus::Iris::Hydra::VERSION, Perl $], $^X"
);
