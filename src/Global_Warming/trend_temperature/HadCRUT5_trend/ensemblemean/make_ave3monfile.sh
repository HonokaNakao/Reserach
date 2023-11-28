# ! /bin/bash

# 1年から3ヶ月毎に抽出したファイルから3ヶ月事の平均値を作成
# (例) 1960年3,4,5月、1961年3,4,5月、… 2014年3,4,5月 -> 1960年MAMの平均値、1961年MAMの平均値 … 2014年MAMの平均値 
#      HadCRUT.5.0.1.0.analysis.anomalies.ensemble_mean_1960_2014_030405 -> HadCRUT.5.0.1.0.analysis.anomalies.ensemble_mean_1960_2014_ave030405
#
#--------------------------------------------------------------------------------------------------------------------------------------------------

LTOP='/home/honoka/work/HadCRUT5'
DTOP='HadCRUT.5.0.1.0.analysis.anomalies.ensemble_mean'
mon3='120102'                                                                        # MAM(030405), JAJ(060708), SON(091011), DJF(120102)

cd ${LTOP}/data/data_ensemble_monthly/${DTOP}_1960_2014/${DTOP}_1960_2014_${mon3}    # 3ヶ月毎に抽出したファイルの在処

# 3ヶ月毎に平均値を作成したGTOOLファイルの作成(例) 1960年3,4,5 … 2014年3,4,5月 -> 1960年MAMの平均値 … 2014年MAMの平均値
gtavr ${DTOP}_1960_2014_${mon3} ostep=3 out:${DTOP}_1960_2014_ave${mon3}

gtcont ${DTOP}_1960_2014_ave${mon3} map=1 color=50 -nocnt -print ps:${DTOP}_1960_2014_ave${mon3}.ps
