#! /bin/bash
## MIROC6 50例からensemble dataを作成するプログラム

#----------------------------------------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------------------------------------

LTOP='/home/honoka/work/MIROC6'

var='MIROC6_T2'
stryr=1960
strmon=1
endyr=2014
endmon=12
mon=$1           # mon=1~12
yr=${stryr}_${endyr}
D1=anomalies_${yr}_${mon}_intpmk

cd ${LTOP}/data/run1_50/${var}_run1_50_ensemble_${yr}/${var}_run1_50_ensemble_${yr}_${mon}/                    # GTOOLの在り処に移動

# run1~10,11~20,21~30,31~40,41~50の平均値算出
for num in 1 11 21 31 41 ; do
	gtavr ${var}_run${num}_${D1} ${var}_run$((${num}+1))_${D1} ${var}_run$((${num}+2))_${D1} ${var}_run$((${num}+3))_${D1} ${var}_run$((${num}+4))_${D1} ${var}_run$((${num}+5))_${D1} \
	${var}_run$((${num}+6))_${D1} ${var}_run$((${num}+7))_${D1} ${var}_run$((${num}+8))_${D1} ${var}_run$((${num}+9))_${D1} \
	out:${var}_run${num}_$((${num}+9))_${D1}
done

# run1~50の平均値算出
gtavr ${var}_run1_10_${D1} ${var}_run11_20_${D1} ${var}_run21_30_${D1} ${var}_run31_40_${D1} ${var}_run41_50_${D1} out:${var}_run1_50_anomalies_ensemble_${yr}_${mon}

# 出力ファイルのヘッダー情報の更新
gtset ${var}_run1_50_anomalies_ensemble_${yr}_${mon} dset:'MIROC6 hist1-50' title:'T2 ensemblemean' out:${var}_run1_50_anomalies_ensemble_${yr}_${mon}
