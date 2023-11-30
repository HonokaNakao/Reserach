PROGRAM Draw_Bar_graph

! 空間相関の度数分布表を描画するプログラム
!
! Compile this program with the following way ;
! % dclfrt draw_bar.f90 -g && ./a.out
!--------------------------------------------------------------

      IMPLICIT NONE

      REAL, PARAMETER    :: nmin = 0.0                              ! 度数分布表 縦軸の下限
      REAL, PARAMETER    :: nmax = 40.0                             ! 度数分布表 横軸の上限
!      REAL, PARAMETER    :: nmax = 50.0                            ! 度数分布表 横軸の上限
      INTEGER, PARAMETER :: ndata = 50                              ! 空間相関　データ総数 
      REAL, PARAMETER    :: dmin = -1.0                             ! 空間相関の下限
      REAL, PARAMETER    :: dmax = 1.0                              ! 空間相関の上限
      REAL    :: patn(ndata)                                        ! 空間相関
      INTEGER :: n

! DCL
      INTEGER, PARAMETER :: map_num = 67                            ! カラーマップ番号
      INTEGER, PARAMETER :: nd = 20                                 ! -1.0, -0.9, ... , 0.9, 1,0の20本の棒
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

!! 入力ファイル名を指定
      CHARACTER ( LEN = 200 ) :: IFILE = 'sppattern_Hades-MIROC_120102_N30_90.txt'       ! input file name

!! 出力ファイル名を指定
      CHARACTER ( LEN = 200 ) :: OFILE = 'bar_sppattern_Hades-MIROC_120102_N30_90'        ! output file name
      CHARACTER( LEN = * ), PARAMETER :: title = "sppattern_Hades-MIROC_N30_90 120102"    ! 図のタイトル

!---------------------------------------------------------------
!! 空間相関データの読み込み
      OPEN ( 10, FILE=IFILE, STATUS='OLD' )    ! open input file
      READ(10, '()')
      READ ( 10, * ) patn
      CLOSE ( 10 )

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
!      CALL UXAXDV( 'B', 0.1, 0.5 )
!      CALL UYAXDV( 'L', 10.0, 50.0 )
!      CALL UYPAXS( 'L', 1 )
!      CALL UXAXDV( 'T', 0.1, 0.5 )

      CALL USDAXS                                    ! 軸おまかせ
      CALL UXSTTL( 'B', 'spatial pattern', 0.0 )     ! x軸タイトル
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

      y2(1) = COUNT( MASK = ( patn < -0.9 ), DIM=1 )

!      DO n = 2, 19
!         y2(n) = COUNT( MASK = ( -0.9+0.1*(n-2) <= patn .AND. patn < -0.9+0.1*(n-1) ), DIM=1 )
!      END DO

      y2(2) = COUNT( MASK = ( -0.9 <= patn .AND. patn < -0.8 ), DIM=1 )
      y2(3) = COUNT( MASK = ( -0.8 <= patn .AND. patn < -0.7 ), DIM=1 )
      y2(4) = COUNT( MASK = ( -0.7 <= patn .AND. patn < -0.6 ), DIM=1 )
      y2(5) = COUNT( MASK = ( -0.6 <= patn .AND. patn < -0.5 ), DIM=1 )
      y2(6) = COUNT( MASK = ( -0.5 <= patn .AND. patn < -0.4 ), DIM=1 )
      y2(7) = COUNT( MASK = ( -0.4 <= patn .AND. patn < -0.3 ), DIM=1 )
      y2(8) = COUNT( MASK = ( -0.3 <= patn .AND. patn < -0.2 ), DIM=1 )
      y2(9) = COUNT( MASK = ( -0.2 <= patn .AND. patn < -0.1 ), DIM=1 )
      y2(10) = COUNT( MASK = ( -0.1 <= patn .AND. patn < 0.0 ), DIM=1 )
      y2(11) = COUNT( MASK = ( 0.0 <= patn .AND. patn < 0.1 ), DIM=1 )
      y2(12) = COUNT( MASK = ( 0.1 <= patn .AND. patn < 0.2 ), DIM=1 )
      y2(13) = COUNT( MASK = ( 0.2 <= patn .AND. patn < 0.3 ), DIM=1 )
      y2(14) = COUNT( MASK = ( 0.3 <= patn .AND. patn < 0.4 ), DIM=1 )
      y2(15) = COUNT( MASK = ( 0.4 <= patn .AND. patn < 0.5 ), DIM=1 )
      y2(16) = COUNT( MASK = ( 0.5 <= patn .AND. patn < 0.6 ), DIM=1 )
      y2(17) = COUNT( MASK = ( 0.6 <= patn .AND. patn < 0.7 ), DIM=1 )
      y2(18) = COUNT( MASK = ( 0.7 <= patn .AND. patn < 0.8 ), DIM=1 )
      y2(19) = COUNT( MASK = ( 0.8 <= patn .AND. patn < 0.9 ), DIM=1 )
      y2(20) = COUNT( MASK = ( patn >= 0.9 ), DIM=1 )

      DO n = 1, nd
         y(n) = ( y1(n) + y2(n) ) / 2.0
      END DO

      CALL UVBRF( nd, x, y1, y2 )                   ! 棒グラフ描画

      call ueitlv

! 仕上げ
!  CALL SGSTXS(0.03)
!  CALL SGTXR(0.5,0.9,title)                        ! 図タイトルの挿入

      CALL GRCLS                                    ! 出力装置クローズ

  call system('mv dcl_0001.png '//ofile )

END PROGRAM Draw_Bar_graph
