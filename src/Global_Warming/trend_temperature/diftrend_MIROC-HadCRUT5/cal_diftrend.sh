#! /bin/bash

# HadCRUT5 ensemble meanとMIROC6 run1-50のtrendの差を計算するプログラム

#----------------------------------------------------------------------------------------------------------------------------------------------

varMIROCes='MIROC6_T2_run1_50_ensemble_1960_2014'
varHades='HadCRUT.5.0.1.0.analysis.anomalies.ensemble_mean_1960_2014'
stryr=1960
endyr=2014
yr=${stryr}_${endyr}
mon=$1           # mon=1~12
runnum=$2        # runnum=1~50

LTOP='/home/honoka/work/HadCRUT5_MIROC6/diftrend/data'
LTOP2=/home/honoka/work/HadCRUT5/data/data_ensemble_monthly/${varHades}/${varHades}_${mon} # HadCRUT5 ensemble trendデータの在処
LTOP3=/home/honoka/work/MIROC6/data/run1_50/MIROC6_T2_run1_50_ensemble_${yr}               # MIROC6 ensemble trendデータの在処
LTOP4=/home/honoka/work/MIROC6/data/run${runnum}/MIROC6_T2_run${runnum}_${yr}_${mon}       # MIROC6 run1-50 trendデータの在処

# (1) trendとsig95_90をシンボリックリンク
mkdir ${LTOP}/trend/diftrend_MIROC-Hades_${yr}_${mon}     # データの置きディレクトリ作成
cd ${LTOP}/trend/diftrend_MIROC-Hades_${yr}_${mon}/

# HadCRUT5 ensemble meanのtrend & sig95_90
ln -s ${LTOP2}/trend_${yr}_${mon}_mon
ln -s ${LTOP2}/sig95_90_trend_${yr}_${mon}_mon

# MIROC6 ensemble meanのtrend & sig95_90
ln -s ${LTOP3}/${varMIROCes}_${mon}/MIROC6_ensm_trend.1_50_${yr}_${mon}_mon
ln -s ${LTOP3}/${varMIROCes}_${mon}/MIROC6_ensm_sig95_90_trend.1_50_${yr}_${mon}_mon

# MIROC6 run1-50のtrend & sig95_90
ln -s ${LTOP4}/MIROC6_trend.${runnum}_${yr}_${mon}_mon
ln -s ${LTOP4}/MIROC6_sig95_90_trend.${runnum}_${yr}_${mon}_mon

#-----------------------------------------------------------------------------------------
# (2) trendの差を計算 ( diftrend = MIROC trend - HadCRUT5 ensemble mean trend )
gtsub MIROC6_ensm_trend.1_50_${yr}_${mon}_mon trend_${yr}_${mon}_mon out:diftrend_MIROC6es-Hades_${yr}_${mon}          # MIROC6 ensemble mean trend - HadCRUT5 ensemble mean trend
gtsub MIROC6_trend.${runnum}_${yr}_${mon}_mon trend_${yr}_${mon}_mon out:diftrend_MIROC6.${runnum}-Hades_${yr}_${mon} # MIROC6 run1-50 trend - HadCRUT5 ensemble mean trend

#-----------------------------------------------------------------------------------------
# (3) シンボリックリンクを削除
rm ${LTOP}/trend/diftrend_MIROC-Hades_${yr}_${mon}/trend_${yr}_${mon}_mon
rm ${LTOP}/trend/diftrend_MIROC-Hades_${yr}_${mon}/MIROC6_ensm_trend.1_50_${yr}_${mon}_mon
rm ${LTOP}/trend/diftrend_MIROC-Hades_${yr}_${mon}/MIROC6_trend.${runnum}_${yr}_${mon}_mon
