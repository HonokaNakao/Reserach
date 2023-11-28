#! /bin/bash

# monthlyデータから年間3ヶ月抽出したGTOOLファイルを作成。
# (例) DJF：1960-2014年のmonthlyデータ -> 1960.1,2,3、1961.1,2,3、… 2014.1,2,3 (55年× 3 ヶ月のファイル)
#
#----------------------------------------------------------------------------------------------------------

LTOP='/home/honoka/work/HadCRUT5'
DTOP='HadCRUT.5.0.1.0.analysis.anomalies'

## 年月からデータ番号を計算する
datanum=$1                 # 1-200でループ
#frstyr=1850                # gtoolデータの最初の年
frstyr=1960                # gtoolデータの最初の年
frstmon=1                  # gtoolデータの最初の月
stryr=1960                 # 切り分ける最初の年
#strmon=9                   # 切り分ける最初の月
strmon=$2                         # strmon=3(MAM), 6(JJA), 9(SON), 12(DJF)
endyr=2014                 # 切り分ける最後の年
#endmon=11                  # 切り分ける最後の月
#mon3='091011'

if [ ${strmon} -lt 9 ] ; then     # strmon=3,6の場合  
	midmon=$(( $strmon+1 ))   # midmon=4,7
	endmon=$(( $strmon+2 ))   # endmon=5,8
	mon3=0${strmon}0${midmon}0${endmon}
elif [ ${strmon} -eq 9 ] ; then   # strmon=9(SON)の場合
	midmon=$(( $strmon+1 ))   # midmon=10
	endmon=$(( $strmon+2 ))   # endmon=11
	mon3=0${strmon}${midmon}${endmon}
else                              # strmon=12(DJF)の場合
	midmon=1   
	endmon=2
	mon3=${strmon}0102
fi

strdata=$(( (${stryr}-${frstyr})*12+${strmon} ))
enddata=$(( (${endyr}-${frstyr})*12+${endmon} ))

echo ${strdata} ${enddata}

cd ${LTOP}/data/data_analysis_gridded_1_200/${DTOP}.${datanum}/${DTOP}.${datanum}_${stryr}_${endyr}

#----------------------------------------------------------------------------
# 3ヶ月毎のディレクトリを作成
if [ ! -d ${DTOP}.${datanum}_${stryr}_${endyr}_${mon3} ] ; then
  mkdir ${LTOP}/data/data_analysis_gridded_1_200/${DTOP}.${datanum}/${DTOP}.${datanum}_${stryr}_${endyr}/${DTOP}.${datanum}_${stryr}_${endyr}_${mon3}
fi

cd ${LTOP}/data/data_analysis_gridded_1_200/${DTOP}.${datanum}/${DTOP}.${datanum}_${stryr}_${endyr}/${DTOP}.${datanum}_${stryr}_${endyr}_${mon3}/
cp ${LTOP}/data/data_analysis_gridded_1_200/${DTOP}.${datanum}/${DTOP}.${datanum}_${stryr}_${endyr}/${DTOP}.${datanum}_${stryr}_${endyr} ./
\\
#----------------------------------------------------------------------------
# 年間3ヶ月毎に抽出したGTOOLファイルを作成
enddata1=$(( $strdata+2 ))

if [ ${strmon} -ne 12 ] ; then
# 55年×3= 165ヶ月ある場合 (MAM,JJA,SON)
ngtcat -t ${strdata}:${enddata1},$((${strdata}+12)):$((${enddata1}+12)),$((${strdata}+24)):$((${enddata1}+24)),$((${strdata}+36)):$((${enddata1}+36)),$((${strdata}+48)):$((${enddata1}+48)),$((${strdata}+60)):$((${enddata1}+60)),$((${strdata}+72)):$((${enddata1}+72)),$((${strdata}+84)):$((${enddata1}+84)),$((${strdata}+96)):$((${enddata1}+96)),$((${strdata}+108)):$((${enddata1}+108)),$((${strdata}+120)):$((${enddata1}+120)),$((${strdata}+132)):$((${enddata1}+132)),$((${strdata}+144)):$((${enddata1}+144)),$((${strdata}+156)):$((${enddata1}+156)),$((${strdata}+168)):$((${enddata1}+168)),$((${strdata}+180)):$((${enddata1}+180)),$((${strdata}+192)):$((${enddata1}+192)),$((${strdata}+204)):$((${enddata1}+204)),$((${strdata}+216)):$((${enddata1}+216)),$((${strdata}+228)):$((${enddata1}+228)),$((${strdata}+240)):$((${enddata1}+240)),$((${strdata}+252)):$((${enddata1}+252)),$((${strdata}+264)):$((${enddata1}+264)),$((${strdata}+276)):$((${enddata1}+276)),$((${strdata}+288)):$((${enddata1}+288)),$((${strdata}+300)):$((${enddata1}+300)),$((${strdata}+312)):$((${enddata1}+312)),$((${strdata}+324)):$((${enddata1}+324)),$((${strdata}+336)):$((${enddata1}+336)),$((${strdata}+348)):$((${enddata1}+348)),$((${strdata}+360)):$((${enddata1}+360)),$((${strdata}+372)):$((${enddata1}+372)),$((${strdata}+384)):$((${enddata1}+384)),$((${strdata}+396)):$((${enddata1}+396)),$((${strdata}+408)):$((${enddata1}+408)),$((${strdata}+420)):$((${enddata1}+420)),$((${strdata}+432)):$((${enddata1}+432)),$((${strdata}+444)):$((${enddata1}+444)),$((${strdata}+456)):$((${enddata1}+456)),$((${strdata}+468)):$((${enddata1}+468)),$((${strdata}+480)):$((${enddata1}+480)),$((${strdata}+492)):$((${enddata1}+492)),$((${strdata}+504)):$((${enddata1}+504)),$((${strdata}+516)):$((${enddata1}+516)),$((${strdata}+528)):$((${enddata1}+528)),$((${strdata}+540)):$((${enddata1}+540)),$((${strdata}+552)):$((${enddata1}+552)),$((${strdata}+564)):$((${enddata1}+564)),$((${strdata}+576)):$((${enddata1}+576)),$((${strdata}+588)):$((${enddata1}+588)),$((${strdata}+600)):$((${enddata1}+600)),$((${strdata}+612)):$((${enddata1}+612)),$((${strdata}+624)):$((${enddata1}+624)),$((${strdata}+636)):$((${enddata1}+636)),$((${strdata}+648)):$((${enddata1}+648)) ${DTOP}.${datanum}_${stryr}_${endyr} > ${DTOP}.${datanum}_${stryr}_${endyr}_${mon3}

else
#--------------------------------
# 54年×3= 162ヶ月ある場合 (DJF)
ngtcat -t ${strdata}:${enddata1},$((${strdata}+12)):$((${enddata1}+12)),$((${strdata}+24)):$((${enddata1}+24)),$((${strdata}+36)):$((${enddata1}+36)),$((${strdata}+48)):$((${enddata1}+48)),$((${strdata}+60)):$((${enddata1}+60)),$((${strdata}+72)):$((${enddata1}+72)),$((${strdata}+84)):$((${enddata1}+84)),$((${strdata}+96)):$((${enddata1}+96)),$((${strdata}+108)):$((${enddata1}+108)),$((${strdata}+120)):$((${enddata1}+120)),$((${strdata}+132)):$((${enddata1}+132)),$((${strdata}+144)):$((${enddata1}+144)),$((${strdata}+156)):$((${enddata1}+156)),$((${strdata}+168)):$((${enddata1}+168)),$((${strdata}+180)):$((${enddata1}+180)),$((${strdata}+192)):$((${enddata1}+192)),$((${strdata}+204)):$((${enddata1}+204)),$((${strdata}+216)):$((${enddata1}+216)),$((${strdata}+228)):$((${enddata1}+228)),$((${strdata}+240)):$((${enddata1}+240)),$((${strdata}+252)):$((${enddata1}+252)),$((${strdata}+264)):$((${enddata1}+264)),$((${strdata}+276)):$((${enddata1}+276)),$((${strdata}+288)):$((${enddata1}+288)),$((${strdata}+300)):$((${enddata1}+300)),$((${strdata}+312)):$((${enddata1}+312)),$((${strdata}+324)):$((${enddata1}+324)),$((${strdata}+336)):$((${enddata1}+336)),$((${strdata}+348)):$((${enddata1}+348)),$((${strdata}+360)):$((${enddata1}+360)),$((${strdata}+372)):$((${enddata1}+372)),$((${strdata}+384)):$((${enddata1}+384)),$((${strdata}+396)):$((${enddata1}+396)),$((${strdata}+408)):$((${enddata1}+408)),$((${strdata}+420)):$((${enddata1}+420)),$((${strdata}+432)):$((${enddata1}+432)),$((${strdata}+444)):$((${enddata1}+444)),$((${strdata}+456)):$((${enddata1}+456)),$((${strdata}+468)):$((${enddata1}+468)),$((${strdata}+480)):$((${enddata1}+480)),$((${strdata}+492)):$((${enddata1}+492)),$((${strdata}+504)):$((${enddata1}+504)),$((${strdata}+516)):$((${enddata1}+516)),$((${strdata}+528)):$((${enddata1}+528)),$((${strdata}+540)):$((${enddata1}+540)),$((${strdata}+552)):$((${enddata1}+552)),$((${strdata}+564)):$((${enddata1}+564)),$((${strdata}+576)):$((${enddata1}+576)),$((${strdata}+588)):$((${enddata1}+588)),$((${strdata}+600)):$((${enddata1}+600)),$((${strdata}+612)):$((${enddata1}+612)),$((${strdata}+624)):$((${enddata1}+624)),$((${strdata}+636)):$((${enddata1}+636)) ${DTOP}.${datanum}_${stryr}_${endyr} > ${DTOP}.${datanum}_${stryr}_${endyr}_${mon3}
fi

#gtcont ${DTOP}.${datanum}_${stryr}_${endyr}_${mon3} map=1 color=50 -nocnt -print ps:${DTOP}.${datanum}_${stryr}_${endyr}_${mon3}.ps
rm ${DTOP}_${stryr}_${endyr}_${mon3}
rm ${DTOP}.${datanum}_${stryr}_${endyr}



