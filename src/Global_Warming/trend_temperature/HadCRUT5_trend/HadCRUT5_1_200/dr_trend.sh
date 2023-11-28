#! /bin/bash
## HadCRUT5 200例のトレンドを描画するプログラム (range=-10~10)

#----------------------------------------------------------------------------------------------------------------------------------------------
LTOP='/home/honoka/work/HadCRUT5/data/data_analysis_gridded_1_200'
LTOP2='/home/honoka/work/HadCRUT5'
DTOP='HadCRUT.5.0.1.0.analysis.anomalies'
stryr=1960
strmon=1
endyr=2014
endmon=12
yr=${stryr}_${endyr}
runnum=$1                       # runnum=1~50 (run1~run50)
mon=$2                          # mon=1~12, 030405, 060708, 091011, 120102

cd ${LTOP}/${DTOP}.${runnum}/${DTOP}.${runnum}_${yr}/${DTOP}.${runnum}_${yr}_${mon}/ # データの在り処に移動

# 作業ディレクトリにカラーマップが無い場合 (polar以外など)
ln -s /usr/local/dcl/lib/dcldbase/colormap_67.x11 colormap.x11           # 特定のカラーマップをcolormap.x11としてシンボリックリンクする
gtcont trend.${runnum}_${yr}_${mon}_mon tone=-10,-1,-0.6,-0.4,-0.2,-0.1,0.0,0.1,0.2,0.4,0.6,1.0,10 pat=10999,12999,22999,28999,48999,53999,58999,65999,70999,89999,97999,99999 map=1 -nocnt -print ps:trend.${runnum}_${yr}_${mon}_mon_rg-10_10.ps
rm colormap.x11

# psファイルからpngファイルへ形式変更
convert -density 100 -rotate 90 trend.${runnum}_${yr}_${mon}_mon_rg-10_10.ps trend.${runnum}_${yr}_${mon}_mon_rg-10_10.png

