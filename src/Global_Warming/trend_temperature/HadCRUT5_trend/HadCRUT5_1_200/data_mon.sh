#! /bin/bash

## トレンドと有意性を1つのpngファイルに出力するプログラム
#-----------------------------------------------------------------

LTOP='/home/honoka/work/HadCRUT5'
DTOP='HadCRUT.5.0.1.0.analysis.anomalies'

datanum=$1       # datanum=1~200
stryr=1960
endyr=2014
mon=$2           # mon=1~12

# 月毎ディレクトリの作成 (ex:1960_2014_1)
#if [ ! -d ${DTOP}.1_200_${stryr}_${endyr}_${mon} ] ; then
#  mkdir ${LTOP}/data/data_analysis_gridded_1_200/${DTOP}.1_200_${stryr}_${endyr}_${mon}
#fi
cd ${LTOP}/data/data_analysis_gridded_1_200/${DTOP}.1_200_${stryr}_${endyr}_${mon}/

# データをシンボリックリンク
#ln -s ${LTOP}/data/data_analysis_gridded_1_200/${DTOP}.${datanum}/${DTOP}.${datanum}_1960_2014/${DTOP}.${datanum}_1960_2014_${mon}/trend.${datanum}_1960_2014_${mon}_mon_rg-1_1.png ./ 
ln -s ${LTOP}/data/data_analysis_gridded_1_200/${DTOP}.${datanum}/${DTOP}.${datanum}_1960_2014/${DTOP}.${datanum}_1960_2014_${mon}/trend.${datanum}_1960_2014_${mon}_mon_rg-10_10.png ./ 
#ln -s ${LTOP}/data/data_analysis_gridded_1_200/${DTOP}.${datanum}/${DTOP}.${datanum}_1960_2014/${DTOP}.${datanum}_1960_2014_${mon}/sig95_90_trend.${datanum}_1960_2014_${mon}_mon.png ./ 

