#!perl -T

=head1 NAME

NetSuite delete Test

=head1 DESCRIPTION

This test attempts to add a very BASIC customer record, and then delete it.
It then performs and additional get, after the deletion, to confirm it
was done successfully.

=cut

use strict;
#use warnings;
use Test::More tests => 18;
use lib 'lib';

BEGIN { use_ok( 'NetSuite' ); }
require_ok( 'NetSuite' );

my $ns = NetSuite->new({ DEFAULT => 1 });
isa_ok($ns, 'NetSuite');
can_ok('NetSuite', qw(login delete logout));

my $loginStatus = $ns->login;
is($loginStatus, 1, 'successful login');

# set the customerId
my $entityId = 'NS' . time;

# construct a very BASIC data structure to represent a customer
my $customer = {
    entityId => $entityId,
    isPerson => 0, # customer is NOT a person
    companyName => 'Module Installation',
    unsubscribe => 'true',
};

my $internalId = $ns->add('customer', $customer);
ok (defined $internalId, 'internalId exists');
like ($internalId, qr/^\d+/, 'internalId defined');

my $deleteId = $ns->delete('customer', $internalId);
ok (defined $deleteId, 'deleteId exists');
like ($deleteId, qr/^\d+/, 'deleteId defined');

$ns->get('customer', $internalId);
ok(defined $ns->errorResults, 'error exists');
is(ref $ns->errorResults, 'HASH', 'error defined');
ok(defined $ns->errorResults->{code}, 'code exists');
is($ns->errorResults->{code}, 'RCRD_DSNT_EXIST', 'code defined');
ok(defined $ns->errorResults->{message}, 'message exists');
is($ns->errorResults->{message}, 'That record does not exist.', 'message defined');
ok(defined $ns->errorResults->{statusDetailType}, 'statusDetailType exists');
is($ns->errorResults->{statusDetailType}, 'ERROR', 'statusDetailType defined');

my $logoutStatus = $ns->logout;
is($logoutStatus, 1, 'successful logout');
exit;
