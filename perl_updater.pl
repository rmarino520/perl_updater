#!/usr/bin/perl

use strict;
use warnings;
use DBI;
my $dbh = DBI->connect("",'','');
if(!$dbh){
 die "failed to connect to MySQL database DBI->errstr()";
}
exit;

package Struct;sub new
{
   my $class = shift;
   my $ref = {}; 
   
   bless $ref, $class;
   return $ref;}
my $struct = new Struct();
$struct->{FULL_PATH} = 'C:\Users\Admin\Desktop\make_struct.txt';
if(!$struct->FindFile())
{
   print "ERROR: Cannot find $struct->{FULL_PATH}\n";
   exit;}
$struct->ReadAndUpdate();

use Data::Dumper;
print Dumper($struct);
####################################
## Find File, Return 1 on success
####################################
sub FindFile
{
   my $struct = shift;
   $struct->{FULL_PATH} =~ /(.+)\\(.+)/i;
   my $path = $1;
   my $file = $2;
    
   opendir my $dir, $path or die "Cannot open directory: $!";
   my @files = readdir $dir;

   return 1 if(grep(/$file/, @files));
}   
####################################
## Read file and update DB
####################################
sub ReadAndUpdate
{
   my $struct = shift;
   open(FH, '<:encoding(UTF-8)', $struct->{FULL_PATH}) or die;
   my @file_array = <FH>;
   close(FH);
   chomp(@file_array);
      foreach my $line (@file_array)
   {
      my $col = 0;
      ## TITLE LINE DOES NOT CONTAIN ','
      if($line !~ /,/i)
      {
         my @title_arr = split(/\|/, $line);
         foreach my $title(@title_arr)
         {
            $col++;
            $title =~ s/^\s+|\s+$//g;
            $title =~ s/\s+/_/g;
            $struct->{FILE_CONTENT}{$col} = $title;         } 
      }
      else
      { 
         $col = 0;
         my @title_arr = split(/\|/, $line);
         foreach my $line_data(@title_arr)
         {
            $col++;
            $line_data =~ s/^\s+|\s+$//g;
            my $col_name = $struct->{FILE_CONTENT}{$col};
            print "$line_data, $col_name\n";
            # if($col_name =~ /NAME/i)
            # elsif($col_name =~ /POSITION/i)
            # elsif($col_name =~ /TEAM/i)
            # elsif($col_name =~ /PREVIOUS_TEAM/i)
            # elsif($col_name =~ /POS_RANK/i)
            
         }      }   }}



