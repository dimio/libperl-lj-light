package LJ::Light::Events;

use vars qw( $VERSION );
$VERSION = '0.1.0';

require 5.008_008;
require LJ::Light::ParseFlat;
use warnings;
use strict;
use utf8;

sub new {
    # Check for common user mistake
    die 'Options to LJ::Light::Events->new should be key/value pairs, not hash reference'
        if ref( $_[1] ) eq 'HASH'; 
 
	my ( $class, %options )	= @_;
	
	my $flat_parser			= LJ::Light::ParseFlat->new;

	my $self = bless {
		ua		=> delete $options{ua},
		url		=> delete $options{url},
		login	=> delete $options{login},
		flparse	=> $flat_parser,
	}, $class;

	return $self;
}

sub get_entries_by_poster {
    die 'Options to LJ::Light::Events->get_entries_by_poster should be key/value pairs, not hash reference'
        if ref( $_[1] ) eq 'HASH'; 
 
	my ( $self, %options )	= @_;

	my $response = $self->{ua}->post( 
		$self->{url},
		Content => {
			mode			=> 'getevents',

			user			=> $self->{login},
			auth_method		=> 'challenge',
			auth_challenge	=> $options{auth}->{challenge},
			auth_response	=> $options{auth}->{auth_response},

			truncate		=> '50',
			howmany			=> $options{show_posts_cnt},
			notags			=> '1',
			selecttype		=> 'lastn',
			usejournal		=> $options{target_community},
			posterid		=> $options{poster},
		},
	);
	die( $response->status_line )
		unless $response->is_success;

	my $response_parsed = $self->{flparse}->parse_flatresponse( $response->decoded_content );

	return $response_parsed;
}

1;
