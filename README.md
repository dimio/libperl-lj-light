# NAME

    LJ::Light

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

    This method returns a requested auth information.
     my $auth\_challenge = $challenge\_auth\_response->{challenge};
     my $auth\_response = $challenge\_auth\_response->{auth\_response};
     my $ljsession = $session\_auth\_response;

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
     $user\_info->{id}; # scalar
     $user\_info->{friends}; # arrayref
     $user\_info->{friendof}; # arrayref

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

- Live Journal flat server protocol
 http://www.livejournal.com/doc/server/ljp.csp.flat.protocol.html
- Live Journal source archive
 https://github.com/apparentlymart/livejournal
