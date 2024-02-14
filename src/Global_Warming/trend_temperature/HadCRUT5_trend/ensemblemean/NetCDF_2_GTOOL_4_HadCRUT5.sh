#! /bin/bash
#
#
# set ENVIRONMENTAL parameters
export DCLDIR=/usr/local/dcl-5.0.1
export GTOOLDIR=/usr/local/gtool3.5
export GTAXDIR=/usr/local/gtool3.5/lib/gt3
export PATH=${GTOOLDIR}/bin/Linux.pgi:${PATH}
#
# set output file name
export OFNM='HadCRUT.5.0.1.0.analysis.anomalies.ensemble_mean.gt'
#
# delete previous GTOOL file
if [ -e ./${OFNM} ] ; then
    rm ./${OFNM}
fi
#
# compile fortran program
dclfrt -fconvert=big-endian -o NetCDF_2_GTOOL_4_HadCRUT5.out ./NetCDF_2_GTOOL_4_HadCRUT5.f90 -L/usr/lib/x86_64-linux-gnu -lnetcdff
#
# run binary file
./NetCDF_2_GTOOL_4_HadCRUT5.out
#
# make GTAX files
gtset ${GTAXDIR}/GTAXLOC.GLON72C ofs=2.5 item:GLON72CM aitm1:GLON72CM out:GTAXLOC.GLON72CM
gtlocwgt GLON72CM
gtset ${GTAXDIR}/GTAXLOC.GLAT36M fact=-1 item:GLAT36IM aitm1:GLAT36IM out:GTAXLOC.GLAT36IM
gtlocwgt GLAT36IM
#
# check GTOOL file
gtcont ${OFNM} range=-10,10 map=1 clr=T cnt=F pixel=1
#
# delete binary file
rm ./NetCDF_2_GTOOL_4_HadCRUT5.out
#
exit 0
