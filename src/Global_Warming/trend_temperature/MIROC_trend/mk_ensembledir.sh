#! /bin/bash
## MIROC6 50例からensemble dataを作成するプログラム

# (1) データを格納するディレクトリ作成
# (2) データをシンボリックリンクする
# (3) run1~50の月毎、季節毎のデータからそれぞれ平均値を算出
#----------------------------------------------------------------------------------------------------------------------------------------------
var='MIROC6_T2'
yr='1960_2014'
LTOP='/home/honoka/work/MIROC6/data'
LTOP2=${LTOP}/run1_50/${var}_run1_50_ensemble_${yr}
runnum=$1                                            # run1~50
mon=$2                                               # mon=1~12,030405,060708,091011,120102
num=1
endnm=anomalies_${yr}_${mon}_intpmk
endnm2=anomalies_${yr}_${mon}

#cd ${LTOP2}/    # データの在処に移動

# (1) データを格納するディレクトリ作成
#if [ ! -d ${var}_run1_50_ensemble_${yr}_${mon} ] ; then
#	mkdir ${LTOP2}/${var}_run1_50_ensemble_${yr}_${mon}
#fi
cd ${LTOP2}/${var}_run1_50_ensemble_${yr}_${mon}/

# (2) データをシンボリックリンクする
#if [ ${mon} -le 12 ] && [ ${mon} -ge 1 ]; then  # mon=1~12
#	ln -s ${LTOP}/run${runnum}/${var}_run${runnum}_${yr}_${mon}/${var}_run${runnum}_anomalies_${yr}_${mon}_intpmk ./
#else                                                 # mon=030405,060708,091011,120102
#	ln -s ${LTOP}/run${runnum}/${var}_run${runnum}_${yr}_${mon}/${var}_run${runnum}_anomalies_${yr}_${mon} ./
#fi

# (3) run1~50の月毎、季節毎のデータからそれぞれ平均値を算出 (失敗 -> mk_ensemble.f90)
if [ ${mon} -le 12 ] && [ ${mon} -ge 1 ]; then  # mon=1~12
	gtavr ${var}_run${num}_${endnm} \
		${var}_run$((${num}+1))_${endnm} ${var}_run$((${num}+2))_${endnm} ${var}_run$((${num}+3))_${endnm} ${var}_run$((${num}+4))_${endnm} ${var}_run$((${num}+5))_${endnm} \
		${var}_run$((${num}+6))_${endnm} ${var}_run$((${num}+7))_${endnm} ${var}_run$((${num}+8))_${endnm} ${var}_run$((${num}+9))_${endnm} ${var}_run$((${num}+10))_${endnm} \
		${var}_run$((${num}+11))_${endnm} ${var}_run$((${num}+12))_${endnm} ${var}_run$((${num}+13))_${endnm} ${var}_run$((${num}+14))_${endnm} ${var}_run$((${num}+15))_${endnm} \
		${var}_run$((${num}+16))_${endnm} ${var}_run$((${num}+17))_${endnm} ${var}_run$((${num}+18))_${endnm} ${var}_run$((${num}+19))_${endnm} ${var}_run$((${num}+20))_${endnm} \
		${var}_run$((${num}+21))_${endnm} ${var}_run$((${num}+22))_${endnm} ${var}_run$((${num}+23))_${endnm} ${var}_run$((${num}+24))_${endnm} ${var}_run$((${num}+25))_${endnm} \
		${var}_run$((${num}+26))_${endnm} ${var}_run$((${num}+27))_${endnm} ${var}_run$((${num}+28))_${endnm} ${var}_run$((${num}+29))_${endnm} ${var}_run$((${num}+30))_${endnm} \
		${var}_run$((${num}+31))_${endnm} ${var}_run$((${num}+32))_${endnm} ${var}_run$((${num}+33))_${endnm} ${var}_run$((${num}+34))_${endnm} ${var}_run$((${num}+35))_${endnm} \
		${var}_run$((${num}+36))_${endnm} ${var}_run$((${num}+37))_${endnm} ${var}_run$((${num}+38))_${endnm} ${var}_run$((${num}+39))_${endnm} ${var}_run$((${num}+40))_${endnm} \
		${var}_run$((${num}+41))_${endnm} ${var}_run$((${num}+42))_${endnm} ${var}_run$((${num}+43))_${endnm} ${var}_run$((${num}+44))_${endnm} ${var}_run$((${num}+45))_${endnm} \
		${var}_run$((${num}+46))_${endnm} ${var}_run$((${num}+47))_${endnm} ${var}_run$((${num}+48))_${endnm} ${var}_run$((${num}+49))_${endnm} \
		out:${var}_run1_50_anomalies_ensemble_${yr}_${mon}
else                                                 # mon=030405,060708,091011,120102
	gtavr ${var}_run${num}_${endnm2} \
		${var}_run$((${num}+1))_${endnm2} ${var}_run$((${num}+2))_${endnm2} ${var}_run$((${num}+3))_${endnm2} ${var}_run$((${num}+4))_${endnm2} ${var}_run$((${num}+5))_${endnm2} \
		${var}_run$((${num}+6))_${endnm2} ${var}_run$((${num}+7))_${endnm2} ${var}_run$((${num}+8))_${endnm2} ${var}_run$((${num}+9))_${endnm2} ${var}_run$((${num}+10))_${endnm2} \
		${var}_run$((${num}+11))_${endnm2} ${var}_run$((${num}+12))_${endnm2} ${var}_run$((${num}+13))_${endnm2} ${var}_run$((${num}+14))_${endnm2} ${var}_run$((${num}+15))_${endnm2} \
		${var}_run$((${num}+16))_${endnm2} ${var}_run$((${num}+17))_${endnm2} ${var}_run$((${num}+18))_${endnm2} ${var}_run$((${num}+19))_${endnm2} ${var}_run$((${num}+20))_${endnm2} \
		${var}_run$((${num}+21))_${endnm2} ${var}_run$((${num}+22))_${endnm2} ${var}_run$((${num}+23))_${endnm2} ${var}_run$((${num}+24))_${endnm2} ${var}_run$((${num}+25))_${endnm2} \
		${var}_run$((${num}+26))_${endnm2} ${var}_run$((${num}+27))_${endnm2} ${var}_run$((${num}+28))_${endnm2} ${var}_run$((${num}+29))_${endnm2} ${var}_run$((${num}+30))_${endnm2} \
		${var}_run$((${num}+31))_${endnm2} ${var}_run$((${num}+32))_${endnm2} ${var}_run$((${num}+33))_${endnm2} ${var}_run$((${num}+34))_${endnm2} ${var}_run$((${num}+35))_${endnm2} \
		${var}_run$((${num}+36))_${endnm2} ${var}_run$((${num}+37))_${endnm2} ${var}_run$((${num}+38))_${endnm2} ${var}_run$((${num}+39))_${endnm2} ${var}_run$((${num}+40))_${endnm2} \
		${var}_run$((${num}+41))_${endnm2} ${var}_run$((${num}+42))_${endnm2} ${var}_run$((${num}+43))_${endnm2} ${var}_run$((${num}+44))_${endnm2} ${var}_run$((${num}+45))_${endnm2} \
		${var}_run$((${num}+46))_${endnm2} ${var}_run$((${num}+47))_${endnm2} ${var}_run$((${num}+48))_${endnm2} ${var}_run$((${num}+49))_${endnm2} \
		out:${var}_run1_50_anomalies_ensemble_${yr}_${mon}
fi
