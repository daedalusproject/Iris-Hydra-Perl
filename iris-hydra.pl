#!/usr/bin/env perl

use warnings;
use strict;

use XML::LibXML;
use Try::Tiny qw(try catch);
use Readonly;

use Data::Dumper;

Readonly my $SCHEMAS_FOLDER => "./schemas/";
Readonly my $HYDRA_SCHEMA   => "hydra.xsd";

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

## Main

my $argssize;
my @args;

# Config files

my $schema = "$SCHEMAS_FOLDER$HYDRA_SCHEMA";
my $is_valid;

$argssize = scalar @ARGV;

if ( $argssize != 1 ) {
    print STDERR "This script only accepts one arg.\n";
    exit 1;
}

my $conf_filename = $ARGV[0];

open( my $fh, '<:encoding(UTF-8)', $conf_filename )
  or die "Could not open file '$conf_filename' $!";

close($fh);

$is_valid = valitate_conf_file( $schema, $conf_filename );

die $is_valid->{message} unless ( $is_valid->{code} );
