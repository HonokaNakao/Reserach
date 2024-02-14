#! /bin/bash

# HadCRUT5 ensemble meanとMIROC ensemble mean & run1-50の２変数(空間相関と領域平均値)の散布図を描画するプログラム

#----------------------------------------------------------------------------------------------------------------------------------------------

mon=$1
area=$2                                                                              # area=NP, N30_90
var1=sppatternwgt                                                                    # 面積重み付き空間相関
var2=trendwgtav                                                                      # 面積重み付き領域平均値

LTOP=/home/honoka/work/HadCRUT5_MIROC6/sppattern/
LTOP2=/home/honoka/work/HadCRUT5_MIROC6/sppattern/data/sppattern_Hades-MIROC/${area} # 空間相関データ(sppatternwgt)の在り処
LTOP3=/home/honoka/work/HadCRUT5_MIROC6/${var2}
LTOP4=/home/honoka/work/HadCRUT5_MIROC6/${var2}/data/${area}                         # 領域平均値データ(trendwgtav)の在り処
LTOP5=/home/honoka/work/HadCRUT5_MIROC6/scatterdg

## データ(空間相関 & 領域平均値)をシンボリックリンク
# 空間相関
ln -s ${LTOP2}/${var1}_Hades-MIROC_${mon}_${area}.txt

# 領域平均値
ln -s ${LTOP4}/HadCRUT5es_${var2}_1960_2014_${mon}_${area}.txt                       # HadCRUT5 ensemble mean
ln -s ${LTOP4}/MIROC6es_${var2}_1960_2014_${mon}_${area}.txt                         # MIROC6 ensemble mean
ln -s ${LTOP4}/MIROC6_r1-50_${var2}_1960_2014_${mon}_${area}.txt                     # MIROC6 run1-50

## 空間相関と領域平均値の散布図をDCLで描画
## 空間相関の度数分布表をDCLで描画
cat << EOF > draw_scatter.f90
PROGRAM Draw_Scatter_diagram

! 空間相関と領域平均値の散布図を描画するプログラム
!
! Compile this program with the following way ;
! % dclfrt draw_scatter.f90 -g && ./a.out
!--------------------------------------------------------------

      IMPLICIT NONE

      REAL, PARAMETER    :: ymin = -0.5                             ! 散布図 縦軸(y軸)の下限
      REAL, PARAMETER    :: ymax = 0.5                              ! 散布図 縦軸(y軸)の上限
      INTEGER, PARAMETER :: ndata = 50                              ! 空間相関　データ総数
      REAL, PARAMETER    :: xmin = -0.5                             ! 空間相関　横軸(x軸)の下限
      REAL, PARAMETER    :: xmax = 1.0                              ! 空間相関　横軸(x軸)上限
      REAL               :: patn(ndata)                             ! 空間相関 ( HadCRUT5 ensemble meanとMIROC run1-50 )
      REAL               :: patnes                                  ! 空間相関 ( HadCRUT5 ensemble meanとMIROC ensemble mean )
      REAL               :: Hadestrendav                            ! 領域平均値 ( HadCRUT5 ensemble mean )
      REAL               :: MIROCestrendav                          ! 領域平均値 ( MIROC ensemble mean )
      REAL               :: MIROCtrendav(ndata)                     ! 領域平均値 ( MIROC run1-50 )
      REAL               :: difMIROCestrendav                       ! 領域平均値の差 ( MIROC ensemble mean - HadCRUT5 ensemble mean )
      REAL               :: difMIROCtrendav(ndata)                  ! 領域平均値の差 ( MIROC run1-50 - HadCRUT5 ensemble mean )

      INTEGER :: n

! DCL
      INTEGER, PARAMETER :: itype = 1                               ! 枠のラインタイプ
      INTEGER, PARAMETER :: idx = 1                                 ! 枠のラインインデクス
!      INTEGER, PARAMETER :: itp1 = 10999                           ! トーンパターン番号
!      INTEGER, PARAMETER :: itp2 = 10999                           ! トーンパターン番号
      REAL, PARAMETER    :: rsize = 0.05                            ! 棒の幅
      REAL               :: dt                                      ! メモリ間隔

      REAL               :: yesm = ymin                              ! ensemble同士の空間相関のy値

!! 入力ファイル名を指定
      CHARACTER ( LEN = 200 ) :: IFILE = '${var1}_Hades-MIROC_${mon}_${area}.txt'               ! input file name ( 空間相関 )
      CHARACTER ( LEN = 200 ) :: IFILE2 = 'HadCRUT5es_${var2}_1960_2014_${mon}_${area}.txt'     ! input file name ( 領域平均値 : HadCRUT5 ensemble mean )
      CHARACTER ( LEN = 200 ) :: IFILE3 = 'MIROC6es_${var2}_1960_2014_${mon}_${area}.txt'       ! input file name ( 領域平均値 : MIROC6 ensemble mean )
      CHARACTER ( LEN = 200 ) :: IFILE4 = 'MIROC6_r1-50_${var2}_1960_2014_${mon}_${area}.txt'   ! input file name ( 領域平均値 : MIROC6 run1-50 )

!! 出力ファイル名を指定
      CHARACTER ( LEN = 300 ) :: OFILE = 'scatter_${var1}-${var2}_Hades-MIROC_${mon}_${area}'   ! output file name 
      CHARACTER( LEN = * ), PARAMETER :: title = "Hades-MIROC_${area} ${mon}"                   ! 図のタイトル 

!---------------------------------------------------------------
!! 空間相関データの読み込み
      OPEN ( 10, FILE=IFILE, STATUS='OLD' )    ! open input file
      READ ( 10, * ) patnes
      DO n = 1, ndata
         READ ( 10, * ) patn(n)
      END DO
      CLOSE ( 10 )

!! 領域平均値データの読み込み
! HadCRUT5 ensemble mean
      OPEN ( 11, FILE=IFILE2, STATUS='OLD' )   ! open input file
      READ ( 11, * ) Hadestrendav
      CLOSE ( 11 ) 

! MIROC ensemble mean
      OPEN ( 12, FILE=IFILE3, STATUS='OLD' )   ! open input file
      READ ( 12, * ) MIROCestrendav
      CLOSE ( 12 ) 

! MIROC run1-50
      OPEN ( 13, FILE=IFILE4, STATUS='OLD' )   ! open input file
      READ ( 13, * ) MIROCtrendav
      CLOSE ( 13 ) 
      
!---------------------------------------------------------------
!! 領域平均値の差 ( MIROC - HadCRUT5 ensemble mean )
! MIROC ensemble mean - HadCRUT5 ensemble mean
      difMIROCestrendav = MIROCestrendav - Hadestrendav

! MIROC run1-50 - HadCRUT5 ensemble mean
      difMIROCtrendav = MIROCtrendav - Hadestrendav

!---------------------------------------------------------------
!! DCLで散布図を描画
      CALL swpset('LDUMP', .true.)                  ! true => make dumpfile(xwd)

!  call gllset('lmiss', .true.)                     ! define non available (欠損値を設定)
!  call glrset('rmiss', -999.)                      ! put number as non available (欠損値の値を定義。rmiss=-9999.)

      CALL GROPN(1)                                 ! 出力装置オープン
      CALL GRFRM                                    ! 新たなフレームの準備
      call sglset('LCLIP', .true.)                  ! 図にはみだして描かない

!?                                                  ! GRSWND,GRSVPT,sgstxy,GRSTRN,GRSTRFは1セット
      CALL GRSWND(xmin, xmax, ymin, ymax)           ! set window size (元データの上限、下限と一致させる)
      CALL GRSVPT(0.2, 0.8, 0.2, 0.8)               ! window上のどこに描画するかを指定 (viewpoint)
      CALL GRSTRN(1)                                ! 座標変換 (1:線形)
      CALL GRSTRF                                   ! 正規化変換を確定 set transform

! 座標軸
!      CALL UXAXDV( 'B', 0.1, 0.5 )
!      CALL UYAXDV( 'L', 10.0, 50.0 )
!      CALL UYPAXS( 'L', 1 )
!      CALL UXAXDV( 'T', 0.1, 0.5 )

      CALL USDAXS                                    ! 軸おまかせ
      CALL UXSTTL( 'B', 'spatial pattern', 0.0 )     ! x軸タイトル
      CALL UYSTTL( 'L', 'diftrendav', 0.0 )          ! y軸タイトル
      CALL UXMTTL( 'T', title, 0.0 )                 ! 図のタイトル

! 散布図
      CALL SGPMZU( ndata, patn, difMIROCtrendav, 10, 11, 0.01 )

! patnes & difMIROCestrendavの点線を描画
! アローを描く
      CALL SGLAZU( patnes, yesm, patnes, 100.0, 3, 21)                       ! HadCRUT5 ensemble meanとMIROC ensemble meanの空間相関 ( 赤点線 )                 
!      CALL SGLAZU( xmin, difMIROCtrendav, 100.0, difMIROCtrendav, 3, 41)    ! 領域平均値の差　MIROC ensemble mean- HadCRUT5 ensemble mean ( 青点線 )
      CALL SGLAZU( xmin, difMIROCestrendav, 100.0, difMIROCestrendav, 3, 41) ! 領域平均値の差　MIROC ensemble mean- HadCRUT5 ensemble mean ( 青点線 )

      CALL GRCLS                                                         ! 出力装置クローズ

  call system('mv dcl_0001.png '//ofile )

END PROGRAM Draw_Scatter_diagram
EOF

# コンパイル & 出力ファイル指定
dclfrt ./draw_scatter.f90 -g && ./a.out

mv ./scatter_${var1}-${var2}_Hades-MIROC_${mon}_${area} ${LTOP5}/data/${area}/ 
mv ./draw_scatter.f90 ${LTOP5}/src/

# シンボリックリンクを削除
rm ${LTOP5}/src/${var1}_Hades-MIROC_${mon}_${area}.txt 
rm ${LTOP5}/src/HadCRUT5es_${var2}_1960_2014_${mon}_${area}.txt
rm ${LTOP5}/src/MIROC6es_${var2}_1960_2014_${mon}_${area}.txt
rm ${LTOP5}/src/MIROC6_r1-50_${var2}_1960_2014_${mon}_${area}.txt

