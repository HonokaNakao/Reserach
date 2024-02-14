#! /bin/bash

# HadCRUT5 trend 1-200例のensemble meanとMIROC6 trend run1-50のensemble meanの差を計算するプログラム

#----------------------------------------------------------------------------------------------------------------------------------------------

mon=$1
LTOP=/home/honoka/work/MIROC6/data/run1_50
LTOP2=/home/honoka/work/HadCRUT5/data/data_analysis_gridded_1_200

cd /home/honoka/work/HadCRUT5_MIROC6/diftrend/data/trend_MIROCr1_50av_Had1_200av/

# trend ensemble meanデータをシンボリックリンク
ln -s ${LTOP}/MIROC6_T2_run1_50_1960_2014_${mon}/MIROC6_trend_r1_50av_1960_2014_${mon}                              # MIROC6 trendav
ln -s ${LTOP2}/HadCRUT.5.0.1.0.analysis.anomalies.1_200_1960_2014_${mon}/HadCRUT5_trend_1_200av_1960_2014_${mon}    # HadCRUT5 trendav

#-----------------------------------------------------------------------------------------
# (1) trendの差を計算 ( diftrend = MIROC trend - HadCRUT5 ensemble mean trend )
gtsub MIROC6_trend_r1_50av_1960_2014_${mon} HadCRUT5_trend_1_200av_1960_2014_${mon} out:diftrend_MIROC6r1_50av-Had1_200av_1960_2014_${mon}  # MIROC run1-50 trendav - HadCRUT5 1-200例 trendav

#-----------------------------------------------------------------------------------------
# (2) シンボリックリンクを削除
rm /home/honoka/work/HadCRUT5_MIROC6/diftrend/data/trend_MIROCr1_50av_Had1_200av/MIROC6_trend_r1_50av_1960_2014_${mon}
rm /home/honoka/work/HadCRUT5_MIROC6/diftrend/data/trend_MIROCr1_50av_Had1_200av/HadCRUT5_trend_1_200av_1960_2014_${mon}
