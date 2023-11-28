#! /bin/bash

# 月毎の30年平年値を計算するプログラム
#
# (1) 月毎の30年平年値を計算 [1961~1990年の1,2,...,12月の30年平年値] (cal_30ave.sh)
# (2) 月毎のファイルに分割 (MIROC6_T2_run1_1960_2014 -> MIROC6_T2_run1_1960_2014_1)
# (3) 月毎の30年平年値を算出 [1961~1990年の1,2,...,12月の30年平年値] (ex:MIROC6_T2_run1_30ave_1)
#----------------------------------------------------------------------------------------------------------------------------------------------
LTOP='/home/honoka/src/sample_code/MIROC6/DECK/historical'
LTOP2='/home/honoka/work/MIROC6/data'
stryr=1850
stryr2=1960
strmon=1
endyr=2014
endmon=12
yr=$(( ${endyr}-${stryr2}+1 ))  # yr=55 (=2014-1960+1)
runnum=$1                       # runnum=1~50 (run1~run50)
mon=$2                          # mon=1~12
var=MIROC6_T2

#----------------------------------------------------------------------------------------------------------------------------------------------
# (1) 切り取るデータ番号を計算
strdata=$(( ${yr}*(${mon}-1)+1 ))
enddata=$(( ${yr}*${mon} ))
echo ${strdata} ${enddata}

#----------------------------------------------------------------------------------------------------------------------------------------------
# (2) 月毎のファイルに分割 (MIROC6_T2_run1_1960_2014 -> MIROC6_T2_run1_1960_2014_1)
cd ${LTOP2}/run${runnum}/

if [ ! -d ${var}_run${runnum}_${stryr2}_${endyr}_${mon} ] ; then
	mkdir ${LTOP2}/run${runnum}/${var}_run${runnum}_${stryr2}_${endyr}_${mon}/
fi
cd ${LTOP2}/run${runnum}/${var}_run${runnum}_${stryr2}_${endyr}_${mon}/

cp ${LTOP2}/run${runnum}/${var}_run${runnum}_${stryr2}_${endyr} ./      # MIROC6_T2_run1_1960_2014をコピー

gtset ${var}_run${runnum}_${stryr2}_${endyr} str=${strdata} end=${enddata} out:${var}_run${runnum}_${stryr2}_${endyr}_${mon}
#gtcont ${var}_run${runnum}_${stryr2}_${endyr}_${mon} map=1 color=50 -nocnt -print ps:${var}_run${runnum}_${stryr2}_${endyr}_${mon}.ps

rm ${var}_run${runnum}_${stryr2}_${endyr}

#----------------------------------------------------------------------------------------------------------------------------------------------
# (3) 月毎の30年平年値を算出 [1961~1990年の1,2,...,12月の30年平年値] (ex:MIROC6_T2_run1_30ave_1)
strdata2=$(( 1961-${stryr2}+1 ))
enddata2=$(( 1990-${stryr2}+1 ))

gtavr ${var}_run${runnum}_${stryr2}_${endyr}_${mon} str=${strdata2} end=${enddata2} out:${var}_run${runnum}_30ave_${mon}














