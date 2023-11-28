#! /bin/bash

# (1) data/run1/MIROC6_T2_1850 ~ data/run1/MIROC6_T2_2014をdata/run1/MIROC6_T2_1850_2014として結合する
#
#----------------------------------------------------------------------------------------------------------------------------------------------
LTOP='/home/honoka/src/sample_code/MIROC6/DECK/historical'
LTOP2='/home/honoka/work/MIROC6/data'
stryr=1850
stryr2=1960
strmon=1
endyr=2014
endmon=12
var=MIROC6_T2
runnum=$1                   # runnum=1~50 (run1~run50)

cd ${LTOP2}/run${runnum}/

# ファイルの連結 (1960~2014年の55年間)
ngtcat -c ${var}_run${runnum}_${stryr2} ${var}_run${runnum}_$((${stryr2}+1)) ${var}_run${runnum}_$((${stryr2}+2)) ${var}_run${runnum}_$((${stryr2}+3)) ${var}_run${runnum}_$((${stryr2}+4))\
        ${var}_run${runnum}_$((${stryr2}+5)) ${var}_run${runnum}_$((${stryr2}+6)) ${var}_run${runnum}_$((${stryr2}+7)) ${var}_run${runnum}_$((${stryr2}+8)) ${var}_run${runnum}_$((${stryr2}+9))\
        ${var}_run${runnum}_$((${stryr2}+10)) ${var}_run${runnum}_$((${stryr2}+11)) ${var}_run${runnum}_$((${stryr2}+12)) ${var}_run${runnum}_$((${stryr2}+13)) ${var}_run${runnum}_$((${stryr2}+14))\
        ${var}_run${runnum}_$((${stryr2}+15)) ${var}_run${runnum}_$((${stryr2}+16)) ${var}_run${runnum}_$((${stryr2}+17)) ${var}_run${runnum}_$((${stryr2}+18)) ${var}_run${runnum}_$((${stryr2}+19))\
        ${var}_run${runnum}_$((${stryr2}+20)) ${var}_run${runnum}_$((${stryr2}+21)) ${var}_run${runnum}_$((${stryr2}+22)) ${var}_run${runnum}_$((${stryr2}+23)) ${var}_run${runnum}_$((${stryr2}+24))\
        ${var}_run${runnum}_$((${stryr2}+25)) ${var}_run${runnum}_$((${stryr2}+26)) ${var}_run${runnum}_$((${stryr2}+27)) ${var}_run${runnum}_$((${stryr2}+28)) ${var}_run${runnum}_$((${stryr2}+29))\
        ${var}_run${runnum}_$((${stryr2}+30)) ${var}_run${runnum}_$((${stryr2}+31)) ${var}_run${runnum}_$((${stryr2}+32)) ${var}_run${runnum}_$((${stryr2}+33)) ${var}_run${runnum}_$((${stryr2}+34))\
        ${var}_run${runnum}_$((${stryr2}+35)) ${var}_run${runnum}_$((${stryr2}+36)) ${var}_run${runnum}_$((${stryr2}+37)) ${var}_run${runnum}_$((${stryr2}+38)) ${var}_run${runnum}_$((${stryr2}+39))\
        ${var}_run${runnum}_$((${stryr2}+40)) ${var}_run${runnum}_$((${stryr2}+41)) ${var}_run${runnum}_$((${stryr2}+42)) ${var}_run${runnum}_$((${stryr2}+43)) ${var}_run${runnum}_$((${stryr2}+44))\
        ${var}_run${runnum}_$((${stryr2}+45)) ${var}_run${runnum}_$((${stryr2}+46)) ${var}_run${runnum}_$((${stryr2}+47)) ${var}_run${runnum}_$((${stryr2}+48)) ${var}_run${runnum}_$((${stryr2}+49))\
        ${var}_run${runnum}_$((${stryr2}+50)) ${var}_run${runnum}_$((${stryr2}+51)) ${var}_run${runnum}_$((${stryr2}+52)) ${var}_run${runnum}_$((${stryr2}+53)) ${var}_run${runnum}_$((${stryr2}+54))\
        > ${var}_run${runnum}_${stryr2}_${endyr}

# ファイルの連結 (1850~2014年の165年間)
ngtcat -c ${var}_run${runnum}_${stryr} ${var}_run${runnum}_$((${stryr}+1)) ${var}_run${runnum}_$((${stryr}+2)) ${var}_run${runnum}_$((${stryr}+3)) ${var}_run${runnum}_$((${stryr}+4))\
        ${var}_run${runnum}_$((${stryr}+5)) ${var}_run${runnum}_$((${stryr}+6)) ${var}_run${runnum}_$((${stryr}+7)) ${var}_run${runnum}_$((${stryr}+8)) ${var}_run${runnum}_$((${stryr}+9))\
        ${var}_run${runnum}_$((${stryr}+10)) ${var}_run${runnum}_$((${stryr}+11)) ${var}_run${runnum}_$((${stryr}+12)) ${var}_run${runnum}_$((${stryr}+13)) ${var}_run${runnum}_$((${stryr}+14))\
        ${var}_run${runnum}_$((${stryr}+15)) ${var}_run${runnum}_$((${stryr}+16)) ${var}_run${runnum}_$((${stryr}+17)) ${var}_run${runnum}_$((${stryr}+18)) ${var}_run${runnum}_$((${stryr}+19))\
        ${var}_run${runnum}_$((${stryr}+20)) ${var}_run${runnum}_$((${stryr}+21)) ${var}_run${runnum}_$((${stryr}+22)) ${var}_run${runnum}_$((${stryr}+23)) ${var}_run${runnum}_$((${stryr}+24))\
        ${var}_run${runnum}_$((${stryr}+25)) ${var}_run${runnum}_$((${stryr}+26)) ${var}_run${runnum}_$((${stryr}+27)) ${var}_run${runnum}_$((${stryr}+28)) ${var}_run${runnum}_$((${stryr}+29))\
        ${var}_run${runnum}_$((${stryr}+30)) ${var}_run${runnum}_$((${stryr}+31)) ${var}_run${runnum}_$((${stryr}+32)) ${var}_run${runnum}_$((${stryr}+33)) ${var}_run${runnum}_$((${stryr}+34))\
        ${var}_run${runnum}_$((${stryr}+35)) ${var}_run${runnum}_$((${stryr}+36)) ${var}_run${runnum}_$((${stryr}+37)) ${var}_run${runnum}_$((${stryr}+38)) ${var}_run${runnum}_$((${stryr}+39))\
        ${var}_run${runnum}_$((${stryr}+40)) ${var}_run${runnum}_$((${stryr}+41)) ${var}_run${runnum}_$((${stryr}+42)) ${var}_run${runnum}_$((${stryr}+43)) ${var}_run${runnum}_$((${stryr}+44))\
        ${var}_run${runnum}_$((${stryr}+45)) ${var}_run${runnum}_$((${stryr}+46)) ${var}_run${runnum}_$((${stryr}+47)) ${var}_run${runnum}_$((${stryr}+48)) ${var}_run${runnum}_$((${stryr}+49))\
        ${var}_run${runnum}_$((${stryr}+50)) ${var}_run${runnum}_$((${stryr}+51)) ${var}_run${runnum}_$((${stryr}+52)) ${var}_run${runnum}_$((${stryr}+53)) ${var}_run${runnum}_$((${stryr}+54))\
        ${var}_run${runnum}_$((${stryr}+55)) ${var}_run${runnum}_$((${stryr}+56)) ${var}_run${runnum}_$((${stryr}+57)) ${var}_run${runnum}_$((${stryr}+58)) ${var}_run${runnum}_$((${stryr}+59))\
        ${var}_run${runnum}_$((${stryr}+60)) ${var}_run${runnum}_$((${stryr}+61)) ${var}_run${runnum}_$((${stryr}+62)) ${var}_run${runnum}_$((${stryr}+63)) ${var}_run${runnum}_$((${stryr}+64))\
        ${var}_run${runnum}_$((${stryr}+65)) ${var}_run${runnum}_$((${stryr}+66)) ${var}_run${runnum}_$((${stryr}+67)) ${var}_run${runnum}_$((${stryr}+68)) ${var}_run${runnum}_$((${stryr}+69))\
        ${var}_run${runnum}_$((${stryr}+70)) ${var}_run${runnum}_$((${stryr}+71)) ${var}_run${runnum}_$((${stryr}+72)) ${var}_run${runnum}_$((${stryr}+73)) ${var}_run${runnum}_$((${stryr}+74))\
        ${var}_run${runnum}_$((${stryr}+75)) ${var}_run${runnum}_$((${stryr}+76)) ${var}_run${runnum}_$((${stryr}+77)) ${var}_run${runnum}_$((${stryr}+78)) ${var}_run${runnum}_$((${stryr}+79))\
        ${var}_run${runnum}_$((${stryr}+80)) ${var}_run${runnum}_$((${stryr}+81)) ${var}_run${runnum}_$((${stryr}+82)) ${var}_run${runnum}_$((${stryr}+83)) ${var}_run${runnum}_$((${stryr}+84))\
        ${var}_run${runnum}_$((${stryr}+85)) ${var}_run${runnum}_$((${stryr}+86)) ${var}_run${runnum}_$((${stryr}+87)) ${var}_run${runnum}_$((${stryr}+88)) ${var}_run${runnum}_$((${stryr}+89))\
        ${var}_run${runnum}_$((${stryr}+90)) ${var}_run${runnum}_$((${stryr}+91)) ${var}_run${runnum}_$((${stryr}+92)) ${var}_run${runnum}_$((${stryr}+93)) ${var}_run${runnum}_$((${stryr}+94))\
        ${var}_run${runnum}_$((${stryr}+95)) ${var}_run${runnum}_$((${stryr}+96)) ${var}_run${runnum}_$((${stryr}+97)) ${var}_run${runnum}_$((${stryr}+98)) ${var}_run${runnum}_$((${stryr}+99))\
        ${var}_run${runnum}_$((${stryr}+100)) ${var}_run${runnum}_$((${stryr}+101)) ${var}_run${runnum}_$((${stryr}+102)) ${var}_run${runnum}_$((${stryr}+103)) ${var}_run${runnum}_$((${stryr}+104))\
        ${var}_run${runnum}_$((${stryr}+105)) ${var}_run${runnum}_$((${stryr}+106)) ${var}_run${runnum}_$((${stryr}+107)) ${var}_run${runnum}_$((${stryr}+108)) ${var}_run${runnum}_$((${stryr}+109))\
        ${var}_run${runnum}_$((${stryr}+110)) ${var}_run${runnum}_$((${stryr}+111)) ${var}_run${runnum}_$((${stryr}+112)) ${var}_run${runnum}_$((${stryr}+113)) ${var}_run${runnum}_$((${stryr}+114))\
        ${var}_run${runnum}_$((${stryr}+115)) ${var}_run${runnum}_$((${stryr}+116)) ${var}_run${runnum}_$((${stryr}+117)) ${var}_run${runnum}_$((${stryr}+118)) ${var}_run${runnum}_$((${stryr}+119))\
        ${var}_run${runnum}_$((${stryr}+120)) ${var}_run${runnum}_$((${stryr}+121)) ${var}_run${runnum}_$((${stryr}+122)) ${var}_run${runnum}_$((${stryr}+123)) ${var}_run${runnum}_$((${stryr}+124))\
        ${var}_run${runnum}_$((${stryr}+125)) ${var}_run${runnum}_$((${stryr}+126)) ${var}_run${runnum}_$((${stryr}+127)) ${var}_run${runnum}_$((${stryr}+128)) ${var}_run${runnum}_$((${stryr}+129))\
        ${var}_run${runnum}_$((${stryr}+130)) ${var}_run${runnum}_$((${stryr}+131)) ${var}_run${runnum}_$((${stryr}+132)) ${var}_run${runnum}_$((${stryr}+133)) ${var}_run${runnum}_$((${stryr}+134))\
        ${var}_run${runnum}_$((${stryr}+135)) ${var}_run${runnum}_$((${stryr}+136)) ${var}_run${runnum}_$((${stryr}+137)) ${var}_run${runnum}_$((${stryr}+138)) ${var}_run${runnum}_$((${stryr}+139))\
        ${var}_run${runnum}_$((${stryr}+140)) ${var}_run${runnum}_$((${stryr}+141)) ${var}_run${runnum}_$((${stryr}+142)) ${var}_run${runnum}_$((${stryr}+143)) ${var}_run${runnum}_$((${stryr}+144))\
        ${var}_run${runnum}_$((${stryr}+145)) ${var}_run${runnum}_$((${stryr}+146)) ${var}_run${runnum}_$((${stryr}+147)) ${var}_run${runnum}_$((${stryr}+148)) ${var}_run${runnum}_$((${stryr}+149))\
        ${var}_run${runnum}_$((${stryr}+150)) ${var}_run${runnum}_$((${stryr}+151)) ${var}_run${runnum}_$((${stryr}+152)) ${var}_run${runnum}_$((${stryr}+153)) ${var}_run${runnum}_$((${stryr}+154))\
        ${var}_run${runnum}_$((${stryr}+155)) ${var}_run${runnum}_$((${stryr}+156)) ${var}_run${runnum}_$((${stryr}+157)) ${var}_run${runnum}_$((${stryr}+158)) ${var}_run${runnum}_$((${stryr}+159))\
        ${var}_run${runnum}_$((${stryr}+160)) ${var}_run${runnum}_$((${stryr}+161)) ${var}_run${runnum}_$((${stryr}+162)) ${var}_run${runnum}_$((${stryr}+163)) ${var}_run${runnum}_$((${stryr}+164))\
        > ${var}_run${runnum}_${stryr}_${endyr}

#gtcont ${var}_run${runnum}_${stryr}_${endyr} map=1 color=50 -nocnt -print ps:${var}_run${runnum}_${stryr}_${endyr}.ps
#gtcont ${var}_run${runnum}_${stryr2}_${endyr} map=1 color=50 -nocnt -print ps:${var}_run${runnum}_${stryr2}_${endyr}.ps

