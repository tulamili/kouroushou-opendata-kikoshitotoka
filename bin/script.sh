#! zsh

selfdir=$( cd $( dirname $0 ) ; pwd ) ; # *同じディレトクリにある実行ファイルを実行するため。
fetched=$selfdir/../fetched 
renamed=$selfdir/../renamed
binded=$selfdir/../binded
export PATH=$selfdir:$PATH ; # パスの設定
export PERL5LIB="$HOME/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}" ; # cpanmを利用していろいろなモジュールをインストールしているため
sleep $(( $RANDOM % 3 )) ; # ランダムな秒数待ってみる。3秒以内で。


proc1="dl2gitrepo $fetched https://www.mhlw.go.jp/content/life_welfare_small_fund.csv 緊急小口資金等の特例貸付"
proc2="copyDTfile -U $fetched/life_welfare_small_fund.csv $renamed"
proc3="cd $renamed ; csv2onetsv -m -s1 -t0 -E 'LWSF22{0126,0202,0307}T????.csv' LWSF2?????T????.csv >| $binded/since220204.csv"

eval $proc1 && { eval $proc2 ; eval $proc3 } 
dufolder -G1 `git rev-parse --show-superproject-working-tree --show-toplevel`


# 開発上や使用する上でのメモ
#
#  新しいサーバーで、このレポジトリに含まれているプログラムを実行することになる。
#  この場合、このスクリプトだけ普段はcrontabから実行することになる。
#  ただし、新しいサーバーで始めるにしても、最初にUNIX系の簡単なコマンドをいろいろ使った初期操作が必要であろう。