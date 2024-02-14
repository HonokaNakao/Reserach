#! /bin/bash

# 面積重み付きの領域平均値の度数分布表をmontageするプログラム 

#----------------------------------------------------------------------------------------------------------------------------------------------

LTOP=/home/honoka/work/HadCRUT5_MIROC6/trendwgtav/data/N30_90/bar
var=bar_trendwgtav_Hadav-MIROC
endnm=N30_90_rg0-0.5_ct
cd ${LTOP}                                                           # データの在り処に移動

# monthly
montage -tile 3x4 -geometry 498x525+0+0 \
        ${var}_1_${endnm} ${var}_2_${endnm} ${var}_3_${endnm} ${var}_4_${endnm} \
        ${var}_5_${endnm} ${var}_6_${endnm} ${var}_7_${endnm} ${var}_8_${endnm} \
        ${var}_9_${endnm} ${var}_10_${endnm} ${var}_11_${endnm} ${var}_12_${endnm} \
        ${var}_1_12_N30_90_rg0-0.5

convert -density 100 ${var}_1_12_N30_90_rg0-0.5 ${var}_1_12_N30_90_rg0-0.5.png

# season
montage -tile 2x2 -geometry 498x525+0+0 \
        ${var}_030405_${endnm} ${var}_060708_${endnm} ${var}_091011_${endnm} ${var}_120102_${endnm} \
        ${var}_MJSD_N30_90_rg0-0.5

convert -density 100 ${var}_MJSD_N30_90_rg0-0.5 ${var}_MJSD_N30_90_rg0-0.5.png
