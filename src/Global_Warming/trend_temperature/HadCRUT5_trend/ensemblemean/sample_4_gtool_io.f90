PROGRAM SAMPLE_4_GTOOL_IO
!
! gtool形式ファイルをfortranで読み書きするサンプルファイル
!
! Compile this program with the following way ;
! 
! % gfortran -fconvert=big_endian sample_4_gtool_io.f90 (野沢先生ver)
! % gfortran -fconvert=big-endian sample_4_gtool_io.f90 (NH ver)
!
!
! This is because the GTOOL file should be written in "BIG ENDIAN".
!
!
  IMPLICIT NONE
!
  INTEGER, PARAMETER :: IMAX=128 ! No. of longitudinal grids
  INTEGER, PARAMETER :: JMAX= 64 ! No. of latitudinal grids
  INTEGER, PARAMETER :: MMAX= 12 ! No. of months
  INTEGER, PARAMETER :: HMAX= 64 ! No. of header informations
!
  CHARACTER :: HEAD( HMAX )*16 ! headers
  REAL :: TEMP( IMAX, JMAX )   ! data
!
  CHARACTER ( LEN = * ) :: IFILE = 'grsst'     ! input file name
  CHARACTER ( LEN = * ) :: OFILE = 'gtool.out' ! output file name
!
  INTEGER :: M
!
!---------------------------------------------
!
  OPEN ( 10, FILE=IFILE, FORM='UNFORMATTED' ) ! open input file
  OPEN ( 20, FILE=OFILE, FORM='UNFORMATTED' ) ! open output file
!
  DO M=1,MMAX
     READ ( 10 ) HEAD ! read headers
     READ ( 10 ) TEMP ! read data
!
     TEMP( : , : ) = TEMP( : , : ) - 273.15 ! convert K -> degC
     HEAD( 16 ) = 'degC' ! change units
!
     WRITE( 20 ) HEAD ! write headers
     WRITE( 20 ) TEMP ! write data
  END DO

  CLOSE( 20 ) ! close output file
  CLOSE( 10 ) ! close input file

END PROGRAM SAMPLE_4_GTOOL_IO
