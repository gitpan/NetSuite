#!perl -T

=head1 NAME

NetSuite get Test

=head1 DESCRIPTION

This test attempts to get a customer record, and validates the returned
data structures and data types.

=head1 DEPENDENCIES

It is dependent on the customer information staying accurate with the
data test.  This customer record has an internalId of -5.

=cut

use strict;
#use warnings;
use Test::More tests => 32;
use lib 'lib';

BEGIN { use_ok( 'NetSuite' ); }
require_ok( 'NetSuite' );

my $ns = NetSuite->new({ DEFAULT => 1 });
isa_ok($ns, 'NetSuite');
can_ok('NetSuite', qw(login get logout));

my $loginStatus = $ns->login;
is($loginStatus, 1, 'successful login');

$ns->get('customer', -5);
is(ref $ns->getResults, 'HASH', 'response parsing');
is($ns->getResults->{statusIsSuccess}, 'true', 'status parsing');

# validate "phone" field, which is just a simple value
ok(defined $ns->getResults->{phone}, 'phone exists');
is($ns->getResults->{phone}, '650-555-9788', 'phone defined');

# validate "isInactive" field, which is just a boolean value
ok(defined $ns->getResults->{isInactive}, 'isInactive exists');
is($ns->getResults->{isInactive}, 'false', 'isInactive defined');

# validate "entityStatus" field which should contain both an internalId and
# a name of the field being returned
ok(defined $ns->getResults->{entityStatusInternalId}, 'entityStatusInternalId exists');
is($ns->getResults->{entityStatusInternalId}, 13, 'entityStatusInternalId defined');
ok(defined $ns->getResults->{entityStatusName}, 'entityStatusName exists');
is($ns->getResults->{entityStatusName}, 'CUSTOMER-Closed Won', 'entityStatusName defined');

# validate "addressbookList", which should be an array ref of addresses
ok(defined $ns->getResults->{addressbookList}, 'addressbookList exists');
is (ref $ns->getResults->{addressbookList}, 'ARRAY', 'addressbookList parsing');
for my $address (@{ $ns->getResults->{addressbookList} }) {
    
    # validate list element as hash_ref
    is (ref $address, 'HASH', 'address parsing');
    
    # validate internalId within list
    ok (defined $address->{internalId}, 'internalId exists');
    like ($address->{internalId}, qr/^\d+/, 'internalId defined');
    
    # validate boolean value within list
    ok (defined $address->{defaultShipping}, 'defaultShipping exists');
    is ($address->{defaultShipping}, 'true', 'defaultShipping defined');
    
    # validate enumerated value within list
    ok (defined $address->{country}, 'country exists');
    is ($address->{country}, '_unitedStates', 'country defined');
    last;
}

# validate "contactList", which should be an array ref of contacts
ok(defined $ns->getResults->{contactList}, 'contactList exists');
is (ref $ns->getResults->{contactList}, 'ARRAY', 'contactList parsing');
for my $contact (@{ $ns->getResults->{contactList} }) {
    
    # validate list element as hash_ref
    is (ref $contact, 'HASH', 'contact parsing');
    
    # validate complex value within list
    ok (defined $contact->{contactInternalId}, 'internalId exists');
    like ($contact->{contactInternalId}, qr/^\d+/, 'internalId defined');
    ok (defined $contact->{contactName}, 'contactName exists');
    like ($contact->{contactName}, qr/^\w+/, 'contactName defined');
    last;
}

my $logoutStatus = $ns->logout;
is($logoutStatus, 1, 'successful logout');
exit;