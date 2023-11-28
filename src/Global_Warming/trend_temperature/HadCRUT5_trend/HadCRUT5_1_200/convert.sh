#! /bin/bash

# trendとsig95_90のpngファイルを切り取る

#----------------------------------------------------------------------------------------------------------------------------------------------

LTOP='/home/honoka/work/HadCRUT5'
DTOP='HadCRUT.5.0.1.0.analysis.anomalies'

stryr=1960
endyr=2014
yr=${stryr}_${endyr}

datanum=$1       # datanum=1~200
mon=$2           # mon=1~12
endnm=${yr}_${mon}_mon_rg-1_1.png  # trend fileの末尾
endnm2=${yr}_${mon}_mon.png        # sig95_90 fileの末尾
endnm3=${yr}_${mon}_mon_rg-10_10.png  # trend fileの末尾

cd ${LTOP}/data/data_analysis_gridded_1_200/${DTOP}.1_200_1960_2014_${mon}/

#convert -density 100 -crop 891x455+122+130 trend.${datanum}_${endnm} trend.${datanum}_${mon}.png
convert -density 100 -crop 891x455+122+130 trend.${datanum}_${endnm3} trend.${datanum}_${mon}_rg-10_10.png
#convert -density 100 -crop 891x455+122+130 sig95_90_trend.${datanum}_${endnm2} sig95_90_trend.${datanum}_${mon}.png
