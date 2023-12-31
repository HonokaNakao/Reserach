PROGRAM DRAW_Trend_Sig95_90

! トレンド(trend)と有意性(sig95_90)をDCLで重ね描きするプログラム
! 1960~2014年1月
!
! Compile this program with the following way ;
! % dclfrt draw_trend_sig.f90 -fconvert=big-endian && ./a.out
!--------------------------------------------------------------

      IMPLICIT NONE
!      INCLUDE '/usr/include/netcdf.inc'

!! 入力ファイル名を指定               123456789-123456789-123456789-123456789-123456789-1
      CHARACTER ( LEN = 200 ) :: IFILE1 = 'GTAXLOC.GLON72CM'                        ! input file name (GTOOL 緯度情報軸ファイル)
      CHARACTER ( LEN = 200 ) :: IFILE2 = 'GTAXLOC.GLAT36IM'                        ! input file name (GTOOL 経度情報軸ファイル)
!      CHARACTER ( LEN = 200 ) :: IFILE3 = 'trend_1960_2014_mon'                    ! input file name (1960~2014年 全期間のトレンド)
      CHARACTER ( LEN = 200 ) :: IFILE3 = 'trend_1960_2014_120102_mon'          ! input file name (1960~2014年 月毎のトレンド)
!      CHARACTER ( LEN = 200 ) :: IFILE4 = 'sig95_90_trend_1960_2014_mon'           ! input file name (1960~2014年 月毎の有意性：有意水準10%,5%)
      CHARACTER ( LEN = 200 ) :: IFILE4 = 'sig95_90_trend_1960_2014_120102_mon'  ! input file name (1960~2014年 全期間の有意性：有意水準10%,5%)

!! 出力ファイル名を指定               123456789-123456789-123456789-123456789-123456789-
!      CHARACTER ( LEN = 200 ) :: OFILE = 'trend_sig9590_1960_2014_mon'  ! output file name
      CHARACTER ( LEN = 200 ) :: OFILE = 'trend_sig9590_1960_2014_120102_mon'  ! output file name

      character( len = * ), parameter :: title = "HadCRUT5_ensm trend/sig95_90 1960-2014 120102"
      character( len = * ), parameter :: var1  = 'trend'
      character( len = * ), parameter :: var2  = 'sig'
!      character( len = * ), parameter :: bmin  = "-1"
!      character( len = * ), parameter :: bmax  = "1"
      character( len = * ), parameter :: bmin  = "-10"
      character( len = * ), parameter :: bmax  = "10"
      character( len = * ), parameter :: unit  = "[K/10yr]"
!      real, parameter :: tmin = -1.
!      real, parameter :: tmax = 1.
      real, parameter :: tmin = -10.
      real, parameter :: tmax = 10.
      real, parameter :: dt = 0.1
!
!--------------------------------------------
!
      INTEGER :: ncid, status
      INTEGER, PARAMETER :: lon=72   ! No. of longitudinal grids
      INTEGER, PARAMETER :: lat=36   ! No. of latitudinal grids
      INTEGER, PARAMETER :: hmax=64  ! No. of header informations
!
      CHARACTER :: HEAD( hmax )*16          ! GTOOLのヘッダー情報
      REAL :: lons( lon ), lats( lat )      ! 格子点情報(緯度・経度)
      REAL :: lons2( lon+1 )                ! DCLで描画する時の緯度:GTAXLOC.GLON72CMがlon(1)~lon(73)のため
!
      REAL :: trend( lon, lat )             ! トレンド (回帰係数):読み込むGTOOLファイル
      REAL :: trendout( lon+1, lat )        ! トレンド (回帰係数):DCLで描画するtrend
      REAL :: sig95_90( lon, lat )          ! 有意水準5%の有意性検定 (有意:trend(i,j) 有意水準10%~5%未満の地点:-99 有意でない:vmiss):読み込むGTOOLファイル
      REAL :: sig95_90out( lon+1, lat )     ! 有意水準5%の有意性検定 (有意:trend(i,j) 有意水準10%~5%未満の地点:-99 有意でない:vmiss):DCLで描画するtrend

      integer :: i, j, n, m
      REAL :: t_min, t_max, l_min, l_max
!
!!! test4 - 67
      INTEGER, PARAMETER :: map_num = 67    ! カラーマップ番号
!      REAL, PARAMETER :: tlev1(11) = (/ -1.0,-0.6,-0.4,-0.2,-0.1,0.0,0.1,0.2,0.4,0.6,1.0 /)               ! 軸(tone level)の値 (trendout)
      REAL, PARAMETER :: tlev1(13) = (/ -10.0,-1.0,-0.6,-0.4,-0.2,-0.1,0.0,0.1,0.2,0.4,0.6,1.0,10.0 /)     ! 軸(tone level)の値 (trendout)
      REAL, PARAMETER :: tlev2(4) = (/ 85.0,90.0,95.0,100.0 /)                                             ! 軸(tone level)の値 (sig95_90out)

!      integer, parameter :: noc = 11
      integer, parameter :: noc = 13
      integer :: inum(noc)
!
!  INTEGER :: ipat(noc)
!      INTEGER, PARAMETER :: ipat1(10) = (/ 10999,22999,28999,48999,53999,58999,65999,70999,89999,99999 /)             ! 色(color pattern)の値 (trendout)
      INTEGER, PARAMETER :: ipat1(12) = (/ 10999,12999,22999,28999,48999,53999,58999,65999,70999,89999,97999,99999 /)  ! 色(color pattern)の値 (trendout)
      INTEGER, PARAMETER :: ipat2(3) = (/ 1652, 1613, 1672 /)                                                          ! 色(color pattern)の値(sig95_90out) (色,パターンの種類,太さ&大きさ,密度)
!  REAL :: bar(noc+1,2), tbar(2,3), x(3), y(3)
!  REAL :: bar(noc,2), tbar(2,3), x(3), y(3)
      REAL :: x(4), y(4)
      REAL , PARAMETER :: lonmin=-180, lonmax=180, latmin=-90, latmax=90
      real :: l(lon+1, lat), lnd(lon, lat)

!---------------------------------------------------------------      
!! GTOOLデータの読み込み 

!! GTOOL 緯度情報軸ファイル
      OPEN ( 10, FILE=IFILE1, FORM='UNFORMATTED', CONVERT="big_endian" ) ! open input file(GTOOLファイルを開く時は、CONVERT="big_endian")                
      READ( 10 ) HEAD
      READ( 10 ) lons2                                                   ! "gtshow GTAXLOC.GLON72CM"で配列の数を確認
      CLOSE( 10 )
      WRITE(*,*) "lonmin=", lons2(1), "lonmax=", lons2(lon+1)

!! GTOOL 経度情報軸ファイル
      OPEN ( 20, FILE=IFILE2, FORM='UNFORMATTED', CONVERT="big_endian" ) ! open input file
      READ( 20 ) HEAD
      READ( 20 ) lats                                                    ! "gtshow GTAXLOC.GLAT36IM"で配列の数を確認
      CLOSE( 20 )
      WRITE(*,*) "latmin=", lats(1), "latmax=", lats(lat)

!! トレンド (trend)
      OPEN ( 30, FILE=IFILE3, FORM='UNFORMATTED', CONVERT="big_endian" ) ! open input file
      READ( 30 ) HEAD
      READ( 30 ) trend
      CLOSE( 30 )
! 元のtrend(GTOOLファイル)とDCLの緯度情報(lon)の配列数が異なる -> trend(73,:)にtrend(1,:)の情報を入れたtrendout(lon+1,lat)を作成
      DO i = 1, lon
         DO j = 1, lat
            trendout(i,j) = trend(i,j)
         END DO
      END DO

      trendout(lon+1,:) = trend(1,:)

!! 有意性 (sig95_90)
      OPEN ( 40, FILE=IFILE4, FORM='UNFORMATTED', CONVERT="big_endian" ) ! open input file
      READ( 40 ) HEAD
      READ( 40 ) sig95_90
      CLOSE( 40 )
! 元のsig95_90(GTOOLファイル)とDCLの緯度情報(lon)の配列数が異なる -> sig95_90(73,:)にsig95_90(1,:)の情報を入れたsig95_90out(lon+1,lat)を作成
      DO i = 1, lon
         DO j = 1, lat
            sig95_90out(i,j) = sig95_90(i,j)
         END DO
      END DO

      sig95_90out(lon+1,:) = sig95_90(1,:)

!---------------------------------------------------------------      
!! DCLで描画

  CALL swpset('LDUMP', .true.)                  ! true => make dumpfile(xwd)

  call gllset('lmiss', .true.)                  ! define non available (欠損値を設定)
  call glrset('rmiss', -999.)                  ! put number as non available (欠損値の値を定義。rmiss=-9999.)

  call sgscmn(map_num)                          ! color map (カラーマップ番号を指定)

  CALL GROPN(1)                                 ! 出力装置オープン

  CALL GRFRM                                    ! 新たなフレームの準備

!  call sgssim(0.5, 0., 0.)                     ! scaling factor & pointing offset (図の縮尺、中心点をずらす)
  call sgssim(0.14, 0., 0.)                     ! scaling factor & pointing offset (図の縮尺、中心点をずらす)
!  call sgssim(0.17, 0., 0.)                    ! scaling factor & pointing offset (図の縮尺、中心点をずらす)
!  call sgsmpl(150., 60., 0.)                   ! rotation angle (中心点の設定。東経150度、北緯60度を中心とし0度回転。 ex:北極(0.,90.,0.))
  call sgsmpl(90., 90., 0.)                     ! rotation angle (中心点の設定。東経150度、北緯60度を中心とし0度回転。 ex:北極(0.,90.,0.))
  call sgsvpt(0.1, 0.9, 0.3, 0.8)               ! viewport (紙(wimdow)のどこに描画するかを指定(viwepoint))

  call sglset('LCLIP', .true.)                  ! 図にはみだして描かない

!?                                              ! GRSWND,GRSVPT,sgstxy,GRSTRN,GRSTRFは1セット
  CALL GRSWND(lonmin, lonmax, latmax, latmin)   ! set window size (元データの上限、下限と一致させる)
  CALL GRSVPT(0.1, 0.9, 0.3, 0.8)               ! window上のどこに描画するかを指定 (viewpoint)
  call sgstxy(lonmin, lonmax, latmin, latmax)   ! set lon & lat window (緯度・経度を指定)
!  CALL GRSTRN(31)                              ! 正射図法
  CALL GRSTRN(15)                               ! KITADA図法
!  CALL GRSTRN(10)                              ! gtoolと同じ図法
!?
  CALL GRSTRF                                   ! 正規化変換を確定 set transform

  call ueitlv

!   DO i = 1, 10                                    
   DO i = 1, noc-1
      call uestlv(tlev1(i), tlev1(i+1), ipat1(i))   ! 塗り分けるtone levelとpatternを1level毎に指定
   END DO

  call uwsgxa( lons2, lon+1 )
  call uwsgya( lats, lat )
  WRITE(*,*) "aaa"
  CALL UETONE(trendout, lon+1, lon+1, lat)
  WRITE(*,*) "bbb"

! ハッチを付ける  
  call ueitlv                                   ! reset color

  DO i = 1, 3
      call uestlv(tlev2(i), tlev2(i+1), ipat2(i))   ! 塗り分けるtone levelとpatternを1level毎に指定
  END DO
  CALL UETONE(sig95_90out, lon+1, lon+1, lat)

  call umiset('indexmj', 1)
  call umiset('itypemj', 3)
  call umiset('indexout', 2)                    ! index of border line
  call umiset('itypeout', 1)                    ! line type of border line

  CALL UMPGLB                                   ! 地図の境界線・経度線・緯度線を描く
  WRITE(*,*) "test1"
  CALL UMPMAP('coast_world')                    ! 各種地図情報を描く（世界の海岸線）
  call slpvpr(3)                                ! line weight
  WRITE(*,*) "test2"

!!! トーンバー
  CALL GRFIG
  CALL GRSWND(tmin, tmax, 0.0, 1.0)             ! ウインドウの設定（x最大,x最小,y最大,y最小）
  CALL GRSVPT(0.2, 0.8, 0.10, 0.15)             ! ビューポートの設定
  CALL GRSTRN(1)                                ! 地図投影法の選択（今回は直角一様座標系）
  CALL GRSTRF                                   ! 正規化変換を確定する

  x(1) = tlev1(1) ; x(2) = tlev1(2) ; x(3) = tlev1(2) ; x(4) = tlev1(1)
  y(1) = 0. ; y(2) = 0. ; y(3) = 1. ; y(4) = 1.
  CALL SGTNZU( 4, x, y, ipat1(1) )

  x(1) = tlev1(2) ; x(2) = tlev1(3) ; x(3) = tlev1(3) ; x(4) = tlev1(2)
  CALL SGTNZU( 4, x, y, ipat1(2) )

  x(1) = tlev1(3) ; x(2) = tlev1(4) ; x(3) = tlev1(4) ; x(4) = tlev1(3)
  CALL SGTNZU( 4, x, y, ipat1(3) )

  x(1) = tlev1(4) ; x(2) = tlev1(5) ; x(3) = tlev1(5) ; x(4) = tlev1(4)
  CALL SGTNZU( 4, x, y, ipat1(4) )

  x(1) = tlev1(5) ; x(2) = tlev1(6) ; x(3) = tlev1(6) ; x(4) = tlev1(5)
  CALL SGTNZU( 4, x, y, ipat1(5) )

  x(1) = tlev1(6) ; x(2) = tlev1(7) ; x(3) = tlev1(7) ; x(4) = tlev1(6)
  CALL SGTNZU( 4, x, y, ipat1(6) )

  x(1) = tlev1(7) ; x(2) = tlev1(8) ; x(3) = tlev1(8) ; x(4) = tlev1(7)
  CALL SGTNZU( 4, x, y, ipat1(7) )

  x(1) = tlev1(8) ; x(2) = tlev1(9) ; x(3) = tlev1(9) ; x(4) = tlev1(8)
  CALL SGTNZU( 4, x, y, ipat1(8) )

  x(1) = tlev1(9) ; x(2) = tlev1(10) ; x(3) = tlev1(10) ; x(4) = tlev1(9)
  CALL SGTNZU( 4, x, y, ipat1(9) )

  x(1) = tlev1(10) ; x(2) = tlev1(11) ; x(3) = tlev1(11) ; x(4) = tlev1(10)
  CALL SGTNZU( 4, x, y, ipat1(10) )

  x(1) = tlev1(11) ; x(2) = tlev1(12) ; x(3) = tlev1(12) ; x(4) = tlev1(11)
  CALL SGTNZU( 4, x, y, ipat1(11) )

  x(1) = tlev1(12) ; x(2) = tlev1(13) ; x(3) = tlev1(13) ; x(4) = tlev1(12)
  CALL SGTNZU( 4, x, y, ipat1(12) )

  CALL SLPVPR( 3 )                        ! ビューポートの枠を描く(色,太さ)
  call uzlset('LABELYR', .false.)         ! true => write lavel year (縦軸のメモリを描く)
  call uzfact(0.8)
  call uysfmt('I3')
!  call uyaxdv('R', dt, 10*dt)

! ! トーンバーの凡例挿入
   CALL SGSTXS(0.02)                       ! フォントの大きさを5%から2%に変更
   CALL SGTXR(0.2,0.07,bmin)               ! 凡例の描画位置を描画領域の(20%,7%)の位置に設定
   CALL SGSTXS(0.02)                       ! フォントの大きさを5%から2%に変更
   CALL SGTXR(0.5,0.07,"0")                ! 凡例の描画位置を描画領域の(20%,7%)の位置に設定
   CALL SGSTXS(0.02)                       ! フォントの大きさを5%から2%に変更
   CALL SGTXR(0.8,0.07,bmax)               ! 凡例の描画位置を描画領域の(80%,7%)の位置に設定
   CALL SGSTXS(0.02)
   CALL SGTXR(0.75,0.17,unit)
   CALL SGSTXS(0.03)                       ! フォントの大きさを5%から3%に変更
   CALL SGTXR(0.5,0.03,"Tone Level")       ! 凡例の描画位置を描画領域の(50%,3%)の位置に設定

! 仕上げ

  CALL SGSTXS(0.03)
  CALL SGTXR(0.5,0.9,title)                     ! 図タイトルの挿入

  CALL GRCLS                                    ! 出力装置クローズ

  call system('mv dcl_0001.png '//ofile )

END PROGRAM DRAW_Trend_Sig95_90
