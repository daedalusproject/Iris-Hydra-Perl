use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'Daedalus::Iris::Hydra',
    VERSION_FROM  => 'lib/Daedalus/Iris/Hydra.pm',
    ABSTRACT_FROM => 'lib/Daedalus/Iris/Hydra.pm',
    AUTHOR  => q{Álvaro Castellano Vela <alvaro.castellano.vela@gmail.com>},
    LICENSE => 'gpl_3',
    MIN_PERL_VERSION   => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM => {},
    dist      => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean     => { FILES => 'Daedalus-Iris-Hydra*' },
    (
        eval { ExtUtils::MakeMaker->VERSION(6.46) }
        ? (
            META_MERGE => {
                'meta-spec' => { version => 2 },
                resources   => {
                    repository => {
                        type => 'git',
                        url =>
'https://git.daedalus-project.io/daedalusproject/Iris-Hydra-Perl.git',
                        web =>
'https://git.daedalus-project.io/daedalusproject/Iris-Hydra-Perl',
                    },
                }
            }
          )
        : ()
    ),
);
