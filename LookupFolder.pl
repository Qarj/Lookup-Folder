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

## USAGE:
## LookupFolder.pl \\IRON\C$\webinject TBA

my $allmatches = 0;
my $filematches = 0;
my $fileschecked = 0;

die "\nno directory provided\n" unless defined $ARGV[0];

#my $path = abs_path $ARGV[0];
my $path = $ARGV[0];
my $extension = $ARGV[1];
my $target = $ARGV[2];

my @filestocheck;

if (!$extension) { die "\nNeed an extension - e.g. config\n"; }
if (!$target) { die "\nNeed a word to search for - e.g. findthis\n"; }


print "\n";
print "Search base path  : $path\n";
print "Search extension  : $extension\n";
print "Search target for : $target [case insensitive]\n\n";

# add on the *.txt extension or whatever supplied
my $filter = '\*'."$extension";

build_list_of_files_to_check();

search_all_files();

print "\nFound $allmatches matches total in $filematches files out of $fileschecked files searched\n";

#
# end of script - subroutines follow
#

# Build a list of files to examine in an array
sub build_list_of_files_to_check {

    my $start_time = time;

    @filestocheck = (`dir /S /B /A-D "$path$filter"`);

    my $run_time = (int(1000 * (time - $start_time)) / 1000);
    print "Built file list in $run_time seconds\n";
    
    return;
}

# Iterate over the files
sub search_all_files {

    my $start_time = time;

    foreach my $checkfile (@filestocheck)
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

        if ($_ =~ m/$target/i) {

            # keep track of number of matches found
            $match = $match + 1;

            # for the first match, print out the filename along with the file match number
            if ($match == 1) {
                $filematches = $filematches + 1;
                print "\n["."$filematches".'] '."$filename:\n";
            }

            # print out the matching line
            print $_, $/;
        }
    }

    close $handle;

    $allmatches = $allmatches + $match;

    $fileschecked = $fileschecked + 1;

    return;
}