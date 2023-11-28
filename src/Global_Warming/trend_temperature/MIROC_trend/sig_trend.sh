#! /bin/bash
## トレンド計算 & 有意性検定を行うプログラム

# 月毎のトレンド
# (1) GTOOLを読む & 月毎トレンド計算 & 検定統計量T計算 & 有意性検定 & GTOOL形式で出力 & 描画  (cal_trend_T_sig_mon.sh)

#季節毎のトレンド
# (2) データ番号を計算 & 1960-2014年MAM,JJA,SON,DJFのファイル作成 (make_3monfile.sh)
# (3) GTOOLを読む & 季節毎トレンド計算 & 検定統計量T計算 & 有意性検定 & GTOOL形式で出力 & 描画  (cal_trend_T_sig_3mon_MAMJJASON.sh,cal_trend_T_sig_3mon_DJF.sh)

# (3)' 月毎、季節毎のトレンドの描画 (range=-10~10 ver)
# (3)'' 月毎、季節毎のトレンドの描画 (range=-10~10、北極点中心に北緯20-90度域をDCLで重ね描き)

# (4) トレンド、有意性の50例をmontage
# (4)' トレンド(range=-10~10)50例をmontage

#----------------------------------------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------------------------------------
# 月毎のトレンド
# (1) GTOOLを読む & 月毎トレンド計算 & 検定統計量T計算 & 有意性検定 & GTOOL形式で出力 & 描画  (cal_trend_T_sig_mon.sh)
#for runnum in $( seq 1 50 ) ; do
#       for mon in $( seq 1 12 ) ; do
#               ./cal_trend_T_sig_mon.sh $runnum $mon
#       done
#done

#----------------------------------------------------------------------------------------------------------------------------------------------
#季節毎のトレンド
# (2) データ番号を計算 & 1960-2014年MAM,JJA,SON,DJFのファイル作成 (make_3monfile.sh)
#for runnum in $( seq 1 50 ) ; do
#       for strmon in 3 6 9 12 ; do 
#               ./make_3monfile.sh $runnum $strmon
#       done
#done

# (3) GTOOLを読む & 季節毎トレンド計算 & 検定統計量T計算 & 有意性検定 & GTOOL形式で出力 & 描画  (cal_trend_T_sig_3mon_MAMJJASON.sh,cal_trend_T_sig_3mon_DJF.sh)
# MAM,JJA,SON
#for runnum in $( seq 1 50 ) ; do
#       for strmon in 3 6 9 ; do
#               ./cal_trend_T_sig_3mon_MAMJJASON.sh $runnum $strmon
#       done
#done

# DJF
#for runnum in $( seq 1 50 ) ; do
#       ./cal_trend_T_sig_3mon_DJF.sh $runnum
#done

# (3)' 月毎、季節毎のトレンドの描画 (range=-10~10 ver)
#for runnum in $( seq 1 50 ) ; do
#	for mon in 1 2 3 4 5 6 7 8 9 10 11 12 030405 060708 091011 120102 ; do
#		./dr_trend.sh $runnum $mon
#	done
#done

# (3)'' 月毎、季節毎のトレンドの描画 (range=-10~10、北極点中心に北緯20-90度域をDCLで重ね描き)
#for runnum in $( seq 1 50 ) ; do
#	for mon in 1 2 3 4 5 6 7 8 9 10 11 12 030405 060708 091011 120102 ; do
#		./draw_trend_sig_r1_50_mon_NP.sh $runnum $mon
#	done
#done

#----------------------------------------------------------------------------------------------------------------------------------------------
# (4) トレンド、有意性の50例をmontage
# 月毎
#for runnum in $( seq 1 50 ) ; do
#       for mon in $( seq 1 12 ) ; do
#               ./data_mon.sh $runnum $mon                  # データをシンボリックリンク (-> 不要 montage_mon.shに含む)
#       done
#done

#for runnum in $( seq 1 50 ) ; do
#       for mon in $( seq 1 12 ) ; do
#               ./convert.sh $runnum $mon                   # fileの切り取り (convert) (-> 不要 draw_trend_sig_r1_50_mon_NP.shに含む)
#        done
#done

#for mon in $( seq 1 12 ) ; do
#       for var in MIROC6_trend MIROC6_sig95_90_trend ; do
#               ./montage_mon.sh $mon $var                  # fileの並び替え (montage)
#               ./montage_mon.sh $mon                       # fileの並び替え (montage) <重ね描きの場合、varのループ不要>
#       done
#done

# 季節毎(MAM,JJA,SON,DJF)
#for runnum in $( seq 1 50 ) ; do
#       for mon in 030405 060708 091011 120102 ; do
#               ./data_mon.sh $runnum $mon                  # データをシンボリックリンク (-> 不要 montage_mon.shに含む)
#       done
#done

#for runnum in $( seq 1 50 ) ; do
#        for mon in 030405 060708 091011 120102 ; do
#                ./convert.sh $runnum $mon                  # fileの切り取り (convert) (-> 不要 draw_trend_sig_r1_50_mon_NP.shに含む)
#        done
#done

for mon in 030405 060708 091011 120102 ; do
#        for var in MIROC6_trend MIROC6_sig95_90_trend ; do
#                ./montage_mon.sh $mon $var                 # fileの並び替え (montage)
                ./montage_mon.sh $mon                       # fileの並び替え (montage) <重ね描きの場合、varのループ不要>
#        done
done

#----------------------------------------------------------------------------------------------------------------------------------------------
# (4)' トレンド(range=-10~10)50例をmontage
#for runnum in $( seq 1 50 ) ; do
#       for mon in 1 2 3 4 5 6 7 8 9 10 11 12 030405 060708 091011 120102 ; do
#               ./data_mon.sh $runnum $mon                  # データをシンボリックリンク
#               ./convert.sh $runnum $mon                   # fileの切り取り (convert)
#       done
#done

#for mon in 1 2 3 4 5 6 7 8 9 10 11 12 030405 060708 091011 120102 ; do
#	./montage_mon.sh $mon                              # fileの並び替え (montage)
#done


