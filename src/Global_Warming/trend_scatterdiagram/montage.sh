#! /bin/bash

# 空間相関と領域平均値の散布図をmontageするプログラム

#----------------------------------------------------------------------------------------------------------------------------------------------
area=$1                    # area=NP, N30_90

var=scatter_sppatternwgt-trendwgtav_Hades-MIROC
LTOP=/home/honoka/work/HadCRUT5_MIROC6/scatterdg/data/${area}/
cd ${LTOP}

# monthly
montage -tile 4x3 -geometry 904x654+0+0 \
        ${var}_1_${area} ${var}_2_${area} ${var}_3_${area} ${var}_4_${area} \
        ${var}_5_${area} ${var}_6_${area} ${var}_7_${area} ${var}_8_${area} \
        ${var}_9_${area} ${var}_10_${area} ${var}_11_${area} ${var}_12_${area} \
        ${var}_1_12_${area}

# season
montage -tile 2x2 -geometry 904x654+0+0 \
        ${var}_030405_${area} ${var}_060708_${area} ${var}_091011_${area} ${var}_120102_${area} \
        ${var}_MJSD_${area}

