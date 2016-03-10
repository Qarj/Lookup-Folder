#!/usr/bin/perl

# $Id$
# $Revision$
# $Date$

use strict;
use warnings;
use vars qw/ $VERSION /;

$VERSION = '0.00';

use File::Basename;
use Time::HiRes 'time';
use Getopt::Long;

my (@opt_search, $opt_folder, $opt_filter, $opt_mode, $opt_age, $opt_decode, $opt_version, $opt_help);

get_options();

#ToDo:
# * read all the search strings into an array:   GetOptions ("library=s" => \@libfiles);
# - decode escaped strings to actual characters - e.g. %22 to ", %20 to space and so on
# - parse directory into arrays with last modified and filename
# - entire file must be read into an array
# - streaming mode? for matching across lines (probably not necessary?)
# - decode quoted printable file
# - check file for multiple parameters
# - file creation time - allow for clock sync error

my ($all_matches, $file_matches, $files_checked) = 0;
my (@files_to_check, @files_creation_time);

# show search
print "\n";
print "Search base path  : $opt_folder\n";
foreach (@opt_search) {
    print "Search target for : $_ \n";
}
print "Search mode       : $opt_mode\n";
print "Max file age mins : $opt_age\n";
print "Flags             :";                
if (defined $opt_decode) { print " [decode quoted printable]"; }
print "\n\n";

build_list_of_files_to_check();
exit;

search_all_files();

print "\nFound $all_matches matches total in $file_matches files out of $files_checked files searched\n";

#
# end of script - subroutines follow
#

# Build a list of files to examine in an array
sub build_list_of_files_to_check {

    my $start_time = time;
    
    #dir folder /A-D /N /O-D /TC /-C
    # /A-D  do not display directories
    # /N    use new long list format with filenames on far right
    # /O-D  sort by date/time with youngest first
    # /TC   sort date/time is creation
    # /-C   disable display of thousands separator for file size
    # /4    display four-digit years
    my @raw_files = (`dir /A-D /N /O-D /TC /-C /4 "$opt_folder"`);

    #foreach (@raw_files) {
    #    print "$_\n";
    #}

    my $i = 0;
    foreach (@raw_files) {
        # regex matches date, time, file size then anything after that is the file name
        if ($_ =~ m{^[\d/]+[ ]+([\d:]+)[ ]+[\d]+[ ](.+)}i ) {
            $files_creation_time[$i] = $1;
            $files_to_check[$i] = $2;
            $i++;
        }
    }

    # debug - check the file names captured
    for my $j (0 .. $#files_to_check) {
        print "$files_creation_time[$j] ";
        print "$files_to_check[$j]\n";
    }
    print "\n";

    my $run_time = (int(1000 * (time - $start_time)) / 1000);
    print "Built file list in $run_time seconds\n";
    
    return;
}

# Iterate over the files
sub search_all_files {

    my $start_time = time;

    foreach my $checkfile (@files_to_check)
    {
        examine_file ($checkfile);
    }

    my $run_time = (int(1000 * (time - $start_time)) / 1000);
    print "\nSearched files in $run_time seconds\n";

    return;
}

# Examine one file
sub examine_file {
    my ($filename) = @_;

    chomp $filename; # remove trailing \n

    # swap back slash to forward slash
    my $linux_file_name = $filename;
    $linux_file_name =~ s{\\}{/}g;

    my $match = 0;

    open my $handle, '<', $linux_file_name or die "\n\nCANNOT OPEN FILE: $linux_file_name\n\n";

    while (<$handle>) {

        if ($_ =~ m/$opt_search[0]/i) {

            # keep track of number of matches found
            $match = $match + 1;

            # for the first match, print out the filename along with the file match number
            if ($match == 1) {
                $file_matches = $file_matches + 1;
                print "\n["."$file_matches".'] '."$filename:\n";
            }

            # print out the matching line
            print $_, $/;
        }
    }

    close $handle;

    $all_matches = $all_matches + $match;

    $files_checked = $files_checked + 1;

    return;
}

#------------------------------------------------------------------
sub get_options {  #shell options

    $opt_mode = 'stop'; # default mode to stop searching once a match is found
    $opt_age = 10;      # default maximum age of files to search to be 10 minutes

    Getopt::Long::Configure('bundling');
    GetOptions(
        's|search=s'  => \@opt_search,
        'f|folder=s'   => \$opt_folder,
        'm|mode=s'   => \$opt_mode,
        'a|age=i'   => \$opt_age,
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

-s|--search     SEARCH STRING, MULTIPLE ACCEPTED      -s user1 -s my%20name
-f|--folder     TARGET FOLDER TO SEARCH               -f \\IRON\D$\email\pickup\*.eml
-m|--mode       MODE - stop AFTER FIRST MATCH OR all  -m stop
-a|--age        MAXIMUM AGE OF FILES - MINUTES        -a 15
-q|--decode     DECODE QUOTED PRINTABLE (EMAIL FILES) -q
-v|--version                                          -v
-h|--help                                             -h

or

LookupFolder.pl -v|--version
LookupFolder.pl -h|--help
EOB
;
return;
}
#------------------------------------------------------------------