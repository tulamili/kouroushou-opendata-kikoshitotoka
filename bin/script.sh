#! zsh

selfdir=$( cd $( dirname $0 ) ; pwd ) ; # *同じディレトクリにある実行ファイルを実行するため。
fetched=$selfdir/../fetched 
renamed=$selfdir/../renamed
binded=$selfdir/../binded
export PATH=$selfdir:$PATH ; # パスの設定
export PERL5LIB="$HOME/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}" ; # cpanmを利用していろいろなモジュールをインストールしているため
sleep $(( $RANDOM % 120 )) ; # ランダムな秒数待ってみる。3秒以内で。

cd $selfdir 
proc1="dl2gitrepo $fetched https://www.mhlw.go.jp/content/life_welfare_small_fund.csv 緊急小口資金等の特例貸付"
proc2="copyDTfile -U -10 $fetched/life_welfare_small_fund.csv $renamed"
proc3="cd $renamed ; csv2onetsv -m -s1 -t0 -E 'LWSF22{0126,0202,0307}T????.csv' LWSF2?????T????.csv >| $binded/since220204.csv"
proc4="git add $binded/since220204.csv $renamed ; git commit -m 'since220204.csvとその材料の更新(または作成).' "; 
proc5="dufolder -G1 `git rev-parse --show-superproject-working-tree --show-toplevel` ; git push "  ;
eval $proc1 ||  { eval $proc2 ; eval $proc3 ; eval $proc4 > /dev/null 2>&1 ; eval $proc5 > /dev/null 2>&1 } 



# 開発上や使用する上でのメモ
#
#  
#  このスクリプトをcrontabから実行できるように書くようにつとめた。
#  
#  2022-03-15 下野寿之(統計数理研究所 特任研究員)

