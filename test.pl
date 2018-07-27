#!/usr/bin/env perl

use warnings;
use strict;
use lib '../lib';
use Daedalus::Hermes;
use Coro;
use Coro::AnyEvent;
use Sys::Syslog;

use Carp;

my $HERMES = Daedalus::Hermes->new('rabbitmq');

my $hermes = $HERMES->new(
    {
        host     => 'localhost',
        user     => 'guest',
        password => 'guest',
        port     => 5672,
        queues   => {
            daedalus_core_notifications => {
                purpose         => "daedalus_core_notifications",
                channel         => 45,
                queue_options   => { durable => 1 },
                amqp_props      => { delivery_mode => 2 },
                publish_options => undef,
            },
        }
    }
);


$SIG{PIPE} = 'IGNORE';

my @pids;

while (1){
    for (1..10) {
    push @pids, async {
    my $received_message =
      $hermes->validateAndReceive( { queue => "daedalus_core_notifications" } )->{body};
          syslog("info", $received_message);
          };
          }
          $_->join for @pids;
          undef(@pids)
}
