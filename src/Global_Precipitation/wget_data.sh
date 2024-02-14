#! /bin/bash
#
#
RHST='opendata.dwd.de'
RDIR='/climate_environment/GPCC/gpcc_normals_v2022'
LDIR='/home/nozawa/GPCC/GPCC_Clim/Data'
#
CWD=${PWD}
#
for RES in 025 05 10 25 ; do
#
  if [ ! -d ${LDIR}/${RES} ] ; then 
      mkdir -p ${LDIR}/${RES}
  fi
#
  YMDHMS=`date +'%Y%m%d'_'%H%M%S'`
  LOG=${CWD}/DL_${RES}_${YMDHMS}.log
#
  pushd ${LDIR}/${RES}
  ystr=1951
  yend=2000
  FNAME='normals_'${ystr}'_'${yend}'_v2022_'${RES}'.nc.gz'
#
  echo -n downloading ${FNAME}
  wget -o ${LOG} -c -N --progress=dot https://${RHST}/${RDIR}/${FNAME}
  echo ' done.'
#
  for ystr in `seq 1931 10 1991` ; do
#
    yend=$((ystr+29))
    FNAME='normals_'${ystr}'_'${yend}'_v2022_'${RES}'.nc.gz'
#
    echo -n downloading ${FNAME}
    wget -a ${LOG} -c -N --progress=dot https://${RHST}/${RDIR}/${FNAME}
    echo ' done.'
#
  done
#  
  popd
#
done
#
#
#
exit
