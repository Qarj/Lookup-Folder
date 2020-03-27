#!/usr/bin/perl

# $Id$
# $Revision$
# $Date$

# perl Lookup-Folder.pl --folder ./test/*.txt --search hello --search WORLD
# perl Lookup-Folder.pl --folder ./test/*.txt --search hello --search WORLD --max_age 15
# perl Lookup-Folder.pl --folder ./test/*.txt --search hello --search WORLD --stop
# perl Lookup-Folder.pl --folder //window.server/D$/mailroot/Pickup/* --search hello
# 
# Note the direction of the slashes in the last example.

use strict;
use warnings;
use vars qw/ $VERSION /;

$VERSION = '0.7.0';

use File::Basename;
use Time::HiRes 'time';
use Getopt::Long;
use MIME::QuotedPrint; # for decoding quoted-printable
use File::Slurp;
use URI::Escape; # to convert the URL encoded search string to normal
use File::Glob qw(bsd_glob);

my (@opt_search, $opt_folder, $opt_stop, $opt_max_age, $opt_decode, $opt_version, $opt_help);

get_options();

decode_search_strings();

my $file_matches = 0;
my $files_checked = 0;
my (@files_to_check, @files_creation_time);
my $current_time = time;
print "Current Time: $current_time\n";

show_search_options();

build_list_of_files_to_check();

search_all_files();

print "\nFound $file_matches matching files out of $files_checked files searched\n";

#
# end of script - subroutines follow
#

# Build a list of files to examine in an array
sub build_list_of_files_to_check {

    my $start_time = time;

    my @raw_files = glob($opt_folder);

    my $i = 0;
    foreach (@raw_files) {
        $files_creation_time[$i] = (stat ($_))[9];
        $files_to_check[$i] = $_;
        print "$files_creation_time[$i]:$files_to_check[$i]\n";
        $i++;
    }

    # Sort the files from newest to oldest
    # This means we can stop reading the contents of files once we hit a specified age
    my @idx = sort { $files_creation_time[$b] <=> $files_creation_time[$a] } 0 .. $#files_creation_time;
    @files_creation_time = @files_creation_time[@idx];
    @files_to_check = @files_to_check[@idx];

    my $run_time = (int(1000 * (time - $start_time)) / 1000);
    print "Built file list in $run_time seconds\n";

    return;
}

# Iterate over the files
sub search_all_files {

    my $start_time = time;

    for my $i (0 .. $#files_to_check)
    {
        $files_checked = $files_checked + 1;
        print "\n["."$files_checked".'] ';

        my $file_age_mins = sprintf '%.1f', ($current_time - $files_creation_time[$i]) / 60;
        print "(age: $file_age_mins mins) ";
        if (defined $opt_max_age) {
            if ($file_age_mins > ($opt_max_age)) {
                print "$files_to_check[$i] - TOO OLD - REMAINGING FILES THIS OLD OR OLDER, STOPPING...\n";
                last;
            }
        }
        print "$files_to_check[$i]\n";

        examine_file ($files_to_check[$i]);
        if (defined $opt_stop && ($file_matches > 0) ) {
            # option to stop after first match is enabled ...
            last; # ... so do not process any more files
        }
    }

    my $run_time = (int(1000 * (time - $start_time)) / 1000);
    print "\nSearched files in $run_time seconds\n";

    return;
}

# Examine one file
sub examine_file {
    my ($filename) = @_;

    my $raw_folder = dirname($opt_folder.'dummy');

    my $text = read_file($filename);

    if (defined $opt_decode) {
        $text = decode_qp($text); ## decode the response output assuming it was quoted printable (i.e. SMTP email format)
    }

    foreach my $search (@opt_search) {

        print "    $search ... ";

        my $match = 0;

        if ($text =~ m/$search/i) {

            # search string has been found in this file
            $match = 1;

            print " FOUND\n";
        }

        if ($match) {
            # great news
        } else {
            print " not found\n";
            return; # this search string was not found in this file, so it is a fail
        }
    }

    # if we made it to here, it means all search strings were found in this file
    $file_matches = $file_matches + 1;

    print "    Success '$filename' contains all search criteria!\n";

    return;
}
#------------------------------------------------------------------
sub decode_search_strings {  # the supplied search strings are assumed to be URL encoded

    foreach (@opt_search) {
        $_ = uri_unescape($_);
    }

    return;
}

sub show_search_options {
    print "\n";
    print "Search base path  : $opt_folder\n";

    foreach (@opt_search) {
        print "Search target for : $_ \n";
    }

    print 'Max file age mins : ';
    if (defined $opt_max_age) {
        print "$opt_max_age\n";
    } else {
        print "none\n";
    }

    print 'Flags             :';
    if (defined $opt_stop) { print ' [stop]'; }
    if (defined $opt_decode) { print ' [decode quoted printable]'; }
    print "\n\n";

    return;
}

#------------------------------------------------------------------
sub get_options {  #shell options

    Getopt::Long::Configure('bundling');
    GetOptions(
        's|search=s'  => \@opt_search,
        'f|folder=s'   => \$opt_folder,
        'm|max_age=i'   => \$opt_max_age,
        't|stop'   => \$opt_stop,
        'q|decode'   => \$opt_decode,
        'v|V|version' => \$opt_version,
        'h|help'      => \$opt_help,
        )
        or do {
            print_usage();
            exit;
        };
    if ($opt_version) {
        print_version();
        exit;
    }

    if ($opt_help) {
        print_version();
        print_usage();
        exit;
    }

    if (not defined $opt_search[0]) {
        print "\nERROR: Search string[s] must be specified\n\n";
        print_usage();
        exit;
    }

    if (not defined $opt_folder) {
        print "\nERROR: Target folder must be specified\n\n";
        print_usage();
        exit;
    }

    return;
}

sub print_version {
    print "\nLookupFolder version $VERSION\nFor more info: https://github.com/Qarj/LookupFolder\n\n";
    return;
}

sub print_usage {
    print <<'EOB'

Usage: LookupFolder.pl <<options>>

-s|--search     SEARCH STRING, MANY OK    --search user1 --search my%20name
-f|--folder     TARGET FOLDER TO SEARCH   --folder \\IRON\D$\email\pickup\*.eml
-m|--max_age    MAX AGE OF FILES - MINS   --max_age 15
-t|--stop       STOP AFTER FIRST MATCH    --stop
-q|--decode     DECODE QUOTED PRINTABLE   --decode
-v|--version                              -v
-h|--help                                 -h

or

LookupFolder.pl -v|--version
LookupFolder.pl -h|--help
EOB
;
return;
}
#------------------------------------------------------------------
