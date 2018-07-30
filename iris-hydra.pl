#!/usr/bin/env perl

use warnings;
use strict;

use XML::LibXML;
use Try::Tiny qw(try catch);
use Readonly;
use XML::Parser;
use XML::SimpleObject;

use Carp qw(croak);

use Data::Dumper;

=head1 NAME

Iris Hydra - Daedalus Project Notification Daemon.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Daemon which processes notifications coming form Daedalus::Hermes queues and processed using Daedalus::Iris

=cut

=head1 CONFIGURATION FILES

This daemon needs an argument containing a path with conf folder.

Conf folder must follow this structure:

.
├── conf.d
│   └── EVENT_NAME.xml
└── iris-hydra.xml

=cut

Readonly my $SCHEMAS_FOLDER  => "./schemas/";
Readonly my $HYDRA_SCHEMA    => "hydra.xsd";
Readonly my $HYDRA_CONF_FILE => "iris-hydra.xml";

=head2 valitate_conf_file

Validate conf/iris_hydra.xml using xsd schema

=cut

sub valitate_conf_file {

    my $schema_file  = shift;
    my $xml_doc_file = shift;

    my $status = {
        code    => 1,
        message => "",
    };

    my $xml_doc = XML::LibXML->load_xml( location => $xml_doc_file );
    my $xsd_doc = XML::LibXML::Schema->new( location => $schema_file );

    try {
        $xsd_doc->validate($xml_doc);
    }
    catch {
        $status->{message} = $_;
        $status->{code}    = 0;
    };

    return $status;
}

=head2 read_conf_files

After validating iris-hydra.xml file, read all conf files required
by conf file. These files must be placed in conf.d folder.

=cut

sub read_conf_files {

    my $hydra_conf_folder = shift;

    my $hydra_conf_file = "$hydra_conf_folder/$HYDRA_CONF_FILE";

    my $parser = XML::Parser->new( ErrorContext => 2, Style => 'Tree' );

    eval { $parser->parsefile($hydra_conf_file); };

    if ($@) {
        croak "\nERROR processing '$hydra_conf_file':\n$@\n";
    }

    my $hydra_config =
      XML::SimpleObject->new( $parser->parsefile($hydra_conf_file) );

    my $hydra = $hydra_config->child("hydra");

    for my $hydra_event ( @{ $hydra->{event} } ) {
        print "events\n";
    }

    die Dumper($hydra);

}

## Main

my $argssize;
my @args;

# Config files

my $schema = "$SCHEMAS_FOLDER$HYDRA_SCHEMA";
my $is_valid;

my $event_configs;

$argssize = scalar @ARGV;

if ( $argssize != 1 ) {
    print STDERR "This script only accepts one arg.\n";
    exit 1;
}

my $conf_folder   = $ARGV[0];
my $conf_filename = "$conf_folder/$HYDRA_CONF_FILE";

open( my $fh, '<:encoding(UTF-8)', $conf_filename )
  or die "Could not open file '$conf_filename' $!";

close($fh);

$is_valid = valitate_conf_file( $schema, $conf_filename );

croak $is_valid->{message} unless ( $is_valid->{code} );

# iris-hydra.xml is valid

$event_configs = read_conf_files($conf_folder);
