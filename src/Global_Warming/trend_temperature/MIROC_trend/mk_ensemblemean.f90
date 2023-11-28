
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

!! 入力ファイル名を指定               123456789-123456789-123456789-123456789-123456789-1 
  CHARACTER ( LEN = 200 ) :: IFILE1 = 'MIROC6_T2_run1_anomalies_1960_2014_1_intpmk' ! input file name
  CHARACTER ( LEN = 200 ) :: IFILE2 = 'MIROC6_T2_run2_anomalies_1960_2014_1_intpmk' ! input file name
  CHARACTER ( LEN = 200 ) :: IFILE3 = 'MIROC6_T2_run3_anomalies_1960_2014_1_intpmk' ! input file name
  CHARACTER ( LEN = 200 ) :: IFILE4 = 'MIROC6_T2_run4_anomalies_1960_2014_1_intpmk' ! input file name
  CHARACTER ( LEN = 200 ) :: IFILE5 = 'MIROC6_T2_run5_anomalies_1960_2014_1_intpmk' ! input file name
  CHARACTER ( LEN = 200 ) :: IFILE6 = 'MIROC6_T2_run6_anomalies_1960_2014_1_intpmk' ! input file name
  CHARACTER ( LEN = 200 ) :: IFILE7 = 'MIROC6_T2_run7_anomalies_1960_2014_1_intpmk' ! input file name
  CHARACTER ( LEN = 200 ) :: IFILE8 = 'MIROC6_T2_run8_anomalies_1960_2014_1_intpmk' ! input file name
  CHARACTER ( LEN = 200 ) :: IFILE9 = 'MIROC6_T2_run9_anomalies_1960_2014_1_intpmk' ! input file name
  CHARACTER ( LEN = 200 ) :: IFILE10 = 'MIROC6_T2_run10_anomalies_1960_2014_1_intpmk' ! input file name

!! 出力ファイル名を指定               123456789-123456789-123456789-123456789-123456789- 
  CHARACTER ( LEN = 200 ) :: OFILE = 'MIROC6_T2_run1_50_anomalies_ensemble_1960_2014_1'  ! output file name

!! GTOOLデータの読み込み
  OPEN ( 10, FILE=IFILE1, FORM='UNFORMATTED' )                                         ! open input file
!  OPEN ( 20, FILE=IFILE2, FORM='UNFORMATTED' )                                         ! open input file
!  OPEN ( 30, FILE=IFILE3, FORM='UNFORMATTED' )                                         ! open input file

  DO m = 1, MMAX
!     DO r = 1, RMAX

        READ( 10 ) HEAD
	READ( 10 ) TAS(:,:,m)
!        TASR(:,:,1) = TAS(:,:,1)              ! run1,1月分のデータ読み込み(ex:run1の1960年1月) 

!        READ( 20 ) HEAD
!	READ( 20 ) TAS(:,:,m)
!        TASR(:,:,2) = TAS(:,:,1)              ! run2,1月分のデータ読み込み(ex:run2の1960年1月) 

!        READ( 30 ) HEAD
!	READ( 30 ) TAS(:,:,m)
!        TASR(:,:,3) = TAS(:,:,1)              ! run3,1月分のデータ読み込み(ex:run2の1960年1月) 

!     EMD DO

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
  WRITE( 40 ) HEAD
  HEAD( 3 ) = 'T2'                            ! change item
  HEAD( 16 ) = 'K'                            ! change unit

!  WRITE( 40 ) TAS
!  WRITE( 40 ) TAS(:,:,:)

  DO m = 1, MMAX  
  WRITE( 40 ) TAS(:,:,m)
  END DO
  CLOSE( 40 ) ! close output file

END
