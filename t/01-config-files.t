#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Daedalus::Iris::Hydra;

plan tests => 1;

ok( Daedalus::Iris::Hydra::run() );

diag(
"Testing Daedalus::Iris::Hydra $Daedalus::Iris::Hydra::VERSION, Perl $], $^X"
);
