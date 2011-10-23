use strict;
use warnings;
use Carp;
use Cwd;
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
# and FAIL.  When we run the test, each file's TAP should be reported by
# description rather than by name.  To be meaningful, we will have to run one
# set of tests twice with different labels and different rules. Then we should
# run two different sets of tests with different labels but the same rules.

# We should also demonstrate that an archive has been created, that it
# contains the TAP report files named by description, and that the meta.yaml
# file is correct.  (The latter will probably require loading some YAML
# module.) #'

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

my ($cwd, $archive, $overall_aggregator);
$cwd = cwd();

{
    my $tdir = tempdir( CLEANUP => 1 );
    chdir $tdir or croak "Unable to chdir for testing";

    my $archive_dir = File::Spec->catdir( $tdir, 'archive' );
    File::Path::make_path( $archive_dir );
    my $archive_file =
        File::Spec->catfile( $archive_dir, 'parrot_test_run.tar.gz' );
    my @extra_files =  ( 'myconfig', 'config_lib.pir' );
    for my $ex (@extra_files) {
        my $ex_file = File::Spec->catfile( $tdir, $ex );
        open my $FH, '>', $ex_file or croak "Unable to open $ex_file";
        print $FH "$ex\n";
        close $FH or croak "Unable to close $ex_file";
    }
    my $archive = TAP::Harness::Archive::MultipleHarnesses->new( {
        verbosity        => $ENV{HARNESS_VERBOSE},
        archive          => 'parrot_test_run.tar.gz',
        merge            => 1,
        jobs             => $ENV{TEST_JOBS} || 1,
        extra_properties => {},
#        extra_files      => [ 'myconfig', 'config_lib.pir' ],
        extra_files      => [ @extra_files ],
    } );
    ok( defined $archive,
        "TAP::Harness::Archive::MultipleHarnesses->new() returned defined value" );
    isa_ok( $archive, 'TAP::Harness::Archive::MultipleHarnesses' );

    chdir($cwd) or croak "Unable to return to $cwd after testing";
}

pass($0);
