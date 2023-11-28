#! /bin/bash

# MIROC6 run1~50の月毎のensemble meanから季節毎のensemble meanを作成
# (ex) MIROC6_ensm_sig95_90_trend.1_50_1960_2014_3_mon MIROC6_ensm_sig95_90_trend.1_50_1960_2014_4_mon MIROC6_ensm_sig95_90_trend.1_50_1960_2014_5_mon
#      -> MIROC6_ensm_sig95_90_trend.1_50_1960_2014_030405_mon
#
#----------------------------------------------------------------------------------------------------------
LTOP='/home/honoka/work/MIROC6'
LTOP2='/home/honoka/work/MIROC6/data/run1_50/MIROC6_T2_run1_50_ensemble_1960_2014'
var='MIROC6_T2'
yr=1960_2014
strmon=$1                                        # strmon=3(MAM), 6(JJA), 9(SON), 12(DJF)
strnm=${var}_run1_50_ensemble_${yr}
strnm2=MIROC6_T2_run1_50_anomalies_ensemble_${yr}

if [ ${strmon} -lt 9 ] ; then                    # strmon=3,6の場合  
        midmon=$(( $strmon+1 ))                  # midmon=4,7
        endmon=$(( $strmon+2 ))                  # endmon=5,8
        mon3=0${strmon}0${midmon}0${endmon}
elif [ ${strmon} -eq 9 ] ; then                  # strmon=9(SON)の場合
        midmon=$(( $strmon+1 ))                  # midmon=10
        endmon=$(( $strmon+2 ))                  # endmon=11
        mon3=0${strmon}${midmon}${endmon}
else                                             # strmon=12(DJF)の場合
        midmon=1
        endmon=2
        mon3=${strmon}0102
fi

cd ${LTOP2}/${strnm}_${mon3}/                    # 3ヶ月毎のディレクトリに移動

#----------------------------------------------------------------------------
# 月毎のデータをシンボリックリンクする
ln -s ${LTOP2}/${strnm}_${strmon}/${strnm2}_${strmon}
ln -s ${LTOP2}/${strnm}_${midmon}/${strnm2}_${midmon}
ln -s ${LTOP2}/${strnm}_${endmon}/${strnm2}_${endmon}

#----------------------------------------------------------------------------
# 月毎のデータを3ヶ月に連結する (ex:3,4,5 -> 030405)
if [ ${strmon} -le 9 ] ; then                    # strmon=3,6,9の場合
	ngtcat -c ${strnm2}_${strmon} ${strnm2}_${midmon} ${strnm2}_${endmon} > ${strnm2}_${mon3}
else                                             # strmon=12の場合
	ngtcat -c ${strnm2}_1 ${strnm2}_2 ${strnm2}_12 > ${strnm2}_${mon3}
fi

# DJFのみ (1960.1,2,12,1961.1,2,12,...,2014.1.2.12 -> 1960.12,1961.1,2...,2013.12,2014.1,2)
mv MIROC6_T2_run1_50_anomalies_ensemble_1960_2014_120102 MIROC6_T2_run1_50_anomalies_ensemble_196001_201412

gtsel MIROC6_T2_run1_50_anomalies_ensemble_196001_201412 str=3 end=164 out:MIROC6_T2_run1_50_anomalies_ensemble_1960_2014_120102




