#! /bin/bash

## トレンドと有意性を1つのpngファイルに出力するプログラム
#-----------------------------------------------------------------

LTOP='/home/honoka/work/HadCRUT5'
DTOP='HadCRUT.5.0.1.0.analysis.anomalies'

stryr=1960
endyr=2014
yr=${stryr}_${endyr}
mon=$1                              # mon=1~12
#var=$2                             # var=trend,sig95_90_trend
var=trend
#endnm=${mon}.png                   # convert済みfileの末尾
endnm=${mon}_rg-10_10.png           # convert済みfileの末尾
#endnm=${yr}_${mon}_mon_rg-1_1.png  # trend fileの末尾
#endnm2=${yr}_${mon}_mon.png        # sig95_90 fileの末尾
num=1                               # num=1,101

cd ${LTOP}/data/data_analysis_gridded_1_200/${DTOP}.1_200_${stryr}_${endyr}_${mon}/  # データの在り処へ移動

# trend, sig95_90
montage -tile 10x20 -geometry 891x455+0+0 \
	${var}.${num}_${endnm} ${var}.$(($num+1))_${endnm} ${var}.$(($num+2))_${endnm} ${var}.$(($num+3))_${endnm} ${var}.$(($num+4))_${endnm} ${var}.$(($num+5))_${endnm} \
	${var}.$(($num+6))_${endnm} ${var}.$(($num+7))_${endnm} ${var}.$(($num+8))_${endnm} ${var}.$(($num+9))_${endnm} ${var}.$(($num+10))_${endnm} \
	${var}.$(($num+11))_${endnm} ${var}.$(($num+12))_${endnm} ${var}.$(($num+13))_${endnm} ${var}.$(($num+14))_${endnm} ${var}.$(($num+15))_${endnm} \
	${var}.$(($num+16))_${endnm} ${var}.$(($num+17))_${endnm} ${var}.$(($num+18))_${endnm} ${var}.$(($num+19))_${endnm} ${var}.$(($num+20))_${endnm} \
	${var}.$(($num+21))_${endnm} ${var}.$(($num+22))_${endnm} ${var}.$(($num+23))_${endnm} ${var}.$(($num+24))_${endnm} ${var}.$(($num+25))_${endnm} \
	${var}.$(($num+26))_${endnm} ${var}.$(($num+27))_${endnm} ${var}.$(($num+28))_${endnm} ${var}.$(($num+29))_${endnm} ${var}.$(($num+30))_${endnm} \
	${var}.$(($num+31))_${endnm} ${var}.$(($num+32))_${endnm} ${var}.$(($num+33))_${endnm} ${var}.$(($num+34))_${endnm} ${var}.$(($num+35))_${endnm} \
	${var}.$(($num+36))_${endnm} ${var}.$(($num+37))_${endnm} ${var}.$(($num+38))_${endnm} ${var}.$(($num+39))_${endnm} ${var}.$(($num+40))_${endnm} \
	${var}.$(($num+41))_${endnm} ${var}.$(($num+42))_${endnm} ${var}.$(($num+43))_${endnm} ${var}.$(($num+44))_${endnm} ${var}.$(($num+45))_${endnm} \
	${var}.$(($num+46))_${endnm} ${var}.$(($num+47))_${endnm} ${var}.$(($num+48))_${endnm} ${var}.$(($num+49))_${endnm} ${var}.$(($num+50))_${endnm} \
	${var}.$(($num+51))_${endnm} ${var}.$(($num+52))_${endnm} ${var}.$(($num+53))_${endnm} ${var}.$(($num+54))_${endnm} ${var}.$(($num+55))_${endnm} \
	${var}.$(($num+56))_${endnm} ${var}.$(($num+57))_${endnm} ${var}.$(($num+58))_${endnm} ${var}.$(($num+59))_${endnm} ${var}.$(($num+60))_${endnm} \
	${var}.$(($num+61))_${endnm} ${var}.$(($num+62))_${endnm} ${var}.$(($num+63))_${endnm} ${var}.$(($num+64))_${endnm} ${var}.$(($num+65))_${endnm} \
	${var}.$(($num+66))_${endnm} ${var}.$(($num+67))_${endnm} ${var}.$(($num+68))_${endnm} ${var}.$(($num+69))_${endnm} ${var}.$(($num+70))_${endnm} \
	${var}.$(($num+71))_${endnm} ${var}.$(($num+72))_${endnm} ${var}.$(($num+73))_${endnm} ${var}.$(($num+74))_${endnm} ${var}.$(($num+75))_${endnm} \
	${var}.$(($num+76))_${endnm} ${var}.$(($num+77))_${endnm} ${var}.$(($num+78))_${endnm} ${var}.$(($num+79))_${endnm} ${var}.$(($num+80))_${endnm} \
	${var}.$(($num+81))_${endnm} ${var}.$(($num+82))_${endnm} ${var}.$(($num+83))_${endnm} ${var}.$(($num+84))_${endnm} ${var}.$(($num+85))_${endnm} \
	${var}.$(($num+86))_${endnm} ${var}.$(($num+87))_${endnm} ${var}.$(($num+88))_${endnm} ${var}.$(($num+89))_${endnm} ${var}.$(($num+90))_${endnm} \
	${var}.$(($num+91))_${endnm} ${var}.$(($num+92))_${endnm} ${var}.$(($num+93))_${endnm} ${var}.$(($num+94))_${endnm} ${var}.$(($num+95))_${endnm} \
	${var}.$(($num+96))_${endnm} ${var}.$(($num+97))_${endnm} ${var}.$(($num+98))_${endnm} ${var}.$(($num+99))_${endnm} ${var}.$(($num+100))_${endnm} \
	${var}.$(($num+101))_${endnm} ${var}.$(($num+102))_${endnm} ${var}.$(($num+103))_${endnm} ${var}.$(($num+104))_${endnm} ${var}.$(($num+105))_${endnm} \
	${var}.$(($num+106))_${endnm} ${var}.$(($num+107))_${endnm} ${var}.$(($num+108))_${endnm} ${var}.$(($num+109))_${endnm} ${var}.$(($num+110))_${endnm} \
	${var}.$(($num+111))_${endnm} ${var}.$(($num+112))_${endnm} ${var}.$(($num+113))_${endnm} ${var}.$(($num+114))_${endnm} ${var}.$(($num+115))_${endnm} \
	${var}.$(($num+116))_${endnm} ${var}.$(($num+117))_${endnm} ${var}.$(($num+118))_${endnm} ${var}.$(($num+119))_${endnm} ${var}.$(($num+120))_${endnm} \
	${var}.$(($num+121))_${endnm} ${var}.$(($num+122))_${endnm} ${var}.$(($num+123))_${endnm} ${var}.$(($num+124))_${endnm} ${var}.$(($num+125))_${endnm} \
	${var}.$(($num+126))_${endnm} ${var}.$(($num+127))_${endnm} ${var}.$(($num+128))_${endnm} ${var}.$(($num+129))_${endnm} ${var}.$(($num+130))_${endnm} \
	${var}.$(($num+131))_${endnm} ${var}.$(($num+132))_${endnm} ${var}.$(($num+133))_${endnm} ${var}.$(($num+134))_${endnm} ${var}.$(($num+135))_${endnm} \
	${var}.$(($num+136))_${endnm} ${var}.$(($num+137))_${endnm} ${var}.$(($num+138))_${endnm} ${var}.$(($num+139))_${endnm} ${var}.$(($num+140))_${endnm} \
	${var}.$(($num+141))_${endnm} ${var}.$(($num+142))_${endnm} ${var}.$(($num+143))_${endnm} ${var}.$(($num+144))_${endnm} ${var}.$(($num+145))_${endnm} \
	${var}.$(($num+146))_${endnm} ${var}.$(($num+147))_${endnm} ${var}.$(($num+148))_${endnm} ${var}.$(($num+149))_${endnm} ${var}.$(($num+150))_${endnm} \
	${var}.$(($num+151))_${endnm} ${var}.$(($num+152))_${endnm} ${var}.$(($num+153))_${endnm} ${var}.$(($num+154))_${endnm} ${var}.$(($num+155))_${endnm} \
	${var}.$(($num+156))_${endnm} ${var}.$(($num+157))_${endnm} ${var}.$(($num+158))_${endnm} ${var}.$(($num+159))_${endnm} ${var}.$(($num+160))_${endnm} \
	${var}.$(($num+161))_${endnm} ${var}.$(($num+162))_${endnm} ${var}.$(($num+163))_${endnm} ${var}.$(($num+164))_${endnm} ${var}.$(($num+165))_${endnm} \
	${var}.$(($num+166))_${endnm} ${var}.$(($num+167))_${endnm} ${var}.$(($num+168))_${endnm} ${var}.$(($num+169))_${endnm} ${var}.$(($num+170))_${endnm} \
	${var}.$(($num+171))_${endnm} ${var}.$(($num+172))_${endnm} ${var}.$(($num+173))_${endnm} ${var}.$(($num+174))_${endnm} ${var}.$(($num+175))_${endnm} \
	${var}.$(($num+176))_${endnm} ${var}.$(($num+177))_${endnm} ${var}.$(($num+178))_${endnm} ${var}.$(($num+179))_${endnm} ${var}.$(($num+180))_${endnm} \
	${var}.$(($num+181))_${endnm} ${var}.$(($num+182))_${endnm} ${var}.$(($num+183))_${endnm} ${var}.$(($num+184))_${endnm} ${var}.$(($num+185))_${endnm} \
	${var}.$(($num+186))_${endnm} ${var}.$(($num+187))_${endnm} ${var}.$(($num+188))_${endnm} ${var}.$(($num+189))_${endnm} ${var}.$(($num+190))_${endnm} \
	${var}.$(($num+191))_${endnm} ${var}.$(($num+192))_${endnm} ${var}.$(($num+193))_${endnm} ${var}.$(($num+194))_${endnm} ${var}.$(($num+195))_${endnm} \
	${var}.$(($num+196))_${endnm} ${var}.$(($num+197))_${endnm} ${var}.$(($num+198))_${endnm} ${var}.$(($num+199))_${endnm} \
	${var}_1_200_${endnm}

