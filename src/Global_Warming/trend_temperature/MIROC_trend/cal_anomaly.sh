#! /bin/bash

# (5) 月毎の偏差を計算 [ex:MIROC6_T2_run1_anomalies_1960_2014_1 = MIROC6_T2_run1_1960_2014_1 - MIROC6_T2_run1_30ave_1] (cal_anomaly.sh)
#
#----------------------------------------------------------------------------------------------------------------------------------------------
LTOP='/home/honoka/src/sample_code/MIROC6/DECK/historical'
LTOP2='/home/honoka/work/MIROC6/data'
stryr=1850
stryr2=1960
strmon=1
endyr=2014
endmon=12
yr=$(( ${endyr}-${stryr2}+1 ))  # yr=55 (=2014-1960+1)
runnum=$1                       # runnum=1~50 (run1~run50)
mon=$2                          # mon=1~12
var=MIROC6_T2

cd ${LTOP2}/run${runnum}/${var}_run${runnum}_${stryr2}_${endyr}_${mon}/

gtsub ${var}_run${runnum}_${stryr2}_${endyr}_${mon} ${var}_run${runnum}_30ave_${mon} out:${var}_run${runnum}_anomalies_${stryr2}_${endyr}_${mon}

