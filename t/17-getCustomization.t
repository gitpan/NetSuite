#!perl -T

=head1 NAME

NetSuite getCustomization Test

=head1 DESCRIPTION

This test attempts to get custom transaction body fields, and loosely
validates the resulting data set.

=cut

use strict;
#use warnings;
use Test::More tests => 46;
use lib 'lib';

BEGIN { use_ok( 'NetSuite' ); }
require_ok( 'NetSuite' );

my $ns = NetSuite->new({ DEFAULT => 1 });
isa_ok($ns, 'NetSuite');
can_ok('NetSuite', qw(login getCustomization logout));

my $loginStatus = $ns->login;
ok(defined $loginStatus, 'loginStatus exists');
is($loginStatus, 1, 'loginStatus defined');

$ns->getCustomization('transactionBodyCustomField');
ok(defined $ns->getResults, 'response exists');
is(ref $ns->getResults, 'HASH', 'response parsing');
ok(defined $ns->getResults->{statusIsSuccess}, 'status exists');
is($ns->getResults->{statusIsSuccess}, 'true', 'status parsing');

ok(defined $ns->getResults->{totalRecords}, 'totalRecords exists');
ok($ns->getResults->{totalRecords} > 0, 'totalRecords defined');
ok(defined $ns->getResults->{recordList}, 'recordList exists');
is(ref $ns->getResults->{recordList}, 'ARRAY', 'recordList parsing');
is(
   scalar @{ $ns->getResults->{recordList} },
   $ns->getResults->{totalRecords},
   'compare recordList with totalRecords'
);

for my $record (@{ $ns->getResults->{recordList} }) {
    is (ref $record, 'HASH', 'record parsing');
    for (qw(
        showInList
        fieldType
        bodyPrintStatement
        recordInternalId
        bodyAssemblyBuild
        bodySale
        bodyItemReceiptOrder
        storeValue
        isMandatory
        recordType
        isParent
        bodyPurchase
        defaultChecked
        bodyPickingTicket
        bodyInventoryAdjustment
        bodyExpenseReport
        bodyItemFulfillmentOrder
        bodyPrintPackingSlip
        bodyOpportunity
        bodyPrintFlag
        isFormula
        checkSpelling
        bodyItemReceipt
        displayType
        bodyItemFulfillment
        label
        bodyJournal
        bodyStore    
    )) {
        ok (defined $record->{$_}, "$_ defined");
    }
    last;
}

my $logoutStatus = $ns->logout;
ok(defined $logoutStatus, 'logoutStatus exists');
is($logoutStatus, 1, 'logoutStatus defined');
exit;