PROGRAM SAMPLE_4_NETCDF_IO
!
! Compile this program with the following way ;
! 
! % gfortran sample_4_netcdf_io.f90 -L/usr/lib -lnetcdf -lnetcdff
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
  WRITE(*,*) LONS
  WRITE(*,*) LATS
!  WRITE(*,*) TOPO
!
END PROGRAM SAMPLE_4_NETCDF_IO
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
