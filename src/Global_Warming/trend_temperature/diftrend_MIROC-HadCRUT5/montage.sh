#! /bin/bash

## トレンドの差と有意性の重ね描きを1つのpngファイルに出力するプログラム
# diftrend = MIROC run1-50 & ensemble mean trend - HadCRUT5 ensemble mean trend

#-----------------------------------------------------------------------------

mon=$1
yr=1960_2014
area=N30_90                                             # area = NP, N30_90

LTOP=/home/honoka/work/HadCRUT5_MIROC6/diftrend/data/${area}/diftrend_MIROC-Hades_${yr}_${mon}
LTOP2=/home/honoka/work/HadCRUT5_MIROC6/diftrend/data/${area}/diftrend_MIROCes-Hades_1960_2014
var=diftrend_sig9590.MIROC
strnm=diftrend_sig9590_MIROCes-Hades_${yr}
endnm=Hades_${yr}_${mon}_${area}
endnm2=${area}
num=1

cd ${LTOP}                                         # GTOOLの在処に移動

# MIROC ensemble mean & run1-50 trend - HadCRUT5 ensemble mean trend
#montage -tile 5x11 -geometry 904x654+0+0 \
#       diftrend_sig9590_MIROCes-${endnm} \
#       ${var}${num}-${endnm} ${var}$(($num+1))-${endnm} ${var}$(($num+2))-${endnm} ${var}$(($num+3))-${endnm} ${var}$(($num+4))-${endnm} ${var}$(($num+5))-${endnm} \
#       ${var}$(($num+6))-${endnm} ${var}$(($num+7))-${endnm} ${var}$(($num+8))-${endnm} ${var}$(($num+9))-${endnm} ${var}$(($num+10))-${endnm} \
#       ${var}$(($num+11))-${endnm} ${var}$(($num+12))-${endnm} ${var}$(($num+13))-${endnm} ${var}$(($num+14))-${endnm} ${var}$(($num+15))-${endnm} \
#       ${var}$(($num+16))-${endnm} ${var}$(($num+17))-${endnm} ${var}$(($num+18))-${endnm} ${var}$(($num+19))-${endnm} ${var}$(($num+20))-${endnm} \
#       ${var}$(($num+21))-${endnm} ${var}$(($num+22))-${endnm} ${var}$(($num+23))-${endnm} ${var}$(($num+24))-${endnm} ${var}$(($num+25))-${endnm} \
#       ${var}$(($num+26))-${endnm} ${var}$(($num+27))-${endnm} ${var}$(($num+28))-${endnm} ${var}$(($num+29))-${endnm} ${var}$(($num+30))-${endnm} \
#       ${var}$(($num+31))-${endnm} ${var}$(($num+32))-${endnm} ${var}$(($num+33))-${endnm} ${var}$(($num+34))-${endnm} ${var}$(($num+35))-${endnm} \
#       ${var}$(($num+36))-${endnm} ${var}$(($num+37))-${endnm} ${var}$(($num+38))-${endnm} ${var}$(($num+39))-${endnm} ${var}$(($num+40))-${endnm} \
#       ${var}$(($num+41))-${endnm} ${var}$(($num+42))-${endnm} ${var}$(($num+43))-${endnm} ${var}$(($num+44))-${endnm} ${var}$(($num+45))-${endnm} \
#       ${var}$(($num+46))-${endnm} ${var}$(($num+47))-${endnm} ${var}$(($num+48))-${endnm} ${var}$(($num+49))-${endnm} \
#       ${var}es_1_50-${endnm}

# png形式に変換
convert ${var}es_1_50-${endnm} ${var}es_1_50-${endnm}.png

# MIROC ensemble mean trend - HadCRUT5 ensemble mean trend ( 1-12月、MAM & JJA & SON & DJF )
#ln -s ${LTOP}/diftrend_sig9590_MIROCes-${endnm} ${LTOP2}/
#cd ${LTOP2}/

# 1-12月
#montage -tile 4x3 -geometry 904x654+0+0 \
#	${strnm}_${num}_${endnm2} ${strnm}_$((${num}+1))_${endnm2} ${strnm}_$((${num}+2))_${endnm2} ${strnm}_$((${num}+3))_${endnm2} \
#	${strnm}_$((${num}+4))_${endnm2} ${strnm}_$((${num}+5))_${endnm2} ${strnm}_$((${num}+6))_${endnm2} ${strnm}_$((${num}+7))_${endnm2} \
#	${strnm}_$((${num}+8))_${endnm2} ${strnm}_$((${num}+9))_${endnm2} ${strnm}_$((${num}+10))_${endnm2} ${strnm}_$((${num}+11))_${endnm2} \
#	${strnm}_1_12_${endnm2}

# MAM, JJA, SON, DJF
#montage -tile 2x2 -geometry 904x654+0+0 \
#	${strnm}_030405_${endnm2} ${strnm}_060708_${endnm2} ${strnm}_091011_${endnm2} ${strnm}_120102_${endnm2} \
#	${strnm}_MJSD_${endnm2}

# png形式に変換
#convert ${strnm}_1_12_${endnm2} ${strnm}_1_12_${endnm2}.png
#convert ${strnm}_MJSD_${endnm2} ${strnm}_MJSD_${endnm2}.png

