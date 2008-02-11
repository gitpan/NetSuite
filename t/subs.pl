#!perl -T

use strict;
#use warnings FATAL => 'all';

sub validateSearchResults {
    my $searchResults = shift;
    
    ok(defined $searchResults, 'response exists');
    is(ref $searchResults, 'HASH', 'response defined');
    ok(defined $searchResults->{statusIsSuccess}, 'status exists');
    is($searchResults->{statusIsSuccess}, 'true', 'status defined');
    
    # confirm each of the search-related values is returned
    for (qw(pageIndex totalPages totalRecords pageSize)) {
        ok(defined $searchResults->{$_}, "$_ exists");
        ok($searchResults->{$_} > 0, "$_ defined");
    }
    
}

sub validateCustomerList {
    my $recordList = shift;
    
    ok (defined $recordList, 'recordList exists');
    is (ref $recordList, 'ARRAY', 'recordList defined');
    for my $record (@{ $recordList }) {
        
        # confirm the record exists and is a hashref
        ok (defined $record, 'record exists');
        is (ref $record, 'HASH', 'record defined');
        
        # confirm the record internalId is returned and is a digit
        ok (defined $record->{recordInternalId}, 'recordInternalId exists');
        like ($record->{recordInternalId}, qr/^(\-)?\d+/, 'recordInternalId defined');
        
        # confirm "complex" field is returned correctly (with name and internalId)
        ok ($record->{entityStatusName}, 'entityStatusName exists');
        ok (defined $record->{entityStatusInternalId}, 'entityStatusInternalId exists');
        like ($record->{entityStatusInternalId}, qr/^(\-)?\d+/, 'entityStatusInternalId defined');
        
        # confirm a boolean value is returned correctly
        ok (defined $record->{isInactive}, 'isInactive exists');
        like ($record->{isInactive}, qr/^(true|false)$/, 'isInactive defined');
        
        # confirm a date value is returned correctly
        ok (defined $record->{dateCreated}, 'dateCreated exists');
        like ($record->{dateCreated}, qr/^\d\d\d\d\-\d\d\-\d\dT\d\d\:\d\d\:\d\d\.\d\d\d\-\d\d\:\d\d$/, 'dateCreated defined');
    
    }
    
}

sub validateTransactionList {
    my $recordList = shift;
    
    ok (defined $recordList, 'recordList exists');
    is (ref $recordList, 'ARRAY', 'recordList defined');
    for my $record (@{ $recordList }) {
        
        # confirm the record exists and is a hashref
        ok (defined $record, 'record exists');
        is (ref $record, 'HASH', 'record defined');
        
        # confirm the record internalId is returned and is a digit
        ok (defined $record->{recordInternalId}, 'recordInternalId exists');
        like ($record->{recordInternalId}, qr/^(\-)?\d+/, 'recordInternalId defined');
        
        # confirm "complex" field is returned correctly (with name and internalId)
        ok ($record->{entityName}, 'entityName exists');
        ok (defined $record->{entityInternalId}, 'entityInternalId exists');
        like ($record->{entityInternalId}, qr/^(\-)?\d+/, 'entityInternalId defined');
        
        # confirm a boolean value is returned correctly
        ok (defined $record->{isTaxable}, 'isTaxable exists');
        like ($record->{isTaxable}, qr/^(true|false)$/, 'isTaxable defined');
        
        # confirm a date value is returned correctly
        ok (defined $record->{createdDate}, 'createdDate exists');
        like ($record->{createdDate}, qr/^\d\d\d\d\-\d\d\-\d\dT\d\d\:\d\d\:\d\d\.\d\d\d\-\d\d\:\d\d$/, 'createdDate defined');
    
    }
    
}
1;