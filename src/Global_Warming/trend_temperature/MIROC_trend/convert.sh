#! /bin/bash

# trendとsig95_90のpngファイルを切り取る

#----------------------------------------------------------------------------------------------------------------------------------------------

LTOP='/home/honoka/work/MIROC6'

var='MIROC6_T2'
stryr=1960
endyr=2014
yr=${stryr}_${endyr}
runnum=$1        # runnum=1~50
mon=$2           # mon=1~12

DTOP=${var}_run${runnum}_anomalies_${stryr}_${endyr}_${mon}_intpmk

endnm=${yr}_${mon}_mon_rg-1_1.png  # trend fileの末尾
endnm2=${yr}_${mon}_mon.png        # sig95_90 fileの末尾
endnm3=${yr}_${mon}_mon_rg-10_10.png  # trend fileの末尾

cd ${LTOP}/data/run1_50/${var}_run1_50_${stryr}_${endyr}_${mon}/

#convert -density 100 -crop 891x455+122+130 MIROC6_trend.${runnum}_${endnm} MIROC6_trend.${runnum}_${mon}.png
convert -density 100 -crop 891x455+122+130 MIROC6_trend.${runnum}_${endnm3} MIROC6_trend.${runnum}_${mon}_rg-10_10.png
#convert -density 100 -crop 891x455+122+130 MIROC6_sig95_90_trend.${runnum}_${endnm2} MIROC6_sig95_90_trend.${runnum}_${mon}.png
