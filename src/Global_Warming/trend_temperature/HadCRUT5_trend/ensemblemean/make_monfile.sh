#! /bin/bash

# GTOOLから特定期間のmonthly(月別)データファイルを作成
# (例) HadCRUT.5.0.1.0.analysis.anomalies.ensemble_mean.gt -> HadCRUT.5.0.1.0.analysis.anomalies.ensemble_mean_1960_2014 (1960年~2014年)

#----------------------------------------------------------------------------------------------------------------------------------------------

LTOP='/home/honoka/work/HadCRUT5'
DTOP='HadCRUT.5.0.1.0.analysis.anomalies.ensemble_mean'

## 年月からデータ番号を計算するfortranを組み込む
frstyr=1850                # gtoolデータの最初の年
frstmon=1                  # gtoolデータの最初の月
stryr=1960                 # 切り分ける最初の年
strmon=1                   # 切り分ける最初の月
#strmon=$1                  # 切り分ける最初の月 (1-12月でループさせる場合：月毎トレンド)
endyr=2014                 # 切り分ける最後の年
endmon=12                  # 切り分ける最後の月

strdata=$(( (${stryr}-${frstyr})*12+${strmon} ))
enddata=$(( (${endyr}-${frstyr})*12+${endmon} ))

echo ${strdata} ${enddata}

##--------
## 年毎のディレクトリ作成 (ex:1960_2014)
if [ ! -d ${DTOP}_${stryr}_${endyr} ] ; then
  mkdir ${LTOP}/data/data_ensemble_monthly/${DTOP}_${stryr}_${endyr}
fi
cd ${LTOP}/data/data_ensemble_monthly/${DTOP}_${stryr}_${endyr}

## 年毎のディレクトリ直下に月別年平均値のディレクトリ作成 (ex:1960_2014/1960_2014_1)
#if [ ! -d ${DTOP}_${stryr}_${endyr}_${strmon} ] ; then
#  mkdir ${LTOP}/data/data_ensemble_monthly/${DTOP}_${stryr}_${endyr}/${DTOP}_${stryr}_${endyr}_${strmon}
#fi
#cd ${LTOP}/data/data_ensemble_monthly/${DTOP}_${stryr}_${endyr}/${DTOP}_${stryr}_${endyr}_${strmon}

##--------
cp ${LTOP}/data/data_ensemble_monthly/${DTOP}.gt ./ 

## 1960年-2014年の月別データを切り分ける
#for name in {${strdata}..${enddata}} ; do 	
#	gtset ${DTOP}.gt str=${name} end=${name} out:${DTOP}_${name}${strmon}
#	gtset ${DTOP}.gt str=${name} end=${name} out:${DTOP}_${name}
#done

## 1960-2014年の月別データを作成
#gtset HadCRUT.5.0.1.0.analysis.anomalies.ensemble_mean.gt str=${strdata} end=${enddata} out:${DTOP}_${stryr}_${endyr}

## 1960-2014年の月別データ(1-12月毎)を作成
#gtset HadCRUT.5.0.1.0.analysis.anomalies.ensemble_mean.gt str=${strdata} end=${enddata} step=12 out:${DTOP}_${stryr}_${endyr}_${strmon} 

## 1960-2014年の3ヶ月データ(MAM,JJA,SON,DJF)


rm ./${DTOP}.gt

## 描画
#gtcont ${DTOP}_${stryr}_${endyr}_${strmon} map=1 color=50 -nocnt -print ps:${DTOP}_${stryr}_${endyr}_${strmon}.ps






