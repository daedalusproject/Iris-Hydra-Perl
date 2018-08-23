requires 'Devel::Cover::Report::Codecov', 0.22;

recommends 'Pod::Usage';

on test => sub {
    requires 'Test::More',       1.302120;
    requires 'Test::Class',      0.50;
    requires 'Test::MockModule', 0.13;
    requires 'Devel::Mutator',   0.03;
};
