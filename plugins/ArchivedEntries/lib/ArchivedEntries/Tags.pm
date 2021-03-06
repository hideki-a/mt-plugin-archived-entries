package ArchivedEntries::Tags;
use strict;
use MT::Entry;
use MT::Placement;

sub _hdlr_archived_entries {
    my ($ctx, $args, $cond) = @_;

    my ($sec, $min, $hour, $day, $month, $year, $wday, $yday, $isdst) = localtime(time);
    $year += 1900;
    $month += 1;

    my @entries = ();

    if ($day > 1) {
        my $start = sprintf "%4d%02d01000000", $year, $month;
        my $end   = sprintf "%4d%02d%02d235959", $year, $month, $day - 1;
        my $blog = $ctx->stash('blog');
        my $category_id = $args->{ category_id } || '';
        my %load_args;

        if ($category_id) {
            $load_args{ join } = MT::Placement->join_on(
                                        'entry_id',
                                        { category_id => $category_id },
                                        { unique => 1 }
                                    );
        }

        $load_args{ range_incl } = { authored_on => 1 };
        $load_args{ sort } = 'authored_on';
        $load_args{ direction } = 'descend';

        @entries = MT::Entry->load(
            {   blog_id     => $blog->id,
                status      => MT::Entry::RELEASE(),
                authored_on => [ $start, $end ],
            },
            \%load_args
        );
    }

    local $ctx->{__stash}{entries} = \@entries;
    return $ctx->invoke_handler('entries', $args, $cond);
}

1;
