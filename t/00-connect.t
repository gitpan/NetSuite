#!perl -T

=head1 NAME

NetSuite Connectivity Test

=head1 DESCRIPTION

This test accesses the NetSuite WSDL v2.6 file and attempts to access
each of the available namespaces.

=head1 DEPENDENCIES

If the number of namespaces increases, or a new version of the WSDL file
is used, then you may receive a warning that an invalid NUMBER of tests
was run.

=cut

use strict;
#use warnings;
use Test::More tests => 44;

BEGIN {
    use_ok( 'XML::Parser' );
    use_ok( 'XML::Parser::EasyTree' );
    use_ok( 'Test::WWW::Mechanize' );
}
require_ok( 'XML::Parser' );
require_ok( 'XML::Parser::EasyTree' );
require_ok( 'Test::WWW::Mechanize' );
$XML::Parser::EasyTree::Noempty=1;

my $mech = Test::WWW::Mechanize->new();
isa_ok($mech, 'Test::WWW::Mechanize');
can_ok('Test::WWW::Mechanize', qw(get_ok content));

$mech->get_ok('https://webservices.netsuite.com/wsdl/v2_6_0/netsuite.wsdl', 'Accessing NetSuite WSDL v2.6');

my $p = new XML::Parser( Style=>'EasyTree' );
isa_ok($p, 'XML::Parser');
can_ok('XML::Parser', qw(parse));

my $wsdl = $p->parse($mech->content);
for my $node (@{ $wsdl->[0]->{content}->[0]->{content}->[0]->{content} }) {
    my $namespace = $node->{attrib}->{namespace};
    $mech->get_ok($node->{attrib}->{schemaLocation}, 'Accessing Namespace ' . $namespace);
}
exit;
