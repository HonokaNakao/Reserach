#! /bin/bash
## 偏差データを作成するプログラム

# (1) ディレクトリ作成 & データをコピー (copy_orgdata.sh)
# (2) データフォーマット変更 [DFMT=URY16 -> DFMT=UR4] (ch_datafmt.sh)
# (3) data/run1/MIROC6_T2_1850 ~ data/run1/MIROC6_T2_2014をdata/run1/MIROC6_T2_1850_2014として結合する (ngtcat.sh)
# (4) 月毎の30年平年値を計算 [1961~1990年の1,2,...,12月の30年平年値] (cal_30ave.sh)
# (5) 月毎の偏差を計算 [ex:MIROC6_T2_run1_anomalies_1960_2014_1 = MIROC6_T2_run1_1960_2014_1 - MIROC6_T2_run1_30ave_1] (cal_anomaly.sh)
#
#----------------------------------------------------------------------------------------------------------------------------------------------
LTOP='/home/honoka/src/sample_code/MIROC6/DECK/historical'
LTOP2='/home/honoka/work/MIROC6/data'
stryr=1850
stryr2=1960
strmon=1
endyr=2014
endmon=12

# (1) ディレクトリ作成 & データをコピー (copy_orgdata.sh)
#./copy_orgdata.sh

# (2) データフォーマット変更 [DFMT=URY16 -> DFMT=UR4] (ch_datafmt.sh)
#for runnum in $( seq 1 50 ) ; do
#	./ch_datafmt.sh $runnum
#done

# (3) data/run1/MIROC6_T2_1850 ~ data/run1/MIROC6_T2_2014をdata/run1/MIROC6_T2_1850_2014として結合する (ngtcat.sh)
#for runnum in $( seq 1 50 ) ; do
#	./ngtcat.sh $runnum
#done

# (4) 月毎の30年平年値を計算 [1961~1990年の1,2,...,12月の30年平年値] (cal_30ave.sh)
#for runnum in $( seq 1 50 ) ; do
#	for mon in $( seq 1 12 ) ; do
#		./cal_30ave.sh $runnum $mon
#	done
#done

# (5) 月毎の偏差を計算 [ex:MIROC6_T2_run1_anomalies_1960_2014_1 = MIROC6_T2_run1_1960_2014_1 - MIROC6_T2_run1_30ave_1] (cal_anomaly.sh)
for runnum in $( seq 1 50 ) ; do
	for mon in $( seq 1 12 ) ; do
		./cal_anomaly.sh $runnum $mon
	done
done


