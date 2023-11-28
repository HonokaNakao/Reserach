#! /bin/bash
## HadCRUT5 ensemble data 200例のトレンドの最小値、最大値を確認するプログラム

#----------------------------------------------------------------------------------------------------------------------------------------------
LTOP='/home/honoka/work/HadCRUT5/data/data_analysis_gridded_1_200'
LTOP2='/home/honoka/work/HadCRUT5'
DTOP='HadCRUT.5.0.1.0.analysis.anomalies'
stryr=1960
strmon=1
endyr=2014
endmon=12
yr=${stryr}_${endyr}
runnum=$1                       # runnum=1~50 (run1~run50)
mon=$2                          # mon=1~12, 030405, 060708, 091011, 120102

cd ${LTOP}/${DTOP}.${runnum}/${DTOP}.${runnum}_${yr}/${DTOP}.${runnum}_${yr}_${mon}/ # データの在り処に移動

ngtstat trend.${runnum}_${yr}_${mon}_mon >> ${LTOP2}/src/t_test/t_test_ensemble1_200/HadCRUT5_200_minmax.txt



