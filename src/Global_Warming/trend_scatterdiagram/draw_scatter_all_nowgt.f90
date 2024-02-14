PROGRAM Draw_Scatter_diagram

! 空間相関と領域平均値の散布図を描画するプログラム
!
! Compile this program with the following way ;
! % dclfrt draw_scatter_all_nowgt.f90 -g && ./a.out
!--------------------------------------------------------------

      IMPLICIT NONE

      REAL, PARAMETER    :: ymin = -0.5                             ! 散布図 縦軸(y軸)の下限
      REAL, PARAMETER    :: ymax = 0.5                              ! 散布図 縦軸(y軸)の上限
      INTEGER, PARAMETER :: ndata = 50                              ! 空間相関　データ総数
      REAL, PARAMETER    :: xmin = -0.5                             ! 空間相関　横軸(x軸)の下限
      REAL, PARAMETER    :: xmax = 1.0                              ! 空間相関　横軸(x軸)上限
      INTEGER, PARAMETER :: ssn = 4                                 ! season = 4 ( MAM, JJA, SON, DJF )
!      REAL               :: patn( ndata )                          ! 空間相関 ( HadCRUT5 ensemble meanとMIROC run1-50 )
      REAL               :: patn1( ndata )                          ! 空間相関 ( HadCRUT5 ensemble meanとMIROC run1-50 ) : MAM
      REAL               :: patn2( ndata )                          ! 空間相関 ( HadCRUT5 ensemble meanとMIROC run1-50 ) : JJA
      REAL               :: patn3( ndata )                          ! 空間相関 ( HadCRUT5 ensemble meanとMIROC run1-50 ) : SON
      REAL               :: patn4( ndata )                          ! 空間相関 ( HadCRUT5 ensemble meanとMIROC run1-50 ) : DJF
!      REAL               :: patn( ndata, ssn )                      ! 空間相関 ( HadCRUT5 ensemble meanとMIROC run1-50 )
!      REAL               :: patnes                                 ! 空間相関 ( HadCRUT5 ensemble meanとMIROC ensemble mean )
      REAL               :: patnes1                                 ! 空間相関 ( HadCRUT5 ensemble meanとMIROC ensemble mean ) : MAM
      REAL               :: patnes2                                 ! 空間相関 ( HadCRUT5 ensemble meanとMIROC ensemble mean ) : JJA
      REAL               :: patnes3                                 ! 空間相関 ( HadCRUT5 ensemble meanとMIROC ensemble mean ) : SON
      REAL               :: patnes4                                 ! 空間相関 ( HadCRUT5 ensemble meanとMIROC ensemble mean ) : DJF
!      REAL               :: patnes( ssn )                           ! 空間相関 ( HadCRUT5 ensemble meanとMIROC ensemble mean )
!      REAL               :: Hadestrendav                           ! 領域平均値 ( HadCRUT5 ensemble mean )
      REAL               :: Hadestrendav1                           ! 領域平均値 ( HadCRUT5 ensemble mean ) : MAM
      REAL               :: Hadestrendav2                           ! 領域平均値 ( HadCRUT5 ensemble mean ) : JJA
      REAL               :: Hadestrendav3                           ! 領域平均値 ( HadCRUT5 ensemble mean ) : SON
      REAL               :: Hadestrendav4                           ! 領域平均値 ( HadCRUT5 ensemble mean ) : DJF
!      REAL               :: Hadestrendav( ssn )                     ! 領域平均値 ( HadCRUT5 ensemble mean )
!      REAL               :: MIROCestrendav                         ! 領域平均値 ( MIROC ensemble mean )
      REAL               :: MIROCestrendav1                         ! 領域平均値 ( MIROC ensemble mean ) : MAM
      REAL               :: MIROCestrendav2                         ! 領域平均値 ( MIROC ensemble mean ) : JJA
      REAL               :: MIROCestrendav3                         ! 領域平均値 ( MIROC ensemble mean ) : SON
      REAL               :: MIROCestrendav4                         ! 領域平均値 ( MIROC ensemble mean ) : DJF
!      REAL               :: MIROCestrendav( ssn )                   ! 領域平均値 ( MIROC ensemble mean )
!      REAL               :: MIROCtrendav( ndata )                  ! 領域平均値 ( MIROC run1-50 )
      REAL               :: MIROCtrendav1( ndata )                  ! 領域平均値 ( MIROC run1-50 ) : MAM
      REAL               :: MIROCtrendav2( ndata )                  ! 領域平均値 ( MIROC run1-50 ) : JJA
      REAL               :: MIROCtrendav3( ndata )                  ! 領域平均値 ( MIROC run1-50 ) : SON
      REAL               :: MIROCtrendav4( ndata )                  ! 領域平均値 ( MIROC run1-50 ) : DJF
!      REAL               :: MIROCtrendav( ndata, ssn )              ! 領域平均値 ( MIROC run1-50 )
!      REAL               :: difMIROCestrendav                      ! 領域平均値の差 ( MIROC ensemble mean - HadCRUT5 ensemble mean )
      REAL               :: difMIROCestrendav1                      ! 領域平均値の差 ( MIROC ensemble mean - HadCRUT5 ensemble mean ) : MAM
      REAL               :: difMIROCestrendav2                      ! 領域平均値の差 ( MIROC ensemble mean - HadCRUT5 ensemble mean ) : JJA
      REAL               :: difMIROCestrendav3                      ! 領域平均値の差 ( MIROC ensemble mean - HadCRUT5 ensemble mean ) : SON
      REAL               :: difMIROCestrendav4                      ! 領域平均値の差 ( MIROC ensemble mean - HadCRUT5 ensemble mean ) : DJF
!      REAL               :: difMIROCestrendav( ssn )                ! 領域平均値の差 ( MIROC ensemble mean - HadCRUT5 ensemble mean )
!      REAL               :: difMIROCtrendav( ndata )               ! 領域平均値の差 ( MIROC run1-50 - HadCRUT5 ensemble mean )
      REAL               :: difMIROCtrendav1( ndata )               ! 領域平均値の差 ( MIROC run1-50 - HadCRUT5 ensemble mean ) : MAM
      REAL               :: difMIROCtrendav2( ndata )               ! 領域平均値の差 ( MIROC run1-50 - HadCRUT5 ensemble mean ) : JJA
      REAL               :: difMIROCtrendav3( ndata )               ! 領域平均値の差 ( MIROC run1-50 - HadCRUT5 ensemble mean ) : SON
      REAL               :: difMIROCtrendav4( ndata )               ! 領域平均値の差 ( MIROC run1-50 - HadCRUT5 ensemble mean ) : DJF
!      REAL               :: difMIROCtrendav( ndata, ssn )           ! 領域平均値の差 ( MIROC run1-50 - HadCRUT5 ensemble mean )

      INTEGER :: n, s

! DCL
      INTEGER, PARAMETER :: itype = 1                               ! 枠のラインタイプ
      INTEGER, PARAMETER :: idx = 1                                 ! 枠のラインインデクス
!      INTEGER, PARAMETER :: itp1 = 10999                           ! トーンパターン番号
!      INTEGER, PARAMETER :: itp2 = 10999                           ! トーンパターン番号
      REAL, PARAMETER    :: rsize = 0.05                            ! 棒の幅
      REAL               :: dt                                      ! メモリ間隔

      REAL               :: yesm = ymin                              ! ensemble同士の空間相関のy値

!! 入力ファイル名を指定
! 空間相関 (面積の重み付けなし)
      CHARACTER ( LEN = 200 ) :: IFILE10 = 'sppattern_Hadav-MIROC_030405_N30_90_nowgt.txt'      ! MAM
      CHARACTER ( LEN = 200 ) :: IFILE11 = 'sppattern_Hadav-MIROC_060708_N30_90_nowgt.txt'      ! JJA
      CHARACTER ( LEN = 200 ) :: IFILE12 = 'sppattern_Hadav-MIROC_091011_N30_90_nowgt.txt'      ! SON
      CHARACTER ( LEN = 200 ) :: IFILE13 = 'sppattern_Hadav-MIROC_120102_N30_90_nowgt.txt'      ! DJF

! 領域平均値------------------------------------------------------------------------------------
! HadCRUT5 アンサンブル平均
      CHARACTER ( LEN = 200 ) :: IFILE20 = 'HadCRUT5_1_200av_trendwgtav_1960_2014_030405_N30_90.txt'     ! MAM
      CHARACTER ( LEN = 200 ) :: IFILE21 = 'HadCRUT5_1_200av_trendwgtav_1960_2014_060708_N30_90.txt'     ! JJA
      CHARACTER ( LEN = 200 ) :: IFILE22 = 'HadCRUT5_1_200av_trendwgtav_1960_2014_091011_N30_90.txt'     ! SON
      CHARACTER ( LEN = 200 ) :: IFILE23 = 'HadCRUT5_1_200av_trendwgtav_1960_2014_120102_N30_90.txt'     ! DJF

! MIROC6 アンサンブル平均
      CHARACTER ( LEN = 200 ) :: IFILE30 = 'MIROC6r1_50av_trendwgtav_1960_2014_030405_N30_90.txt'        ! MAM
      CHARACTER ( LEN = 200 ) :: IFILE31 = 'MIROC6r1_50av_trendwgtav_1960_2014_060708_N30_90.txt'        ! JJA
      CHARACTER ( LEN = 200 ) :: IFILE32 = 'MIROC6r1_50av_trendwgtav_1960_2014_091011_N30_90.txt'        ! SON
      CHARACTER ( LEN = 200 ) :: IFILE33 = 'MIROC6r1_50av_trendwgtav_1960_2014_120102_N30_90.txt'        ! DJF

! MIROC6 run1-50
      CHARACTER ( LEN = 200 ) :: IFILE40 = 'MIROC6_r1-50_trendwgtav_1960_2014_030405_N30_90.txt'         ! MAM
      CHARACTER ( LEN = 200 ) :: IFILE41 = 'MIROC6_r1-50_trendwgtav_1960_2014_060708_N30_90.txt'         ! JJA
      CHARACTER ( LEN = 200 ) :: IFILE42 = 'MIROC6_r1-50_trendwgtav_1960_2014_091011_N30_90.txt'         ! SON
      CHARACTER ( LEN = 200 ) :: IFILE43 = 'MIROC6_r1-50_trendwgtav_1960_2014_120102_N30_90.txt'         ! DJF

!! 出力ファイル名を指定
      CHARACTER ( LEN = 300 ) :: OFILE = 'scatter_sppattern-trendwgtav_Hadav-MIROC_allseason_N30_90_nowgt'   ! output file name 
      CHARACTER( LEN = * ), PARAMETER :: title = "Hadav-MIROC_N30_90 MJSD"                   ! 図のタイトル 

!---------------------------------------------------------------
!! 空間相関データの読み込み
      OPEN ( 11, FILE=IFILE10, STATUS='OLD' )    ! open input file
      READ ( 11, * ) patnes1
      DO n = 1, ndata
         READ ( 11, * ) patn1(n)
      END DO
      CLOSE ( 11 )

      OPEN ( 20, FILE=IFILE11, STATUS='OLD' )    ! open input file
      READ ( 20, * ) patnes2
      DO n = 1, ndata
         READ ( 20, * ) patn2(n)
      END DO
      CLOSE ( 20 )

      OPEN ( 21, FILE=IFILE12, STATUS='OLD' )    ! open input file
      READ ( 21, * ) patnes3
      DO n = 1, ndata
         READ ( 21, * ) patn3(n)
      END DO
      CLOSE ( 21 )

      OPEN ( 22, FILE=IFILE13, STATUS='OLD' )    ! open input file
      READ ( 22, * ) patnes4
      DO n = 1, ndata
         READ ( 22, * ) patn4(n)
      END DO
      CLOSE ( 22 )

!! 領域平均値データの読み込み
! HadCRUT5 ensemble mean
      OPEN ( 23, FILE=IFILE20, STATUS='OLD' )   ! open input file
      READ ( 23, * ) Hadestrendav1
      CLOSE ( 23 ) 

      OPEN ( 24, FILE=IFILE21, STATUS='OLD' )   ! open input file
      READ ( 24, * ) Hadestrendav2
      CLOSE ( 24 ) 

      OPEN ( 25, FILE=IFILE22, STATUS='OLD' )   ! open input file
      READ ( 25, * ) Hadestrendav3
      CLOSE ( 25 ) 

      OPEN ( 26, FILE=IFILE23, STATUS='OLD' )   ! open input file
      READ ( 26, * ) Hadestrendav4
      CLOSE ( 26 ) 

! MIROC ensemble mean
      OPEN ( 27, FILE=IFILE30, STATUS='OLD' )   ! open input file
      READ ( 27, * ) MIROCestrendav1
      CLOSE ( 27 ) 

      OPEN ( 28, FILE=IFILE31, STATUS='OLD' )   ! open input file
      READ ( 28, * ) MIROCestrendav2
      CLOSE ( 28 ) 

      OPEN ( 29, FILE=IFILE32, STATUS='OLD' )   ! open input file
      READ ( 29, * ) MIROCestrendav3
      CLOSE ( 29 ) 

      OPEN ( 30, FILE=IFILE33, STATUS='OLD' )   ! open input file
      READ ( 30, * ) MIROCestrendav4
      CLOSE ( 30 ) 

! MIROC run1-50
      OPEN ( 31, FILE=IFILE40, STATUS='OLD' )   ! open input file
      DO n = 1, ndata
         READ ( 31, * ) MIROCtrendav1(n)
      END DO
      CLOSE ( 31 ) 
      
      OPEN ( 32, FILE=IFILE41, STATUS='OLD' )   ! open input file
      DO n = 1, ndata
         READ ( 32, * ) MIROCtrendav2(n)
      END DO
      CLOSE ( 32 ) 

      OPEN ( 33, FILE=IFILE42, STATUS='OLD' )   ! open input file
      DO n = 1, ndata
         READ ( 33, * ) MIROCtrendav3(n)
      END DO
      CLOSE ( 33 ) 

      OPEN ( 34, FILE=IFILE43, STATUS='OLD' )   ! open input file
      DO n = 1, ndata
         READ ( 34, * ) MIROCtrendav4(n)
      END DO
      CLOSE ( 34 ) 

!---------------------------------------------------------------
!! 領域平均値の差 ( MIROC - HadCRUT5 ensemble mean )
! MIROC ensemble mean - HadCRUT5 ensemble mean
!      difMIROCestrendav = MIROCestrendav - Hadestrendav
      difMIROCestrendav1 = MIROCestrendav1 - Hadestrendav1
      difMIROCestrendav2 = MIROCestrendav2 - Hadestrendav2
      difMIROCestrendav3 = MIROCestrendav3 - Hadestrendav3
      difMIROCestrendav4 = MIROCestrendav4 - Hadestrendav4

! MIROC run1-50 - HadCRUT5 ensemble mean
!      difMIROCtrendav = MIROCtrendav - Hadestrendav
      difMIROCtrendav1 = MIROCtrendav1 - Hadestrendav1
      difMIROCtrendav2 = MIROCtrendav2 - Hadestrendav2
      difMIROCtrendav3 = MIROCtrendav3 - Hadestrendav3
      difMIROCtrendav4 = MIROCtrendav4 - Hadestrendav4

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
!      CALL SGPMZU( ndata, patn, difMIROCtrendav, 10, 11, 0.01 )
      CALL SGPMZU( ndata, patn1, difMIROCtrendav1, 10, 31, 0.01 )  ! 黄緑点 : MAM
      CALL SGPMZU( ndata, patn2, difMIROCtrendav2, 10, 21, 0.01 )  ! 赤点 : JJA
      CALL SGPMZU( ndata, patn3, difMIROCtrendav3, 10, 781, 0.01 ) ! オレンジ点 : SON
      CALL SGPMZU( ndata, patn4, difMIROCtrendav4, 10, 41, 0.01 )  ! 青点 : DJF

! patnes & difMIROCestrendavの点線を描画
! アローを描く
!      CALL SGLAZU( patnes, yesm, patnes, 100.0, 3, 21)                       ! HadCRUT5 ensemble meanとMIROC ensemble meanの空間相関 ( 赤点線 )                 
      CALL SGLAZU( patnes1, yesm, patnes1, 100.0, 3, 31)                      ! HadCRUT5 ensemble meanとMIROC ensemble meanの空間相関 ( 黄緑点線 ) : MAM                 
      CALL SGLAZU( patnes2, yesm, patnes2, 100.0, 3, 21)                      ! HadCRUT5 ensemble meanとMIROC ensemble meanの空間相関 ( 赤点線 ) : JJA                
      CALL SGLAZU( patnes3, yesm, patnes3, 100.0, 3, 781)                     ! HadCRUT5 ensemble meanとMIROC ensemble meanの空間相関 ( オレンジ点線 ) : SON           
      CALL SGLAZU( patnes4, yesm, patnes4, 100.0, 3, 41)                      ! HadCRUT5 ensemble meanとMIROC ensemble meanの空間相関 ( 青点線 ) : DJF           

!      CALL SGLAZU( xmin, difMIROCestrendav, 100.0, difMIROCestrendav, 3, 41)   ! 領域平均値の差　MIROC ensemble mean- HadCRUT5 ensemble mean ( 青点線 )
      CALL SGLAZU( xmin, difMIROCestrendav1, 100.0, difMIROCestrendav1, 3, 31)  ! 領域平均値の差　MIROC ensemble mean- HadCRUT5 ensemble mean ( 黄緑点線 ) : MAM
      CALL SGLAZU( xmin, difMIROCestrendav2, 100.0, difMIROCestrendav2, 3, 21)  ! 領域平均値の差　MIROC ensemble mean- HadCRUT5 ensemble mean ( 赤点線 ) : JJA
      CALL SGLAZU( xmin, difMIROCestrendav3, 100.0, difMIROCestrendav3, 3, 781) ! 領域平均値の差　MIROC ensemble mean- HadCRUT5 ensemble mean ( オレンジ点線 ) : SON
      CALL SGLAZU( xmin, difMIROCestrendav4, 100.0, difMIROCestrendav4, 3, 41)  ! 領域平均値の差　MIROC ensemble mean- HadCRUT5 ensemble mean ( 青点線 ) : DJF

      CALL GRCLS                                                         ! 出力装置クローズ

  call system('mv dcl_0001.png '//ofile )

END PROGRAM Draw_Scatter_diagram
