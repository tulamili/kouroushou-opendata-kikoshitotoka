#!/usr/bin/perl
use feature 'say' ; 
use strict ; use warnings ; 

my $lft = '' ; 
my $n ; 
while ( <> ) { 
  chomp ; 
  do { $lft = $_ ;  next } unless 6 == @ { [ m/,/g ] } ; 
  say "$lft,$_" ;
}
