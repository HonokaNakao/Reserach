PROGRAM read_trend

! trend_1960_2014_mon (gtoolファイル)を読むプログラム
! gfortran -fconvert=big-endian read_trend.f90
!------------------------------------------------------------------------------------
  IMPLICIT NONE

  INTEGER, PARAMETER :: IMAX= 72   ! No. of longitudinal grids
  INTEGER, PARAMETER :: JMAX= 36   ! No. of latitudinal grids
  INTEGER, PARAMETER :: HMAX= 64   ! No. of header informations
  REAL, PARAMETER :: vmiss = -999. ! 欠損値

  CHARACTER :: HEAD( HMAX )*16 ! headers
  REAL :: trend( IMAX, JMAX )        ! data (trend)
!  REAL :: x( IMAX, JMAX, MMAX )      ! xdata

  REAL :: sumx( IMAX, JMAX )         ! x値の合計値
  REAL :: sumy( IMAX, JMAX )         ! y値の合計値
  REAL :: avex( IMAX, JMAX )         ! x値の平均値
  REAL :: avey( IMAX, JMAX )         ! y値の平均値
  REAL :: ndata( IMAX, JMAX )        ! 欠損値以外のデータ総数
  REAL :: dataratio( IMAX, JMAX )    ! データの存在割合　(欠損値以外のデータ総数/データ合計数)
  REAL :: xx( IMAX, JMAX )           ! x**2の合計 (分子1項目)
  REAL :: block1( IMAX, JMAX )       ! sigma(xi*yi) (分母1項目)

!! 入力ファイル名を指定               123456789-123456789-123456789-123456789-123456789-1
  CHARACTER ( LEN = 200 ) :: IFILE = 'trend_1960_2014_mon' ! input file name

!! 出力ファイル名を指定               123456789-123456789-123456789-123456789-123456789-
  CHARACTER ( LEN = 200 ) :: OFILE = 't_trend_1960_2014_mon'  ! output file name

!! GTOOLデータの読み込み
  OPEN ( 10, FILE=IFILE, FORM='UNFORMATTED' ) ! open input file

     READ( 10 ) HEAD
     READ( 10 ) trend
!     x(:,:,m) = m

  CLOSE( 10 )                                 ! close input file

END PROGRAM read_trend
