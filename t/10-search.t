#!/usr/bin/perl

=head1 NAME

NetSuite search Test

=head1 DESCRIPTION

This test attempts to perform a search using a customFieldList
and validates the returning customer results.

=cut

use strict;
#use warnings;
use Test::More tests => 135;
use lib 'lib';

BEGIN { use_ok( 'NetSuite' ); }
require_ok( 'NetSuite' );
require_ok( 't/subs.pl' );

my $ns = NetSuite->new({ DEFAULT => 1, DEBUG => 1 });
isa_ok($ns, 'NetSuite');
can_ok('NetSuite', qw(login search searchMore logout));

my $loginStatus = $ns->login;
is($loginStatus, 1, 'successful login');

my $pageSize = 10; # the number of results per page to return
my $query = {
    basic => [
        { name => 'customFieldList', value => [
                {
                    name => 'customField',
                    attr => {
                        internalId => 'custentity1',
                        operator => 'anyOf',
                        'xsi:type' => 'core:SearchMultiSelectCustomField'
                    },
                    value => [
                        { attr => { internalId => 1 } },
                        { attr => { internalId => 2 } },
                        { attr => { internalId => 3 } },
                        { attr => { internalId => 4 } },
                    ]
                },
            ],
        },
    ],
};

my $searchStatus = $ns->search('customer', $query, { pageSize => $pageSize });
ok(defined $searchStatus, 'return exists');
is($searchStatus, 1, 'return defined');
&validateSearchResults($ns->searchResults);
&validateCustomerList($ns->searchResults->{recordList});

# confirm the pageSize is equal to the pageSize returned in the results
is(
   $pageSize,
   $ns->searchResults->{pageSize},
   'compare set pageSize with results pageSize'
);

# confirm the pageSize is equal to the pageSize returned in the results
is(
   $pageSize,
   $ns->searchResults->{pageSize},
   'compare set pageSize with results pageSize'
);

my $logoutStatus = $ns->logout;
is($logoutStatus, 1, 'successful logout');
exit;