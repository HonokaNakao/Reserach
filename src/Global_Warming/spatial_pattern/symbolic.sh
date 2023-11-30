#! /bin/bash

# MIROC6 ensemblemean & 50例 と HadCRUT5 ensemblemeanの月毎トレンドをシンボリックリンクするプログラム
#----------------------------------------------------------------------------------------------------------------------------------------------

LTOP=/home/honoka/work/MIROC6/data/run1_50/MIROC6_T2_run1_50_ensemble_1960_2014/MIROC6_T2_run1_50_ensemble_1960_2014
LTOP2=/home/honoka/work/HadCRUT5/data/data_ensemble_monthly/HadCRUT.5.0.1.0.analysis.anomalies.ensemble_mean_1960_2014/HadCRUT.5.0.1.0.analysis.anomalies.ensemble_mean_1960_2014
LTOP3=/home/honoka/work/MIROC6/data
mon=$1                                                                                              # mon=1~12
run=$2                                                                                              # run=1~50
DTOP=MIROC6_ensm_trend.1_50_1960_2014
DTOP2=trend_1960_2014
DEND=mon

cd /home/honoka/work/sppattern/data/trend/

# MIROC6 ensemble mean
ln -s ${LTOP}_${mon}/${DTOP}_${mon}_${DEND} ./MIROC6_ensm_${DTOP2}_${mon}_${DEND}                    # 月毎トレンド

# MIROC6 run1~50 
ln -s ${LTOP3}/run${run}/MIROC6_T2_run${run}_1960_2014_${mon}/MIROC6_trend.${run}_1960_2014_${mon}_mon ./MIROC6.${run}_${DTOP2}_${mon}_${DEND}   # 月毎トレンド 

# HadCRUT5 ensemble mean
ln -s ${LTOP2}_${mon}/${DTOP2}_${mon}_${DEND} ./HadCRUT5_ensm_${DTOP2}_${mon}_${DEND}                 # 月毎トレンド

