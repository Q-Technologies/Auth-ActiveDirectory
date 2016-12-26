#!perl -T
use strict;
use warnings;
use Test::More tests => 1;
use Test::Net::LDAP;
use Test::Net::LDAP::Mock;
use Test::Net::LDAP::Util qw(ldap_mockify);
use Auth::ActiveDirectory;

use DDP;

Test::Net::LDAP::Mock->mock_target('ldap://127.0.0.1:389');
Test::Net::LDAP::Mock->mock_target(
    'localhost',
    port   => 389,
    schema => 'ldap'
);

my $ldap = Test::Net::LDAP::Mock->new( '127.0.0.1', 389 );

$ldap->add( 'uid=user1, ou=person, dc=example, dc=com', 'password1' );
$ldap->add( 'uid=user2, ou=person, dc=example, dc=com', 'password2' );
$ldap->add( 'uid=user3, ou=person, dc=example, dc=com', 'password3' );

$ldap->add(
    'cn=group1, ou=groups, dc=example, dc=com',
    attrs => [
        member => [ 'uid=user1, ou=person, dc=example, dc=com', 'uid=user2, ou=person, dc=example, dc=com', ]
    ]
);

$ldap->add(
    'cn=group2, ou=groups, dc=example, dc=com',
    attrs => [
        member => [ 'uid=user2, ou=person, dc=example, dc=com', 'uid=user3, ou=person, dc=example, dc=com', ]
    ]
);

$ldap->add(
    'cn=group3, ou=groups, dc=example, dc=com',
    attrs => [
        member => [ 'uid=user3, ou=person, dc=example, dc=com', 'uid=user1, ou=person, dc=example, dc=com', ]
    ]
);
no warnings 'redefine';

sub ldap {
    my $self = shift;
    return $ldap;
}

my $obj = Auth::ActiveDirectory->new(
    ldap      => ldap(),
    domain    => 'example',
    principal => 'com',
);

my $user = $obj->authenticate( 'user1', 'password1' );
#p $user;

