#! /bin/bash

# (1) データフォーマット変更 [DFMT=URY16 -> DFMT=UR4] (ch_datafmt.sh)
#
#----------------------------------------------------------------------------------------------------------------------------------------------
LTOP='/home/honoka/src/sample_code/MIROC6/DECK/historical'
LTOP2='/home/honoka/work/MIROC6/data'
stryr=1850
stryr2=1960
strmon=1
endyr=2014
endmon=12
runnum=$1                # runnum=1~50 (run1~run50)

cd ${LTOP2}/run${runnum}/

for yr in $( seq ${stryr} ${endyr} ) ; do                                     # 1850~2014年
        ngtconv T2_run${runnum}_${yr} -f UR4 MIROC6_T2_run${runnum}_${yr}
done


