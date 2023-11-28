#! /bin/bash

LTOP='/home/honoka/work/MIROC6'

var='MIROC6_T2'
stryr=1960
strmon=1
endyr=2014
endmon=12
runnum=$1        # runnum=1~50 (不要)
mon=$2           # mon=1~12
yr=${stryr}_${endyr}

DTOP=${var}_run${runnum}_anomalies_${stryr}_${endyr}_${mon}_intpmk

cd ${LTOP}/data/run1_50/${var}_run1_50_ensemble_${yr}/${var}_run1_50_ensemble_${yr}_${mon}/                    # GTOOLの在り処に移動

cat << EOF > mk_ensemblemean.f90

PROGRAM mk_ensemblemean
! MIROC6 50例の平均値を算出し、ensemble meanを作成するプログラム
! gfortran -fconvert=big-endian mk_ensemblemean.f90

!--------------------------------------------------------------------------

      IMPLICIT NONE

  INTEGER, PARAMETER :: IMAX= 72   ! No. of longitudinal grids
  INTEGER, PARAMETER :: JMAX= 36   ! No. of latitudinal grids
  INTEGER, PARAMETER :: HMAX= 64   ! No. of header informations
!  INTEGER, PARAMETER :: MMAX= 660   ! No. of months (1960-2014年660個の月別データ)
  INTEGER, PARAMETER :: MMAX= 55   ! No. of months (1960-2014年1月55個の月別データ)
  INTEGER, PARAMETER :: RMAX= 50   ! No. of runnumber (runnum=1~50)
  REAL, PARAMETER :: vmiss = -999. ! 欠損値

  CHARACTER :: HEAD( HMAX )*16 ! headers
  REAL :: TAS( IMAX, JMAX, MMAX )    ! 元データ (ex:1960~2014年１月データ)
  REAL :: TASR( IMAX, JMAX, RMAX )   ! data (run1~50毎の1地点 ex:run1の1960年1月)
  REAL :: sumTASR( IMAX, JMAX )      ! TASRの合計値 (ex:1960年1月のrun1~run50の合計値)
  REAL :: TASM( IMAX, JMAX, MMAX )   ! 1960~2014年のTASRの平均値 (ex:1960年1月の平均値)
  REAL :: ndata( IMAX, JMAX )        ! 欠損値以外のデータ総数
 
  INTEGER :: m, r

!! 入力ファイル名を指定               123456789-123456789-123456789-123456789-123456789-1  ! ファイル名もループ
  CHARACTER ( LEN = 200 ) :: IFILE1 = '${var}_run1_anomalies_${yr}_${mon}_intpmk' ! input file name
  CHARACTER ( LEN = 200 ) :: IFILE2 = '${var}_run2_anomalies_${yr}_${mon}_intpmk' ! input file name
  CHARACTER ( LEN = 200 ) :: IFILE3 = '${var}_run3_anomalies_${yr}_${mon}_intpmk' ! input file name
  CHARACTER ( LEN = 200 ) :: IFILE4 = '${var}_run4_anomalies_${yr}_${mon}_intpmk' ! input file name
  CHARACTER ( LEN = 200 ) :: IFILE5 = '${var}_run5_anomalies_${yr}_${mon}_intpmk' ! input file name
  CHARACTER ( LEN = 200 ) :: IFILE6 = '${var}_run6_anomalies_${yr}_${mon}_intpmk' ! input file name
  CHARACTER ( LEN = 200 ) :: IFILE7 = '${var}_run7_anomalies_${yr}_${mon}_intpmk' ! input file name
  CHARACTER ( LEN = 200 ) :: IFILE8 = '${var}_run8_anomalies_${yr}_${mon}_intpmk' ! input file name
  CHARACTER ( LEN = 200 ) :: IFILE9 = '${var}_run9_anomalies_${yr}_${mon}_intpmk' ! input file name
  CHARACTER ( LEN = 200 ) :: IFILE10 = '${var}_run10_anomalies_${yr}_${mon}_intpmk' ! input file name

!! 出力ファイル名を指定               123456789-123456789-123456789-123456789-123456789- 
  CHARACTER ( LEN = 200 ) :: OFILE = '${var}_run1_50_anomalies_ensemble_${yr}_${mon}'  ! output file name

!! GTOOLデータの読み込み
  OPEN ( 10, FILE=IFILE1, FORM='UNFORMATTED' )                                         ! open input file
!  OPEN ( 20, FILE=IFILE2, FORM='UNFORMATTED' )                                         ! open input file
!  OPEN ( 30, FILE=IFILE3, FORM='UNFORMATTED' )                                         ! open input file

  DO m = 1, MMAX
!     DO r = 1, RMAX  (不要)

        READ( 10 ) HEAD
	READ( 10 ) TAS(:,:,m)
!        TASR(:,:,1) = TAS(:,:,1)              ! run1,1月分のデータ読み込み(ex:run1の1960年1月) 

!        READ( 20 ) HEAD
!      	READ( 20 ) TAS(:,:,m)
!        TASR(:,:,2) = TAS(:,:,1)              ! run2,1月分のデータ読み込み(ex:run2の1960年1月) 

!        READ( 30 ) HEAD
!	READ( 30 ) TAS(:,:,m)
!        TASR(:,:,3) = TAS(:,:,1)              ! run3,1月分のデータ読み込み(ex:run2の1960年1月) 

!     END DO

!! TASRの合計値、欠損値以外のデータ総数
!     sumTASR = SUM( TASR, DIM=3 , MASK = ( TASR /= vmiss ))
!     ndata = COUNT( MASK =( TASR /= vmiss ), DIM=3 )

!! x,yの平均値
!     TASM(:,:,m) = sumTASR(:,:) / ndata(:,:)                                             ! TASM = TASRの平均値 (ex:1960~2014年１月のrun1~50の平均値)

  END DO

  CLOSE( 10 )                                                                          ! close input file
!  CLOSE( 20 )                                                                          ! close input file
!  CLOSE( 30 )                                                                          ! close input file


  OPEN ( 40, FILE=OFILE, FORM='UNFORMATTED' ) ! open output file
  
!  DO m = 1, MMAX
  HEAD( 3 ) = 'T2'                            ! change item
  HEAD( 16 ) = 'K'                            ! change unit
  WRITE( 40 ) HEAD                ! <修正> HEAD(lon,lat,m) : ヘッダー情報を3次元にする必要がある。(データとヘッダーは1セット)

  WRITE( 40 ) TAS
!  WRITE( 40 ) TAS(:,:,:)

!  WRITE( 40 ) TAS(:,:,m)
!  END DO
  CLOSE( 40 ) ! close output file

END
EOF

#gfortran -fconvert=big-endian ./mk_ensemblemean.f90;./a.out > ${LTOP}/log/test_ver1.txt    # コンパイル & 実行 & 実行結果を確認 (redirection)
gfortran -fconvert=big-endian ./mk_ensemblemean.f90;./a.out    # コンパイル & 実行 & 実行結果を確認 (redirection)

mv ./mk_ensemblemean.f90 ${LTOP}/src/                                                          # fortranファイルをsrcに移動

