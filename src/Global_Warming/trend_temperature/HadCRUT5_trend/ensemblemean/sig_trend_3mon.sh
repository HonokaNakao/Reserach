#! /bin/bash

## トレンド計算をするプログラム
# (1) データ番号を計算 & 年間3ヶ月抽出したファイルの作成   (make_3monfile.sh)
# (2) GTOOLを読む & トレンド計算 & 検定統計量T & 有意性検定 & GTOOL形式で出力 & 描画  (cal_trend_T_sig_3mon.sh)
#     -> [1]trend [2]sig95_90
#-----------------------------------------------------------------

LTOP='/home/honoka/work/HadCRUT5'
DTOP='HadCRUT.5.0.1.0.analysis.anomalies.ensemble_mean'

# (1) データ番号を計算 & 年間3ヶ月抽出したファイルの作成   (make_3monfile.sh)
#cd ${LTOP}/src/t_test/t_test_ensemblemean/
#./make_3monfile.sh

# (2) GTOOLを読む & トレンド計算 & 検定統計量計算T & 有意性検定 & GTOOL形式で出力 & 描画  (cal_trend_T_sig_3mon.sh)
./cal_trend_T_sig_3mon.sh 



