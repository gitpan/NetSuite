#!perl -T

=head1 NAME

NetSuite update Test

=head1 DESCRIPTION

This test attempts to submit an update request, and then get the customer,
and validate the updated field.

=head1 DEPENDENCIES

It is dependent on the exists of the customer record with internalId -5.

=cut

use strict;
#use warnings;
use Test::More tests => 14;
use lib 'lib';

BEGIN { use_ok( 'NetSuite' ); }
require_ok( 'NetSuite' );

my $ns = NetSuite->new({ DEFAULT => 1 });
isa_ok($ns, 'NetSuite');
can_ok('NetSuite', qw(login get update logout));

my $loginStatus = $ns->login;
is($loginStatus, 1, 'successful login');

# set the comments variable equal to something unique
# (time is good enough)
my $comments = time;

# pass that into a customer hash_ref to validate lat
my $customer = {
    internalId => '-5',
    comments => $comments,
};

my $internalId = $ns->update('customer', $customer);
# validate "internalId" field of the updated record
ok(defined $internalId, 'internalId exists');
is($internalId, '-5', 'internalId defined');

$ns->get('customer', -5);
ok(defined $ns->getResults, 'response exists');
is(ref $ns->getResults, 'HASH', 'response parsing');
ok(defined $ns->getResults->{statusIsSuccess}, 'status exists');
is($ns->getResults->{statusIsSuccess}, 'true', 'status defined');

# validate "comments" field, which is just a simple value
ok(defined $ns->getResults->{comments}, 'comments exists');
is($ns->getResults->{comments}, $comments, 'comments defined');

my $logoutStatus = $ns->logout;
is($logoutStatus, 1, 'successful logout');
exit;