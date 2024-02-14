PROGRAM Read_Gtool_Change_Header_WGTOOL
!
! gtool形式ファイルをfortranで読み書きするサンプルファイル
! 出力する際に、gtoolのヘッダー情報を変更する(WGTOOL)
!
! Compile this program with the following way ;
!
! % dclfrt -fconvert=big-endian ./read_gtool_wgtool.f90 -L[DIR] -lnetcdff
!
! This is because the GTOOL file should be written in "BIG ENDIAN".
!!
  IMPLICIT NONE ! 暗黙の型宣言を無効化
!
! GTOOL形式データ読み込み用の変数等を宣言
!
! 入力ファイル名を指定                        123456789-123456789-123456789-123456789-123456789-1
  CHARACTER( LEN = 51 ), PARAMETER :: ifnm = 'HadCRUT.5.0.1.0.analysis.anomalies.ensemble_mean.gt'
!
! 配列の要素数を指定
  INTEGER, PARAMETER :: lon  =   72 ! 経度方向の格子数
  INTEGER, PARAMETER :: lat  =   36 ! 緯度方向の格子数
  INTEGER, PARAMETER :: ntim = 2077 ! 時間方向のデータ数 (momth)
  INTEGER, PARAMETER :: hmax = 64   ! ヘッダー情報のデータ数
!
  CHARACTER :: head( hmax )*16 ! ヘッダー情報
  REAL :: tas( lon, lat )      ! 入力ファイルのデータ　変数名
!
  INTEGER :: M      ! 時間ループの制御変数

  REAL*8  :: dmiss  ! 欠損値
!
  INTEGER, PARAMETER :: yref = 1850 ! 時間データの基準年
  INTEGER, PARAMETER :: mref =    1 ! 時間データの基準年
  INTEGER, PARAMETER :: dref =    1 ! 時間データの基準年
!
! 配列を宣言
  REAL*8  :: dlon ( lon  )    ! 経度の格子点データ
  REAL*8  :: dlat ( lat  )    ! 緯度の格子点データ
  REAL*8  :: dtime( ntim )    ! 時間のデータ
  REAL*8  :: dtas ( lon, lat, ntim ) ! 気温偏差の格子点データ
!
! GTOOL形式データ書き込み用の変数等を宣言
!
! 出力ファイル名を指定                        123456789-123456789-123456789-123456789-123456789-
  CHARACTER( LEN = 50 ), PARAMETER :: ofnm = 'HadCRUT.5.0.1.0.analysis.anomalies.ensemble_mean_2'
!
! ヘッダー用の変数を宣言                        123456789-123456789-123456789-12
  CHARACTER( LEN = 16 ), PARAMETER :: hitem  = 'tas_mean        '                 ! 変数名(ITEM)
  CHARACTER( LEN = 32 ), PARAMETER :: htitl  = 'blended LSAT_anom with SST_anom ' ! タイトル
  CHARACTER( LEN = 16 ), PARAMETER :: hunit  = 'K               '                 ! 単位
  CHARACTER( LEN = 16 ), PARAMETER :: hdset  = 'HadCRUT.5.0.1.0 '                 ! データセット名
  CHARACTER( LEN = 16 ), PARAMETER :: htunit = 'HOUR            '                 ! 時刻の単位
  CHARACTER( LEN = 16 ), PARAMETER :: haitm1 = 'GLON72CM        '                 ! 軸１の格子識別情報
  CHARACTER( LEN = 16 ), PARAMETER :: haitm2 = 'GLAT36IM        '                 ! 軸２の格子識別情報
  CHARACTER( LEN = 16 ), PARAMETER :: haitm3 = 'SFC1            '                 ! 軸３の格子識別情報
  CHARACTER( LEN = 16 ), PARAMETER :: huser  = 'nakao           '                 ! 作成者
  INTEGER, DIMENSION(6) :: jdate  ! 年、月、日、時、分、秒
  INTEGER :: itime ! 時刻（通し）
  INTEGER :: itdur ! データ代表時間
  INTEGER :: istyp ! スケーリングタイプ
!
! 配列を宣言
!  REAL    :: tas ( lon, lat ) ! = dtas( :, :, n )
!
! 内部変数
  INTEGER :: status ! NetCDFファイルの処理状態
  INTEGER :: i, j, n ! ループ変数
  REAL, PARAMETER    :: vmiss = -999. ! 欠損値
!
!-------------------------------------------------------------
!
! GTOOL 形式ファイルからデータ読み込み
! GTOOL 形式ファイルに書き込み
!
  OPEN ( 10, file=TRIM( ifnm ), form='unformatted' ) ! 入力ファイルを開く
  OPEN ( 20, file=TRIM( ofnm ), form='unformatted' ) ! 出力ファイルを開く
!
  DO M = 1, ntim
     READ ( 10 ) head ! ヘッダー情報を読む
     READ ( 10 ) tas  ! データを読む
  END DO 

!------------------------------------------------------------
!
! 気温偏差の欠損値をvmiss に変更(NetCDF)
!
!  DO n = 1, ntim
!     DO j = 1, lat
!        DO i = 1, lon
!           IF ( dtas(i,j,n) .EQ. dmiss ) THEN
!              dtas(i,j,n) = DBLE( vmiss )
!           END IF
!        END DO
!     END DO
!  END DO
!
!--------------------------------------------------------------   
!
! GTOOL形式ファイルに書き込み
!
  itdur = 24
  istyp =  1
!
  DO n = 1, ntim
     itime = INT( dtime(n)*24 )
!
     CALL DATEF3( INT( dtime(n) ), yref, mref, dref, jdate(1), jdate(2), jdate(3) )
     IF ( dtime(n) - INT( dtime(n) ) .EQ. 0.D0 ) THEN
        jdate(4) =  0
     ELSE
        jdate(4) = 12
     END IF
     jdate(5) = 0
     jdate(6) = 0
!
!     DO j = 1, lat                              ! 欠損値を与えたgtoolデータ tas(lon,lat)を作成
!        DO i = 1, lon
!           tas(i,j) = REAL( dtas(i,j,n) )
!        END DO
!     END DO
!

     WRITE( 20 ) head ! ヘッダー情報を書く
     WRITE( 20 ) tas  ! データを書く

     CALL WGTOOL &
         ( tas, 20 , &
           hitem , htitl , hunit , hdset , &
           itime , itdur , htunit, jdate , &
           haitm1, haitm2, haitm3, istyp , &
           lon   , lat   , 1     , huser  )
!
  END DO
!
  CLOSE( 20 ) ! 出力ファイルを閉じる
  CLOSE( 10 ) ! 入力ファイルを閉じる
!
!--------------------------------------------------------------   
!
  STOP
!
END PROGRAM Read_Gtool_Change_Header_WGTOOL
!
!--------------------------------------------------------------   
!
SUBROUTINE HANDLE_ERR( status )
  INTEGER :: status
!
  WRITE(*,*) NF_STRERROR( status )
  STOP
!
END SUBROUTINE HANDLE_ERR
!
!***********************************************************************
!* PACKAGE WGTOOL "! GTOOL3
!*
!*"  [HIS] 94/06/04(numaguti)
!***********************************************************************
!
      SUBROUTINE WGTOOL     &                    !" GTOOL3
              ( GDATA , JFILE , &
                HITEM , HTITL , HUNIT , HDSET , &
                ITIME , ITDUR , HTUNIT, JDATE , &
                HAXISX, HAXISY, HAXISZ, istyp , &
                IMAX  , JMAX  , KMAX  , HUSER    )
!*
      INTEGER    IMAX, JMAX, KMAX
!*
      REAL       GDATA ( IMAX, JMAX, KMAX )
      INTEGER    JFILE
      CHARACTER  HITEM  *(*)
      CHARACTER  HTITL  *(*)
      CHARACTER  HUNIT  *(*)
      CHARACTER  HDSET  *(*)
      INTEGER    ITIME
      INTEGER    ITDUR
      CHARACTER  HTUNIT  *(*)
      INTEGER    JDATE ( 6 )
      CHARACTER  HAXISX *(*)
      CHARACTER  HAXISY *(*)
      CHARACTER  HAXISZ *(*)
      integer    istyp                          !" scaling type
      CHARACTER  HUSER *(*)
!*
!*   [INTERNAL WORK]
      INTEGER    I
      CHARACTER  HEAD  ( 64 )*16
      INTEGER    JDATEN( 6 )
      CHARACTER  HTITLZ*32
!*
!*   [INTERNAL SAVE]
      REAL       VMISS
      DATA       VMISS / -999. /
!*
      DO 800 I = 1, 64
         HEAD( I) = ' '
  800 CONTINUE
      WRITE ( HEAD( 1), '(I16)' ) 9010
      HEAD( 2) = HDSET
      HEAD( 3) = HITEM
      WRITE ( HEAD(12), '(I16)' ) 1
      WRITE ( HEAD(13), '(I16)' ) 1
      HTITLZ   = HTITL
      HEAD(14) = HTITLZ(1:16)
      HEAD(15) = HTITLZ(17:32)
      HEAD(16) = HUNIT
      WRITE ( HEAD(25), '(I16)' ) ITIME
      WRITE ( HEAD(28), '(I16)' ) ITDUR
      HEAD(26) = HTUNIT
      WRITE ( HEAD(27), 820 ) (JDATE(I),I=1,6)
  820 FORMAT( I4.4,I2.2,I2.2,' ',I2.2,I2.2,I2.2 )
       HEAD(29) = HAXISX
      WRITE ( HEAD(30), '(I16)' ) 1
      WRITE ( HEAD(31), '(I16)' ) IMAX
      HEAD(32) = HAXISY
      WRITE ( HEAD(33), '(I16)' ) 1
      WRITE ( HEAD(34), '(I16)' ) JMAX
      HEAD(35) = HAXISZ
      WRITE ( HEAD(36), '(I16)' ) 1
      WRITE ( HEAD(37), '(I16)' ) KMAX
      HEAD(38) = 'UR4'
!      DO 830 I = 39, 43
!         WRITE ( HEAD(I), '(E16.7)' ) VMISS
!  830 CONTINUE
      WRITE ( HEAD(39), '(E16.7)' ) VMISS
      WRITE ( HEAD(40), '(E16.7)' ) VMISS
      WRITE ( HEAD(41), '(E16.7)' ) VMISS
      WRITE ( HEAD(42), '(E16.7)' ) VMISS
      WRITE ( HEAD(43), '(E16.7)' ) VMISS

      WRITE ( HEAD(44), '(I16)'   ) istyp
      WRITE ( HEAD(46), '(I16)'   ) 0
      WRITE ( HEAD(47), '(E16.7)' ) 0.
      WRITE ( HEAD(48), '(I16)'   ) 0
      CALL DATEQ3( JDATEN(1), JDATEN(2), JDATEN(3) )
      CALL TIMEQ3( JDATEN(4), JDATEN(5), JDATEN(6) )
      WRITE ( HEAD(60), 820 ) (JDATEN(I),I=1,6)
      WRITE ( HEAD(62), 820 ) (JDATEN(I),I=1,6)
      HEAD(61) = HUSER
      HEAD(63) = HUSER
      WRITE ( HEAD(64), '(I16)' ) IMAX*JMAX*KMAX
!*
      WRITE ( JFILE ) HEAD
      WRITE ( JFILE ) GDATA
!*
      WRITE (6,*) ' *** OUTPUT ', HITEM, ' TIME= ', HEAD(27)
!*
      RETURN
      END
