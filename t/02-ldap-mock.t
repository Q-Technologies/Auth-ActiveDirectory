use strict;
use warnings;
use Test::More tests => 9;
use Test::Net::LDAP;
use Test::Net::LDAP::Mock;
use Test::Net::LDAP::Util qw(ldap_mockify);
use Auth::ActiveDirectory;

Test::Net::LDAP::Mock->mock_target('ldap://127.0.0.1:389');
Test::Net::LDAP::Mock->mock_target(
    'localhost',
    port   => 389,
    schema => 'ldap'
);

my $ldap = Test::Net::LDAP::Mock->new( '127.0.0.1', 389 );

$ldap->add(
    'CN=Mario Zieschang,OU=mziescha,OU=users,OU=developers,DC=example,DC=org',
    attrs => [
        objectClass       => [ "top", "person", "organizationalPerson", "user" ],
        cn                => "Mario Zieschang",
        sn                => "Zieschang",
        description       => "Operations",
        givenName         => "Mario",
        distinguishedName => "CN=Mario Zieschang,OU=users,OU=developers,DC=example,DC=org",
        displayName       => "Mario Zieschang",
        memberOf          => [
            "CN=dockers,OU=Gruppen,DC=example,DC=org",    "CN=admin,OU=Gruppen,DC=example,DC=org",
            "CN=Operations,OU=Gruppen,DC=example,DC=org", "CN=developers,OU=Gruppen,DC=example,DC=org"
        ],
        name                  => "Mario Zieschang",
        homeDrive             => "G:",
        sAMAccountName        => "mziescha",
        userPrincipalName     => 'mziescha@example.org',
        objectCategory        => "CN=Person,CN=Schema,CN=Configuration,DC=example,DC=org",
        mail                  => 'mziescha@cpan.org',
    ]
);

my $obj = Auth::ActiveDirectory->new( ldap => $ldap, domain => 'example', principal => 'org', );
my $user = $obj->authenticate( 'mziescha', 'password1' );

is( $user->firstname, 'Mario' );
is( $user->surname,   'Zieschang' );
is( $user->uid,       'mziescha' );
is( $user->mail,      'mziescha@cpan.org' );

is( scalar @{ $user->groups }, 4 );
ok( defined $_->name, 'Group name should be defined' ) foreach @{ $user->groups };
