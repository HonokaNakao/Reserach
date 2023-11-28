#! /bin/bash

## データをシンボリックリンクするプログラム
# (ex:MIROC6_T2_run1_anomalies_1960_2014_1_intpmk)
#-----------------------------------------------------------------

LTOP='/home/honoka/work/MIROC6'
var='MIROC6_T2'
stryr=1960
endyr=2014
runnum=$1        # runnum=1~50
mon=$2           # mon=1~12

DTOP=${var}_run${runnum}_anomalies_${stryr}_${endyr}_${mon}_intpmk

cd ${LTOP}/data/run1_50/${var}_run1_50_${stryr}_${endyr}_${mon}/

ln -s ${LTOP}/data/run${runnum}/${var}_run${runnum}_${stryr}_${endyr}_${mon}/${DTOP} ./
