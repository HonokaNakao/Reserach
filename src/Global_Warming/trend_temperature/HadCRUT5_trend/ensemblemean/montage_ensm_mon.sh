#! /bin/bash

## HadCRUT5 ensemble meanの月毎、季節毎のトレンドと有意性を1つのpngファイルに出力するプログラム
#-----------------------------------------------------------------

LTOP='/home/honoka/work/HadCRUT5/data/data_ensemble_monthly/HadCRUT.5.0.1.0.analysis.anomalies.ensemble_mean_1960_2014'
DTOP='HadCRUT.5.0.1.0.analysis.anomalies.ensemble_mean_1960_2014'
stryr=1960
endyr=2014
yr=${stryr}_${endyr}
#mon=$1                               # mon=1~12, 030405,060708,091011,120102
#strnm=trend_sig9590_1960_2014
#endnm=mon

strnm=${LTOP}/${DTOP}
midnm=trend_sig9590
endnm=NP
num=1                                # num=1,101
cd ${LTOP}/

# データをシンボリックリンク
#ln -s ${LTOP}/${DTOP}_${mon}/${strnm}_${mon}_mon ./

# trend, sig95_90重ね描きのmontage
# 月毎 (original)
#montage -tile 3x4 -geometry 904x654+0+0 \
#	${strnm}_1_${endnm} ${strnm}_2_${endnm} ${strnm}_3_${endnm} ${strnm}_4_${endnm} ${strnm}_5_${endnm} \
#        ${strnm}_6_${endnm} ${strnm}_7_${endnm} ${strnm}_8_${endnm} ${strnm}_9_${endnm} ${strnm}_10_${endnm} \
#        ${strnm}_11_${endnm} ${strnm}_12_${endnm} \
#        ${strnm}_1_12_${endnm}

# 月毎 (切り取りver)
#montage -tile 3x4 -geometry 664x470+0+0 \
#	${strnm}_1/${midnm}_1_${endnm} ${strnm}_2/${midnm}_2_${endnm} ${strnm}_3/${midnm}_3_${endnm} ${strnm}_4/${midnm}_4_${endnm} ${strnm}_5/${midnm}_5_${endnm} \
#	${strnm}_6/${midnm}_6_${endnm} ${strnm}_7/${midnm}_7_${endnm} ${strnm}_8/${midnm}_8_${endnm} ${strnm}_9/${midnm}_9_${endnm} ${strnm}_10/${midnm}_10_${endnm} \
#	${strnm}_11/${midnm}_11_${endnm} ${strnm}_12/${midnm}_12_${endnm} \
#	${LTOP}/trend_sig9590_1960_2014_1_12_mon_NP

# 季節毎 (original)
#montage -tile 2x2 -geometry 904x654+0+0 \
#	${strnm}_030405_${endnm} ${strnm}_060708_${endnm} ${strnm}_091011_${endnm} ${strnm}_120102_${endnm} \
#	${strnm}_MJSD_${endnm}

# 季節毎 (切り取りver)
montage -tile 2x2 -geometry 664x470+0+0 \
       ${strnm}_030405/${midnm}_030405_${endnm} ${strnm}_060708/${midnm}_060708_${endnm} ${strnm}_091011/${midnm}_091011_${endnm} ${strnm}_120102/${midnm}_120102_${endnm} \
       ${LTOP}/trend_sig9590_1960_2014_MJSD_mon_NP

## montage後---------
# シンボリックリンクしたデータを削除 (このブロックのみ最初はコメントアウトする)
#rm ${LTOP}/${strnm}_${mon}_${endnm}
