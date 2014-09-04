package WWW::StatsMix;

$WWW::StatsMix::VERSION = '0.01';

use 5.006;
use JSON;
use Data::Dumper;

use WWW::StatsMix::Stat;
use WWW::StatsMix::Metric;
use WWW::StatsMix::UserAgent;

use Moo;
use namespace::clean;
extends 'WWW::StatsMix::UserAgent';

=head1 NAME

WWW::StatsMix - Interface to StatsMix API.

=head1 VERSION

Version 0.01

=cut

has format      => (is => 'ro', default => sub { return 'json' });
has metrics_url => (is => 'ro', default => sub { return 'http://api.statsmix.com/api/v2/metrics' });
has stats_url   => (is => 'ro', default => sub { return 'http://api.statsmix.com/api/v2/stats'   });
has track_url   => (is => 'ro', default => sub { return 'http://api.statsmix.com/api/v2/track'   });

=head1 DESCRIPTION

L<WWW::StatsMix> provides suite to to track, chart,  and share all your important
metrics. The API is part of Copper.io - a full stact set of developer tools.  For
more details about the API L<click here|http://www.statsmix.com/developers/documentation>.

=head1 SYNOPSIS

    use strict; use warnings;
    use WWW::StatsMix;

    my $API_KEY = "Your API Key";
    my $api = WWW::StatsMix->new(api_key => $API_KEY);

    my $metric_1 = $api->create_metric({ name => "Testing - 1" });
    my $metric_2 = $api->create_metric({ name => "Testing - 2", include_in_email => 0 });
    $api->update_metric($metric_2->id, { name => "Testing - 3", include_in_email => 1 });

    my $metrics  = $api->get_metrics;
    my $only_2   = $api->get_metrics({ limit => 2 });

=head1 METHODS

=head2 create_metric()

Creates new metric. Possible parameters for the method are as below:

   +------------------+-----------------------------------------------------------------------+
   | Key              | Description                                                           |
   +------------------+-----------------------------------------------------------------------+
   | name             | The name of the metric. Metric names must be unique within a profile. |
   |                  |                                                                       |
   | profile_id       | The profile the metric belongs in.                                    |
   |                  |                                                                       |
   | sharing          | Sharing status for the metric. Either "public" (unauthenticated users |
   |                  | can view the metric at the specific URL) or "none" (default).         |
   |                  |                                                                       |
   | include_in_email | This specifies whether to include the metric in the daily             |
   |                  | StatsMix email sent to users.                                         |
   |                  |                                                                       |
   | url              | Publicly accessible URL for the metric (only if sharing is set        |
   |                  | to "public").                                                         |
   +------------------+-----------------------------------------------------------------------+

=cut

sub create_metric {
    my ($self, $params) = @_;

    $params->{format} = $self->format;
    my $response = $self->post($self->metrics_url, [ %$params ]);
    my $content  = from_json($response->content);

    return WWW::StatsMix::Metric->new($content->{metric});
}

=head2 update_metric()

Updates the metric. Possible parameters for the method are as below:

   +------------------+-----------------------------------------------------------------------+
   | Key              | Description                                                           |
   +------------------+-----------------------------------------------------------------------+
   | name             | The name of the metric. Metric names must be unique within a profile. |
   |                  |                                                                       |
   | profile_id       | The profile the metric belongs in.                                    |
   |                  |                                                                       |
   | sharing          | Sharing status for the metric. Either "public" (unauthenticated users |
   |                  | can view the metric at the specific URL) or "none" (default).         |
   |                  |                                                                       |
   | include_in_email | This specifies whether to include the metric in the daily             |
   |                  | StatsMix email sent to users.                                         |
   |                  |                                                                       |
   | url              | Publicly accessible URL for the metric (only if sharing is set        |
   |                  | to "public").                                                         |
   +------------------+-----------------------------------------------------------------------+

=cut

sub update_metric {
    my ($self, $id, $params) = @_;

    my $url      = sprintf("%s/%d.json", $self->metrics_url, $id);
    my $response = $self->put($url, [ %$params ]);
    my $content  = from_json($response->content);

    return WWW::StatsMix::Metric->new($content->{metric});
}

=head2 delete_metric()

Delete the metric. Possible parameters for the method are as below:

   +-----------+----------------------------------------+
   | Key       | Description                            |
   +-----------+----------------------------------------+
   |           |                                        |
   | metric_id | The metric id that you want to delete. |
   |           |                                        |
   +-----------+----------------------------------------+

=cut

sub delete_metric {
    my ($self, $id) = @_;

    my $url      = sprintf("%s/%d.json", $self->metrics_url, $id);
    my $response = $self->delete($url);
    my $content  = from_json($response->content);

    return WWW::StatsMix::Metric->new($content->{metric});
}

=head2 get_metrics()

The method get_metrics() will return a default of up to 50 records. The parameter
limit  can  be  passed  to specify the number of records to return. The parameter
profile_id  can also be used to scope records to a particular profile. Parameters
start_date &  end_date can be used to limit the date range based on the timestamp
in a stat's generated_at.

   +------------+---------------------------------------------------------------+
   | Key        | Description                                                   |
   +------------+---------------------------------------------------------------+
   | limit      | Limit the number of metrics. Default is 50.                   |
   |            |                                                               |
   | profile_id | Scope the search to a particular profile.                     |
   |            |                                                               |
   | start_date | Limit the searh in date range against stats generated_at key. |
   | / end_date |                                                               |
   +------------+---------------------------------------------------------------+

=cut

sub get_metrics {
    my ($self, $params) = @_;

    my $url = sprintf("%s?format=%s", $self->metrics_url, $self->format);
    foreach (qw(limit profile_id start_date end_date)) {
        if (exists $params->{$_}) {
            $url .= sprintf("&%s=%s", $_, $params->{$_});
        }
    }

    my $response = $self->get($url);
    my $content  = from_json($response->content);

    return _get_metrics($content);
}

=head2 create_stat()

The  method  create_stat() creates stat for the given metric. You can also create
stat with ref_id.

   +--------------+---------------------------------------------------------------+
   | Key          | Description                                                   |
   +--------------+---------------------------------------------------------------+
   | metric_id    | The metric id for which the stat would be created (required). |
   |              |                                                               |
   | value        | The value for the stat (required).                            |
   |              |                                                               |
   | ref_id       | Stat can be assigned ref if (optionally).                     |
   |              |                                                               |
   | generated_at | Can be assigned generated at time stamp (optionally)          |
   |              |                                                               |
   +--------------+---------------------------------------------------------------+

=cut

sub create_stat {
    my ($self, $params) = @_;

    $params->{format} = $self->format;
    my $response = $self->post($self->stats_url, [ %$params ]);
    my $content  = from_json($response->content);

    return WWW::StatsMix::Stat->new($content->{stat});
}

=head2 get_stat()

Get the stat of the metric. Stat can be located by stat id or ref id.  parameters
for the method are as below:

   +-----------+-------------------------------------+
   | Key       | Description                         |
   +-----------+-------------------------------------+
   | metric_id | The id of the metric (required).    |
   |           |                                     |
   | id        | The stat id of the stat (optional). |
   |           |                                     |
   | ref_id    | Ref id of the stat (optional).      |
   +-----------+-------------------------------------+

=cut

sub get_stat {
    my ($self, $metric, $params) = @_;

    my $id       = _get_id($params);
    my $url      = sprintf("%s/%d.json?metric_id=%d", $self->stats_url, $id, $metric);
    my $response = $self->get($url);
    my $content  = from_json($response->content);

    return WWW::StatsMix::Stat->new($content->{stat});
}

=head2 update_stat()

Update the stat of the metric.Stat can be located by stat id or ref id.Parameters
for the method are as below:

   +-----------+-------------------------------------+
   | Key       | Description                         |
   +-----------+-------------------------------------+
   | metric_id | The id of the metric (required).    |
   |           |                                     |
   | value     | The stat value (required).          |
   |           |                                     |
   | id        | The stat id of the stat (optional). |
   |           |                                     |
   | ref_id    | Ref id of the stat (optional).      |
   +-----------+-------------------------------------+

=cut

sub update_stat {
    my ($self, $metric, $params) = @_;

    my $id       = _get_id($params);
    my $value    = _get_value($params);
    my $data     = { metric_id => $metric, value => $value };
    my $url      = sprintf("%s/%d.json", $self->stats_url, $id);
    my $response = $self->put($url, [ %$data ]);
    my $content  = from_json($response->content);

    return WWW::StatsMix::Stat->new($content->{stat});
}

=head2 delete_stat()

Delete the stat of the metric.Stat can be located by stat id or ref id.Parameters
for the method are as below:

   +-----------+-------------------------------------+
   | Key       | Description                         |
   +-----------+-------------------------------------+
   | metric_id | The id of the metric (required).    |
   |           |                                     |
   | id        | The stat id of the stat (optional). |
   |           |                                     |
   | ref_id    | Ref id of the stat (optional).      |
   +-----------+-------------------------------------+

=cut

sub delete_stat {
    my ($self, $metric, $params) = @_;

    my $id       = _get_id($params);
    my $url      = sprintf("%s/%d.json?metric_id=%d", $self->stats_url, $id, $metric);
    my $response = $self->delete($url);
    my $content  = from_json($response->content);

    return WWW::StatsMix::Stat->new($content->{stat});
}

=head2 get_stats()

The method get_stats() will return a default of up to 50  records.  The parameter
limit  can  be  passed  to specify the number of records to return. The parameter
metric_id  can also be used to scope records to a particular profile. Parameters
start_date &  end_date can be used to limit the date range based on the timestamp
in a stat's generated_at.

   +------------+---------------------------------------------------------------+
   | Key        | Description                                                   |
   +------------+---------------------------------------------------------------+
   | limit      | Limit the number of metrics. Default is 50.                   |
   |            |                                                               |
   | metric_id  | Scope the search to a particular metric.                      |
   |            |                                                               |
   | start_date | Limit the searh in date range against stats generated_at key. |
   | / end_date |                                                               |
   +------------+---------------------------------------------------------------+

=cut

sub get_stats {
    my ($self, $params) = @_;

    my $url = sprintf("%s?format=%s", $self->stats_url, $self->format);
    foreach (qw(limit metric_id start_date end_date)) {
        if (exists $params->{$_}) {
            $url .= sprintf("&%s=%s", $_, $params->{$_});
        }
    }

    my $response = $self->get($url);
    my $content  = from_json($response->content);

    return _get_stats($content);
}

# PRIVATE METHODS
#
#

sub _get_id {
    my ($params) = @_;

    if (defined $params) {
        if (exists $params->{id}) {
            return $params->{id};
        }
        elsif (exists $params->{ref_id}) {
            return $params->{ref_id};
        }
    }

    die "Missing required key id/ref_id";
}

sub _get_value {
    my ($params) = @_;

    return $params->{value}
        if (defined $params && exists $params->{value});

    die "Missing required key id/ref_id";
}

sub _get_metrics {
    my ($content) = @_;

    my $metrics = [];
    foreach (@{$content->{metrics}->{metric}}) {
        push @$metrics, WWW::StatsMix::Metric->new($_);
    }

    return $metrics;
}

sub _get_stats {
    my ($content) = @_;

    my $stats = [];
    foreach (@{$content->{stats}->{stat}}) {
        push @$stats, WWW::StatsMix::Stat->new($_);
    }

    return $stats;
}

sub _now_yyyy_mm_dd_hh_mi_ss {
    my ($sec,$min,$hour,$mday,$mon,$year) = localtime(time);
    return sprintf("%04d-%02d-%02d %02d:%02d:%02d", $year+=1900, ++$mon, $mday, $hour, $min, $sec);
}

sub _now_yyyy_mm_dd {
    my ($sec,$min,$hour,$mday,$mon,$year) = localtime(time);
    return sprintf("%04d-%02d-%02d", $year+=1900, ++$mon, $mday);
}

=head1 Author

Mohammad S Anwar, C<< <mohammad.anwar at yahoo.com> >>

=head1 REPOSITORY

L<https://github.com/Manwar/WWW-StatsMix>

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
