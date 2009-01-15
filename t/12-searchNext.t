#!perl -T

=head1 NAME

NetSuite searchNext Test

=head1 DESCRIPTION

This test attempts to perform a basic search and then perform a searchNext
function to retrive the next page of results.

=cut

use strict;
#use warnings;
use Test::More tests => 262;
use lib 'lib';

BEGIN { use_ok( 'NetSuite' ); }
require_ok( 'NetSuite' );
require_ok( '/home/netsuite/t/subs.pl' );

my $ns = NetSuite->new({ DEFAULT => 1 });
isa_ok($ns, 'NetSuite');
can_ok('NetSuite', qw(login search searchNext logout));

my $loginStatus = $ns->login;
is($loginStatus, 1, 'successful login');

my $pageSize = 10; # the number of results per page to return
my $query = {
    basic => [
        { name => 'isInactive', value => 0 } # 0 means false
    ]
};

my $searchStatus = $ns->search('customer', $query, { pageSize => $pageSize });
ok(defined $searchStatus, 'return exists');
is($searchStatus, 1, 'return defined');
&validateSearchResults($ns->searchResults);
&validateCustomerList($ns->searchResults->{recordList});

# set the current pageIndex value for use later in verifying
my $pageIndex = $ns->searchResults->{pageIndex};

# confirm the pageSize is equal to the pageSize returned in the results
is(
   $pageSize,
   $ns->searchResults->{pageSize},
   'compare set pageSize with results pageSize'
);

# issue the request for the list to be incremenet $pageList records
my $searchNextStatus = $ns->searchNext;
ok(defined $searchNextStatus, 'return exists');
is($searchNextStatus, 1, 'return defined');
&validateSearchResults($ns->searchResults);
&validateCustomerList($ns->searchResults->{recordList});

# confirm the pageSize is equal to the pageSize returned in the results
is(
   $pageSize,
   $ns->searchResults->{pageSize},
   'compare set pageSize with results pageSize'
);

$pageIndex++;

is(
   $pageIndex,
   $ns->searchResults->{pageIndex},
   'compare new pageIndex with original pageIndex'
);

my $logoutStatus = $ns->logout;
is($logoutStatus, 1, 'successful logout');
exit;
