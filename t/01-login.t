#!perl

=head1 NAME

NetSuite Login Test

=head1 DESCRIPTION

This test attempts to connect to a NetSuite developer account, using the
public account information.  It is setup as a Web Services Only role
(in case some CPANer decides to mess around with my test account) and should
have full access to web services (which could allow someone to mess around
with my test account).  Hopefully no one does... * innocent smile *

It validates the retured login results and tests both a successful and
unsuccessful login attempt.

=cut

use strict;
no warnings "all";
use Test::More tests => 20;
use lib 'lib';

BEGIN { use_ok( 'NetSuite' ); }
require_ok( 'NetSuite' );

my $loginSuccess = NetSuite->new({ DEFAULT => 1 });
isa_ok($loginSuccess, 'NetSuite');
can_ok('NetSuite', qw(login loginResults));

# test a successful login
my $loginSuccessStatus = $loginSuccess->login;
is($loginSuccessStatus, 1, 'successful login');

is ($loginSuccess->loginResults->{statusIsSuccess}, 'true', 'status parsing');
is (ref $loginSuccess->loginResults->{wsRoleList}, 'ARRAY', 'roleList parsing (defined)');
ok (scalar @{ $loginSuccess->loginResults->{wsRoleList} } > 0, 'roleList parsing (array_ref)');

# if we were able to login successfully, we know there is at least 1
# role in the role list.  Compare the data structure for one element
# of the list, and break
for my $role (@{ $loginSuccess->loginResults->{wsRoleList} }) {
    is (ref $role, 'HASH', 'role parsing (hash_ref)');
    like ($role->{isDefault}, qr/^(true|false)$/, 'isDefault (data verification)');
    like ($role->{isInactive}, qr/^(true|false)$/, 'isInactive (data verification)');
    like ($role->{roleInternalId}, qr/^\d+$/, 'roleInternalId (data verification)');
    is ($role->{roleName}, 'Web Services Only', 'roleName (data verification)');
    last;
}

my $logoutStatus = $loginSuccess->logout;
is($logoutStatus, 1, 'successful logout');

# test a failed login
my $loginFailure = NetSuite->new({
    EMAIL => 'invalid@email.com',
    PASSWORD => 'password',
    ROLE => 3,
    ACCOUNT => 12345678
});
isa_ok($loginFailure, 'NetSuite');
can_ok('NetSuite', qw(login loginResults));

my $loginFailureStatus = $loginFailure->login;
is($loginFailureStatus, undef, 'failed login');

is(ref $loginFailure->errorResults, 'HASH', 'error parsing');
is(
   $loginFailure->errorResults->{code},
   'INVALID_LOGIN_CREDENTIALS',
   'error code (data verification)'
);
is(
   $loginFailure->errorResults->{message},
   'You have entered an invalid email address or account number. Please try again.',
   'error message  (data verification)'
);

exit;