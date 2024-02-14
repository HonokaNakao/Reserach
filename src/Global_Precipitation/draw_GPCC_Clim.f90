!*********************************************************************************
PROGRAM DRAW_GPCC_CLIM
!*********************************************************************************
!
! Compile this program with the following way ;
! % dclfrt draw_normals.f90 -L/usr/lib -lnetcdf -lnetcdff
!
  IMPLICIT NONE
  INCLUDE '/usr/include/netcdf.inc'
!
! Settings to read data in NetCDF files
  CHARACTER( LEN = 30 ) :: ifile = 'normals_1991_2020_v2022_025.nc' ! input file name
!                                   123456789-123456789-123456789-
  INTEGER :: status ! Status indicator when reading data
  INTEGER :: ncid  ! ID for file
  INTEGER :: lonid ! ID for longitude
  INTEGER :: latid ! ID for latitude
  INTEGER :: varid ! ID for variable(precipitation)
!
! Parameters and variables for the data
  INTEGER, PARAMETER :: lon=1440 ! Length of dimension for longitude
  INTEGER, PARAMETER :: lat= 720 ! Length of dimension for latitude
  INTEGER, PARAMETER :: mon=  12 ! Length of dimension for time/month
  REAL*8, DIMENSION( lon           ) :: dlon   ! Grid points for longitude
  REAL*8, DIMENSION(      lat      ) :: dlat   ! Grid points for latitude
  REAL,   DIMENSION( lon, lat, mon ) :: precip ! Monthly precipitation
  REAL :: rmiss ! Missing value
!
! Parameters and variables for drawing
  REAL, DIMENSION( lon ) :: xlon ! Grid points for longitude
  REAL, DIMENSION( lat ) :: ylat ! Grid points for latitude
  INTEGER :: iws
  INTEGER, PARAMETER :: icmn = 16 ! Set colormap
  REAL, PARAMETER :: xmin = -180., xmax = 180., &
                     ymin = - 90., ymax =  90. ! Window
  REAL, PARAMETER :: vxmn =  0.01, vxmx = 0.99, &
                     vymn =  0.01, vymx = 0.71 ! Viewport
  REAL, PARAMETER :: simfac = 0.175, vxoff = 0.0, vyoff = 0.05 ! Scaling factor & offsets
  REAL, PARAMETER :: plx = 150., ply = 90., plrot = 0.0 ! Rotation angle for map projection
  INTEGER, PARAMETER :: itr = 15 ! Set map projection
!
! For title
  CHARACTER( LEN = 9 ) :: cmon( mon ) = (/ 'JANUARY  ', 'FEBRUARY ', &
                              'MARCH    ', 'APRIL    ', 'MAY      ', &
                              'JUNE     ', 'JULY     ', 'AUGUST   ', &
                              'SEPTEMBER', 'OCTOBER  ', 'NOVEMBER ', 'DECEMBER ' /)
  REAL, PARAMETER :: vxt = ( vxmn + vxmx )/2, &
                     vyt = vymx - ( vymx - vymn )*0.05
!
! For colorbar
  INTEGER, PARAMETER :: nmax = 14
  REAL, DIMENSION( 0:nmax ) :: tlev = (/ -999,    1,   10,   25,   50, &
                                           75,  100,  150,  200,  300, &
                                          400,  600,  800, 1000, 9999 /) ! Tone levels
  INTEGER, DIMENSION( nmax ) :: itpat = (/ 20999, 24999, 28999, 32999, &
                                    36999, 40999, 50999, 60999, 70999, &
                                    78999, 82999, 86999, 90999, 99999 /) ! Tone patterns
  REAL, PARAMETER :: vx0 = 0.05, vx1 = 0.95, vy0 = 0.14, vy1 = 0.16
  REAL, PARAMETER :: dvx = ( vx1 - vx0 )/nmax, dvy = vy1 - vy0
  REAL, DIMENSION( 0:4 ) :: vx, vy = (/ vy0, vy1, vy1, vy0, vy0 /)
  REAL :: vxl, vyl
  CHARACTER( LEN = 4 ) :: clev
!
! Loop variables
  INTEGER :: m, n
!
!*********************************************************************************
!
! Open NetCDF file
  status = NF_OPEN( TRIM( ifile ), nf_nowrite, ncid )
  IF ( status .NE. nf_noerr ) CALL HANDLE_ERR( status )
!
! Get data for longitude
  status = NF_INQ_VARID( ncid, 'lon', lonid )
  IF ( status .NE. nf_noerr ) CALL HANDLE_ERR( status )
  status = NF_GET_VAR_DOUBLE( ncid, lonid, dlon )
  IF ( status .NE. nf_noerr ) CALL HANDLE_ERR( status )
!
! Get data for latitude
  status = NF_INQ_VARID( ncid, 'lat', latid )
  IF ( status .NE. nf_noerr ) CALL HANDLE_ERR( status )
  status = NF_GET_VAR_DOUBLE( ncid, latid, dlat )
  IF ( status .NE. nf_noerr ) CALL HANDLE_ERR( status )
!
! Get data for variable & missing value
  status = NF_INQ_varid( ncid, 'precip', varid )
  IF ( status .NE. nf_noerr ) CALL HANDLE_ERR( status )
  status = NF_GET_VAR_REAL( ncid, varid, precip )
  IF ( status .NE. nf_noerr ) CALL HANDLE_ERR( status )
  status = NF_GET_ATT_REAL( ncid, varid, 'missing_value', rmiss )
  IF ( status .NE. nf_noerr ) CALL HANDLE_ERR( status )
!
! Close NetCDF file
  status = NF_CLOSE( ncid )
  IF ( status .NE. nf_noerr ) CALL HANDLE_ERR( status )
!
! ------------------------------------------------------------------------------
!
  xlon(:) = REAL( dlon(:) )
  ylat(:) = REAL( dlat(:) )
!
! Setting for missing value
  CALL GLLSET( 'LMISS', .TRUE. )
  CALL GLRSET( 'RMISS', rmiss )
!
! ------------------------------------------------------------------------------
!
  CALL SGPWSN
  READ(*,*) iws
!
! Set parameters
  CALL GROPN ( iws ) ! Open graphics
  CALL SGSCMN( icmn ) ! Set colormap 
  CALL SGLSET( 'LFULL', .TRUE. ) ! Use full area
  CALL UMLSET( 'LGRIDMJ', .FALSE. ) ! Do not write major lon-lat lines
  CALL UMISET( 'INDEXMN', 81 ) ! Change lon-lat line index
!
  DO m = 1, mon
!
! Prepare new frame
     CALL GRFRM
     CALL GRSWND( xmin, xmax, ymin, ymax ) ! Window
     CALL GRSVPT( vxmn, vxmx, vymn, vymx ) ! Viewport
     CALL GRSSIM( simfac, vxoff, vyoff ) ! Scaling factor & offsets
     CALL GRSMPL( plx, ply, plrot ) ! Rotation angle for map projection
     CALL GRSTXY( xmin, xmax, ymin, ymax )
     CALL GRSTRN( itr ) ! Set transformation number
     CALL GRSTRF ! Fix parameters
!
! Set grid points 
     CALL UWSGXA( xlon, lon ) ! Longitude
     CALL UWSGYA( ylat, lat ) ! Latitude
!
! Set tone levels
     IF ( m .EQ. 1 ) THEN
        DO n = 1, nmax
           CALL UESTLV( tlev(n-1), tlev(n), itpat(n) )
        END DO
     END IF
!
! Tone, coastline, and header
     CALL UETONE( precip(:,:,m), lon, lon, lat )
     CALL UMPMAP( 'coast_world' )
     CALL UMPGLB
     CALL SGTXZV( vxt, vyt, TRIM( cmon(m) )//' from 1991 to 2020', 0.035, 0, 0, 3 )
!
! Colorbar
     DO n = 1, nmax
        IF ( n .EQ. 1 ) THEN
           vx(0) = vx0
           vx(1) = vx0
           vx(2) = vx0 + dvx
           vx(3) = vx0 + dvx
           vx(4) = vx0
        ELSE
           vx(:) = vx(:) + dvx
        END IF
        CALL SGTNZV( 5, vx, vy, itpat(n) )
        CALL SGPLZV( 5, vx, vy, 1, 1 )
        WRITE( clev, '(I4)' ) INT( tlev(n) )
        clev = TRIM( ADJUSTL( clev ) )
        vxl = vx(2)
        vyl = vy0 - dvy
        IF ( n .LT. nmax ) CALL SGTXZV( vxl, vyl, clev, 0.018, 0, 0, 3 )
     END DO
 !
     vxl = vxt
     vyl = vy0 - 3*dvy
     CALL SGTXZV( vxl, vyl, 'Precipitation [mm/month]', 0.028, 0, 0, 3 )
!
  END DO
!
  CALL GRCLS ! close graphics
!
  STOP
END PROGRAM DRAW_GPCC_CLIM
!
!*********************************************************************************
SUBROUTINE HANDLE_ERR( STATUS )
!*********************************************************************************
!
  INTEGER :: status
!
  WRITE(*,*) NF_STRERROR( status )
!
  STOP
END SUBROUTINE HANDLE_ERR
