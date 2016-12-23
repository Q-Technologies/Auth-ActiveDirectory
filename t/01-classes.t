#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More tests => 26;

use_ok('Auth::ActiveDirectory')        || print "Bail out!\n";
use_ok('Auth::ActiveDirectory::User')  || print "Bail out!\n";
use_ok('Auth::ActiveDirectory::Group') || print "Bail out!\n";

my $obj = new_ok( 'Auth::ActiveDirectory' => [ 'host', '127.0.0.1', 'port', 389, 'timeout', 60, 'domain', 'somedomain', 'principal', 'someprinzipal' ] );
is( $obj->domain,                            'somedomain' );
is( $obj->host,                              '127.0.0.1', );
is( $obj->port,                              389, );
is( $obj->principal,                         'someprinzipal' );
is( $obj->timeout,                           60 );
is( $obj->domain('someotheruser@somewhere'), 'someotheruser@somewhere' );
is( $obj->host('someotheruser'),             'someotheruser' );
is( $obj->port(388),                         388 );
is( $obj->principal('someother'),            'someother' );
is( $obj->timeout(120),                      120 );

$obj = new_ok( 'Auth::ActiveDirectory::Group' => [ 'name', 'new Test' ] );
is( $obj->name,         'new Test' );
is( $obj->name('test'), 'test' );

$obj = new_ok(
    'Auth::ActiveDirectory::User' => [
        uid       => 'someuser@somewhere',
        firstname => 'firstname',
        surname   => 'surname',
        groups    => [ Auth::ActiveDirectory::Group->new( name => 'Group 1' ), Auth::ActiveDirectory::Group->new( name => 'Group 2' ), ],
        user      => 'someuser',
    ]
);

is( $obj->uid,                            'someuser@somewhere' );
is( $obj->firstname,                      'firstname', );
is( $obj->surname,                        'surname', );
is( $obj->user,                           'someuser' );
is( $obj->uid('someotheruser@somewhere'), 'someotheruser@somewhere' );
is( $obj->firstname('someotheruser'),     'someotheruser' );
is( $obj->surname('other'),               'other' );
is( $obj->user('someother'),              'someother' );
