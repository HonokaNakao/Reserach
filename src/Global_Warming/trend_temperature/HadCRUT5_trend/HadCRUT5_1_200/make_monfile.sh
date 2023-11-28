#! /bin/bash

# GTOOLから特定期間のmonthly(月別)データファイルを作成
# (例) HadCRUT.5.0.1.0.analysis.anomalies.ensemble_mean.gt -> HadCRUT.5.0.1.0.analysis.anomalies.ensemble_mean_1960_2014 (1960年~2014年)

#----------------------------------------------------------------------------------------------------------------------------------------------

LTOP='/home/honoka/work/HadCRUT5'
DTOP='HadCRUT.5.0.1.0.analysis.anomalies'

## 年月からデータ番号を計算するfortranを組み込む
datanum=$1                 # ensemble data番号 (= 1~200)
frstyr=1850                # gtoolデータの最初の年
frstmon=1                  # gtoolデータの最初の月
stryr=1960                 # 切り分ける最初の年
strmon=1                  # 切り分ける最初の月 (1-12月でループさせる場合：月毎トレンド)
mon=$2                     # 切り分ける最初の月 (1-12月でループさせる場合：月毎トレンド)
endyr=2014                 # 切り分ける最後の年
endmon=12                  # 切り分ける最後の月

strdata=$(( (${stryr}-${frstyr})*12+${strmon} ))
enddata=$(( (${endyr}-${frstyr})*12+${endmon} ))
echo ${strdata} ${enddata}

strdata2=$(( (${stryr}-${frstyr})*12+${mon} ))

##--------
## 年毎のディレクトリ作成 (ex:1960_2014)
if [ ! -d ${DTOP}.${datanum}_${stryr}_${endyr} ] ; then
  mkdir ${LTOP}/data/data_analysis_gridded_1_200/${DTOP}.${datanum}/${DTOP}.${datanum}_${stryr}_${endyr}
fi
cd ${LTOP}/data/data_analysis_gridded_1_200/${DTOP}.${datanum}/${DTOP}.${datanum}_${stryr}_${endyr}
cp ${LTOP}/data/data_analysis_gridded_1_200/${DTOP}.${datanum}/${DTOP}.${datanum}.gt ./ 

## 1960-2014年の月別データを作成
gtset ${DTOP}.${datanum}.gt str=${strdata} end=${enddata} out:${DTOP}.${datanum}_${stryr}_${endyr}
rm ./${DTOP}.${datanum}.gt
gtcont ${DTOP}.${datanum}_${stryr}_${endyr} map=1 color=50 -nocnt -print ps:${DTOP}.${datanum}_${stryr}_${endyr}.ps

## 年毎のディレクトリ直下に月別年平均値のディレクトリ作成 (ex:1960_2014/1960_2014_1)
#for mon in $( seq 1 12 ) ; do
#	if [ ! -d ${DTOP}.${datanum}_${stryr}_${endyr}_${mon} ] ; then
#		mkdir ${LTOP}/data/data_analysis_gridded_1_200/${DTOP}.${datanum}/${DTOP}.${datanum}_${stryr}_${endyr}/${DTOP}.${datanum}_${stryr}_${endyr}_${mon}
#        fi
#done
	
#if [ ! -d ${DTOP}.${datanum}_${stryr}_${endyr}_${mon} ] ; then
#	mkdir ${LTOP}/data/data_analysis_gridded_1_200/${DTOP}.${datanum}/${DTOP}.${datanum}_${stryr}_${endyr}/${DTOP}.${datanum}_${stryr}_${endyr}_${mon}
#fi

#cd ${LTOP}/data/data_analysis_gridded_1_200/${DTOP}.${datanum}/${DTOP}.${datanum}_${stryr}_${endyr}/${DTOP}.${datanum}_${stryr}_${endyr}_${mon}/
#cp ${LTOP}/data/data_analysis_gridded_1_200/${DTOP}.${datanum}/${DTOP}.${datanum}.gt ./ 

## 1960-2014年の月別データ(1-12月毎)を作成
#rm ${DTOP}_${stryr}_${endyr}_${mon}
#gtset ${DTOP}.${datanum}.gt str=${strdata2} end=${enddata} step=12 out:${DTOP}.${datanum}_${stryr}_${endyr}_${mon} 
#gtcont ${DTOP}.${datanum}_${stryr}_${endyr}_${mon} map=1 color=50 -nocnt -print ps:${DTOP}.${datanum}_${stryr}_${endyr}_${mon}.ps
#rm ./${DTOP}.${datanum}.gt







