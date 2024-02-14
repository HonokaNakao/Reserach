PROGRAM Draw_Bar_graph

! 面積重み付き領域平均値の度数分布表を描画するプログラム
!
! Compile this program with the following way ;
! % dclfrt draw_bar_Hadav_MIROCav.f90 -g && ./a.out
!--------------------------------------------------------------

      IMPLICIT NONE

      REAL, PARAMETER    :: nmin = 0.0                              ! 度数分布表 縦軸の下限
!      REAL, PARAMETER    :: nmax = 40.0                             ! 度数分布表 横軸の上限
      REAL, PARAMETER    :: nmax = 50.0                            ! 度数分布表 横軸の上限
      INTEGER, PARAMETER :: ndata = 50                              ! 領域平均値　データ総数 
      REAL, PARAMETER    :: dmin = 0.0                              ! 領域平均値の下限 
      REAL, PARAMETER    :: dmax = 0.5                              ! 領域平均値の上限 
      REAL               :: HadCRUTestrendav                        ! HadCRUT5 ensemble meanの領域平均値
      REAL               :: MIROCestrendav                          ! MIROC6 ensemble meanの領域平均値
      REAL               :: MIROCtrendav(ndata)                     ! MIROC6 run1~50の領域平均値
      INTEGER :: n

! DCL
      INTEGER, PARAMETER :: map_num = 67                            ! カラーマップ番号
!      INTEGER, PARAMETER :: nd = 11                                ! -0.00005, 0, 0.00005, ... , 0.00045, 0.0005の11本の棒 (NPの場合)
!      INTEGER, PARAMETER :: nd = 21                                ! -0.00005, 0, 0.00005, ... , 0.00095, 0.0001の21本の棒 (N30_90の場合)
      INTEGER, PARAMETER :: nd = 10                                 ! 0.0, 0.05, ... , 0.45, 0.5の10本の棒 (N30_90の場合)
      REAL               :: x(nd)
      REAL               :: y(nd)
      REAL               :: x1(nd)                                  ! 棒の両端の座標値
      REAL               :: x2(nd)                                  ! 棒の両端の座標値
      REAL               :: y1(nd)                                  ! 棒の両端の座標値
      REAL               :: y2(nd)                                  ! 棒の両端の座標値       
      INTEGER, PARAMETER :: itype = 1                               ! 枠のラインタイプ
      INTEGER, PARAMETER :: idx = 1                                 ! 枠のラインインデクス
!      INTEGER, PARAMETER :: itp1 = 10999                           ! トーンパターン番号
!      INTEGER, PARAMETER :: itp2 = 10999                           ! トーンパターン番号
      REAL, PARAMETER    :: rsize = 0.05                            ! 棒の幅
      REAL               :: dt                                      ! メモリ間隔

      REAL               :: yesm = 0.0                              ! ensemble同士の空間相関のy値

!! 入力ファイル名を指定
      CHARACTER ( LEN = 200 ) :: IFILE = 'HadCRUT5_1_200av_trendwgtav_1960_2014_120102_N30_90.txt'     ! input file name (trend : 面積の重み付けあり)
      CHARACTER ( LEN = 200 ) :: IFILE2 = 'MIROC6r1_50av_trendwgtav_1960_2014_120102_N30_90.txt'       ! input file name (trend : 面積の重み付けあり)
      CHARACTER ( LEN = 200 ) :: IFILE3 = 'MIROC6_r1-50_trendwgtav_1960_2014_120102_N30_90.txt'        ! input file name (trend : 面積の重み付けあり)

!! 出力ファイル名を指定
      CHARACTER ( LEN = 200 ) :: OFILE = 'bar_trendwgtav_Hadav-MIROC_120102_N30_90_rg0-0.5'      ! output file name (trend : 面積の重み付けあり)
      CHARACTER( LEN = * ), PARAMETER :: title = "120102"                                         ! 図のタイトル (trend : 面積の重み付けあり)

!---------------------------------------------------------------
!! 面積重み付き領域平均値データの読み込み
! HadCRUT5 アンサンブル平均の領域平均値
      OPEN ( 10, FILE=IFILE, STATUS='OLD' )    ! open input file
      READ( 10, * ) HadCRUTestrendav
      CLOSE ( 10 )

! MIROC アンサンブル平均の領域平均値
      OPEN ( 11, FILE=IFILE2, STATUS='OLD' )    ! open input file
      READ( 11, * ) MIROCestrendav
      CLOSE ( 11 )

! MIROC run1~50の領域平均値
      OPEN ( 12, FILE=IFILE3, STATUS='OLD' )    ! open input file
      READ( 12, * ) MIROCtrendav
      CLOSE ( 12 )

!---------------------------------------------------------------
!! DCLで描画
      CALL swpset('LDUMP', .true.)                  ! true => make dumpfile(xwd)

!  call gllset('lmiss', .true.)                     ! define non available (欠損値を設定)
!  call glrset('rmiss', -999.)                      ! put number as non available (欠損値の値を定義。rmiss=-9999.)

!  call sgscmn(map_num)                             ! color map (カラーマップ番号を指定)

      CALL GROPN(1)                                 ! 出力装置オープン
      CALL GRFRM                                    ! 新たなフレームの準備
      call sglset('LCLIP', .true.)                  ! 図にはみだして描かない

!?                                                  ! GRSWND,GRSVPT,sgstxy,GRSTRN,GRSTRFは1セット
      CALL GRSWND(dmin, dmax, nmin, nmax)           ! set window size (元データの上限、下限と一致させる)
      CALL GRSVPT(0.2, 0.8, 0.2, 0.8)               ! window上のどこに描画するかを指定 (viewpoint)
      CALL GRSTRN(1)                                ! 座標変換 (1:線形)
      CALL GRSTRF                                   ! 正規化変換を確定 set transform

! 座標軸
! x軸
      CALL UXAXDV( 'B', 0.05, 0.1 )                  ! DXAXDV( '場所', 小目盛, 大目盛 )
      CALL UXAXDV( 'T', 0.05, 0.1 )
! y軸
      CALL UYAXDV( 'L', 1.0, 5.0 )
      CALL UYAXDV( 'R', 1.0, 5.0 )
      CALL UYPAXS( 'L', 1 )

!      CALL USDAXS                                   ! x,y軸おまかせ
      CALL UXSTTL( 'B', 'trendwgtav', 0.0 )          ! x軸タイトル
      CALL UYSTTL( 'L', 'quantity', 0.0 )            ! y軸タイトル
      CALL UXMTTL( 'T', title, 0.0 )                 ! 図のタイトル

! 棒グラフ
      dt = ( dmax - dmin ) / nd

! x方向の変数 (棒1本の位置)
      DO n = 1, nd
         x1(n) = dmin + dt*( n - 1. )
         x2(n) = x1(n) + dt
         x(n) = ( x1(n) + x2(n) ) / 2.0
      END DO

! y方向の変数 (度数)
      y1 = 0.0                                       ! 縦軸の下限

      y2(1) = COUNT( MASK = ( MIROCtrendav < dmin+dt ), DIM=1 )

      DO n = 2, nd-1
         y2(n) = COUNT( MASK = ( dmin+dt*(n-1) <= MIROCtrendav .AND. MIROCtrendav < dmin+dt*n ), DIM=1 )
      END DO

      y2(nd) = COUNT( MASK = ( MIROCtrendav >= dmax-dt ), DIM=1 )

      DO n = 1, nd
         y(n) = ( y1(n) + y2(n) ) / 2.0
      END DO

      CALL UVBRF( nd, x, y1, y2 )                   ! 棒グラフ描画

      call ueitlv

! ensemble同士の空間相関を打点
! テキストを描く
!      CALL SGTXZU( patnes, 0.2, '*', 0.035, 0, 0, 14 )

! 線を描く
!      CALL SGLNZU( patnes, yesm, patnes, 100.0, 21 )

! アローを描く
      CALL SGLAZU( HadCRUTestrendav, yesm, HadCRUTestrendav, 100.0, 3, 21 ) ! HadCRUT5 ensemble meanの面積重み付き領域平均値 (赤点線)
      CALL SGLAZU( MIROCestrendav, yesm, MIROCestrendav, 100.0, 3, 41 )     ! MIROC6 ensemble meanの面積重み付き領域平均値 (青点線) 

! 仕上げ
!  CALL SGSTXS(0.03)
!  CALL SGTXR(0.5,0.9,title)                        ! 図タイトルの挿入

      CALL GRCLS                                    ! 出力装置クローズ

  call system('mv dcl_0001.png '//ofile )

END PROGRAM Draw_Bar_graph
