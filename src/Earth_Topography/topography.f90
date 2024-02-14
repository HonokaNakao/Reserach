PROGRAM TOPOGRAPHY
!
! Compile this program with the following way ;
! 
! % dclfrt topography.f90 -L/usr/lib -lnetcdf -lnetcdff
!
  IMPLICIT NONE
  INCLUDE '/usr/include/netcdf.inc'
!
  CHARACTER ( LEN = * ), PARAMETER :: IFILE = 'etopo01_Ice_1deg.nc' ! input file name
  INTEGER :: NCID, STATUS
!
  INTEGER, PARAMETER :: LON=361, LAT=181 ! Length of dimensions
  INTEGER :: LONID, LATID ! IDs for longitude and latitude
  REAL :: LONS( LON ), LATS( LAT ) ! Grid points for longitude and latitude
!
  CHARACTER ( LEN = * ), PARAMETER :: VAR = 'topo' ! Name of variable
  INTEGER :: TPID ! ID for variable
  REAL :: TOPO( LON, LAT ) ! Data of variable
!
  REAL, PARAMETER :: tlmin = -10600. ! min. of tone level
  REAL, PARAMETER :: tlmax =   7400. ! max. of tone level
  REAL, PARAMETER :: dtlev =    200. ! diff. in tone level
  REAL :: tlev1, tlev2 ! lower and upper tone levels
  INTEGER :: itpat, it ! tone number & loop parameter for tones
  REAL x(4), y(4) ! work arrays for drawing colorbar
!
  INTEGER iws ! workstation No.
!
!---------------------------------------------
!
  STATUS = NF_OPEN( IFILE, NF_NOWRITE, NCID ) ! Open NetCDF file
  IF ( STATUS .NE. NF_NOERR ) CALL HANDLE_ERR( STATUS )
!
  STATUS = NF_INQ_VARID( NCID, 'lon', LONID ) ! Get ID for longitude
  IF ( STATUS .NE. NF_NOERR ) CALL HANDLE_ERR( STATUS )
!
  STATUS = NF_GET_VAR_REAL( NCID, LONID, LONS ) ! Get data for longitude
  IF ( STATUS .NE. NF_NOERR ) CALL HANDLE_ERR( STATUS )
!
  STATUS = NF_INQ_VARID( NCID, 'lat', LATID ) ! Get ID for latitude
  IF ( STATUS .NE. NF_NOERR ) CALL HANDLE_ERR( STATUS )
!
  STATUS = NF_GET_VAR_REAL( NCID, LATID, LATS ) ! Get data for latitude
  IF ( STATUS .NE. NF_NOERR ) CALL HANDLE_ERR( STATUS )
!
  STATUS = NF_INQ_VARID( NCID, VAR, TPID ) ! Get ID for variable
  IF ( STATUS .NE. NF_NOERR ) CALL HANDLE_ERR( STATUS )
!
  STATUS = NF_GET_VAR_REAL( NCID, TPID, TOPO ) ! Get data for variable
  IF ( STATUS .NE. NF_NOERR ) CALL HANDLE_ERR( STATUS )
!
  STATUS = NF_CLOSE( NCID ) ! Close NetCDF file
  IF ( STATUS .NE. NF_NOERR ) CALL HANDLE_ERR( STATUS )
!
! Start graph
!  CALL SWCSET( 'CLRMAP', 'colormap_49.x11' )
!  CALL SGCSMN( 49 )              ! カラーマップの変更
  CALL SWISET( 'IWIDTH', 1000 )
  CALL SWISET( 'IHEIGHT', 800 )
  CALL SGLSET( 'LFULL', .TRUE. ) ! Set to use full area
  CALL UZLSET( 'LABELYR', .TRUE. )
  CALL UZISET( 'IROTLYR', 1 )
  CALL UZISET( 'ICENTYR', 0 )
  CALL UMLSET( 'LGRIDMJ', .FALSE. )

  WRITE(*,*) ' WORKSTATION ID (I)  ? ;'
  CALL SGPWSN
  READ (*,*) iws
  CALL GROPN( iws )
!
! Set tone levels and patterns
  tlev1 = tlmin ; tlev2 = tlmin + dtlev ; itpat = 10999
  CALL UESTLV( tlev1, tlev2, itpat )
  DO it = 2, 89
     tlev1 = tlev2 ; tlev2 = tlev2 + dtlev ; itpat = itpat + 1000
     CALL UESTLV( tlev1, tlev2, itpat )
  END DO
  tlev1 = tlev2 ; tlev2 = tlmax ; itpat = itpat + 1000
  CALL UESTLV( tlev1, tlev2, itpat )
!
  CALL GRFRM
  CALL GRSWND( 0.00, 360., -90.,  90. )
  CALL GRSVPT( 0.01, 0.79, 0.01, 0.79 )
  CALL GRSSIM( 0.4, 0.0, 0.0 )
  CALL GRSMPL( 135., 45.0, 0.0 )
  CALL GRSTXY( -180., 180., 0.0, 90.0 )
  CALL GRSTRN( 30 )
  CALL GRSTRF
!
! Set grid points
  CALL UWSGXA( lons, lon )
  CALL UWSGYA( lats, lat )
!
  CALL UETONE( topo, lon, lon, lat ) ! draw tones
!
  CALL UMPMAP( 'coast_world' ) ! draw coast lines
  CALL UMPMAP( 'border_world' ) ! draw country border lines
  CALL UMPGLB
!
! Start to draw colorbar
  CALL GRFIG
  CALL GRSWND( 0.00, 1.00, tlmin, tlmax )
  CALL GRSVPT( 0.85, 0.89, 0.02, 0.67 )
  CALL GRSTRN( 1 )
  CALL GRSTRF
!  
  DO it = 1, 90
     tlev1 = tlmin + (it-1)*dtlev
     tlev2 = tlmin +  it   *dtlev
     itpat = (it-1)*1000 + 10999
     x(1) =   0.0 ; x(2) =   1.0 ; x(3) =   1.0 ; x(4) =   0.0
     y(1) = tlev1 ; y(2) = tlev1 ; y(3) = tlev2 ; y(4) = tlev2
     CALL SGTNZU( 4, x, y, itpat )
  END DO
  CALL SLPVPR( 3 )
  CALL UYAXDV( 'R', 500.0, 3000.0 )
  CALL UYSTTL( 'R', 'Topography [m]', 0.0 )
!  
  CALL GRCLS
!
END PROGRAM TOPOGRAPHY
!
!---------------------------------------------
!
SUBROUTINE HANDLE_ERR( STATUS )
!
  INTEGER :: STATUS
!
  WRITE( *, * ) NF_STRERROR( STATUS )
  STOP
!
END SUBROUTINE HANDLE_ERR
