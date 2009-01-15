#!perl -T

=head1 NAME

NetSuite Logout Test

=head1 DESCRIPTION

This test attempts to connect to a NetSuite developer account, and then
logout successfully.

It validates the retured logout results and tests both a successful and
unsuccessful logout attempt.

=cut

use strict;
#use warnings;
use Test::More tests => 11;
use lib 'lib';

BEGIN { use_ok( 'NetSuite' ); }
require_ok( 'NetSuite' );

my $ns = NetSuite->new({ DEFAULT => 1 });
isa_ok($ns, 'NetSuite');
can_ok('NetSuite', qw(login loginResults));

my $loginSuccessStatus = $ns->login;
is($loginSuccessStatus, 1, 'successful login');

my $logoutSuccessStatus = $ns->logout;
is($logoutSuccessStatus, 1, 'successsful logout');
is ($ns->loginResults->{statusIsSuccess}, 'true', 'status parsing');

# after successfully logging out of the session
# another attempt at logging out will throw an error
my $logoutFailureStatus = $ns->logout;
is($logoutFailureStatus, undef, 'failed logout');
is(ref $ns->errorResults, 'HASH', 'error parsing');
is(
   $ns->errorResults->{code},
   'WS_LOG_IN_REQD',
   'error code (data verification)'
);
is(
   $ns->errorResults->{message},
   'You must log in before performing a web service operation.',
   'error message  (data verification)'
);

exit;
