#! /bin/bash

# 領域平均値差を算出するプログラム ( diftrendwgtav = MIROC trendwgtav - HadCRUT5 trendwgtav )

# -------------------------------------------------------------------------------------------

# (1) 領域平均値差を算出 (cal_diftrendwgtav.sh)
#for mon in $( seq 1 12 ) ; do                      # 月毎
#for mon in 030405 060708 091011 120102 ; do        # 季節毎
#        ./cal_diftrendwgtav.sh $mon                # trend ensemble mean ver
#        ./cal_diftrendwgtav_MIROCav-Hadav.sh $mon  # trendアンサンブル平均 ver
#done

# (2) diftrendwgtavを結合
./paste.sh
