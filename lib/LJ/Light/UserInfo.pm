package LJ::Light::UserInfo;

use vars qw( $VERSION );
$VERSION = "0.04";

require 5.008_008;
use warnings;
use strict;
use utf8;

sub new {
    # Check for common user mistake
    die 'Options to LJ::Light::UserInfo->new should be key/value pairs, not hash reference'
        if ref( $_[1] ) eq 'HASH'; 
 
	my ( $class, %options )	= @_;

	my $self = bless {
		ua	=> delete $options{ua},
	}, $class;

	return $self;
}

sub get_userid {
	die 'Options to LJ::Light::UserInfo->get_userid should be key/value pairs, not hash reference'
        if ref( $_[1] ) eq 'HASH'; 

	my ( $self, %options ) = @_;

	if ( $options{mode} eq 'www' ) {
		my $userid = _get_userid_www(
			$self->{ua},
			$options{url},
			$options{poster},
		);
		return $userid;
	}
	elsif ( $options{mode} eq 'flat' ) {
		my $userid = _get_userid_flat(
			$self->{ua},
			$options{url},
			$options{poster},
		);
		return $userid;
	}
	else { die 'You must specify "mode" to call get_userid' }
}

sub _get_userid_www {
	my $ua			= shift;
	my $url			= shift;
	my $username	= shift;

	my $response = $ua->get( 
		$url . $username,
	);
	die( $response->status_line )
		unless $response->is_success;

	my $userid = $1 if (
		$response->decoded_content =~ m{\(#(\d+)\)}
	);

	return $userid;
}

sub _get_userid_flat {
	# Dummy
	# Can't get user id via flat protocol
}

1;
