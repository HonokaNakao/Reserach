#! /bin/bash
## MIROC6 50例のトレンドを描画するプログラム (range=-10~10)

#----------------------------------------------------------------------------------------------------------------------------------------------

LTOP='/home/honoka/work/MIROC6/data'
runnum=$1                             # runnum=1~50
mon=$2                                # mon=1~12,030405,060708,091011,120102
var='MIROC6_T2'
yr='1960_2014'

cd ${LTOP}/run${runnum}/${var}_run${runnum}_${yr}_${mon}/                # データの在り処に移動

# 作業ディレクトリにカラーマップが無い場合 (polar以外など)
ln -s /usr/local/dcl/lib/dcldbase/colormap_67.x11 colormap.x11           # 特定のカラーマップをcolormap.x11としてシンボリックリンクする
gtcont MIROC6_trend.${runnum}_${yr}_${mon}_mon tone=-10,-1,-0.6,-0.4,-0.2,-0.1,0.0,0.1,0.2,0.4,0.6,1.0,10 pat=10999,12999,22999,28999,48999,53999,58999,65999,70999,89999,97999,99999 map=1 -nocnt -print ps:MIROC6_trend.${runnum}_${yr}_${mon}_mon_rg-10_10.ps
rm colormap.x11

# psファイルからpngファイルへ形式変更
convert -density 100 -rotate 90 MIROC6_trend.${runnum}_${yr}_${mon}_mon_rg-10_10.ps MIROC6_trend.${runnum}_${yr}_${mon}_mon_rg-10_10.png
