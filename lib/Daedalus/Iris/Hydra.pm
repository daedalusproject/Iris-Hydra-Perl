package Daedalus::Iris::Hydra;

use 5.006;
use strict;
use warnings;
use XML::LibXML;
use Try::Tiny qw(try catch);
use Readonly;
use XML::Parser;
use XML::SimpleObject;
use Daedalus::Hermes;

use Carp qw(croak);
use Data::Dumper;

=head1 NAME

Daedalus::Iris::Hydra - Daedalus Project Notification Daemon.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Daemon which processes notifications coming form Daedalus::Hermes queues and processed using Daedalus::Iris

=cut

=head2 CONFIGURATION FILES

This daemon needs an argument containing a path with conf folder.

Conf folder must follow this structure:

.
├── conf.d
│   └── EVENT_NAME.xml
└── iris-hydra.xml

Schemas folder must follow this structure so far:

.
└── hydra.xsd

=cut

=head2 valitate_conf_file

Validate conf/iris_hydra.xml using xsd schema

=cut

Readonly my $SCHEMAS_FOLDER  => "./schemas/";
Readonly my $HYDRA_SCHEMA    => "hydra.xsd";
Readonly my $HYDRA_CONF_FILE => "iris-hydra.xml";

__PACKAGE__->run(@ARGV) unless caller();

sub run {

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

=head2 read_hydra_conf_files

After validating iris-hydra.xml file, read all conf files required
by conf file. These files must be placed in conf.d folder.

=cut

    sub read_hydra_conf_files {

        my $hydra_conf_folder = shift;

        my $event_configs = {};

        my @hermes_config_names;

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

            my $notification_name = $hydra_event->child('name')->value;
            my $notification_type = $hydra_event->child('notification')->value;
            my $hermes_name =
              $hydra_event->child('hermes')->child('name')->value;

            if ( grep ( /^$hermes_name$/, @hermes_config_names ) ) {
                croak
"\nHermes config must be different for each event, $hermes_name is being used in more than one event.\n";
            }
            else {
                push @hermes_config_names, $hermes_name;
            }

            $event_configs->{$notification_name} =
              { notification_type => $notification_type, };

# For each hermes_config there must exist an xml config file iwit the same name inside conf.d
            $event_configs->{$notification_name}->{hermes_config} =
              Daedalus::Hermes::parse_hermes_config(
                "$hydra_conf_folder/conf.d/$hermes_name.xml");
        }

        return $event_configs;

    }

    sub start_hermes {
        my $hermes_config = shift;
        my $conf_folder   = shift;

        my $iris_notification_type = $hermes_config->{notification_type};

        my $iris_conf_file = "$conf_folder/iris-$iris_notification_type.xml";

        my $parser = XML::Parser->new( ErrorContext => 2, Style => 'Tree' );

        eval { $parser->parsefile($iris_conf_file); };

        if ($@) {
            croak "\nERROR processing '$iris_conf_file':\n$@\n";
        }

        my $iris_config =
          XML::SimpleObject->new( $parser->parsefile($iris_conf_file) );

        my $iris = $iris_config->child("iris");

        my %iris;

        for my $child ( $iris->children ) {
            $iris{ $child->name } = $child->value;
        }
        die Dumper( \%iris );
    }
## Main

    my $argssize;
    my @args;

    # Config files

    my $is_valid;

    my $event_configs;

    $argssize = scalar @ARGV;

    my $conf_folder    = "";
    my $schemas_folder = "";

    if ( $argssize != 2 ) {
        if ( @_ != 2 ) {
            print STDERR
"This script only accepts two args, conf folder location and schemas folder location.\n";
            exit 1;
        }
        else {
            $conf_folder    = shift;
            $schemas_folder = shift;
        }
    }
    else {
        $conf_folder    = $ARGV[0];
        $schemas_folder = $ARGV[1];
    }
    my $conf_filename = "$conf_folder/$HYDRA_CONF_FILE";
    my $schema        = "$schemas_folder/$HYDRA_SCHEMA";

    open( my $fh, '<:encoding(UTF-8)', $conf_filename )
      or die "Could not open file '$conf_filename' $!";

    close($fh);

    $is_valid = valitate_conf_file( $schema, $conf_filename );

    croak $is_valid->{message} unless ( $is_valid->{code} );

    # iris-hydra.xml is valid

    $event_configs = read_hydra_conf_files($conf_folder);

    # Check Iris Config
    for my $event_name ( keys %$event_configs ) {
        my $iris_notification_type =
          $event_configs->{$event_name}->{notification_type};
        my $iris_conf_filename =
          "$conf_folder/iris-$iris_notification_type.xml";
        my $iris_conf_schema =
          "$schemas_folder/iris-$iris_notification_type.xsd";
        my $check_status =
          valitate_conf_file( $iris_conf_schema, $iris_conf_filename );
        croak "Iris config for $event_name is invalid"
          unless ( $check_status->{code} );
    }

    #Create subprocess for each event
    my $pid;
    for my $event_name ( keys %$event_configs ) {
        $pid = fork();
        croak "Fatal error creating subprocess" if not defined $pid;
        if ( not $pid ) {
            start_hermes( $event_configs->{$event_name}, $conf_folder );
        }
    }
}

=head1 AUTHOR

Álvaro Castellano Vela, C<< <alvaro.castellano.vela at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-daedalus-iris-hydra at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Daedalus-Iris-Hydra>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Daedalus::Iris::Hydra


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Daedalus-Iris-Hydra>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Daedalus-Iris-Hydra>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Daedalus-Iris-Hydra>

=item * Search CPAN

L<http://search.cpan.org/dist/Daedalus-Iris-Hydra/>

=back


=head1 ACKNOWLEDGEMENTS

=head1 LICENSE AND COPYRIGHT

Copyright 2018 Álvaro Castellano Vela.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GENERAL PUBLIC LICENSE Version 3.

=cut

1;    # End of Daedalus::Iris::Hydra
