use strict;
use warnings FATAL => 'all';

use Test::Tester 0.108;
use Test::More 0.88;
use Test::Warnings;

plan( skip_all => "running in a bare repository (some files missing): skipping" ) if -d '.git';

plan skip_all => 'These tests are only for Test::Builder 0.9x'
    if Test::Builder->VERSION >= 1.005;

require Test::Kwalitee;

my ($premature, @results) = run_tests(
    sub {
        # prevent Test::Kwalitee from making a plan
        no warnings 'redefine';
        local *Test::Builder::plan = sub { };
        local *Test::Builder::done_testing = sub { };

        # we are testing ourselves, so we don't want this warning
        local $ENV{_KWALITEE_NO_WARN} = 1;

        Test::Kwalitee->import;
    },
);
# this list reflects Module::CPANTS::Analyse 0.87
my (@metrics) = qw(
    has_buildtool
    has_changelog
    has_manifest
    has_meta_yml
    has_readme
    has_tests
    no_symlinks
    proper_libs
    no_pod_errors
    use_strict
);

sub is_metric {
    my ( $metric, $is_name ) = @_;
    return unless $metric->{name}      eq $is_name;
    return unless $metric->{depth}     == 1;
    return unless $metric->{ok}        == 1;
    return unless $metric->{actual_ok} == 1;
    return unless $metric->{type}      eq '';
    return unless $metric->{diag}      eq '';
}

subtest "known metrics exist" => sub {
    for my $metric ( @metrics ) {
        my $contains =  grep { is_metric($_, $metric) } @results;
        ok( $contains, "results contains $metric");
    }
};
done_testing;
