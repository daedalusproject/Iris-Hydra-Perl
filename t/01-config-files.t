#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Daedalus::Iris::Hydra;

plan tests => 1;

ok( Daedalus::Iris::Hydra::run( 't/conf_files/conf', 't/conf_files/schemas' ) );

diag(
"Testing Daedalus::Iris::Hydra $Daedalus::Iris::Hydra::VERSION, Perl $], $^X"
);
