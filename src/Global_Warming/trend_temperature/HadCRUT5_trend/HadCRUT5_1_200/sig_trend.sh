#! /bin/bash

## トレンド計算 & 有意性検定を行うプログラム
# (1) データ番号を計算 & 1960-2014年のファイルを作成 (make_monfile.sh)
# (2) データ番号を計算 & 1960-2014年MAM,JJA,SON,DJFのファイル作成 (make_3monfile.sh)
# (3) GTOOLを読む & 月毎トレンド計算 & 検定統計量T計算 & 有意性検定 & GTOOL形式で出力 & 描画  (cal_trend_T_sig_mon.sh)
# (4) GTOOLを読む & 季節毎トレンド計算 & 検定統計量T計算 & 有意性検定 & GTOOL形式で出力 & 描画  (cal_trend_T_sig_3mon_MAMJJASON.sh,cal_trend_T_sig_3mon_DJF.sh)
# (3)(4)' 月毎、季節毎のトレンドの描画 (range=-10~10 ver)
# (5)' トレンド(range=-10~10)200例をmontage

#-----------------------------------------------------------------

LTOP='/home/honoka/work/HadCRUT5'
DTOP='HadCRUT.5.0.1.0.analysis.anomalies'

cd ${LTOP}/src/t_test/t_test_ensemble1_200/

# (1) データ番号を計算 & 1960-2014年のファイルを作成 (make_monfile.sh)
#for datanum in $( seq 1 200 ) ; do
#	for mon in $( seq 1 12 ) ; do 	
#		./make_monfile.sh $datanum
#		./make_monfile.sh $datanum $mon
#	done
#done

# (2) データ番号を計算 & 1960-2014年MAM,JJA,SON,DJFのファイル作成 (make_3monfile.sh)
#for datanum in $( seq 1 200 ) ; do
#	for strmon in 3 6 9 12 ; do 
#		./make_3monfile.sh $datanum $strmon
#	done
#done

# (3) GTOOLを読む & 月毎トレンド計算 & 検定統計量T計算 & 有意性検定 & GTOOL形式で出力 & 描画  (cal_trend_T_sig_mon.sh)
#for datanum in $( seq 1 200 ) ; do
#	for mon in $( seq 1 12 ) ; do
#		./cal_trend_T_sig_mon.sh $datanum $mon
#	done
#done

# (4) GTOOLを読む & 季節毎トレンド計算 & 検定統計量T計算 & 有意性検定 & GTOOL形式で出力 & 描画  (cal_trend_T_sig_3mon_MAMJJASON.sh,cal_trend_T_sig_3mon_DJF.sh)
# MAM,JJA,SON
#for datanum in $( seq 1 200 ) ; do
#	for strmon in 3 6 9 ; do
#		./cal_trend_T_sig_3mon_MAMJJASON.sh $datanum $strmon
#	done
#done

# DJF
#for datanum in $( seq 1 200 ) ; do
#	./cal_trend_T_sig_3mon_DJF.sh $datanum
#done

# (3)(4)' 月毎、季節毎のトレンドの描画 (range=-10~10 ver)
#for runnum in $( seq 1 200 ) ; do
#        for mon in 1 2 3 4 5 6 7 8 9 10 11 12 030405 060708 091011 120102 ; do
#                ./dr_trend.sh $runnum $mon
#        done
#done

# (5) トレンド、有意性の200例をmontage (montage_mon.sh)
# 月毎
#for datanum in $( seq 1 200 ) ; do
#	for mon in $( seq 1 12 ) ; do
#		./data_mon.sh $datanum $mon                # データをシンボリックリンク
#	done
#done

#for datanum in $( seq 1 200 ) ; do
#	for mon in $( seq 1 12 ) ; do
#		./convert.sh $datanum $mon                 # fileの切り取り (convert)
#        done
#done

#for mon in $( seq 1 12 ) ; do
#	for var in trend sig95_90_trend ; do
#		./montage_mon.sh $mon $var                 # fileの並び替え (montage)
#	done
#done

# 季節毎(MAM,JJA,SON,DJF)
#for datanum in $( seq 1 200 ) ; do
#	for mon in 030405 060708 091011 120102 ; do
#		./data_mon.sh $datanum $mon                # データをシンボリックリンク
#	done
#done

#for datanum in $( seq 1 200 ) ; do
#	for mon in 030405 060708 091011 120102 ; do
#		./convert.sh $datanum $mon                 # fileの切り取り (convert)
#        done
#done

#for mon in 030405 060708 091011 120102 ; do
#	for var in trend sig95_90_trend ; do
#		./montage_mon.sh $mon $var                 # fileの並び替え (montage)
#        done
#done

# (5)' トレンド(range=-10~10)50例をmontage
for datanum in $( seq 1 200 ) ; do
       for mon in 1 2 3 4 5 6 7 8 9 10 11 12 030405 060708 091011 120102 ; do
               ./data_mon.sh $datanum $mon                  # データをシンボリックリンク
               ./convert.sh $datanum $mon                   # fileの切り取り (convert)
       done
done

for mon in 1 2 3 4 5 6 7 8 9 10 11 12 030405 060708 091011 120102 ; do
        ./montage_mon.sh $mon                              # fileの並び替え (montage)
done

