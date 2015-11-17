#!/usr/bin/perl

=head1 NAME

=head1 SYNOPSIS

=head1 SUMMARY

=head1 DESCRIPTION



=head1 OPTIONS


=cut


use strict;
use warnings;

use IO::Handle;
use Cwd;
use File::Spec;

die "Incorrect arguments" if (scalar @ARGV < 1);

my $target='';
my $target_local='';
my $abs_target;
my %dep_hash=();
my @dep_list=();

###############################

sub AddDepFile
{
    my ($d) = @_;
    return 0 unless $d;
    return 0 if ($d eq $target);
    return 0 if ($d eq $target_local);

    if (! exists $dep_hash{$d} )
    {
        push @dep_list, $d;
        $dep_hash{$d} = '';
        return 1;
    }
    else
    {
        #print "Find circular dependence:$d\n";
    }
    return 0;
}

sub LoadFile
{
    my ($filename) = @_;

    my $fh;
    die "Can't open $filename: $!\n" 
        unless (open($fh, "<", $filename));
    
    local $_;
    while (<$fh>) 
    {
        my $ln = $_;
        chomp $ln;

        if ( $ln =~ s{^\s*([^\s:]+)\s*:\s*\\?}{} )
        {
            #my $tf = Cwd::abs_path($1);
            if ($target)
            {
                #die "Different target found $tf, not $target" 
                #    unless $tf eq $target;
            }
            else
            { 
                $target = $1;
            }

        }

        while ( $ln =~ s{^\s*([^\s:\\]+)\s*\\?}{} )
        {
            AddDepFile($1);
        }
        next if ($ln =~ m{^\s*$});
        next if ! $ln;

        die "error in parsing $filename: $ln";
    }
    close $fh;
    die "No target defined in $filename" unless $target;

    return $target;
}



###############################

my $dst_file = shift @ARGV;
LoadFile($dst_file);

$target_local = $target;
$target_local =~ s{direxp\.a$}{local\.a};

foreach my $file (@ARGV) 
{
    LoadFile($file);
}

#$target=File::Spec->abs2rel($target);

my $dst_fh;
die "Cannot open $dst_file"
        unless (open($dst_fh, ">", $dst_file));

print $dst_fh "$target : ";
foreach my $d (@dep_list)
{
    print $dst_fh " $d";
}

print $dst_fh "\n";
close $dst_fh;
exit 0;
