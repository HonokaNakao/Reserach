#! /bin/bash
#
#
RHST='www.metoffice.gov.uk'
RTOP='/hadobs/hadcrut5/data/current'
LTOP='/home/nakao/HadCRUT5/Data'
#
CWD=${PWD}
#
# For analysis/diagnostics
#
RDIR=${RTOP}/analysis/diagnostics
LDIR=${LTOP}/analysis/diagnostics
#
if [ ! -d ${LDIR} ] ; then 
  mkdir -p ${LDIR}
fi
#
pushd ${LDIR}
#
YMDHMS=`date +'%Y%m%d'_'%H%M%S'`
LOG=${CWD}/wget_anal_diag_${YMDHMS}.log
touch ${LOG}
#
for SRS in summary ensemble component ; do
  for PRD in monthly annual ; do
    for RGN in global northern_hemisphere southern_hemisphere ; do
#
      NCF=HadCRUT.5.0.1.0.analysis.${SRS}_series.${RGN}.${PRD}.nc
      echo -n downloading ${NCF}
      wget -a ${LOG} -c -N --progress=dot https://${RHST}/${RDIR}/${NCF}
      echo ' done.'
#
      CSV=HadCRUT.5.0.1.0.analysis.${SRS}_series.${RGN}.${PRD}.csv
      echo -n downloading ${CSV}
      wget -a ${LOG} -c -N --progress=dot https://${RHST}/${RDIR}/${CSV}
      echo ' done.'
#
    done
  done
done
#
popd
#
# For analysis/gridded
#
RDIR=${RTOP}/analysis
LDIR=${LTOP}/analysis/gridded
#
if [ ! -d ${LDIR} ] ; then 
  mkdir -p ${LDIR}
fi
#
pushd ${LDIR}
#
YMDHMS=`date +'%Y%m%d'_'%H%M%S'`
LOG=${CWD}/wget_anal_grid_${YMDHMS}.log
touch ${LOG}
#
for TYP in anomalies.ensmble_mean weights ; do
#
  NCF=HadCRUT.5.0.1.0.analysis.${TYP}.nc
  echo -n downloading ${NCF}
  wget -a ${LOG} -c -N --progress=dot https://${RHST}/${RDIR}/${NCF}
  echo ' done.'
#
done
#
for nstr in `seq 1 10 191` ; do
#
  nend=$((nstr+9))
  NCF=HadCRUT.5.0.1.0.analysis.anomalies.${nstr}_to_${nend}_netcdf.zip
  echo -n downloading ${NCF}
  wget -a ${LOG} -c -N --progress=dot https://${RHST}/${RDIR}/${NCF}
  echo ' done.'
#
done
#
popd
#
# For non-infilled/diagnostics
#
RDIR=${RTOP}/non-infilled/diagnostics
LDIR=${LTOP}/non-infilled/diagnostics
#
if [ ! -d ${LDIR} ] ; then 
  mkdir -p ${LDIR}
fi
#
pushd ${LDIR}
YMDHMS=`date +'%Y%m%d'_'%H%M%S'`
LOG=${CWD}/wget_ninf_diag_${YMDHMS}.log
touch ${LOG}
#
for SRS in summary ensemble component ; do
  for PRD in monthly annual ; do
    for RGN in global northern_hemisphere southern_hemisphere ; do
#
      NCF=HadCRUT.5.0.1.0.${SRS}_series.${RGN}.${PRD}.nc
      echo -n downloading ${NCF}
      wget -a ${LOG} -c -N --progress=dot https://${RHST}/${RDIR}/${NCF}
      echo ' done.'
#
      CSV=HadCRUT.5.0.1.0.${SRS}_series.${RGN}.${PRD}.csv
      echo -n downloading ${CSV}
      wget -a ${LOG} -c -N --progress=dot https://${RHST}/${RDIR}/${CSV}
      echo ' done.'
#
    done
  done
done
#
popd
#
# For non-infilled/gridded
#
RDIR=${RTOP}/non-infilled
LDIR=${LTOP}/non-infilled/gridded
#
if [ ! -d ${LDIR} ] ; then 
  mkdir -p ${LDIR}
fi
#
pushd ${LDIR}
YMDHMS=`date +'%Y%m%d'_'%H%M%S'`
LOG=${CWD}/wget_ninf_grid_${YMDHMS}.log
touch ${LOG}
#
for TYP in anomalies.ensmble_mean weights ; do
#
  NCF=HadCRUT.5.0.1.0.${TYP}.nc
  echo -n downloading ${NCF}
  wget -a ${LOG} -c -N --progress=dot https://${RHST}/${RDIR}/${NCF}
  echo ' done.'
#
done
#
for nstr in `seq 1 10 191` ; do
#
  nend=$((nstr+9))
  NCF=HadCRUT.5.0.1.0.anomalies.${nstr}_to_${nend}_netcdf.zip
  echo -n downloading ${NCF}
  wget -a ${LOG} -c -N --progress=dot https://${RHST}/${RDIR}/${NCF}
  echo ' done.'
#
done
#
#
#
NCF=HadCRUT.5.0.1.0.uncorrelated.nc
echo -n downloading ${NCF}
wget -a ${LOG} -c -N --progress=dot https://${RHST}/${RDIR}/${NCF}
echo ' done.'
#
for ystr in `seq 1850 10 2020` ; do
#
  yend=$((ystr+9))
  NCF=HadCRUT.5.0.1.0.error_covariance.${ystr}_to_${yend}.zip
  echo -n downloading ${NCF}
  wget -a ${LOG} -c -N --progress=dot https://${RHST}/${RDIR}/${NCF}
  echo ' done.'
#
done
#
popd
#
#
#
exit
