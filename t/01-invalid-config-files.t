#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More tests => 2;
use Test::Exception;

use Daedalus::Iris::Hydra;

throws_ok {
    Daedalus::Iris::Hydra::run( 't/conf_files/conf-duplicated-events',
        't/conf_files/schemas' );
}
qr/Hermes config must be different for each event, daedalus_core_notifications is being used in more than one event/,
  "It is not allowed to define more than one event with the same name.";

throws_ok {
    Daedalus::Iris::Hydra::run( 't/conf_files/conf-duplicated-hermes',
        't/conf_files/schemas' );
}
qr/Hermes config must be different for each event, daedalus_core_notifications is being used in more than one event/,
  "It is not allowed to define more than one event with the same name.";

diag(
"Testing Daedalus::Iris::Hydra $Daedalus::Iris::Hydra::VERSION, Perl $], $^X"
);
