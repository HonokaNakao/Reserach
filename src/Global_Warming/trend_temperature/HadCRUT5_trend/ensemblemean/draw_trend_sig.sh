#! /bin/bash

# trend、sig95_90のデータをDCLで重ね描き
#    (例)trend_1960_2014_1_mon -> 1960年-2014年1月のトレンドデータ
#        sig95_90_trend_1960_2014_1_mon -> 1960年-2014年１月の有意性(90,95%)のデータ

#----------------------------------------------------------------------------------------------------------------------------------------------
# 月毎
#for month in $( seq 1 12 ) ; do
#    ./draw_trend_sig_mon.sh $month             # trend=-1~1で描画
#    ./draw_trend_sig_mon_rg-10_10.sh $month    # trend=-10~10で描画
#    ./draw_trend_sig_mon_rg-10_10_NP.sh $month  # trend=-10~10,北極点中心で描画 -> 画像の切り取り
#done

# 季節毎
for mon3 in 030405 060708 091011 120102 ; do
#    ./draw_trend_sig_mon.sh $mon3              # trend=-1~1で描画
#    ./draw_trend_sig_mon_rg-10_10.sh $mon3     # trend=-10~10で描画
    ./draw_trend_sig_mon_rg-10_10_NP.sh $mon3   # trend=-10~10,北極点中心で描画 -> 画像の切り取り
done


