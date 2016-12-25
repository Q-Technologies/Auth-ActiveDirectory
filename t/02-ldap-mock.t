#!perl -T
use strict;
use warnings;
use Test::More tests => 1;
use Test::Net::LDAP;
use Test::Net::LDAP::Mock;
use Test::Net::LDAP::Util qw(ldap_mockify);

use DDP;

Test::Net::LDAP::Mock->mock_target('ldap://127.0.0.1:389');
Test::Net::LDAP::Mock->mock_target(
    'localhost',
    port   => 389,
    schema => 'ldap'
);

BEGIN {
    my $ldap = Test::Net::LDAP::Mock->new( '127.0.0.1', 389 );

    $ldap->add( 'uid=user1, ou=users, dc=example, dc=com', 'password1' );
    $ldap->add( 'uid=user2, ou=users, dc=example, dc=com', 'password2' );
    $ldap->add(
        'cn=group1, ou=groups, dc=example, dc=com',
        attrs => [
            member => [ 'uid=user1, ou=users, dc=example, dc=com', 'uid=user2, ou=users, dc=example, dc=com', ]
        ]
    );

    no warnings 'redefine';

    sub ldap {
        my $self = shift;
        return $ldap;
    }
}

{

    package TestApp;
    use Auth::ActiveDirectory;

    my $obj = Auth::ActiveDirectory->new(
        ldap      => ldap(),
        domain    => 'example',
        principal => 'com',
    );

    my $user = $obj->authenticate( 'user1', 'password1' );
    use DDP;
    p $user;

}
