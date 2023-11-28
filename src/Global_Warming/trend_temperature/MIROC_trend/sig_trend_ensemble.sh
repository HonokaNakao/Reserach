#! /bin/bash
## MIROC6 ensemble dataのトレンド計算 & 有意性検定を行うプログラム
## 50例からensemble dataを作成 (mk_ensemble.sh)

# (1) データを格納するディレクトリ作成 & データをシンボリックリンクする (mk_ensembledir.sh)
# (2) run1~50のデータをシンボリックリンクする (ex:MIROC6_T2_run1_anomalies_1960_2014_1_intpmk)
# (3) MIROC6 50例の平均値を算出する (mk_ensemblemean2.sh)
# (4) MIROC6 ensemblemeanの月毎、季節毎のトレンド算出 & 有意性検定 (cal_ensm_trend_T_sig_mon.sh)
# (5) MIROC6 ensemblemean trend、sig95_90のデータをDCLで重ね描き (draw_trend_sig_mon.sh)
# (6) MIROC6 ensemblemeanの月毎、季節毎のトレンド & 有意性をmontage (montage_ensm_mon.sh)

#----------------------------------------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------------------------------------
# (1) データを格納するディレクトリ作成 & データをシンボリックリンクする (mk_ensemble.sh)
#for runnum in $( seq 1 50 ) ; do
#       for mon in 1 2 3 4 5 6 7 8 9 10 11 12 030405 060708 091011 120102 ; do
#               ./mk_ensembledir.sh $runnum $mon
#       done
#done

# (2) run1~50のデータをシンボリックリンクする (ex:MIROC6_T2_run1_anomalies_1960_2014_1_intpmk)
#for runnum in $( seq 1 50 ) ; do
#       for mon in $( seq 1 12 ) ; do
#               ./symbolic.sh $runnum $mon
#       done
#done

# (3) MIROC6 50例の平均値を算出する (mk_ensemblemean2.sh)
#for mon in $( seq 1 12 ) ; do
#	./mk_ensemblemean2.sh $mon
#done

# (4) MIROC6 ensemblemeanの月毎、季節毎のトレンド算出 & 有意性検定 (cal_ensm_trend_T_sig_mon.sh)
# 月毎
#for mon in $( seq 1 12 ) ; do
#	./cal_ensm_trend_T_sig_mon.sh $mon
#done

# 季節毎
#for strmon in 3 6 9 12 ; do
#	./make_3monfile_ensm.sh $strmon                      # 3ヶ月毎のファイルを作成
#done

#for strmon in 3 6 9 ; do                                    # MAM, JJA, SONの場合  
#	./cal_ensm_trend_T_sig_3mon_MAMJJASON.sh $strmon
#done

#./cal_ensm_trend_T_sig_3mon_DJF.sh                          # DJFの場合

# (5) MIROC6 ensemblemean trend、sig95_90のデータをDCLで重ね描き (draw_trend_sig_mon.sh)
# 月毎
#for mon in $( seq 1 12 ) ; do
#    ./draw_trend_sig_mon.sh $mon                            # trend=-10~10で描画
#    ./draw_trend_sig_mon_NP.sh $mon                         # trend=-10~10、北極点中心で描画 -> 画像の切り取り
#done

# 季節毎
#for mon3 in 030405 060708 091011 120102 ; do
#    ./draw_trend_sig_mon.sh $mon3                           # trend=-10~10で描画
#    ./draw_trend_sig_mon_NP.sh $mon3                         # trend=-10~10、北極点中心で描画 -> 画像の切り取り
#done

# (6) MIROC6 ensemblemeanの月毎、季節毎のトレンド & 有意性をmontage (montage_ensm_mon.sh)
# 月毎
#for mon in $( seq 1 12 ) ; do
#	./montage_ensm_mon.sh $mon
#done

#	./montage_ensm_mon.sh                                # 切り取りver

# 季節毎
#for mon3 in 030405 060708 091011 120102 ; do
#	./montage_ensm_mon.sh $mon3
#done
	./montage_ensm_mon.sh                                # 切り取りver

