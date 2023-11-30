#! /bin/bash

# 空間相関の度数分布表をmontageするプログラム 

#----------------------------------------------------------------------------------------------------------------------------------------------

area=$1                    # area=NP, N30_90
LTOP=/home/honoka/work/sppattern/data/sppattern_Hades-MIROC/${area}/bar/

cd ${LTOP}

# monthly
montage -tile 4x3 -geometry 904x654+0+0 \
	bar_sppattern_Hades-MIROC_1_${area} bar_sppattern_Hades-MIROC_2_${area} bar_sppattern_Hades-MIROC_3_${area} bar_sppattern_Hades-MIROC_4_${area} \
	bar_sppattern_Hades-MIROC_5_${area} bar_sppattern_Hades-MIROC_6_${area} bar_sppattern_Hades-MIROC_7_${area} bar_sppattern_Hades-MIROC_8_${area} \
	bar_sppattern_Hades-MIROC_9_${area} bar_sppattern_Hades-MIROC_10_${area} bar_sppattern_Hades-MIROC_11_${area} bar_sppattern_Hades-MIROC_12_${area} \
	bar_sppattern_Hades-MIROC_1_12_${area}

# season
montage -tile 2x2 -geometry 904x654+0+0 \
	bar_sppattern_Hades-MIROC_030405_${area} bar_sppattern_Hades-MIROC_060708_${area} bar_sppattern_Hades-MIROC_091011_${area} bar_sppattern_Hades-MIROC_120102_${area} \
	bar_sppattern_Hades-MIROC_MJSD_${area}






