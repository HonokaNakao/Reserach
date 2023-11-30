PROGRAM cal_sppattern_MIROC_HadCRUT

! MIROC6 ensemblemean & 50例とHadCRUT5 ensemblemean & 200例の空間相関を算出するプログラム
! gfortran -fconvert=big-endian cal_pattern.f90
!----------------------------------------------------------------------------------------------

      IMPLICIT NONE

      INTEGER, PARAMETER :: IMAX= 72           ! No. of longitudinal grids
      INTEGER, PARAMETER :: JMAX= 36           ! No. of latitudinal grids
      INTEGER, PARAMETER :: HMAX= 64           ! No. of header informations
      INTEGER, PARAMETER :: MMAX= 55           ! No. of months (1960-2014年1月55個の月別データ)
      INTEGER, PARAMETER :: KMAX= 2592         ! No. of longitudinal grids(72)*latitudinal grids(36)
      INTEGER, PARAMETER :: ndata = 51        ! MIROCデータ数 : ndata = run(50)+1
      REAL, PARAMETER    :: vmiss = -999.      ! 欠損値
      INTEGER            :: i, j, n, k

      CHARACTER :: HEAD( HMAX )*16             ! headers
      REAL :: trend1( IMAX, JMAX )             ! HadCRUT5 ensemble meanにおけるtrend (1960-2014年の月毎トレンド) :xdata
      REAL :: trendHades( KMAX )               ! HadCRUT5 ensemble meanにおけるtrend (1960-2014年の月毎トレンド)
      REAL :: trend2( IMAX, JMAX, ndata )      ! MIROC6 ensemble mean & run1-50におけるtrend (1960-2014年の月毎トレンド) :ydata
      REAL :: trendMIROC( KMAX, ndata )        ! MIROC6 ensemble mean & run1-50におけるtrend (1960-2014年の月毎トレンド)

      REAL :: numdt                            ! trendの欠損値以外のデータ総数
      REAL :: sumtrendHades
      REAL :: sumtrendMIROC( ndata )
      REAL :: avetrendHades
      REAL :: avetrendMIROC( ndata )
      REAL :: block1( ndata )                  ! Sxy(block1) = xdataとydataの共分散 : HadCRIT5 ensemble mean - MIROC ensemble mean & run1~50
      REAL :: block2( ndata )                  ! 空間相関の分母(sx*sy) : HadCRIT5 ensemble mean - MIROC ensemble mean & run1~50
      REAL :: xx                               ! (xdata)**2の合計
      REAL :: yy( ndata )                      ! (ydata)**2の合計 : MIROC ensemble mean & run1~50
      REAL :: sx                               ! xdataの標準偏差
      REAL :: sy( ndata )                      ! ydataの標準偏差 : MIROC ensemble mean & run1=50
      REAL :: patn( ndata )                    ! HadCRUT5 ensemble meanとMIROC6 ensemble mean, MIROC6 run1~50の空間相関51個

!! 入力ファイル名を指定               123456789-123456789-123456789-123456789-123456789-1
      CHARACTER ( LEN = 200 ) :: IFILE = 'ifnmMIROC_12.txt'
      CHARACTER ( LEN = 200 ) :: IFILEHad ='HadCRUT5_ensm_trend_1960_2014_12_mon'                    ! input file name : HadCRUT5 ensemble data
      CHARACTER ( LEN = 200 ) :: IFILEMIROC( ndata )                                            ! input file name : MIROC ensemble data & MIROC(run1~50)

! 入力ファイルを変数に格納
      OPEN ( 11, FILE=IFILE, STATUS='OLD' )    ! open input file
      READ ( 11, * ) IFILEMIROC
      CLOSE ( 11 )
   
!---------------------------------------------
!! GTOOLデータの読み込み
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
!! dataの1次元化 
!  HadCRUT5 ensemble meanにおける月毎trend
      CALL ch_dim21( IMAX, JMAX, trend1, &                    ! input
                   & trendHades )                             ! output

! MIROC ensemble data & run1-50における月毎trend
      CALL ch_dim32( IMAX, JMAX, ndata, trend2, &             ! input
                    & trendMIROC )                            ! output

!---------------------------------------------
! 欠損値以外のデータ総数
      numdt = COUNT( MASK =( trendHades /= vmiss ), DIM=1 )
       
!---------------------------------------------
! 平均値
      sumtrendHades = SUM( trendHades, DIM=1, MASK = ( trendHades /= vmiss ))
      sumtrendMIROC(:) = SUM( trendMIROC(:,:), DIM=1, MASK = ( trendMIROC(:,:) /= vmiss ))

      avetrendHades = sumtrendHades / numdt
      avetrendMIROC(:) = sumtrendMIROC(:) / numdt

!---------------------------------------------
! 標準偏差 sx, sy
      xx = 0.0
      yy = 0.0

      DO n = 1, ndata
	 block1(n) = 0.0
         DO k = 1, KMAX
            IF( (trendHades(k) .NE. vmiss ) .AND. ( trendMIROC(k,n) .NE. vmiss )) THEN
              block1(n) = block1(n) + trendHades(k)*trendMIROC(k,n)
	      yy(n) = yy(n) + ( trendMIROC(k,n) )**2
            END IF
         END DO
      END DO

      DO k = 1, KMAX
         xx = xx + ( trendHades(k) )**2
      END DO

      sx = SQRT( xx - numdt*(avetrendHades)**2 )
      sy(:) = SQRT( yy(:) - numdt*(avetrendMIROC(:))**2 )
      block2(:) = sx*sy(:)

      DO n = 1, ndata
         IF ( block2(n) .NE. 0 ) THEN
            patn(n) = ( block1(n) - numdt*avetrendHades*avetrendMIROC(n) ) / block2(n)
         ELSE 
            patn(n) = vmiss
         END IF
      END DO
         
!      write(*,*) yy(1), block1(1), block2(1), sx, sy(1), numdt, avetrendHades, xx

!      do k = 1, kmax
!         write(*,*) trendHades(k)
!      end do

!       do i = 1, IMAX
!          write(*,*) trend1(i,1)
!       end do

      DO n = 1, ndata
         WRITE(*,*) patn(n)
      END DO

END PROGRAM cal_sppattern_MIROC_HadCRUT

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
               
