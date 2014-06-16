#!/usr/bin/perl

=head1 NAME

This perl script is used to find the file contain main() in c/c++ file.
This method has flaws, since it searches pattern matching 
"int main(*)", and no grammar syntax (suck as comments) is considered.  

It should be OK for most test programs, but the correct way to determine if a 
source code contains main() function is to search its object file by running 
   nm main.o | grep "T main"


=head1 SYNOPSIS

=head1 SUMMARY

=head1 DESCRIPTION



=head1 OPTIONS


=cut


use strict;
use warnings;

use IO::Handle;

sub match_main_func_line
{
    my ($ln) = @_;
    
    #print "testing:$ln";
    if ($ln =~ m{^\s*(?:int\s+|void\s+|)main\s*\(.*\)} ) 
    {
       return 1;
    }
    return 0;
}

sub find_main 
{
    my($filename) = @_;
    my $fh;
    unless (open($fh, "<", $filename)) 
    {
        die "Can't open $filename: $!\n";
    }

    local $_;
    while (<$fh>) 
    {    
        # find "int main(argc, argv)"
        my $ln = $_;
        if (match_main_func_line($ln))
        {
            close $fh;
            return 1;
        };
    }
    close $fh;
    return 0;
}

###############################

my @findlist = ();

foreach my $file (@ARGV) 
{
    #print "Open $file\n";
    if (find_main($file))
    {
        push @findlist, $file;
    }
}

print join(' ',@findlist);
print "\n";
exit 0;
