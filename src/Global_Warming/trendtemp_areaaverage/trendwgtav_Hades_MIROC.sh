#! /bin/bash

# HadCRUT5とMIROC6 ensemble mean & run1~50の面積重み付き領域平均値を描画するプログラム
# (1) 度数分布表を描画 (draw_bar.sh)
# (2) montage (montage.sh)
#----------------------------------------------------------------------------------------------------------------------------------------------

# 領域平均値を算出 (cal_trendwgtav.sh)
#for mon in $( seq 1 12 ) ; do                 # 月毎
#for mon in 030405 060708 091011 120102 ; do   # 季節毎
#        ./cal_trendwgtav_N30_90.sh $mon
#done

# (1) 度数分布表を描画 (draw_bar.sh)
#for mon in $( seq 1 12 ) ; do                 # 月毎
#for mon in 030405 060708 091011 120102 ; do   # 季節毎
#        for area in NP N30_90 ; do
#        for area in N30_90 ; do
#               ./draw_bar.sh $mon $area                       # ensemble mean同士の場合
#               ./draw_bar_Hadav_MIROCav.sh $mon $area         # アンサンブル平均同士の場合 (2024.2.1ver)
#               ./draw_bar_Hadav_MIROCav_rg0-0.5.sh $mon $area  # アンサンブル平均同士の場合 range=0~0.5 (2024.2.8ver)
#       done
#done

# (2) montage (montage.sh)
#for area in NP N30_90 ; do
for area in N30_90 ; do
	./montage.sh $area
done

