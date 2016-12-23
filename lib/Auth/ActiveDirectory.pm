package Auth::ActiveDirectory;

=head1 NAME

Auth::ActiveDirectory - Authentication module for MS ActiveDirectory

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use 5.18.0;
use strict;
use warnings FATAL => 'all';
use Carp;
use Net::LDAP qw[];
use Net::LDAP::Constant qw[LDAP_INVALID_CREDENTIALS];
my $ErrorCodes = {
    '525' => { error => 'user not found' },
    '52e' => { error => 'invalid credentials' },
    '530' => { error => 'not permitted to logon at this time' },
    '531' => { error => 'not permitted to logon at this workstation' },
    '532' => { error => 'password expired' },
    '533' => { error => 'data 533' },
    '701' => { error => 'account expired' },
    '773' => { error => 'user must reset password' },
    '775' => { error => 'user account locked' },
    '534' => {
        error       => 'account disabled',
        description => 'The user has not been granted the requested logon type at this machine'
    },
};

=head1 SUBROUTINES/METHODS

=cut

{

=head2 _create_connection

=cut

    sub _create_connection {
        my ( $host, $port, $timeout ) = @_;
        return Net::LDAP->new( $host, port => $port || 389, timeout => $timeout || 60 ) || sub {
            cluck(qq/Failed to connect to '$host'. Reason: '$@'/);
            return undef;
        };
    }

=head2 _v_is_error

=cut

    sub _v_is_error {
        my ( $message, $s_user ) = @_;
        return 0 if ( !$message->is_error );
        my $error = $message->error;
        my $level = $message->code == LDAP_INVALID_CREDENTIALS ? 'debug' : 'error';
        cluck(qq/Failed to authenticate user '$s_user'. Reason: '$error'/);
        return 1;
    }

=head2 _parse_error_message

=cut

    sub _parse_error_message {
        my ($message)   = @_;
        my ($errorcode) = $message->{errorMessage} =~ m/(?:data\s(.*)),/;
        return $ErrorCodes->{$errorcode};
    }

}

=head2 authenticate

Basicaly the subroutine for authentication in the ActiveDirectory

=cut

sub authenticate {
    my ( $stg, $s_username, $s_auth_password ) = @_;
    my $connection = _create_connection( $stg->{host}, $stg->{port}, $stg->{timeout} ) || return undef;
    my $s_user = sprintf( '%s@%s', $s_username, $s_principal );
    my $message = $connection->bind( $s_user, password => $s_auth_password );
    return _parse_error_message($message) if ( _v_is_error( $message, $s_user ) );
    my $s_domain = $stg->{domain};
    my $result   = $connection->search(    # perform a search
        base   => qq/dc=$s_principal,dc=$s_domain/,
        filter => qq/(&(objectClass=person)(userPrincipalName=$s_user.$s_domain))/,
    );
    foreach ( $result->entries ) {
        my $groups = [];
        foreach my $group ( $_->get_value(q/memberOf/) ) {
            push( @$groups, $1 ) if ( $group =~ m/^CN=(.*),OU=.*$/ );
        }
        return {
            uid       => $s_username,
            firstname => $_->get_value(q/givenName/),
            surname   => $_->get_value(q/sn/),
            groups    => $groups,
            user      => $s_user,
        };
    }
    return undef;
}

=head2 list_users

=cut

sub _list_users {
    my ( $stg, $o_session_user, $search_string ) = @_;
    my $connection = _create_connection( $stg->{host}, $stg->{port}, $stg->{timeout} ) || return undef;
    my $s_user     = $o_session_user->{user};
    my $message    = $connection->bind( $s_user, password => $o_session_user->{password} );

    return undef if ( _v_is_error( $message, $s_user ) );
    my $s_principal = $stg->{principal};
    my $s_domain    = $stg->{domain};
    my $result      = $connection->search(
        base   => qq/dc=$s_principal,dc=$s_domain/,
        filter => qq/(&(objectClass=person)(name=$search_string*))/,
    );
    my $return_names = [];
    push( @$return_names, { name => $_->get_value(q/name/), uid => $_->get_value(q/sAMAccountName/), } ) foreach ( $result->entries );
    return $return_names;
}

1;    # Auth::ActiveDirectory

__END__

=head1 SYNOPSIS

=head1 AUTHOR

Mario Zieschang, C<< <mziescha at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-Auth-ActiveDirectory at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Auth-ActiveDirectory>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 MOTIVATION

If you have a run in programming you don't always notice all packages in this moment.
And later when someone will know which packages are used, it's not neccessary to look at all of the packages.

Usefull for the Makefile.PL or Build.PL.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Auth::ActiveDirectory


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Auth-ActiveDirectory>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Auth-ActiveDirectory>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Auth-ActiveDirectory>

=item * Search CPAN

L<http://search.cpan.org/dist/Auth-ActiveDirectory/>

=back

=head1 ACKNOWLEDGEMENTS

=head1 LICENSE AND COPYRIGHT

Copyright 2015 Mario Zieschang.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut
