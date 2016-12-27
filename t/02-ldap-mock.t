use strict;
use warnings;
use Test::More tests => 4;
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

$ldap->add(
    'uid=user1, cn=Mario Zieschang, ou=Zieschang, dc=example, dc=com',
    attrs => [
        memberOf => [
            "CN=dockers,OU=groups,DC=example,DC=com",                    "CN=dev-exchange_change,OU=groups,DC=example,DC=com",
            "CN=ad-jira-users_change,OU=groups,DC=example,DC=com",       "CN=ad-confluence-it_change,OU=groups,DC=example,DC=com",
            "CN=ad-confluence-users_change,OU=groups,DC=example,DC=com", "CN=developers,OU=groups,DC=example,DC=com",
        ],
        objectClass       => 'person',
        userPrincipalName => 'user1@example.com',
        givenName         => 'Mario',
        sn                => 'Zieschang',
    ]
);

$ldap->add(
    'cn=Dominic Sonntag, ou=groups, dc=example, dc=com',
    attrs => [
        memberOf => [
            "CN=dockers,OU=groups,DC=example,DC=com",                    "CN=dev-exchange_change,OU=groups,DC=example,DC=com",
            "CN=ad-jira-users_change,OU=groups,DC=example,DC=com",       "CN=ad-confluence-it_change,OU=groups,DC=example,DC=com",
            "CN=ad-confluence-users_change,OU=groups,DC=example,DC=com", "CN=developers,OU=groups,DC=example,DC=com",
        ],
        objectClass       => 'person',
        userPrincipalName => 'user2@example.com',
        givenName         => 'Dominic',
        sn                => 'Sonntag',
    ]
);

$ldap->add(
    'cn=user 3, ou=groups, dc=example, dc=com',
    attrs => [
        memberOf => [
            "CN=dockers,OU=groups,DC=example,DC=com",                    "CN=dev-exchange_change,OU=groups,DC=example,DC=com",
            "CN=ad-jira-users_change,OU=groups,DC=example,DC=com",       "CN=ad-confluence-it_change,OU=groups,DC=example,DC=com",
            "CN=ad-confluence-users_change,OU=groups,DC=example,DC=com", "CN=developers,OU=groups,DC=example,DC=com",
        ],
        objectClass       => 'person',
        userPrincipalName => 'user3@example.com',
        givenName         => 'user3',
        sn                => '3',

    ]
);

my $obj = Auth::ActiveDirectory->new( ldap => $ldap, domain => 'example', principal => 'com', );
my $user = $obj->authenticate( 'user1', 'password1' );
is( $user->firstname,          'Mario' );
is( $user->surname,            'Zieschang' );
is( $user->uid,                'user1' );
is( scalar @{ $user->groups }, 6 );
