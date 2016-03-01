# NAME

    LJ::Light - primitive perl module for access Live Journal flat API.

# DESCRIPTION

    The C<LJ::Light> is a class implementing for Livejorunal flat API client.
    In normal use the application creates an C<LJ::Light> object, and then configures it with values for
    default UserAgent (via C<LWP::UserAgent>), url to LJ flat interface, etc. 
    There are methods for: authorisation, getting user info, search user posts in specified journals.

# SYNOPSIS

    use LJ::Light;
    my $lj_client = LJ::Light->new(
       login       => 'test', # login on your LiveJournal account
       pass        => 'test', # password on your LiveJournal account
        # OR md5 hash of your password
       hpass       => '098f6bcd4621d373cade4e832627b4f6',
    );

# TODO

    [ ] make 'session' auth method for Events.pm
    [ ] make "friends_all, friend_of, friends_mutual, friends_no_mutual" methods

# METHODS

- new

        my $lj_client = LJ::Light->new(
           login       => 'test', # login on your LiveJournal account
           pass        => 'test', # password on your LiveJournal account
            # OR md5 hash of your password
           hpass       => '098f6bcd4621d373cade4e832627b4f6',
        );

- auth

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

- get\_userinfo

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

- events

        my $lj_events = $lj_client->events;

        $lj_events->get_entries_by_poster
        # hashref to raw parsed flat response with user entries in specified journal
        my $entries_in_journal = $lj_auth->get_entries_by_poster(
           show_posts_cnt   => 5, # num of last posts count to search, max = 50
           target_community => 'ru-perl', # name of journal to search
           poster           => $user_info->{id}, # user ID, which records to search
           auth             => $lj_client->auth->challenge, # auth response
        );

# DEPENDENCIES

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

# EXAMPLES

# AUTHOR

    dimio (http://dimio.org)

# SEE ALSO

- Live Journal flat server protocol:
 http://www.livejournal.com/doc/server/ljp.csp.flat.protocol.html
- Live Journal source archive:
 https://github.com/apparentlymart/livejournal
- More Live Journal services:
 http://dimio.org/lj-tools
