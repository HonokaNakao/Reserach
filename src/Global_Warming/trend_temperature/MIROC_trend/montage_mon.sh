#! /bin/bash

## トレンドと有意性を1つのpngファイルに出力するプログラム
#-----------------------------------------------------------------

LTOP='/home/honoka/work/MIROC6/data/run1_50'
LTOP2='/home/honoka/work/MIROC6/data/run'

DTOP='MIROC6_T2'
DTOP2='MIROC6_T2_run'
stryr=1960
endyr=2014
yr=${stryr}_${endyr}

#endnm=${yr}_${mon}_mon_rg-1_1.png   # trend fileの末尾
endnm=${yr}_${mon}_mon_rg-10_10.png  # trend fileの末尾
endnm2=${yr}_${mon}_mon.png          # sig95_90 fileの末尾

mon=$1                               # mon=1~12
#var=$2                              # var=MIROC6_trend,MIROC6_sig95_90_trend
#var=MIROC6_trend
var=MIROC6_trend_sig9590
#endnm=${mon}.png                    # convert済みfileの末尾
#endnm=${mon}_rg-10_10.png            # convert済みfileの末尾
endnm=${mon}_NP           
#num=1                                # num=1,101
tm=${yr}_${mon}                      # time

cd ${LTOP}/${DTOP}_run1_50_${yr}_${mon}/

# trend, sig95_90
#montage -tile 5x10 -geometry 891x455+0+0 \
#	${var}.${num}_${endnm} ${var}.$(($num+1))_${endnm} ${var}.$(($num+2))_${endnm} ${var}.$(($num+3))_${endnm} ${var}.$(($num+4))_${endnm} ${var}.$(($num+5))_${endnm} \
#	${var}.$(($num+6))_${endnm} ${var}.$(($num+7))_${endnm} ${var}.$(($num+8))_${endnm} ${var}.$(($num+9))_${endnm} ${var}.$(($num+10))_${endnm} \
#	${var}.$(($num+11))_${endnm} ${var}.$(($num+12))_${endnm} ${var}.$(($num+13))_${endnm} ${var}.$(($num+14))_${endnm} ${var}.$(($num+15))_${endnm} \
#	${var}.$(($num+16))_${endnm} ${var}.$(($num+17))_${endnm} ${var}.$(($num+18))_${endnm} ${var}.$(($num+19))_${endnm} ${var}.$(($num+20))_${endnm} \
#	${var}.$(($num+21))_${endnm} ${var}.$(($num+22))_${endnm} ${var}.$(($num+23))_${endnm} ${var}.$(($num+24))_${endnm} ${var}.$(($num+25))_${endnm} \
#	${var}.$(($num+26))_${endnm} ${var}.$(($num+27))_${endnm} ${var}.$(($num+28))_${endnm} ${var}.$(($num+29))_${endnm} ${var}.$(($num+30))_${endnm} \
#	${var}.$(($num+31))_${endnm} ${var}.$(($num+32))_${endnm} ${var}.$(($num+33))_${endnm} ${var}.$(($num+34))_${endnm} ${var}.$(($num+35))_${endnm} \
#	${var}.$(($num+36))_${endnm} ${var}.$(($num+37))_${endnm} ${var}.$(($num+38))_${endnm} ${var}.$(($num+39))_${endnm} ${var}.$(($num+40))_${endnm} \
#	${var}.$(($num+41))_${endnm} ${var}.$(($num+42))_${endnm} ${var}.$(($num+43))_${endnm} ${var}.$(($num+44))_${endnm} ${var}.$(($num+45))_${endnm} \
#	${var}.$(($num+46))_${endnm} ${var}.$(($num+47))_${endnm} ${var}.$(($num+48))_${endnm} ${var}.$(($num+49))_${endnm} \
#	${var}_1_50_${endnm}

# trendのsig95_90重ね描き (北緯20-90度)
montage -tile 5x10 -geometry 664x470+0+0 \
	${LTOP2}1/${DTOP2}1_${tm}/${var}.1_${endnm} ${LTOP2}2/${DTOP2}2_${tm}/${var}.2_${endnm} ${LTOP2}3/${DTOP2}3_${tm}/${var}.3_${endnm} ${LTOP2}4/${DTOP2}4_${tm}/${var}.4_${endnm} \
	${LTOP2}5/${DTOP2}5_${tm}/${var}.5_${endnm} ${LTOP2}6/${DTOP2}6_${tm}/${var}.6_${endnm} ${LTOP2}7/${DTOP2}7_${tm}/${var}.7_${endnm} ${LTOP2}8/${DTOP2}8_${tm}/${var}.8_${endnm} \
	${LTOP2}9/${DTOP2}9_${tm}/${var}.9_${endnm} ${LTOP2}10/${DTOP2}10_${tm}/${var}.10_${endnm} ${LTOP2}11/${DTOP2}11_${tm}/${var}.11_${endnm} ${LTOP2}12/${DTOP2}12_${tm}/${var}.12_${endnm} \
	${LTOP2}13/${DTOP2}13_${tm}/${var}.13_${endnm} ${LTOP2}14/${DTOP2}14_${tm}/${var}.14_${endnm} ${LTOP2}15/${DTOP2}15_${tm}/${var}.15_${endnm} ${LTOP2}16/${DTOP2}16_${tm}/${var}.16_${endnm} \
	${LTOP2}17/${DTOP2}17_${tm}/${var}.17_${endnm} ${LTOP2}18/${DTOP2}18_${tm}/${var}.18_${endnm} ${LTOP2}19/${DTOP2}19_${tm}/${var}.19_${endnm} ${LTOP2}20/${DTOP2}20_${tm}/${var}.20_${endnm} \
	${LTOP2}21/${DTOP2}21_${tm}/${var}.21_${endnm} ${LTOP2}22/${DTOP2}22_${tm}/${var}.22_${endnm} ${LTOP2}23/${DTOP2}23_${tm}/${var}.23_${endnm} ${LTOP2}24/${DTOP2}24_${tm}/${var}.24_${endnm} \
	${LTOP2}25/${DTOP2}25_${tm}/${var}.25_${endnm} ${LTOP2}26/${DTOP2}26_${tm}/${var}.26_${endnm} ${LTOP2}27/${DTOP2}27_${tm}/${var}.27_${endnm} ${LTOP2}28/${DTOP2}28_${tm}/${var}.28_${endnm} \
	${LTOP2}29/${DTOP2}29_${tm}/${var}.29_${endnm} ${LTOP2}30/${DTOP2}30_${tm}/${var}.30_${endnm} ${LTOP2}31/${DTOP2}31_${tm}/${var}.31_${endnm} ${LTOP2}32/${DTOP2}32_${tm}/${var}.32_${endnm} \
	${LTOP2}33/${DTOP2}33_${tm}/${var}.33_${endnm} ${LTOP2}34/${DTOP2}34_${tm}/${var}.34_${endnm} ${LTOP2}35/${DTOP2}35_${tm}/${var}.35_${endnm} ${LTOP2}36/${DTOP2}36_${tm}/${var}.36_${endnm} \
	${LTOP2}37/${DTOP2}37_${tm}/${var}.37_${endnm} ${LTOP2}38/${DTOP2}38_${tm}/${var}.38_${endnm} ${LTOP2}39/${DTOP2}39_${tm}/${var}.39_${endnm} ${LTOP2}40/${DTOP2}40_${tm}/${var}.40_${endnm} \
	${LTOP2}41/${DTOP2}41_${tm}/${var}.41_${endnm} ${LTOP2}42/${DTOP2}42_${tm}/${var}.42_${endnm} ${LTOP2}43/${DTOP2}43_${tm}/${var}.43_${endnm} ${LTOP2}44/${DTOP2}44_${tm}/${var}.44_${endnm} \
	${LTOP2}45/${DTOP2}45_${tm}/${var}.45_${endnm} ${LTOP2}46/${DTOP2}46_${tm}/${var}.46_${endnm} ${LTOP2}47/${DTOP2}47_${tm}/${var}.47_${endnm} ${LTOP2}48/${DTOP2}48_${tm}/${var}.48_${endnm} \
	${LTOP2}49/${DTOP2}49_${tm}/${var}.49_${endnm} ${LTOP2}50/${DTOP2}50_${tm}/${var}.50_${endnm} \
	${var}_1_50_${endnm}
