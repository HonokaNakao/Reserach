#! /bin/bash

# マスキング処理を行うプログラム [HadCRUT5と同じ欠損値とするマスキング処理]

#----------------------------------------------------------------------------------------------------------------------------------------------
LTOP='/home/honoka/src/sample_code/MIROC6/DECK/historical'
LTOP2='/home/honoka/work/MIROC6/data'
LTOP3='/home/honoka/work/HadCRUT5/data/data_ensemble_monthly/HadCRUT.5.0.1.0.analysis.anomalies.ensemble_mean_1960_2014'
DTOP='HadCRUT.5.0.1.0.analysis.anomalies.ensemble_mean_1960_2014'
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
ln -s ${LTOP3}/${DTOP}_${mon}/${DTOP}_${mon} ./ # HadCRUT5データをシンボリックリンクする

gtmask ${${var}}_run${runnum}_anomalies_${stryr2}_${endyr}_${mon}_intp ${DTOP}_${mon} out:${var}_run${runnum}_anomalies_${stryr2}_${endyr}_${mon}_intpmk

rm ${DTOP}_${mon}
