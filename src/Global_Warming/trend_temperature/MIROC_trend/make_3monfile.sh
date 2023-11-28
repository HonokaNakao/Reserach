#! /bin/bash

# monthlyデータから年間3ヶ月抽出したGTOOLファイルを作成。
# (例) DJF：1960-2014年のmonthlyデータ -> 1960.1,2,3、1961.1,2,3、… 2014.1,2,3 (55年× 3 ヶ月のファイル)
#
#----------------------------------------------------------------------------------------------------------

LTOP='/home/honoka/work/MIROC6'

runnum=$1
var='MIROC6_T2'
#frstyr=1850                                     # gtoolデータの最初の年
frstyr=1960                                      # gtoolデータの最初の年
frstmon=1                                        # gtoolデータの最初の月
stryr=1960                                       # 切り分ける最初の年
strmon=$2                                        # strmon=3(MAM), 6(JJA), 9(SON), 12(DJF)
endyr=2014                                       # 切り分ける最後の年
#endmon=11                                       # 切り分ける最後の月

DTOP=${var}_run${runnum}_anomalies_${stryr}_${endyr}_${strmon}_intpmk
DTOP2=${var}_run${runnum}_anomalies_${stryr}_${endyr}

if [ ${strmon} -lt 9 ] ; then                    # strmon=3,6の場合  
	midmon=$(( $strmon+1 ))                  # midmon=4,7
	endmon=$(( $strmon+2 ))                  # endmon=5,8
	mon3=0${strmon}0${midmon}0${endmon}
elif [ ${strmon} -eq 9 ] ; then                  # strmon=9(SON)の場合
	midmon=$(( $strmon+1 ))                  # midmon=10
	endmon=$(( $strmon+2 ))                  # endmon=11
	mon3=0${strmon}${midmon}${endmon}
else                                             # strmon=12(DJF)の場合
	midmon=1   
	endmon=2
	mon3=${strmon}0102
fi

#----------------------------------------------------------------------------
# 3ヶ月毎のディレクトリを作成
if [ ! -d ${var}_run${runnum}_${stryr}_${endyr}_${mon3} ] ; then
	mkdir ${LTOP}/data/run${runnum}/${var}_run${runnum}_${stryr}_${endyr}_${mon3}
fi

cd ${LTOP}/data/run${runnum}/${var}_run${runnum}_${stryr}_${endyr}_${mon3}/

#----------------------------------------------------------------------------
# 月毎のデータをシンボリックリンクする
ln -s ${LTOP}/data/run${runnum}/${var}_run${runnum}_${stryr}_${endyr}_${strmon}/${DTOP2}_${strmon}_intpmk ./
ln -s ${LTOP}/data/run${runnum}/${var}_run${runnum}_${stryr}_${endyr}_${midmon}/${DTOP2}_${midmon}_intpmk ./
ln -s ${LTOP}/data/run${runnum}/${var}_run${runnum}_${stryr}_${endyr}_${endmon}/${DTOP2}_${endmon}_intpmk ./

#----------------------------------------------------------------------------
# 1960~2013年12月,1961~2014年1,2月のファイルに切り出す
ngtcat ${DTOP2}_12_intpmk -t 1:54 > ${var}_run${runnum}_${stryr}_2013_12_intpmk
ngtcat ${DTOP2}_1_intpmk -t 2:55 > ${var}_run${runnum}_1961_${endyr}_1_intpmk
ngtcat ${DTOP2}_2_intpmk -t 2:55 > ${var}_run${runnum}_1961_${endyr}_2_intpmk

#----------------------------------------------------------------------------
# 年間3ヶ月毎に抽出したGTOOLファイルを作成
if [ ${strmon} -le 9 ] ; then                    # strmon=3,6,9の場合
	ngtcat -c ${DTOP2}_${strmon}_intpmk ${DTOP2}_${midmon}_intpmk ${DTOP2}_${endmon}_intpmk > ${DTOP2}_${mon3}
else                                             # strmon=12の場合
	ngtcat -c ${var}_run${runnum}_${stryr}_2013_12_intpmk ${var}_run${runnum}_1961_${endyr}_1_intpmk ${var}_run${runnum}_1961_${endyr}_2_intpmk > ${DTOP2}_${mon3}
fi

#----------------------------------------------------------------------------
	
#gtcont ${DTOP2}_${mon3} map=1 color=50 -nocnt -print ps:${DTOP2}_${mon3}.ps

mv ${var}_run${runnum}_${stryr}_2013_12_intpmk ${LTOP}/data/run${runnum}/${var}_run${runnum}_${stryr}_${endyr}_12/
mv ${var}_run${runnum}_1961_${endyr}_1_intpmk ${LTOP}/data/run${runnum}/${var}_run${runnum}_${stryr}_${endyr}_1/
mv ${var}_run${runnum}_1961_${endyr}_2_intpmk ${LTOP}/data/run${runnum}/${var}_run${runnum}_${stryr}_${endyr}_2/

rm ./*_intpmk




