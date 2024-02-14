#! /bin/bash

# 面積重み付きの領域平均値差(テキストファイル)を1-12月連結するプログラム
#----------------------------------------------------------------------------------------------------------

# diftrend ensemble mean ver (MIROCes, Hades)
#cd /home/honoka/work/HadCRUT5_MIROC6/trendwgtav/data/N30_90/diftrendwgtav_MIROC-Had/   # データの在り処に移動
#stnm=diftrendav_MIROC-Hades
#endnm=N30_90.txt

#--------------------------------------------
# diftrend アンサンブル平均 ver (MIROCav, Hadav)
#cd /home/honoka/work/HadCRUT5_MIROC6/trendwgtav/data/N30_90/diftrendwgtav_MIROCav-Hadav/  # データの在り処に移動
#stnm=diftrendav_MIROC-Hadav
#endnm=N30_90.txt

#--------------------------------------------
# trend アンサンブル平均 ver (MIROC run1-50)
cd /home/honoka/work/HadCRUT5_MIROC6/trendwgtav/data/N30_90/                               # データの在り処に移動
stnm=MIROC6_r1-50_trendwgtav_1960_2014
endnm=N30_90.txt

paste ${stnm}_1_${endnm} ${stnm}_2_${endnm} ${stnm}_3_${endnm} ${stnm}_4_${endnm} ${stnm}_5_${endnm} \
	${stnm}_6_${endnm} ${stnm}_7_${endnm} ${stnm}_8_${endnm} ${stnm}_9_${endnm} ${stnm}_10_${endnm} \
	${stnm}_11_${endnm} ${stnm}_12_${endnm} \
	> ${stnm}_1_12_${endnm} 


