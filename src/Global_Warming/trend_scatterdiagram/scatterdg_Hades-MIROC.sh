#! /bin/bash

# HadCRUT5 ensemble meanとMIROC ensemble mean & run1-50の２変数(空間相関と領域平均値)の散布図を描画するプログラム
# (1) 散布図を描画 (draw_scatter.sh)

#----------------------------------------------------------------------------------------------------------------------------------------------
# (1) 散布図を描画 (draw_scatter.sh)
#for mon in $( seq 1 12 ) ; do                 # 月毎
#for mon in 030405 060708 091011 120102 ; do  # 季節毎
#        for area in NP N30_90 ; do
#               ./draw_scatter.sh $mon $area
#        done
#done

# (1)' 散布図を描画 (draw_scatter_all.sh) MAM,JJA,SON,DJFの重ね描き
for area in NP N30_90 ; do
	./draw_scatter_all.sh $area
done


# (2) montage (montage.sh)
#for area in NP N30_90 ; do
#	./montage.sh $area
#done
