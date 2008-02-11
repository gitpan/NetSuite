#!perl -T

=head1 NAME

NetSuite getSelectValue Test

=head1 DESCRIPTION

This test attempts to use the getSelectValue method of the NetSuite API
using the "check_account" list.  It confirms the totalRecords returns
matches the array reference of the recordList, and confirms the data
structure matches what is expected.

=cut

use strict;
#use warnings;
use Test::More tests => 15;
use lib 'lib';

BEGIN { use_ok( 'NetSuite' ); }
require_ok( 'NetSuite' );

my $ns = NetSuite->new({ DEFAULT => 1 });
isa_ok($ns, 'NetSuite');
can_ok('NetSuite', qw(login getSelectValue logout));

my $loginStatus = $ns->login;
is($loginStatus, 1, 'successful login');

my $getSelectValueStatus = $ns->getSelectValue('check_account');
is($getSelectValueStatus, 1, 'successful getSelectValue');
is(ref $ns->getResults, 'HASH', 'response parsing');
is($ns->getResults->{statusIsSuccess}, 'true', 'status parsing');
ok($ns->getResults->{totalRecords} > 0, 'confirm records');
is(ref $ns->getResults->{recordRefList}, 'ARRAY', 'record parsing');
is(
   scalar @{ $ns->getResults->{recordRefList} },
   $ns->getResults->{totalRecords},
   'compare recordList with totalRecords'
);

for my $recordRef (@{ $ns->getResults->{recordRefList} }) {
   is (ref $recordRef, 'HASH', 'recordRef parsing');
   ok (defined $recordRef->{recordRefName}, 'recordRefName (data validation)');
   like ($recordRef->{recordRefInternalId}, qr/^\d+/, 'recordRefInternalId (data validation)');
   last;
}

my $logoutStatus = $ns->logout;
is($logoutStatus, 1, 'successful logout');

exit;
