PROGRAM cal_tval95

! 有意性検定　有意水準5%の閾値t値を計算するプログラム
!
! compile this program with the following way ;
!
! % gfortran -fconvert=big-endian cal_tval95.f90
!      
! This is because the GTOOL file should be written in "BIG ENDIAN".
!----------------------------------------------------------------------

      IMPLICIT NONE 
      
      INTEGER, PARAMETER :: IMAX= 72   ! No. of longitudinal grids
      INTEGER, PARAMETER :: JMAX= 36   ! No. of latitudinal grids
      INTEGER, PARAMETER :: HMAX= 64   ! No. of header informations
!      INTEGER, PARAMETER :: MMAX= 660   ! No. of months (1960-2014年660個の月別データ)
      INTEGER, PARAMETER :: MMAX= 55   ! No. of months (1960-2014年1月55個の月別データ)
      REAL, PARAMETER :: vmiss = -999. ! 欠損値

      CHARACTER :: HEAD( HMAX )*16 ! headers
      REAL :: TASM( IMAX, JMAX, MMAX )   ! data(ydata)
      REAL :: ndata( IMAX, JMAX )        ! 欠損値以外のデータ総数

      REAL :: trend( IMAX, JMAX )        ! トレンド (回帰係数)
      REAL :: T( IMAX, JMAX)             ! トレンドの検定統計量T値
      REAL :: tval95( IMAX, JMAX )       ! 有意水準10%の閾値 t値

      INTEGER :: m
 
!! 入力ファイル名を指定               123456789-123456789-123456789-123456789-123456789-1 
      CHARACTER ( LEN = 200 ) :: IFILE = 'HadCRUT.5.0.1.0.analysis.anomalies.ensemble_mean_1960_2014_1' ! input file name
      CHARACTER ( LEN = 200 ) :: IFILE2 = 'T_trend_1960_2014_1_mon' ! input file name

!! 出力ファイル名を指定               123456789-123456789-123456789-123456789-123456789- 
      CHARACTER ( LEN = 200 ) :: OFILE = 'tval90_1960_2014_1_mon'  ! output file name

!! GTOOLデータの読み込み 
!! HadCRUT5 元データ
      OPEN ( 10, FILE=IFILE, FORM='UNFORMATTED' ) ! open input file

      DO m = 1, MMAX
         READ( 10 ) HEAD
         READ( 10 ) TASM(:,:,m)
      END DO
      CLOSE( 10 )                                 ! close input file
!      WRITE(*,*) TASM(1,1,1)

!! トレンドの検定統計量T値
      OPEN ( 20, FILE=IFILE2, FORM='UNFORMATTED' ) ! open input file
      READ( 20 ) HEAD
      READ( 20 ) T
      CLOSE( 20 )                                 ! close input file
!      WRITE(*,*) T(1,1)
!
!---------------------------------------------------------------------
!
!! x,yの合計値、欠損値以外のデータ総数
      ndata = COUNT( MASK =( TASM /= vmiss ), DIM=3 )
      WRITE(*,*) ndata(1,1)
!
!---------------------------------------------------------------------
!
!! 有意水準5%の閾値 t値計算
      CALL t_test_95( IMAX, JMAX, ndata, tval95 )

      WRITE(*,*) tval95(1,1)

END PROGRAM cal_tval95
!
!-----------------------------------------------------------------
!
subroutine t_test_95( lon, lat, ndata, tv )
!
      implicit none
!
      integer :: lon, lat
      integer :: i, j
      real :: ndata( lon, lat ) , f, p, t_val, tv( lon, lat )
!
  tv = 0
  
  do i = 1, lon
     do j = 1, lat
        f = real( ndata(i,j) - 2 )
!        print*, ndata(i,j)
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
           p = ((1./f)-(1/60.))/((1./50.)-(1./60.))
           t_val = p*2.009 + (1.-p)*2.000
        else if ( f == 60 ) then
           t_val = 2.000
        else if ( ( 60 < f ) .and. ( f < 80 ) ) then
           p = ((1./f)-(1./80.))/((1./60.)-(1./80.))
           t_val = p*2.000 + (1.-p)*1.990
        else if ( f == 80 ) then
           t_val = 1.990
        else if ( ( 80 < f ) .and. ( f < 120 ) ) then
           p = ((1./f)-(1./120.))/((1./80.)-(1./120.))
           t_val = p*1.990 + (1.-p)*1.980
        else if ( f == 120 ) then
           t_val = 1.980
        else if ( ( 120 < f ) .and. ( f < 240 ) ) then
           p = ((1./f)-(1./240.))/((1./120.)-(1./240.))
           t_val = p*1.980 + (1.-p)*1.970
!        else if ( ndata(i,j) < 3 ) then
        else if ( ndata(i,j) <= 0 ) then
           t_val = 9999
        else
           print*, 'Error!'
           stop !!! hoka no hyougen
        end if
        tv(i,j) = t_val
     end do
  end do

! contains
! subroutine handle_err( status )
! !
!   integer :: status
! !
!   write( *, * ) nf_strerror( status )
!   stop
! !
! end subroutine handle_err

end subroutine t_test_95
!
!-----------------------------------------------------------------
!!


