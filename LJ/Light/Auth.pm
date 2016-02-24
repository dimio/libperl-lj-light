package LJ::Light::Auth;

use vars qw( $VERSION );

require LJ::Light::ParseFlat;
$VERSION = "0.04";

require 5.008_008;
use warnings;
use strict;
use utf8;
use Digest::MD5;

use FindBin qw( $Bin );
use lib $Bin;


sub new {
    # Check for common user mistake
    die 'Options to LJ::Light::Auth should be key/value pairs, not hash reference'
        if ref( $_[1] ) eq 'HASH'; 
 
	my ( $class, %options )	= @_;
	
	my $options 			= \%options;
	my $flat_parser			= LJ::Light::ParseFlat->new;

	my $self = bless {
		url		=> delete $options->{url},
		ua		=> delete $options->{ua},
		login	=> delete $options->{login},
		pass	=> delete $options->{pass},
		hpass	=> delete $options->{hpass},
		flparse	=> $flat_parser,
	}, $class;

	return $self;
}

sub session {
	my $self	= shift;
	my $auth	= $self->challenge;

	my $response = $self->{ua}->post( 
		$self->{url},
		Content => {
			mode			=> 'sessiongenerate',
			user			=> $self->{login},
			auth_method		=> 'challenge',
			auth_challenge	=> $auth->{challenge},
			auth_response	=> $auth->{auth_response},
		},
	);
	die( $response->status_line )
		unless $response->is_success;

	my $response_parsed = $self->{flparse}->parse_flatresponse( $response->decoded_content );

	return $response_parsed->{ljsession};
}

sub challenge {
	my $self	= shift;
	my $auth	= {};

	$auth->{challenge} = _get_challenge( $self );

	if ( $self->{pass} ){
		$auth->{auth_response} = _make_challenge_auth(
			$self->{pass},
			$auth->{challenge},
			0,
		);
	}
	elsif ( $self->{hpass} ){
		$auth->{auth_response} = _make_challenge_auth(
			$self->{hpass},
			$auth->{challenge},
			1,
		);
	}
	else { die "You must specify account password!"; }

	return $auth;
}

sub _make_challenge_auth {
	my $pass		= shift;
	my $challenge	= shift;
	my $ishpass		= shift;

	my $md5=Digest::MD5->new;
	my $hpass;

	if ( $ishpass ){
		$hpass = $pass;
		undef $pass;
	}
	elsif ( !$ishpass ){
		$md5->add( $pass );
		$hpass = $md5->hexdigest;
		undef $pass;
	}

	$md5->add( $challenge, $hpass );
	my $auth_response = $md5->hexdigest;

	return $auth_response;
}

sub _get_challenge {
	my $self	= shift;

	my $response = $self->{ua}->post( 
		$self->{url},
		Content => {
			mode	=> 'getchallenge',
		},
	);
	die( $response->status_line )
		unless $response->is_success;

	my $response_parsed = $self->{flparse}->parse_flatresponse( $response->decoded_content );

	return $response_parsed->{challenge};
}

1;
