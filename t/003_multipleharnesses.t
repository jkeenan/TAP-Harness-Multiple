use strict;
use warnings;
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

use_ok('TAP::Harness::Archive::MultipleHarnesses');

pass($0);
