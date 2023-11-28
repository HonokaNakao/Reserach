#! /bin/bash

# 格子補間するプログラム [HadCRUT5と同じ水平解像度に変更]

# MIROC6 (GLON256, GGLA128) 
# HadCRUT5 (GLON72CM, GLAT36IM)
#
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

cd ${LTOP2}/run${runnum}/${var}_run${runnum}_${stryr2}_${endyr}_${mon}/

gtintrp ${var}_run${runnum}_anomalies_${stryr2}_${endyr}_${mon} x:GLON72CM y:GLAT36IM out:${var}_run${runnum}_anomalies_${stryr2}_${endyr}_${mon}_intp



