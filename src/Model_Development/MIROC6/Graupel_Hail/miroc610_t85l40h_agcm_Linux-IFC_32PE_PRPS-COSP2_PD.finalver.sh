#!/bin/csh
#
#      MIROC6 SPRINTARS run
#
#setenv RUNNAME   miroc610_t85l40h_agcm_Intel_32PE_PRPS-COSP2_PD_1mon_water_1day_3hour  # Run name
setenv RUNNAME   miroc610_t85l40h_agcm_Intel_32PE_PRPS-COSP2_PD_1mon                   # Run name (2021.11.20 expt18)
setenv VRES1     41                                                                    # layers+1
setenv NMPIA     32                                                                    # # of MPI parallel [Atm]
setenv EXEA      agcm.t85l40hfull_PRPS_grha_expt18_211118-32PE.parallel                # Executable file (2021.11.18)
setenv GCMDIR    ~/miroc6.1.0_PRPS                                                     # ROOT of GCM
setenv SYSTEM    Linux-IFC                                                             # CPU/OS System
setenv DATD      /home/nakao/miroc580_data                                             # Directory for data (2021.07.20)
setenv EMIT      $DATD/SPRINTARS                                                       # Directory for emission
setenv OUTD      /raid_zeus/nakao/transout/transout18/$RUNNAME                         # Directory for output (2021.11.18)
setenv RSTFILEA  $OUTD/RSTA                                                            # Restart File
setenv INITFILEA $DATD/RSTA_SP.t85l40h_PRPS_grha                                       # Initial File (2021.07.20)
#
if (-e $OUTD) then
rm -rf ${OUTD}.bak
mv $OUTD ${OUTD}.bak
endif
mkdir -p $OUTD
cd $OUTD
#
#      parameters
#
############################################################
cat << END_OF_DATA >>! $OUTD/SYSIN
 &nmrun  run='$RUNNAME'                                  &end
 &nmtime start=2000,1,1, dur=1, tunit='MON'              &end
 &nmdelt delt=12.d0, tunit='MIN', safer=0.7d0            &end
 &nmcaln ogrego=t, oideal=f                              &end
 &nmmain stepa=60.d0, stepo=20.d0, stepc=60.d0, tunit='MIN' &end
 &nmosch ieb=3, ileap=26                                 &end
 &nmotsp ntsplt=60                                       &end
 &nmitsp nsplit=30                                       &end

 &nmoain ooaint=t, lonint=1, latint=1                    &end
 &nmscrt iscrtya=0                                       &end

 &nmchck ocheck=t, ockall=f                              &end
 &nmchkl ocheck=t                                        &end

 &nminit class='ALL', file='$INITFILEA', tinit=2302,1,1  &end
 &nmrstr class='ALL', file='$RSTFILEA', tintv=1, tunit='YEAR', overwt=t   &end

# SST and sea ice
 &nmdata item='GRSST',  file='$DATD/hadisst_2000.t85'                     &end
 &nmdata item='GRICE',  file='$DATD/hadice_2000.t85'                      &end

# topography
 &nmdata item='GRZ',    file='$DATD/grz.t85'                              &end
 &nmdata item='GRZSD',  file='$DATD/grzsd.t85'                            &end
# grid indices
 &nmdata item='GRLNDF', file='$DATD/matsiro/grlndf.t85-med'               &end
 &nmdata item='GRIDX',  file='$DATD/matsiro/gridx.t85-med', iclas='LND'   &end
 &nmdata item='GRIDCP', itemd='GRIDX', file='$DATD/matsiro/gridx.t85-med', iclas='LND' &end
 &nmdata item='GRIDX01',file='$DATD/matsiro/gridx01.sage2000.t85'         &end
 &nmdata item='GRIDX02',file='$DATD/matsiro/gridx02.sage2000.t85'         &end
 &nmdata item='GLFRC01',file='$DATD/matsiro/glfrc01.sage2000.t85'         &end
 &nmdata item='GLFRC02',file='$DATD/matsiro/glfrc02.sage2000.t85'         &end
# lake
 &nmdata item='LKFRAC', itemd='LKFRC', file='$DATD/matsiro/lkfrc.t85-med.mod091102' &end
 &nmdata item='LKINI',  itemd='LKDEP', file='$DATD/matsiro/lkdep.t85-med.mod091102' &end
 &nmdata item='LKDEP',  file='$DATD/matsiro/lkdep.t85-med.mod091102'      &end
# other MATSIRO files
 &nmdata item='SLIDX',  file='$DATD/matsiro/slidx.t85-med.mod'            &end
 &nmdata item='GRLAI01',file='$DATD/matsiro/grlai01.t85.y2005.laimin'     &end
 &nmdata item='GRLAI02',file='$DATD/matsiro/grlai02.t85.y2005.laimin'     &end
 &nmdata item='GRALB',  file='$DATD/matsiro/gralb.t85-med.mod'            &end
 &nmdata item='GRALBN', file='$DATD/matsiro/gralbn.t85-med.mod'           &end
 &nmdata item='GRTANS', file='$DATD/matsiro/grtans.t85-med'               &end
 &nmgbnd file='$DATD/LANDPARA.mat4c-ice.g66'                              &end
 &nmsbnd file='$DATD/SOILPARA.mat2.g66'                                   &end
 &nmdata item='RIVWTH', file='$DATD/matsiro/RIVWTH_t85_100127.gt'         &end
 &nmrivr rivmap='$DATD/matsiro/RIVMAP_t85_100127'                         &end

# SPRINTARS
 &nmdata item='GRIDSP', file='$EMIT/gridxsp.sage2000.t85'                 &end
 &nmdata item='LKFRSP', itemd='LKFRC', file='$DATD/matsiro/lkfrc.t85-med.mod091102' &end
 &nmdata item='REGION', file='$EMIT/region.t85'                           &end
 &nmdata item='BBBC',   file='$EMIT/GFED3.1_BC_mean_monthly.t85'          &end
 &nmdata item='BBOC',   file='$EMIT/GFED3.1_OC_mean_monthly.t85'          &end
 &nmdata item='ANTBC',  file='$EMIT/edgar_HTAP_BC_2010_t85'               &end
 &nmdata item='ANTOC',  file='$EMIT/edgar_HTAP_OC_2010_t85'               &end
 &nmdata item='TERPG',  file='$EMIT/terp.t85'                             &end
 &nmdata item='ISOPG',  file='$EMIT/isop.t85'                             &end
 &nmdata item='ANTSO2', file='$EMIT/edgar_HTAP_SO2_2010_t85'              &end
 &nmdata item='BBSO2',  file='$EMIT/GFED3.1_SO2_mean_monthly.t85'         &end
 &nmdata item='ANTSO4', file='$EMIT/SO4_ship_2000.t85'                    &end
 &nmdata item='VOLSO2', file='$EMIT/volso2.t85'                           &end
 &nmdata item='VOLALT', file='$EMIT/volalt.t85'                           &end
 &nmdata item='AIRFEL', file='$EMIT/airfuel_2000.t85l40h'                 &end
 &nmdata item='DAYTIM', file='$EMIT/daytim.t85'                           &end
 &nmdata item='CHLOA',  file='$EMIT/A_CHL_a_9km.t85'                      &end
 &nmdata item='DIFATT', file='$EMIT/A_k490nm_9km.t85'                     &end
# chemistry
 &nmdata item='OHRAD',  file='$EMIT/RCPhist_t85l40-oh-hyb.2000.new'       &end
 &nmdata item='OZONE',  file='$EMIT/RCPhist_t85l40-o3-hyb.2000'           &end
 &nmdata item='H2O2',   file='$EMIT/RCPhist_t85l40-h2o2-hyb.2000'         &end
 &nmdata item='NO3G',   file='$EMIT/no3.t85l40h'                          &end

# solar
 &nmslcn ohist=t                                                          &end
 &nmdata item='SOLCON', file='$DATD/solar-new/TSI.2000mon.T85.gt', xsel=0 &end

# volcano
 &nmdata item='TAUVOL', file='$DATD/volcano/TAUVOL4.2000.t85-extpl', xsel=0 &end

#### ATMOS set up ####

# Aerosols
 &nmaccn naemin=1.D0, clwmin=1.d-10, tnuw=25200.d0, fbchy=1.d-3           &end
 &nmaecl fliqmin=1.d-3, ucmin=1.4d7,1.d1, rcmax=30.d-6,300.d-6            &end

# LSC/cloud microphysics
 &nmmlsc rcfact=0.2d0, oind2=t, oind2_fx=f                                &end
 &nmbery b1=0.05d0, b2=0.12d0, b3=1.0d-13                                 &end
 &nmpdf  varmin=1.d-11                                                    &end
 &nmprps dtmic=60.d0,
         eaut=0.2d0,     eacc=0.6d0,      eauti=0.01d0,
         qminautl=1.d-9, qminauti=1.d-9,
         csiaut=50.d-6,  tsauti=180.d0,
         evpr=1.d0,      bfice=0.05d0,   bfsnow=0.01d0,
         depsubi=1.d0,   subs=1.d0,      dnfsubi=1.d0,
         adrmlti=8.d-6,
         vfctr=1.d0,     vfcti=1.5d0,    vfcts=2.5d0,   vfctg=3.d0, 
         efacrs=1.0d0,   efagg=10.d0,    mur=5.d0,      efricg=1.d0        &end

# Radiation
 &nmradt para='$DATD/PARA.bnd29ch111sp.200615',
         ppmn2o=0.31585d0, ppmch4=1.75100,
         ppmcfc=2.63450d-4,5.37050d-4,2*0.d0,8.25150d-5,1.70550d-5,
                8.67050d-6,0.d0,1.37400d-4,3.00000d-7,0.d0,1.10750d-5,
                1.10400d-5,2*0.d0,4.88482d-8,1.32805d-6,0.d0,1.39650d-5,
                3.05000d-6,0.d0,4.54000d-6,0.d0,9.93700d-5,0.d0,
                2.85000d-6,2*0.d0                                         &end

 &nmco2  ppmco2=368.86d0                                                  &end
 &nmradm oaerof=t, tautbl='$DATD/tautab.bin', invtbl='$DATD/invtau.bin', 
         oisccp=f, ocosp=t, ocospexe=t, ocospref=t, ocospis7=f,
         cospin='$DATD/COSP2/cosp_input_nl_v2.0.idid.txt',
         cospout='$DATD/COSP2/cosp_output_nl_v2.0.20181228.txt', nseed=2  &end 
 &nmrada ovarra=t, oind1=t, oind1_fx=f, kvol=2                            &end
#         cospin='$DATD/COSP2/cosp_input_nl_v2.0.idid.txt',
#         cospout='$DATD/COSP2/cosp_output_nl_v2.0.20181228.txt', nseed=2  &end 

 &nmdcor otpdif=f                                                         &end

# Horizontal diffusion
 &nmhdif ray0=15.d0, ray0ma=0.4d0, order=4, tefold=0.4d0, tunit='DAY', khdtop=2, facte=2.d0 &end

# Gravity wave drag
 &nmgrav alp=1.4d-4, fc2=0.4d0                                            &end

# Cumulus convection
 &nmascm cpres=0.55, wcbmax=1.4d0, oinicb=f                               &end
 &nmasup clmd=0.54d0, pa=0.1d0, tauz=8.d3, precz0=1.d3, preczh=3.5d3, ztref=1.d0 &end
 &nmasmf fmax=1.5d-2, alp0=8.d7, taud=5.d2, zfmax=3.5d3, fmaxp=2.d0       &end
 &nmasmt ftmlt=4.d0, meltau=10.d0                                         &end
 &nmasdn evatau=2.d0, rddmx=0.8d0, rddr=6.d-4                             &end

# Shallow convection
 &nmscnv c0=5.d0, minpdc=40000.d0, qlumax=0.2d-3, eismax=2.d0, kfp=0.6d0  &end

# Turbulence
 &nmvdml famls=500.d0, faz1=1.5d0, faz2=500.d0, alp3=5.d0                 &end
 &nmvdtd octei=f                                                          &end
 &nmvlev3 olmtr=t, dfmmax=2.2d4, dfhmax=2.2d4, dfwmax=2.2d4, dfqmax=2.2d4 &end

# Surface
 &nmsfcl usminm=1.5d0, usminh=1.5d0, usmine=1.5d0                         &end
 &nmice  albice=0.85d0,0.65d0                                             &end
 &nmsnow albsnw=0.95d0,0.85d0,0.8d0,0.65d0,0.0d0,0.0d0,
         talsnw=268.15d0,273.15d0                                         &end

# MATSIRO
 &nmmgnd nitr=20                                                          &end
 &nmmice albice=0.50d0,0.30d0,0.05d0    &end
 &nmmz0  z0msnw=5.d-2                                                     &end
 &nmmblk vamin=2.d0, cform=5.d-7                                          &end
 &nmmsnr snwcrt=120.d0                                                    &end
 &nmsalb tauage=1.d6                                                      &end
 &nmsncv snwcrt=-1.d0                                                     &end
 &nmnflx ndiv=5                                                           &end

#### LAKE set up ####

### mosaic-matsiro-lake ###
 &nmrdistl oredist=f                                                      &end
 &nmlksh  hamax=10.D2, hsmax=10.D2, himax=10.D2, hhmin=10.D2              &end
 &nmlkdmp lkhadmp=2.D0, lkhsdmp=30.D0, lkhidmp=30.D0                      &end
 &nmrinl  rindmp=1.D0, sindmp=1.D0                                        &end
 &nmdsl dz1=1.0d2, ds0=0.1d0,0.2d0,0.3d0,0.4d0                            &end
 &nmdfvlm ahvl0=1.D0,1.D0,1.D0,1.D0,1.D0                                  &end

#############################################################################
# OUTPUT
#############################################################################

 &nmhisd tintv=1, tavrg=1, tunit='MON'                   &end

 &nmhist item='U',        file='u'                       &end
 &nmhist item='V',        file='v'                       &end
 &nmhist item='T',        file='t'                       &end
 &nmhist item='PS',       file='ps'                      &end
 &nmhist item='Q',        file='q'                       &end
 &nmhist item='Z',        file='z'                       &end
 &nmhist item='WS10C',    file='ws10'                    &end
 &nmhist item='RAIN',     file='rneng'                   &end
 &nmhist item='RAINC',    file='rnceng'                  &end
 &nmhist item='RAINL',    file='rnleng'                  &end
 &nmhist item='SNWFLX',   file='sneng'                   &end
 &nmhist item='PRCP',     file='rainf'                   &end
 &nmhist item='PRCPC',    file='raincu'                  &end
 &nmhist item='PRCPL',    file='rainls'                  &end
 &nmhist item='SNFAL',    file='snowf'                   &end
 &nmhist item='SNFALC',   file='snowcu'                  &end
 &nmhist item='SNFALL',   file='snowls'                  &end
 &nmhist item='DHBGTC',   file='dhbgtc'                  &end
 &nmhist item='DWBGTC',   file='dwbgtc'                  &end
 &nmhist item='DUBGTC',   file='dubgtc'                  &end
 &nmhist item='DVBGTC',   file='dvbgtc'                  &end
 &nmhist item='HBGTL',    file='hbgtl'                   &end
 &nmhist item='DHBGTL',   file='dhbgtl'                  &end
 &nmhist item='WBGTL',    file='wbgtl'                   &end
 &nmhist item='DWBGTL',   file='dwbgtl'                  &end
 &nmhist item='GLW',      file='glw'                     &end
 &nmhist item='GLSNW',    file='glsnw'                   &end
 &nmhist item='T2',       file='t2'                      &end
 &nmhist item='RH',       file='rh'                      &end
 &nmhist item='EVAP',     file='evap'                    &end
 &nmhist item='SENS',     file='sens'                    &end
 &nmhist item='DTRADL',   file='dtradl'                  &end
 &nmhist item='DTRADS',   file='dtrads'                  &end
 &nmhist item='OLR',      file='olr'                     &end
 &nmhist item='OSR',      file='osr'                     &end
 &nmhist item='OSRD',     file='osrd'                    &end
 &nmhist item='OSRU',     file='osru'                    &end
 &nmhist item='OLRC',     file='olrc'                    &end
 &nmhist item='OSRC',     file='osrc'                    &end
 &nmhist item='OSRUC',    file='osruc'                   &end
 &nmhist item='SLR',      file='slr'                     &end
 &nmhist item='SSR',      file='ssr'                     &end
 &nmhist item='SLRD',     file='slrd'                    &end
 &nmhist item='SSRD',     file='ssrd'                    &end
 &nmhist item='SLRU',     file='slru'                    &end
 &nmhist item='SSRU',     file='ssru'                    &end
 &nmhist item='SLRC',     file='slrc'                    &end
 &nmhist item='SSRC',     file='ssrc'                    &end
 &nmhist item='SLRDC',    file='slrdc'                   &end
 &nmhist item='SSRDC',    file='ssrdc'                   &end
 &nmhist item='FAERL',    file='arfl_toa', zsel=$VRES1   &end
 &nmhist item='FAERL',    file='arfl_sfc', zsel=1        &end
 &nmhist item='FAERS',    file='arfs_toa', zsel=$VRES1   &end
 &nmhist item='FAERS',    file='arfs_sfc', zsel=1        &end
 &nmhist item='FAETL',    file='arftl'                   &end
 &nmhist item='FAETS',    file='arfts'                   &end
 &nmhist item='FAECL',    file='arflc_toa', zsel=$VRES1  &end
 &nmhist item='FAECL',    file='arflc_sfc', zsel=1       &end
 &nmhist item='FAECS',    file='arfsc_toa', zsel=$VRES1  &end
 &nmhist item='FAECS',    file='arfsc_sfc', zsel=1       &end
 &nmhist item='FATCL',    file='arftlc'                  &end
 &nmhist item='FATCS',    file='arftsc'                  &end
 &nmhist item='IAERL',    file='crfl_toa', zsel=$VRES1   &end
 &nmhist item='IAERL',    file='crfl_sfc', zsel=1        &end
 &nmhist item='IAERS',    file='crfs_toa', zsel=$VRES1   &end
 &nmhist item='IAERS',    file='crfs_sfc', zsel=1        &end
 &nmhist item='IAETL',    file='crftl'                   &end
 &nmhist item='IAETS',    file='crfts'                   &end
 &nmhist item='EFDU',     file='emitfdu'                 &end
 &nmhist item='EFSA',     file='emitfsa'                 &end
 &nmhist item='EFOC',     file='emitfoc'                 &end
 &nmhist item='EFBC',     file='emitfbc'                 &end
 &nmhist item='SO2FLX',   file='emitfso2'                &end
 &nmhist item='DMSFLX',   file='emitfdms'                &end
 &nmhist item='TAUT',     file='taut'                    &end
 &nmhist item='TAUDU',    file='taudu'                   &end
 &nmhist item='TAUCA',    file='tauca'                   &end
 &nmhist item='TAUSU',    file='tausu'                   &end
 &nmhist item='TAUNN',    file='tausa'                   &end
 &nmhist item='TAUTC',    file='tautc'                   &end
 &nmhist item='TAUDUC',   file='tauduc'                  &end
 &nmhist item='TAUCAC',   file='taucac'                  &end
 &nmhist item='TAUSUC',   file='tausuc'                  &end
 &nmhist item='TAUNNC',   file='tausac'                  &end
 &nmhist item='TAUOC',    file='tauom'                   &end
 &nmhist item='TAUBC',    file='taubc'                   &end
 &nmhist item='TAUOCC',   file='tauomc'                  &end
 &nmhist item='TAUBCC',   file='taubcc'                  &end
 &nmhist item='TAUTA',    file='tauta'                   &end
 &nmhist item='TAUTF',    file='tautf'                   &end
 &nmhist item='TAUT2',    file='taut2'                   &end
 &nmhist item='TAUT3',    file='taut3'                   &end
 &nmhist item='ALFA',     file='alfa'                    &end
 &nmhist item='ALFAC',    file='alfac'                   &end
 &nmhist item='SSA',      file='ssa'                     &end
 &nmhist item='SSAC',     file='ssac'                    &end
 &nmhist item='EXTT1',    file='cextt'                   &end
 &nmhist item='ABST1',    file='cabst'                   &end
 &nmhist item='BAKT1',    file='cbakt'                   &end
 &nmhist item='EXTDU1',   file='cextdu'                  &end
 &nmhist item='EXTCA1',   file='cextca'                  &end
 &nmhist item='EXTSU1',   file='cextsu'                  &end
 &nmhist item='EXTNN1',   file='cextsa'                  &end
 &nmhist item='NMCDT',    file='numdu'                   &end
 &nmhist item='NMCC1',    file='numca'                   &end
 &nmhist item='NMCC2',    file='numsoa'                  &end
 &nmhist item='NMCC3',    file='numebc'                  &end
 &nmhist item='NMCST',    file='numsu'                   &end
 &nmhist item='NMCNT',    file='numsa'                   &end
 &nmhist item='CONDT',    file='condu'                   &end
 &nmhist item='CONBT',    file='conbc'                   &end
 &nmhist item='CONOT',    file='conom'                   &end
 &nmhist item='CONS1',    file='consu'                   &end
 &nmhist item='CONNT',    file='consa'                   &end
 &nmhist item='PM25',     file='pm25'                    &end
 &nmhist item='COLDT',    file='coldu'                   &end
 &nmhist item='COLBT',    file='colbc'                   &end
 &nmhist item='COLOT',    file='colom'                   &end
 &nmhist item='COLS1',    file='colsu'                   &end
 &nmhist item='COLNT',    file='colsa'                   &end
 &nmhist item='SPPT2',    file='pptso2'                  &end
 &nmhist item='SPPT3',    file='pptdms'                  &end
 &nmhist item='WEFTDU',   file='dwetdu'                  &end
 &nmhist item='DRFTDU',   file='ddrydu'                  &end
 &nmhist item='GRFTDU',   file='dgrvdu'                  &end
 &nmhist item='WEFTOC',   file='dwetom'                  &end
 &nmhist item='DRFTOC',   file='ddryom'                  &end
 &nmhist item='GRFTOC',   file='dgrvom'                  &end
 &nmhist item='WEFTBC',   file='dwetbc'                  &end
 &nmhist item='DRFTBC',   file='ddrybc'                  &end
 &nmhist item='GRFTBC',   file='dgrvbc'                  &end
 &nmhist item='WEFTSU',   file='dwetsu'                  &end
 &nmhist item='DRFTSU',   file='ddrysu'                  &end
 &nmhist item='GRFTSU',   file='dgrvsu'                  &end
 &nmhist item='WEFTSA',   file='dwetsa'                  &end
 &nmhist item='DRFTSA',   file='ddrysa'                  &end
 &nmhist item='GRFTSA',   file='dgrvsa'                  &end
 &nmhist item='WEFSO2',   file='dwetso2'                 &end
 &nmhist item='DRFSO2',   file='ddryso2'                 &end
 &nmhist item='DRFDMS',   file='ddrydms'                 &end
 &nmhist item='CFSO2',    file='dcheso2'                 &end
 &nmhist item='CFSO2W',   file='dchwso2'                 &end
 &nmhist item='CCOVER',   file='ccover'                  &end
 &nmhist item='CCOVERM',  file='ccoverm'                 &end
 &nmhist item='CCOVERMR', file='ccovermr'                &end
 &nmhist item='HCOVERMR', file='hcovermr'                &end
 &nmhist item='MCOVERMR', file='mcovermr'                &end
 &nmhist item='LCOVERMR', file='lcovermr'                &end
 &nmhist item='TCLDF',    file='tcldf'                   &end
 &nmhist item='CLDFRC',   file='cldfrc'                  &end
 &nmhist item='CUMFRC',   file='cumfrc'                  &end
 &nmhist item='QCOL',     file='qcol'                    &end
 &nmhist item='CUMCWP',   file='cumwp'                   &end
 &nmhist item='CUMCIP',   file='cumip'                   &end
 &nmhist item='CLDWP',    file='cldwp'                   &end
 &nmhist item='CLDIP',    file='cldip'                   &end
 &nmhist item='QCON',     file='qcon'                    &end
 &nmhist item='CUMCWC',   file='cumwc'                   &end
 &nmhist item='CUMCIC',   file='cumic'                   &end
 &nmhist item='CLDCWC',   file='cldwc'                   &end
 &nmhist item='CLDCIC',   file='cldic'                   &end
 &nmhist item='CMPCTR',   file='cmpctr'                  &end
 &nmhist item='CMPCTU',   file='cmpctu'                  &end
 &nmhist item='CMPCLR',   file='cmpclr'                  &end
 &nmhist item='CMPCLU',   file='cmpclu'                  &end
 &nmhist item='IMPCTR',   file='impctr'                  &end
 &nmhist item='IMPCTU',   file='impctu'                  &end
 &nmhist item='IMPCLR',   file='impclr'                  &end
 &nmhist item='IMPCLU',   file='impclu'                  &end
 &nmhist item='TAUCWL',   file='taucwl'                  &end
 &nmhist item='TAUCIL',   file='taucil'                  &end
 &nmhist item='TAUCWC',   file='taucwc'                  &end
 &nmhist item='TAUCIC',   file='taucic'                  &end
 &nmhist item='PCTOP',    file='pctop'                   &end
 &nmhist item='TCTOP',    file='tctop'                   &end
 &nmhist item='PCTOPW',   file='pctopw'                  &end
 &nmhist item='TCTOPW',   file='tctopw'                  &end
 &nmhist item='PCTOPI',   file='pctopi'                  &end
 &nmhist item='TCTOPI',   file='tctopi'                  &end
 &nmhist item='OMGCCN',   file='omgccn'                  &end
 &nmhist item='FPRCL',    file='gprec'                                        &end
 &nmhist item='FRANL',    file='gprecl'                                       &end
 &nmhist item='FSNWL',    file='gprecs'                                       &end
 &nmhist item='FRANLF',   file='gplint'                                       &end
 &nmhist item='FSNWLF',   file='gpsint'                                       &end
 &nmhist item='EVLSC',    file='evlsc'                                        &end
 &nmhist item='FLIQL',    file='fliql'                                        &end
 &nmhist item='FLIQAR',   file='fliqar'                                       &end
 &nmhist item='QLIQC',    file='qliqc'                                        &end
 &nmhist item='QICEC',    file='qicec'                                        &end
 &nmhist item='QLIQL',    file='qliql'                                        &end
 &nmhist item='QICEL',    file='qicel'                                        &end
 &nmhist item='CFRCOUT',  file='cfrcout'                                      &end
 &nmhist item='IFRCOUT',  file='ifrcout'                                      &end
 &nmhist item='PREFRC',   file='prefrc'                                       &end
 &nmhist item='SNWFRC',   file='snwfrc'                                       &end
 &nmhist item='GRPFRC',   file='grpfrc'                                       &end
 &nmhist item='RFLUX',    file='rflux'                                        &end
 &nmhist item='SFLUX',    file='sflux'                                        &end
 &nmhist item='RRSFC',    file='rrsfc'                                        &end
 &nmhist item='RRCB',     file='rrcb'                                         &end
 &nmhist item='REFFC',    file='reffc'                                        &end
 &nmhist item='REFFI',    file='reffi'                                        &end
 &nmhist item='REFFR',    file='reffr'                                        &end
 &nmhist item='REFFS',    file='reffs'                                        &end
 &nmhist item='REFFG',    file='reffg'                                        &end
 &nmhist item='RPPCL1',   file='rppcl1'                                       &end
 &nmhist item='RPPCL2',   file='rppcl2'                                       &end
 &nmhist item='VQR',      file='vqr'                                          &end
 &nmhist item='VQI',      file='vqi'                                          &end
 &nmhist item='VQS',      file='vqs'                                          &end
 &nmhist item='VQG',      file='vqg'                                          &end
 &nmhist item='VNR',      file='vnr'                                          &end
 &nmhist item='VNI',      file='vni'                                          &end
 &nmhist item='VNS',      file='vns'                                          &end
 &nmhist item='VNG',      file='vng'                                          &end
 &nmhist item='LTS',      file='lts'                                          &end
 &nmhist item='WVM',      file='wvm'                                          &end
 &nmhist item='CLWP',     file='clwp'                                         &end
 &nmhist item='CIWP',     file='ciwp'                                         &end
 &nmhist item='LWPL',     file='lwpl'                                         &end
 &nmhist item='IWPL',     file='iwpl'                                         &end
 &nmhist item='DWP',      file='dwp'                                          &end
 &nmhist item='RWP',      file='rwp'                                          &end
 &nmhist item='RWPCL',    file='rwpcl'                                        &end
 &nmhist item='RWPBC',    file='rwpbc'                                        &end
 &nmhist item='SWP',      file='swp'                                          &end
 &nmhist item='GWP',      file='gwp'                                          &end
 &nmhist item='COLNC',    file='colnc'                                        &end
 &nmhist item='COLNI',    file='colni'                                        &end
 &nmhist item='COLNR',    file='colnr'                                        &end
 &nmhist item='COLNS',    file='colns'                                        &end
 &nmhist item='COLNG',    file='colng'                                        &end
 &nmhist item='ACVS',     file='acvs'                                         &end
 &nmhist item='ACCS',     file='accs'                                         &end
 &nmhist item='ACAUS',    file='acaus'                                        &end
 &nmhist item='QTDCNEV',  file='qtdcnev'                                      &end
 &nmhist item='QTDHOMF',  file='qtdhomf'                                      &end
 &nmhist item='QTDHETF',  file='qtdhetf'                                      &end
 &nmhist item='QTDMLTS',  file='qtdmlts'                                      &end
 &nmhist item='QTDFRZRI', file='qtdfrzri'                                     &end
 &nmhist item='QTDFRZRS', file='qtdfrzrs'                                     &end
 &nmhist item='QTDAUTL',  file='qtdautl'                                      &end
 &nmhist item='QTDACCR',  file='qtdaccr'                                      &end
 &nmhist item='QTDHALM',  file='qtdhalm'                                      &end
 &nmhist item='QTDACCS',  file='qtdaccs'                                      &end
 &nmhist item='QTDBEGI',  file='qtdbegi'                                      &end
 &nmhist item='QTDBEGS',  file='qtdbegs'                                      &end
 &nmhist item='QTDEVPR',  file='qtdevpr'                                      &end
 &nmhist item='QTDACAU',  file='qtdacau'                                      &end
 &nmhist item='QTDDEPI',  file='qtddepi'                                      &end
 &nmhist item='QTDSUBI',  file='qtdsubi'                                      &end
 &nmhist item='QTDAUTI',  file='qtdauti'                                      &end
 &nmhist item='QTDACIS',  file='qtdacis'                                      &end
 &nmhist item='QTDACRS',  file='qtdacrs'                                      &end
 &nmhist item='QTDSUBS',  file='qtdsubs'                                      &end
 &nmhist item='QTDSEDR',  file='qtdsedr'                                      &end
 &nmhist item='QTDSEDS',  file='qtdseds'                                      &end
 &nmhist item='QTDSEDI',  file='qtdsedi'                                      &end
 &nmhist item='QTDMLTI',  file='qtdmlti'                                      &end
 &nmhist item='QTDSEDG',  file='qtdsedg'                                      &end
 &nmhist item='QTDSUBG',  file='qtdsubg'                                      &end
 &nmhist item='QTDDEPG',  file='qtddepg'                                      &end
 &nmhist item='QTDBEGG',  file='qtdbegg'                                      &end
 &nmhist item='QTDPSACR', file='qtdpsacr'                                     &end
 &nmhist item='QTDMLTG',  file='qtdmltg'                                      &end
 &nmhist item='QTDFRZRG', file='qtdfrzrg'                                     &end
 &nmhist item='QTDPSACWG', file='qtdpsacwg'                                   &end
 &nmhist item='NTDHOMFC', file='ntdhomfc'                                     &end
 &nmhist item='NTDHOMFI', file='ntdhomfi'                                     &end
 &nmhist item='NTDHETF',  file='ntdhetf'                                      &end
 &nmhist item='NTDMLTS',  file='ntdmlts'                                      &end
 &nmhist item='NTDFRZRI', file='ntdfrzri'                                     &end
 &nmhist item='NTDFRZRS', file='ntdfrzrs'                                     &end
 &nmhist item='NTDEVPR',  file='ntdevpr'                                      &end
 &nmhist item='NTDAUTR',  file='ntdautr'                                      &end
 &nmhist item='NTDAUTC',  file='ntdautc'                                      &end
 &nmhist item='NTDACCR',  file='ntdaccr'                                      &end
 &nmhist item='NTDSCLR',  file='ntdsclr'                                      &end
 &nmhist item='NTDSUBI',  file='ntdsubi'                                      &end
 &nmhist item='NTDAUTI',  file='ntdauti'                                      &end
 &nmhist item='NTDACCS',  file='ntdaccs'                                      &end
 &nmhist item='NTDHALM',  file='ntdhalm'                                      &end
 &nmhist item='NTDACIS',  file='ntdacis'                                      &end
 &nmhist item='NTDACRS',  file='ntdacrs'                                      &end
 &nmhist item='NTDSAGS',  file='ntdsags'                                      &end
 &nmhist item='NTDSEDR',  file='ntdsedr'                                      &end
 &nmhist item='NTDSEDS',  file='ntdseds'                                      &end
 &nmhist item='NTDSEDI',  file='ntdsedi'                                      &end
 &nmhist item='NTDMLTIC', file='ntdmltic'                                     &end
 &nmhist item='NTDMLTI',  file='ntdmlti'                                      &end
 &nmhist item='NTDSEDG',  file='ntdsedg'                                      &end
 &nmhist item='NTDSUBG',  file='ntdsubg'                                      &end
 &nmhist item='NTDPSACRG', file='ntdpsacrg'                                   &end
 &nmhist item='NTDMLTG',  file='ntdmltg'                                      &end
 &nmhist item='NTDFRZRG', file='ntdfrzrg'                                     &end
 &nmhist item='NTDPSACWG', file='ntdpsacwg'                                   &end
 &nmhist item='CICTD1',   file='cictd1'                                       &end
 &nmhist item='CICTD2',   file='cictd2'                                       &end
 &nmhist item='CICTD3',   file='cictd3'                                       &end
 &nmhist item='CICTD4',   file='cictd4'                                       &end
 &nmhist item='CICTD5',   file='cictd5'                                       &end
 &nmhist item='ESWAGG',   file='eswagg'                                       &end
 &nmhist item='FRANLF',   file='gplint'                                       &end
 &nmhist item='FSNWLF',   file='gpsint'                                       &end
 &nmhist item='PRLSC',    file='prcp'                                         &end
 &nmhist item='QCTEND',   file='qctend'                                       &end
 &nmhist item='QITEND',   file='qitend'                                       &end
 &nmhist item='QRTEND',   file='qrtend'                                       &end
 &nmhist item='QSTEND',   file='qstend'                                       &end
 &nmhist item='NCTEND',   file='nctend'                                       &end
 &nmhist item='NITEND',   file='nitend'                                       &end
 &nmhist item='NRTEND',   file='nrtend'                                       &end
 &nmhist item='NSTEND',   file='nstend'                                       &end
 &nmhist item='LHTEND',   file='lhtend'                                       &end
 &nmhist item='GDTXOUT',  file='gdtxout', pout=t  &end
 &nmhist item='GDQVOUT',  file='gdqvout', pout=t  &end
 &nmhist item='GDQCOUT',  file='gdqcout', pout=t  &end
 &nmhist item='GDNCOUT',  file='gdncout', pout=t  &end
 &nmhist item='GDQIOUT',  file='gdqiout', pout=t  &end
 &nmhist item='GDNIOUT',  file='gdniout', pout=t  &end
 &nmhist item='GDQROUT',  file='gdqrout', pout=t  &end
 &nmhist item='GDNROUT',  file='gdnrout', pout=t  &end
 &nmhist item='GDQSOUT',  file='gdqsout', pout=t  &end
 &nmhist item='GDNSOUT',  file='gdnsout', pout=t  &end
 &nmhist item='GDQGOUT',  file='gdqgout', pout=t  &end
 &nmhist item='GDNGOUT',  file='gdngout', pout=t  &end
 &nmhist item='GDQCOUT',  file='gdqcout_1day',  tintv=1, tavrg=1, tunit='DAY' &end
 &nmhist item='GDNCOUT',  file='gdncout_1day',  tintv=1, tavrg=1, tunit='DAY' &end
 &nmhist item='GDQIOUT',  file='gdqiout_1day',  tintv=1, tavrg=1, tunit='DAY' &end
 &nmhist item='GDNIOUT',  file='gdniout_1day',  tintv=1, tavrg=1, tunit='DAY' &end
 &nmhist item='GDQROUT',  file='gdqrout_1day',  tintv=1, tavrg=1, tunit='DAY' &end
 &nmhist item='GDNROUT',  file='gdnrout_1day',  tintv=1, tavrg=1, tunit='DAY' &end
 &nmhist item='GDQSOUT',  file='gdqsout_1day',  tintv=1, tavrg=1, tunit='DAY' &end
 &nmhist item='GDNSOUT',  file='gdnsout_1day',  tintv=1, tavrg=1, tunit='DAY' &end
 &nmhist item='GDQGOUT',  file='gdqgout_1day',  tintv=1, tavrg=1, tunit='DAY' &end
 &nmhist item='GDNGOUT',  file='gdngout_1day',  tintv=1, tavrg=1, tunit='DAY' &end
 &nmhist item='GDQCOUT',  file='gdqcout_3hr',  tintv=3, tavrg=0, tunit='HOUR' &end
 &nmhist item='GDNCOUT',  file='gdncout_3hr',  tintv=3, tavrg=0, tunit='HOUR' &end
 &nmhist item='GDQIOUT',  file='gdqiout_3hr',  tintv=3, tavrg=0, tunit='HOUR' &end
 &nmhist item='GDNIOUT',  file='gdniout_3hr',  tintv=3, tavrg=0, tunit='HOUR' &end
 &nmhist item='GDQROUT',  file='gdqrout_3hr',  tintv=3, tavrg=0, tunit='HOUR' &end
 &nmhist item='GDNROUT',  file='gdnrout_3hr',  tintv=3, tavrg=0, tunit='HOUR' &end
 &nmhist item='GDQSOUT',  file='gdqsout_3hr',  tintv=3, tavrg=0, tunit='HOUR' &end
 &nmhist item='GDNSOUT',  file='gdnsout_3hr',  tintv=3, tavrg=0, tunit='HOUR' &end
 &nmhist item='GDQGOUT',  file='gdqgout_3hr',  tintv=3, tavrg=0, tunit='HOUR' &end
 &nmhist item='GDNGOUT',  file='gdngout_3hr',  tintv=3, tavrg=0, tunit='HOUR' &end
 &nmhist item='REFFC',    file='reffc_1hr' ,   tintv=1, tavrg=0, tunit='HOUR' &end
 &nmhist item='REFFI',    file='reffi_1hr' ,   tintv=1, tavrg=0, tunit='HOUR' &end
 &nmhist item='REFFR',    file='reffr_1hr' ,   tintv=1, tavrg=0, tunit='HOUR' &end
 &nmhist item='REFFS',    file='reffs_1hr' ,   tintv=1, tavrg=0, tunit='HOUR' &end
 &nmhist item='REFFG',    file='reffg_1hr' ,   tintv=1, tavrg=0, tunit='HOUR' &end
 &nmhist item='QTDSEDG',  file='qtdsedg_1hr',  tintv=1, tavrg=0, tunit='HOUR' &end
 &nmhist item='QTDSUBG',  file='qtdsubg_1hr',  tintv=1, tavrg=0, tunit='HOUR' &end
 &nmhist item='QTDDEPG',  file='qtddepg_1hr',  tintv=1, tavrg=0, tunit='HOUR' &end
 &nmhist item='QTDBEGG',  file='qtdbegg_1hr',  tintv=1, tavrg=0, tunit='HOUR' &end
 &nmhist item='QTDPSACR', file='qtdpsacr_1hr', tintv=1, tavrg=0, tunit='HOUR' &end
 &nmhist item='QTDMLTG',  file='qtdmltg_1hr',  tintv=1, tavrg=0, tunit='HOUR' &end
 &nmhist item='QTDFRZRG', file='qtdfrzrg_1hr', tintv=1, tavrg=0, tunit='HOUR' &end
 &nmhist item='QTDPSACWG', file='qtdpsacwg_1hr',tintv=1,tavrg=0, tunit='HOUR' &end
 &nmhist item='NTDSEDG',  file='ntdsedg_1hr',  tintv=1, tavrg=0, tunit='HOUR' &end
 &nmhist item='NTDSUBG',  file='ntdsubg_1hr',  tintv=1, tavrg=0, tunit='HOUR' &end
 &nmhist item='NTDPSACRG', file='ntdpsacrg_1hr',tintv=1,tavrg=0, tunit='HOUR' &end
 &nmhist item='NTDMLTG',  file='ntdmltg_1hr',  tintv=1, tavrg=0, tunit='HOUR' &end
 &nmhist item='NTDFRZRG', file='ntdfrzrg_1hr', tintv=1, tavrg=0, tunit='HOUR' &end
 &nmhist item='NTDPSACWG', file='ntdpsacwg_1hr',tintv=1,tavrg=0, tunit='HOUR' &end
 &nmhist item='VQR',      file='vqr_1hr',      tintv=1, tavrg=0, tunit='HOUR' &end
 &nmhist item='VQI',      file='vqi_1hr',      tintv=1, tavrg=0, tunit='HOUR' &end
 &nmhist item='VQS',      file='vqs_1hr',      tintv=1, tavrg=0, tunit='HOUR' &end
 &nmhist item='VQG',      file='vqg_1hr',      tintv=1, tavrg=0, tunit='HOUR' &end
 &nmhist item='VNR',      file='vnr_1hr',      tintv=1, tavrg=0, tunit='HOUR' &end
 &nmhist item='VNI',      file='vni_1hr',      tintv=1, tavrg=0, tunit='HOUR' &end
 &nmhist item='VNS',      file='vns_1hr',      tintv=1, tavrg=0, tunit='HOUR' &end
 &nmhist item='VNG',      file='vng_1hr',      tintv=1, tavrg=0, tunit='HOUR' &end

#-----  COSP2 OUTPUTS:
 &nmhist item='cllcalipso', file='cllcalipso'            &end
 &nmhist item='clmcalipso', file='clmcalipso'            &end
 &nmhist item='clhcalipso', file='clhcalipso'            &end
 &nmhist item='cltcalipso', file='cltcalipso'            &end
 &nmhist item='cltlidarradar', file='cltlidarradar'      &end
 &nmhist item='cllcalipsoice', file='cllcalipsoice'      &end
 &nmhist item='clmcalipsoice', file='clmcalipsoice'      &end
 &nmhist item='clhcalipsoice', file='clhcalipsoice'      &end
 &nmhist item='cltcalipsoice', file='cltcalipsoice'      &end
 &nmhist item='cllcalipsoliq', file='cllcalipsoliq'      &end
 &nmhist item='clmcalipsoliq', file='clmcalipsoliq'      &end
 &nmhist item='clhcalipsoliq', file='clhcalipsoliq'      &end
 &nmhist item='cltcalipsoliq', file='cltcalipsoliq'      &end
 &nmhist item='cllcalipsoun', file='cllcalipsoun'        &end
 &nmhist item='cltmodis', file='cltmodis'                &end
 &nmhist item='clwmodis', file='clwmodis'                &end
 &nmhist item='climodis', file='climodis'                &end
 &nmhist item='clhmodis', file='clhmodis'                &end
 &nmhist item='clmmodis', file='clmmodis'                &end
 &nmhist item='cllmodis', file='cllmodis'                &end
 &nmhist item='tautmodis', file='tautmodis'              &end
 &nmhist item='tauwmodis', file='tauwmodis'              &end
 &nmhist item='tauimodis', file='tauimodis'              &end
 &nmhist item='reffclwmodis', file='reffclwmodis'        &end
 &nmhist item='reffclimodis', file='reffclimodis'        &end
 &nmhist item='lwpmodis', file='lwpmodis'                &end
 &nmhist item='iwpmodis', file='iwpmodis'                &end
 &nmhist item='clcalipso', file='clcalipso'              &end
 &nmhist item='clcalipsotmp', file='clcalipsotmp'        &end
 &nmhist item='clcalipsotmpliq', file='clcalipsotmpliq'  &end
 &nmhist item='clcalipsotmpice', file='clcalipsotmpice'  &end
 &nmhist item='clcalipsotmpun', file='clcalipsotmpun'    &end
### IDiD for COSOPv2.0 (2019.01.21)
 &nmhist item='ncfodd1',  file='ncfodd1_ac1m',  tintv=1, tavrg=-1, tunit='MON' &end
 &nmhist item='ncfodd2',  file='ncfodd2_ac1m',  tintv=1, tavrg=-1, tunit='MON' &end
 &nmhist item='ncfodd3',  file='ncfodd3_ac1m',  tintv=1, tavrg=-1, tunit='MON' &end
 &nmhist item='npdfcld',  file='npdfcld_ac1m',  tintv=1, tavrg=-1, tunit='MON' &end
 &nmhist item='npdfdrz',  file='npdfdrz_ac1m',  tintv=1, tavrg=-1, tunit='MON' &end
 &nmhist item='npdfrain', file='npdfrain_ac1m', tintv=1, tavrg=-1, tunit='MON' &end
#-----  COSP2 OUTPUTS:
END_OF_DATA
############################################################

 echo job started at `date` > $OUTD/SYSOUT
 source /etc/profile.d/modules.csh
 module purge
 #module load openmpi-1.10.6/intel1700-64
 #module load openmpi-4.1.0/intel-19.1.3
 module load compiler/2021.3.0 openmpi-4.1.1/oneapi-2021.3.0 mkl/2021.3.0
 #mpirun -np $NMPIA $GCMDIR/bin/$SYSTEM/$EXEA >& $OUTD/ERROUT
 mpirun -np $NMPIA $GCMDIR/bin/$SYSTEM/$EXEA < /dev/null >& $OUTD/ERROUT
 echo job end at `date` >> $OUTD/SYSOUT

 exit
