
=head1 NAME

 LJ::Light

=head1 SYNOPSIS

 use LJ::Light;
 my $lj_client = LJ::Light->new(
    login	=> 'test', # login on your LiveJournal account
    pass	=> 'test', # password on your LiveJournal account
     # OR md5 hash of your password
    hpass	=> '098f6bcd4621d373cade4e832627b4f6',
 );

=cut

package LJ::Light;

use vars qw( $VERSION );
$VERSION = "0.04";

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

=item get_userinfo

 my $user_info = $lj_client->get_userinfo( $username,
    [ 'id', ]
 );
 # or
 my @infos = qw( id );
 my $user_info = $lj_client->get_userinfo( $username, \@infos );

This method returns a reference to a hash with requested user information.
 my $user_id = $user_info->{id};

=cut

sub get_userinfo {
    my $self     = shift;
    my $username = shift;
    my $infos    = shift;

    my $user_info = {};
    my $userinfo = LJ::Light::UserInfo->new( ua => $self->{ua}, );

    foreach my $info (@$infos) {
        chomp $info;

        if ( $info eq 'id' ) {
            $user_info->{$info} = $userinfo->get_userid(
                mode   => 'www',
                url    => $prefs->{userinfo_url},
                poster => $username,
            );
        }
        elsif ( $info eq 'friends' ) {

            # dummy
        }
        else { warn "You must specified params to get_userinfo!" }
    }

    return $user_info;
}

=back
=cut

1;
