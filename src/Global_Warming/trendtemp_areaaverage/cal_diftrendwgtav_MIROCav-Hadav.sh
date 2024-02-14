#! /bin/bash

# 領域平均値差を算出するプログラム ( diftrendwgtav = MIROC trendav - HadCRUT5 trendav )
# MIROCav = MIROC6 run1-50 trendのアンサンブル平均
# HadCRUT5av = HadCRUT5 1-200 trendのアンサンブル平均

# -----------------------------------------------------------------------------------------

mon=$1
area=N30_90

cd /home/honoka/work/HadCRUT5_MIROC6/trendwgtav/data/N30_90/
var2=trendwgtav

## 領域平均値差を算出
cat << EOF > cal_diftrendwgtav_MIROCav-Hadav.f90
PROGRAM Cal_diftrendav

! 領域平均値差を算出するプログラム
!
! Compile this program with the following way ;
! % dclfrt cal_diftrendwgtav_MIROCav-Hadav.f90 -g && ./a.out
!--------------------------------------------------------------

      IMPLICIT NONE

      REAL, PARAMETER    :: ymin = -0.5                             ! 散布図 縦軸(y軸)の下限
      REAL, PARAMETER    :: ymax = 0.5                              ! 散布図 縦軸(y軸)の上限
      INTEGER, PARAMETER :: ndata = 50                              ! 空間相関　データ総数
      REAL, PARAMETER    :: xmin = -0.5                             ! 空間相関　横軸(x軸)の下限
      REAL, PARAMETER    :: xmax = 1.0                              ! 空間相関　横軸(x軸)上限
      REAL               :: Hadestrendav                            ! 領域平均値 ( HadCRUT5 trendのアンサンブル平均 )
      REAL               :: MIROCestrendav                          ! 領域平均値 ( MIROC6 trendのアンサンブル平均 )
      REAL               :: MIROCtrendav(ndata)                     ! 領域平均値 ( MIROC run1-50 )
      REAL               :: difMIROCestrendav                       ! 領域平均値の差 ( MIROC アンサンブル平均 - HadCRUT5 アンサンブル平均 )
      REAL               :: difMIROCtrendav(ndata)                  ! 領域平均値の差 ( MIROC run1-50 - HadCRUT5 アンサンブル平均 )
      REAL               :: diftrendav(ndata+1)                     ! 領域平均値差

      INTEGER :: n

!! 入力ファイル名を指定
      CHARACTER ( LEN = 200 ) :: IFILE = 'HadCRUT5_1_200av_trendwgtav_1960_2014_${mon}_${area}.txt'    ! input file name ( 領域平均値 : HadCRUT5 アンサンブル平均 )
      CHARACTER ( LEN = 200 ) :: IFILE2 = 'MIROC6r1_50av_trendwgtav_1960_2014_${mon}_${area}.txt'      ! input file name ( 領域平均値 : MIROC6 アンサンブル平均 )
      CHARACTER ( LEN = 200 ) :: IFILE3 = 'MIROC6_r1-50_trendwgtav_1960_2014_${mon}_${area}.txt'       ! input file name ( 領域平均値 : MIROC6 run1-50 )

!! 出力ファイル名を指定
      CHARACTER ( LEN = 300 ) :: OFILE = 'diftrendav_MIROC-Hadav_${mon}_${area}.txt'             ! output file name (アンサンブル平均 ver)

!--------------------------------------------------------------------------------
!! 領域平均値データの読み込み
! HadCRUT5 ensemble mean
      OPEN ( 11, FILE=IFILE, STATUS='OLD' )   ! open input file
      READ ( 11, * ) Hadestrendav
      CLOSE ( 11 ) 

! MIROC ensemble mean
      OPEN ( 12, FILE=IFILE2, STATUS='OLD' )   ! open input file
      READ ( 12, * ) MIROCestrendav
      CLOSE ( 12 ) 

! MIROC run1-50
      OPEN ( 13, FILE=IFILE3, STATUS='OLD' )   ! open input file
      READ ( 13, * ) MIROCtrendav
      CLOSE ( 13 ) 

!--------------------------------------------------------------------------------
!! 領域平均値の差 ( MIROC - HadCRUT5 ensemble mean )
! MIROC ensemble mean - HadCRUT5 ensemble mean
      difMIROCestrendav = MIROCestrendav - Hadestrendav

! MIROC run1-50 - HadCRUT5 ensemble mean
      difMIROCtrendav = MIROCtrendav - Hadestrendav

! 出力変数 diftrendav
      diftrendav(1) = difMIROCestrendav
      DO n = 1, ndata
         diftrendav(n+1) = difMIROCtrendav(n)
      END DO

!      OPEN ( 14, FILE=OFILE )                                          ! open output file
!      WRITE( 14,* ) diftrendav                                         ! 面積重み付き領域平均値差
!      CLOSE( 14 ) ! close output file
 
      OPEN ( 14, FILE=OFILE )                                           ! open output file
      DO n = 1, ndata+1 
         WRITE( 14,* ) diftrendav(n)                                    ! 面積重み付き領域平均値差
      END DO
      CLOSE( 14 ) ! close output file
END PROGRAM Cal_diftrendav
EOF

# コンパイル
gfortran -fconvert=big-endian ./cal_diftrendwgtav_MIROCav-Hadav.f90;./a.out

mv ./cal_diftrendwgtav_MIROCav-Hadav.f90 /home/honoka/work/HadCRUT5_MIROC6/trendwgtav/src/ 
mv ./diftrendav_MIROC-Hadav_${mon}_${area}.txt /home/honoka/work/HadCRUT5_MIROC6/trendwgtav/data/N30_90/diftrendwgtav_MIROCav-Hadav/


