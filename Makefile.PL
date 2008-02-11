
use strict;
use warnings;
use ExtUtils::MakeMaker qw( WriteMakefile prompt );

my %config = (

    NAME => 'NetSuite',
    AUTHOR => 'Jonathan Lloyd <webmaster@lifegames.org>',
    VERSION_FROM =>  'lib/NetSuite.pm',
    ABSTRACT_FROM => 'lib/NetSuite.pm',
    PREREQ_PM => {
        'SOAP::Lite' => 0.69,
        'XML::Parser' => 0,
        'XML::Parser::EasyTree' => 0,
        'Carp' => 0,
        'Data::Dumper' => 0,
        'Test::More' => 0,
    },
);


my $extras = prompt('Do you want to install XML::Handler::YAWriter, 
XML::Parser::PerlSAX and File::Util for debugging?
(This is highly recommended.)', 'yes');

if ($extras =~ m/^y/i) {
    $config{PREREQ_PM}->{'File::Util'} = 0;
    $config{PREREQ_PM}->{'XML::Handler::YAWriter'} = 0;
    $config{PREREQ_PM}->{'XML::Parser::PerlSAX'} = 0;
}



print "Running the test suite may take several minutes to run.\n";
my $tests = prompt( 'Do you want to run the test suite?', 'yes' );

if ($tests =~ m/^y/i) {
    print "Great! If you experience delays, blame NetSuite.\n";
    $config{test} = { TESTS => 't/*.t' };
}
else {
    print "Skipping test suite. Good luck!.\n";
}

WriteMakefile(%config);

# used to declare the HARNESS_PERL_SWITCHES environment variable
# so that an error in SOAP::Transport::HTTP does not display to 
# the end user.
package MY;
sub test {
    my $inherited = shift->SUPER::test(@_);
    $inherited =~ s/(PERL_DL_NONLAZY=)/HARNESS_PERL_SWITCHES='-X' $1/g;
    $inherited;
}
