#!perl -T

=head1 NAME

NetSuite add Test

=head1 DESCRIPTION

This test attempts to add a customer record, and validates the returned
internalId.

=cut

use strict;
#use warnings;
use Test::More tests => 102;
use lib 'lib';

BEGIN { use_ok( 'NetSuite' ); }
require_ok( 'NetSuite' );

my $ns = NetSuite->new({ DEFAULT => 1 });
isa_ok($ns, 'NetSuite');
can_ok('NetSuite', qw(login get logout));

my $loginStatus = $ns->login;
is($loginStatus, 1, 'successful login');

# set the customerId
my $entityId = 'NS' . time;

# construct a very complicated data structure to represent a customer
my $customer = {
    isPerson => 0,
    entityId => $entityId,
    companyName => 'Module Installation',
    entityStatus => 13, # notice I only pass in the internalId
    emailPreference => '_hTML', # enumerated value
    unsubscribe => 0,
    phone => '650-627-1000', # just to see how it gets added
    creditCardsList => [
        {
            ccDefault => 'true',
            ccMemo => 'This is my default credit card.',
            paymentMethod => 5, # Visa
            ccNumber => '4111111111111111',
            ccExpireDate => '2010-01-01T00:00:00',
            ccName => 'Visa'
        },
        {
            ccDefault => 0,
            ccMemo => 'This is NOT my default credit card.',
            paymentMethod => 3, # MasterCard
            ccNumber => '5431111111111111',
            ccExpireDate => '2010-01-01T00:00:00',
            ccName => 'MasterCard'
        }
    ],
    addressbookList => [
        {
            defaultShipping => 'true',
            defaultBilling => 0,
            isResidential => 0,
            phone => '650-627-1000',
            label => 'United States Office',
            addr1 => '2955 Campus Drive',
            addr2 => 'Suite 100',
            city => 'San Mateo',
            state => 'CA',
            zip => '94403',
            country => '_unitedStates',
        },
        {
            defaultShipping => 0,
            defaultBilling => 'true',
            isResidential => 0,
            phone => '4401628774400',
            label => 'Europe/Middle East/Africa',
            addr1 => '1 Grenfell Road',
            addr2 => 'Maidenhead',
            city => 'Berks',
            state => 'UK',
            zip => 'SL6 1HN',
            country => '_unitedKingdomGB',
        }
    ],
};

# submit the record to NetSuite and return the internalId
my $internalId = $ns->add('customer', $customer);

# validate that the internalId was returned correctly
ok (defined $internalId, 'internalId exists');
like ($internalId, qr/^\d+/, 'internalId defined');

# submit the request to get a customer
$ns->get('customer', $internalId);

# validate the response
ok(defined $ns->getResults, 'response exists');
is(ref $ns->getResults, 'HASH', 'response defined');
ok(defined $ns->getResults->{statusIsSuccess}, 'status exists');
is($ns->getResults->{statusIsSuccess}, 'true', 'status parsing');

# replace entityStatus with the internalId
$customer->{entityStatusInternalId} = $customer->{entityStatus};
delete $customer->{entityStatus};

# validate each of the non-list fields with the values in the customer hash ref
for my $field (keys %{ $customer }) {
    if ($field =~ m/List$/) {
        for my $index (0..$#{ $customer->{$field} }) {
            for my $record (keys %{ $customer->{$field}->[$index] }) {
                if ($record eq 'paymentMethod') {
                    $customer->{$field}->[$index]->{paymentMethodInternalId} =
                        $customer->{$field}->[$index]->{$record};
                    delete $customer->{$field}->[$index]->{$record};
                }
                elsif ($record eq 'ccNumber') {
                    $customer->{$field}->[$index]->{$record} =~ s/^\d+(\d\d\d\d)$/************$1/;
                }
                elsif ($record eq 'ccExpireDate') {
                    delete $customer->{$field}->[$index]->{$record};
                }
                elsif ($customer->{$field}->[$index]->{$record} =~ /^\d+$/) {
                    if ($customer->{$field}->[$index]->{$record} == 0) {
                        $customer->{$field}->[$index]->{$record} = 'false';
                    }
                }
            }
        }
    }
    else {
        if ($customer->{$field} =~ /^\d+$/) {
            $customer->{$field} = 'false' if $customer->{$field} == 0;
        }
        ok(defined $ns->getResults->{$field}, "$field exists");
        is($ns->getResults->{$field}, $customer->{$field}, "$field defined");
        
    }
}

# validate "addressbookList", against the submitted hash
ok(defined $ns->getResults->{addressbookList}, 'addressbookList exists');
is (ref $ns->getResults->{addressbookList}, 'ARRAY', 'addressbookList parsing');
for my $address (@{ $ns->getResults->{addressbookList} }) {
    
    # validate list element as hash_ref
    is (ref $address, 'HASH', 'address parsing');
    
    if ($address->{defaultShipping} eq 'true') {
        # validate each of the address fields for integrity
        for my $field (keys %{ $customer->{addressbookList}->[0] }) {
            ok(defined $address->{$field}, "$field exists");
            is($address->{$field}, $customer->{addressbookList}->[0]->{$field}, "$field defined");
        }
    }
    
    if ($address->{defaultBilling} eq 'true') {
        # validate each of the address fields for integrity
        for my $field (keys %{ $customer->{addressbookList}->[1] }) {
            ok(defined $address->{$field}, "$field exists");
            is($address->{$field}, $customer->{addressbookList}->[1]->{$field}, "$field defined");
        }
    }
    
    # validate internalId within list
    ok (defined $address->{internalId}, 'internalId exists');
    like ($address->{internalId}, qr/^\d+/, 'internalId defined');
    
}

# validate "creditCardsList", against the submitted hash
ok(defined $ns->getResults->{creditCardsList}, 'creditCardsList exists');
is (ref $ns->getResults->{creditCardsList}, 'ARRAY', 'creditCardsList parsing');
for my $creditCard (@{ $ns->getResults->{creditCardsList} }) {
    
    # validate list element as hash_ref
    is (ref $creditCard, 'HASH', 'address parsing');
    
    if ($creditCard->{ccDefault} eq 'true') {
        # validate each of the address fields for integrity
        for my $field (keys %{ $customer->{creditCardsList}->[0] }) {
            ok(defined $creditCard->{$field}, "$field exists");
            is($creditCard->{$field}, $customer->{creditCardsList}->[0]->{$field}, "$field defined");
        }
    }
    else {
        # validate each of the address fields for integrity
        for my $field (keys %{ $customer->{creditCardsList}->[1] }) {
            ok(defined $creditCard->{$field}, "$field exists");
            is($creditCard->{$field}, $customer->{creditCardsList}->[1]->{$field}, "$field defined");
        }
    }
    
    # APPARENTLY THE internalId IS NOT RETURNED WITH THE CREDITCARD
    # Stupid Netsuite..
    
    # validate internalId within list
    # ok (defined $creditCard->{internalId}, 'internalId exists');
    # like ($creditCard->{internalId}, qr/^\d+/, 'internalId defined');
    
}

my $logoutStatus = $ns->logout;
is($logoutStatus, 1, 'successful logout');
exit;