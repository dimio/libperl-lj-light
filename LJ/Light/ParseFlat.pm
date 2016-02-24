package LJ::Light::ParseFlat;

use vars qw( $VERSION );
$VERSION = "0.04";

require 5.008_008;
use warnings;
use strict;
use utf8;

sub new {
    my $class = shift;
    my $self = bless {}, $class;

    return $self;
}

sub parse_flatresponse {
    my $self         = shift;
    my $resp_content = shift;

    my $resp_parsed = {};
    # my %$resp_parsed	= split(/\n/, $resp_content);

    my @resp_content = split( /\n/, $resp_content );
    my $index = 0;
    foreach (@resp_content) {
        chomp;
        s/\n//g;
        if ( length > 0 ) {
            my $value = splice( @resp_content, $index + 1, 1 );
            $value =~ s/\n//g;
            $resp_parsed->{$_} = $value;
        }
        $index++;
    }

    die "LJ response: $resp_parsed->{success}: $resp_parsed->{errmsg}"
        if $resp_parsed->{success} ne 'OK';

    return $resp_parsed;
}

1;
