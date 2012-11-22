#!/usr/bin/env perl

use strict;
use warnings;
use Config::JFDI;
use FindBin;
use MIME::Lite;
use Try::Tiny;
use WWW::Mechanize;

my $CONFIG = Config::JFDI->new(name => "login_dyndns_org", path => "$FindBin::Bin/../etc");
my $DEBUG  = $CONFIG->config->{debug};

try {
    my $top = "https://www.dyndns.com/account/entrance/";
    my $mech = WWW::Mechanize->new();
    $mech->agent_alias( 'Windows IE 6' );
    $mech->get( $top );
    for ($mech->forms) {
        if ($mech->attr('id') =~ m/^login\b/) {
            $mech->form_id($mech->attr('id'));
            last;
        }
    }
    $mech->submit_form(
        with_fields => {
            username => $CONFIG->config->{username},
            password => $CONFIG->config->{password},
        },
    );
    die sprintf("login failed. %s", $mech->content) unless $mech->content =~ m/Welcome/i;
}
catch {
    my $msg = MIME::Lite->new(
        From    => $CONFIG->config->{mail_from},
        To      => $CONFIG->config->{mail_to},
        Subject => '[login_dyndns_org.pl] exception error',
        Data    => $_ || "unknow error",
    );
    $msg->send;
    exit 1;
};

if ($DEBUG) {
    my $msg = MIME::Lite->new(
        From    => $CONFIG->config->{mail_from},
        To      => $CONFIG->config->{mail_to},
        Subject => '[login_dyndns_org.pl] login succeeded',
        Data    => 'login succeeded',
    );
    $msg->send;
}

exit 0;
