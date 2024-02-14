#! /bin/bash

# MIROC6 ensemblemean & 50例とHadCRUT5 ensemblemean & 200例の面積重み付き領域平均値を算出するプログラム (北緯32.5-87.5度)
#----------------------------------------------------------------------------------------------------------------------------------------------

mon=$1                                        # mon=1~12

cd /home/honoka/work/HadCRUT5_MIROC6/sppattern/data/trend/         # トレンドデータの在り処に移動 

cat << EOF > cal_trendwgtav_N30_90.f90
PROGRAM cal_trendwgtav_MIROC_HadCRUT

! MIROC6 ensemblemean & 50例とHadCRUT5 ensemblemean & 200例の空間相関を算出するプログラム
! gfortran -fconvert=big-endian cal_trendwgtav_N30_90.f90
!----------------------------------------------------------------------------------------------

      IMPLICIT NONE

      INTEGER, PARAMETER :: IMAX= 72                          ! No. of longitudinal grids
      INTEGER, PARAMETER :: JMAX= 36                          ! No. of latitudinal grids
      INTEGER, PARAMETER :: HMAX= 64                          ! No. of header informations
      INTEGER, PARAMETER :: MMAX= 55                          ! No. of months (1960-2014年1月55個の月別データ)
      INTEGER            :: KMIN                              ! No. of longitudinal grids(72)*latitudinal grids(36)
      INTEGER, PARAMETER :: KMAX= 2592                        ! No. of longitudinal grids(72)*latitudinal grids(36)
      INTEGER, PARAMETER :: ndata = 51                        ! MIROCデータ数 : ndata = run(50)+1
      REAL, PARAMETER    :: vmiss = -999.                     ! 欠損値
      INTEGER            :: i, j, n, k, w

      CHARACTER          :: HEAD( HMAX )*16                   ! headers

      INTEGER, PARAMETER :: arealon1 = 1                      ! 対象領域開始の経度番号    (input) : (ex) iarea1 = 1    (lon(1) = -177.5度)
      INTEGER, PARAMETER :: arealon2 = IMAX                   ! 対象領域終了の経度番号    (input) : (ex) iarea2 = IMAX (lon(72) = 177.5度)
      INTEGER, PARAMETER :: arealat1 = 25                     ! 対象領域開始の緯度番号    (input) : (ex) jarea1 = 25   (lat(25) = 北緯32.5度)
      INTEGER, PARAMETER :: arealat2 = JMAX                   ! 対象領域終了の緯度番号    (input) : (ex) jarea2 = JMAX (lat(36) = 北緯87.5度)
      REAL               :: lon( IMAX+1 )                     ! longitude   (経度：度)
      REAL               :: lonrad( IMAX )                    ! longitude   (rad)
      REAL               :: dlon = 5.0                        ! 1格子の経度 (度)
      REAL               :: lat( JMAX )                       ! latitude    (緯度：度)
      REAL               :: latrad( JMAX )                    ! latitude    (rad)
      REAL               :: dlat = 5.0                        ! 1格子の緯度 (度)
      REAL, PARAMETER    :: PI = 3.141592
      REAL, PARAMETER    :: earthrad = 6378.1                 ! 地球の半径 = 6378.1km
      REAL               :: grid( IMAX, JMAX )                ! 1格子の面積
      REAL               :: sumgrd                            ! 対象領域の面積
      REAL               :: wgtrto( arealon2-arealon1+1, arealat2-arealat1+1 )              ! 1格子の面積比率の2次元データ:wgtrto(i,j)
      REAL               :: wgtrto1d( (arealon2-arealon1+1)*(arealat2-arealat1+1) )         ! 1格子の面積比率の1次元データ:wgtrto1d(i*j)


      REAL :: trend1( IMAX, JMAX )                            ! HadCRUT5 ensemble meanにおけるtrend (1960-2014年の月毎トレンド) :xdata
      REAL :: trendHades( KMAX )                              ! HadCRUT5 ensemble meanにおけるtrend (1960-2014年の月毎トレンド)
      REAL :: trend2( IMAX, JMAX, ndata )                     ! MIROC6 ensemble mean & run1-50におけるtrend (1960-2014年の月毎トレンド) :ydata
      REAL :: trendMIROC( KMAX, ndata )                       ! MIROC6 ensemble mean & run1-50におけるtrend (1960-2014年の月毎トレンド)

      REAL :: numdt                                           ! trendの欠損値以外のデータ総数
      REAL :: sumtrendHades
      REAL :: sumtrendMIROC( ndata )
      REAL :: avetrendHades
      REAL :: avetrendMIROC( ndata )

      REAL :: difx( KMAX )                                    ! trendHades - avetrendHades(領域平均値)
      REAL :: dify( KMAX, ndata )                             ! trendMIROC - avetrendMIROCes(領域平均値)
!      REAL :: bunsi( KMAX, ndata )                            ! 空間相関の計算式の分子
      REAL :: bunsi( ndata )                                  ! 空間相関の計算式の分子
      REAL :: bunbo1                                          ! 空間相関の計算式の分母1項目
      REAL :: bunbo2( ndata )                                 ! 空間相関の計算式の分母2項目 

      REAL :: block1( ndata )                                 ! Sxy(block1) = xdataとydataの共分散 : HadCRIT5 ensemble mean - MIROC ensemble mean & run1~50
      REAL :: block2( ndata )                                 ! 空間相関の分母(sx*sy) : HadCRIT5 ensemble mean - MIROC ensemble mean & run1~50
      REAL :: xx                                              ! (xdata)**2の合計
      REAL :: yy( ndata )                                     ! (ydata)**2の合計 : MIROC ensemble mean & run1~50
      REAL :: sx                                              ! xdataの標準偏差
      REAL :: sy( ndata )                                     ! ydataの標準偏差 : MIROC ensemble mean & run1=50
      REAL :: patn( ndata )                                   ! HadCRUT5 ensemble meanとMIROC6 ensemble mean, MIROC6 run1~50の空間相関51個

!! 入力ファイル名を指定               123456789-123456789-123456789-123456789-123456789-1
      CHARACTER ( LEN = 200 ) :: IFILE = 'ifnmMIROC2_${mon}.txt'                                    ! trendのensemble mean ver

      CHARACTER ( LEN = 200 ) :: IFILEHad ='HadCRUT5_trend_1_200av_1960_2014_${mon}'                ! input file name : HadCRUT5 ensemble data (trendのensemble mean)

      CHARACTER ( LEN = 200 ) :: IFILEMIROC( ndata )                                                ! input file name : MIROC ensemble data & MIROC(run1~50)
      CHARACTER ( LEN = 200 ) :: IFILELon = 'GTAXLOC.GLON72CM'                                      ! longitude(軸ファイル) : -177.5, -172.5, ... , 177.5, 182.5 [73個]  
      CHARACTER ( LEN = 200 ) :: IFILELat = 'GTAXLOC.GLAT36IM'                                      ! latitude(軸ファイル) : -87.5, -82.5, ... , 82.5, 87.5 [36個]

!!　出力ファイル名を指定
      CHARACTER ( LEN = 200 ) :: OFILE = 'MIROC6r1_50av_trendwgtav_1960_2014_${mon}_N30_90.txt'     ! MIROC ensemblemeanのtrendの面積重み付き領域平均値 (trendのensemble mean)

      CHARACTER ( LEN = 200 ) :: OFILE2 = 'MIROC6_r1-50_trendwgtav_1960_2014_${mon}_N30_90.txt'     ! MIROC run1_50のtrendの面積重み付き領域平均値

      CHARACTER ( LEN = 200 ) :: OFILE3 = 'HadCRUT5_1_200av_trendwgtav_1960_2014_${mon}_N30_90.txt' ! HadCRUT5 ensemblemeanのtrendの面積重み付き領域平均値 (trendのensemble mean)


! 入力ファイルを変数に格納
      OPEN ( 11, FILE=IFILE, STATUS='OLD' )    ! open input file
      READ ( 11, * ) IFILEMIROC
      CLOSE ( 11 )
   
!---------------------------------------------
!! GTOOLデータの読み込み
! longitude
      OPEN ( 12, FILE=IFILELon, FORM='UNFORMATTED' )          ! open input file
      READ( 12 ) HEAD
      READ( 12 ) lon
      CLOSE( 12 )                                             ! close input file

! latitude
       OPEN ( 13, FILE=IFILELat, FORM='UNFORMATTED' )         ! open input file
       READ( 13 ) HEAD
       READ( 13 ) lat
       CLOSE( 13 )                                            ! close input file

!  HadCRUT5 ensemble meanにおける月毎trend
      CALL gt_open( IMAX, JMAX, IFILEHad, &                   ! input
                  & trend1 )                                  ! output

! MIROC ensemble data & run1-50における月毎trend
!      DO n = 1, ndata
!         CALL gt_open( IMAX, JMAX, IFILEMIROC(n), &          ! input        
!                     & trend2(:,:,n) )	                      ! output
!      END DO

      CALL gt_open2( IMAX, JMAX, ndata, IFILEMIROC, &         ! input
                   & trend2 )                                 ! output

!---------------------------------------------
!! dataに面積の重み付け
      CALL cal_wgtrto( IMAX, JMAX, arealon1, arealon2, arealat1, arealat2, lon, lat, dlon, dlat, &    ! input
                     & wgtrto )                                                                       ! output

!      DO j = 1, 12
!	 WRITE(*,*) "j=",j,"wgtrto(1,j)=",wgtrto(1,j)
!      END DO 

!---------------------------------------------
!! dataの1次元化 
!  HadCRUT5 ensemble meanにおける月毎trend
      CALL ch_dim21( IMAX, JMAX, trend1, &                    ! input
                   & trendHades )                             ! output

! MIROC ensemble data & run1-50における月毎trend
      CALL ch_dim32( IMAX, JMAX, ndata, trend2, &             ! input
                    & trendMIROC )                            ! output

! 面積比率
      CALL ch_dim21( arealon2-arealon1+1, arealat2-arealat1+1, wgtrto, & ! input
                   & wgtrto1d )                                          ! output 

!      DO w = 1, 864
!	 WRITE(*,*) "w=", w, "wgtrto1d(w)=",wgtrto1d(w)
!      END DO 

!---------------------------------------------
! 欠損値以外のデータ総数
      numdt = 0.0
      KMIN = IMAX*(arealat1-1) + 1
!      WRITE(*,*) KMIN

      DO k = KMIN, KMAX                                       ! 北半球 (北緯32.5-87.5度)
         IF ( trendHades(k) .NE. vmiss ) THEN
            numdt = numdt + 1.0
         END IF
      END DO

!---------------------------------------------
! 平均値の算出
      avetrendHades = 0.0
      avetrendMIROC = 0.0

!      DO k = 1, KMAX
!	  WRITE(*,*) k, "trendHades(k)=",trendHades(k)
!      END DO

      w = 1
      DO k = KMIN, KMAX                                       ! 北半球 (北緯32.5-87.5度)
         IF ( trendHades(k) .NE. vmiss ) THEN	 
            trendHades(k) = trendHades(k) * wgtrto1d(w)       ! 面積の重み付け 
            avetrendHades = avetrendHades + trendHades(k)     ! 面積の重み付き領域平均値      
!            trendHades(k) = trendHades(k) * 864               ! 面積の重み付きトレンドを算出
	    w = w + 1
         END IF
      END DO

      DO n = 1, ndata
         w = 1
         DO k = KMIN, KMAX                                            ! 北半球 (北緯32.5-87.5度)
            IF ( trendMIROC(k,n) .NE. vmiss ) THEN	 
               trendMIROC(k,n) = trendMIROC(k,n) * wgtrto1d(w)        ! 面積の重み付け
               avetrendMIROC(n) = avetrendMIROC(n) + trendMIROC(k,n)  ! 面積の重み付き領域平均値
!               trendMIROC(k,n)=trendMIROC(k,n)*864                    ! 面積の重み付きトレンドを算出
	       w = w + 1
            END IF
         END DO
      END DO

!      DO n = 1, ndata
!         WRITE(*,*) n, "avetrendMIROC(n)=", avetrendMIROC(n)     
!      END DO

!      WRITE(*,*) "avetrendHades=", avetrendHades

      OPEN ( 20, FILE=OFILE )                    ! open output file
      WRITE( 20,* ) avetrendMIROC(1)                                   ! MIROC ensemble trendの面積重み付き領域平均値
      CLOSE( 20 ) ! close output file

      OPEN ( 21, FILE=OFILE2 )                   ! open output file
      DO n = 2, 51
         WRITE( 21,* ) avetrendMIROC(n)                                ! MIROC run1_50 trendの面積重み付き領域平均値
      END DO
      CLOSE( 21 ) ! close output file
      
      OPEN ( 22, FILE=OFILE3 ) ! open output file
      WRITE( 22,* ) avetrendHades                                      ! HadCRUT5 ensemble trendの面積重み付き領域平均値
      CLOSE( 22 ) ! close output file


END PROGRAM cal_trendwgtav_MIROC_HadCRUT

!
!------------------------------------------------------------------------------------------------------------
!------------------------------------------------------------------------------------------------------------
!
subroutine gt_open( imax, jmax, ifile, var )
! 1つのgtoolデータを読む
      implicit none

      integer   :: imax                                       ! No. of longitudinal grids (input)
      integer   :: jmax                                       ! No. of latitudinal grids  (input)
      character (*) :: ifile                                  ! 入力ファイル名            (input)
      character :: head(64)*16                                ! ヘッダー情報              (internal work)
      real      :: var( imax, jmax )                          ! データを格納する変数      (output)
!
      open ( 10, file=ifile, form='unformatted' )             ! open input file
      read( 10 ) head                     
      read( 10 ) var                           
      close( 10 )       
 
end subroutine gt_open
!
!---------------------------------------------
!
subroutine gt_open2( imax, jmax, ndata, ifile, var )
! 複数のgtoolデータを1つの変数に読む

      implicit none

      integer   :: imax                                       ! No. of longitudinal grids (input)
      integer   :: jmax                                       ! No. of latitudinal grids  (input)
      integer   :: ndata                                      ! No. of data               (input)
      character (*) :: ifile( ndata )                         ! 入力ファイル名            (input)
      character :: head(64)*16                                ! ヘッダー情報              (internal work)
      integer   :: i,j,n                                      ! ループ変数                (internal work)
      real      :: var( imax, jmax, ndata )                   ! データを格納する変数      (output)

      DO n = 1, ndata
         CALL gt_open( imax, jmax, ifile(n), &                ! input        
                     & var(:,:,n) )	                      ! output
      END DO

end subroutine gt_open2
!
!---------------------------------------------
!
subroutine ch_dim21( imax, jmax, var2d, var1d ) 
! dataを2次元から1次元にする

      implicit none

      integer   :: imax                                       ! No. of longitudinal grids (input)
      integer   :: jmax                                       ! No. of latitudinal grids  (input)
      real      :: var2d( imax, jmax )                        ! 2次元データを格納する変数 (input)
      integer   :: kmax                                       ! kmax = imax*jmax          (internal work)
      integer   :: i, j, k                                    ! ループ変数                (internal work)
      real      :: var1d( imax*jmax )                         ! 2次元データを格納する変数 (output)
      
      do j = 1, jmax
         do i = 1, imax
            k = imax * ( j - 1 ) + i
            var1d(k) = var2d(i,j)
         end do
      end do
      
end subroutine ch_dim21
!
!---------------------------------------------
!
subroutine ch_dim32( imax, jmax, ndata, var3d, var2d )
! dataを3次元から2次元にする

      implicit none

      integer   :: imax                                       ! No. of longitudinal grids (input)
      integer   :: jmax                                       ! No. of latitudinal grids  (input)
      integer   :: ndata                                      ! No. of data               (input)
      real      :: var3d( imax, jmax, ndata )                 ! 3次元データを格納する変数 (input)
      integer   :: kmax                                       ! kmax = imax*jmax          (internal work)
      integer   :: i, j, k, n                                 ! ループ変数                (internal work)
      real      :: var2d( imax*jmax, ndata )                  ! 2次元データを格納する変数 (output)

      do n = 1, ndata
         do j = 1, jmax
            do i = 1, imax
               k = imax * ( j - 1 ) + i
               var2d(k,n) = var3d(i,j,n)
            end do
         end do
      end do

end subroutine ch_dim32
!
!---------------------------------------------
!
subroutine cal_wgtrto( imax, jmax, arealon1, arealon2, arealat1, arealat2, lon, lat, dlon, dlat, wgtrto )
!! 1格子毎の面積比率を算出するサブルーチン
      implicit none

      integer            :: imax                              ! No. of longitudinal grids (input)
      integer            :: jmax                              ! No. of latitudinal grids  (input)
      integer            :: arealon1                          ! 対象領域開始の経度番号    (input) : (ex) iarea1 = 1    (lon(1) = -177.5度)
      integer            :: arealon2                          ! 対象領域終了の経度番号    (input) : (ex) iarea2 = IMAX (lon(72) = 177.5度)
      integer            :: arealat1                          ! 対象領域開始の緯度番号    (input) : (ex) jarea1 = 19   (lat(19) = 北緯2.5度)
      integer            :: arealat2                          ! 対象領域終了の緯度番号    (input) : (ex) jarea2 = JMAX (lat(36) = 北緯87.5度)
      real               :: lon( imax+1 )                     ! longitude   [経度：度]    (input)
      real               :: lat( jmax )                       ! longitude   [経度：度]    (input)
      real               :: dlon                              ! 1格子の経度 (度)          (input)
      real               :: dlat                              ! 1格子の緯度 (度)          (input)
      integer            :: i, j                              !                           (internal work)
      real, parameter    :: PI = 3.141592                     !                           (internal work)
      real, parameter    :: earthrad = 6378.1                 ! 地球の半径 = 6378.1km     (internal work)
      real               :: lonrad( imax )                    ! longitude   [rad]         (internal work)
      real               :: latrad( jmax )                    ! latitude    [rad]         (internal work)
      real               :: grid( imax, jmax )                ! 1格子の面積               (internal work)
      real               :: sumgrd                            ! 対象領域の面積            (internal work)
      real               :: wgtrto( arealon2-arealon1+1, arealat2-arealat1+1 )              ! 1格子の面積比率           (output)

! ラジアンに変換
      do i = 1, IMAX
         lonrad(i) = lon(i) * ( PI / 180.0 )
      end do

      do j = 1, JMAX
         latrad(j) = lat(j) * ( PI / 180.0 )
      end do

!---------------------------------------------
! 1格子の面積
      dlon = dlon * ( PI / 180.0 )
      dlat = dlat * ( PI / 180.0 )

      do i = 1, IMAX
         do j = 1, JMAX
            grid(i,j) = (earthrad**2)*dlon*dlat*COS(latrad(j))
         end do
      end do

!      do j = 1, JMAX
!      write(*,*) "j=",j, "grid(1,j)=", grid(1,j)
!      end do

!---------------------------------------------
! 対象領域の面積
      sumgrd = 0.0

      do i = arealon1, arealon2                               ! 対象領域の経度(lon)を指定
         do j = arealat1, arealat2                            ! 対象領域の緯度(lat)を指定
            sumgrd = sumgrd + grid(i,j)
         end do
      end do

!---------------------------------------------
! 1格子の面積比率
!      wgtrto(:,:) = grid(:,:) / sumgrd
 
      do i = arealon1, arealon2
         do j = arealat1, arealat2
!            wgtrto(i,j) = grid(i,j) / sumgrd
            wgtrto(i,j-24) = grid(i,j) / sumgrd
         end do
      end do

!      do j = 1,12
!	 write(*,*) "j=", j, "wgtrto(1,j)=", wgtrto(1,j)
!      end do

end subroutine cal_wgtrto
EOF

# コンパイル & 出力ファイル指定
gfortran -fconvert=big-endian ./cal_trendwgtav_N30_90.f90;./a.out

mv ./cal_trendwgtav_N30_90.f90 /home/honoka/work/HadCRUT5_MIROC6/trendwgtav/src/

mv ./MIROC6r1_50av_trendwgtav_1960_2014_${mon}_N30_90.txt /home/honoka/work/HadCRUT5_MIROC6/trendwgtav/data/N30_90/                # MIROC trend run1-50av 領域平均値 (面積の重み付き)

mv ./MIROC6_r1-50_trendwgtav_1960_2014_${mon}_N30_90.txt /home/honoka/work/HadCRUT5_MIROC6/trendwgtav/data/N30_90/                 # MIROC run1-50 領域平均値 (面積の重み付き)

mv ./HadCRUT5_1_200av_trendwgtav_1960_2014_${mon}_N30_90.txt /home/honoka/work/HadCRUT5_MIROC6/trendwgtav/data/N30_90/             # HadCRUT5 1-200av 領域平均値 (面積の重み付き)
 
