PROGRAM DRAW_Trend_Sig95_90

! トレンド(trend)と有意性(sig95_90)をDCLで重ね描きするプログラム
! 1960~2014年1月
!
! Compile this program with the following way ;
! % gfortran -fconvert=big-endian read_gtool.f90 && ./a.out
!--------------------------------------------------------------

      IMPLICIT NONE
      INCLUDE '/usr/include/netcdf.inc'

!! 入力ファイル名を指定               123456789-123456789-123456789-123456789-123456789-1
      CHARACTER ( LEN = 200 ) :: IFILE1 = 'GTAXLOC.GLON72CM'                ! input file name (GTOOL 緯度情報軸ファイル)
      CHARACTER ( LEN = 200 ) :: IFILE2 = 'GTAXLOC.GLAT36IM'                ! input file name (GTOOL 経度情報軸ファイル)
      CHARACTER ( LEN = 200 ) :: IFILE3 = 'trend_1960_2014_1_mon'           ! input file name (トレンド)
      CHARACTER ( LEN = 200 ) :: IFILE4 = 'sig95_90_trend_1960_2014_1_mon'  ! input file name (有意性：有意水準10%,5%)

!! 出力ファイル名を指定               123456789-123456789-123456789-123456789-123456789-
      CHARACTER ( LEN = 200 ) :: OFILE = 'trend_sig9590_1960_2014_1_mon'  ! output file name

      INTEGER, PARAMETER :: lon=72   ! No. of longitudinal grids
      INTEGER, PARAMETER :: lat=36   ! No. of latitudinal grids
      INTEGER, PARAMETER :: hmax=64  ! No. of header informations
!
      CHARACTER :: HEAD( hmax )*16     ! headers
      REAL :: lons( lon ), lats( lat ) ! grid points for longitude and latitude
      REAL :: trend( lon, lat )        ! トレンド (回帰係数)
      REAL :: sig95_90( lon, lat )     ! 有意水準5%の有意性検定 (有意:trend(i,j) 有意水準10%~5%未満の地点:-99 有意でない:vmiss)
!---------------------------------------------------------------      
!! GTOOLデータの読み込み 

!! GTOOL 緯度情報軸ファイル
      OPEN ( 10, FILE=IFILE1, FORM='UNFORMATTED' ) ! open input file
      READ( 10 ) HEAD
      READ( 10 ) lons
      CLOSE( 10 )
      WRITE(*,*) "lonmin=", lons(1), "lonmax=", lons(lon)

!! GTOOL 経度情報軸ファイル
      OPEN ( 20, FILE=IFILE2, FORM='UNFORMATTED' ) ! open input file
      READ( 20 ) HEAD
      READ( 20 ) lats
      CLOSE( 20 )
      WRITE(*,*) "latmin=", lats(1), "latmax=", lats(lat)

!! トレンド (trend)
      OPEN ( 30, FILE=IFILE3, FORM='UNFORMATTED' ) ! open input file
      READ( 30 ) HEAD
      READ( 30 ) trend
      CLOSE( 30 )

!! 有意性 (sig95_90)
      OPEN ( 40, FILE=IFILE4, FORM='UNFORMATTED' ) ! open input file
      READ( 40 ) HEAD
      READ( 40 ) sig95_90
      CLOSE( 40 )

END
