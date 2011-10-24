use strict;
use warnings;
use Carp;
use Cwd;
use Data::Dumper;$Data::Dumper::Indent=1;
use File::Basename;
use File::Copy;
use File::Temp qw( tempdir );
use File::Path 2.08 ();
use Test::More qw( no_plan );
use TAP::Harness::Archive::MultipleHarnesses;
use IO::CaptureOutput qw( capture );

# To test this we will have to create at least one set of tests as we do in
# t/fullharness, i.e., a set that has 'label', 'rule' and 'tests' elements.
# The test files will have to contain some real tests, perhaps with both PASS
# and FAIL.  When we run the test, each files TAP should be reported by
# description rather than by name.  To be meaningful, we will have to run one
# set of tests twice with different labels and different rules. Then we should
# run two different sets of tests with different labels but the same rules.

# We should also demonstrate that an archive has been created, that it
# contains the TAP report files named by description, and that the meta.yaml
# file is correct.  (The latter will probably require loading some YAML
# module.)

#    my $archive = TAP::Harness::Archive::MultipleHarnesses->new( {
#        verbosity        => $ENV{HARNESS_VERBOSE},
#        archive          => 'parrot_test_run.tar.gz',
#        merge            => 1,
#        jobs             => $ENV{TEST_JOBS} || 1,
#        extra_properties => \%env_data,
#        extra_files      => [ 'myconfig', 'config_lib.pir' ],
#    } );
#    my $overall_aggregator = $archive->runtests(\@targets);
#    $archive->summary($overall_aggregator);

use_ok('TAP::Harness::Archive::MultipleHarnesses');

my ($cwd, $archive, $overall_aggregator, @targets);
$cwd = cwd();

{
    my $tmpdir = tempdir( CLEANUP => 1 );
    chdir $tmpdir or croak "Unable to chdir for testing";

    my $archive_dir = File::Spec->catdir( $tmpdir, 'archive' );
    File::Path::make_path( $archive_dir, { mode => 0755 } );
    my $archive_file =
        File::Spec->catfile( $archive_dir, 'parrot_test_run.tar.gz' );
    my $t_dir = File::Spec->catdir( $tmpdir, 't' );
    File::Path::make_path( $t_dir, { mode => 0755 } );
    foreach my $t_file ( glob("$cwd/t/testlib/*.t") ) {
        copy $t_file => "$t_dir/" . basename($t_file)
            or croak "Unable to copy .t file into position for testing";
    }
    my @extra_files =  ( 'myconfig', 'config_lib.pir' );
    for my $ex (@extra_files) {
        my $ex_file = File::Spec->catfile( $tmpdir, $ex );
        open my $FH, '>', $ex_file or croak "Unable to open $ex_file";
        print $FH "$ex\n";
        close $FH or croak "Unable to close $ex_file";
    }
    my $archive = TAP::Harness::Archive::MultipleHarnesses->new( {
        verbosity        => $ENV{HARNESS_VERBOSE},
        archive          => $archive_file,
        merge            => 1,
        jobs             => $ENV{TEST_JOBS} || 1,
        extra_properties => {},
        extra_files      => [ @extra_files ],
    } );
    ok( defined $archive,
        "TAP::Harness::Archive::MultipleHarnesses->new() returned defined value" );
    isa_ok( $archive, 'TAP::Harness::Archive::MultipleHarnesses' );

    @targets = (
        {
            label   => 'greek',
            rule    => sub { return 1; },
            tests   => make_test_set( 'greek', [
                "$t_dir/alpha.t",
                "$t_dir/beta.t",
            ] ),
        },
        {
            label   => 'hebrew',
            rule    => sub { return 1; },
            tests   => make_test_set( 'hebrew', [
                "$t_dir/aleph.t",
                "$t_dir/beth.t",
            ] ),
        },
    );
    my ($stdout, $stderr);
    capture(
        sub {
            $overall_aggregator = $archive->runtests(\@targets);
            $archive->summary($overall_aggregator);
        },
        \$stdout,
        \$stderr,
    );
    like( $stdout, qr/greek__alpha/s, "Test reported by description" );
    like( $stdout, qr/greek__beta/s,  "Test reported by description" );
    like( $stdout, qr/hebrew__aleph/s, "Test reported by description" );
    like( $stdout, qr/hebrew__beth/s,  "Test reported by description" );
    like( $stdout, qr/Result: PASS/s,
        "Got summary: different label/tests; same environment" );

    chdir($cwd) or croak "Unable to return to $cwd after testing";
}

{
    my $tmpdir = tempdir( CLEANUP => 1 );
    chdir $tmpdir or croak "Unable to chdir for testing";

    my $archive_dir = File::Spec->catdir( $tmpdir, 'archive' );
    File::Path::make_path( $archive_dir, { mode => 0755 } );
    my $archive_file =
        File::Spec->catfile( $archive_dir, 'parrot_test_run.tar.gz' );
    my $t_dir = File::Spec->catdir( $tmpdir, 't' );
    File::Path::make_path( $t_dir, { mode => 0755 } );
    foreach my $t_file ( glob("$cwd/t/testlib/*.t") ) {
        copy $t_file => "$t_dir/" . basename($t_file)
            or croak "Unable to copy .t file into position for testing";
    }
    my @extra_files =  ( 'myconfig', 'config_lib.pir' );
    for my $ex (@extra_files) {
        my $ex_file = File::Spec->catfile( $tmpdir, $ex );
        open my $FH, '>', $ex_file or croak "Unable to open $ex_file";
        print $FH "$ex\n";
        close $FH or croak "Unable to close $ex_file";
    }
    my $archive = TAP::Harness::Archive::MultipleHarnesses->new( {
        verbosity        => $ENV{HARNESS_VERBOSE},
        archive          => $archive_file,
        merge            => 1,
        jobs             => $ENV{TEST_JOBS} || 1,
        extra_properties => {},
        extra_files      => [ @extra_files ],
    } );
    ok( defined $archive,
        "TAP::Harness::Archive::MultipleHarnesses->new() returned defined value" );
    isa_ok( $archive, 'TAP::Harness::Archive::MultipleHarnesses' );

    @targets = (
        {
            label   => 'american',
            rule    => sub { return 1; },
            tests   => make_test_set( 'american', [
                "$t_dir/alpha.t",
                "$t_dir/beta.t",
            ] ),
        },
        {
            label   => 'commonwealth',
            rule    => sub { return 'hello world'; },
            tests   => make_test_set( 'commonwealth', [
                "$t_dir/alpha.t",
                "$t_dir/beta.t",
            ] ),
        },
    );
    my ($stdout, $stderr);
    capture(
        sub {
            $overall_aggregator = $archive->runtests(\@targets);
            $archive->summary($overall_aggregator);
        },
        \$stdout,
        \$stderr,
    );
    like( $stdout, qr/american__alpha/s, "Test reported by description" );
    like( $stdout, qr/american__beta/s,  "Test reported by description" );
    like( $stdout, qr/commonwealth__alpha/s, "Test reported by description" );
    like( $stdout, qr/commonwealth__beta/s,  "Test reported by description" );
    like( $stdout, qr/Result: PASS/s,
        "Got summary: different label, same tests; different environments" );

    chdir($cwd) or croak "Unable to return to $cwd after testing";
}

pass($0);

sub make_test_set {
    my ($label, $testsref) = @_;
    my @tests = ();
    foreach my $t (@$testsref) {
        push @tests,
            [ $t, $label . '__' . basename($t) ];
    }
    return \@tests;
}
