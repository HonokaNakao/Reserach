#! /bin/bash

## トレンドと有意性を1つのpngファイルに出力するプログラム
#-----------------------------------------------------------------

LTOP='/home/honoka/work/MIROC6'

var='MIROC6_T2'
stryr=1960
endyr=2014
runnum=$1        # runnum=1~50
mon=$2           # mon=1~12

DTOP=${var}_run${runnum}_anomalies_${stryr}_${endyr}_${mon}_intpmk

cd ${LTOP}/data/run${runnum}/${var}_run${runnum}_${stryr}_${endyr}_${mon}/                    # GTOOLの在り処に移動

# 月毎ディレクトリの作成 (ex:1960_2014_1)
#if [ ! -d ${var}_run1_50_${stryr}_${endyr}_${mon} ] ; then
#  mkdir ${LTOP}/data/run1_50/${var}_run1_50_${stryr}_${endyr}_${mon}
#fi
cd ${LTOP}/data/run1_50/${var}_run1_50_${stryr}_${endyr}_${mon}/

# データをシンボリックリンク
#ln -s ${LTOP}/data/run${runnum}/${var}_run${runnum}_${stryr}_${endyr}_${mon}/MIROC6_trend.${runnum}_${stryr}_${endyr}_${mon}_mon_rg-1_1.png ./
ln -s ${LTOP}/data/run${runnum}/${var}_run${runnum}_${stryr}_${endyr}_${mon}/MIROC6_trend.${runnum}_${stryr}_${endyr}_${mon}_mon_rg-10_10.png ./
#ln -s ${LTOP}/data/run${runnum}/${var}_run${runnum}_${stryr}_${endyr}_${mon}/MIROC6_sig95_90_trend.${runnum}_${stryr}_${endyr}_${mon}_mon.png ./

