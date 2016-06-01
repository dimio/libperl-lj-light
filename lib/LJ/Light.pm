
=head1 NAME

 LJ::Light - primitive perl module for access Live Journal flat API.

=head1 DESCRIPTION

 The C<LJ::Light> is a class implementing for Livejorunal flat API client.
 In normal use the application creates an C<LJ::Light> object, and then configures it with values for
 default UserAgent (via C<LWP::UserAgent>), url to LJ flat interface, etc. 
 There are methods for: authorisation, getting user info, search user posts in specified journals.

=head1 SYNOPSIS

 use LJ::Light;
 my $lj_client = LJ::Light->new(
    login	=> 'test', # login on your LiveJournal account
    pass	=> 'test', # password on your LiveJournal account
     # OR md5 hash of your password
    hpass	=> '098f6bcd4621d373cade4e832627b4f6',
 );

=head1 TODO

 [ ] make 'session' auth method for Events.pm
 [ ] make "friends_all, friend_of, friends_mutual, friends_no_mutual" methods

=cut

package LJ::Light;

use vars qw( $VERSION );
$VERSION = '0.1.1';

require 5.008_008;
use warnings;
use strict;
use utf8;
use LWP::UserAgent;

use LJ::Light::Auth;
use LJ::Light::ParseFlat;
use LJ::Light::UserInfo;
use LJ::Light::Events;

my $prefs = {
    flat_url     => 'http://www.livejournal.com/interface/flat',
    base_url     => 'http://www.livejournal.com/',
    userinfo_url => 'http://www.livejournal.com/userinfo.bml?user=',
};

=head1 METHODS

=over

=item new

 my $lj_client = LJ::Light->new(
    login	=> 'test', # login on your LiveJournal account
    pass	=> 'test', # password on your LiveJournal account
     # OR md5 hash of your password
    hpass	=> '098f6bcd4621d373cade4e832627b4f6',
 );

=cut

sub new {
    die 'Options to LJ::Light should be key/value pairs, not hash reference'
        if ref( $_[1] ) eq 'HASH';

    my ( $class, %options ) = @_;

    my $self = bless {
        login => delete $options{login},
        pass  => delete $options{pass},
        hpass => delete $options{hpass},

        ua => delete $options{ua} || LWP::UserAgent->new( agent => "LJ::Light $VERSION" ),
        flat_url => delete $options{url} || $prefs->{flat_url},
    }, $class;

    return $self;
}

=item auth

 my $lj_auth = $lj_client->auth;
 my $challenge_auth_response = $lj_auth->challenge; # hashref
 my $session_auth_response = $lj_auth->session; # scalar
 # or
 my $challenge_auth_response = $lj_client->auth->challenge; # hashref
 my $session_auth_response = $lj_client->auth->session; # scalar

This method returns a requested auth information: auth challenge and auth response
if select "challenge" or value of auth cookie if select "session".

 my $auth_challenge = $challenge_auth_response->{challenge};
 my $auth_response = $challenge_auth_response->{auth_response};
 my $ljsession = $session_auth_response;

=cut

sub auth {
    my $self = shift;

    return $self->{auth} if $self->{auth};

    my $auth = LJ::Light::Auth->new(
        ua    => $self->{ua},
        url   => $self->{flat_url},
        login => $self->{login},
        pass  => $self->{pass},
        hpass => $self->{hpass},
    );
    return $self->{auth} = $auth;
}

=item get_userinfo

 my $user_info = $lj_client->get_userinfo( $username,
    [ 'id', 'friends', 'friendof', ]
 ); # hashref
 # or
 my $user_info = $lj_client->get_userinfo( $username,
    [ qw( id friends friendof ) ]
 ); # hashref
 # or
 my @infos = qw( id friends friendof );
 my $user_info = $lj_client->get_userinfo( $username, \@infos ); # hashref

This method returns a reference to a hash with requested user information.

 $user_info->{id}; # scalar
 $user_info->{friends}; # arrayref
 $user_info->{friendof}; # arrayref

=cut

sub get_userinfo {
    my $self     = shift;
    my $username = shift;
    my $infos    = shift;

    my $user_info = {};

    $self->{userinfo} = LJ::Light::UserInfo->new( ua => $self->{ua}, )
        if !$self->{userinfo};

    foreach my $info (@$infos) {
        chomp $info;

        if ( $info eq 'id' ) {
            $user_info->{$info} = $self->{userinfo}->get_userid(
                mode   => 'www',
                url    => $prefs->{userinfo_url},
                poster => $username,
            );
        }
        elsif ( $info eq 'friends' ) {
            my @dummy;
            $user_info->{$info} = \@dummy;
        }
        elsif ( $info eq 'friendof' ) {
            my @dummy;
            $user_info->{$info} = \@dummy;
        }

        # mutual, no mutual: get $self->{userinfo}->friends, ftiendof (if it is not exist)
        # and generate @mutual/@no_mutual
        else { warn "You must specified params to get_userinfo!" }
    }

    return $user_info;
}

=item events

 my $lj_events = $lj_client->events;

 $lj_events->get_entries_by_poster
 # hashref to raw parsed flat response with user entries in specified journal
 my $entries_in_journal = $lj_auth->get_entries_by_poster(
    show_posts_cnt   => 5, # num of last posts count to search, max = 50
    target_community => 'ru-perl', # name of journal to search
    poster           => $user_info->{id}, # user ID, which records to search
    auth             => $lj_client->auth->challenge, # auth response
 );

=cut

sub events {
    my $self = shift;

    return $self->{events} if $self->{events};

    my $events = LJ::Light::Events->new(
        ua    => $self->{ua},
        url   => $self->{flat_url},
        login => $self->{login},
    );
    return $self->{events} = $events;
}

1;

=back

=head1 DEPENDENCIES

 perl 5.8.8 or higher;
 warnings;
 strict;
 utf8;
 LWP::UserAgent;
 Digest::MD5;
 LJ::Light::Auth;
 LJ::Light::ParseFlat;
 LJ::Light::UserInfo;
 LJ::Light::Events;

=head1 EXAMPLES


=head1 AUTHOR

 dimio (http://dimio.org)

=head1 SEE ALSO

=over

=item Live Journal flat server protocol:
 http://www.livejournal.com/doc/server/ljp.csp.flat.protocol.html

=item Live Journal source archive:
 https://github.com/apparentlymart/livejournal

=item More Live Journal services:
 http://dimio.org/lj-tools

= item Another LJ modules:
 https://metacpan.org/pod/WebService::LiveJournal
 https://metacpan.org/pod/LJ::GetCookieSession

= item Semantic Versioning guide:
 http://semver.org/

=back

=cut
