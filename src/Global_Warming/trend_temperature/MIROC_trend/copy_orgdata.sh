#! /bin/bash

# (1)データを格納するディレクトリ作成
# (2)データをコピーする
#
#----------------------------------------------------------------------------------------------------------------------------------------------
LTOP='/home/honoka/src/sample_code/MIROC6/DECK/historical'
LTOP2='/home/honoka/work/MIROC6/data'
stryr=1850
stryr2=1960
strmon=1
endyr=2014
endmon=12

# 1961.1, 1990.12 データ番号の計算
strdata=$(( (1961-${stryr})*12+${strmon} ))
enddata=$(( (1990-${stryr})*12+${endmon} ))
echo ${strdata} ${enddata}

# run01~run09-------------------------------------------------------------------
for runnum in $( seq 1 9 ) ; do               # run01~run09で同様の作業を実施
       if [ ! -d run${runnum} ] ; then
           mkdir ${LTOP2}/run${runnum}
        fi
       cd ${LTOP2}/run${runnum}/

# 1960~2014年 T2をコピー
        for year in $( seq ${stryr} ${endyr} ) ; do
               cp ${LTOP}/run0${runnum}/y${year}/ATM/T2 T2_run${runnum}_${year}
        done

# run10~run50-------------------------------------------------------------------
for runnum in $( seq 10 50 ) ; do               # run10~run50で同様の作業を実施
       if [ ! -d run${runnum} ] ; then
           mkdir ${LTOP2}/run${runnum}
        fi
       cd ${LTOP2}/run${runnum}/

# 1960~2014年 T2をコピー
        for year in $( seq ${stryr} ${endyr} ) ; do
               cp ${LTOP}/run${runnum}/y${year}/ATM/T2 T2_run${runnum}_${year}
       done

