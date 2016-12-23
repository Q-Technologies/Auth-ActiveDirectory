package Auth::ActiveDirectory::CLI;

use strict;
use warnings;
use Getopt::Long qw{:config bundling};
use Auth::ActiveDirectory;
use Pod::Usage;
use Carp qw/croak/;

=head1 NAME

Auth::ActiveDirectory::CLI - Authentication module for MS ActiveDirectory

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Quick summary of what the module does.

=head1 SUBROUTINES/METHODS

=cut

{

=head2 _h_process_command_line

Private subroutine to handle command line args.

=cut

    sub _process_command_line {
        my (%params) = @_;
        $params{'argv'} = [@ARGV];
        GetOptions(

            # command
            'h|help|?'  => \$params{help},
            'v|version' => \$params{version},

            # options
            'f|file=s'      => \$params{config},
            'u|username=s'  => \$params{username},
            'w|password=s'  => \$params{password},
            'p|principal=s' => \$params{principal},
            'd|domain=s'    => \$params{domain},
            'host=s'        => \$params{host},
            'port=s'        => \$params{port},
            'timeout=s'     => \$params{timeout},

        );
        return %params;
    }

}

=head2 run

Collection of uth::ActiveDirectory packages to run on command line.

=cut

sub run {
    my $self = shift;
    my %args = ();
    %args = _process_command_line(%args);
    if ( $args{version} ) { print __PACKAGE__, ' Verion: ', $VERSION, $/; return; }
    pod2usage( { -verbose => 1 } ) if ( $args{help} );
    croak "No host is given!"      unless $args{host};
    croak "No domain is given!"    unless $args{domain};
    croak "No principal is given!" unless $args{principal};

    my $obj = Auth::ActiveDirectory->new(
        host      => $args{host},
        port      => $args{port} || 389,
        timeout   => $args{timeout} || 60,
        domain    => $args{domain},
        principal => $args{principal},
    );
    croak "No username is given!" unless $args{username};
    croak "No password is given!" unless $args{password};
    my $user = $obj->authenticate( $args{username}, $args{password} );
    use DDP;
    p $user;
}

1;    # End of uth::ActiveDirectory::CLI

__END__

=head1 AUTHOR

Mario Zieschang, C<< <mziescha at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-auth-activedirectory at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Auth-ActiveDirectory>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




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

Copyright 2016 Mario Zieschang.

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

1; # End of Auth::ActiveDirectory
