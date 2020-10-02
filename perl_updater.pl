#!/usr/bin/perl

use strict;
use warnings;
use DBI;


# my $dbh = DBI->connect("DBI:mysql:perl_updater",'root','XXXXXX');
# if(!$dbh)
   # {die "failed to connect to database DBI->errstr()";}

package Struct;
sub new
{
   my $class = shift;
   my $ref = {}; 
   
   bless $ref, $class;
   return $ref;
}

my $struct = new Struct();
$struct->{FULL_PATH} = 'C:\Users\Admin\Desktop\make_struct.txt';
if(!$struct->FindFile())
{
   print "ERROR: Cannot find $struct->{FULL_PATH}\n";
   exit;
}
$struct->ReadAndUpdate();


#use Data::Dumper;
#print Dumper($struct);

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
            $struct->{FILE_CONTENT}{$col} = $title;
         } 
      }
      else
      { 
         $col = 0;
         my $full_name;
         my $player_struct = undef;
         my @title_arr = split(/\|/, $line);
         foreach my $line_data(@title_arr)
         {
            $col++;
            $line_data =~ s/^\s+|\s+$//g;
            my $col_name = $struct->{FILE_CONTENT}{$col};
            my $query;
            
            if($col_name =~ /NAME/i)
            {
               my @name_arr = split(',', $line_data);
               my $full_name = $name_arr[1].' '.$name_arr[0];
               $full_name =~ s/^\s+//g;
               $player_struct->{NAME} = $full_name;
               #query = "insert into team_info (first_name, last_name) values $";
            }
            elsif($col_name =~ /POSITION/i)
            {
               $player_struct->{POS} = $line_data;               
            }
            elsif($col_name =~ /^TEAM/i)
            { 
               $player_struct->{CURR_TEAM} = $line_data; 
            }
            elsif($col_name =~ /PREVIOUS_TEAM/i)
            {
               if($line_data =~ /,/i)
               {
                  my @team_arr = split(',', $line_data);
                  foreach my $team(@team_arr)
                  {
                     push(@{$player_struct->{PREV_TEAM}}, $team);
                  }
               }
               else
               {
                  $player_struct->{PREV_TEAM} = $line_data;
               }
            }
            elsif($col_name =~ /POS_RANK/i)
            {
               $player_struct->{POS_RANK} = $line_data;   
            }
         }
         use Data::Dumper;
         print Dumper($player_struct);
      }
   }
}
