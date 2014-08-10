package WWW::StatsMix;

$WWW::StatsMix::VERSION = '0.01';

use 5.006;
use JSON;
use Data::Dumper;

use WWW::StatsMix::UserAgent;
use WWW::StatsMix::Stat;
use WWW::StatsMix::Metric;

use Moo;
use namespace::clean;
extends 'WWW::StatsMix::UserAgent';

=head1 NAME

WWW::StatsMix - Interface to StatsMix API.

=head1 VERSION

Version 0.01

=cut

has metrics_url => (is => 'ro', default => sub { return 'http://api.statsmix.com/api/v2/metrics' });
has stats_url   => (is => 'ro', default => sub { return 'http://api.statsmix.com/api/v2/stats'   });
has track_url   => (is => 'ro', default => sub { return 'http://api.statsmix.com/api/v2/track'   });

=head1 DESCRIPTION

L<WWW::StatsMix> provides suite to to track, chart,  and share all your important
metrics. The API is part of Copper.io - a full stact set of developer tools.  For
more details about the API L<click here|http://www.statsmix.com/developers/documentation>.

=head1 METHODS

=head2 create_metric()

=cut

sub create_metric {
}

=head2 update_metric()

=cut

sub update_metric {
}

=head2 get_metrics()

=cut

sub get_metrics {
}

=head2 create_stat()

- Create a stat with a reference id (REF_ID).
- Create a stat with metadata and custom timestamp (POST)

=cut

sub create_stat {
}

=head2 update_stat()

- Update stat using stat_id (GET)
- Update stat using ref_id (GET)

=cut

sub update_stat {
}


=head2 delete_stat()

- Delete stat using stat_id (GET)
- Delete stat using ref_id (GET)

=cut

sub delete_stat {
}

=head2 get_stats()

- Show a stat using stat_id (GET)
- Show a stat using ref_id (GET)

=cut

sub get_stats {
}

=head1 Author

Mohammad S Anwar, C<< <mohammad.anwar at yahoo.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-www-statsmix at rt.cpan.org>,
or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-StatsMix>.
I will be notified, and then you'll automatically be notified of progress on your
bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::StatsMix

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WWW-StatsMix>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WWW-StatsMix>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WWW-StatsMix>

=item * Search CPAN

L<http://search.cpan.org/dist/WWW-StatsMix/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2014 Mohammad S Anwar.

This  program  is  free software; you can redistribute it and/or modify it under
the  terms  of the the Artistic License (2.0). You may obtain a copy of the full
license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any  use,  modification, and distribution of the Standard or Modified Versions is
governed by this Artistic License.By using, modifying or distributing the Package,
you accept this license. Do not use, modify, or distribute the Package, if you do
not accept this license.

If your Modified Version has been derived from a Modified Version made by someone
other than you,you are nevertheless required to ensure that your Modified Version
 complies with the requirements of this license.

This  license  does  not grant you the right to use any trademark,  service mark,
tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge patent license
to make,  have made, use,  offer to sell, sell, import and otherwise transfer the
Package with respect to any patent claims licensable by the Copyright Holder that
are  necessarily  infringed  by  the  Package. If you institute patent litigation
(including  a  cross-claim  or  counterclaim) against any party alleging that the
Package constitutes direct or contributory patent infringement,then this Artistic
License to you shall terminate on the date that such litigation is filed.

Disclaimer  of  Warranty:  THE  PACKAGE  IS  PROVIDED BY THE COPYRIGHT HOLDER AND
CONTRIBUTORS  "AS IS'  AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES. THE IMPLIED
WARRANTIES    OF   MERCHANTABILITY,   FITNESS   FOR   A   PARTICULAR  PURPOSE, OR
NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY YOUR LOCAL LAW. UNLESS
REQUIRED BY LAW, NO COPYRIGHT HOLDER OR CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL,  OR CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE
OF THE PACKAGE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut

1; # End of WWW::StatsMix
