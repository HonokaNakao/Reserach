#! /bin/bash
## MIROC6 ensemble meanの月毎トレンド算出 & 有意性検定を行うプログラム

# (1)特定の期間のGTOOLデータファイルを読む
#    (例)MIROC6_T2_run1_anomalies_1960_2014_1_intpmk -> 1960年-2014年1月データ
#
# (2)トレンド計算 (月毎のトレンド [K/month] -> [K/decade]として出力)
#
# (3)検定統計量T値、有意水準10%,5%の閾値t値を計算 & 有意性検定 

#----------------------------------------------------------------------------------------------------------------------------------------------

LTOP='/home/honoka/work/MIROC6'

var='MIROC6_T2'
stryr=1960
strmon=1
endyr=2014
endmon=12
yr=${stryr}_${endyr}
mon=$1           # mon=1~12

D1=${var}_run1_50_ensemble_${yr}
DTOP=${var}_run1_50_anomalies_ensemble_${yr}_${mon}

cd ${LTOP}/data/run1_50/${D1}/${D1}_${mon}/                                         # GTOOLデータの在り処へ移動

## 月別データを読み込む & トレンド計算 & 検定統計量T計算
cat << EOF > cal_ensm_trend_T_sig_mon.f90
PROGRAM cal_ensm_trend_T_sig_mon

! gfortran -fconvert=big-endian cal_ensm_trend_T_sig_mon.f90

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
  REAL :: block4( IMAX, JMAX )       ! xx-ndata*avex*avex (分母)
  REAL :: trend( IMAX, JMAX )        ! トレンド (回帰係数)

  REAL :: b( IMAX, JMAX )            ! b 　    (回帰直線のy切片)
  REAL :: esty( IMAX, JMAX, MMAX )   ! y値の推定値　
  REAL :: block2( IMAX, JMAX )       ! sigma((TASM-esty)**2) (T値計算の分母計算過程)
  REAL :: block3( IMAX, JMAX )       ! sigma((x-avex)**2)    (T値計算の分子計算過程)
  REAL :: sigmae( IMAX, JMAX )       ! SQRT( block2/(ndata-2) )　(誤差項標準偏差 : T値計算の分母)
  REAL :: T( IMAX, JMAX )            ! 検定統計量 T値

  REAL :: t_val
  INTEGER :: f                       ! f値(自由度)
  INTEGER :: p                       ! p値
  REAL :: tval90( IMAX, JMAX )       ! 有意水準10%の閾値t値
  REAL :: tval95( IMAX, JMAX )       ! 有意水準5%の閾値t値
  REAL :: sig90( IMAX, JMAX )        ! 有意水準10%の有意性検定 (有意:trend, 有意でない:vmiss)
  REAL :: sig95( IMAX, JMAX )        ! 有意水準5%の有意性検定 (有意:trend, 有意でない:vmiss)
  REAL :: sig95_90( IMAX, JMAX )     ! 有意水準5%の有意性検定 (有意な地点:97.5 有意水準10%~5%未満の地点:92.5 有意でない地点:89)

!! 入力ファイル名を指定               123456789-123456789-123456789-123456789-123456789-1 
  CHARACTER ( LEN = 200 ) :: IFILE = '${DTOP}' ! input file name

!! 出力ファイル名を指定               123456789-123456789-123456789-123456789-123456789- 
  CHARACTER ( LEN = 200 ) :: OFILE = 'MIROC6_ensm_trend.1_50_${yr}_${mon}_mon'  ! output file name
!  CHARACTER ( LEN = 200 ) :: OFILE2 = 'MIROC6_ensm_T_trend.1_50_${yr}_${mon}_mon'  ! output file name
!  CHARACTER ( LEN = 200 ) :: OFILE3 = 'MIROC6_ensm_tval90_trend.1_50_${yr}_${mon}_mon'  ! output file name
!  CHARACTER ( LEN = 200 ) :: OFILE4 = 'MIROC6_ensm_sig90_trend.1_50_${yr}_${mon}_mon'  ! output file name
!  CHARACTER ( LEN = 200 ) :: OFILE5 = 'MIROC6_ensm_tval95_trend.1_50_${yr}_${mon}_mon'  ! output file name
!  CHARACTER ( LEN = 200 ) :: OFILE6 = 'MIROC6_ensm_sig95_trend.1_50_${yr}_${mon}_mon'  ! output file name
  CHARACTER ( LEN = 200 ) :: OFILE7 = 'MIROC6_ensm_sig95_90_trend.1_50_${yr}_${mon}_mon'  ! output file name
!  CHARACTER ( LEN = 200 ) :: OFILE8 = 'MIROC6_ensm_sigmae_trend.1_50_${yr}_${mon}_mon'  ! output file name
!  CHARACTER ( LEN = 200 ) :: OFILE9 = 'MIROC6_ensm_esty_trend.1_50_${yr}_${mon}_mon'  ! output file name

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
  DO i = 1, IMAX
     DO j = 1, JMAX
        IF ( ndata(i,j) .NE. 0.0000 ) THEN
                avex(i,j) = sumx(i,j) / ndata(i,j)
                avey(i,j) = sumy(i,j) / ndata(i,j)
        ELSE
                avex(i,j) = vmiss
                avey(i,j) = vmiss
        END IF
     END DO
  END DO

!  avex(:,:) = sumx(:,:) / ndata(:,:)
!  avey(:,:) = sumy(:,:) / ndata(:,:)

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

!! trend計算の分子
  block4(:,:) = xx(:,:) - ndata(:,:)*avex(:,:)*avex(:,:) 

!! トレンド計算
  trend = 0.0
!  trend(:,:) = 120.0*( block1(:,:) - ndata(:,:)*avex(:,:)*avey(:,:) ) / (xx(:,:) - ndata(:,:)*avex(:,:)*avex(:,:))  ! 120*[K/month] -> [K/decade]
!  trend(:,:) = 10.0*( block1(:,:) - ndata(:,:)*avex(:,:)*avey(:,:) ) / (xx(:,:) - ndata(:,:)*avex(:,:)*avex(:,:))  ! 10*[K/yr] -> [K/decade]

  DO i = 1, IMAX
     DO j = 1, JMAX
        IF( ndata(i,j) .NE. 0.0000 .AND. block4(i,j) .NE. 0.0000 ) THEN
                trend(i,j) = 10.0*( block1(i,j) - ndata(i,j)*avex(i,j)*avey(i,j) ) / (block4(i,j))  ! 10*[K/yr] -> [K/decade]
        ELSE
                trend(i,j) = vmiss
        END IF
     END DO
  END DO

  OPEN ( 20, FILE=OFILE, FORM='UNFORMATTED' ) ! open output file
  WRITE( 20 ) HEAD
  HEAD( 3 ) = 'trend'                         ! change item
  HEAD( 16 ) = 'K/decade'                     ! change unit
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
  
!  OPEN ( 21, FILE=OFILE9, FORM='UNFORMATTED' ) ! open output file
!  WRITE( 21 ) HEAD
!  WRITE( 21 ) esty
!  CLOSE( 21 ) ! close output file

!! T計算の分母 block2(i,j) = sigma((TASM-esty)**2) & sigmae(i,j) = SQRT( block2(i,j)/(ndata(i,j)-2) )
!! T計算の分子 block3(i,j) = sigma((x-avex)**2) )
  block2 = 0.0
  block3 = 0.0

  DO i = 1, IMAX
     DO j = 1, JMAX
        DO m = 1, MMAX
           IF( TASM(i,j,m) .NE. vmiss ) THEN
             block2(i,j) = block2(i,j) + ( TASM(i,j,m) - esty(i,j,m) ) ** 2
             block3(i,j) = block3(i,j) +  (x(i,j,m)-avex(i,j))**2 
           END IF
        END DO
     END DO
  END DO

  IF ( TASM(i,j,m) .NE. vmiss ) THEN
     sigmae(:,:) = SQRT( block2(:,:) / ( ndata(:,:) - 2.0 ) )
  END IF

!  OPEN ( 22, FILE=OFILE8, FORM='UNFORMATTED' ) ! open output file
!  WRITE( 22 ) HEAD
!  WRITE( 22 ) sigmae
!  CLOSE( 22 ) ! close output file

!! 検定統計量T値
  T(:,:) = trend(:,:) * SQRT(block3(:,:)) / sigmae(:,:)

!  OPEN( 30, FILE=OFILE2, FORM='UNFORMATTED' ) ! open output file
!  WRITE( 30 ) HEAD
!  WRITE( 30 ) T
!  CLOSE( 30 ) ! close output file
!
!--------------------------------------------
!! 閾値t値 (有意水準10%) tval90
!  tv = 0
!
  do i = 1, IMAX
     do j = 1, JMAX
        f = real( ndata(i,j) - 2 )
        if ( f == 1 ) then
           t_val = 6.314
        else if ( f == 2 ) then
           t_val = 2.920
        else if ( f == 3 ) then
           t_val = 2.353
        else if ( f == 4 ) then
           t_val = 2.132
        else if ( f == 5 ) then
           t_val = 2.015
        else if ( f == 6 ) then
           t_val = 1.943
        else if ( f == 7 ) then
           t_val = 1.895
        else if ( f == 8 ) then
           t_val = 1.860
        else if ( f == 9 ) then
           t_val = 1.833
        else if ( f == 10 ) then
           t_val = 1.812
        else if ( f == 11 ) then
           t_val = 1.796
        else if ( f == 12 ) then
           t_val = 1.782
        else if ( f == 13 ) then
           t_val = 1.771
        else if ( f == 14 ) then
           t_val = 1.761
        else if ( f == 15 ) then
           t_val = 1.753
        else if ( f == 16 ) then
           t_val = 1.746
        else if ( f == 17 ) then
           t_val = 1.740
        else if ( f == 18 ) then
           t_val = 1.734
        else if ( f == 19 ) then
           t_val = 1.729
        else if ( f == 20 ) then
           t_val = 1.725
        else if ( f == 21 ) then
           t_val = 1.721
        else if ( f == 22 ) then
           t_val = 1.717
        else if ( f == 23 ) then
           t_val = 1.714
        else if ( f == 24 ) then
           t_val = 1.711
        else if ( f == 25 ) then
           t_val = 1.708
        else if ( f == 26 ) then
           t_val = 1.706
        else if ( f == 27 ) then
           t_val = 1.703
        else if ( f == 28 ) then
           t_val = 1.701
        else if ( f == 29 ) then
           t_val = 1.699
        else if ( f == 30 ) then
           t_val = 1.697
        else if ( f == 31 ) then
           t_val = 1.696
        else if ( f == 32 ) then
           t_val = 1.694
        else if ( f == 33 ) then
           t_val = 1.692
        else if ( f == 34 ) then
           t_val = 1.691
        else if ( f == 35 ) then
           t_val = 1.690
        else if ( f == 36 ) then
           t_val = 1.688
        else if ( f == 37 ) then
           t_val = 1.687
        else if ( f == 38 ) then
           t_val = 1.686
        else if ( f == 39 ) then
           t_val = 1.685
        else if ( f == 40 ) then
           t_val = 1.684
        else if ( f == 41 ) then
           t_val = 1.683
        else if ( f == 42 ) then
           t_val = 1.682
        else if ( f == 43 ) then
           t_val = 1.681
        else if ( f == 44 ) then
           t_val = 1.680
        else if ( f == 45 ) then
           t_val = 1.679
        else if ( f == 46 ) then
           t_val = 1.679
        else if ( f == 47 ) then
           t_val = 1.678
        else if ( f == 48 ) then
           t_val = 1.677
        else if ( f == 49 ) then
           t_val = 1.677
        else if ( f == 50 ) then
           t_val = 1.676
        else if ( ( 50 < f ) .and. ( f < 60 ) ) then
           p = ((1./f)-(1./60.))/((1./50.)-(1./60.))
           t_val = p*1.676 + (1.-p)*1.671
        else if ( f == 60 ) then
           t_val = 1.671
        else if ( ( 60 < f ) .and. ( f < 80 ) ) then
           p = ((1./f)-(1./80.))/((1./60.)-(1./80.))
           t_val = p*1.671 + (1.-p)*1.664
        else if ( f == 80 ) then
           t_val = 1.664
        else if ( ( 80 < f ) .and. ( f < 120 ) ) then
           p = ((1./f)-(1./120.))/((1./80.)-(1./120.))
           t_val = p*1.664 + (1-p)*1.658
        else if ( f == 120 ) then
           t_val = 1.658
        else if ( ( 120 < f ) .and. ( f < 240 ) ) then
           p = ((1./f)-(1./240.))/((1./120.)-(1./240.))
           t_val = p*1.658 + (1-p)*1.651
        else if ( f <= 0 ) then
!           t_val = -9999
           t_val = vmiss
        else
           print*, 'Error!'
           stop !!! hoka no hyougen
        end if
        tval90(i,j) = t_val

!! 有意性検定 (有意水準10%) -> 有意な地点：trend(i,j) 有意でない地点：vmiss
        IF( ABS(T(i,j)) >= tval90(i,j) ) THEN
          sig90(i,j) = trend(i,j)                  ! 有意
        ELSE
          sig90(i,j) = vmiss                       ! 有意でない
        END IF
     end do
  end do

!  OPEN( 50, FILE=OFILE3, FORM='UNFORMATTED' ) ! open output file
!  WRITE( 50 ) HEAD
!  WRITE( 50 ) tval90
!  CLOSE( 50 ) ! close output file
  
!  OPEN( 60, FILE=OFILE4, FORM='UNFORMATTED' ) ! open output file
!  WRITE( 60 ) HEAD
!  WRITE( 60 ) sig90
!  CLOSE( 60 ) ! close output file

!--------------------------------------------
!! 閾値t値 (有意水準5%) tval95
!  tv = 0

  do i = 1, IMAX
     do j = 1, JMAX
        f = real( ndata(i,j) - 2 )
        if ( f == 1 ) then
           t_val = 12.706
        else if ( f == 2 ) then
           t_val = 4.303
        else if ( f == 3 ) then
           t_val = 3.182
        else if ( f == 4 ) then
           t_val = 2.776
        else if ( f == 5 ) then
           t_val = 2.571
        else if ( f == 6 ) then
           t_val = 2.447
        else if ( f == 7 ) then
           t_val = 2.365
        else if ( f == 8 ) then
           t_val = 2.306
        else if ( f == 9 ) then
           t_val = 2.262
        else if ( f == 10 ) then
           t_val = 2.228
        else if ( f == 11 ) then
           t_val = 2.201
        else if ( f == 12 ) then
           t_val = 2.179
        else if ( f == 13 ) then
           t_val = 2.160
        else if ( f == 14 ) then
           t_val = 2.145
        else if ( f == 15 ) then
           t_val = 2.131
        else if ( f == 16 ) then
           t_val = 2.120
        else if ( f == 17 ) then
           t_val = 2.110
        else if ( f == 18 ) then
           t_val = 2.101
        else if ( f == 19 ) then
           t_val = 2.093
        else if ( f == 20 ) then
           t_val = 2.086
        else if ( f == 21 ) then
           t_val = 2.080
        else if ( f == 22 ) then
           t_val = 2.074
        else if ( f == 23 ) then
           t_val = 2.069
        else if ( f == 24 ) then
           t_val = 2.064
        else if ( f == 25 ) then
           t_val = 2.060
        else if ( f == 26 ) then
           t_val = 2.056
        else if ( f == 27 ) then
           t_val = 2.052
        else if ( f == 28 ) then
           t_val = 2.048
        else if ( f == 29 ) then
           t_val = 2.045
        else if ( f == 30 ) then
           t_val = 2.042
        else if ( f == 31 ) then
           t_val = 2.040
        else if ( f == 32 ) then
           t_val = 2.037
        else if ( f == 33 ) then
           t_val = 2.035
        else if ( f == 34 ) then
           t_val = 2.032
        else if ( f == 35 ) then
           t_val = 2.030
        else if ( f == 36 ) then
           t_val = 2.028
        else if ( f == 37 ) then
           t_val = 2.026
        else if ( f == 38 ) then
           t_val = 2.024
        else if ( f == 39 ) then
           t_val = 2.023
        else if ( f == 40 ) then
           t_val = 2.021
        else if ( f == 41 ) then
           t_val = 2.020
        else if ( f == 42 ) then
           t_val = 2.018
        else if ( f == 43 ) then
           t_val = 2.017
        else if ( f == 44 ) then
           t_val = 2.015
        else if ( f == 45 ) then
           t_val = 2.014
        else if ( f == 46 ) then
           t_val = 2.013
        else if ( f == 47 ) then
           t_val = 2.012
        else if ( f == 48 ) then
           t_val = 2.011
        else if ( f == 49 ) then
           t_val = 2.010
        else if ( f == 50 ) then
           t_val = 2.009
        else if ( ( 50 < f ) .and. ( f < 60 ) ) then
           p = ((1./f)-(1./60.))/((1./50.)-(1./60.))
           t_val = p*2.009 + (1.-p)*2.000
        else if ( f == 60 ) then
           t_val = 2.000
        else if ( ( 60 < f ) .and. ( f < 80 ) ) then
           p = ((1./f)-(1./80.))/((1./60.)-(1./80.))
           t_val = p*2.000 + (1-p)*1.990
        else if ( f == 80 ) then
           t_val = 1.990
        else if ( ( 80 < f ) .and. ( f < 120 ) ) then
           p = ((1/f)-(1/120.))/((1/80.)-(1/120.))
           t_val = p*1.990 + (1-p)*1.980
        else if ( f == 120 ) then
           t_val = 1.980
        else if ( ( 120 < f ) .and. ( f < 240 ) ) then
           p = ((1/f)-(1/240.))/((1/120.)-(1/240.))
           t_val = p*1.980 + (1-p)*1.970
        else if ( f <= 0 ) then
!           t_val = 9999
           t_val = vmiss
        else
           print*, 'Error!'
           stop !!! hoka no hyougen
        end if
        tval95(i,j) = t_val

!! 有意性検定 (有意水準5%) -> 有意な地点：trend(i,j) 有意でない地点：vmiss
        IF( ABS(T(i,j)) >= tval95(i,j) ) THEN  
          sig95(i,j) = trend(i,j)                  ! 有意
        ELSE
          sig95(i,j) = vmiss                       ! 有意でない
        END IF
     end do
  end do

!  OPEN( 70, FILE=OFILE5, FORM='UNFORMATTED' ) ! open output file
!  WRITE( 70 ) HEAD
!  WRITE( 70 ) tval95
!  CLOSE( 70 ) ! close output file
  
!  OPEN( 80, FILE=OFILE6, FORM='UNFORMATTED' ) ! open output file
!  WRITE( 80 ) HEAD
!  HEAD( 3 ) = 'sig95'                         ! change item
!  WRITE( 80 ) sig95
!  CLOSE( 80 ) ! close output file

!! 有意性検定 (有意水準5%) -> 有意な地点:97.5 有意水準10%~5%未満の地点:92.5 有意でない地点:89
  DO i = 1, IMAX
     DO j = 1, JMAX  
        IF( ABS(T(i,j)) >= tval95(i,j) ) THEN
          sig95_90(i,j) = 97.5
        ELSE IF ( ABS(T(i,j)) >= tval90(i,j) ) THEN
          sig95_90(i,j) = 92.5
        ELSE
!          sig95_90(i,j) = vmiss
          sig95_90(i,j) = 89
        END IF
     END DO 
  END DO

  OPEN( 90, FILE=OFILE7, FORM='UNFORMATTED' ) ! open output file
  WRITE( 90 ) HEAD
  HEAD( 3 ) = 'sig95_90'                      ! change item
  WRITE( 90 ) sig95_90
  CLOSE( 90 ) ! close output file

END
EOF

gfortran -fconvert=big-endian ./cal_ensm_trend_T_sig_mon.f90;./a.out > ${LTOP}/log/test_ver1.txt    # コンパイル & 実行 & 実行結果を確認 (redirection)

mv ./cal_ensm_trend_T_sig_mon.f90 ${LTOP}/src/                                                      # fortranファイルをsrcに移動           

## 描画
cd ${LTOP}/data/run1_50/${D1}/${D1}_${mon}/                                                         # GTOOLデータの在り処へ移動

# 作業ディレクトリにカラーマップが無い場合 (polar以外など)
ln -s /usr/local/dcl/lib/dcldbase/colormap_67.x11 colormap.x11                                      # 特定のカラーマップをcolormap.x11としてシンボリックリンクする
# trend
gtcont MIROC6_ensm_trend.1_50_${yr}_${mon}_mon tone=-1,-0.6,-0.4,-0.2,-0.1,0.0,0.1,0.2,0.4,0.6,1.0 pat=10999,22999,28999,48999,53999,58999,65999,70999,89999,99999 map=1 -nocnt -print ps:MIROC6_ensm_trend.1_50_${yr}_${mon}_mon_rg-1_1.ps
gtcont MIROC6_ensm_trend.1_50_${yr}_${mon}_mon tone=-10,-1,-0.6,-0.4,-0.2,-0.1,0.0,0.1,0.2,0.4,0.6,1.0,10 pat=10999,12999,22999,28999,48999,53999,58999,65999,70999,89999,97999,99999 map=1 -nocnt -print ps:MIROC6_ensm_trend.1_50_${yr}_${mon}_mon_rg-10_10.ps
# sig95_90
gtcont MIROC6_ensm_sig95_90_trend.1_50_${yr}_${mon}_mon tone=85.0,90.0,95.0,100.0 pat=10999,53999,89999 map=1 -nocnt -print ps:MIROC6_ensm_sig95_90_trend.1_50_${yr}_${mon}_mon.ps
rm colormap.x11

# psファイルからpngファイルへ形式変更
convert -density 100 -rotate 90 MIROC6_ensm_trend.1_50_${yr}_${mon}_mon_rg-1_1.ps MIROC6_ensm_trend.1_50_${yr}_${mon}_mon_rg-1_1.png
convert -density 100 -rotate 90 MIROC6_ensm_trend.1_50_${yr}_${mon}_mon_rg-10_10.ps MIROC6_ensm_trend.1_50_${yr}_${mon}_mon_rg-10_10.png

convert -density 100 -rotate 90 MIROC6_ensm_sig95_90_trend.1_50_${yr}_${mon}_mon.ps MIROC6_ensm_sig95_90_trend.1_50_${yr}_${mon}_mon.png

