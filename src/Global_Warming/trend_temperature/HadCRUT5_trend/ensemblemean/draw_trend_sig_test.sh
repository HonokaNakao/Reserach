#! /bin/bash

# トレンド(trend)と有意性(sig95_90)をDCLで重ね描きするプログラム
# 1960~2014年1月
#
#----------------------------------------------------------------------------------------------------------
LTOP='/home/honoka/work/HadCRUT5'
DTOP='HadCRUT.5.0.1.0.analysis.anomalies.ensemble_mean'

# GTOOLの軸ファイルに対して作業ディレクトリからリンクを張る
ln -s /usr/local/gtool3.5/lib/gt3/GTAXLOC.GLAT36IM ./        # 緯度情報軸ファイル
ln -s /usr/local/gtool3.5/lib/gt3/GTAXLOC.GLON72CM ./        # 経度情報軸ファイル

# 元データに対して作業ディレクトリからリンクを貼る
ln -s ${LTOP}/data/data_ensemble_monthly/${DTOP}_1960_2014/${DTOP}_1960_2014_5/trend_1960_2014_5_mon ./           # トレンド (trend)
ln -s ${LTOP}/data/data_ensemble_monthly/${DTOP}_1960_2014/${DTOP}_1960_2014_5/sig95_90_trend_1960_2014_5_mon ./  # 有意性 (sig95_90)


# DCLで重ね描きするFortranプログラムをコンパイル (draw_trend_sig.f90)
#dclfrt draw_trend_sig.f90 -fconvert=big-endian && ./a.out  
dclfrt draw_trend_sig.f90 && ./a.out                            # DCLで描画する際は、little-endianでコンパイルする(draw_trend.sig.f90内で、gtoolのみbig-endian指定する) 
#dclfrt test.f90 && ./a.out                            # DCLで描画する際は、little-endianでコンパイルする(draw_trend.sig.f90内で、gtoolのみbig-endian指定する) 


# 軸ファイルを削除
rm a.out GTAXLOC* trend_1960_2014_5_mon sig95_90_trend_1960_2014_5_mon



