#! /bin/bash

## MIROC6 ensemble meanの月毎、季節毎のトレンドと有意性を1つのpngファイルに出力するプログラム
#-----------------------------------------------------------------

LTOP='/home/honoka/work/MIROC6'
LTOP2='/home/honoka/work/MIROC6/data/run1_50/MIROC6_T2_run1_50_ensemble_1960_2014/MIROC6_T2_run1_50_ensemble_1960_2014'
LTOP3='/home/honoka/work/MIROC6/data/run1_50/MIROC6_T2_run1_50_ensemble_1960_2014'

DTOP='MIROC6_T2'
stryr=1960
endyr=2014
yr=${stryr}_${endyr}
#mon=$1                               # mon=1~12
#var=$2                              # var=MIROC6_ensm_trend,MIROC6_ensm_sig95_90_trend
#var=MIROC6_ensm_trend           
#var=MIROC6_ensm_sig95_90_trend     
var=MIROC6_ensm_trend_sig9590_1960_2014_${mon}_mon

#strnm=${var}.1_50_${yr}
#strnm=MIROC6_ensm_trend_sig9590_1960_2014
strnm=${LTOP2}
midnm=MIROC6_ensm_trend_sig9590

#endnm=${yr}_${mon}_mon_rg-1_1.png    # trend fileの末尾
#endnm=${yr}_${mon}_mon_rg-10_10.png  # trend fileの末尾
endnm2=${yr}_${mon}_mon.png           # sig95_90 fileの末尾
endnm3=mon_rg-10_10.png               # trend fileの末尾  
endnm4=mon.png                        # sig95_90 fileの末尾
#endnm=mon                             # trend_sig9590 fileの末尾
endnm=NP
num=1                                 # num=1,101

cd ${LTOP}/data/run1_50/${DTOP}_run1_50_ensemble_${yr}/

# データをシンボリックリンク
#ln -s ${LTOP}/data/run1_50/${DTOP}_run1_50_ensemble_${yr}/${DTOP}_run1_50_ensemble_${yr}_${mon}/${var}.1_50_${endnm}       # var=MIROC6_ensm_trend
#ln -s ${LTOP}/data/run1_50/${DTOP}_run1_50_ensemble_${yr}/${DTOP}_run1_50_ensemble_${yr}_${mon}/${var}.1_50_${endnm2}      # var=MIROC6_ensm_sig95_90_trend
#ln -s ${LTOP}/data/run1_50/${DTOP}_run1_50_ensemble_${yr}/${DTOP}_run1_50_ensemble_${yr}_${mon}/${var}                      # var=MIROC6_ensm_trend_sig9590_1960_2014_1_mon

#-----------------------------------------------------------------
# trend, sig95_90のmontage
# trend  
#montage -tile 3x4 -geometry 1044x739+0+0 \
#	${strnm}_1_${endnm3} ${strnm}_2_${endnm3} ${strnm}_3_${endnm3} ${strnm}_4_${endnm3} ${strnm}_5_${endnm3} \
#        ${strnm}_6_${endnm3} ${strnm}_7_${endnm3} ${strnm}_8_${endnm3} ${strnm}_9_${endnm3} ${strnm}_10_${endnm3} \
#        ${strnm}_11_${endnm3} ${strnm}_12_${endnm3} \
#        ${strnm}_1_12_${endnm3}

# sig95_90
#montage -tile 3x4 -geometry 1044x739+0+0 \
#	${strnm}_1_${endnm4} ${strnm}_2_${endnm4} ${strnm}_3_${endnm4} ${strnm}_4_${endnm4} ${strnm}_5_${endnm4} \
#        ${strnm}_6_${endnm4} ${strnm}_7_${endnm4} ${strnm}_8_${endnm4} ${strnm}_9_${endnm4} ${strnm}_10_${endnm4} \
#        ${strnm}_11_${endnm4} ${strnm}_12_${endnm4} \
#        ${strnm}_1_12_${endnm4}

#-----------------------------------------------------------------
# trend_sig9590 (trendとsig95_90の重ね描き)
# 月毎 (original)
#montage -tile 3x4 -geometry 904x654+0+0 \
#       ${strnm}_1_${endnm} ${strnm}_2_${endnm} ${strnm}_3_${endnm} ${strnm}_4_${endnm} ${strnm}_5_${endnm} \
#        ${strnm}_6_${endnm} ${strnm}_7_${endnm} ${strnm}_8_${endnm} ${strnm}_9_${endnm} ${strnm}_10_${endnm} \
#        ${strnm}_11_${endnm} ${strnm}_12_${endnm} \
#        ${strnm}_1_12_${endnm}

# 月毎 (切り取りver)
#montage -tile 3x4 -geometry 664x470+0+0 \
#       ${strnm}_1/${midnm}_1_${endnm} ${strnm}_2/${midnm}_2_${endnm} ${strnm}_3/${midnm}_3_${endnm} ${strnm}_4/${midnm}_4_${endnm} ${strnm}_5/${midnm}_5_${endnm} \
#       ${strnm}_6/${midnm}_6_${endnm} ${strnm}_7/${midnm}_7_${endnm} ${strnm}_8/${midnm}_8_${endnm} ${strnm}_9/${midnm}_9_${endnm} ${strnm}_10/${midnm}_10_${endnm} \
#       ${strnm}_11/${midnm}_11_${endnm} ${strnm}_12/${midnm}_12_${endnm} \
#       ${LTOP3}/${midnm}_${yr}_1_12_mon_NP

# 季節毎 (original)
#montage -tile 2x2 -geometry 904x654+0+0 \
#       ${strnm}_030405_${endnm} ${strnm}_060708_${endnm} ${strnm}_091011_${endnm} ${strnm}_120102_${endnm} \
#       ${strnm}_MJSD_${endnm}

# 季節毎 (切り取りver)
montage -tile 2x2 -geometry 664x470+0+0 \
       ${strnm}_030405/${midnm}_030405_${endnm} ${strnm}_060708/${midnm}_060708_${endnm} ${strnm}_091011/${midnm}_091011_${endnm} ${strnm}_120102/${midnm}_120102_${endnm} \
       ${LTOP3}/${midnm}_${yr}_MJSD_mon_NP

## montage後---------
# シンボリックリンクしたデータを削除 (このブロックのみ最初はコメントアウトする) -> シンボリックリンク不要 (montageの際に、絶対パスでファイル指定する)
#rm ${LTOP}/data/run1_50/${DTOP}_run1_50_ensemble_${yr}/${var}.1_50_${endnm}                                               # var=MIROC6_ensm_trend
#rm ${LTOP}/data/run1_50/${DTOP}_run1_50_ensemble_${yr}/${var}.1_50_${endnm2}                                              # var=MIROC6_ensm_sig95_90_trend
#rm ${LTOP}/data/run1_50/${DTOP}_run1_50_ensemble_${yr}/${var}                                                             # var=MIROC6_ensm_trend_sig9590_1960_2014_1_mon

