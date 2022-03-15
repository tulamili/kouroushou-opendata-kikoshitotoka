#!/usr/bin/perl
#use 5.030 ; 
use strict ; 
use warnings ;
use feature 'say' ;
use File::Copy qw[ copy ] ;
use File::Spec::Functions qw [ catfile ] ; 
use FindBin qw[ $Bin $Script ] ;
use Getopt::Std ; getopts '2:fh:t:' , \my %o ; 
use POSIX qw [ strftime ] ; 
use Term::ANSIColor qw[ :constants ] ; $Term::ANSIColor::AUTORESET = 1 ;
use Time::HiRes qw[ gettimeofday tv_interval ] ; 
use Time::Local qw[ timegm ] ; # タイムゾーンに依存する時差を計算するため
use utf8 ; 
binmode STDOUT , 'utf8' ; 
binmode STDERR , 'utf8' ; 

my $t0 ;
$o{h} //= 'LWSF' ; 
$o{t} //= '.csv' ;
my $opt20 = 0 eq ($o{2}//'') ;

BEGIN { $t0 = [ gettimeofday ] } ; 
exec "$Bin/$Script --help" if @ARGV < 2 ; # binmode STDERR がHELP_MESSAGEにて文字化けを起こすため

END { 
  exit if '--help' eq ($ARGV[0]//'') ;
  exit if $opt20 ;
  say STDERR GREEN BOLD FAINT & dt3 , "\t" , "プログラム実行時間($Script) : ", sprintf "%0.3f 秒", tv_interval $t0 ;
} 

my $srcfile = $ARGV[0] ; # source file
die "$srcfile does not exist as a file. \n" unless -f $srcfile ; # コピー元のファイルが無ければ停止。
my $directory = $ARGV[1] ;
mkdir $directory or die unless -e $directory ; 
die "$directory does not exist as a directory. \n" unless -d $directory ;
my $newname = catfile $directory , strftime "$o{h}%y%m%dT%H%M$o{t}" , localtime [ stat $srcfile ] -> [ 9 ] ; #  ( $modified ) ; 
die "$newname is a directory. \n" if -d $newname ;  # コピー先のファイル名が、なぜかディレクトリだったら停止。
die "$newname already exists. \n" if -e $newname && ! $o{f} ; # コピー先にファイルが存在する場合、-fの指定が無ければ停止。
copy $srcfile , $newname or die ; 
say STDERR FAINT YELLOW "Copy Done : $srcfile --> " , $newname unless $opt20 ;
exit 0 ; 

=encoding utf8

=head1

$0 FILE DIR 

  指定されたファイル(FILE)を指定されたディレクトリ(DIR)に
  名前を LWSFyymmddThhm.csv に変えてコピーする。日時はファイルの最終変更日時を用いる。

 オプション: 
   -f     : ファイルの上書きを許容する。
   -h STR : 新しいファイル名の先頭の部分。未指定なら LWSF 
   -t STR : 新しいファイル名の末尾の部分。未指定なら .csv
   -2 0   : 標準エラー出力に、2次情報を出力しない。 

 目的: 
   毎週更新される厚労省オープンデータの「緊急小口資金等の特例貸付」のCSVファイルを蓄積し利用しやすくするため。


 開発上のメモ : 
   *

=cut

 

sub dtJ { 
  strftime ('%B%d日(%a)%H時%M分' , localtime ) ; # $t->[0] ) ; # ロケールが日本で無いと%Bが英語で表示されたりして変になるかも。
}

# 関数 dt2 : その時点の日時を0.01秒単位(10ミリ秒単位)で、日時記録を残すようにする。
sub dt2 { 
  my $t = [ gettimeofday ] ; 
  my $z = do { my $d = timegm(localtime)-timegm(gmtime) ; sprintf '%+03d:%02d', $d/3600, $d/60%60 } ;
  strftime( '%Y-%m-%d %H:%M:%S.' . sprintf("%02d", $t->[1] / 1e4 ) . $z , localtime( $t->[0] ) ) 
}

# 関数 dt3 : その時点の日時を0.001秒単位(ミリ秒単位)で、日時記録を残すようにする。
sub dt3 { my $t = [ gettimeofday ] ; strftime( "%Y-%m-%d %H:%M:%S." . sprintf("%03d", $t->[1] / 1e3 ) , localtime( $t->[0] ) ) }

# 数を3桁区切りに変換する。
sub d3 ($) { $_[0] =~ s/(?<=\d)(?=(\d\d\d)+($|\D))/,/gr } ; 

## ヘルプ (オプション --help が与えられた時に、動作する)
sub VERSION_MESSAGE {}
sub HELP_MESSAGE {
  use FindBin qw[ $Script ] ; 
  $ARGV[1] //= '' ;
  open my $FH , '<' , $0 ;
  while(<$FH>){
    s/\$0/$Script/g ;
    print $_ if s/^=head1// .. s/^=cut// and $ARGV[1] =~ /^o(p(t(i(o(ns?)?)?)?)?)?$/i ? m/^\s+\-/ : 1;
  }
  close $FH ;
  exit 0 ;
}