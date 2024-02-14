#! /bin/bash

# diftrendとsig95_90の重ね描きをするプログラム
# diftrend = MIROC6 ensemble mean trend - HadCRUT5 ensemble mean trend

# (1)特定の期間のtrend、sig95_90_trend(GTOOLデータファイル)を読む
#    (例)diftrend_MIROC6es-Hades_1960_2014_1 -> 1960年-2014年1月のトレンドの差
#        MIROC6_ensm_sig95_90_trend.1_50_1960_2014_1_mon -> 1960年-2014年１月の有意性(90,95%)のデータ
#
# (2)trend、sig95_90のデータをDCLで重ね描き
#    描画領域：北緯30-90度域（北極点中心）

#----------------------------------------------------------------------------------------------------------------------------------------------

LTOP='/home/honoka/work/HadCRUT5_MIROC6/diftrend/data'
yr=1960_2014
strnm=MIROC6_ensm
mon=$1

cd ${LTOP}/trend/diftrend_MIROC-Hades_${yr}_${mon}/          # GTOOLの在処に移動

# GTOOLの軸ファイルに対して作業ディレクトリからリンクを張る
ln -s /usr/local/gtool3.5/lib/gt3/GTAXLOC.GLAT36IM           # 緯度情報軸ファイル
ln -s /usr/local/gtool3.5/lib/gt3/GTAXLOC.GLON72CM           # 経度情報軸ファイル

## trend、sig95_90_trendデータの読み込み & DCLで重ね描き
cat << EOF > draw_diftrend_sig_mon_N30_90.f90
PROGRAM DRAW_DifTrend_Sig95_90_N30_90

! トレンドの差(diftrend)と有意性(sig95_90)をDCLで重ね描きするプログラム
! 1960~2014年1月
!
! Compile this program with the following way ;
! % dclfrt draw_diftrend_sig_mon_N30_90.f90 -fconvert=big-endian && ./a.out
!--------------------------------------------------------------

      IMPLICIT NONE

!! 入力ファイル名を指定               123456789-123456789-123456789-123456789-123456789-1
      CHARACTER ( LEN = 200 ) :: IFILE1 = 'GTAXLOC.GLON72CM'                                 ! input file name (GTOOL 緯度情報軸ファイル)
      CHARACTER ( LEN = 200 ) :: IFILE2 = 'GTAXLOC.GLAT36IM'                                 ! input file name (GTOOL 経度情報軸ファイル)
      CHARACTER ( LEN = 200 ) :: IFILE3 = 'diftrend_MIROC6es-Hades_${yr}_${mon}'             ! input file name (1960~2014年のトレンドの差)
      CHARACTER ( LEN = 200 ) :: IFILE4 = '${strnm}_sig95_90_trend.1_50_${yr}_${mon}_mon'    ! input file name (1960~2014年 全期間の有意性：有意水準10%,5%)

!! 出力ファイル名を指定               123456789-123456789-123456789-123456789-123456789-
      CHARACTER ( LEN = 200 ) :: OFILE = 'diftrend_sig9590_MIROCes-Hades_${yr}_${mon}_N30_90'    ! output file name

      character( len = * ), parameter :: title = "diftrend/sig95_90 es ${mon}"
      character( len = * ), parameter :: var1  = 'diftrend'
      character( len = * ), parameter :: var2  = 'sig'
      character( len = * ), parameter :: bmin  = "-5"
      character( len = * ), parameter :: bmax  = "5"
      character( len = * ), parameter :: unit  = "[K/10yr]"
      real, parameter :: tmin = -5.
      real, parameter :: tmax = 5.
      real, parameter :: dt = 0.1
!
!--------------------------------------------
!
      INTEGER :: ncid, status
      INTEGER, PARAMETER :: lon=72          ! No. of longitudinal grids
      INTEGER, PARAMETER :: lat=36          ! No. of latitudinal grids
      INTEGER, PARAMETER :: hmax=64         ! No. of header informations
!
      CHARACTER :: HEAD( hmax )*16          ! GTOOLのヘッダー情報
      REAL :: lons( lon ), lats( lat )      ! 格子点情報(緯度・経度)
      REAL :: lons2( lon+1 )                ! DCLで描画する時の緯度:GTAXLOC.GLON72CMがlon(1)~lon(73)のため
!
      REAL :: diftrend( lon, lat )          ! トレンド (回帰係数):読み込むGTOOLファイル
      REAL :: diftrendout( lon+1, lat )     ! トレンド (回帰係数):DCLで描画するdiftrend
      REAL :: sig95_90( lon, lat )          ! 有意水準5%の有意性検定 (有意:trend(i,j) 有意水準10%~5%未満の地点:-99 有意でない:vmiss):読み込むGTOOLファイル
      REAL :: sig95_90out( lon+1, lat )     ! 有意水準5%の有意性検定 (有意:trend(i,j) 有意水準10%~5%未満の地点:-99 有意でない:vmiss):DCLで描画するtrend

      integer :: i, j, n, m
      REAL :: t_min, t_max, l_min, l_max
!
!!! test4 - 67
      INTEGER, PARAMETER :: map_num = 67    ! カラーマップ番号
!      REAL, PARAMETER :: tlev1(11) = (/ -1.0,-0.6,-0.4,-0.2,-0.1,0.0,0.1,0.2,0.4,0.6,1.0 /)               ! 軸(tone level)の値 (diftrendout)
!      REAL, PARAMETER :: tlev1(13) = (/ -10.0,-1.0,-0.6,-0.4,-0.2,-0.1,0.0,0.1,0.2,0.4,0.6,1.0,10.0 /)     ! 軸(tone level)の値 (diftrendout)
      REAL, PARAMETER :: tlev1(13) = (/ -5.0,-2.0,-1.0,-0.5,-0.2,-0.1,0.0,0.1,0.2,0.5,1.0,2.0,5.0 /)        ! 軸(tone level)の値 (diftrendout)
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
      READ( 30 ) diftrend
      CLOSE( 30 )
! 元のtrend(GTOOLファイル)とDCLの緯度情報(lon)の配列数が異なる -> trend(73,:)にtrend(1,:)の情報を入れたtrendout(lon+1,lat)を作成
      DO i = 1, lon
         DO j = 1, lat
            diftrendout(i,j) = diftrend(i,j)
         END DO
      END DO

      diftrendout(lon+1,:) = diftrend(1,:)

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

  CALL swpset('LDUMP', .true.)                   ! true => make dumpfile(xwd)

  call gllset('lmiss', .true.)                   ! define non available (欠損値を設定)
  call glrset('rmiss', -999.)                    ! put number as non available (欠損値の値を定義。rmiss=-9999.)

  call sgscmn(map_num)                           ! color map (カラーマップ番号を指定)

  CALL GROPN(1)                                  ! 出力装置オープン

  CALL GRFRM                                     ! 新たなフレームの準備

!  call sgssim(0.23, 0., 0.)                      ! scaling factor & pointing offset (図の縮尺、中心点をずらす)
  call sgssim(0.27, 0., 0.)                      ! scaling factor & pointing offset (図の縮尺、中心点をずらす)
!  call sgsmpl(150., 60., 0.)                    ! rotation angle (中心点の設定。東経150度、北緯60度を中心とし0度回転。 ex:北極(0.,90.,0.))
!  call sgsmpl(90., 90., 0.)                     ! rotation angle (中心点の設定。東経150度、北緯60度を中心とし0度回転。 ex:北極(0.,90.,0.))
  call sgsmpl(0., 90., 80.)                      ! rotation angle (中心点の設定。東経150度、北緯60度を中心とし0度回転。 ex:北極(0.,90.,0.))
!  call sgsvpt(0.1, 0.9, 0.3, 0.8)               ! viewport (紙(wimdow)のどこに描画するかを指定(viwepoint))
  call sgsvpt(0.2, 0.8, 0.2, 0.8)                ! viewport (紙(wimdow)のどこに描画するかを指定(viwepoint))

  call sglset('LCLIP', .true.)                   ! 図にはみだして描かない

!?                                               ! GRSWND,GRSVPT,sgstxy,GRSTRN,GRSTRFは1セット
  CALL GRSWND(lonmin, lonmax, latmax, latmin)    ! set window size (元データの上限、下限と一致させる)
!  CALL GRSVPT(0.1, 0.9, 0.3, 0.8)               ! window上のどこに描画するかを指定 (viewpoint)
  CALL GRSVPT(0.2, 0.8, 0.23, 0.83)              ! window上のどこに描画するかを指定 (viewpoint)
!  call sgstxy(lonmin, lonmax, latmin, latmax)   ! set lon & lat window (緯度・経度を指定)
  call sgstxy(lonmin, lonmax, 30., latmax)       ! set lon & lat window (緯度・経度を指定)
  CALL GRSTRN(31)                                ! 正射図法
!  CALL GRSTRN(15)                               ! KITADA図法
!  CALL GRSTRN(10)                               ! gtoolと同じ図法
!?
  CALL GRSTRF                                    ! 正規化変換を確定 set transform

  call ueitlv

!   DO i = 1, 10
   DO i = 1, noc-1
      call uestlv(tlev1(i), tlev1(i+1), ipat1(i))   ! 塗り分けるtone levelとpatternを1level毎に指定
   END DO

  call uwsgxa( lons2, lon+1 )
  call uwsgya( lats, lat )
  CALL UETONE(diftrendout, lon+1, lon+1, lat)

! ハッチを付ける  
  call ueitlv                                       ! reset color

  DO i = 1, 3
      call uestlv(tlev2(i), tlev2(i+1), ipat2(i))   ! 塗り分けるtone levelとpatternを1level毎に指定
  END DO
  CALL UETONE(sig95_90out, lon+1, lon+1, lat)

  call umiset('indexmj', 1)
  call umiset('itypemj', 3)
  call umiset('indexout', 2)                    ! index of border line
  call umiset('itypeout', 1)                    ! line type of border line

  CALL UMPGLB                                   ! 地図の境界線・経度線・緯度線を描く
  CALL UMPMAP('coast_world')                    ! 各種地図情報を描く（世界の海岸線）
  call slpvpr(3)                                ! line weight

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

  CALL SLPVPR( 3 )                         ! ビューポートの枠を描く(色,太さ)
  call uzlset('LABELYR', .false.)          ! true => write lavel year (縦軸のメモリを描く)
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
  CALL SGTXR(0.5,0.9,title)                ! 図タイトルの挿入

  CALL GRCLS                               ! 出力装置クローズ

  call system('mv dcl_0001.png '//ofile )

END PROGRAM DRAW_DifTrend_Sig95_90_N30_90
EOF

dclfrt draw_diftrend_sig_mon_N30_90.f90 && ./a.out                                     # DCLで描画する際は、little-endianでコンパイルする(draw_trend.sig.f90内で、gtoolのみbig-endian指定する) 

rm a.out GTAXLOC* 
mv ./draw_diftrend_sig_mon_N30_90.f90 /home/honoka/work/HadCRUT5_MIROC6/diftrend/src/  # fortranファイルをsrcに移動

mkdir ${LTOP}/N30_90/diftrend_MIROC-Hades_${yr}_${mon}
mv ./diftrend_sig9590_MIROCes-Hades_${yr}_${mon}_N30_90 ${LTOP}/N30_90/diftrend_MIROC-Hades_${yr}_${mon}/

# 画像の切り取り (convert)
#convert -density 100 -crop 664x470+110+40 diftrend_sig9590_MIROCes-Hades_${yr}_${mon}_NP diftrend_sig9590_MIROCes-Hades_${mon}_NP
