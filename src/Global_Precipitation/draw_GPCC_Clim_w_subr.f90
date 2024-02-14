!*********************************************************************************
PROGRAM DRAW_GPCC_CLIM_W_SUBR
!*********************************************************************************
!
! Compile this program with the following way ;
! % dclfrt draw_GPCC_Clim_w_subr.f90 -L/usr/lib -lnetcdf -lnetcdff
!
  IMPLICIT NONE
!
! NetCDF file
  CHARACTER( LEN = 30 ) :: ifile = 'normals_1991_2020_v2022_025.nc' ! input file name
!                                   123456789-123456789-123456789-
!
! Parameters and variables for the data
  INTEGER, PARAMETER :: lon=1440 ! Length of dimension for longitude
  INTEGER, PARAMETER :: lat= 720 ! Length of dimension for latitude
  INTEGER, PARAMETER :: mon=  12 ! Length of dimension for time/month
  REAL, DIMENSION( lon           ) :: xlon   ! Grid points for longitude
  REAL, DIMENSION(      lat      ) :: ylat   ! Grid points for latitude
  REAL, DIMENSION( lon, lat, mon ) :: precip ! Monthly precipitation
  REAL :: rmiss ! missing value
!
! For colorbar
  INTEGER, PARAMETER :: nmax = 14
  REAL, DIMENSION( 0:nmax ) :: tlev = (/ -999,    1,   10,   25,   50, &
                                           75,  100,  150,  200,  300, &
                                          400,  600,  800, 1000, 9999 /)
  INTEGER, DIMENSION( nmax ) :: itpat = (/ 20999, 24999, 28999, 32999, &
                                    36999, 40999, 50999, 60999, 70999, &
                                    78999, 82999, 86999, 90999, 99999 /)
!
! For title
  CHARACTER( LEN = 9 ) :: cmon( mon ) = (/ 'JANUARY  ', 'FEBRUARY ', &
                              'MARCH    ', 'APRIL    ', 'MAY      ', &
                              'JUNE     ', 'JULY     ', 'AUGUST   ', &
                              'SEPTEMBER', 'OCTOBER  ', 'NOVEMBER ', 'DECEMBER ' /)
!
!*********************************************************************************
!
! Get data
  CALL READ_NCDATA( TRIM( ifile ), lon, lat, mon, xlon, ylat, precip, rmiss )
!
! Setting for missing value
  CALL GLLSET( 'LMISS', .TRUE. )
  CALL GLRSET( 'RMISS', rmiss )
!
! Draw figure
  CALL DRAW_FIGURE( lon, lat, mon, xlon, ylat, precip, cmon, nmax, tlev, itpat )
!
  STOP
END PROGRAM DRAW_GPCC_CLIM_W_SUBR
!
!*********************************************************************************
SUBROUTINE READ_NCDATA( fnm, lon, lat, mon, xlon, ylat, precip, rmv )
!*********************************************************************************
!
  IMPLICIT NONE
  INCLUDE '/usr/include/netcdf.inc'
!
! Inputs
  CHARACTER( LEN = * ) :: fnm
  INTEGER :: lon, lat, mon ! Dimensions
!
! Outputs
  REAL, DIMENSION( lon           ) :: xlon   ! Longitude
  REAL, DIMENSION(      lat      ) :: ylat   ! Latitude
  REAL, DIMENSION( lon, lat, mon ) :: precip ! Precipitation
  REAL :: rmv ! missing value
!
  INTEGER :: status ! Status indicator when reading data
  INTEGER :: ncid, lonid, latid, varid ! IDs for file, dimensions, and variables
  REAL*8, DIMENSION( lon ) :: dlon ! Longitude in double precision
  REAL*8, DIMENSION( lat ) :: dlat ! Latitude  in double precision
!
!*********************************************************************************
!
! Open NetCDF file
  status = NF_OPEN( fnm, nf_nowrite, ncid )
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
  status = NF_GET_ATT_REAL( ncid, varid, 'missing_value', rmv )
  IF ( status .NE. nf_noerr ) CALL HANDLE_ERR( status )
!
! Close NetCDF file
  status = NF_CLOSE( ncid )
  IF ( status .NE. nf_noerr ) CALL HANDLE_ERR( status )
!
  xlon(:) = REAL( dlon(:) )
  ylat(:) = REAL( dlat(:) )
!
  RETURN
!
END SUBROUTINE READ_NCDATA
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
!
!*********************************************************************************
SUBROUTINE DRAW_FIGURE( lon, lat, mon, xlon, ylat, precip, cmon, nmax, tlev, itpat )
!*********************************************************************************
!
  IMPLICIT NONE
!
! Inputs
  INTEGER :: lon, lat, mon ! Dimensions
  REAL, DIMENSION( lon           ) :: xlon   ! Longitude
  REAL, DIMENSION(      lat      ) :: ylat   ! Latitude
  REAL, DIMENSION( lon, lat, mon ) :: precip ! Precipitation
  CHARACTER( LEN = * ) :: cmon( mon ) ! Name of month for title
  INTEGER :: nmax ! No. of tones
  REAL, DIMENSION( 0:nmax ) :: tlev   ! Tone levels
  INTEGER, DIMENSION( nmax ) :: itpat ! Tone patterns
!
  INTEGER :: iws ! 1:display, 2:PDF
  INTEGER, PARAMETER :: icmn = 16 ! Colormap
  REAL, PARAMETER :: xmin = -180.0, xmax = 180.0, &
                     ymin = - 90.0, ymax =  90.0 ! Window
  REAL, PARAMETER :: vxmn =   0.01, vxmx =  0.99, &
                     vymn =   0.01, vymx =  0.71 ! Viewport
  REAL, PARAMETER :: simfac = 0.175, vxoff = 0.0, vyoff = 0.05 ! Scaling factor & offsets
  REAL, PARAMETER :: plx = 150., ply = 90., plrot = 0.0 ! Rotation angle for map projection
  INTEGER, PARAMETER :: itr = 15 ! Map projection
  REAL, PARAMETER :: vxt = ( vxmn + vxmx )/2, &
                     vyt = vymx - ( vymx - vymn )*0.05 ! Position of title
!
  INTEGER :: m, n
!
!*********************************************************************************
!
  CALL SGPWSN
  READ(*,*) iws
!
! Set parameters
  CALL GROPN ( iws ) ! Open graphics
  CALL SGSCMN( icmn ) ! Set colormap 
  CALL SGLSET( 'LFULL', .TRUE. ) ! Use full area
  CALL UMLSET( 'LGRIDMJ', .FALSE. ) ! Do not write major lon-lat lines
  CALL UMISET( 'INDEXMN', 81 ) ! Change lat-lon line index
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
     CALL COLORBAR( nmax, tlev, itpat )
  END DO
!
  CALL GRCLS ! close graphics
!
  RETURN
!
END SUBROUTINE DRAW_FIGURE
!
!*********************************************************************************
SUBROUTINE COLORBAR( nmax, tlev, itpat )
!*********************************************************************************
!
  IMPLICIT NONE
!
! Inputs
  INTEGER :: nmax ! No. of tones
  REAL, DIMENSION( 0:nmax ) :: tlev   ! Tone levels
  INTEGER, DIMENSION( nmax ) :: itpat ! Tone patterns
!
  REAL, PARAMETER :: vx0 = 0.05, vx1 = 0.95, vy0 = 0.14, vy1 = 0.16
  REAL :: dvx, dvy, vxl, vyl
  REAL, DIMENSION(0:4) :: vx, vy = (/ vy0, vy1, vy1, vy0, vy0 /)
  CHARACTER( LEN = 4 ) :: clev
!
  INTEGER :: n
!
!*********************************************************************************
!
  dvx = ( vx1 - vx0 )/nmax
  dvy =   vy1 - vy0
!
! Draw colorbar
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
     vxl = ( vx0 + vx1 )/2
     vyl = vy0 - 3*dvy
     CALL SGTXZV( vxl, vyl, 'Precipitation [mm/month]', 0.028, 0, 0, 3 )
!
  RETURN
!
END SUBROUTINE COLORBAR
