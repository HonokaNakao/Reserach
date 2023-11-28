#! /bin/bash

# (1)特定の期間のGTOOLデータファイルを読む
#    (例)HadCRUT.5.0.1.0.analysis.anomalies.ensemble_mean_1960_2014 -> 1960年-2014年データ

# (2)トレンド計算 (月毎のトレンド [K/month] -> [K/decade]として出力)

#----------------------------------------------------------------------------------------------------------------------------------------------

LTOP='/home/honoka/work/HadCRUT5'
DTOP='HadCRUT.5.0.1.0.analysis.anomalies.ensemble_mean'
strmon=$1

cd ${LTOP}/data/data_ensemble_monthly/${DTOP}_1960_2014/${DTOP}_1960_2014_${strmon}           # GTOOLの在り処に移動

## 月別データを読み込む & トレンド計算 & 検定統計量T計算
cat << EOF > cal_trend_T_mon.f90
PROGRAM cal_trend_T_mon

! gfortran -fconvert=big-endian cal_trend_T_mon.f90

  INTEGER, PARAMETER :: IMAX= 72   ! No. of longitudinal grids
  INTEGER, PARAMETER :: JMAX= 36   ! No. of latitudinal grids
  INTEGER, PARAMETER :: HMAX= 64   ! No. of header informations
!  INTEGER, PARAMETER :: MMAX= 660   ! No. of months (1960-2014年660個の月別データ)
  INTEGER, PARAMETER :: MMAX= 55   ! No. of months (1960-2014年1月55個の月別データ)
  REAL, PARAMETER :: vmiss = -999. ! 欠損値

  CHARACTER :: HEAD( HMAX )*16 ! headers
  REAL :: TAS( IMAX, JMAX )          ! data
  REAL :: TASM( IMAX, JMAX, MMAX )   ! data(ydata)
  REAL :: x( IMAX, JMAX, MMAX )      ! xdata

  REAL :: sumx( IMAX, JMAX )         ! x値の合計値
  REAL :: sumy( IMAX, JMAX )         ! y値の合計値
  REAL :: avex( IMAX, JMAX )         ! x値の平均値
  REAL :: avey( IMAX, JMAX )         ! y値の平均値
  REAL :: ndata( IMAX, JMAX )        ! 欠損値以外のデータ総数
  REAL :: dataratio( IMAX, JMAX )    ! データの存在割合　(欠損値以外のデータ総数/データ合計数)
  REAL :: xx( IMAX, JMAX )           ! x**2の合計 (分子1項目)
  REAL :: block1( IMAX, JMAX )       ! sigma(xi*yi) (分母1項目)
  REAL :: trend( IMAX, JMAX )        ! トレンド (回帰係数)

  REAL :: b( IMAX, JMAX )            ! b 　    (回帰直線のy切片)
  REAL :: esty( IMAX, JMAX , MMAX )  ! y値の推定値　
  REAL :: block2( IMAX, JMAX, MMAX ) ! sigma((TASM-esty)**2) (T値計算の分母計算過程)
  REAL :: block3( IMAX, JMAX, MMAX ) ! sigma((x-avex)**2)    (T値計算の分子計算過程)
  REAL :: sigmae( IMAX, JMAX, MMAX ) ! SQRT( block2(i,j,m)/(ndata-2) )　(誤差項標準偏差 : T値計算の分母)
  REAL :: T( IMAX, JMAX )            ! 検定統計量 T値

!! 入力ファイル名を指定               123456789-123456789-123456789-123456789-123456789-1 
  CHARACTER ( LEN = 200 ) :: IFILE = 'HadCRUT.5.0.1.0.analysis.anomalies.ensemble_mean_1960_2014_${strmon}' ! input file name

!! 出力ファイル名を指定               123456789-123456789-123456789-123456789-123456789- 
  CHARACTER ( LEN = 200 ) :: OFILE = 'trend_1960_2014_${strmon}_mon'  ! output file name
  CHARACTER ( LEN = 200 ) :: OFILE2 = 'T_trend_1960_2014_${strmon}_mon'  ! output file name

!! GTOOLデータの読み込み 
  OPEN ( 10, FILE=IFILE, FORM='UNFORMATTED' ) ! open input file

  DO m = 1, MMAX
     READ( 10 ) HEAD
     READ( 10 ) TASM(:,:,m)
!     TASM(:,:,m) = TAS(:,:)
     x(:,:,m) = m
  END DO

  CLOSE( 10 )                                 ! close input file

!! x,yの合計値、欠損値以外のデータ総数
  sumx = SUM( x, DIM=3, MASK = ( TASM /= vmiss ))
  sumy = SUM( TASM, DIM=3, MASK = ( TASM /= vmiss ))
  ndata = COUNT( MASK =( TASM /= vmiss ), DIM=3 )

!! x,yの平均値
  avex(:,:) = sumx(:,:) / ndata(:,:)
  avey(:,:) = sumy(:,:) / ndata(:,:)

!! x**2の合計(xx,分母1項目)
!! trend計算の分子１項目(block1) sigma(xi*yi)
  xx = 0.0
  block1 = 0.0

  DO i = 1, IMAX
     DO j = 1, JMAX
        DO m = 1, MMAX
           IF ( TASM(i,j,m) .NE. vmiss ) THEN
              xx(i,j) = xx(i,j) + (x(i,j,m))**2
              block1(i,j) = block1(i,j) + x(i,j,m)*TASM(i,j,m)
           END IF
        END DO
      END DO
  END DO

!! トレンド計算
  trend = 0.0
!  trend(:,:) = 120.0*( block1(:,:) - ndata(:,:)*avex(:,:)*avey(:,:) ) / (xx(:,:) - ndata(:,:)*avex(:,:)*avex(:,:))  ! 120*[K/month] -> [K/decade]
  trend(:,:) = 10.0*( block1(:,:) - ndata(:,:)*avex(:,:)*avey(:,:) ) / (xx(:,:) - ndata(:,:)*avex(:,:)*avex(:,:))  ! 10*[K/yr] -> [K/decade]

  OPEN ( 20, FILE=OFILE, FORM='UNFORMATTED' ) ! open output file
  WRITE( 20 ) HEAD
  WRITE( 20 ) trend
  CLOSE( 20 ) ! close output file

!-----------------
!! 検定統計量T計算

!! 回帰直線のy切片 (b)
  b(:,:) = avey(:,:) - trend(:,:)*avex(:,:)

!! yの推定値 (esty) 
  DO i = 1, IMAX
     DO j = 1, JMAX
        DO m = 1, MMAX
           IF( TASM(i,j,m) .NE. vmiss ) THEN
             esty(i,j,m) = trend(i,j)*x(i,j,m) + b(i,j)
           END IF
        END DO 
     END DO 
  END DO 

!! T計算の分母 block2(i,j,m) = sigma((TASM-esty)**2) & sigmae(i,j,m) = SQRT( block2(i,j,m)/(ndata-2) )
!! T計算の分子 block3(i,j,m) = SQRT( sigma((x-avex)**2) )
  block2 = 0.0
  block3 = 0.0

  IF ( TASM(i,j,m) .NE. vmiss ) THEN
     block2(:,:,:) = block2(:,:,:) + ( TASM(:,:,:) - esty(:,:,:) ) ** 2
!     sigmae(:,:,:) = SQRT( block2() / ( ndata(:,:) - 2.0 ) )
  END IF

  DO i = 1, IMAX
     DO j = 1, JMAX
        DO m = 1, MMAX
           IF( TASM(i,j,m) .NE. vmiss ) THEN
             sigmae(i,j,m) = SQRT( block2(i,j,m) / ( ndata(i,j) - 2.0 ) )
             block3(i,j,m) = block3(i,j,m) + SQRT( (x(i,j,m)-avex(i,j))**2 )
           END IF
        END DO
     END DO
  END DO

! block3(:,:,:) = block3(:,:,:) + SQRT( (x(:,:,:)-avex(:,:))**2 ) 

!! T値
!  T(:,:) = trend(:,:) * block3(:,:,:) / sigmae(:,:,:)

  DO i = 1, IMAX
     DO j = 1, JMAX
        DO m = 1, MMAX
           IF( TASM(i,j,m) .NE. vmiss ) THEN
             T(i,j) = trend(i,j) * block3(i,j,m) / sigmae(i,j,m)
           END IF
        END DO
     END DO
  END DO

  OPEN( 30, FILE=OFILE2, FORM='UNFORMATTED' ) ! open output file
  WRITE( 30 ) HEAD
  WRITE( 30 ) T
  CLOSE( 30 ) ! close output file

END
EOF

##gfortran -fconvert=big-endian ./read_gtool.f90;./a.out                             # コンパイル & 実行
gfortran -fconvert=big-endian ./cal_trend_T_mon.f90;./a.out > ${LTOP}/log/test_ver3.txt    # コンパイル & 実行 & 実行結果を確認 (redirection)

mv ./cal_trend_T_mon.f90 ${LTOP}/src/t_test/t_test_ensemblemean/                           # fortranファイルをsrcに移動           

## 描画
cd ${LTOP}/data/data_ensemble_monthly/${DTOP}_1960_2014/${DTOP}_1960_2014_${strmon}                              # GTOOLの在り処に移動
#gtcont trend_1960_2014_${strmon}_mon map=1 color=50 -nocnt -print ps:trend_1960_2014_${strmon}_mon.ps
#gtcont trend_1960_2014_${strmon}_mon map=1 color=50 range=-0.667,1.07 -nocnt -print ps:trend_1960_2014_${strmon}_mon_rg-0.667_1.07.ps
#gtcont dataratio_1960_2014_${strmon}_mon map=1 color=50 range=0.0,1.01 -nocnt -print ps:dataratio_1960_2014_${strmon}_mon.ps
#gtcont dataratio_1960_2014_${strmon}_mon cont=0.1,0.5 trend_1960_2014_${strmon}_mon map=1 color=50 -print ps:trend_dataratio_1960_2014_${strmon}_mon.ps
gtcont T_trend_1960_2014_${strmon}_mon map=1 color=50 -nocnt -print ps:T_trend_1960_2014_${strmon}_mon.ps
gtcont T_trend_1960_2014_${strmon}_mon map=1 color=50 range=-25,25 -nocnt -print ps:T_trend_1960_2014_${strmon}_mon_rg-25_25.ps

# 作業ディレクトリにカラーマップが無い場合 (polar以外など)
#ln -s /usr/local/dcl/lib/dcldbase/colormap_67.x11 colormap.x11      #特定のカラーマップをcolormap.x11としてシンボリックリンクする
#gtcont trend_1960_2014_${strmon}_mon tone=-1,-0.6,-0.4,-0.2,-0.1,0.0,0.1,0.2,0.4,0.6,1.0 pat=10999,22999,28999,48999,53999,58999,65999,70999,89999,99999 map=1 -nocnt -print ps:trend_1960_2014_${strmon}_mon_rg-1_1.ps
#rm colormap.x11
