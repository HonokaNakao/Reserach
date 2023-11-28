#! /bin/bash

## トレンド計算をするプログラム
# (1) データ番号を計算 & 月別データに切り分ける            (make_monfile.sh)
# (2) GTOOLを読む & トレンド計算 & 検定統計量T & 有意性検定 & GTOOL形式で出力 & 描画  (cal_trend_T_sig_mon.sh)
#     有意な地点:trend, 有意でない地点:vmiss
# (3) 月毎トレンドと有意性の重ね描きをmontage (montage_ensm_mon.sh)
# (4) 季節毎トレンドと有意性の重ね描きをmontage (montage_ensm_mon.sh)

#-----------------------------------------------------------------

LTOP='/home/honoka/work/HadCRUT5'
DTOP='HadCRUT.5.0.1.0.analysis.anomalies.ensemble_mean'

# (1) データ番号を計算 & 月別データに切り分ける (make_monfile.sh)
#cd ${LTOP}/src/t_test/
#for month in $( seq 1 12 ) ; do    
#./make_monfile.sh $month
#done

# (2) GTOOLを読む & トレンド計算 & 検定統計量計算T & 有意性検定 & GTOOL形式で出力 & 描画  (cal_trend_T_sig_mon.sh)
#for month in $( seq 1 12 ) ; do
#  	./cal_trend_T_mon.sh $month
#        ./cal_trend_T_sig_mon.sh $month
#done

# (3) 月毎トレンドと有意性の重ね描きをmontage (montage_ensm_mon.sh)
#for month in $( seq 1 12 ) ; do    
#	./montage_ensm_mon.sh $month
#done
#	./montage_ensm_mon.sh            # 切り取りver

# (4) 季節毎トレンドと有意性の重ね描きをmontage (montage_ensm_mon.sh)
#for month in 030405 060708 091011 120102 ; do    
#	./montage_ensm_mon.sh $month
#done
	./montage_ensm_mon.sh            # 切り取りver


