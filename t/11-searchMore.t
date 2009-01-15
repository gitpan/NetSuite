#!perl -T

=head1 NAME

NetSuite searchMore Test

=head1 DESCRIPTION

This test attempts to perform a basic search and then perform a searchNext
function to retrive the next page of results.

=cut

use strict;
#use warnings;
use Test::More tests => 262;
use lib 'lib';
use XML::Handler::YAWriter;
use NetSuite;

BEGIN { use_ok( 'NetSuite' ); }
require_ok( 'NetSuite' );
require_ok( '/home/netsuite/t/subs.pl' );

my $ns = NetSuite->new({ DEFAULT => 1, DEBUG => 1 });
isa_ok($ns, 'NetSuite');
can_ok('NetSuite', qw(login search searchMore logout));

my $loginStatus = $ns->login;
is($loginStatus, 1, 'successful login');

my $pageSize = 10; # the number of results per page to return
my $query = {
    basic => [
        { name => 'mainline', value => 'true' },
        { name => 'type', attr => { operator => 'anyOf' }, value => [
                { value => '_salesOrder' },
                { value => '_invoice' },
                { value => '_cashSale' },
            ]   
        },
        { name => 'tranDate', value => 'today', attr => { operator => 'onOrBefore' } },
    ],
    customerJoin => [
        { name => 'email', attr => { operator => 'notEmpty' } },
        { name => 'entityStatus', attr => { operator => 'anyOf' }, value => [
                { attr => { internalId => '13' } },
                { attr => { internalId => '15' } },
                { attr => { internalId => '16' } },
            ]                                                          
        },
    ],
};

my $searchStatus = $ns->search('transaction', $query, { pageSize => $pageSize });
ok(defined $searchStatus, 'return exists');
is($searchStatus, 1, 'return defined');

&validateSearchResults($ns->searchResults);
&validateTransactionList($ns->searchResults->{recordList});

# confirm the pageSize is equal to the pageSize returned in the results
is(
   $pageSize,
   $ns->searchResults->{pageSize},
   'compare set pageSize with results pageSize'
);

# set which page of the record set to pull
my $pageIndex = 3;

# issue the request for the list to be incremenet $pageList records
my $searchMoreStatus = $ns->searchMore($pageIndex);
ok(defined $searchMoreStatus, 'return exists');
is($searchMoreStatus, 1, 'return defined');
&validateSearchResults($ns->searchResults);
&validateTransactionList($ns->searchResults->{recordList});

# confirm the pageSize is equal to the pageSize returned in the results
is(
   $pageSize,
   $ns->searchResults->{pageSize},
   'compare set pageSize with results pageSize'
);

# confirm the pageIndex is equal to what was requested
is(
   $pageIndex,
   $ns->searchResults->{pageIndex},
   'compare new pageIndex with original pageIndex'
);

my $logoutStatus = $ns->logout;
is($logoutStatus, 1, 'successful logout');
exit;
