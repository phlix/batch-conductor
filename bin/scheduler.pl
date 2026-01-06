#!/usr/bin/env perl
use strict;
use warnings;

use FindBin qw($Bin);
use File::Spec;
use File::Path qw(make_path);
use POSIX qw(strftime);

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

my $BASE_DIR    = File::Spec->catdir($Bin, '..');
my $JOB_DIR    = File::Spec->catdir($BASE_DIR, 'config', 'jobs');
my $RUN_DIR    = File::Spec->catdir($BASE_DIR, 'run');
my $STATUS_FILE = File::Spec->catfile($RUN_DIR, 'status.dat');
my $RUN_LOG     = File::Spec->catfile($RUN_DIR, 'run.log');

# ---------------------------------------------------------------------------
# Bootstrap
# ---------------------------------------------------------------------------

# Ensure run directory exists
make_path($RUN_DIR) unless -d $RUN_DIR;

# Hard safety check: run.log must never be a directory
if (-d $RUN_LOG) {
    die "FATAL: $RUN_LOG is a directory. Remove it before running the scheduler.";
}

my %status = load_status($STATUS_FILE);
my %jobs   = load_jobs($JOB_DIR);

# ---------------------------------------------------------------------------
# Scheduling
# ---------------------------------------------------------------------------

for my $job (sort keys %jobs) {

    # Already completed for this batch day
    if (exists $status{$job} && $status{$job}{state} eq 'OK') {
        log_event("$job SKIPPED (already completed)");
        next;
    }

    # Dependencies not satisfied
    next unless dependencies_satisfied($job, \%jobs, \%status);

    # Execute job
    run_job($job, $jobs{$job}, \%status);

    # Persist status only after real execution
    save_status($STATUS_FILE, \%status);
}

exit 0;

# ---------------------------------------------------------------------------
# Functions
# ---------------------------------------------------------------------------

sub load_jobs {
    my ($dir) = @_;
    my %jobs;

    return %jobs unless -d $dir;

    for my $file (glob("$dir/*.conf")) {
        open my $fh, '<', $file or die "Cannot open $file: $!";
        my $current;

        while (<$fh>) {
            chomp;
            next if /^\s*$/ || /^\s*#/;

            if (/^\[job:(.+?)\]/) {
                $current = $1;
                $jobs{$current} = {};
            }
            elsif ($current && /^(\w+)\s*=\s*(.+)$/) {
                $jobs{$current}{$1} = $2;
            }
        }
        close $fh;
    }

    return %jobs;
}

sub load_status {
    my ($file) = @_;
    my %status;

    return %status unless -f $file;

    open my $fh, '<', $file or die "Cannot open $file: $!";
    while (<$fh>) {
        chomp;
        next if /^\s*$/;

        # Supported formats:
        # job:OK
        # job|OK|timestamp
        my ($job, $state, $ts) = split /[:|]/, $_, 3;

        $status{$job} = {
            state => $state,
            ts    => $ts,   # may be undef for legacy entries
        };
    }
    close $fh;

    return %status;
}

sub save_status {
    my ($file, $status) = @_;

    open my $fh, '>', $file or die "Cannot write $file: $!";
    for my $job (sort keys %$status) {
        my $state = $status->{$job}{state};
        my $ts    = $status->{$job}{ts} // '';
        print $fh "$job|$state|$ts\n";
    }
    close $fh;
}

sub dependencies_satisfied {
    my ($job, $jobs, $status) = @_;

    my $after = $jobs->{$job}{after} or return 1;

    for my $dep (split /\s*,\s*/, $after) {
        return 0 unless exists $status->{$dep}
                     && $status->{$dep}{state} eq 'OK';
    }

    return 1;
}

sub run_job {
    my ($job, $def, $status) = @_;

    my $cmd = $def->{cmd}
      or die "Job '$job' has no cmd defined";

    print timestamp(), " running job $job\n";

    my $rc = system($cmd);

    if ($rc == 0) {
        if (!exists $status->{$job}
            || $status->{$job}{state} ne 'OK') {

            $status->{$job} = {
                state => 'OK',
                ts    => timestamp_plain(),
            };
        }
        log_event("$job OK");
    }
    else {
        $status->{$job} = {
            state => 'ERROR',
            ts    => timestamp_plain(),
        };
        log_event("$job ERROR");
    }
}

sub log_event {
    my ($msg) = @_;
    open my $fh, '>>', $RUN_LOG
      or die "Cannot write $RUN_LOG: $!";
    print $fh timestamp(), " $msg\n";
    close $fh;
}

sub timestamp {
    return strftime('[%Y-%m-%d %H:%M:%S]', localtime);
}

sub timestamp_plain {
    return strftime('%Y-%m-%d %H:%M:%S', localtime);
}

