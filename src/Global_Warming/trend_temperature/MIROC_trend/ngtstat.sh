#! /bin/bash
## MIROC6 50例のトレンドの最小値、最大値を確認するプログラム

#----------------------------------------------------------------------------------------------------------------------------------------------
LTOP='/home/honoka/work/MIROC6'
stryr=1960
strmon=1
endyr=2014
endmon=12
runnum=$1                       # runnum=1~50 (run1~run50)
mon=$2                          # mon=1~12, 030405, 060708, 091011, 120102
var=MIROC6_T2

cd ${LTOP}/data/run${runnum}/${var}_run${runnum}_${stryr}_${endyr}_${mon}/         # データの在り処に移動

ngtstat MIROC6_trend.${runnum}_${stryr}_${endyr}_${mon}_mon >> ${LTOP}/src/MIROC6_50_minmax.txt



