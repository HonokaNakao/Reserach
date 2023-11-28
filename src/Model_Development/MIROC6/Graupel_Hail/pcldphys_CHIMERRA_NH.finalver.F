* PACKAGE PMLSC !! physics: large scale condensation with cloud water
*
* -Specify OPT_LSCBGT to check cloud ice tendency & water and energy budget.
*
************************************************************************
#include "miroc.h"

#ifdef SYS_SX
!! !option! -pvctl chgpwr
#endif
#ifdef SYS_FUJITSU
!ocl simd
#endif
      SUBROUTINE CLDPHYS    !! cloud physics
     O         ( GTT   , GTQ   ,
     O           GPRCL , GSNWL , GDCLW , GDCFRC, FLIQL ,GDQXI,
*COSP
     O           QLIQL , QICEL , GPLINT, GPSINT,
#ifdef OPT_SPRINTARS
     O           GPREC , FLIQAR,
#ifdef OPT_PROG_CLDN
     O           ESWAGG,
#endif
#endif
#ifdef OPT_SNWRAD
     O           RPPCL , REFFR , REFFS ,
     O           PREFRC, SNWFRC,  
#endif
     I           GDT   , GDQ   , GDP   , GDPM  , GDZM  , GDZ ,
#ifdef OPT_SPRINTARS
#ifdef OPT_PROG_CLDN
     I           ICNHE , CMPCLR,
#endif
     I           UAPCL ,
#endif
     I           TIME  , DELT  , IJS    )
*
      IMPLICIT NONE
*
*   [PARAM]
#include        "zcdim.F"                /* # of grid point & wave */
#include        "zpdim.F"                /* physics etc.           */
#include        "zccom.F"                /* stand. physical const. */
#include        "zradim-X.F"             /* radiation              */
#include        "zmtask.F"
*
*   [OUTPUT]
      REAL*8     GTT   ( IJSDIM, KMAX      )   !! heating rate
      REAL*8     GTQ   ( IJSDIM, KMAX, NTR )   !! change in q & l
      REAL*8     GDCLW ( IJSDIM, KMAX )        !! cloud water (liq+ice)
      REAL*8     GDCFRC( IJSDIM, KMAX      )   !! cloud fraction
      REAL*8     GDQXI ( IJSDIM, KMAX )        !! in-cloud water vapor
      REAL*8     FLIQL ( IJSDIM, KMAX      )   !! liquid fraction
      REAL*8     FLIQAR( IJSDIM, KMAX      )   !! liquid fraction for AeRosol
*
      REAL*8     GPRCL ( IJSDIM, NTR       )   !! rain fall
      REAL*8     GSNWL ( IJSDIM            )   !! snow fall
      REAL*8     GPREC ( IJSDIM, KMAX+1    )   !! precipitation flux
*COSP
      REAL*8     QLIQL  ( IJSDIM, KMAX  )      !! mixing_ratio_large_scale_cloud_liquid [kg/kg]
      REAL*8     QICEL  ( IJSDIM, KMAX  ) 
      REAL*8     GPLINT ( IJSDIM, KMAX  )      !! liq. precip. flux interpolated
      REAL*8     GPSINT ( IJSDIM, KMAX  )      !! solid precip. flux interpolated
#if defined(OPT_SPRINTARS) && defined(OPT_PROG_CLDN)
      REAL*8     ESWAGG( IJSDIM, KMAX      )   !! riming collection efficiency
#endif
#ifdef OPT_SNWRAD
      REAL*8     RPPCL  ( IJSDIM,KMAX,KPPCL )  !! mean volume radius for radiation [cm]
#endif
      REAL*8     PREFRC ( IJSDIM, KMAX )       !! precipitation fraction (rain)  [none]
      REAL*8     SNWFRC ( IJSDIM, KMAX )       !! precipitation fraction (snow)  [none]
      REAL*8     GRPFRC ( IJSDIM, KMAX )       !! precipitation fraction (graupel)  [none]
      REAL*8     REFFR  ( IJSDIM,KMAX )        !! raindrop  effective radius       [um]
      REAL*8     REFFS  ( IJSDIM,KMAX )        !! snowflake effective radius       [um]
      REAL*8     REFFG  ( IJSDIM,KMAX )        !! graupel   effective radius       [um]
*
*   [INPUT]
      REAL*8     GDT   ( IJSDIM, KMAX      )   !! temperature T
      REAL*8     GDQ   ( IJSDIM, KMAX, NTR )   !! humidity q
      REAL*8     GDP   ( IJSDIM, KMAX      )   !! pressure P
      REAL*8     GDPM  ( IJSDIM, KMAX+1    )   !! pressure (half lev)
      REAL*8     GDZ   ( IJSDIM, KMAX      )   !! altitude
      REAL*8     GDZM  ( IJSDIM, KMAX+1    )   !! altitude
#if defined(OPT_SPRINTARS) && defined(OPT_PROG_CLDN)
      REAL*8     ICNHE ( IJSDIM, KMAX )        !! rate of heterogeneous nucleation [m-3 s-1]
      REAL*8     CMPCLR( IJSDIM, KMAX, KCPCL ) !! cloud effective radius (m)
#endif
      REAL*8     UAPCL ( IJSDIM, KMAX      )   !! aerosol number (1/m**3)
      REAL*8     TIME                          !! time
      REAL*8     DELT                          !! delta(t) (atmosphere)
      INTEGER    IJS                           !! IJ index
*
*   [INTERNAL SAVE]
      REAL*8     ELF, ELFI, ELFM
      REAL*8     FTD1, FTD2, FTD3
      SAVE       ELF, ELFI, ELFM
      SAVE       FTD1, FTD2, FTD3
      INTEGER    ISTS2(MAX_MTASK), IENS2(MAX_MTASK)
      SAVE       ISTS2, IENS2
*
*   [INTERNAL WORK]
#ifndef OPT_NOCOMMON
      COMMON
     &           RH    ,
     &           QLIQ  , QICE  ,
     &           RDZ   , GDTX  , GDQX
#endif
      REAL*8     DELZ  ( IJSDIM, KMAX )        !! mean thickness between level K and K+1 [m]
      REAL*8     DELP  ( IJSDIM, KMAX )        !! mean thickness between level K and K+1 [Pa]
      REAL*8     RHO   ( IJSDIM, KMAX )        !! atmospheric density [kg m-3]
      REAL*8     GDTX  ( IJSDIM, KMAX )        !! temperature [K]
      REAL*8     GDQX  ( IJSDIM, KMAX )        !! water vapor
      REAL*8     GDTL  ( IJSDIM, KMAX )        !! liquid temperature
      REAL*8     GDQT  ( IJSDIM, KMAX )        !! total water
      REAL*8     RH    ( IJSDIM, KMAX )        !! relative humidity
      REAL*8     GDTD  ( IJSDIM, KMAX )        !! dew-point temperature
      REAL*8     GDCLWX( IJSDIM, KMAX )        !! cloud liquid water (bfr cold rain)
      REAL*8     RHLIQ ( IJSDIM, KMAX )        !! relative humidity liquid
      REAL*8     RHICE ( IJSDIM, KMAX )        !! relative humidity ice
      REAL*8     GPRECL ( IJSDIM, KMAX+1)      !! liq. precip. flux  [kg/m2/s]
      REAL*8     GPRECS ( IJSDIM, KMAX+1)      !! solid precip. flux [kg/m2/s]
      REAL*8     QLIQ  ( IJSDIM, KMAX )
      REAL*8     QICE  ( IJSDIM, KMAX )
      REAL*8     QSAT
      REAL*8     RDZ   ( IJSDIM, KMAX )
      REAL*8     FLIQOU( IJSDIM, KMAX      )   !! liquid fraction
      REAL*8     FTD
*
*   [INTERNAL WORK FOR PROGNOSTIC RAIN+SNOW]
*** T. Michibata: 2018.05.30: Introduced for CHIMERRA Microphysics Scheme
*     << Subtime Steps for Microphysics >>
      INTEGER    IITRMIC                       !! loop ID
      INTEGER    NITRMIC                       !! # of subtime steps for microphysics
      REAL*8     DTMIC                         !! dt [s] for microphysics (user prescribed)

*     << Warm Rain Microphysics >>
      !! EVAPORATION OF RAIN (LIQUID): R -> V  (rain -> vapor)
      REAL*8     PQEVPR ( IJSDIM, KMAX )       !! Qr tendency           (Qr = q of rain)
      REAL*8     PNEVPR ( IJSDIM, KMAX )       !! Nr tendency           (Nr = N of rain)
      !! AUTOCONVERSION (LIQUID): C + C -> R   (cloud + cloud -> rain)
      REAL*8     PQAUTL ( IJSDIM, KMAX )       !! Qr tendency
      REAL*8     PNAUTLC( IJSDIM, KMAX )       !! Nc tendency
      REAL*8     PNAUTLR( IJSDIM, KMAX )       !! Nr tendency
      !! ACCRETION (LIQUID): C + R -> R        (cloud + rain -> rain)
      REAL*8     PQACCL ( IJSDIM, KMAX )       !! Qc and/or Qr tendency (Qc = q of cloud)
      REAL*8     PNACCL ( IJSDIM, KMAX )       !! Nc tendency           (Nc = N of cloud)
      !! SELF-COLLECTION OF RAIN (LIQUID): R -> R (small rain -> big rain)
      REAL*8     PNSCLL ( IJSDIM, KMAX )       !! Nr tendency           (Nr = N of rain)         

*     << Cold Rain Microphysics >>
      !! DEPOSITION (ICE): V -> I              (Vapor -> Ice)
      REAL*8     PQDEPI ( IJSDIM, KMAX )       !!
      !! SUBLIMATION (ICE, SNOW): I -> V, S -> V  (Ice -> Vapor, Snow -> Vapor)
      REAL*8     PQSUBI ( IJSDIM, KMAX )       !! (PQSBI = P + q + sublimation + Ice) 
      REAL*8     PNSUBI ( IJSDIM, KMAX )       !! (PNSUBI = P + N + sublimation + Ice)
      REAL*8     PQSUBS ( IJSDIM, KMAX )       !! (PQSUBS = P + q + sublimation + Snow)
      REAL*8     PNSUBS ( IJSDIM, KMAX )       !! Note: snow sublimation doesn't change Ns! (PNSUBS = P + N + sublimation + Snow)
      !! AUTOCONVERSION (ICE): I + I -> S      (Ice + Ice -> Snow)
      REAL*8     PQAUTI ( IJSDIM, KMAX )       !! (PQAUTI = P + q + autoconversion + Ice)
      REAL*8     PNAUTI ( IJSDIM, KMAX )       !! (PNAUTI = P + N + autoconversion + Ice)
      !! ACCRETION (ICE): C + S -> S           (Cloud + Snow -> Snow)
      REAL*8     PQACCCS ( IJSDIM, KMAX )      !! (PQACCCS = P + q + accretion + Snow)
      REAL*8     PNACCCS ( IJSDIM, KMAX )      !! (PNACCCS = P + N + accretion + Snow)
      !! (OPTIONAL) HALLET-MOSSOP: S -> I      (Snow -> Ice)
      REAL*8     PQHLMI ( IJSDIM, KMAX )       !! (PQHLMI = P + q + Hallet-Mossop + Ice)
      REAL*8     PNHLMI ( IJSDIM, KMAX )       !! (PNHLMI = P + N + Hallet-Mossop + Ice)
      !! ACCRETION (ICE): I + S -> S           (Ice + Snow -> Snow)
      REAL*8     PQACCIS ( IJSDIM, KMAX )      !! (PQACCCS = P + q + accretion +Ice->Snow)
      REAL*8     PNACCIS ( IJSDIM, KMAX )      !! (PNACCCS = P + N + accretion + Ice->Snow)
      !! ACCRETION (ICE): R + S -> S           (Rain + Snow -> Snow)
      REAL*8     PQACCRS ( IJSDIM, KMAX )      !!
      REAL*8     PNACCRS ( IJSDIM, KMAX )      !!
      !! SELF-AGGREGATION (SNOW): S -> S       (small Snow -> big Snow)
      REAL*8     PNSAGS ( IJSDIM, KMAX )       !!
      !! BERGERON (ICE):
      REAL*8     PBERGI ( IJSDIM, KMAX )       !!
      !! BERGERON (SNOW):
      REAL*8     PBERGS ( IJSDIM, KMAX )       !!
      !! BERGERON (GRUPEL):
      REAL*8     PBERGG ( IJSDIM, KMAX )       !!
      
      !! DEPOSITION (GRAUPEL): V -> G          (Vapor -> Graupel)
      REAL*8     PQDEPG ( IJSDIM, KMAX )       !!
      !! SUBLIMATION (GRAUPEL): G -> V         (Graupel -> Vapor)
      REAL*8     PQSUBG ( IJSDIM, KMAX )       !! (PQSUBG = P + q + sublimation + Graupel) 
      REAL*8     PNSUBG ( IJSDIM, KMAX )       !! (PNSUBG = P + N + sublimation + Graupel)

      !! PQSACR : R + S -> G (Rain + Snow -> Graupel)
      REAL*8     PQSACR ( IJSDIM, KMAX )       !! (PQSACR = Q for PSACR) 
      REAL*8     PNSACR ( IJSDIM, KMAX )       !! (PNSACR = N for PSACR) 
     
      !! AUTOCONVERSION (SNOW): S + S -> G      (Snow + Snow -> Graupel)
      REAL*8     PQAUTS ( IJSDIM, KMAX )       !! (PQAUTS = P + q + autoconversion + Snow)
      REAL*8     PNAUTS ( IJSDIM, KMAX )       !! (PNAUTS = P + N + autoconversion + Snow)
      
      !! PSACWG : G + C -> big G (Graupel + Cloud droplet -> Graupel)
      REAL*8     PSACWG ( IJSDIM, KMAX )       !! (PSACWG = Q for PSACWG) 
      REAL*8     NPSACWG( IJSDIM, KMAX )       !! (NPSACWG = N for PSACWG)
      REAL*8     PSACWG_X( IJSDIM, KMAX )      !! (PSACWG = Q for PSACWG)
      REAL*8     NPSACWG_X( IJSDIM, KMAX )     !! (NPSACWG = N for PSACWG) 

*     << Summary Tendency >>
      REAL*8     NNFCT                         !! non-negative factor (>= 0)
      REAL*8     DQVALL ( IJSDIM, KMAX )
      REAL*8     DQCALL ( IJSDIM, KMAX )
      REAL*8     DQIALL ( IJSDIM, KMAX )
      REAL*8     DQRALL ( IJSDIM, KMAX )
      REAL*8     DQSALL ( IJSDIM, KMAX )
      REAL*8     DQGALL ( IJSDIM, KMAX )
      REAL*8     QVTEND ( IJSDIM, KMAX )  !! Qv (Qv = q of vapor)
      REAL*8     QCTEND ( IJSDIM, KMAX )  !! Qc (Qc = q of cloud)
      REAL*8     QITEND ( IJSDIM, KMAX )  !! Qi (Qi = q of ice)
      REAL*8     QRTEND ( IJSDIM, KMAX )  !! Qr (Qr = q of rain)
      REAL*8     QSTEND ( IJSDIM, KMAX )  !! Qs (Qs = q of snow)
      REAL*8     QGTEND ( IJSDIM, KMAX )  !! Qg (Qg = q of graupel)
      REAL*8     DNCALL ( IJSDIM, KMAX )
      REAL*8     DNIALL ( IJSDIM, KMAX )
      REAL*8     DNRALL ( IJSDIM, KMAX )
      REAL*8     DNSALL ( IJSDIM, KMAX )
      REAL*8     DNGALL ( IJSDIM, KMAX )
      REAL*8     NCTEND ( IJSDIM, KMAX )  !! Nc (N of cloud)
      REAL*8     NITEND ( IJSDIM, KMAX )  !! Ni (N of cloud)
      REAL*8     NRTEND ( IJSDIM, KMAX )  !! Nr (N of rain) 
      REAL*8     NSTEND ( IJSDIM, KMAX )  !! Ns (N of snow)
      REAL*8     NGTEND ( IJSDIM, KMAX )  !! Ng (N of graupel)
      REAL*8     LHTEND ( IJSDIM, KMAX )  !! Latent Heating Rate [K/day]
      REAL*8     DTEMP                    !! dT due to microphysics [K]

*     << Hydrometeors >>
      REAL*8     GDIFRC ( IJSDIM, KMAX )       !! ice cloud fraction            [none] (dimensionless)
      REAL*8     RFLUX  ( IJSDIM, KMAX )       !! rain flux [kg m-2 s-1] from mass-weighted fall velocity
      REAL*8     SFLUX  ( IJSDIM, KMAX )       !! snow flux [kg m-2 s-1] from mass-weighted fall velocity
      REAL*8     GFLUX  ( IJSDIM, KMAX )       !! graupel flux [kg m-2 s-1] from mass-weighted fall velocity
      REAL*8     GDQV   ( IJSDIM, KMAX )       !! water vapor mixing ratio [kg/kg]
      REAL*8     GDQC   ( IJSDIM, KMAX )       !! cloud water mass mixing ratio [kg/kg]
      REAL*8     GDNC   ( IJSDIM, KMAX )       !! cloud drop number concentration [m-3] (prognosed @ AERCCN)
      REAL*8     GDQI   ( IJSDIM, KMAX )       !! cloud ice mass mixing ratio [kg/kg]
      REAL*8     GDNI   ( IJSDIM, KMAX )       !! cloud ice  number concentration [m-3] (prognosed @ AERCCN)
      REAL*8     GDQR   ( IJSDIM, KMAX )       !! rain mass mixing ratio    [kg/kg]
      REAL*8     GDNR   ( IJSDIM, KMAX )       !! rain number concentration [m-3]
      REAL*8     GDQS   ( IJSDIM, KMAX )       !! snow mass mixing ratio    [kg/kg]
      REAL*8     GDNS   ( IJSDIM, KMAX )       !! snow number concentration [m-3]
      REAL*8     GDQG   ( IJSDIM, KMAX )       !! graupel.hail mass mixing ratio    [kg/kg]
      REAL*8     GDNG   ( IJSDIM, KMAX )       !! graupel.hail number concentration [m-3]
      REAL*8     SGCF                          !! subgrid liq. cld. fraction (for safety)
      REAL*8     SGIF                          !! subgrid ice  cld. fraction (for safety)
      REAL*8     SGPF                          !! subgrid      rain fraction (for safety)
      REAL*8     SGSF                          !! subgrid      snow fraction (for safety)
      REAL*8     SGGF                          !! subgrid      graupel fraction (for safety)
      REAL*8     QCLDL                         !! cloud water mass mixing ratio [kg/kg] (in-cloud Qc)
      REAL*8     NCLDL                         !! cloud number concentration [m-3] (in-cloud Nc)
      REAL*8     QCLDI                         !! cloud ice mass mixing ratio [kg/kg] (in-cloud Qi)
      REAL*8     NCLDI                         !! cloud ice number concentration [m-3] (in-cloud Ni)
      REAL*8     QRAIN                         !! rain mass mixing ratio [kg/kg] (in-cloud Qr)
      REAL*8     NRAIN                         !! rain number concentration [m-3] (in-cloud Nr)
      REAL*8     QSNOW                         !! snow mass mixing ratio [kg/kg] for "in-cloud" value
      REAL*8     NSNOW                         !! snow num. mixing ratio [m-3]   for "in-cloud" value
      REAL*8     QGRPL                         !! graupel mass mixing ratio [kg/kg] for "in-cloud" value
      REAL*8     NGRPL                         !! graupel num. mixing ratio [m-3]   for "in-cloud" value
      REAL*8     RHOSU                         !! typical 850hPa air density
      REAL*8     RHOF                          !!
      REAL*8     VDIF                          !! water vapor diffusivity
      REAL*8     VISC                          !! viscosity
      REAL*8     SCHM                          !! schmidt number
      REAL*8     QVCLR                         !! H2O vapor mixing ratio in clear air [kg/kg]
      REAL*8     GDQVL                         !! H2O vapor mixing ratio for liquid   [kg/kg]
      REAL*8     GDQVI                         !! H2O vapor mixing ratio for ice      [kg/kg]
      REAL*8     GDQVG                         !! H2O vapor mixing ratio for graupel   [kg/kg]
!      REAL*8     RRSFC  ( IJSDIM )             !! rain rate at the surface [kg m-2 s-1]
!      REAL*8     RRCB   ( IJSDIM )             !! rain rate at the cloud-base [kg m-2 s-1]

*     << Sedimentation >>
      !! Sedimentation of Ice, Rain. and Snow
      REAL*8     PQSEDR ( IJSDIM, KMAX )       !! Qr tendency
      REAL*8     PNSEDR ( IJSDIM, KMAX )       !! Nr tendency
      REAL*8     PQSEDI ( IJSDIM, KMAX )       !! Qi tendency
      REAL*8     PNSEDI ( IJSDIM, KMAX )       !! Ni tendency
      REAL*8     PQSEDS ( IJSDIM, KMAX )       !! Qs tendency
      REAL*8     PNSEDS ( IJSDIM, KMAX )       !! Ns tendency
      REAL*8     PQSEDG ( IJSDIM, KMAX )       !! Qg tendency
      REAL*8     PNSEDG ( IJSDIM, KMAX )       !! Ng tendency

      !! Size Distribution Parameters
      REAL*8     WDIST                         !! spectral width parameter based on Martin et al. (1994)
      REAL*8     LAMC ( IJSDIM, KMAX )         !! slope of the cloud droplet distribution [m-1]
      REAL*8     LAMR ( IJSDIM, KMAX )         !! slope of the raindrop distribution [m-1]
      REAL*8     LAMI ( IJSDIM, KMAX )         !! slope of the cloud ice distribution [m-1]
      REAL*8     LAMS ( IJSDIM, KMAX )         !! slope of the snowflake distribution [m-1]
      REAL*8     LAMG ( IJSDIM, KMAX )         !! slope of the graupel distribution [m-1]
      REAL*8     DCMEAN                        !! mean diameter (cloud) [m]
      REAL*8     DIMEAN                        !! mean diameter (ice) [m]
      REAL*8     DRMEAN                        !! mean diameter (rain) [m]
      REAL*8     DSMEAN                        !! mean diameter (snow) [m]
      REAL*8     DGMEAN                        !! mean diameter (graupel) [m]
!      REAL*8     MASSI  ( IJSDIM, KMAX )       !! ice  mass [kg]
!      REAL*8     MASSR  ( IJSDIM, KMAX )       !! rain mass [kg]
!      REAL*8     MASSS  ( IJSDIM, KMAX )       !! snow mass [kg]
!      REAL*8     DIAMI  ( IJSDIM, KMAX )       !! ice       diameter [m]
!      REAL*8     DIAMR  ( IJSDIM, KMAX )       !! raindrop  diameter [m]
!      REAL*8     DIAMS  ( IJSDIM, KMAX )       !! snowflake diameter [um]
      !! Method based on Posselt and Lohmann (2009) as well as Sant et al. (2015) & addition of graupel (21.09.13)
      REAL*8     N0I                           !! N0I = NCLDI * LAMI [m-4]     ! interceptor                                           
      REAL*8     N0R                           !! N0R = NRAIN * LAMR [m-4]
      REAL*8     N0S                           !! N0S = NSNOW * LAMS [m-4]
      REAL*8     N0G                           !! N0G = NGRPL * LAMG [m-4]
      REAL*8     D0C                           !! D0C = 1/LAMC [m]
      REAL*8     D0I                           !! D0I = 1/LAMI [m]
      REAL*8     D0R                           !! D0R = 1/LAMR [m]
      REAL*8     D0S                           !! D0S = 1/LAMS [m]
      REAL*8     D0G                           !! D0G = 1/LAMG [m]
      REAL*8     BETA1                         !! beta1 = 1.23
      REAL*8     BETA2                         !! beta2 = 0.22
      REAL*8     VQR    ( IJSDIM, KMAX )       !!   mass weight  raindrop fall velocity [m/s]
      REAL*8     VNR    ( IJSDIM, KMAX )       !! number weight  raindrop fall velocity [m/s]
      REAL*8     VQI    ( IJSDIM, KMAX )       !!   mass weight cloud ice fall velocity [m/s]
      REAL*8     VNI    ( IJSDIM, KMAX )       !! number weight cloud ice fall velocity [m/s]
      REAL*8     VQS    ( IJSDIM, KMAX )       !!   mass weight snowflake fall velocity [m/s]
      REAL*8     VNS    ( IJSDIM, KMAX )       !! number weight snowflake fall velocity [m/s]
      REAL*8     VQG    ( IJSDIM, KMAX )       !!   mass weight graupel fall velocity [m/s]
      REAL*8     VNG    ( IJSDIM, KMAX )       !! number weight graupel fall velocity [m/s]
      REAL*8     FQR    ( IJSDIM, KMAX )       !!   mass sed. flux for P system (rain)     [kg m-1 s-3]
      REAL*8     FNR    ( IJSDIM, KMAX )       !! number sed. flux for P system (rain)     [kg m-1 s-3]
      REAL*8     FQI    ( IJSDIM, KMAX )       !!   mass sed. flux for P system (ice)      [kg m-1 s-3]
      REAL*8     FNI    ( IJSDIM, KMAX )       !! number sed. flux for P system (ice)      [kg m-1 s-3]
      REAL*8     FQS    ( IJSDIM, KMAX )       !!   mass sed. flux for P system (snow)     [kg m-1 s-3]
      REAL*8     FNS    ( IJSDIM, KMAX )       !! number sed. flux for P system (snow)     [kg m-1 s-3]
      REAL*8     FQG    ( IJSDIM, KMAX )       !!   mass sed. flux for P system (graupel)  [kg m-1 s-3]
      REAL*8     FNG    ( IJSDIM, KMAX )       !! number sed. flux for P system (graupel)  [kg m-1 s-3]

      !! sub-timestep for iteration for sedimentation
      INTEGER    IITRSED                       !! loop
      INTEGER    NITRSED( IJSDIM )             !! # of subtime steps for sedimentation
      INTEGER    MAX_NITRSED
      REAL*8     FRSED  ( IJSDIM )             !! 1 / NITRSED
      REAL*8     VCFLP  ( IJSDIM )             !! subtime step [sec] due to vertical CFL (p-system)
      REAL*8     VCFLZ  ( IJSDIM )             !! subtime step [sec] due to vertical CFL (z-system)
      REAL*8     DTSED  ( IJSDIM )             !! dt [s] for sedimentation (determined by vertical CFL)

*     << Statistics >>
      !! Column Integrated Hydrometeors
      REAL*8     WVM    ( IJSDIM )             !! water vapor mass (precipitable water) [kg m-2]
      REAL*8     CLWP   ( IJSDIM )             !! cloud liquid water path [kg m-2]
      REAL*8     CIWP   ( IJSDIM )             !! cloud ice water path [kg m-2]
      REAL*8     RWP    ( IJSDIM )             !! rain water path [kg m-2]
      REAL*8     RWPCL  ( IJSDIM )             !! rain water path [kg m-2] (cloud layer)
      REAL*8     RWPBC  ( IJSDIM )             !! rain water path [kg m-2] (below cloud)
      REAL*8     SWP    ( IJSDIM )             !! snow water path [kg m-2]
      REAL*8     GWP    ( IJSDIM )             !! graupel water path [kg m-2]
      REAL*8     COLCCN ( IJSDIM )             !! column CCN burden [# m-2]
      REAL*8     COLNC  ( IJSDIM )             !! column  Nc burden [# m-2]
      REAL*8     COLNI  ( IJSDIM )             !! column  Ni burden [# m-2]
      REAL*8     COLNR  ( IJSDIM )             !! column  Nr burden [# m-2]
      REAL*8     COLNS  ( IJSDIM )             !! column  Ns bursen [# m-2]
      REAL*8     COLNG  ( IJSDIM )             !! column  Ng burden [# m-2]
      !! Column Integrated Process Rates
      REAL*8     ACVS   ( IJSDIM )             !! autoconversion rate [kg m-2 s-1]
      REAL*8     ACCS   ( IJSDIM )             !! accretion rate      [kg m-2 s-1]
      REAL*8     ACAUS  ( IJSDIM )             !! Acc/Aut ratio       [none]
      !! Effective Radii
      REAL*8     REFFC  ( IJSDIM, KMAX )       !! cloud droplet effective radius [um]
      REAL*8     REFFI  ( IJSDIM, KMAX )       !! ice   crystal effective radius [um]
      !! LTS
      REAL*8     LTS    ( IJSDIM )             !! LTS [K]
      REAL*8     THETA  ( IJSDIM,KMAX )
      INTEGER    KP700  ( IJSDIM )
      INTEGER    KPSFC  ( IJSDIM )
      INTEGER    KP7
      INTEGER    KPS
      REAL*8     DIFF_P700  ( IJSDIM )
      REAL*8     DIFF_P1000 ( IJSDIM )

      !! Tendency Monitor
      REAL*8     QTD ( IJSDIM, KMAX , 32 )  !! Q tendency diagnostics
*      1: condensation/evaporation (diagnosed by the prognostic PDF scheme)
*      2: homogeneous freezing
*      3: heterogeneous freezing
*      4: instantaneous snow melting
*      5: freezing of rain to ice  at -5 degC
*      6: freezing of rain to snow at -5 degC
*      7: autoconversion c+c -> r
*      8: accretion c+r -> r
*      9: Hallet-Mossop process
*     10: accretion c+s -> s
*     11: Bergeron c -> i
*     12: Bergeron c -> s
*     13: rain evaporation
*     14: acc/aut ratio
*     15: deposition (ice)
*     16: sublimation (ice)
*     17: autoconversion of ice to snow
*     18: accretion of i+s -> s
*     19: accretion of r+s -> s
*     20: snow sublimation
*     21: rain sedimentation
*     22: snow sedimentation
*     23: ice  sedimentation
*     24: ice melting
*     25: graupel sedimentation
*     26: graupel sublimation
*     27: deposition (graupel)
*     28: Bergeron c -> g
*     29: PSACR r + s -> g
*     30: instantaneous graupel melting g -> r
*     31: freezing of rain to graupel at -5 degC
*     32: PSACWG g + c -> g

      REAL*8     NTD ( IJSDIM, KMAX , 29 )  !! N tendency diagnostics
*      1: dNc/dt due to homogeneous freezing
*      2: dNi/dt due to homogeneous freezing
*      3: dNi/dt due to heterogeneous freezing
*      4: dNr/dt due to melting snow
*      5: dNi/dt due to rain freez
*      6: dNs/dt due to rain freez
*      7: dNr/dt due to evaporation
*      8: dNr/dt due to autoconversion
*      9: dNc/dt due to autoconversion
*     10: dNr/dt due to accretion
*     11: dNr/dt due to self-collect.
*     12: dNi/dt due to sublimation of ice
*     13: dNs/dt due to autoconv.
*     14: dNs/dt due to acc c+s -> s
*     15: dNs/dt due to H-M process
*     16: dNs/dt due to acc i+s -> s
*     17: dNs/dt due to acc r+s -> s
*     18: dNs/dt due to self-aggreg.
*     19: dNr/dt due to sedimentation
*     20: dNs/dt due to sedimentat.
*     21: dNi/dt due to sedimentat.
*     22: dNc/dt due to melting ice
*     23: dNi/dt due to melting ice
*     24: dNg/dt due to sedimentat.
*     25: dNg/dt due to sublimation of graupel
*     26: dNg/dt due to PSACR of graupel
*     27: dNg/dt due to melting graupel g -> r
*     28: dNg/dt due to rain freez
*     29: dNg/dt due to NPSACWG g + c -> g

      !! Temperature Tendency
      REAL*8     TTD ( IJSDIM, KMAX , 13 )  !! temperature tendency
*      1: cloud droplet homogeneous freezing     (Qc --> Qi): T increases
*      2: cloud droplet heterogeneous nucleation (Qc --> Qi): T increases
*      3: snow melting             (Qs --> Qr)      : T decreases
*      4: rain freezing            (Qr --> Qs or Qg): T increases
*      5: rain evaporation         (Qr --> Qv)      : T decreases
*      6: snow sublimation         (Qs --> Qv)      : T decreases
*      7: ice melting              (Qi --> Qc)      : T decreases
*      8: ice deposition           (Qv --> Qi)      : T increase
*      9: ice sublimation          (Qi --> Qv)      : T decreases
*     10: Bergeron ice             (Qc --> Qi)      : T increase
*     11: Bergeron snow            (Qc --> Qs)      : T increase
*     12: accretion c+s -> s       (Qc --> Qs)      : T increase
*     13: snow melting             (Qg --> Qr)      : T decreases
*
      REAL*8     HBGTA ( IJSDIM )              !!
      REAL*8     HBGTB ( IJSDIM )              !!
      REAL*8     HBGTC1( IJSDIM, KMAX )        !!
      REAL*8     HBGTC2( IJSDIM, KMAX )        !!
      REAL*8     HBGTC3( IJSDIM, KMAX )        !!
      REAL*8     HBGTC4( IJSDIM, KMAX )        !!
      REAL*8     WBGTA ( IJSDIM )              !!
      REAL*8     WBGTB ( IJSDIM )              !!
      REAL*8     DQTEND( IJSDIM )              !! water budget check
      REAL*8     DWATER( IJSDIM )              !! water budget check
      REAL*8     DSEDR ( IJSDIM )              !! water budget check
      REAL*8     DSEDI ( IJSDIM )              !! water budget check
      REAL*8     DSEDS ( IJSDIM )              !! water budget check
      REAL*8     DSEDG ( IJSDIM )              !! water budget check
      REAL*8     DSEDRS( IJSDIM )              !! water budget check
      REAL*8     MSCNSV( IJSDIM )              !! water budget check
      REAL*8     FLXBEF( IJSDIM )              !! water budget check
      REAL*8     FLXAFT( IJSDIM )              !! water budget check
      REAL*8     RBEF  ( IJSDIM )              !! water budget check
      REAL*8     IBEF  ( IJSDIM )              !! water budget check
      REAL*8     SBEF  ( IJSDIM )              !! water budget check
      REAL*8     GBEF  ( IJSDIM )              !! water budget check
      REAL*8     RAFT  ( IJSDIM )              !! water budget check
      REAL*8     IAFT  ( IJSDIM )              !! water budget check
      REAL*8     SAFT  ( IJSDIM )              !! water budget check
      REAL*8     GAFT  ( IJSDIM )              !! water budget check

*
      INTEGER    IJ, K, M
      INTEGER    IFPAR, JFPAR
      INTEGER    ISTS, IENS                    !! do NOT save
      LOGICAL    OAERNUM_INPUT
*
      INTEGER    DUMINT1( IJSDIM )                   !! dummy variable to save memory
      INTEGER    DUMINT2( IJSDIM )                   !! dummy variable to save memory
      REAL*8     DUM0D                               !! dummy variable to save memory
      REAL*8     DUM1, DUM2, DUM3, DUM4, DUM5, DUM6  !! dummy variable to save memory
      REAL*8     DUMIJK( IJSDIM, KMAX )              !! dummy variable to save memory
*
*   [INTERNAL PARM]
      REAL*8     PI
      REAL*8     RCFACT                        !! random-overlapping factor
      REAL*8     GAMM                          !! gamma function
      !REAL*8     QIMIN                         !! min. cloud ice
      LOGICAL    OIND2                         !! on/off 2nd indirect effect
      LOGICAL    OIND2_FX                      !! fix/var. 2st indirect effect
      REAL*8     REFCT( KCPCL )                !! Re/Rvol           (DUMMY)
      REAL*8     RCMAX( KCPCL )                !! maximum of radius (DUMMY)
      REAL*8     UCMIN( KCPCL )                !! minimum cloud drop number
      REAL*8     FLIQMIN                       !! minimum liquid fraction
      SAVE       FLIQMIN
      REAL*8     TWSNOW                        !! wet-bulb temp. rain/snow
      !REAL*8     EFRIM                         !! collision EFficiency for RIMing
      SAVE       RCFACT,
     &           OIND2 , OIND2_FX
      SAVE       RCMAX , REFCT , UCMIN
      SAVE       TWSNOW
      SAVE       PI
#ifdef OPT_PROG_CLDN
      REAL*8     AVOG                          !! Avogadro constant
      SAVE       AVOG
      REAL*8     GDTV  ( IJSDIM, KMAX )        !! virtual temperature Tv
#endif
      LOGICAL    OCCN2CLD, OCLD2CCN       !! use prognosed CCN to nucleation
      SAVE       OCCN2CLD
      LOGICAL    OFIRST
      SAVE       OFIRST
      CHARACTER  HCLAS *3
*
*     !! will be disappeared in near future in CHIMERRA framework
      REAL*8     B1, B2, B3                    !! Berry Coef.
      SAVE       B1, B2, B3
      INTEGER    NTRX
      PARAMETER (NTRX=NTR-NTRV+1)
      REAL*8     FSCAV ( NTRX )
      REAL*8     FENTR ( NTRX )
      REAL*8     FSCUM ( NTRX )
      REAL*8     FSWTR ( NTRX )
      SAVE       FSCAV , FENTR , FSCUM ,  FSWTR
      REAL*8     TSICE                         !! temp. of ice/liq = 0
      REAL*8     TWICE                         !! temp. of ice/liq = 1
      SAVE       TSICE , TWICE
*
*
*   [INTERNAL PARM FOR PROGNOSTIC RAIN+SNOW]
      !! tracer ID
      INTEGER    INC                           !! tracer No. for Nc (liquid droplet num. conc.)
      INTEGER    INI                           !! tracer No. for Ni (ice droplet num. conc.)
      PARAMETER (INC=NTRC+NDU+NSA+NCAX+NSU+1)
      PARAMETER (INI=NTRC+NDU+NSA+NCAX+NSU+2)
      !! Minimum Boundary
      REAL*8     QMIN
      REAL*8     MINCLD                        !! minimum PREFRC to avoid a numerical error
      REAL*8     SFRE                          !! Safety Factor for Rounding Error
      PARAMETER (SFRE = 1.D0 - 1.D-5)
      REAL*8     LMTMDC (2)  !! limit mean diameter for cloud droplet
      REAL*8     LMTMDI (2)  !! limit mean diameter for ice crystal
      REAL*8     LMTMDR (2)  !! limit mean diameter for raindrop
      REAL*8     LMTMDS (2)  !! limit mean diameter for snowflake
      REAL*8     LMTMDG (2)  !! limit mean diameter for graupel
      !! Scheme Dependent Parameters (Tunable Nobs):
      REAL*8     DRAT        !! ratio of threshold diameter to average diameter
      REAL*8     MICE        !! mass of an ice crystal
      REAL*8     CSIAUT      !! CSIAUT ... Critical Size of Ice crystals for
                             !! AUToconversion of ice to snow [m]
      REAL*8     TSAUTI      !! Time-Scale for AUToconversion of Ice, assuming 180 sec.
      REAL*8     MSNW        !! mass of an snow
      REAL*8     CSSAUT      !! CSSAUT ... Critical Size of Snow crystals for
                             !! AUToconversion of snow to graupel [m]
      REAL*8     TSAUTS      !! Time-Scale for AUToconversion of Snow, assuming 180 sec.
      REAL*8     MI0         !! generated NEW Ice  Mass [kg] via H-M process,    assuming  10 micron
      REAL*8     NEWRM       !! generated NEW Rain Mass [kg] via autoconversion, assuming  25 micron
      REAL*8     NEWSM       !! generated NEW Snow Mass [kg] via autoconversion, assuming 150 micron
      REAL*8     EFACRS      !! collision EFficiency for ACretion of Raindrop by Snowflake
      REAL*8     EFRICG      !! collision EFficiency for RIming of Cloud droplet by Graupel
      REAL*8     EFAGG       !! AGGregation EFiciency of cloud ice and snow
      REAL*8     EFRIM       !! RIMing EFiciency of cloud water and snow
      REAL*8     AFR         !! ventilation parameters for rain
      REAL*8     BFR         !! ventilation parameters for rain
      REAL*8     AFS         !! ventilation parameters for snow
      REAL*8     BFS         !! ventilation parameters for snow
#ifdef OPT_TC80
      REAL*8     QCRIT       !! autoconversion threshold Qc
      REAL*8     RCRIT       !! autoconversion threshold Rc = 10 micron
      REAL*8     ECR         !! mean collection efficiency for droplets Ecr = 0.55 micron
      REAL*8     MYU         !! dynamic viscosity
#endif
#ifdef OPT_LD04
      REAL*8     R3          !! mean volume radius
      REAL*8     R6          !! 6th momentum volume radius
      REAL*8     R6C         !! critical threshold of R6 for Heaviside step function
      REAL*8     BETA6       !! 6th of beta coeff.
#endif
#ifdef OPT_SB06
!      REAL*8, PARAMETER :: KC = 9.44D9    !! [cm3 g-2 s-1] SB01
!      REAL*8, PARAMETER :: KR = 5.78D3    !! [cm3 g-1 s-1] SB01
      REAL*8, PARAMETER :: KC = 4.44D9    !! [cm3 g-2 s-1] SB06
      REAL*8, PARAMETER :: KR = 5.25D3    !! [cm3 g-1 s-1] SB06
      REAL*8     RCMEAN      !! mean size of the cloud droplet [micron]
      REAL*8     MASSC       !! mean cloud mass by Lc/Nc [kg]
      REAL*8     MASSCR      !! mass boundary between cloud and rain [kg]
      !REAL*8, PARAMETER :: MASSCR = 4.D0/3.D0*PI*RHOW*(40.D-6)**3  !! mass boundary between cloud and rain at 40 micron [kg]
      REAL*8     RRMEAN      !! mean size of the raindrop [micron]
      REAL*8     MASSR       !! mean rain mass by Lr/Nr [kg]
      REAL*8     REFZC       !! radar reflectivity Z (cloud)
      REAL*8     REFZR       !! radar reflectivity Z (rain)
      REAL*8     TAU         !! internal time variable [none]
      REAL*8     FAIAUT      !! dimless autoconversion rate from Eq. 6 of Seifert and Beheng (2006)
      REAL*8     FAIACC      !! dimless      accretion rate from Eq. 8 of Seifert and Beheng (2006)
#endif
#if defined (OPT_SB06NEW1) || (OPT_SB06NEW2) || (OPT_SB06NEW3)
      REAL*8     R3          !! mean volume radius
      REAL*8     R6          !! 6th momentum volume radius
      REAL*8     R6C         !! critical threshold of R6 for Heaviside step function
      REAL*8     BETA6       !! 6th of beta coeff.
      REAL*8, PARAMETER :: KC = 4.44D9    !! [cm3 g-2 s-1] SB06
      REAL*8, PARAMETER :: KR = 5.25D3    !! [cm3 g-1 s-1] SB06
      REAL*8     RCMEAN      !! mean size of the cloud droplet [micron]
      REAL*8     MASSC       !! mean cloud mass by Lc/Nc [kg]
      REAL*8     MASSCR      !! mass boundary between cloud and rain [kg]
      REAL*8     RRMEAN      !! mean size of the raindrop [micron]
      REAL*8     MASSR       !! mean rain mass by Lr/Nr [kg]
      REAL*8     REFZC       !! radar reflectivity Z (cloud)
      REAL*8     REFZR       !! radar reflectivity Z (rain)
      REAL*8     TAU         !! internal time variable [none]
      REAL*8     FAIAUT      !! dimless autoconversion rate from Eq. 6 of Seifert and Beheng (2006)
      REAL*8     FAIACC      !! dimless      accretion rate from Eq. 8 of Seifert and Beheng (2006)
#endif
      !! fall speed parameters, V = aD^b (V is in m/s)
      !! droplets
      REAL*8     B1R                           !! [m/s]
      REAL*8     B2R                           !! [m/s]
      REAL*8     B3R                           !! [/m]
      REAL*8     BVR                           !! 3918 [/s] (constant)
      REAL*8     DVR                           !! critical distribution parameter Dv, i.e. 2463 [um]
      REAL*8     DVQ                           !! threshold of bulk velocity for VQR [m]
      REAL*8     DVN                           !! threshold of bulk velocity for VNR [m]
      !! snow
      REAL*8     AS, ASN
      REAL*8     BS
      REAL*8     RHOW                          !! bulk density liquid 1000 [kg m-3]
      REAL*8     RHOI                          !! bulk density ice crystal  500 [kg m-3]
      REAL*8     RHOS                          !! bulk density snow 250 [kg m-3]
      REAL*8     RHOWS                         !! bulk density water solid  917 [kg m-3]
      !! graupel
      REAL*8     RHOG                          !! bulk density graupel 900 [kg m-3]
      REAL*8     SPFGA                         !! Shape Parameters for Fall speed set differently for hail/Graupel : a
      REAL*8     SPFGB                         !! Shape Parameters for Fall speed set differently for hail/Graupel : b
      REAL*8     GAMB                          !! Gamma( b + 3 ) , b = 2

*
      SAVE       MINCLD, QMIN
      SAVE       RHOW, RHOI, RHOS, RHOWS, RHOG,
     &           B1R,  B2R,  B3R
!     &           SPFGA, SPFGB, GAMB
      SAVE       DTMIC
      REAL*8, SAVE :: GAMM_MUI, GAMM_MUR, GAMM_MUS, GAMM_MUG
      REAL*8, SAVE :: GAMM_QS, GAMM_NS
      REAL*8, SAVE :: GAMM_QI, GAMM_NI
      REAL*8, SAVE :: GAMM_QG, GAMM_NG
      REAL*8, SAVE :: GAMM_BS3, GAMM_BS5
*
*      << Tuning Parameters from NAMELIST "PRPS" >>
*
      !! Scheme Dependent Tunable Nobs
      REAL*8     EAUT,     EACC,     EAUTI,    EAUTS     !! Enhancement Factors
      SAVE       EAUT,     EACC,     EAUTI,    EAUTS     !! default = 1.0
      REAL*8     QMINAUTL, QMINAUTI            !! autoconversion threshold for Qc
      SAVE       QMINAUTL, QMINAUTI            !! default = 1.d-9 kg/kg
      SAVE       CSIAUT,   TSAUTI
      SAVE       CSSAUT,   TSAUTS
      SAVE       EFACRS,   EFAGG,    EFRIM,    EFRICG
      REAL*8     EVPR                          !! factor for rain evaporation
      SAVE       EVPR                          !! default = 0.5
      REAL*8     ADRMLTI                       !! assumed droplet radius [um] due to melting ice
      SAVE       ADRMLTI                       !! default = 8.0 [um]
                                               !! if adrmlti=0, drop radius is same as melting ice.
      REAL*8     BFICE, BFSNOW                 !! factor for Bergeron ice and Bergeron snow
      SAVE       BFICE, BFSNOW                 !! default = 1.0
      REAL*8     BFGRP                         !! factor for Bergeron graupel
      SAVE       BFGRP                         !! default = 1.0
      REAL*8     DEPSUBI, SUBS                 !! factor for depo/sublim of ice and sublim of snow
      SAVE       DEPSUBI, SUBS                 !! default = 1.0
      REAL*8     DEPSUBG                       !! factor for depo/sublim of graupel 
      SAVE       DEPSUBG                       !! default = 1.0
      REAL*8     DNFSUBI                       !! factor for dNi due to sublimation of ice
      SAVE       DNFSUBI                       !! default = 1.0
      REAL*8     DNFSUBG                       !! factor for dNg due to sublimation of graupel
      SAVE       DNFSUBG                       !! default = 1.0
      REAL*8     THOMF                         !! temperature [K] at homogeneous freezing
      SAVE       THOMF                         !! default = 233.15 [K]
      REAL*8     VFCTR, VFCTI, VFCTS, VFCTG    !! factor for terminal velocity
      SAVE       VFCTR, VFCTI, VFCTS, VFCTG    !! default = 1.0
      !! Droplet Size Distribution (DEFAULT: Modified-Gamma DSD is Assumed)
      REAL*8     NUC                           !! shape factor (cloud)
      REAL*8     NUI                           !! shape factor (ice)
      REAL*8     NUR                           !! shape factor (rain)
      REAL*8     NUS                           !! shape factor (snow)
      REAL*8     MUC                           !! shape factor (cloud)
      REAL*8     MUI                           !! shape factor (ice)
      REAL*8     MUR                           !! shape factor (rain)
      REAL*8     MUS                           !! shape factor (snow)
      REAL*8     MUG                           !! shape factor (graupel)
      SAVE       NUC, NUI, NUR, NUS
      SAVE       MUC, MUI, MUR, MUS, MUG
      !! PSACR(r + s -> g) Parameter (based on Gettelman, 2018)
      REAL*8     ECG                       !! collection efficiency 
      SAVE       ECG                       !! default = 1.0

*
*   [INTERNAL FUNC]
#include        "zqsat.F"                /* saturate vapor pressure */
#ifndef HAVE_CBRT
      REAL*8    CBRT, X_
      CBRT( X_ )  = ( X_ )**( 1.D0 / 3.D0 )
#endif
*
      NAMELIST  /NMMLSC/ RCFACT ,
     &                   OIND2 , OIND2_FX      ,
     &                   EFRIM
      NAMELIST  /NMBERY/ B1    , B2    , B3
      NAMELIST  /NMAECL/ REFCT   , RCMAX
     &                 , FLIQMIN , UCMIN
     &                 , OCCN2CLD, OCLD2CCN
      NAMELIST  /NMSNWF/ TWSNOW
      NAMELIST  /NMCLIC/ TSICE , TWICE
      NAMELIST  /NMSCAV/ FSCAV , FENTR , FSCUM ,  FSWTR
*
      !! Tuning Paarameters in CHIMERRA (Prog. Rain and Prog. Snow)
*        NOTE: The namelist variables should have "SAVE" attribution,
*              otherwise they will be choosen default value therein.
      NAMELIST  /NMPRPS/ DTMIC,
     &                   EAUT    , EACC    , EAUTI   , EAUTS   ,
     &                   QMINAUTL, QMINAUTI,
     &                   CSIAUT  , TSAUTI  ,
     &                   CSSAUT  , TSAUTS  ,
     &                   EVPR    ,
     &                   EFACRS  , EFAGG   , EFRIM   , EFRICG   ,
     &                   BFICE   , BFSNOW  , BFGRP   ,
     &                   DEPSUBI , SUBS    , DNFSUBI ,
     &                   DEPSUBG , DNFSUBG , 
     &                   ADRMLTI , THOMF   ,
     &                   VFCTR   , VFCTI   , VFCTS   , VFCTG   ,
     &                   NUC     , NUI     , NUR     , NUS     ,
     &                   MUC     , MUI     , MUR     , MUS
*
*---------------------------------------------------------------*
*     !! will be disappeared in near future in CHIMERRA framework
      DATA       B1             / 0.035D0        /
      DATA       B2             / 0.12D0         /
      DATA       B3             / 1.D-12         /
      DATA       TSICE          / 273.15D0       /
      DATA       TWICE          / 258.15D0       /
      DATA       FSCAV          / NTRX*0.D0      /
      DATA       FENTR          / NTRX*0.D0      /
      DATA       FSCUM          / NTRX*0.D0      /
      DATA       FSWTR          / NTRX*1.D0      /
*---------------------------------------------------------------*
*
      DATA       OIND2          / .TRUE.         /
      DATA       OIND2_FX       / .FALSE.        /
      DATA       OCCN2CLD       / .TRUE.         /
      DATA       OCLD2CCN       / .TRUE.         /
      DATA       UCMIN          / 2.5D7, 1.D1    /
      DATA       RCMAX          / 3.D-5, 2.D-4   /
      DATA       REFCT          / 1.1D0, 1.D0    /
      DATA       FLIQMIN        / 2.D-3          /
      DATA       TWSNOW         / 273.15D0       /
      DATA       RCFACT         / 0.D0           /
      !DATA       EFRIM          / 1.D0           /
      DATA       OFIRST         / .TRUE.         /
#ifdef OPT_PROG_CLDN
      DATA       AVOG           / 6.02214D23     /
#endif
      DATA       HCLAS          / 'SFC'          /
*
!---- PROGNOSTIC RAIN+SNOW
      DATA       QMIN           / 1.D-18         /
      DATA       MINCLD         / 1.D-4          /
      !! New Limitter (2018.08.24)
      DATA       LMTMDC         /  10.D-6,    50.D-6 /
      DATA       LMTMDI         /  10.D-6,    60.D-6 /
      DATA       LMTMDR         /  50.D-6,  2000.D-6 /
      DATA       LMTMDS         / 300.D-6,  4000.D-6 /
      DATA       LMTMDG         / 4000.D-6, 5000.D-5 /

      DATA       RHOW           / 1000.D0        /
      DATA       RHOS           / 250.D0         /
      DATA       RHOI           / 500.D0         /
      DATA       RHOWS          / 917.D0         /
      DATA       RHOG           / 900.D0         /

      DATA       EAUT           / 1.D0           /
      DATA       EACC           / 1.D0           /
      DATA       EAUTI          / 1.D0           /
      DATA       EAUTS          / 1.D0           /
      DATA       QMINAUTL       / 1.D-9          /
      DATA       QMINAUTI       / 1.D-9          /
*     size distribution parameter for cloud and rain
      DATA       B1R            / 9.65D0         /
      DATA       B2R            / 10.43D0        /
      DATA       B3R            / 600.D0         /
      DATA       SPFGA          / 19.3D0         /
      DATA       SPFGB          / 0.37D0         /
      DATA       GAMB           / 2.8875D0       /
      DATA       BETA1          / 1.23D0         /
      DATA       BETA2          / 0.22D0         /
      DATA       CSIAUT         / 150.D-6        /
      DATA       TSAUTI         / 180.D0         /
      DATA       CSSAUT         / 0.02D0         /
      DATA       TSAUTS         / 180.D0         /
      DATA       EFACRS         / 1.D0           /
      DATA       EFRICG         / 1.D0           /
      DATA       EFAGG          / 0.5D0          /
      DATA       EFRIM          / 1.D0           /
      DATA       EVPR           / 0.5D0          /
      DATA       BFICE          / 1.D0           /
      DATA       BFSNOW         / 1.D0           /
      DATA       BFGRP          / 1.D0           /
      DATA       DEPSUBI        / 1.D0           /
      DATA       SUBS           / 1.D0           /
      DATA       DNFSUBI        / 0.D0           /
      DATA       DNFSUBG        / 0.D0           /
      DATA       DEPSUBG        / 1.D0           /
      DATA       ADRMLTI        / 8.D-6          /
      DATA       THOMF          / 233.15D0       /
      DATA       VFCTR          / 1.D0           /
      DATA       VFCTI          / 1.D0           /
      DATA       VFCTS          / 1.D0           /
      DATA       VFCTG          / 1.D0           /
*     ventilation parameters (based on Khairoutdinov and Randall, 2003)
      DATA       AFR            / 0.78D0         / !! for rain
      DATA       BFR            / 0.308D0        / !! for rain
      DATA       AFS            / 0.86D0         / !! for snow
      DATA       BFS            / 0.28D0         / !! for snow
      DATA       AS             / 11.72D0        / !! snow
      DATA       BS             / 0.41D0         / !! snow
*     autoconversion and accretion schemes
#ifdef OPT_TC80
      DATA       MYU            / 1.8D-05        /
      DATA       ECR            / 0.55D0         /
      DATA       RCRIT          / 10.D-06        /
#endif
*     if MUR is 1.0, RDSD is defined as the exponential distribution,
*     and other integer 2 <= MUR < NGAM defined as modified-gamma distribution.
      DATA       NUC            / 2.D0           /
      DATA       NUI            / 1.D0           /
      DATA       NUR            / 0.3333333333333333D0   /
      DATA       NUS            / 1.D0           /
      DATA       MUC            / 1.D0           /
      DATA       MUI            / 1.D0           /
      DATA       MUR            / 5.D0           /
      DATA       MUS            / 1.D0           /
      DATA       MUG            / 1.D0           /
      DATA       DTMIC          / 120.D0         /
*     PSACR (r + s -> g) parameters (based on Gettelman, 2018)
      DATA       ECG            / 1.D0         /

*
*==============================================================================*
*    1. INITIALIZE BLOCK
*==============================================================================*
*
*    << Print Log-Messages About Scheme Configurations >>
*
      IF ( OFIRST ) THEN
         CALL REWNML( IFPAR, JFPAR )
         CALL MMGetLocalRange2( ISTS, IENS, HCLAS )
         CALL DIV_RANGE( ISTS2, IENS2, ISTS, IENS, NUM_MTASK )
         WRITE ( JFPAR,* ) ' @@@ CLDPHYS: CLOUD MICROPHYSICS 08/01/25',
     &                     ', for AGCM5.7b 2002/04/17'
         WRITE ( JFPAR,* )
     &        ' @@@ CLDPHYS: NEW MICROPHYSICS SCHEME 17/02/21 '
         WRITE ( JFPAR,* )
     &        '              Cloud/Hydrometeors Interactive Model with'
         WRITE ( JFPAR,* )
     &        '              Explicit Rain and Radiation (CHIMERRA)'
         WRITE ( JFPAR,* )
     &        ' @@@ CLDPHYS: CHIMERRA PROGNOSTIC RAIN 18/06/08'
         WRITE ( JFPAR,* )
     &        ' @@@ CLDPHYS: CHIMERRA PROGNOSTIC SNOW 18/06/08'
         WRITE ( JFPAR,* )
     &        ' @@@ CLDPHYS: CHIMERRA COUPLED TO RADIATION 18/07/20'
#ifdef OPT_SNWRAD
         WRITE ( JFPAR,* )
     &        '              --> CALCULATE RAIN+SNOW RADIATION'
#else
         WRITE ( JFPAR,* )
     &        '              --> NOT CALCULATE RAIN+SNOW RADIATION'
#endif
*
*    Warm-Rain Microphysics Scheme
#if defined(OPT_KK00)
         WRITE ( JFPAR,* )
     &        ' @@@ CLDPHYS: CHIMERRA KK00 WARMRAIN (DEFAULT) 18/06/08'
#elif defined(OPT_BE68)
         WRITE ( JFPAR,* )
     &        ' @@@ CLDPHYS: CHIMERRA Be68 WARMRAIN 19/01/16'
#elif defined(OPT_TC80)
         WRITE ( JFPAR,* )
     &        ' @@@ CLDPHYS: CHIMERRA TC80 WARMRAIN 19/01/16'
#elif defined(OPT_LD04)
         WRITE ( JFPAR,* )
     &        ' @@@ CLDPHYS: CHIMERRA LD04 WARMRAIN 19/01/16'
#elif defined(OPT_BE94)
         WRITE ( JFPAR,* )
     &        ' @@@ CLDPHYS: CHIMERRA Be94 WARMRAIN 19/01/16'
#elif defined(OPT_SB06)
         WRITE ( JFPAR,* )
     &        ' @@@ CLDPHYS: CHIMERRA SB06 WARMRAIN 19/01/16'
#elif defined(OPT_SB06NEW1)
         WRITE ( JFPAR,* )
     &        ' @@@ CLDPHYS: CHIMERRA SB06NEW1 WARMRAIN 19/04/06'
#elif defined(OPT_SB06NEW2)
         WRITE ( JFPAR,* )
     &        ' @@@ CLDPHYS: CHIMERRA SB06NEW2 WARMRAIN 19/04/06'
#elif defined(OPT_SB06NEW3)
         WRITE ( JFPAR,* )
     &        ' @@@ CLDPHYS: CHIMERRA SB06NEW3 WARMRAIN 19/04/06'
#else
         WRITE ( JFPAR,* )
     &        ' ### CLDPHYS: NOT SPECIFIED WARMRAIN SCHEME!'
         CALL XABORT( 1 )
#endif
#ifdef OPT_ACCLMT
         WRITE ( JFPAR,* )
     &        ' @@@ CLDPHYS: ACCLMT EXP. (always Pacc < Paut) 19/02/13'
#endif
#ifdef OPT_DNCAC0
         WRITE ( JFPAR,* )
     &        ' @@@ CLDPHYS: dNc|acc = 0                      19/04/07'
#endif
*
!         WRITE ( JFPAR,* ) '   --> NTRA-1= ', NTRA-1
!         WRITE ( JFPAR,* ) '   --> INC   = ', INC
!         WRITE ( JFPAR,* ) '   --> INI   = ', INI
!         WRITE ( JFPAR,* ) '   --> subtime step = ', DTMIC, "sec"
!         WRITE ( JFPAR,* ) "       ISTS,  IENS  = ", ISTS, IENS
!         WRITE ( JFPAR,* ) "       ISTS2, IENS2 = ", ISTS2, IENS2
!         WRITE ( JFPAR,* ) "       IJSDIM       = ", IJSDIM
!         WRITE ( JFPAR,* ) "       NUM_MTASK    = ", NUM_MTASK
*
#ifdef OPT_USEQVI
         WRITE ( JFPAR,* )
     &        ' @@@ CLDPHYS: USE IN-CLOUD VAPOR 08/04/22'
#endif
!         WRITE ( JFPAR,* ) '   --> IQG, IQR, IQS   = ', IQG, IQR, IQS
!         WRITE ( JFPAR,* ) '   --> ING, INR, INS   = ', ING, INR, INS
         OFIRST = .FALSE.
*
*
*    << Read Parameters From NAMELIST >>
*
         READ  ( IFPAR, NMMLSC, END=190 )
  190    WRITE ( JFPAR, NMMLSC )
         CALL REWNML( IFPAR, JFPAR )
         READ  ( IFPAR, NMBERY, END=290 )
  290    WRITE ( JFPAR, NMBERY )
         CALL REWNML( IFPAR, JFPAR )
         READ  ( IFPAR, NMAECL, END=390 )
  390    WRITE ( JFPAR, NMAECL )
         CALL REWNML( IFPAR, JFPAR )
         READ  ( IFPAR, NMCLIC, END=490 )
  490    WRITE ( JFPAR, NMCLIC )
         CALL REWNML( IFPAR, JFPAR )
         READ  ( IFPAR, NMSNWF, END=590 )
  590    WRITE ( JFPAR, NMSNWF )
         CALL REWNML( IFPAR, JFPAR )
         READ  ( IFPAR, NMSCAV, END=690 )
  690    WRITE ( JFPAR, NMSCAV )
         CALL REWNML( IFPAR, JFPAR )      !! CHIMERRA (2018.06.06) tuning params
         READ  ( IFPAR, NMPRPS, END=790 ) !! CHIMERRA (2018.06.06) tuning params
  790    WRITE ( JFPAR, NMPRPS )          !! CHIMERRA (2018.06.06) tuning params
*
         IF ( OIND2 ) THEN
            WRITE ( JFPAR,* )
     &        ' @@@ PRADT: AEROSOL 2nd INDIRECT EFFECT  04/02/23'
            IF ( OIND2_FX ) THEN
               WRITE ( JFPAR,* )
     &        '          : ===> FIXED'
            ELSE
               WRITE ( JFPAR,* )
     &        '          : ===> NOT FIXED'
            ENDIF
         ENDIF

*
*
*    << Populate Physical Constants Used in CLDPHYS >>
*
         ELF  = EL / CP
         ELFI = (EL+EMELT) / CP
         ELFM = EMELT / CP
         FTD1 = EPSV * ES0
         FTD2 = TMELT * RVAP
         FTD3 = TMELT * EL
         PI = ATAN( 1.D0 ) * 4.D0
*
         GAMM_MUI = GAMM(MUI)
         GAMM_MUR = GAMM(MUR)
         GAMM_MUS = GAMM(MUS)
         GAMM_MUG = GAMM(MUG)
         GAMM_QS = GAMM(3.D0 + MUS + BETA2) / GAMM(3.D0 + MUS)
         GAMM_NS = GAMM(MUS + BETA2) / GAMM(MUS)
         GAMM_QI = GAMM(3.D0 + MUI + BETA2) / GAMM(3.D0 + MUI)
         GAMM_NI = GAMM(MUI + BETA2) / GAMM(MUI)
         GAMM_QG = GAMM(3.D0 + MUG + BETA2) / GAMM(3.D0 + MUG)
         GAMM_NG = GAMM(MUG + BETA2) / GAMM(MUG)
         GAMM_BS3 = GAMM(BS + 3.D0)
         GAMM_BS5 = GAMM(BS / 2.D0 + 5.D0)
         WRITE ( JFPAR,* )
     &        ' @@@ CLDPHYS: INITIALIZE FINISHED!'
*
      ENDIF  !! OFIRST
*
*
*    << Reset to Initial Value >>
*
      ISTS = ISTS2( 1 )
      IENS = IENS2( NUM_MTASK )
      GTQ    = 0.D0
      GPRCL  = 0.D0
      GSNWL  = 0.D0
      FLIQOU = -999.D0
      FLIQL  = 0.D0
      FLIQAR = 0.D0
      QTD    = 0.D0  !! Q tendencies (2018.08.29)
      NTD    = 0.D0  !! N tendencies (2018.08.29)
      TTD    = 0.D0  !! T tendencies (2018.08.29)
      HBGTC1 = 0.D0
      HBGTC2 = 0.D0
      HBGTC3 = 0.D0
      HBGTC4 = 0.D0
      HBGTB  = 0.D0
      HBGTA  = 0.D0
      WBGTB  = 0.D0
      WBGTA  = 0.D0
      DQTEND = 0.D0  !! check ++
      DSEDRS = 0.D0  !! check ++
*
#ifdef OPT_SNWRAD
      RPPCL  = 0.D0     !! mean volume radii (rain and snow) for radiation [cm]
#endif
      COLCCN = 0.D0
***
      !! Prognostic Rain+Snow new process rates
      NITRMIC = MAX(1, INT( DELT / DTMIC ))  !! # of substeps for iteration
      BVR = B3R * ( B2R - 5.D0 * ( B2R - B1R ) )
      DVR = B1R / BVR
      DVQ = DVR / ( MUR + 3.D0 )
      DVN = DVR / MUR
      !! new process rates
      MI0     = (4.D0/3.D0*PI*RHOI) * ( 10.D-6)**(3.0)
      NEWRM   = (4.D0/3.D0*PI*RHOW) * ( 25.D-6)**(3.0)
      NEWSM   = (4.D0/3.D0*PI*RHOS) * (150.D-6)**(3.0)
      !! summary tendencies
      QVTEND = 0.D0
      QCTEND = 0.D0
      QITEND = 0.D0
      QRTEND = 0.D0
      QSTEND = 0.D0
      QGTEND = 0.D0
      NCTEND = 0.D0
      NITEND = 0.D0
      NRTEND = 0.D0
      NSTEND = 0.D0
      NGTEND = 0.D0
      LHTEND = 0.D0
*
      IF ( OIND2 ) THEN
*
*     aerosol number conc. ( 1/m**3 )
*
* modified on 2010/10/22 for noSPRINTARS
         IF ( OIND2_FX ) THEN
            OAERNUM_INPUT = .TRUE.
         ELSE
            OAERNUM_INPUT = .FALSE.
         ENDIF
      ENDIF
*
#ifdef OPT_PROG_CLDN
      CALL VIRTMP
     O         ( GDTV  ,
     I           GDT   , GDQ    )
#endif
*
*
*    << Fundamental Configurations, and Local Copy >>
*
      DO K = 1, KMAX
         DO IJ = ISTS, IENS
            RHO  (IJ,K) = GDP(IJ,K) / (RAIR * GDT(IJ,K))          !! atmospheric density [kg m-3]
            RDZ  (IJ,K) = ( GDPM(IJ,K)-GDPM(IJ,K+1) ) / GRAV      !! rho*dz = dp / g     [kg m-2]
            DELP (IJ,K) = GDPM(IJ,K)   - GDPM(IJ,K+1)             !! dP                  [Pa = kg m-1 s-2]
            DELZ (IJ,K) = GDZM(IJ,K+1) - GDZM(IJ,K)               !! dZ                  [m]

            GDQV(IJ,K) = GDQ(IJ,K,1)                             !! local copy [kg/kg]
            GDQC(IJ,K) = GDQ(IJ,K,ITL)                           !! local copy [kg/kg]
            GDNC(IJ,K) = GDQ(IJ,K,INC) * GDP(IJ,K) / RAIR
     &                 / GDTV(IJ,K) * AVOG / (18.D-3*RVAP/RAIR)  !! local copy (from AERCCN) [#/m3]
            GDQI(IJ,K) = GDQ(IJ,K,ITI)                           !! local copy [kg/kg]
            GDNI(IJ,K) = GDQ(IJ,K,INI) * GDP(IJ,K) / RAIR
     &                 / GDTV(IJ,K) * AVOG / (18.D-3*RVAP/RAIR)  !! local copy (from AERCCN) [#/m3]
            GDQR(IJ,K) = GDQ(IJ,K,IQR)                           !! local copy [kg/kg]
            GDNR(IJ,K) = GDQ(IJ,K,INR) * RHO(IJ,K)               !! local copy [#/m3]
            GDQS(IJ,K) = GDQ(IJ,K,IQS)                           !! local copy [kg/kg]
            GDNS(IJ,K) = GDQ(IJ,K,INS) * RHO(IJ,K)               !! local copy [#/m3]
            GDQG(IJ,K) = GDQ(IJ,K,IQG)                           !! local copy [kg/kg]
            GDNG(IJ,K) = GDQ(IJ,K,ING) * RHO(IJ,K)               !! local copy [#/m3]

            GDTL (IJ,K) = GDT (IJ,K) - ELF *GDQC(IJ,K)
     &                               - ELFI*GDQI(IJ,K)
            GDQT (IJ,K) = GDQV(IJ,K) + GDQC(IJ,K) + GDQI(IJ,K)
!            GDQT (IJ,K) = GDQV(IJ,K) + GDQC(IJ,K) + GDQI(IJ,K)
!     &                  + GDQR(IJ,K) + GDQS(IJ,K)
*
*
*    <<  Total Energy and Water Mass >>
*
            HBGTB(IJ) = HBGTB(IJ)
     &                + ( CP*GDT(IJ,K)            !! temperature
     &                  + (EL+EMELT)*GDQ(IJ,K,1)  !! water vapor
     &                  + EMELT*GDQ(IJ,K,ITL)     !! cloud water
     &                  ) * RDZ(IJ,K)

!            WBGTB(IJ) = WBGTB(IJ)
!     &                + ( GDQ(IJ,K,1)             !! water vapor
!     &                  + GDQ(IJ,K,ITL)           !! cloud water
!     &                  + GDQ(IJ,K,ITI)           !! cloud ice
!     &                  + GDQ(IJ,K,IQR)           !! rain water
!     &                  + GDQ(IJ,K,IQS)           !! snow water
!     &                  ) * RDZ(IJ,K)
            DUM1 = DELP(IJ,K)/GRAV
            WBGTB(IJ) = WBGTB(IJ)
     &                + ( GDQ(IJ,K,1)             !! water vapor
     &                  + GDQ(IJ,K,ITL)           !! cloud water
     &                  + GDQ(IJ,K,ITI)           !! cloud ice
     &                  + GDQ(IJ,K,IQR)           !! rain water
     &                  + GDQ(IJ,K,IQS)           !! snow water
     &                  ) * DUM1
         ENDDO
      ENDDO
*
*
*==============================================================================*
*    2. MACROPHYSICS BLOCK
*==============================================================================*
*
*
*     << Diagnose Cloud Water and Cloud Fraction based on a PDF Scheme >>
*
      CALL CLDDGN
     O   ( GDTX  , GDQX  , GDQC , GDCFRC , GDQXI  ,
     I     GDQ(1,1,IMU2) , GDQ(1,1,IMU3) ,
     I     GDTL  , GDQT  , GDQ(1,1,ITI)  , GDP    , 1   , KMAX ,
     I     ISTS  , IENS   )

      DO K = 1, KMAX
         DO IJ = ISTS, IENS
            GDIFRC(IJ,K) = GDCFRC(IJ,K)
     &                  * ( MAX( GDQI(IJ,K),QMIN ) /
     &                      MAX( GDQC(IJ,K)+GDQI(IJ,K),QMIN ) )
            GDCLWX(IJ,K) = GDQC(IJ,K)    !! liquid Qc for Aerosol Scheme
            QTD(IJ,K,1) = GDQC(IJ,K) - GDQ(IJ,K,ITL)
            !LHTEND(IJ,K) = LHTEND(IJ,K) + (GDTX(IJ,K)-GDT(IJ,K))  !! ++ add cloud condensation
*
*
*     << Initial Quality Check for Q and N Consistency >>
*
            !! Qc and Nc
            IF ( GDQC(IJ,K) .GT. QMIN ) THEN
               DUM1 = (6.D0*RHO(IJ,K)*GDQC(IJ,K))
     &              / (PI*RHOW*LMTMDC(1)**3.0)
               DUM2 = (6.D0*RHO(IJ,K)*GDQC(IJ,K))
     &              / (PI*RHOW*LMTMDC(2)**3.0)
               GDNC(IJ,K) = MIN( MAX( GDNC(IJ,K), DUM2 ), DUM1 )
            ELSE
               GDQC(IJ,K) = 0.D0
               GDNC(IJ,K) = 0.D0
            ENDIF

            !! Qi and Ni
            IF ( GDQI(IJ,K) .GT. QMIN ) THEN
               DUM1 = (6.D0*RHO(IJ,K)*GDQI(IJ,K))
     &              / (PI*RHOI*LMTMDI(1)**3.0)
               DUM2 = (6.D0*RHO(IJ,K)*GDQI(IJ,K))
     &              / (PI*RHOI*LMTMDI(2)**3.0)
               GDNI(IJ,K) = MIN( MAX( GDNI(IJ,K), DUM2 ), DUM1 )
            ELSE
               GDQI(IJ,K) = 0.D0
               GDNI(IJ,K) = 0.D0
            ENDIF

            !! Qr and Nr
            IF ( GDQR(IJ,K) .GT. QMIN ) THEN
               DUM1 = (6.D0*RHO(IJ,K)*GDQR(IJ,K))
     &              / (PI*RHOW*LMTMDR(1)**3.0)
               DUM2 = (6.D0*RHO(IJ,K)*GDQR(IJ,K))
     &              / (PI*RHOW*LMTMDR(2)**3.0)
               GDNR(IJ,K) = MIN( MAX( GDNR(IJ,K), DUM2 ), DUM1 )
            ELSE
               GDQR(IJ,K) = 0.D0
               GDNR(IJ,K) = 0.D0
            ENDIF

            !! Qs and Ns
            IF ( GDQS(IJ,K) .GT. QMIN ) THEN
               DUM1 = (6.D0*RHO(IJ,K)*GDQS(IJ,K))
     &              / (PI*RHOS*LMTMDS(1)**3.0)
               DUM2 = (6.D0*RHO(IJ,K)*GDQS(IJ,K))
     &              / (PI*RHOS*LMTMDS(2)**3.0)
               GDNS(IJ,K) = MIN( MAX( GDNS(IJ,K), DUM2 ), DUM1 )
            ELSE
               GDQS(IJ,K) = 0.D0
               GDNS(IJ,K) = 0.D0
            ENDIF

            !! Qg and Ng
            IF ( GDQG(IJ,K) .GT. QMIN ) THEN
               DUM1 = (6.D0*RHO(IJ,K)*GDQG(IJ,K))
     &              / (PI*RHOG*LMTMDG(1)**3.0)
               DUM2 = (6.D0*RHO(IJ,K)*GDQG(IJ,K))
     &              / (PI*RHOG*LMTMDG(2)**3.0)
               GDNG(IJ,K) = MIN( MAX( GDNG(IJ,K), DUM2 ), DUM1 )
               DUM1 = 1.D-7 * (RHO(IJ,K)*GDQG(IJ,K))/1.6D-10  ! Reisner et al. (1998) Eq.70
               DUM2 = 1.D2  * (RHO(IJ,K)*GDQG(IJ,K))/1.6D-10  ! Reisner et al. (1998) Eq.70
               GDNG(IJ,K) = MIN( MAX( GDNG(IJ,K), DUM1 ), DUM2 )
            ELSE
               GDQG(IJ,K) = 0.D0
               GDNG(IJ,K) = 0.D0
            ENDIF
*
*
*     << Instantaneous Phase Change >>
*        Note: instantaneous processes for cloud liquid and cloud ice will be
*              evaluated in the subtime step later (5. FLUX MODIFICATION BLOCK),
*              so only the precip. hydrometeors (rain and snow) are considered here.

            !! Homogeneous Cloud Droplet Freezing (Qc --> Qi, Nc --> Ni)
*              Note: assuming that the size of newly formed cloud ice due to the
*                    homogeneous nucleation will be 25 micron (mean volume radius).
            IF ( GDTX(IJ,K) .LE. THOMF .AND.
     &           GDQC(IJ,K) .GT.     0.D0 .AND.
     &           GDNC(IJ,K) .GT.     0.D0       ) THEN
               DUM1 = ELFM * GDQC(IJ,K)  !! latent heating (T increase)
               IF ( GDTX(IJ,K)+DUM1 .LE. THOMF ) THEN
                  DUM0D = 1.D0
               ELSE
                  DUM0D = -( GDTX(IJ,K)-THOMF ) / DUM1
               ENDIF
               DUM1 = ( 3.D0 * RHO(IJ,K) * DUM0D*GDQC(IJ,K) )
     &              / ( 4.D0 * PI * ((25.D-6)**3.0) * RHOI )
               !GDQC(IJ,K) = GDQC(IJ,K) - DUM0D*GDQC(IJ,K)
               !GDQI(IJ,K) = GDQI(IJ,K) + DUM0D*GDQC(IJ,K)
               DUM2 = DUM0D*GDQC(IJ,K)  !! Note: must be stored into DUM2
                                        !!       to avoid rounding error.
               DUM3 = DUM0D*GDNC(IJ,K)
               GDQC(IJ,K) = GDQC(IJ,K) - DUM2
               GDQI(IJ,K) = GDQI(IJ,K) + DUM2
               GDNC(IJ,K) = GDNC(IJ,K) - DUM3
               GDNI(IJ,K) = GDNI(IJ,K) + DUM1
               DUM1 = DUM1 / DELT
               DUM2 = DUM2 / DELT
               DUM3 = DUM3 / DELT
               QTD(IJ,K,2) = QTD(IJ,K,2) + DUM2
               NTD(IJ,K,1) = NTD(IJ,K,1) - DUM3
               NTD(IJ,K,2) = NTD(IJ,K,2) + DUM1
               QCTEND(IJ,K) = QCTEND(IJ,K) - DUM2
               QITEND(IJ,K) = QITEND(IJ,K) + DUM2
               NCTEND(IJ,K) = NCTEND(IJ,K) - DUM3
               NITEND(IJ,K) = NITEND(IJ,K) + DUM1
               !! Latent Heating Rate [K] (T increase)
               TTD(IJ,K,1) = TTD(IJ,K,1) + ( ELFM*DUM2 )
               LHTEND(IJ,K) = LHTEND(IJ,K) + ( ELFM*DUM2 )
            ENDIF

            !! Heterogeneous Cloud Droplet Nucleation (Qc --> Qi, Nc --> Ni)
            QSAT = FQSATI( GDTX(IJ,K),GDP(IJ,K) )
            IF ( GDTX (IJ,K) .LT. 263.15D0 .AND.
     &           GDQXI(IJ,K) .GT.     QSAT       ) THEN
               DUM0D = ICNHE(IJ,K)*1.D-12/RHO(IJ,K) * DELT  !! [m-3 s-1]*[kg]/[kg m-3] * [s] = [kg/kg]
               DUM0D = MIN( DUM0D,GDQC(IJ,K) )
               GDQC(IJ,K) = GDQC(IJ,K) - DUM0D
               GDQI(IJ,K) = GDQI(IJ,K) + DUM0D
               GDNC(IJ,K) = GDNC(IJ,K) - DUM0D
               GDNI(IJ,K) = GDNI(IJ,K) + DUM0D
               DUM0D = DUM0D / DELT
               QTD(IJ,K,3) = QTD(IJ,K,3) + DUM0D
               NTD(IJ,K,3) = NTD(IJ,K,3) + DUM0D
               QCTEND(IJ,K) = QCTEND(IJ,K) - DUM0D
               QITEND(IJ,K) = QITEND(IJ,K) + DUM0D
               NCTEND(IJ,K) = NCTEND(IJ,K) - DUM0D
               NITEND(IJ,K) = NITEND(IJ,K) + DUM0D
               !! Latent Heating Rate [K] (T inclease)
               TTD(IJ,K,2) = TTD(IJ,K,2) + ELFM*DUM0D
               LHTEND(IJ,K) = LHTEND(IJ,K) + ELFM*DUM0D
            ENDIF

            !! Instantaneous Snow Melting (Qs --> Qr, Ns --> Nr)
            IF ( GDTX(IJ,K) .GT. TWSNOW+2.D0  .AND.
     &           GDQS(IJ,K) .GT.        0.D0  .AND.
     &           GDNS(IJ,K) .GT.        0.D0        ) THEN
               DUM0D = ELFM * GDQS(IJ,K)  !! latent heat [K] (T decrease)
               IF ( GDTX(IJ,K)-DUM0D .GE. TWSNOW+2.D0 ) THEN
                  DUM0D = 1.D0
               ELSE
                  DUM0D = ( GDTX(IJ,K)-(TWSNOW+2.D0) ) / DUM0D
                  DUM0D = MIN( MAX(0.D0, DUM0D), 1.D0 )
               ENDIF
               DUM1 = DUM0D*GDQS(IJ,K)
               DUM2 = DUM0D*GDNS(IJ,K)
               GDQR(IJ,K) = GDQR(IJ,K) + DUM1
               GDQS(IJ,K) = GDQS(IJ,K) - DUM1
               GDNR(IJ,K) = GDNR(IJ,K) + DUM2
               GDNS(IJ,K) = GDNS(IJ,K) - DUM2
               DUM1 = DUM1 / DELT
               DUM2 = DUM2 / DELT
               QTD(IJ,K,4) = QTD(IJ,K,4) + DUM1
               NTD(IJ,K,4) = NTD(IJ,K,4) + DUM2
               QRTEND(IJ,K) = QRTEND(IJ,K) + DUM1
               QSTEND(IJ,K) = QSTEND(IJ,K) - DUM1
               NRTEND(IJ,K) = NRTEND(IJ,K) + DUM2
               NSTEND(IJ,K) = NSTEND(IJ,K) - DUM2
               !! Latent Heating Rate [K] (T decrease)
               TTD (IJ,K,3) = TTD (IJ,K,3) - ( ELFM*DUM1 )
               LHTEND(IJ,K) = LHTEND(IJ,K) - ( ELFM*DUM1 )
            ENDIF

            !! Homogeneous Rain Freezing  (Qr --> Qi or Qs, Nr --> Ni or Ns)
            IF ( GDTX(IJ,K) .LE. TWSNOW-5.D0  .AND.
     &           GDQR(IJ,K) .GT.        0.D0  .AND.
     &           GDNR(IJ,K) .GT.        0.D0        ) THEN
               DUM0D = ELFM * GDQR(IJ,K)  !! latent heat [K] (T increase)
               IF ( GDTX(IJ,K)+DUM0D .LE. TWSNOW-5.D0 ) THEN
                  DUM0D = 1.D0
               ELSE
                  DUM0D = -( GDTX(IJ,K)-(TWSNOW-5.D0) ) / DUM0D
                  DUM0D = MIN( MAX(0.D0, DUM0D), 1.D0 )
               ENDIF
               IF ( GDQR(IJ,K) .GT. QMIN  .AND.
     &              GDNR(IJ,K) .GT. 0.D0        ) THEN
                  QRAIN = GDQR(IJ,K)
                  NRAIN = GDNR(IJ,K)
                  DRMEAN = CBRT((6.D0*RHO(IJ,K)*QRAIN)/(PI*RHOW*NRAIN))
                  D0R = DRMEAN / CBRT( ((MUR+2.D0)*(MUR+1.D0)*MUR) )
                  LAMR(IJ,K) = 1.D0 / D0R
               ELSE
                  LAMR(IJ,K) = 0.D0
               ENDIF
               DUM1 = DUM0D*GDQR(IJ,K)
               DUM2 = DUM0D*GDNR(IJ,K)
               IF ( LAMR(IJ,K) .GE. 1.D0/CSIAUT ) THEN
                  !! Qr --> Qi, Nr --> Ni
                  GDQI   (IJ,K) = GDQI   (IJ,K) + DUM1
                  GDQR   (IJ,K) = GDQR   (IJ,K) - DUM1
                  GDNI   (IJ,K) = GDNI   (IJ,K) + DUM2
                  GDNR   (IJ,K) = GDNR   (IJ,K) - DUM2
                  DUM1 = DUM1 / DELT
                  DUM2 = DUM2 / DELT
                  QTD(IJ,K,5) = QTD(IJ,K,5) + DUM1
                  NTD(IJ,K,5) = NTD(IJ,K,5) + DUM2
                  QRTEND (IJ,K) = QRTEND (IJ,K) - DUM1
                  QITEND (IJ,K) = QITEND (IJ,K) + DUM1
                  NRTEND (IJ,K) = NRTEND (IJ,K) - DUM2
                  NITEND (IJ,K) = NITEND (IJ,K) + DUM2
               ELSE IF ( LAMR(IJ,K) .GE. 0.3D-8 ) THEN
                  !! Qr --> Qs, Nr --> Ns
                  GDQR   (IJ,K) = GDQR   (IJ,K) - DUM1
                  GDQS   (IJ,K) = GDQS   (IJ,K) + DUM1
                  GDNR   (IJ,K) = GDNR   (IJ,K) - DUM2
                  GDNS   (IJ,K) = GDNS   (IJ,K) + DUM2
                  DUM1 = DUM1 / DELT
                  DUM2 = DUM2 / DELT
                  QTD(IJ,K,6) = QTD(IJ,K,6) + DUM1
                  NTD(IJ,K,6) = NTD(IJ,K,6) + DUM2
                  QRTEND (IJ,K) = QRTEND (IJ,K) - DUM1
                  QSTEND (IJ,K) = QSTEND (IJ,K) + DUM1
                  NRTEND (IJ,K) = NRTEND (IJ,K) - DUM2
                  NSTEND (IJ,K) = NSTEND (IJ,K) + DUM2
               ELSE
                  !! Qr --> Qg, Nr --> Ng
                  GDQR   (IJ,K) = GDQR   (IJ,K) - DUM1
                  GDQG   (IJ,K) = GDQG   (IJ,K) + DUM1
                  GDNR   (IJ,K) = GDNR   (IJ,K) - DUM2
                  GDNG   (IJ,K) = GDNG   (IJ,K) + DUM2
                  DUM1 = DUM1 / DELT
                  DUM2 = DUM2 / DELT
                  QTD(IJ,K,31) = QTD(IJ,K,31) + DUM1
                  NTD(IJ,K,28) = NTD(IJ,K,28) + DUM2
                  QRTEND (IJ,K) = QRTEND (IJ,K) - DUM1
                  QGTEND (IJ,K) = QGTEND (IJ,K) + DUM1
                  NRTEND (IJ,K) = NRTEND (IJ,K) - DUM2
                  NGTEND (IJ,K) = NGTEND (IJ,K) + DUM2
               ENDIF
               !! Latent Heating Rate [K] (T increase)
               TTD (IJ,K,4) = TTD (IJ,K,4) + ( ELFM*DUM1 )
               LHTEND(IJ,K) = LHTEND(IJ,K) + ( ELFM*DUM1 )
            ENDIF

            !! Update Temperature due to Instantaneous Processes
            GDTX(IJ,K) = GDTX(IJ,K) + LHTEND(IJ,K)*DELT
         ENDDO
      ENDDO
*
*     << Precipitation Fraction Diagnosis >>
*
      DO IJ = ISTS, IENS
         PREFRC(IJ,KMAX) = GDCFRC(IJ,KMAX)
         SNWFRC(IJ,KMAX) = MINCLD
         !GRPFRC(IJ,KMAX) = SNWFRC(IJ,K)
         GRPFRC(IJ,KMAX) = MINCLD
      ENDDO
      DO K = KMAX - 1, 1, -1
         DO IJ = ISTS, IENS
            PREFRC(IJ,K) = MAX( GDCFRC(IJ,K), MINCLD )
            IF (GDQR(IJ,K+1)+GDQS(IJ,K+1)+GDQG(IJ,K+1) .GT. 3.D-18) THEN
               PREFRC(IJ,K) = MAX( PREFRC(IJ,K+1), PREFRC(IJ,K) )
            ENDIF
            SNWFRC(IJ,K) = PREFRC(IJ,K)
     &                   * MAX( GDQS(IJ,K), QMIN )
     &                   / MAX( GDQR(IJ,K)+GDQS(IJ,K)+GDQG(IJ,K), QMIN )
            !GRPFRC(IJ,K) = SNWFRC(IJ,K)
            GRPFRC(IJ,K) = PREFRC(IJ,K)
     &                   * MAX( GDQG(IJ,K), QMIN )
     &                   / MAX( GDQR(IJ,K)+GDQS(IJ,K)+GDQG(IJ,K), QMIN )
            IF ( GDQS(IJ,K) .LE. QMIN ) THEN
               GDQS  (IJ,K) = 0.D0
               GDNS  (IJ,K) = 0.D0
               SNWFRC(IJ,K) = 0.D0
!               GRPFRC(IJ,K) = SNWFRC(IJ,K)
            ENDIF
            IF ( GDQG(IJ,K) .LE. QMIN ) THEN
               GDQG  (IJ,K) = 0.D0
               GDNG  (IJ,K) = 0.D0
               GRPFRC(IJ,K) = 0.D0
            ENDIF
         ENDDO
      ENDDO      
*
*==============================================================================*
*    3. MICROPHYSICS BLOCK
*       NOTE: Subtime step iteration for microphysics (NITRMIC Loop) will
*             continue to the end of "5. FLUX MODIFICATION BLOCK"
*==============================================================================*
*
*     << Subtime Step Iteration for Microphysics (NITRMIC Loop) >>
*
      DO IITRMIC = 1, NITRMIC  !! main loop for microphysical subtime step
*
      DO K = KMAX, 1, -1
         DO IJ = ISTS, IENS
*
*     << Retrieve Size Parameters and Bulk Fall Velocities >>
*
            !--- Get In-Cloud Values
            SGCF  = MAX( MINCLD, GDCFRC(IJ,K) )    !! subgrid liq cld. fraction
            SGIF  = MAX( MINCLD, GDIFRC(IJ,K) )    !! subgrid ice cld. fraction
            SGPF  = MAX( MINCLD, PREFRC(IJ,K) )    !! subgrid     rain fraction
            SGSF  = MAX( MINCLD, SNWFRC(IJ,K) )    !! subgrid     snow fraction
            SGGF  = MAX( MINCLD, GRPFRC(IJ,K) )    !! subgrid  graupel fraction
            QCLDL = GDQC(IJ,K) / SGCF
            NCLDL = GDNC(IJ,K) / SGCF
            QCLDI = GDQI(IJ,K) / SGIF
            NCLDI = GDNI(IJ,K) / SGIF
            QRAIN = GDQR(IJ,K) / SGPF
            NRAIN = GDNR(IJ,K) / SGPF
            QSNOW = GDQS(IJ,K) / SGSF
            NSNOW = GDNS(IJ,K) / SGSF
            QGRPL = GDQG(IJ,K) / SGGF
            NGRPL = GDNG(IJ,K) / SGGF

            !--- Get Size Information
            !! Cloud Liquid
            IF ( QCLDL .GT. QMIN  .AND.  NCLDL .GT. 0.D0 ) THEN
               DCMEAN = CBRT( (6.D0*RHO(IJ,K)*QCLDL)/(PI*RHOW*NCLDL) )
               D0C = DCMEAN / CBRT( (MUC+2.D0)*(MUC+1.D0)*MUC )
               LAMC(IJ,K) = 1.D0 / D0C
            ELSE
               LAMC(IJ,K) = 0.D0
               QCLDL = 0.D0  ! for bug-fix (2018.08.30)
               NCLDL = 0.D0  ! for bug-fix (2018.08.30)
            ENDIF
            !! Cloud Ice
            IF ( QCLDI .GT. QMIN  .AND.  NCLDI .GT. 0.D0 ) THEN
               DIMEAN = CBRT( (6.D0*RHO(IJ,K)*QCLDI)/(PI*RHOI*NCLDI) )
               D0I = DIMEAN / CBRT( (MUI+2.D0)*(MUI+1.D0)*MUI )
               LAMI(IJ,K) = 1.D0 / D0I
               N0I = NCLDI * LAMI(IJ,K) / GAMM_MUI
            ELSE
               D0I = 0.D0
               N0I = 0.D0
               LAMI (IJ,K) = 0.D0
               QCLDI = 0.D0  ! for bug-fix (2018.08.30)
               NCLDI = 0.D0  ! for bug-fix (2018.08.30)
            ENDIF
            !! Raindrop
            IF ( QRAIN .GT. QMIN  .AND.  NRAIN .GT. 0.D0 ) THEN
               DRMEAN = CBRT( (6.D0*RHO(IJ,K)*QRAIN)/(PI*RHOW*NRAIN) )
               D0R = DRMEAN / CBRT( (MUR+2.D0)*(MUR+1.D0)*MUR )
               LAMR(IJ,K) = 1.D0 / D0R
               N0R = NRAIN * LAMR(IJ,K) / GAMM_MUR
            ELSE
               D0R = 0.D0
               N0R = 0.D0
               LAMR (IJ,K) = 0.D0
               QRAIN = 0.D0  ! for bug-fix (2018.08.30)
               NRAIN = 0.D0  ! for bug-fix (2018.08.30)
            ENDIF
            !! Snowflake
            IF ( QSNOW .GT. QMIN  .AND.  NSNOW .GT. 0.D0 ) THEN
               DSMEAN = CBRT( (6.D0*RHO(IJ,K)*QSNOW)/(PI*RHOS*NSNOW) )
               D0S = DSMEAN / CBRT( (MUS+2.D0)*(MUS+1.D0)*MUS )
               LAMS(IJ,K)  = 1.D0 / D0S
               N0S = NSNOW * LAMS(IJ,K) / GAMM_MUS
            ELSE
               D0S = 0.D0
               N0S = 0.D0
               LAMS (IJ,K) = 0.D0
               QSNOW = 0.D0  ! for bug-fix (2018.08.30)
               NSNOW = 0.D0  ! for bug-fix (2018.08.30)
            ENDIF

            !! Graupel
            IF ( QGRPL .GT. QMIN  .AND.  NGRPL .GT. 0.D0 ) THEN
               DGMEAN = CBRT( (6.D0*RHO(IJ,K)*QGRPL)/(PI*RHOG*NGRPL) )
               D0G = DGMEAN / CBRT( (MUG+2.D0)*(MUG+1.D0)*MUG )
               LAMG(IJ,K)  = 1.D0 / D0G
               N0G = NGRPL * LAMG(IJ,K) / GAMM_MUG
            ELSE
               D0G = 0.D0
               N0G = 0.D0
               LAMG (IJ,K) = 0.D0
               QGRPL = 0.D0  ! for bug-fix (2021.10.21)
               NGRPL = 0.D0  ! for bug-fix (2021.10.21)
            ENDIF

            !--- Mass/Number Weighted Fall Velocities
            !! Raindrop
            VQR(IJ,K) = ( MUR+3.D0 ) * BVR * D0R * VFCTR
            VQR(IJ,K) = MIN( MAX( 0.D0, VQR(IJ,K) ), B1R )
            VNR(IJ,K) = MUR * BVR * D0R * VFCTR
            VNR(IJ,K) = MIN( MAX( 0.D0, VNR(IJ,K) ), B1R )
            !! Snowflake
            VQS(IJ,K) = BETA1 * D0S**(BETA2) * GAMM_QS * VFCTS
            VNS(IJ,K) = BETA1 * D0S**(BETA2) * GAMM_NS * VFCTS
            !! Graupel
            VQG(IJ,K) = BETA1 * D0G**(BETA2) * GAMM_QG * VFCTG
!            VQG(IJ,K) = 2.D0 * VQS(IJ,K)
            VNG(IJ,K) = BETA1 * D0G**(BETA2) * GAMM_NG * VFCTG
!            VNG(IJ,K) = 2.D0 * VNS(IJ,K)
*
*
*     << Microphysical Process Rates >>
*
*     !--- Warm Rain Cloud Microphysics
            !! Autoconversion (Liquid): C + C -> R
#if defined(OPT_KK00)
            IF ( QCLDL .GT. QMINAUTL  .AND.  NCLDL .GT. 0.D0 ) THEN
               PQAUTL (IJ,K) = 1350.D0 * QCLDL**2.47
     &                       * (NCLDL*1.D-6)**(-1.79)
               PQAUTL (IJ,K) = PQAUTL(IJ,K) * EAUT  !! Enhancement Factor
               PNAUTLC(IJ,K) = PQAUTL(IJ,K) * NCLDL / QCLDL
               PNAUTLR(IJ,K) = PQAUTL(IJ,K) * (RHO(IJ,K)/NEWRM)
            ELSE
               PQAUTL (IJ,K) = 0.D0
               PNAUTLC(IJ,K) = 0.D0
               PNAUTLR(IJ,K) = 0.D0
            ENDIF
#elif defined(OPT_BE68)
            IF ( QCLDL .GT. QMINAUTL  .AND.  NCLDL .GT. 0.D0 ) THEN
               PQAUTL (IJ,K) = 3.5D-2 * (RHO(IJ,K)*QCLDL)**2.00
     &           / ( 1.2D-1 + (1.D-12*(NCLDL/(RHO(IJ,K)*QCLDL))) )
               PQAUTL (IJ,K) = ( PQAUTL(IJ,K)/RHO(IJ,K) ) * EAUT  !! Enhancement Factor
               PNAUTLC(IJ,K) = PQAUTL(IJ,K) * NCLDL / QCLDL
               PNAUTLR(IJ,K) = PQAUTL(IJ,K) * (RHO(IJ,K)/NEWRM)
            ELSE
               PQAUTL (IJ,K) = 0.D0
               PNAUTLC(IJ,K) = 0.D0
               PNAUTLR(IJ,K) = 0.D0
            ENDIF
#elif defined(OPT_TC80)
            IF ( QCLDL .GT. QMINAUTL  .AND.  NCLDL .GT. 0.D0 ) THEN
               QCRIT = 4.D0/3.D0 * PI * RHOW * RCRIT**3.D0 * NCLDL      !! Heaviside
               QCRIT = ( 6.2D-31 * NCLDL**3.D0 - 5.53D-22 * NCLDL**2.D0 !! Heaviside
     &               + 4.54D-13 * NCLDL + 3.71D-06 - 7.59D0/NCLDL )     !! Heaviside
               IF ( QCLDL .GE. QCRIT ) THEN                             !! Heaviside
                  PQAUTL(IJ,K) = 0.104D0*GRAV*ECR*RHO(IJ,K)**(4.D0/3.D0)
     &                         * QCLDL**(7.D0/3.D0)
     &                         / ( MYU*(NCLDL*RHOW)**(1.0/3.0) )
                  PQAUTL (IJ,K) = ( PQAUTL(IJ,K)/RHO(IJ,K) ) * EAUT  !! Enhancement Factor
                  PNAUTLC(IJ,K) = PQAUTL(IJ,K) * NCLDL / QCLDL
                  PNAUTLR(IJ,K) = PQAUTL(IJ,K) * (RHO(IJ,K)/NEWRM)
               ELSE
                  PQAUTL (IJ,K) = 0.D0
                  PNAUTLC(IJ,K) = 0.D0
                  PNAUTLR(IJ,K) = 0.D0
               ENDIF
            ELSE
               PQAUTL (IJ,K) = 0.D0
               PNAUTLC(IJ,K) = 0.D0
               PNAUTLR(IJ,K) = 0.D0
            ENDIF
#elif defined(OPT_LD04)
            IF ( QCLDL .GT. QMINAUTL  .AND.  NCLDL .GT. 0.D0 ) THEN
               R3    = ( 3.D0*RHO(IJ,K)*QCLDL/NCLDL/4.D0/PI/RHOW )
     &                 **( 1.D0/3.D0 ) * 1.D6  ! [micron]
               BETA6 = ( ( R3+3.D0 )/R3 )**(2.D0/6.D0)             !! [no dimension]
               R6    = BETA6 * R3                                  !! [micron]
               R6C   = 23.72D0/( ( RHO(IJ,K)*QCLDL*1.D3 )
     &                 **(1.D0/6.D0)*R6**(1.D0/2.D0) )             !! [micron]
               IF ( R6 .GT. R6C ) THEN
                  PQAUTL (IJ,K) = ( 3.D0/4.D0/PI/RHOW )**2.D0 * 1.9D17
     &                          * BETA6**6.D0
     &                          * ( RHO(IJ,K)*QCLDL )**3.D0/NCLDL
                  PQAUTL (IJ,K) = ( PQAUTL(IJ,K)/RHO(IJ,K) ) * EAUT  !! Enhancement Factor
                  PNAUTLC(IJ,K) = PQAUTL(IJ,K) * NCLDL / QCLDL
                  PNAUTLR(IJ,K) = PQAUTL(IJ,K) * (RHO(IJ,K)/NEWRM)
               ELSE
                  PQAUTL (IJ,K) = 0.D0
                  PNAUTLC(IJ,K) = 0.D0
                  PNAUTLR(IJ,K) = 0.D0
               ENDIF
            ELSE
               PQAUTL (IJ,K) = 0.D0
               PNAUTLC(IJ,K) = 0.D0
               PNAUTLR(IJ,K) = 0.D0
            ENDIF
#elif defined(OPT_BE94)
            IF ( QCLDL .GT. QMINAUTL  .AND.  NCLDL .GT. 0.D0 ) THEN
               ! original formula
!               NCLDL = MIN( MAX(1.D6, NCLDL), 2000.D6 )                 ! safety
!               PQAUTL (IJ,K) = 6.D28 * (RHO(IJ,K)*QCLDL*10.D-3)**4.7
!     &                       * (NCLDL*1.D-6)**(-3.3) * (9.9D0)**(-1.7)
!               PQAUTL (IJ,K) = MIN( MAX(1.D-17, PQAUTL(IJ,K)), 1.D-6 )  ! safety
!               PQAUTL (IJ,K) = ( PQAUTL(IJ,K)/RHO(IJ,K) ) * EAUT  !! Enhancement Factor
!               PNAUTLC(IJ,K) = PQAUTL(IJ,K) * NCLDL / QCLDL
!               PNAUTLR(IJ,K) = PQAUTL(IJ,K) * (RHO(IJ,K)/NEWRM)
               ! analytic formula
               DUM1 = ( (RHO(IJ,K)*QCLDL*1.D-03)**(1.D0-4.7D0)
     &                  - (1.D0-4.7D0) * 6.D25 * 9.9D0**(-1.7)
     &                    * (NCLDL*1.D-6)**(-3.3) * DTMIC )
     &              **(1.D0/(1.D0-4.7D0))
               DUM2 = ( 1.D0 - DUM1/(RHO(IJ,K)*QCLDL*1.D-03) ) / DTMIC
               DUM3 = MAX( DUM2, 4.D-13 )  ! safety
               PQAUTL (IJ,K) = QCLDL * DUM3  ! [kg/kg/s]
               PQAUTL (IJ,K) = MIN( MAX(1.D-17, PQAUTL(IJ,K)), 1.D-6 )  ! safety
               PQAUTL (IJ,K) = PQAUTL(IJ,K) * EAUT  !! Enhancement Factor
               PNAUTLC(IJ,K) = PQAUTL(IJ,K) * NCLDL / QCLDL
               PNAUTLR(IJ,K) = PQAUTL(IJ,K) * (RHO(IJ,K)/NEWRM)
            ELSE
               PQAUTL (IJ,K) = 0.D0
               PNAUTLC(IJ,K) = 0.D0
               PNAUTLR(IJ,K) = 0.D0
            ENDIF
#endif

            !! Accretion (Liquid): C + R -> R
            IF ( QCLDL .GT. QMIN  .AND.  NCLDL .GT. 0.D0 ) THEN
               PQACCL(IJ,K) = 67.D0 * (QCLDL*QRAIN)**(1.15)
               PQACCL(IJ,K) = PQACCL(IJ,K) * EACC  !! Enhancement Factor
#ifdef OPT_ACCLMT
               PQACCL(IJ,K) = MIN( PQACCL(IJ,K), PQAUTL(IJ,K) )
#endif
               PNACCL(IJ,K) = PQACCL(IJ,K) * NCLDL / QCLDL
#ifdef OPT_DNCAC0
               PNACCL(IJ,K) = 0.D0  !! dNc/dt|acc = 0.0
#endif
            ELSE
               PQACCL(IJ,K) = 0.D0
               PNACCL(IJ,K) = 0.D0
            ENDIF

#if defined(OPT_SB06)
            IF ( QCLDL .GT. QMINAUTL  .AND.  NCLDL .GT. 0.D0 ) THEN
               MASSC  = RHO(IJ,K)*QCLDL / NCLDL          !! mass of cloud droplet [kg]
               MASSCR = 4.D0/3.D0*PI*RHOW*(40.D-6)**3.0  !! mass bnd between cloud and rain assuming 40 micron 
               TAU    = QRAIN / ( QCLDL + QRAIN )
               TAU    = MIN( MAX( 1.D-5, TAU ), 0.999999D0 )
               ! Seifert and Beheng (2001)
!!               FAIAUT = 600.D0 * TAU**0.680 * ( 1.D0 - TAU**0.680 )**3.00
!!               FAIACC = ( TAU / (TAU + 5.D-4) )**4.00
               ! Seifert and Beheng (2006) update version
               FAIAUT = 400.D0 * TAU**0.700 * ( 1.D0 - TAU**0.700 )**3.00
               FAIAUT = MAX( 1.D-1, FAIAUT ) ! safety
               FAIACC = ( TAU / (TAU + 5.D-5) )**4.00
               PQAUTL (IJ,K) = ( KC / (20.D0 * MASSCR*1.D3) ) *
     &              ( (NUC+2.D0)*(NUC+4.D0)/((NUC+1.D0)**2.0) ) *
     &              ( (RHO(IJ,K)*QCLDL*1.D-3)**2.0 ) *
     &              ( ((RHO(IJ,K)*QCLDL*1.D-3)/(NCLDL*1.D-6))**2.0 )
               PQAUTL (IJ,K) = PQAUTL(IJ,K)
     &                       * ( 1.D0 + ( FAIAUT/(1.D0-TAU)**2.0 ) )
     &                       * ( 1.225D0/RHO(IJ,K) ) * 1.D3        !! [kg m-3 s-1]
               PQAUTL (IJ,K) = PQAUTL(IJ,K) / RHO(IJ,K) * EAUT     !! [kg/kg/s] with Enhancement Factor
               PQACCL (IJ,K) = KR * (RHO(IJ,K)*QCLDL*1.D-3)
     &                       * (RHO(IJ,K)*QRAIN*1.D-3) * FAIACC
               PQACCL (IJ,K) = PQACCL(IJ,K)
     &                       * ( 1.225D0/RHO(IJ,K) )**0.50 * 1.D3  !! [kg m-3 s-1]
               PQACCL (IJ,K) = PQACCL(IJ,K) / RHO(IJ,K) * EACC     !! [kg/kg/s] with Enhancement Factor
#ifdef OPT_ACCLMT
               PQACCL(IJ,K) = MIN( PQACCL(IJ,K), PQAUTL(IJ,K) )
#endif
               PNAUTLC(IJ,K) = KC * ( (NUC+2.D0)/(NUC+1.D0) )
     &                       * (RHO(IJ,K)*QCLDL*1.D-3)**2.00
               PNAUTLC(IJ,K) = PNAUTLC(IJ,K)
     &                       * ( 1.225D0/RHO(IJ,K) ) * 1.D6            !! [m-3 s-1]
               PNAUTLR(IJ,K) = (1.D0/MASSCR) * PQAUTL(IJ,K)*RHO(IJ,K)  !! [m-3 s-1]
               PNACCL (IJ,K) = (1.D0/MASSC ) * PQACCL(IJ,K)*RHO(IJ,K)  !! [m-3 s-1]
#ifdef OPT_DNCAC0
               PNACCL (IJ,K) = 0.D0  !! dNc/dt|acc = 0.0
#endif
            ELSE
               PQAUTL (IJ,K) = 0.D0
               PNAUTLC(IJ,K) = 0.D0
               PNAUTLR(IJ,K) = 0.D0
               PQACCL (IJ,K) = 0.D0
               PNACCL (IJ,K) = 0.D0
            ENDIF
#endif

#if defined(OPT_SB06NEW1)
            IF ( GDCFRC(IJ,K) .GT. MINCLD  .AND.
     &           QCLDL        .GT. 1.D-10  .AND.
     &           NCLDL        .GT. 0.D0          ) THEN
               R3    = ( 3.D0*RHO(IJ,K)*QCLDL/NCLDL/4.D0/PI/RHOW )
     &                 **( 1.D0/3.D0 ) * 1.D6  ! [micron]
               BETA6 = ( ( R3+3.D0 )/R3 )**(2.D0/6.D0)             !! [no dimension]
               R6    = BETA6 * R3                                  !! [micron]
               R6C   = 23.72D0/( ( RHO(IJ,K)*QCLDL*1.D3 )
     &                 **(1.D0/6.D0)*R6**(1.D0/2.D0) )             !! [micron]
            ELSE
               R6 = -999.D0
            ENDIF
            IF ( QCLDL .GT. QMINAUTL  .AND.
     &           NCLDL .GT. 0.D0      .AND.
     &           R6    .GT. R6C             ) THEN
               MASSC  = RHO(IJ,K)*QCLDL / NCLDL          !! mass of cloud droplet [kg]
               MASSCR = 4.D0/3.D0*PI*RHOW*(40.D-6)**3.0  !! mass bnd between cloud and rain assuming 40 micron
               TAU    = QRAIN / ( QCLDL + QRAIN )
               TAU    = MIN( MAX( 1.D-5, TAU ), 0.999999D0 )
               FAIAUT = 400.D0 * TAU**0.700 * ( 1.D0 - TAU**0.700 )**3.00
               FAIAUT = MAX( 1.D-1, FAIAUT ) ! safety
               FAIACC = ( TAU / (TAU + 5.D-5) )**4.00
               PQAUTL (IJ,K) = ( KC / (20.D0 * MASSCR*1.D3) ) *
     &              ( (NUC+2.D0)*(NUC+4.D0)/((NUC+1.D0)**2.0) ) *
     &              ( (RHO(IJ,K)*QCLDL*1.D-3)**2.0 ) *
     &              ( ((RHO(IJ,K)*QCLDL*1.D-3)/(NCLDL*1.D-6))**2.0 )
               PQAUTL (IJ,K) = PQAUTL(IJ,K)
     &                       * ( 1.D0 + ( FAIAUT/(1.D0-TAU)**2.0 ) )
     &                       * ( 1.225D0/RHO(IJ,K) ) * 1.D3        !! [kg m-3 s-1]
               PQAUTL (IJ,K) = PQAUTL(IJ,K) / RHO(IJ,K) * EAUT     !! [kg/kg/s] with Enhancement Factor
               PQACCL (IJ,K) = KR * (RHO(IJ,K)*QCLDL*1.D-3)
     &                       * (RHO(IJ,K)*QRAIN*1.D-3) * FAIACC
               PQACCL (IJ,K) = PQACCL(IJ,K)
     &                       * ( 1.225D0/RHO(IJ,K) )**0.50 * 1.D3  !! [kg m-3 s-1]
               PQACCL (IJ,K) = PQACCL(IJ,K) / RHO(IJ,K) * EACC     !! [kg/kg/s] with Enhancement Factor
#ifdef OPT_ACCLMT
               PQACCL(IJ,K) = MIN( PQACCL(IJ,K), PQAUTL(IJ,K) )
#endif
               PNAUTLC(IJ,K) = KC * ( (NUC+2.D0)/(NUC+1.D0) )
     &                       * (RHO(IJ,K)*QCLDL*1.D-3)**2.00
               PNAUTLC(IJ,K) = PNAUTLC(IJ,K)
     &                       * ( 1.225D0/RHO(IJ,K) ) * 1.D6        !! [m-3 s-1]
!               PNAUTLR(IJ,K) = (1.D0/2.D0) * (2.D0/MASSCR)
!     &                       * PQAUTL(IJ,K)*RHO(IJ,K)  !! [m-3 s-1]
               PNAUTLR(IJ,K) = (1.D0/MASSCR) * PQAUTL(IJ,K)*RHO(IJ,K) !! [m-3 s-1]
               PNACCL (IJ,K) = (1.D0/MASSC ) * PQACCL(IJ,K)*RHO(IJ,K) !! [m-3 s-1]
            ELSE
               PQAUTL (IJ,K) = 0.D0
               PNAUTLC(IJ,K) = 0.D0
               PNAUTLR(IJ,K) = 0.D0
               PQACCL (IJ,K) = 0.D0
               PNACCL (IJ,K) = 0.D0
            ENDIF
#endif

#if defined(OPT_SB06NEW2)
            IF ( GDCFRC(IJ,K) .GT. MINCLD  .AND.
     &           QCLDL        .GT. 1.D-10  .AND.
     &           NCLDL        .GT. 0.D0          ) THEN
               R3    = ( 3.D0*RHO(IJ,K)*QCLDL/NCLDL/4.D0/PI/RHOW )
     &                 **( 1.D0/3.D0 ) * 1.D6  ! [micron]
               BETA6 = ( ( R3+3.D0 )/R3 )**(2.D0/6.D0)             !! [no dimension]
               R6    = BETA6 * R3                                  !! [micron]
               R6C   = 23.72D0/( ( RHO(IJ,K)*QCLDL*1.D3 )
     &                 **(1.D0/6.D0)*R6**(1.D0/2.D0) )             !! [micron]
            ELSE
               R6 = -999.D0
            ENDIF
            IF ( QCLDL .GT. QMINAUTL  .AND.
     &           NCLDL .GT. 0.D0      .AND.
     &           R6    .GT. R6C+2.D0        ) THEN
               MASSC  = RHO(IJ,K)*QCLDL / NCLDL          !! mass of cloud droplet [kg]
               MASSCR = 4.D0/3.D0*PI*RHOW*(40.D-6)**3.0  !! mass bnd between cloud and rain assuming 40 micron
               TAU    = QRAIN / ( QCLDL + QRAIN )
               TAU    = MIN( MAX( 1.D-5, TAU ), 0.999999D0 )
               FAIAUT = 400.D0 * TAU**0.700 * ( 1.D0 - TAU**0.700 )**3.00
               FAIAUT = MAX( 1.D-1, FAIAUT ) ! safety
               FAIACC = ( TAU / (TAU + 5.D-5) )**4.00
               PQAUTL (IJ,K) = ( KC / (20.D0 * MASSCR*1.D3) ) *
     &              ( (NUC+2.D0)*(NUC+4.D0)/((NUC+1.D0)**2.0) ) *
     &              ( (RHO(IJ,K)*QCLDL*1.D-3)**2.0 ) *
     &              ( ((RHO(IJ,K)*QCLDL*1.D-3)/(NCLDL*1.D-6))**2.0 )
               PQAUTL (IJ,K) = PQAUTL(IJ,K)
     &                       * ( 1.D0 + ( FAIAUT/(1.D0-TAU)**2.0 ) )
     &                       * ( 1.225D0/RHO(IJ,K) ) * 1.D3        !! [kg m-3 s-1]
               PQAUTL (IJ,K) = PQAUTL(IJ,K) / RHO(IJ,K) * EAUT     !! [kg/kg/s] with Enhancement Factor
               PQACCL (IJ,K) = KR * (RHO(IJ,K)*QCLDL*1.D-3)
     &                       * (RHO(IJ,K)*QRAIN*1.D-3) * FAIACC
               PQACCL (IJ,K) = PQACCL(IJ,K)
     &                       * ( 1.225D0/RHO(IJ,K) )**0.50 * 1.D3  !! [kg m-3 s-1]
               PQACCL (IJ,K) = PQACCL(IJ,K) / RHO(IJ,K) * EACC     !! [kg/kg/s] with Enhancement Factor
#ifdef OPT_ACCLMT
               PQACCL(IJ,K) = MIN( PQACCL(IJ,K), PQAUTL(IJ,K) )
#endif
               PNAUTLC(IJ,K) = KC * ( (NUC+2.D0)/(NUC+1.D0) )
     &                       * (RHO(IJ,K)*QCLDL*1.D-3)**2.00
               PNAUTLC(IJ,K) = PNAUTLC(IJ,K)
     &                       * ( 1.225D0/RHO(IJ,K) ) * 1.D6        !! [m-3 s-1]
!               PNAUTLR(IJ,K) = (1.D0/2.D0) * (2.D0/MASSCR)
!     &                       * PQAUTL(IJ,K)*RHO(IJ,K)  !! [m-3 s-1]
               PNAUTLR(IJ,K) = (1.D0/MASSCR) * PQAUTL(IJ,K)*RHO(IJ,K) !! [m-3 s-1]
               PNACCL (IJ,K) = (1.D0/MASSC ) * PQACCL(IJ,K)*RHO(IJ,K) !! [m-3 s-1]
            ELSE
               PQAUTL (IJ,K) = 0.D0
               PNAUTLC(IJ,K) = 0.D0
               PNAUTLR(IJ,K) = 0.D0
               PQACCL (IJ,K) = 0.D0
               PNACCL (IJ,K) = 0.D0
            ENDIF
#endif

#if defined(OPT_SB06NEW3)
            IF ( GDCFRC(IJ,K) .GT. MINCLD  .AND.
     &           QCLDL        .GT. 1.D-10  .AND.
     &           NCLDL        .GT. 0.D0          ) THEN
               R3    = ( 3.D0*RHO(IJ,K)*QCLDL/NCLDL/4.D0/PI/RHOW )
     &                 **( 1.D0/3.D0 ) * 1.D6  ! [micron]
               BETA6 = ( ( R3+3.D0 )/R3 )**(2.D0/6.D0)             !! [no dimension]
               R6    = BETA6 * R3                                  !! [micron]
               R6C   = 23.72D0/( ( RHO(IJ,K)*QCLDL*1.D3 )
     &                 **(1.D0/6.D0)*R6**(1.D0/2.D0) )             !! [micron]
            ELSE
               R6 = -999.D0
            ENDIF
            IF ( QCLDL .GT. QMINAUTL  .AND.
     &           NCLDL .GT. 0.D0      .AND.
     &           R6    .GT. R6C+3.D0        ) THEN
               MASSC  = RHO(IJ,K)*QCLDL / NCLDL          !! mass of cloud droplet [kg]
               MASSCR = 4.D0/3.D0*PI*RHOW*(40.D-6)**3.0  !! mass bnd between cloud and rain assuming 40 micron
               TAU    = QRAIN / ( QCLDL + QRAIN )
               TAU    = MIN( MAX( 1.D-5, TAU ), 0.999999D0 )
               FAIAUT = 400.D0 * TAU**0.700 * ( 1.D0 - TAU**0.700 )**3.00
               FAIAUT = MAX( 1.D-1, FAIAUT ) ! safety
               FAIACC = ( TAU / (TAU + 5.D-5) )**4.00
               PQAUTL (IJ,K) = ( KC / (20.D0 * MASSCR*1.D3) ) *
     &              ( (NUC+2.D0)*(NUC+4.D0)/((NUC+1.D0)**2.0) ) *
     &              ( (RHO(IJ,K)*QCLDL*1.D-3)**2.0 ) *
     &              ( ((RHO(IJ,K)*QCLDL*1.D-3)/(NCLDL*1.D-6))**2.0 )
               PQAUTL (IJ,K) = PQAUTL(IJ,K)
     &                       * ( 1.D0 + ( FAIAUT/(1.D0-TAU)**2.0 ) )
     &                       * ( 1.225D0/RHO(IJ,K) ) * 1.D3        !! [kg m-3 s-1]
               PQAUTL (IJ,K) = PQAUTL(IJ,K) / RHO(IJ,K) * EAUT     !! [kg/kg/s] with Enhancement Factor
               PQACCL (IJ,K) = KR * (RHO(IJ,K)*QCLDL*1.D-3)
     &                       * (RHO(IJ,K)*QRAIN*1.D-3) * FAIACC
               PQACCL (IJ,K) = PQACCL(IJ,K)
     &                       * ( 1.225D0/RHO(IJ,K) )**0.50 * 1.D3  !! [kg m-3 s-1]
               PQACCL (IJ,K) = PQACCL(IJ,K) / RHO(IJ,K) * EACC     !! [kg/kg/s] with Enhancement Factor
#ifdef OPT_ACCLMT
               PQACCL(IJ,K) = MIN( PQACCL(IJ,K), PQAUTL(IJ,K) )
#endif
               PNAUTLC(IJ,K) = KC * ( (NUC+2.D0)/(NUC+1.D0) )
     &                       * (RHO(IJ,K)*QCLDL*1.D-3)**2.00
               PNAUTLC(IJ,K) = PNAUTLC(IJ,K)
     &                       * ( 1.225D0/RHO(IJ,K) ) * 1.D6        !! [m-3 s-1]
!               PNAUTLR(IJ,K) = (1.D0/2.D0) * (2.D0/MASSCR)
!     &                       * PQAUTL(IJ,K)*RHO(IJ,K)  !! [m-3 s-1]
               PNAUTLR(IJ,K) = (1.D0/MASSCR) * PQAUTL(IJ,K)*RHO(IJ,K) !! [m-3 s-1]
               PNACCL (IJ,K) = (1.D0/MASSC ) * PQACCL(IJ,K)*RHO(IJ,K) !! [m-3 s-1]
            ELSE
               PQAUTL (IJ,K) = 0.D0
               PNAUTLC(IJ,K) = 0.D0
               PNAUTLR(IJ,K) = 0.D0
               PQACCL (IJ,K) = 0.D0
               PNACCL (IJ,K) = 0.D0
            ENDIF
#endif

            !! Self-Collection (Liquid): R -> R
            IF ( QRAIN .GT. QMIN  .AND.  NRAIN .GT. 0.D0 ) THEN
               PNSCLL(IJ,K) = -8.D0 * NRAIN * QRAIN * RHO(IJ,K)
            ELSE
               PNSCLL(IJ,K) = 0.D0
            ENDIF

            !! Rain Evaporation: R -> V
            IF ( QRAIN       .GT. QMIN  .AND.  K .NE. KMAX  .AND.
     &           VQR(IJ,MIN(K+1,KMAX)) .GT. 0.D0                  ) THEN
               QSAT = FQSATL( GDTX(IJ,K), GDP(IJ,K) )
               DUM1 = ELF*FDQSATL( GDTX(IJ,K), QSAT  )
               DUM2 = GDQX(IJ,K) + ( (QSAT-GDQX(IJ,K))/(1.D0+DUM1) )
               DUM3 = EVPR * MAX( DUM2-GDQX(IJ,K), 0.D0 ) / VQR(IJ,K+1)
               DUM4 = MIN( DUM3, 1.D0/RDZ(IJ,K) )
               PQEVPR(IJ,K) = ( RHO(IJ,K+1)*GDQR(IJ,K+1)*VQR(IJ,K+1) )
     &                      * DUM4 / SGPF  !! [kg/kg/s] (in-cloud)
               PNEVPR(IJ,K) = ( (PQEVPR(IJ,K)*DTMIC)/QRAIN )**1.D0
     &                      * NRAIN / DTMIC
            ELSE
               PQEVPR(IJ,K) = 0.D0
               PNEVPR(IJ,K) = 0.D0
            ENDIF
*
*     !--- Cold Rain Cloud Microphysics
            !! Autoconversion (Ice): I + I -> S
            IF ( QCLDI      .GT. QMINAUTI  .AND.  !! ice autoconversion threshold
     &           GDTX(IJ,K) .LE. TMELT           ) THEN
               DRAT = LAMI(IJ,K) * CSIAUT
               PNAUTI(IJ,K) = N0I / (LAMI(IJ,K) * TSAUTI) * EXP(-DRAT)
               MICE = (RHOI * PI / 6.D0) / LAMI(IJ,K)**(3.0)
               PQAUTI(IJ,K) = EAUTI * MICE * PNAUTI(IJ,K)
     &                      * ( ((DRAT+3.D0)*DRAT + 6.D0)*DRAT + 6.D0 )
            ELSE
               PQAUTI(IJ,K) = 0.D0
               PNAUTI(IJ,K) = 0.D0
            ENDIF

            !! Accretion (Ice): C + S -> S
*              # optional Hallet-Mossop process included here
            IF ( QCLDL      .GT. QMIN  .AND.
     &           QSNOW      .GT. QMIN  .AND.
     &           GDTX(IJ,K) .LE. TMELT       ) THEN
               RHOSU = 850.D2 / (RAIR * TMELT)
               RHOF  = (RHOSU/RHO(IJ,K))**0.54
               ASN   = AS * RHOF
               VISC  = 1.496D-6 * GDTX(IJ,K)**(1.5)
     &               / (GDTX(IJ,K) + 120.D0)
               WDIST = 0.0005714D0*1.D-6*NCLDL*RHO(IJ,K) + 0.2714D0
               WDIST = 1.D0 / (WDIST*WDIST) - 1.D0
               WDIST = MAX( WDIST, 2.D0 )        !! spectral width parameter from Martine et al. (1994)
               DUM1 = (WDIST+1.D0) / LAMC(IJ,K)  !! provisional mean droplet size
               DUM2 = DUM1*DUM1*VNS(IJ,K)*RHOW*LAMS(IJ,K)/(9.D0*VISC)
               ESWAGG(IJ,K) = DUM2*DUM2/((DUM2+0.4D0)*(DUM2+0.4D0))
               ESWAGG(IJ,K) = MIN( MAX( 0.D0,ESWAGG(IJ,K) ), 1.D0 )
               DUM3  = PI / 4.D0 * ASN * RHO(IJ,K) * N0S * GAMM_BS3
     &               / LAMS(IJ,K)**(BS+3.D0)
               DUM4  = ESWAGG(IJ,K) * DUM3  !! explicit riming efficiency
               DUM4  = DUM4 * EFRIM
               PQACCCS(IJ,K) = DUM4 * QCLDL
               PNACCCS(IJ,K) = DUM4 * NCLDL
               !! Hallet-Mossop Process (based on Cotton et al., 1986):
               IF ( GDTX(IJ,K) .GE. 268.16D0  .AND.
     &              GDTX(IJ,K) .LT. 270.16D0        ) THEN
                  PNHLMI(IJ,K) = PQACCCS(IJ,K) * 3.5D8
     &                         * ( 270.16D0-GDTX(IJ,K) ) / 2.D0
               ELSEIF ( GDTX(IJ,K) .GE. 265.16D0  .AND.
     &                  GDTX(IJ,K) .LT. 268.16D0        ) THEN
                  PNHLMI(IJ,K) = PQACCCS(IJ,K) * 3.5D8
     &                         * ( GDTX(IJ,K)-265.16D0 ) / 3.D0
               ELSE
                  PNHLMI(IJ,K) = 0.D0
               ENDIF
               PQHLMI (IJ,K) = MIN( PNHLMI(IJ,K)*MI0, PQACCCS(IJ,K) )
               PQACCCS(IJ,K) = PQACCCS(IJ,K) - PQHLMI(IJ,K)
            ELSE
               ESWAGG(IJ,K) = 0.D0
               PQACCCS(IJ,K) = 0.D0
               PNACCCS(IJ,K) = 0.D0
               PQHLMI (IJ,K) = 0.D0
               PNHLMI (IJ,K) = 0.D0
            ENDIF

            !! Accretion (Ice): I + S -> S
            IF ( QCLDI      .GT. QMIN  .AND.
     &           QSNOW      .GT. QMIN  .AND.
     &           LAMI(IJ,K) .GT. 0.D0  .AND.
     &           LAMS(IJ,K) .GT. 0.D0  .AND.
     &           GDTX(IJ,K) .LE. TMELT       ) THEN
               RHOSU = 850.D2 / (RAIR * TMELT)
               RHOF  = (RHOSU/RHO(IJ,K))**0.54
               ASN   = AS * RHOF
               DUM1  = PI / 4.D0 * EFAGG * ASN * RHO(IJ,K) * N0S
     &               * GAMM_BS3 / LAMS(IJ,K)**(BS+3.D0)
               PQACCIS(IJ,K) = DUM1 * QCLDI
               PNACCIS(IJ,K) = DUM1 * NCLDI
            ELSE
               PQACCIS(IJ,K) = 0.D0
               PNACCIS(IJ,K) = 0.D0
            ENDIF

            !! Accretion (Ice): R + S -> S
            IF ( QRAIN      .GT. QMIN  .AND.
     &           QSNOW      .GT. QMIN  .AND.
     &           GDTX(IJ,K) .LE. TMELT       ) THEN
               DUM1 = PI * RHO(IJ,K) * N0R * N0S
     &              / ( LAMR(IJ,K)**3.0 * LAMS(IJ,K) )
               DUM1 = EFACRS * DUM1
               DUM2 = LAMR(IJ,K) / LAMS(IJ,K)
               PQACCRS(IJ,K) = DUM1 * PI * RHOW
     &                       * SQRT( (1.2D0*VQR(IJ,K)
     &                                - 0.95*VQS(IJ,K))**2.0
     &                               + (8.D-2*VQR(IJ,K)*VQS(IJ,K)) )
     &                       / LAMR(IJ,K)**3.0
     &                       * ( (0.5D0*DUM2 + 2.D0) * DUM2 + 5.D0 )
               PNACCRS(IJ,K) = DUM1 * 0.5D0
     &                       * SQRT( 1.7D0*(VNR(IJ,K)-VNS(IJ,K))**2.0
     &                               + 0.3D0*VNR(IJ,K)*VNS(IJ,K) )
     &                       * ( (DUM2 + 1.D0) * DUM2 + 1.D0 )
            ELSE
               PQACCRS(IJ,K) = 0.D0
               PNACCRS(IJ,K) = 0.D0
            ENDIF

            !! Self-Aggregation (Snow): S -> S
            IF ( QSNOW      .GT. QMIN  .AND.
     &           GDTX(IJ,K) .LE. TMELT       ) THEN
               RHOSU = 850.D2 / (RAIR * TMELT)
               RHOF  = (RHOSU/RHO(IJ,K))**0.54
               ASN   = AS * RHOF
               PNSAGS(IJ,K) = -1108.D0 / (4.D0*720.D0*RHOS) * ASN
     &                      * RHO(IJ,K)*QSNOW * NSNOW
     &                      * ( (QSNOW/NSNOW)
     &                          *(1.D0/(RHOS*PI)) )**( (BS-1.D0)/3.D0 )
               PNSAGS(IJ,K) = PNSAGS(IJ,K) * EFAGG
            ELSE
               PNSAGS(IJ,K)  = 0.D0
            ENDIF

            !! Cloud Ice Deposition/Sublimation: I <-> V
*              Note: including Bergeron process for ice here
            GDQVL = FQSATL( GDTX(IJ,K), GDP(IJ,K) )
            IF ( GDTX(IJ,K) .GE. TMELT ) THEN
               GDQVI = GDQVL
            ELSE
               GDQVI = FQSATI( GDTX(IJ,K), GDP(IJ,K) )
            ENDIF
            IF ( QCLDI .GT. QMIN ) THEN
               VDIF = 8.794D-5 * GDTX(IJ,K)**(1.81) / GDP(IJ,K)  !! WATER VAPOR DIFFUSION
               DUM1 = (EL+EMELT)*GDQVI / (RVAP * GDTX(IJ,K)**(2.0))
               DUM2 = 1.D0 + DUM1*ELFI  !! ab
               DUM3 = 2.D0 * PI * N0I * RHO(IJ,K) * VDIF
     &              / (LAMI(IJ,K)*LAMI(IJ,K))  !! epsi
               PQDEPI(IJ,K) = DUM3 / DUM2 * (GDQX(IJ,K)-GDQVI)
               PQDEPI(IJ,K) = PQDEPI(IJ,K) * DEPSUBI
               IF ( GDTX  (IJ,K) .LT. TMELT  .AND.
     &              PQDEPI(IJ,K) .GT.  0.D0        ) THEN
                  PQSUBI(IJ,K) = 0.D0
                  PNSUBI(IJ,K) = 0.D0
               ELSE
                  PQSUBI(IJ,K) = MAX( 0.D0, -(PQDEPI(IJ,K)) )  !! tendency is positive
                  PQDEPI(IJ,K) = 0.D0
                  PNSUBI(IJ,K) = PQSUBI(IJ,K) / GDQI(IJ,K) * NCLDI  !! in-cloud value
                  PNSUBI(IJ,K) = PNSUBI(IJ,K) * DNFSUBI  !! DNFSUBI should be 0 (dNi|subi=0)
               ENDIF
               !! Bergeron Process (Ice): C -> I
               IF ( QCLDL      .GT. QMIN  .AND.
     &              GDTX(IJ,K) .LT. TMELT       ) THEN
                  PBERGI(IJ,K) = MAX( DUM3/DUM2*(GDQVL-GDQVI), 0.D0 )
                  PBERGI(IJ,K) = PBERGI(IJ,K) * BFICE
               ELSE
                  PBERGI(IJ,K) = 0.D0
               ENDIF
            ELSE
               PQDEPI(IJ,K) = 0.D0
               PQSUBI(IJ,K) = 0.D0
               PBERGI(IJ,K) = 0.D0
               PNSUBI(IJ,K) = 0.D0
            ENDIF
            
            !! Graupel Deposition/Sublimation: G <-> V
*              Note: including Bergeron process for ice here
            GDQVL = FQSATL( GDTX(IJ,K), GDP(IJ,K) )
            IF ( GDTX(IJ,K) .GE. TMELT ) THEN
               GDQVG = GDQVL
            ELSE
               GDQVG = FQSATG( GDTX(IJ,K), GDP(IJ,K) )
            ENDIF
            IF ( QGRPL .GT. QMIN ) THEN
               VDIF = 8.794D-5 * GDTX(IJ,K)**(1.81) / GDP(IJ,K)  !! WATER VAPOR DIFFUSION
               DUM1 = (EL+EMELT)*GDQVG / (RVAP * GDTX(IJ,K)**(2.0))
               DUM2 = 1.D0 + DUM1*ELFI  !! ab
               DUM3 = 2.D0 * PI * N0G * RHO(IJ,K) * VDIF
     &              / (LAMG(IJ,K)*LAMG(IJ,K))  !! epsi
               PQDEPG(IJ,K) = DUM3 / DUM2 * (GDQX(IJ,K)-GDQVG)
               PQDEPG(IJ,K) = PQDEPG(IJ,K) * DEPSUBG
               IF ( GDTX  (IJ,K) .LT. TMELT  .AND.
     &              PQDEPG(IJ,K) .GT.  0.D0        ) THEN
                  PQSUBG(IJ,K) = 0.D0
                  PNSUBG(IJ,K) = 0.D0
               ELSE
                  PQSUBG(IJ,K) = MAX( 0.D0, -(PQDEPG(IJ,K)) )  !! tendency is positive
                  PQDEPG(IJ,K) = 0.D0
                  PNSUBG(IJ,K) = PQSUBG(IJ,K) / GDQG(IJ,K) * NGRPL  !! in-cloud value
                  PNSUBG(IJ,K) = PNSUBG(IJ,K) * DNFSUBG  !! DNFSUBG should be 0 (dNg|subi=0)
               ENDIF
               !! Bergeron Process (Graupel): C -> G
               IF ( QCLDL      .GT. QMIN  .AND.
     &              GDTX(IJ,K) .LT. TMELT       ) THEN
                  PBERGG(IJ,K) = MAX( DUM3/DUM2*(GDQVL-GDQVG), 0.D0 )
                  PBERGG(IJ,K) = PBERGG(IJ,K) * BFGRP
               ELSE
                  PBERGG(IJ,K) = 0.D0
               ENDIF
            ELSE
               PQDEPG(IJ,K) = 0.D0
               PQSUBG(IJ,K) = 0.D0
               PBERGG(IJ,K) = 0.D0
               PNSUBG(IJ,K) = 0.D0
            ENDIF

            !! Bergeron Process (Snow): C -> S
            IF ( QCLDL      .GT. QMIN  .AND.
     &           QSNOW      .GT. QMIN  .AND.
     &           LAMS(IJ,K) .GT. 0.D0  .AND.
     &           GDTX(IJ,K) .LT. TMELT       ) THEN
               RHOSU = 850.D2 / (RAIR * TMELT)
               RHOF  = (RHOSU/RHO(IJ,K))**0.54
               ASN   = AS * RHOF
               VDIF  = 8.794D-5 * GDTX(IJ,K)**(1.81) / GDP(IJ,K)
               VISC  = 1.496D-6 * GDTX(IJ,K)**(1.5)
     &               / (GDTX(IJ,K) + 120.D0)
               SCHM  = VISC / (RHO(IJ,K)*VDIF)
               DUM1  = (EL+EMELT)*GDQVI / (RVAP * GDTX(IJ,K)**(2.0))
               DUM2  = 1.D0 + DUM1*ELFI  !! ab
               DUM3  = 2.D0 * PI * N0S * RHO(IJ,K) * VDIF
     &               * ( AFS/(LAMS(IJ,K)*LAMS(IJ,K))
     &                   + BFS*(ASN*RHO(IJ,K)/VISC)**(0.5)
     &                     * SCHM**(1.0/3.0) * GAMM_BS5
     &                     / (LAMS(IJ,K)**(5.D0/2.D0 + BS/2.D0)) ) !! eps
               PBERGS(IJ,K) = DUM3 * (GDQVL-GDQVI) / DUM2
               PBERGS(IJ,K) = MAX( 0.D0, PBERGS(IJ,K) )      !! safety for positive
               PBERGS(IJ,K) = PBERGS(IJ,K) * BFSNOW
            ELSE
               PBERGS(IJ,K) = 0.D0
            ENDIF

            !! Snow Sublimation: S -> V
            IF ( QSNOW .GT. QMIN ) THEN
               GDQVI = FQSATI( GDTX(IJ,K), GDP(IJ,K) )
               RHOSU = 850.D2 / (RAIR * TMELT)
               RHOF  = (RHOSU/RHO(IJ,K))**0.54
               ASN   = AS * RHOF
               VDIF  = 8.794D-5 * GDTX(IJ,K)**(1.81) / GDP(IJ,K)
               VISC  = 1.496D-6 * GDTX(IJ,K)**(1.5)
     &               / (GDTX(IJ,K) + 120.D0)
               SCHM  = VISC / (RHO(IJ,K)*VDIF)
               DUM1  = (EL+EMELT)*GDQVI / (RVAP * GDTX(IJ,K)**(2.0))
               DUM2  = 1.D0 + DUM1*ELFI  !! ab
               DUM3  = 2.D0 * PI * N0S * RHO(IJ,K) * VDIF
     &               * ( AFS/(LAMS(IJ,K)*LAMS(IJ,K))
     &                   + BFS*(ASN*RHO(IJ,K)/VISC)**(0.5)
     &                     * SCHM**(1.0/3.0) * GAMM_BS5
     &                     / (LAMS(IJ,K)**(5.D0/2.D0 + BS/2.D0)) ) !! eps
               DUM4 = MIN( MAX( 0.D0, GDCFRC(IJ,K) ), 0.990D0 )
               DUM1 = SNWFRC(IJ,K) - DUM4
               QVCLR = ( GDQX(IJ,K)-(DUM4*GDQVL) ) / ( 1.D0 - DUM4 )
               PQSUBS(IJ,K) = - (DUM3 * (QVCLR-GDQVI) / DUM2)  !! positive tendency
               PQSUBS(IJ,K) = MAX( 0.D0, PQSUBS(IJ,K)*DUM1 )
               PQSUBS(IJ,K) = ( PQSUBS(IJ,K) / SNWFRC(IJ,K) ) * SUBS
               PNSUBS(IJ,K) = 0.D0  !! snow sublimation doesn't change Ns!
            ELSE
               PQSUBS(IJ,K) = 0.D0
               PNSUBS(IJ,K) = 0.D0
            ENDIF

            !! PSACR : R + S -> G
            IF (QSNOW .GT. QMIN .AND. NSNOW .GT. 0.D0 .AND. 
     &           QRAIN .GT. QMIN .AND. NRAIN .GT. 0.D0 .AND.
     &             VQR(IJ,K) .GT. 0.D0  .AND. 
     &             VQS(IJ,K) .GT. 0.D0  .AND. 
     &             LAMS(IJ,K) .GT. 0.D0 .AND.
     &             LAMR(IJ,K) .GT. 0.D0 .AND.
     &             N0R .GT. 0.D0        .AND.
     &             N0S .GT. 0.D0                             ) THEN
!              PQSACR(IJ,K) = (PI ** 2.0) * RHOS * ECG * RHO(IJ,K) * N0R 
!     &         * N0S / ( LAMS(IJ,K) ** 3.0 )
!     &         * ((1.2D0 * VQR(IJ,K) - 0.95D0 * VQS(IJ,K)) ** 2.0 
!     &         + 0.08D0 * VQS(IJ,K) * VQR(IJ,K)) ** 0.5
!     &         * ( 5.D0 / ( LAMR(IJ,K) * ( LAMS(IJ,K) ** 3.0 )) 
!     &         + 2.D0 / (( LAMS(IJ,K) ** 2.0 ) * ( LAMR(IJ,K) ** 2.0 ))
!     &         + 0.5D0 / ( LAMS(IJ,K) * ( LAMR(IJ,K) ** 3.0 )))
               DUM1 = (PI **2.0) * RHOS * ECG * RHO(IJ,K) * N0R 
     &               * N0S / ( LAMS(IJ,K) **3.0 )
               DUM2 =  ((1.2D0 * VQR(IJ,K) - 0.95D0 * VQS(IJ,K)) **2.0 
     &               + 0.08D0 * VQS(IJ,K) * VQR(IJ,K)) **0.5
               DUM3 =  5.D0 / ( LAMR(IJ,K) * ( LAMS(IJ,K) **3.0 )) 
     &               + 2.D0 / (( LAMS(IJ,K) **2.0 ) 
     &               * ( LAMR(IJ,K) **2.0 ))
     &               + 0.5D0 / ( LAMS(IJ,K) * ( LAMR(IJ,K) **3.0 ))
               PQSACR(IJ,K) = DUM1 * DUM2 * DUM3
               PQSACR(IJ,K) = min( PQSACR(IJ,K), 1.0D-8 )
          
               DUM1 = (4.D0 * PI *((1000.D-6)**3.0) / 3.D0) * RHOG
               PNSACR(IJ,K) = PQSACR(IJ,K) / DUM1

!               WRITE ( JFPAR,* ) 'DUM1, DUM2, DUM3 = ', DUM1, DUM2, DUM3
!               WRITE ( JFPAR,* ) 'LAMS, LAMR = ', LAMS(IJ,K), LAMR(IJ,K)
!               WRITE ( JFPAR,* ) 'N0R, N0S = ', N0R, N0S
            ELSE
               PQSACR(IJ,K) = 0.D0
               PNSACR(IJ,K) = 0.D0
            ENDIF

            !! Autoconversion (Snow): S + S -> G
            IF ( QSNOW      .GT. QMINAUTI  .AND.  !! snow autoconversion threshold
     &           GDTX(IJ,K) .LE. TMELT           ) THEN
               DRAT = LAMS(IJ,K) * CSSAUT
               PNAUTS(IJ,K) = N0S / (LAMS(IJ,K) * TSAUTS) * EXP(-DRAT)
               MSNW = (RHOS * PI / 6.D0) / LAMS(IJ,K)**(3.0)
               PQAUTS(IJ,K) = EAUTS * MSNW * PNAUTS(IJ,K)
     &                      * ( ((DRAT+3.D0)*DRAT + 6.D0)*DRAT + 6.D0 )
            ELSE
               PQAUTS(IJ,K) = 0.D0
               PNAUTS(IJ,K) = 0.D0
            ENDIF

!            !! PSACWG , NPSACWG (Conversion of rimed cloud water to graupel) : C -> G (21.11.15)
!            IF ( QCLDL .GT. QMIN .AND.
!     &           QGRPL .GT. QMIN .AND.
!     &           LAMG(IJ,K) .GT. 0.D0         ) THEN 
!               DUM1 = GAMB * ( PI / 4.D0 ) * EFRICG * SPFGA 
!     &                * QCLDL * RHO(IJ,K)
!               DUM2 = N0G / (LAMG(IJ,K) ** ( SPFGB + 3.D0 ))
!               PSACWG(IJ,K) = DUM1 * DUM2
!
!            ! check invalid?
!            IF ( PSACWG(IJ,K) .GT. 1.D-3 ) THEN
!               WRITE(JFPAR,*) '### TOO LARGE PSACWG:', K, PSACWG(IJ,K)
!            ENDIF
!            
!               DUM1 = GAMB * ( PI / 4.D0 ) * EFRICG * SPFGA 
!     &                  * NCLDL * RHO(IJ,K)
!               DUM2 = N0G / (LAMG(IJ,K) ** ( SPFGB + 3.D0 ))
!               NPSACWG(IJ,K) = DUM1 * DUM2
!            ELSE
!               PSACWG(IJ,K) = 0.D0
!               NPSACWG(IJ,K) = 0.D0
!            ENDIF
!
!            IF (PSACWG(IJ,K) .LE. QMIN) THEN
!               PSACWG(IJ,K) = 0.D0
!            ELSE
!               PSACWG(IJ,K) = PSACWG(IJ,K)
!            ENDIF
!
!            IF (NPSACWG(IJ,K) .LE. 0.D0) THEN
!               NPSACWG(IJ,K) = 0.D0
!            ELSE
!               NPSACWG(IJ,K) = NPSACWG(IJ,K)
!            ENDIF

!            WRITE ( JFPAR,* ) 'PRIMING K DUM1, DUM2 = ', K, DUM1, DUM2
!            WRITE ( JFPAR,* ) 'K,PSACWG(IJ,K) = ', K, PSACWG(IJ,K)
!            WRITE ( JFPAR,* ) 'NPSACWG K DUM1, DUM2 = ', K, DUM1, DUM2
!            WRITE ( JFPAR,* ) 'K, NPSACWG(IJ,K) = ', K, NPSACWG(IJ,K)
!            WRITE ( JFPAR,* ) 'LAMG(IJ,K) K = ', LAMG(IJ,K), K
 
            !! PSACWG , NPSACWG (Conversion of rimed cloud water to graupel) : C -> G
            IF ( QCLDL .GT. QMIN .AND.
     &           QGRPL .GT. QMIN .AND.
     &           LAMG(IJ,K) .GT. 0.D0         ) THEN
               DUM1 = GAMB * ( PI / 4.D0 ) * EFRICG * SPFGA
     &                * QCLDL * RHO(IJ,K)
               DUM2 = N0G / (LAMG(IJ,K) ** ( SPFGB + 3.D0 ))
               DUM3 = DUM1 * DUM2  ! => PSACWG(IJ,K)
               PSACWG(IJ,K) = DUM1 * DUM2
               !PSACWG(IJ,K) = 0.D0
               PSACWG(IJ,K) = MIN( MAX(0.D0, DUM3), 1.D-9 ) ! safety
               !PSACWG_X(IJ,K) = DUM3
               PSACWG_X(IJ,K) = PSACWG(IJ,K)
               DUM1 = GAMB * ( PI / 4.D0 ) * EFRICG * SPFGA * NCLDL
     &                * RHO(IJ,K)
               DUM2 = N0G / (LAMG(IJ,K) ** ( SPFGB + 3.D0 ))
               DUM4 = DUM1 * DUM2  ! => NPSACWG(IJ,K)
               NPSACWG(IJ,K) = DUM1 * DUM2 * 1.D-3
               NPSACWG(IJ,K) = MIN( MAX(0.D0, DUM4), 1.D0 ) ! safety
               !NPSACWG(IJ,K) = 0.D0
               !NPSACWG_X(IJ,K) = DUM4
               NPSACWG_X(IJ,K) = NPSACWG(IJ,K)
            ELSE
               PSACWG(IJ,K) = 0.D0
               NPSACWG(IJ,K) = 0.D0
            ENDIF
            ! check negative?
!            IF ( DUM3 .LT. 0.D0 .OR. DUM4 .LT. 0.D0 ) THEN
!               WRITE(JFPAR,*) '### NEGATIVE:', K, DUM3, DUM4
!            ENDIF
!            ! check invalid?
!            IF ( DUM3 .GT. 1.D-3 ) THEN
!               WRITE(JFPAR,*) '### TOO LARGE PSACWG:', K, DUM3, DUM4
!            ENDIF


*
*
*     << Check Negative, and Modify the Process Rates if Needed >>
*
            !! Qc Non-Negative Control
            DUM1 = ( PQAUTL(IJ,K) + PQACCL(IJ,K) + PQHLMI(IJ,K)
     &               + PQACCCS(IJ,K) + PBERGS(IJ,K) ) * GDCFRC(IJ,K)
     &             + PBERGI(IJ,K)
            DUM2 = DUM1 * DTMIC
            IF ( GDQC(IJ,K) .GE. DUM2 ) THEN
               NNFCT = 1.D0
            ELSE
               NNFCT = GDQC(IJ,K) / DUM2 * SFRE  !! avoid "round-off error"
            ENDIF
            PQAUTL (IJ,K) = PQAUTL (IJ,K) * NNFCT
            PQACCL (IJ,K) = PQACCL (IJ,K) * NNFCT
            PQHLMI (IJ,K) = PQHLMI (IJ,K) * NNFCT
            PQACCCS(IJ,K) = PQACCCS(IJ,K) * NNFCT
            PBERGS (IJ,K) = PBERGS (IJ,K) * NNFCT
            PBERGI (IJ,K) = PBERGI (IJ,K) * NNFCT

            !! Nc Non-Negative Control
            DUM1 = ( PNAUTLC(IJ,K) + PNACCL(IJ,K)
     &               + PNACCCS(IJ,K) ) * GDCFRC(IJ,K)
            DUM2 = DUM1 * DTMIC
            IF ( GDNC(IJ,K) .GE. DUM2 ) THEN
               NNFCT = 1.D0
            ELSE
               NNFCT = GDNC(IJ,K) / DUM2 * SFRE  !! avoid "round-off error"
            ENDIF
            PNAUTLC(IJ,K) = PNAUTLC(IJ,K) * NNFCT
            PNACCL (IJ,K) = PNACCL (IJ,K) * NNFCT
            PNACCCS(IJ,K) = PNACCCS(IJ,K) * NNFCT

            !! Qi Non-Negative Control
            DUM1 = -PQHLMI(IJ,K) * GDCFRC(IJ,K)
     &             + ( PQAUTI(IJ,K)+PQACCIS(IJ,K)
     &                -PQDEPI(IJ,K)+PQSUBI (IJ,K) ) * GDIFRC(IJ,K)
     &             - PBERGI(IJ,K)
            DUM2 = DUM1 * DTMIC
            IF ( GDQI(IJ,K) .GE. DUM2 ) THEN
               NNFCT = 1.D0
            ELSE
               NNFCT = GDQI(IJ,K) / DUM2 * SFRE  !! avoid "round-off error"
            ENDIF
            PQAUTI (IJ,K) = PQAUTI (IJ,K) * NNFCT
            PQACCIS(IJ,K) = PQACCIS(IJ,K) * NNFCT
            PQDEPI (IJ,K) = PQDEPI (IJ,K) * NNFCT
            PQSUBI (IJ,K) = PQSUBI (IJ,K) * NNFCT

            !! Ni Non-Negative Control
            DUM1 = -PNHLMI(IJ,K) * GDCFRC(IJ,K)
     &             + ( PNAUTI(IJ,K)+PNACCIS(IJ,K)+PNSUBI(IJ,K) )
     &               * GDIFRC(IJ,K)
            DUM2 = DUM1 * DTMIC
            IF ( GDNI(IJ,K) .GE. DUM2 ) THEN
               NNFCT = 1.D0
            ELSE
               NNFCT = GDNI(IJ,K) / DUM2 * SFRE  !! avoid "round-off error"
            ENDIF
            PNHLMI (IJ,K) = PNHLMI (IJ,K) * NNFCT
            PNAUTI (IJ,K) = PNAUTI (IJ,K) * NNFCT
            PNACCIS(IJ,K) = PNACCIS(IJ,K) * NNFCT
            PNSUBI (IJ,K) = PNSUBI (IJ,K) * NNFCT

            !! Qr Non-Negative Control
            DUM1 = ( -PQAUTL(IJ,K)-PQACCL(IJ,K) ) * GDCFRC(IJ,K)
     &               + ( PQACCRS(IJ,K) + PQEVPR(IJ,K) ) * PREFRC(IJ,K)
            DUM2 = DUM1 * DTMIC
            IF ( GDQR(IJ,K) .GE. DUM2 ) THEN
               NNFCT = 1.D0
            ELSE
               NNFCT = GDQR(IJ,K) / DUM2 * SFRE  !! avoid "round-off error"
            ENDIF
            PQACCRS(IJ,K) = PQACCRS(IJ,K) * NNFCT
            PQEVPR (IJ,K) = PQEVPR (IJ,K) * NNFCT

            !! Nr Non-Negative Control
            DUM1 = -PNAUTLR(IJ,K) * GDCFRC(IJ,K)
     &             + ( PNACCRS(IJ,K)-PNSCLL(IJ,K)+PNEVPR(IJ,K) )
     &                 * PREFRC(IJ,K)  !! note: PNSCLL is already negative
            DUM2 = DUM1 * DTMIC
            IF ( GDNR(IJ,K) .GE. DUM2 ) THEN
               NNFCT = 1.D0
            ELSE
               NNFCT = GDNR(IJ,K) / DUM2 * SFRE  !! avoid "round-off error"
            ENDIF
            PNAUTLR(IJ,K) = PNAUTLR(IJ,K) * NNFCT
            PNACCRS(IJ,K) = PNACCRS(IJ,K) * NNFCT
            PNSCLL (IJ,K) = PNSCLL (IJ,K) * NNFCT
            PNEVPR (IJ,K) = PNEVPR (IJ,K) * NNFCT

            !! Qs Non-Negative Control
            DUM1 = -( PQACCCS(IJ,K)+PBERGS(IJ,K) ) * GDCFRC(IJ,K)
     &             -( PQAUTI(IJ,K)+PQACCIS(IJ,K) ) * GDIFRC(IJ,K)
     &             -( PQACCRS(IJ,K) * PREFRC(IJ,K) )
     &             + PQSUBS(IJ,K) * SNWFRC(IJ,K)
            DUM2 = DUM1 *DTMIC
            IF ( GDQS(IJ,K) .GE. DUM2 ) THEN
               NNFCT = 1.D0
            ELSE
               NNFCT = GDQS(IJ,K) / DUM2 * SFRE  !! avoid "round-off error"
            ENDIF
            PQSUBS(IJ,K)  = PQSUBS(IJ,K) * NNFCT

            !! Ns Non-Negative Control
            DUM1 = -PNSAGS(IJ,K) * SNWFRC(IJ,K)
     &             -PNAUTI(IJ,K) * GDIFRC(IJ,K)  !! note: PNSAGS is already negative
     &             +PNSUBS(IJ,K) * SNWFRC(IJ,K)  !! note: actually, PNSUBS = 0.D0 since Ns doesn't change
            DUM2 = DUM1 * DTMIC
            IF ( GDNS(IJ,K) .GE. DUM2 ) THEN
               NNFCT = 1.D0
            ELSE
               NNFCT = GDNS(IJ,K) / DUM2 * SFRE  !! avoid "round-off error"
            ENDIF
            PNSAGS (IJ,K) = PNSAGS (IJ,K) * NNFCT
            PNAUTI (IJ,K) = PNAUTI (IJ,K) * NNFCT
            PNSUBS (IJ,K) = PNSUBS (IJ,K) * NNFCT
*
*
*     << Summary Tendencies >>
*        Note: PBERGI is already grid-mean value.
*
            !! Water Vapour
            DQVALL (IJ,K) =
     &             (    
     &               ( -PQDEPI(IJ,K) + PQSUBI(IJ,K) ) * GDIFRC(IJ,K)
     &               + PQEVPR(IJ,K) * PREFRC(IJ,K)
     &               + PQSUBS(IJ,K) * SNWFRC(IJ,K)
     &             ) * DTMIC
            QVTEND(IJ,K) = QVTEND(IJ,K) + DQVALL(IJ,K)/DTMIC

            !! Cloud Liquid
            DQCALL (IJ,K) =
     &             (
     &               ( -PQAUTL(IJ,K) - PQACCL(IJ,K) - PQHLMI(IJ,K)
     &                 -PQACCCS(IJ,K) - PBERGS(IJ,K) ) * GDCFRC(IJ,K)
     &               -PBERGI(IJ,K)
     &               -PBERGG(IJ,K)
     &             ) * DTMIC
            DNCALL (IJ,K) =
     &             (
     &               ( -PNAUTLC(IJ,K) - PNACCL(IJ,K)
     &                 -PNACCCS(IJ,K) ) * GDCFRC(IJ,K)
     &             ) * DTMIC
            QCTEND(IJ,K) = QCTEND(IJ,K) + DQCALL(IJ,K)/DTMIC
            NCTEND(IJ,K) = NCTEND(IJ,K) + DNCALL(IJ,K)/DTMIC

            !! Cloud Ice
            DQIALL (IJ,K) =
     &             (
     &               PQHLMI(IJ,K) * GDCFRC(IJ,K)
     &               + ( -PQAUTI(IJ,K) - PQACCIS(IJ,K)
     &                   +PQDEPI(IJ,K) - PQSUBI (IJ,K) ) * GDIFRC(IJ,K)
            
     &               + PBERGI(IJ,K)
     &             ) * DTMIC
            DNIALL (IJ,K) =
     &             (
     &               PNHLMI(IJ,K) * GDCFRC(IJ,K)
     &               + ( -PNAUTI(IJ,K) - PNACCIS(IJ,K) - PNSUBI(IJ,K) )
     &                 * GDIFRC(IJ,K)
     &             ) * DTMIC
            QITEND(IJ,K) = QITEND(IJ,K) + DQIALL(IJ,K)/DTMIC
            NITEND(IJ,K) = NITEND(IJ,K) + DNIALL(IJ,K)/DTMIC

            !! Rainwater
            DQRALL (IJ,K) =
     &             (
     &               ( PQAUTL(IJ,K) + PQACCL(IJ,K) ) * GDCFRC(IJ,K)
     &               + ( -PQACCRS(IJ,K) - PQEVPR(IJ,K) ) * PREFRC(IJ,K)
     &             ) * DTMIC
            DNRALL (IJ,K) =
     &             (
     &               ( PNAUTLR(IJ,K) * GDCFRC(IJ,K) )
     &               + ( -PNACCRS(IJ,K) + PNSCLL(IJ,K) - PNEVPR(IJ,K) )
     &                 * PREFRC(IJ,K)  !! note: PNSCLL is already negative
     &             ) * DTMIC
            QRTEND(IJ,K) = QRTEND(IJ,K) + DQRALL(IJ,K)/DTMIC
            NRTEND(IJ,K) = NRTEND(IJ,K) + DNRALL(IJ,K)/DTMIC

            !! Snowflake
            DQSALL (IJ,K) =
     &             (
     &               ( PQACCCS(IJ,K)+PBERGS(IJ,K) ) * GDCFRC(IJ,K)
     &               + ( PQAUTI(IJ,K) + PQACCIS(IJ,K) ) * GDIFRC(IJ,K)
     &               + PQACCRS(IJ,K) * PREFRC(IJ,K)
     &               - PQSUBS(IJ,K)  * SNWFRC(IJ,K)
     &             ) * DTMIC
            DNSALL (IJ,K) =
     &             (
     &               PNSAGS(IJ,K) * SNWFRC(IJ,K)
     &              +PNAUTI(IJ,K) * GDIFRC(IJ,K)      !! note: PNSAGS is already negative
     &              -PNSUBS(IJ,K) * SNWFRC(IJ,K)
     &             ) * DTMIC
            QSTEND(IJ,K) = QSTEND(IJ,K) + DQSALL(IJ,K)/DTMIC
            NSTEND(IJ,K) = NSTEND(IJ,K) + DNSALL(IJ,K)/DTMIC

            !! Graupel
            DQGALL (IJ,K) = 
     &             ( 
     &               PQSACR(IJ,K) * GDCFRC(IJ,K) 
!     &                + PNAUTS(IJ,K) * SNWFRC(IJ,K)
     &                + PSACWG(IJ,K) * GRPFRC(IJ,K) 
     &              ) * DTMIC
            DNGALL (IJ,K) = 
     &              ( 
     &               PNSACR(IJ,K) * GDCFRC(IJ,K) 
     &               + PNAUTS(IJ,K) * SNWFRC(IJ,K)
     &               + NPSACWG(IJ,K) * GRPFRC(IJ,K)
     &              ) * DTMIC
            
            QGTEND(IJ,K) = QGTEND(IJ,K) + DQGALL(IJ,K)/DTMIC
            NGTEND(IJ,K) = NGTEND(IJ,K) + DNGALL(IJ,K)/DTMIC

            !! Latent Heating Rate
*              Note: melting/freezing processes will be evaluated in the
*                    "5. FLUX MODIFICATION BLOCK" after calculating sedimentation flux.
*                    This is because it is considered as a "fast" process.
            
            DUM1 = ELFI * PQDEPI (IJ,K)*GDIFRC(IJ,K)  !! Qv --> Qi
     &           + ELFI * PQDEPG (IJ,K)*GRPFRC(IJ,K)  !! Qv --> Qg
     &           - ELFI * PQSUBI (IJ,K)*GDIFRC(IJ,K)  !! Qi --> Qv
     &           - ELFI * PQSUBS (IJ,K)*SNWFRC(IJ,K)  !! Qs --> Qv
     &           - ELFI * PQSUBG (IJ,K)*GRPFRC(IJ,K)  !! Qg --> Qv
     &           + ELFM * PQHLMI (IJ,K)*GDCFRC(IJ,K)  !! Qc --> Qi
*                    This is because it is considered as a "fast" process.
            
            DUM1 = ELFI * PQDEPI (IJ,K)*GDIFRC(IJ,K)  !! Qv --> Qi
     &           + ELFI * PQDEPG (IJ,K)*GRPFRC(IJ,K)  !! Qv --> Qg
     &           - ELFI * PQSUBI (IJ,K)*GDIFRC(IJ,K)  !! Qi --> Qv
     &           - ELFI * PQSUBS (IJ,K)*SNWFRC(IJ,K)  !! Qs --> Qv
     &           - ELFI * PQSUBG (IJ,K)*GRPFRC(IJ,K)  !! Qg --> Qv
     &           + ELFM * PQHLMI (IJ,K)*GDCFRC(IJ,K)  !! Qc --> Qi
     &           + ELFM * PBERGI (IJ,K)               !! Qc --> Qi (already grid-mean)
     &           + ELFM * PBERGG (IJ,K)               !! Qc --> Qg (already grid-mean)
     &           + ELFM * PQACCCS(IJ,K)*GDCFRC(IJ,K)  !! Qc --> Qs
     &           + ELFM * PBERGS (IJ,K)*GDCFRC(IJ,K)  !! Qc --> Qs
     &           - ELF  * PQEVPR (IJ,K)*PREFRC(IJ,K)  !! Qr --> Qv
            LHTEND(IJ,K) = LHTEND(IJ,K) + DUM1        !! dT/dt [K/s]
            DTEMP = DUM1 * DTMIC                      !! dT    [K]
            GDTX(IJ,K) = GDTX(IJ,K) + DTEMP

            !! for Output Tendencies
            QTD(IJ,K, 7) = QTD(IJ,K, 7) + PQAUTL (IJ,K)*SGCF
            QTD(IJ,K, 8) = QTD(IJ,K, 8) + PQACCL (IJ,K)*SGCF
            QTD(IJ,K, 9) = QTD(IJ,K, 9) + PQHLMI (IJ,K)*SGCF
            QTD(IJ,K,10) = QTD(IJ,K,10) + PQACCCS(IJ,K)*SGCF
            QTD(IJ,K,11) = QTD(IJ,K,11) + PBERGI (IJ,K)       !! already grid-mean
            QTD(IJ,K,12) = QTD(IJ,K,12) + PBERGS (IJ,K)*SGCF
            QTD(IJ,K,13) = QTD(IJ,K,13) + PQEVPR (IJ,K)*SGPF
            QTD(IJ,K,14) = QTD(IJ,K,14)
     &                   + ( PQACCL(IJ,K)/MAX(1.D-13,PQAUTL(IJ,K)) )
            QTD(IJ,K,15) = QTD(IJ,K,15) + PQDEPI (IJ,K)*SGIF
            QTD(IJ,K,16) = QTD(IJ,K,16) + PQSUBI (IJ,K)*SGIF
            QTD(IJ,K,17) = QTD(IJ,K,17) + PQAUTI (IJ,K)*SGIF
            QTD(IJ,K,18) = QTD(IJ,K,18) + PQACCIS(IJ,K)*SGIF
            QTD(IJ,K,19) = QTD(IJ,K,19) + PQACCRS(IJ,K)*SGPF
            QTD(IJ,K,20) = QTD(IJ,K,20) + PQSUBS (IJ,K)*SGSF
            QTD(IJ,K,26) = QTD(IJ,K,26) + PQSUBG (IJ,K)*SGGF
            QTD(IJ,K,27) = QTD(IJ,K,27) + PQDEPG (IJ,K)*SGGF
            QTD(IJ,K,28) = QTD(IJ,K,28) + PBERGG (IJ,K)*SGGF
            QTD(IJ,K,29) = QTD(IJ,K,29) + PQSACR (IJ,K)*SGGF
!            QTD(IJ,K,32) = QTD(IJ,K,32) + PSACWG (IJ,K)*SGGF
            QTD(IJ,K,32) = QTD(IJ,K,32) + PSACWG_X(IJ,K)*SGGF
*
            NTD(IJ,K, 7) = NTD(IJ,K, 7) + PNEVPR (IJ,K)*SGCF
            NTD(IJ,K, 8) = NTD(IJ,K, 8) + PNAUTLR(IJ,K)*SGCF
            NTD(IJ,K, 9) = NTD(IJ,K, 9) + PNAUTLC(IJ,K)*SGCF
            NTD(IJ,K,10) = NTD(IJ,K,10) + PNACCL (IJ,K)*SGCF
            NTD(IJ,K,11) = NTD(IJ,K,11) + PNSCLL (IJ,K)*SGPF
            NTD(IJ,K,12) = NTD(IJ,K,12) + PNSUBI (IJ,K)*SGIF
            NTD(IJ,K,13) = NTD(IJ,K,13) + PNAUTI (IJ,K)*SGIF
            NTD(IJ,K,14) = NTD(IJ,K,14) + PNACCCS(IJ,K)*SGCF
            NTD(IJ,K,15) = NTD(IJ,K,15) + PNHLMI (IJ,K)*SGCF
            NTD(IJ,K,16) = NTD(IJ,K,16) + PNACCIS(IJ,K)*SGIF
            NTD(IJ,K,17) = NTD(IJ,K,17) + PNACCRS(IJ,K)*SGPF
            NTD(IJ,K,18) = NTD(IJ,K,18) + PNSAGS (IJ,K)*SGSF
            NTD(IJ,K,25) = NTD(IJ,K,25) + PNSUBG (IJ,K)*SGGF
            NTD(IJ,K,26) = NTD(IJ,K,26) + PNSACR (IJ,K)*SGGF
!            NTD(IJ,K,29) = NTD(IJ,K,29) + NPSACWG(IJ,K)*SGGF
            NTD(IJ,K,29) = NTD(IJ,K,29) + NPSACWG_X(IJ,K)*SGGF
*
            TTD(IJ,K, 5) = TTD(IJ,K, 5) -  ELF*PQEVPR (IJ,K)*SGPF
            TTD(IJ,K, 6) = TTD(IJ,K, 6) - ELFI*PQSUBS (IJ,K)*SGSF
            TTD(IJ,K, 8) = TTD(IJ,K, 8) + ELFI*PQDEPI (IJ,K)*SGIF
            TTD(IJ,K, 9) = TTD(IJ,K, 9) - ELFI*PQSUBI (IJ,K)*SGIF
            TTD(IJ,K,10) = TTD(IJ,K,10) + ELFM*PBERGI (IJ,K)     !! already grid-mean
            TTD(IJ,K,11) = TTD(IJ,K,11) + ELFM*PBERGS (IJ,K)*SGCF
            TTD(IJ,K,12) = TTD(IJ,K,12) + ELFM*PQACCCS(IJ,K)*SGCF
         ENDDO
      ENDDO
*
*     << Precipitation Flux [kg m-2 s-1] >>
*
      RFLUX(:,:) = RHO(:,:) * GDQR(:,:) * VQR(:,:)  !! grid mean
      SFLUX(:,:) = RHO(:,:) * GDQS(:,:) * VQS(:,:)  !! grid mean
      GFLUX(:,:) = RHO(:,:) * GDQG(:,:) * VQG(:,:)  !! grid mean
*
*==============================================================================*
*    4. SEDIMENTATION BLOCK
*       NOTE1: IJ loop is outside and K loop is inside here, because
*              sedimentation process must be evaluated within each IJ column.
*       NOTE2: For simplified, sedimentation is applied only to rain and snow,
*              but it will be better to consider the cloud ice as well.
*       NOTE3: In the sedimentation process, the vertical CFL will be determined
*              based on "in-cloud" hydrometeors, but the tendency is calculated
*              as "grid-mean" values.
*       -----------------
*       2018.06.21      |  These notes avobe can be solved by applying
*       T.Michibata     |  "Box-Lagrangian" sedimentation scheme, which doesn't
*       added comments  |  depend upon the dt (i.e.: same dt can be applyed for
*                       |  both microphysics and sedimentation).
*                       |  Single-ice approach is one of the good methods to
*                       |  represent the continuous transition of ice-to-snow.
*                       |  These future work will help to reduce the simulation
*                       |  cost significantly.
*==============================================================================*
*
      FLXBEF(:) = 0.D0
      MSCNSV(:) = 0.D0  !! check ++
      DSEDR (:) = 0.D0  !! check ++
      DSEDI (:) = 0.D0  !! check ++
      DSEDS (:) = 0.D0  !! check ++
      DSEDG (:) = 0.D0  !! check ++
*
      DO K = KMAX, 1, -1
         DO IJ = ISTS, IENS
*
*     << Update Hydrometeors from Estimated Tendencies >>
*
*           !--- Conservation for Prognostic Tracers

            !! Mass Consevation
            GDQX(IJ,K) = GDQX(IJ,K) + DQVALL(IJ,K)
            GDQC(IJ,K) = GDQC(IJ,K) + DQCALL(IJ,K)
            GDQI(IJ,K) = GDQI(IJ,K) + DQIALL(IJ,K)
            GDQR(IJ,K) = GDQR(IJ,K) + DQRALL(IJ,K)
            GDQS(IJ,K) = GDQS(IJ,K) + DQSALL(IJ,K)
            GDQG(IJ,K) = GDQG(IJ,K) + DQGALL(IJ,K)
            !! Number Conservation
            GDNC(IJ,K) = GDNC(IJ,K) + DNCALL(IJ,K)
            GDNI(IJ,K) = GDNI(IJ,K) + DNIALL(IJ,K)
            GDNR(IJ,K) = GDNR(IJ,K) + DNRALL(IJ,K)
            GDNS(IJ,K) = GDNS(IJ,K) + DNSALL(IJ,K)
            GDNG(IJ,K) = GDNG(IJ,K) + DNGALL(IJ,K)
*
*           ++ DQTEND CHECK ++
            DQTEND(IJ) = DQTEND(IJ) +
     &                 ( DQVALL(IJ,K)
     &                  +DQCALL(IJ,K)
     &                  +DQIALL(IJ,K)
     &                  +DQRALL(IJ,K)
     &                  +DQSALL(IJ,K)
     &                  +DQGALL(IJ,K) )
            DUM1 = DELP(IJ,K)/GRAV
            FLXBEF(IJ) = FLXBEF(IJ)
     &                 + ( GDQR(IJ,K)
     &                    +GDQI(IJ,K)
     &                    +GDQS(IJ,K)
     &                    +GDQG(IJ,K)
     &                   ) * DUM1
            MSCNSV(IJ) = MSCNSV(IJ)
     &                 + ( GDQR(IJ,K)  !! rain water
     &                    +GDQI(IJ,K)  !! rain water
     &                    +GDQS(IJ,K)  !! snow water
     &                    +GDQG(IJ,K)  !! graupel water
     &                   ) * DUM1

*           !--- Bulk Fall Velocities Diagnostics Again
            SGPF  = MAX( MINCLD, PREFRC(IJ,K) )    !! subgrid     rain    fraction
            SGIF  = MAX( MINCLD, GDIFRC(IJ,K) )    !! subgrid     ice     fraction
            SGSF  = MAX( MINCLD, SNWFRC(IJ,K) )    !! subgrid     snow    fraction
            SGGF  = MAX( MINCLD, GRPFRC(IJ,K) )    !! subgrid     graupel fraction

            !! Raindrop
            QRAIN = GDQR(IJ,K)/SGPF                !! CFL is determined by "in-cloud" value
            NRAIN = MAX( MINCLD,GDNR(IJ,K)/SGPF )  !! CFL is determined by "in-cloud" value
            DRMEAN = CBRT( (6.D0*RHO(IJ,K)*QRAIN)/(PI*RHOW*NRAIN) )
            D0R = DRMEAN / CBRT( (MUR+2.D0)*(MUR+1.D0)*MUR )
            VQR(IJ,K) = ( MUR+3.D0 ) * BVR * D0R * VFCTR
            VQR(IJ,K) = MIN( MAX( 0.D0, VQR(IJ,K) ), B1R )
            VNR(IJ,K) = MUR * BVR * D0R * VFCTR
            VNR(IJ,K) = MIN( MAX( 0.D0, VNR(IJ,K) ), B1R )
            FQR(IJ,K) = GRAV * RHO(IJ,K) * VQR(IJ,K)  !! [kg m-1 s-3]
            FNR(IJ,K) = GRAV * RHO(IJ,K) * VNR(IJ,K)  !! [kg m-1 s-3]
            !! Cloud Ice
            QCLDI = GDQI(IJ,K)/SGIF                !! CFL is determined by "in-cloud" value
            NCLDI = MAX( MINCLD,GDNI(IJ,K)/SGIF )  !! CFL is determined by "in-cloud" value
            DIMEAN = CBRT( (6.D0*RHO(IJ,K)*QCLDI)/(PI*RHOI*NCLDI) )
            D0I = DIMEAN / CBRT( (MUI+2.D0)*(MUI+1.D0)*MUI )
            VQI(IJ,K) = BETA1 * D0I**(BETA2) * GAMM_QI * VFCTI
            VNI(IJ,K) = BETA1 * D0I**(BETA2) * GAMM_NI * VFCTI
            FQI(IJ,K) = GRAV * RHO(IJ,K) * VQI(IJ,K)  !! [kg m-1 s-3]
            FNI(IJ,K) = GRAV * RHO(IJ,K) * VNI(IJ,K)  !! [kg m-1 s-3]
            !! Snowflake
            QSNOW = GDQS(IJ,K)/SGSF                !! CFL is determined by "in-cloud" value
            NSNOW = MAX( MINCLD,GDNS(IJ,K)/SGSF )  !! CFL is determined by "in-cloud" value
            DSMEAN = CBRT( (6.D0*RHO(IJ,K)*QSNOW)/(PI*RHOS*NSNOW) )
            D0S = DSMEAN / CBRT( (MUS+2.D0)*(MUS+1.D0)*MUS )
            VQS(IJ,K) = BETA1 * D0S**(BETA2) * GAMM_QS * VFCTS
            VNS(IJ,K) = BETA1 * D0S**(BETA2) * GAMM_NS * VFCTS
            FQS(IJ,K) = GRAV * RHO(IJ,K) * VQS(IJ,K)  !! [kg m-1 s-3]
            FNS(IJ,K) = GRAV * RHO(IJ,K) * VNS(IJ,K)  !! [kg m-1 s-3]
            !! Graupel
            QGRPL = GDQG(IJ,K)/SGGF                !! CFL is determined by "in-cloud" value
            NGRPL = MAX( MINCLD,GDNG(IJ,K)/SGGF )  !! CFL is determined by "in-cloud" value
            DGMEAN = CBRT( (6.D0*RHO(IJ,K)*QGRPL)/(PI*RHOG*NGRPL) )
            D0G = DGMEAN / CBRT( (MUG+2.D0)*(MUG+1.D0)*MUG )
            VQG(IJ,K) = BETA1 * D0G**(BETA2) * GAMM_QG * VFCTG
!            VQG(IJ,K) = 2.D0 * VQS(IJ,K)
            VNG(IJ,K) = BETA1 * D0G**(BETA2) * GAMM_NG * VFCTG
!            VNG(IJ,K) = 2.D0 * VNS(IJ,K)
            FQG(IJ,K) = GRAV * RHO(IJ,K) * VQG(IJ,K)  !! [kg m-1 s-3]
            FNG(IJ,K) = GRAV * RHO(IJ,K) * VNG(IJ,K)  !! [kg m-1 s-3]

!            WRITE ( JFPAR,* ) 'VQG(IJ,K), VNG(IJ,K) = ', 
!     &                         VQG(IJ,K), VNG(IJ,K)
         ENDDO
      ENDDO
*
*     << Determine the # of Iteration for Sedimentation >>
*
      DUMINT1 = 1
      DUMINT2 = 1
      DO K = 1, KMAX
         DO IJ = ISTS, IENS
            DUM1 = MAX(VQR(IJ,K), VQI(IJ,K), VQS(IJ,K), VQG(IJ,K),
     &                 VNR(IJ,K), VNI(IJ,K), VNS(IJ,K), VNG(IJ,K))
            DUM2 = DUM1 / DELZ(IJ,K) * DTMIC
            DUM3 = GRAV * RHO(IJ,K) * DUM1 / DELP(IJ,K) * DTMIC

*           !--- Vertical CFL Condition
            !! Z-Cordinate System
            DUMINT1(IJ) = MAX(DUMINT1(IJ), 1 + INT(DUM2))

            !! P-Cordinate System
            DUMINT2(IJ) = MAX(DUMINT2(IJ), 1 + INT(DUM3))
         ENDDO
      ENDDO
      DO IJ = ISTS, IENS
         VCFLZ(IJ) = DTMIC / DUMINT1(IJ)
         VCFLP(IJ) = DTMIC / DUMINT2(IJ)

         NITRSED(IJ) = MAX( DUMINT1(IJ), DUMINT2(IJ) ) !! safety by double check
         DTSED(IJ) = DTMIC / NITRSED(IJ) !! dt for sedimentation

         FRSED(IJ) = 1.D0 / NITRSED(IJ)
      ENDDO
*
*     << Subtime Step Iteration for Sedimentation (NITRSED Loop) >>
*
      MAX_NITRSED = MAXVAL( NITRSED(ISTS:IENS) )
      DO IITRSED = 1, MAX_NITRSED   !! iteration for sedimentation
         DO IJ = ISTS, IENS
            RBEF(IJ) = 0.D0
            IBEF(IJ) = 0.D0
            SBEF(IJ) = 0.D0
            GBEF(IJ) = 0.D0
            RAFT(IJ) = 0.D0
            IAFT(IJ) = 0.D0
            SAFT(IJ) = 0.D0
            GAFT(IJ) = 0.D0
         ENDDO

         !! K = KMAX (at the model top)
         DO IJ = ISTS, IENS
            IF (IITRSED .GT. NITRSED(IJ)) CYCLE

            PQSEDR(IJ,KMAX) = FQR(IJ,KMAX)*GDQR(IJ,KMAX)/DELP(IJ,KMAX)  !! [kg kg-1 s-1]
            PNSEDR(IJ,KMAX) = FNR(IJ,KMAX)*GDNR(IJ,KMAX)/DELP(IJ,KMAX)  !! [m-3 s-1]
            PQSEDI(IJ,KMAX) = FQI(IJ,KMAX)*GDQI(IJ,KMAX)/DELP(IJ,KMAX)  !! [kg kg-1 s-1]
            PNSEDI(IJ,KMAX) = FNI(IJ,KMAX)*GDNI(IJ,KMAX)/DELP(IJ,KMAX)  !! [m-3 s-1]
            PQSEDS(IJ,KMAX) = FQS(IJ,KMAX)*GDQS(IJ,KMAX)/DELP(IJ,KMAX)  !! [kg kg-1 s-1]
            PNSEDS(IJ,KMAX) = FNS(IJ,KMAX)*GDNS(IJ,KMAX)/DELP(IJ,KMAX)  !! [m-3 s-1]
            PQSEDG(IJ,KMAX) = FQG(IJ,KMAX)*GDQG(IJ,KMAX)/DELP(IJ,KMAX)  !! [kg kg-1 s-1]
            PNSEDG(IJ,KMAX) = FNG(IJ,KMAX)*GDNG(IJ,KMAX)/DELP(IJ,KMAX)  !! [m-3 s-1]
            RBEF (IJ) = RBEF (IJ) + GDQR(IJ,KMAX)*DELP(IJ,KMAX)/GRAV
            IBEF (IJ) = IBEF (IJ) + GDQI(IJ,KMAX)*DELP(IJ,KMAX)/GRAV
            SBEF (IJ) = SBEF (IJ) + GDQS(IJ,KMAX)*DELP(IJ,KMAX)/GRAV
            GBEF (IJ) = GBEF (IJ) + GDQG(IJ,KMAX)*DELP(IJ,KMAX)/GRAV
            GDQR(IJ,KMAX) = GDQR(IJ,KMAX) - PQSEDR(IJ,KMAX)*DTSED(IJ)
            GDNR(IJ,KMAX) = GDNR(IJ,KMAX) - PNSEDR(IJ,KMAX)*DTSED(IJ)
            GDQI(IJ,KMAX) = GDQI(IJ,KMAX) - PQSEDI(IJ,KMAX)*DTSED(IJ)
            GDNI(IJ,KMAX) = GDNI(IJ,KMAX) - PNSEDI(IJ,KMAX)*DTSED(IJ)
            GDQS(IJ,KMAX) = GDQS(IJ,KMAX) - PQSEDS(IJ,KMAX)*DTSED(IJ)
            GDNS(IJ,KMAX) = GDNS(IJ,KMAX) - PNSEDS(IJ,KMAX)*DTSED(IJ)
            GDQG(IJ,KMAX) = GDQG(IJ,KMAX) - PQSEDG(IJ,KMAX)*DTSED(IJ)
            GDNG(IJ,KMAX) = GDNG(IJ,KMAX) - PNSEDG(IJ,KMAX)*DTSED(IJ)
            DSEDR(IJ) = DSEDR(IJ) + GDQR(IJ,KMAX)*DELP(IJ,KMAX)/GRAV  !! kg m-2 (tmp ++)
            DSEDI(IJ) = DSEDI(IJ) + GDQI(IJ,KMAX)*DELP(IJ,KMAX)/GRAV  !! kg m-2 (tmp ++)
            DSEDS(IJ) = DSEDS(IJ) + GDQS(IJ,KMAX)*DELP(IJ,KMAX)/GRAV  !! kg m-2 (tmp ++)
            DSEDG(IJ) = DSEDG(IJ) + GDQG(IJ,KMAX)*DELP(IJ,KMAX)/GRAV  !! kg m-2 (tmp ++)
            RAFT (IJ) = RAFT (IJ) + GDQR(IJ,KMAX)*DELP(IJ,KMAX)/GRAV
            IAFT (IJ) = IAFT (IJ) + GDQI(IJ,KMAX)*DELP(IJ,KMAX)/GRAV
            SAFT (IJ) = SAFT (IJ) + GDQS(IJ,KMAX)*DELP(IJ,KMAX)/GRAV
            GAFT (IJ) = GAFT (IJ) + GDQG(IJ,KMAX)*DELP(IJ,KMAX)/GRAV
            
         ENDDO
         !! 1 < K < KMAX-1
         DO K = KMAX-1, 1, -1
            DO IJ = ISTS, IENS
               IF (IITRSED .GT. NITRSED(IJ)) CYCLE

               PQSEDR(IJ,K) = ( (FQR(IJ,K+1)*GDQR(IJ,K+1))
     &                         -(FQR(IJ,K)  *GDQR(IJ,K)) ) / DELP(IJ,K) !! [kg kg-1 s-1]
               PNSEDR(IJ,K) = ( (FNR(IJ,K+1)*GDNR(IJ,K+1))
     &                         -(FNR(IJ,K)  *GDNR(IJ,K)) ) / DELP(IJ,K) !! [m-3 s-1]
               PQSEDI(IJ,K) = ( (FQI(IJ,K+1)*GDQI(IJ,K+1))
     &                         -(FQI(IJ,K)  *GDQI(IJ,K)) ) / DELP(IJ,K) !! [kg kg-1 s-1]
               PNSEDI(IJ,K) = ( (FNI(IJ,K+1)*GDNI(IJ,K+1))
     &                         -(FNI(IJ,K)  *GDNI(IJ,K)) ) / DELP(IJ,K) !! [m-3 s-1]
               PQSEDS(IJ,K) = ( (FQS(IJ,K+1)*GDQS(IJ,K+1))
     &                         -(FQS(IJ,K)  *GDQS(IJ,K)) ) / DELP(IJ,K) !! [kg kg-1 s-1]
               PNSEDS(IJ,K) = ( (FNS(IJ,K+1)*GDNS(IJ,K+1))
     &                         -(FNS(IJ,K)  *GDNS(IJ,K)) ) / DELP(IJ,K) !! [m-3 s-1]
               PQSEDG(IJ,K) = ( (FQG(IJ,K+1)*GDQG(IJ,K+1))
     &                         -(FQG(IJ,K)  *GDQG(IJ,K)) ) / DELP(IJ,K) !! [kg kg-1 s-1]
               PNSEDG(IJ,K) = ( (FNG(IJ,K+1)*GDNG(IJ,K+1))
     &                         -(FNG(IJ,K)  *GDNG(IJ,K)) ) / DELP(IJ,K) !! [m-3 s-1]
               !! Update Tracers
               DUM1 = DELP(IJ,K)/GRAV
               RBEF (IJ) = RBEF (IJ) + GDQR(IJ,K)*DUM1
               IBEF (IJ) = IBEF (IJ) + GDQI(IJ,K)*DUM1
               SBEF (IJ) = SBEF (IJ) + GDQS(IJ,K)*DUM1
               GBEF (IJ) = GBEF (IJ) + GDQG(IJ,K)*DUM1
               GDQR(IJ,K) = GDQR(IJ,K) + PQSEDR(IJ,K)*DTSED(IJ)
               GDNR(IJ,K) = GDNR(IJ,K) + PNSEDR(IJ,K)*DTSED(IJ)
               GDQI(IJ,K) = GDQI(IJ,K) + PQSEDI(IJ,K)*DTSED(IJ)
               GDNI(IJ,K) = GDNI(IJ,K) + PNSEDI(IJ,K)*DTSED(IJ)
               GDQS(IJ,K) = GDQS(IJ,K) + PQSEDS(IJ,K)*DTSED(IJ)
               GDNS(IJ,K) = GDNS(IJ,K) + PNSEDS(IJ,K)*DTSED(IJ)
               GDQG(IJ,K) = GDQG(IJ,K) + PQSEDG(IJ,K)*DTSED(IJ)
               GDNG(IJ,K) = GDNG(IJ,K) + PNSEDG(IJ,K)*DTSED(IJ)
               DSEDR(IJ) = DSEDR(IJ) + GDQR(IJ,K)*DUM1  !! kg m-2 (tmp ++)
               DSEDI(IJ) = DSEDI(IJ) + GDQI(IJ,K)*DUM1  !! kg m-2 (tmp ++)
               DSEDS(IJ) = DSEDS(IJ) + GDQS(IJ,K)*DUM1  !! kg m-2 (tmp ++)
               DSEDG(IJ) = DSEDG(IJ) + GDQG(IJ,K)*DUM1  !! kg m-2 (tmp ++)
               RAFT (IJ) = RAFT (IJ) + GDQR(IJ,K)*DUM1
               IAFT (IJ) = IAFT (IJ) + GDQI(IJ,K)*DUM1
               SAFT (IJ) = SAFT (IJ) + GDQS(IJ,K)*DUM1
               GAFT (IJ) = GAFT (IJ) + GDQG(IJ,K)*DUM1

               !! for Output Tendencies
               DUM1 = PQSEDR(IJ,K) * FRSED(IJ)
               DUM2 = PNSEDR(IJ,K) * FRSED(IJ)
               DUM3 = PQSEDS(IJ,K) * FRSED(IJ)
               DUM4 = PNSEDS(IJ,K) * FRSED(IJ)
               DUM5 = PQSEDG(IJ,K) * FRSED(IJ)
               DUM6 = PNSEDG(IJ,K) * FRSED(IJ)
               QTD(IJ,K,21) = QTD(IJ,K,21) + DUM1
               QTD(IJ,K,22) = QTD(IJ,K,22) + DUM3
               QTD(IJ,K,25) = QTD(IJ,K,25) + DUM5
               NTD(IJ,K,19) = NTD(IJ,K,19) + DUM2
               NTD(IJ,K,20) = NTD(IJ,K,20) + DUM4
               NTD(IJ,K,24) = NTD(IJ,K,24) + DUM6
               QRTEND(IJ,K) = QRTEND(IJ,K) + DUM1
               NRTEND(IJ,K) = NRTEND(IJ,K) + DUM2
               QSTEND(IJ,K) = QSTEND(IJ,K) + DUM3
               NSTEND(IJ,K) = NSTEND(IJ,K) + DUM4
               QGTEND(IJ,K) = QGTEND(IJ,K) + DUM5
               NGTEND(IJ,K) = NGTEND(IJ,K) + DUM6
                 !! add cloud ice (2018.07.08)
               DUM1 = PQSEDI(IJ,K) * FRSED(IJ)
               DUM2 = PNSEDI(IJ,K) * FRSED(IJ)
               QTD(IJ,K,23) = QTD(IJ,K,23) + DUM1
               NTD(IJ,K,21) = NTD(IJ,K,21) + DUM2
               QITEND(IJ,K) = QITEND(IJ,K) + DUM1
               NITEND(IJ,K) = NITEND(IJ,K) + DUM2
            ENDDO
         ENDDO

         DO IJ = ISTS, IENS
            IF (IITRSED .GT. NITRSED(IJ)) CYCLE

            !! Add Sedimentation Flux at K=1 into Surface Precipitation Flux
            !! to promise the mass conservation!
            DUM4 = 1.D0 * NITRSED(IJ) * NITRMIC  !! # of total subtime-step iteration
            DUM1 = FQR(IJ,1) * GDQR(IJ,1) / GRAV / DUM4  !! [kg m-2 s-1]
            DUM2 = FQS(IJ,1) * GDQS(IJ,1) / GRAV / DUM4  !! [kg m-2 s-1]
            DUM2 = DUM2 + FQI(IJ,1) * GDQI(IJ,1) / GRAV / DUM4  !! [kg m-2 s-1]
            DUM3 = ( DUM1 + DUM2 ) * DTSED(IJ)                    !! [kg m-2]
            GPRCL(IJ,1) = GPRCL(IJ,1) + MAX( 0.D0,DUM1 )  !! [kg m-2 s-1]
            GSNWL(IJ  ) = GSNWL(IJ  ) + MAX( 0.D0,DUM2 )  !! [kg m-2 s-1] add cloud ice
         ENDDO
      ENDDO  !! NITRSED: iteration for sedimentation
*
*     Inbalance Check ++
*
      FLXAFT = 0.D0
      DO K = KMAX, 1, -1
         DO IJ = ISTS, IENS
            DUM1 = DELP(IJ,K)/GRAV
            FLXAFT(IJ) = FLXAFT(IJ)
     &                 + ( GDQR(IJ,K)+GDQI(IJ,K)+GDQS(IJ,K)+GDQG(IJ,K) ) * DUM1
         ENDDO
      ENDDO
      DO IJ = ISTS, IENS
         DWATER(IJ) = FLXAFT(IJ) - FLXBEF(IJ)  !! changes in INTEGRAL[ RHO*(Qr+Qs) ]dp
         DSEDRS(IJ) = DSEDRS(IJ) + DWATER(IJ)  !! kg m-2 (integrate over microphys)
      ENDDO
*
*==============================================================================*
*    5. FLUX MODIFICATION BLOCK
*==============================================================================*
*
      DO K = KMAX, 1, -1
         DO IJ = ISTS, IENS
*
*     << Instantaneous Phase Change >>
*
            DTEMP = 0.D0  !! dT during DTMIC due to instantaneous phase change

            !! Instantaneous Melting (Qi and Qs --> Qc or Qr, Ni and Ns --> Nc or Nr)
            !! Cloud Ice Melting (Qi --> Qc, Ni --> Nc)
*              Note: assuming that the size of newly formed cloud droplet due to
*                    the melting of ice crystals will be 8 micron (mean volume radius).
            !! Instantaneous Melting (Qg --> Qr) 

            IF ( GDTX(IJ,K) .GT. TWSNOW  .AND.
     &           GDQI(IJ,K) .GT.   0.D0  .AND.
     &           GDNI(IJ,K) .GT.   0.D0        ) THEN
               DUM0D = ELFM * GDQI(IJ,K)  !! latent heat [K] (T decrease)
               IF ( GDTX(IJ,K)-DUM0D .GE. TWSNOW ) THEN
                  DUM0D = 1.D0
               ELSE
                  DUM0D = ( GDTX(IJ,K)-TWSNOW ) / DUM0D
                  DUM0D = MIN( MAX(0.D0, DUM0D), 1.D0 )
               ENDIF
               DUM1 = DUM0D*GDQI(IJ,K)
               DUM2 = DUM0D*GDNI(IJ,K)
               DUM3 = ( 3.D0 * RHO(IJ,K) * DUM0D*GDQI(IJ,K) )
     &              / ( 4.D0 * PI * ((ADRMLTI)**3.0) * RHOW )
               GDQC(IJ,K) = GDQC(IJ,K) + DUM1
               GDQI(IJ,K) = GDQI(IJ,K) - DUM1
               GDNC(IJ,K) = GDNC(IJ,K) + DUM3
               GDNI(IJ,K) = GDNI(IJ,K) - DUM2
               DUM1 = DUM1 / DTMIC
               DUM2 = DUM2 / DTMIC
               DUM3 = DUM3 / DTMIC
               QTD(IJ,K,24) = QTD(IJ,K,24) + DUM1
               NTD(IJ,K,22) = NTD(IJ,K,22) + DUM3
               NTD(IJ,K,23) = NTD(IJ,K,23) - DUM2
               QCTEND(IJ,K) = QCTEND(IJ,K) + DUM1
               QITEND(IJ,K) = QITEND(IJ,K) - DUM1
               NCTEND(IJ,K) = NCTEND(IJ,K) + DUM3
               NITEND(IJ,K) = NITEND(IJ,K) - DUM2
               !! Latent Heating Rate [K] (T decrease)
               TTD (IJ,K,7) = TTD (IJ,K,7) - ( ELFM*DUM1 )
               LHTEND(IJ,K) = LHTEND(IJ,K) - ( ELFM*DUM1 )
               DTEMP = DTEMP - ( ELFM*DUM1*DTMIC )
            ENDIF

            !! Snowflake Melting (Qs --> Qr, Ns --> Nr)
            IF ( GDTX(IJ,K) .GT. TWSNOW+2.D0  .AND.
     &           GDQS(IJ,K) .GT.        0.D0  .AND.
     &           GDNS(IJ,K) .GT.        0.D0        ) THEN
               DUM0D = ELFM * GDQS(IJ,K)  !! latent heat [K] (T decrease)
               IF ( GDTX(IJ,K)-DUM0D .GE. TWSNOW+2.D0 ) THEN
                  DUM0D = 1.D0
               ELSE
                  DUM0D = ( GDTX(IJ,K)-(TWSNOW+2.D0) ) / DUM0D
                  DUM0D = MIN( MAX(0.D0, DUM0D), 1.D0 )
               ENDIF
               DUM1 = DUM0D*GDQS(IJ,K)
               DUM2 = DUM0D*GDNS(IJ,K)
               GDQR(IJ,K) = GDQR(IJ,K) + DUM1
               GDQS(IJ,K) = GDQS(IJ,K) - DUM1
               GDNR(IJ,K) = GDNR(IJ,K) + DUM2
               GDNS(IJ,K) = GDNS(IJ,K) - DUM2
               DUM1 = DUM1 / DTMIC
               DUM2 = DUM2 / DTMIC
               QTD(IJ,K,4) = QTD(IJ,K,4) + DUM1
               NTD(IJ,K,4) = NTD(IJ,K,4) + DUM2
               QRTEND (IJ,K) = QRTEND (IJ,K) + DUM1
               QSTEND (IJ,K) = QSTEND (IJ,K) - DUM1
               NRTEND (IJ,K) = NRTEND (IJ,K) + DUM2
               NSTEND (IJ,K) = NSTEND (IJ,K) - DUM2
               !! Latent Heating Rate [K] (T decrease)
               TTD (IJ,K,3) = TTD (IJ,K,3) - ( ELFM*DUM1 )
               LHTEND(IJ,K) = LHTEND(IJ,K) - ( ELFM*DUM1 )
               DTEMP = DTEMP - ( ELFM*DUM1*DTMIC )
            ENDIF

            !! Graupel Melting (Qg --> Qr, Ng --> Nr)
            IF ( GDTX(IJ,K) .GT. TWSNOW+2.D0  .AND.
     &           GDQG(IJ,K) .GT.        0.D0  .AND.
     &           GDNG(IJ,K) .GT.        0.D0        ) THEN
               DUM0D = ELFM * GDQG(IJ,K)  !! latent heat [K] (T decrease)
               IF ( GDTX(IJ,K)-DUM0D .GE. TWSNOW+2.D0 ) THEN
                  DUM0D = 1.D0
               ELSE
                  DUM0D = ( GDTX(IJ,K)-(TWSNOW+2.D0) ) / DUM0D
                  DUM0D = MIN( MAX(0.D0, DUM0D), 1.D0 )
               ENDIF
               DUM1 = DUM0D*GDQG(IJ,K)
               DUM2 = DUM0D*GDNG(IJ,K)
               GDQR(IJ,K) = GDQR(IJ,K) + DUM1
               GDQG(IJ,K) = GDQG(IJ,K) - DUM1
               GDNR(IJ,K) = GDNR(IJ,K) + DUM2
               GDNG(IJ,K) = GDNG(IJ,K) - DUM2
               DUM1 = DUM1 / DTMIC
               DUM2 = DUM2 / DTMIC
               QTD(IJ,K,30) = QTD(IJ,K,30) + DUM1
               NTD(IJ,K,27) = NTD(IJ,K,27) + DUM2
               QRTEND (IJ,K) = QRTEND (IJ,K) + DUM1
               QGTEND (IJ,K) = QGTEND (IJ,K) - DUM1
               NRTEND (IJ,K) = NRTEND (IJ,K) + DUM2
               NGTEND (IJ,K) = NGTEND (IJ,K) - DUM2
               !! Latent Heating Rate [K] (T decrease)
               TTD (IJ,K,13) = TTD (IJ,K,13) - ( ELFM*DUM1 )
               LHTEND(IJ,K) = LHTEND(IJ,K) - ( ELFM*DUM1 )
               DTEMP = DTEMP - ( ELFM*DUM1*DTMIC )
            ENDIF

            !! Homogeneous Freezing  (Qc and Qr --> Qi or Qs, Nc and Nr --> Ni or Ns)
*              Note: Conversion of Freezed Rain into Cloud Ice or Snowflake depends upon
*                    the Raindrop Mean Size with Threshold of CSIAUT (default=150um).
            IF ( GDTX(IJ,K) .LE. TWSNOW-5.D0  .AND.
     &           GDQR(IJ,K) .GT.        0.D0  .AND.
     &           GDNR(IJ,K) .GT.        0.D0        ) THEN
               DUM0D = ELFM * GDQR(IJ,K)  !! latent heat [K] (T increase)
               IF ( GDTX(IJ,K)+DUM0D .LE. TWSNOW-5.D0 ) THEN
                  DUM0D = 1.D0
               ELSE
                  DUM0D = -( GDTX(IJ,K)-(TWSNOW-5.D0) ) / DUM0D
                  DUM0D = MIN( MAX(0.D0, DUM0D), 1.D0 )
               ENDIF
               DUM1 = DUM0D*GDQR(IJ,K)
               DUM2 = DUM0D*GDNR(IJ,K)
               IF ( QRAIN .GT. QMIN  .AND.  NRAIN .GT. 0.D0 ) THEN
                  DRMEAN = CBRT((6.D0*RHO(IJ,K)*QRAIN)/(PI*RHOW*NRAIN))
                  D0R = DRMEAN / CBRT( (MUR+2.D0)*(MUR+1.D0)*MUR )
                  LAMR(IJ,K) = 1.D0 / D0R
               ELSE
                  LAMR(IJ,K) = 0.D0
               ENDIF
               IF ( QSNOW .GT. QMIN  .AND.  NSNOW .GT. 0.D0 ) THEN
                  DSMEAN = CBRT((6.D0*RHO(IJ,K)*QSNOW)/(PI*RHOS*NSNOW))
                  D0S = DSMEAN / CBRT( (MUS+2.D0)*(MUS+1.D0)*MUS )
                  LAMS(IJ,K) = 1.D0 / D0S
               ELSE
                  LAMS(IJ,K) = 0.D0
               ENDIF
               IF ( LAMR(IJ,K) .GE. 1.D0/CSIAUT ) THEN
                  !! Qr --> Qi, Nr --> Ni
                  GDQI   (IJ,K) = GDQI   (IJ,K) + DUM1
                  GDQR   (IJ,K) = GDQR   (IJ,K) - DUM1
                  GDNI   (IJ,K) = GDNI   (IJ,K) + DUM2
                  GDNR   (IJ,K) = GDNR   (IJ,K) - DUM2
                  DUM1 = DUM1 / DTMIC
                  DUM2 = DUM2 / DTMIC
                  QTD(IJ,K,5) = QTD(IJ,K,5) + DUM1
                  NTD(IJ,K,5) = NTD(IJ,K,5) + DUM2
                  QRTEND (IJ,K) = QRTEND (IJ,K) - DUM1
                  QITEND (IJ,K) = QITEND (IJ,K) + DUM1
                  NRTEND (IJ,K) = NRTEND (IJ,K) - DUM2
                  NITEND (IJ,K) = NITEND (IJ,K) + DUM2
               ELSE IF ( LAMR(IJ,K) .GE. 0.3D-8 ) THEN
                  !! Qr --> Qs, Nr --> Ns
                  GDQS   (IJ,K) = GDQS   (IJ,K) + DUM1
                  GDQR   (IJ,K) = GDQR   (IJ,K) - DUM1
                  GDNS   (IJ,K) = GDNS   (IJ,K) + DUM2
                  GDNR   (IJ,K) = GDNR   (IJ,K) - DUM2
                  DUM1 = DUM1 / DTMIC
                  DUM2 = DUM2 / DTMIC
                  QTD(IJ,K,6) = QTD(IJ,K,6) + DUM1
                  NTD(IJ,K,6) = NTD(IJ,K,6) + DUM2
                  QRTEND (IJ,K) = QRTEND (IJ,K) - DUM1
                  QSTEND (IJ,K) = QSTEND (IJ,K) + DUM1
                  NRTEND (IJ,K) = NRTEND (IJ,K) - DUM2
                  NSTEND (IJ,K) = NSTEND (IJ,K) + DUM2
               ELSE
                  !! Qr --> Qg, Nr --> Ng
                  GDQR   (IJ,K) = GDQR   (IJ,K) - DUM1
                  GDQG   (IJ,K) = GDQG   (IJ,K) + DUM1
                  GDNR   (IJ,K) = GDNR   (IJ,K) - DUM2
                  GDNG   (IJ,K) = GDNG   (IJ,K) + DUM2
                  DUM1 = DUM1 / DELT
                  DUM2 = DUM2 / DELT
                  QTD(IJ,K,31) = QTD(IJ,K,31) + DUM1
                  NTD(IJ,K,28) = NTD(IJ,K,28) + DUM2
                  QRTEND (IJ,K) = QRTEND (IJ,K) - DUM1
                  QGTEND (IJ,K) = QGTEND (IJ,K) + DUM1
                  NRTEND (IJ,K) = NRTEND (IJ,K) - DUM2
                  NGTEND (IJ,K) = NGTEND (IJ,K) + DUM2
               ENDIF
               !! Latent Heating Rate [K] (T increase)
               TTD (IJ,K,4) = TTD (IJ,K,4) + ( ELFM*DUM1 )
               LHTEND(IJ,K) = LHTEND(IJ,K) + ( ELFM*DUM1 )
               DTEMP = DTEMP + ( ELFM*DUM1*DTMIC )
            ENDIF
            

            !! Update Temperature due to Instantaneous Processes (during DTMIC)
            GDTX(IJ,K) = GDTX(IJ,K) + DTEMP
*
*
*     << Update Subgrid Fraction >>
*
            !! Update Cloud Fraction
            GDIFRC(IJ,K) = GDCFRC(IJ,K)
     &                   * ( MAX( GDQI(IJ,K),QMIN ) /
     &                       MAX( GDQC(IJ,K)+GDQI(IJ,K),QMIN ) )
         ENDDO
      ENDDO

      DO K = KMAX, 1, -1
         DO IJ = ISTS, IENS
            !! Update Precipitation Fraction
            PREFRC(IJ,K) = GDCFRC(IJ,K)  !! initialize
            SNWFRC(IJ,K) = MINCLD        !! initialize
            !GRPFRC(IJ,K) = SNWFRC(IJ,K)
            GRPFRC(IJ,K) = MINCLD
            IF ( K .NE. KMAX ) THEN
               PREFRC(IJ,K) = MAX( PREFRC(IJ,K), MINCLD )  !! for safety
               IF (GDQR(IJ,K+1)+GDQS(IJ,K+1)+GDQG(IJ,K+1).GT.3.D-18)THEN
                  PREFRC(IJ,K) = MAX( PREFRC(IJ,K+1), PREFRC(IJ,K) )
               ENDIF
               SNWFRC(IJ,K) = PREFRC(IJ,K)
     &                      * MAX( GDQS(IJ,K),QMIN )
     &                      / MAX(GDQR(IJ,K)+GDQS(IJ,K)+GDQG(IJ,K),QMIN)
               !GRPFRC(IJ,K) = SNWFRC(IJ,K)
               GRPFRC(IJ,K) = PREFRC(IJ,K)
     &           * MAX( GDQG(IJ,K),QMIN )
     &           / MAX( GDQR(IJ,K)+GDQS(IJ,K)+GDQG(IJ,K),QMIN )
            ENDIF

*
*
*     << Consistency Check for Mass and Number Concentrations >>
*
            !! Update Nc
            IF ( GDQC(IJ,K) .LT. QMIN ) THEN
               GDQC(IJ,K) = 0.D0
               GDNC(IJ,K) = 0.D0
            ENDIF
            !! Update Ni
            IF ( GDQI(IJ,K) .LT. QMIN ) THEN
               GDQI(IJ,K) = 0.D0
               GDNI(IJ,K) = 0.D0
            ENDIF
            !! Update Nr
            IF ( GDQR(IJ,K) .LT. QMIN ) THEN
               GDQR(IJ,K) = 0.D0
               GDNR(IJ,K) = 0.D0
            ENDIF
            !! Update Ns
            IF ( GDQS(IJ,K) .LT. QMIN ) THEN
               GDQS(IJ,K) = 0.D0
               GDNS(IJ,K) = 0.D0
            ENDIF
            !! Update Ng
            IF ( GDQG(IJ,K) .LT. QMIN ) THEN
               GDQG(IJ,K) = 0.D0
               GDNG(IJ,K) = 0.D0
            ENDIF
         ENDDO
      ENDDO
*
      ENDDO  !! NITRMIC: main loop for microphysical subtime step
*
*==============================================================================*
*    6. STATISTICS BLOCK
*==============================================================================*
*
      QTD = QTD / NITRMIC
      NTD = NTD / NITRMIC
      TTD = TTD / NITRMIC * 86400.D0 !! [K/s] --> [K/day]
      DO K = 1, KMAX
         DO IJ = ISTS, IENS
*
            !! Get In-Cloud Values
            SGCF  = MAX( MINCLD, GDCFRC(IJ,K) )  !! subgrid liq cld. fraction
            SGIF  = MAX( MINCLD, GDIFRC(IJ,K) )  !! subgrid ice cld. fraction
            SGPF  = MAX( MINCLD, PREFRC(IJ,K) )  !! subgrid     rain fraction
            SGSF  = MAX( MINCLD, SNWFRC(IJ,K) )  !! subgrid     snow fraction
            SGGF  = MAX( MINCLD, GRPFRC(IJ,K) )  !! subgrid     graupel fraction
            QCLDL = GDQC(IJ,K) / SGCF
            NCLDL = GDNC(IJ,K) / SGCF
            QCLDI = GDQI(IJ,K) / SGIF
            NCLDI = GDNI(IJ,K) / SGIF
            QRAIN = GDQR(IJ,K) / SGPF
            NRAIN = GDNR(IJ,K) / SGPF
            QSNOW = GDQS(IJ,K) / SGSF
            NSNOW = GDNS(IJ,K) / SGSF
            QGRPL = GDQG(IJ,K) / SGGF
            NGRPL = GDNG(IJ,K) / SGGF
*
*        << Tendencies Diagnostics >>
*
            !! Microphysical Process Rates
            QVTEND(IJ,K) = QVTEND(IJ,K) / REAL(NITRMIC)
            QCTEND(IJ,K) = QCTEND(IJ,K) / REAL(NITRMIC)
            NCTEND(IJ,K) = NCTEND(IJ,K) / REAL(NITRMIC)
            QITEND(IJ,K) = QITEND(IJ,K) / REAL(NITRMIC)
            NITEND(IJ,K) = NITEND(IJ,K) / REAL(NITRMIC)
            QRTEND(IJ,K) = QRTEND(IJ,K) / REAL(NITRMIC)
            NRTEND(IJ,K) = NRTEND(IJ,K) / REAL(NITRMIC)
            QSTEND(IJ,K) = QSTEND(IJ,K) / REAL(NITRMIC)
            NSTEND(IJ,K) = NSTEND(IJ,K) / REAL(NITRMIC)
            QGTEND(IJ,K) = QGTEND(IJ,K) / REAL(NITRMIC)
            NGTEND(IJ,K) = NGTEND(IJ,K) / REAL(NITRMIC)
            LHTEND(IJ,K) = LHTEND(IJ,K) / REAL(NITRMIC) * 86400.D0  !! [K/s] --> [K/day]
*
*
*        << Effective Radii >>
*           Note: Output Effective Radii are In-Cloud Values.
*                 Cloud Liq Reff Larger than  10 micron, and Smaller than   25 micron.
*                 Cloud Ice Reff Larger than  20 micron, and Smaller than  300 micron.
*                 Raindrop  Reff Larger than   0 micron, and Smaller than 2000 micron.
*                 Snowflake Reff Larger than 150 micron, and Smaller than 2000 micron.
*                 Graupel   Reff Larger than 300 micron, and Smaller than 200000 micron.
*                 These thresholds are determined by the microphysical schemes therein,
*                 as well as a limitation of the current radiation LUT for MstrnX (2018.06.21).
*
            !! Cloud Droplet Effective Radius: unit in micron
*              Note: 10 < Reff (cloud) < 25 micron
            IF ( GDCFRC(IJ,K) .GT. MINCLD  .AND.
     &           QCLDL        .GT. 1.D-10  .AND.
     &           NCLDL        .GT. 0.D0          ) THEN
               REFFC(IJ,K) = 1.1D0
     &          * CBRT( 3.D0*QCLDL*RHO(IJ,K)/NCLDL/4.D0/PI/RHOW ) * 1.D6
               REFFC(IJ,K) = MIN( MAX(REFFC(IJ,K),10.D0), 25.D0 )
            ELSE
               REFFC(IJ,K) = -999.D0
            ENDIF

            !! Cloud Ice Effective Radius: unit in micron
*              Note: 20 < Reff (ice) < 300 micron
            IF ( GDIFRC(IJ,K) .GT. MINCLD  .AND.
     &           QCLDI        .GT. 1.D-10  .AND.
     &           NCLDI        .GT. 0.D0          ) THEN
               REFFI(IJ,K) = 1.1D0
     &          * CBRT( 3.D0*QCLDI*RHO(IJ,K)/NCLDI/4.D0/PI/RHOI ) * 1.D6
               REFFI(IJ,K) = MIN( MAX(REFFI(IJ,K),20.D0 ), 300.D0 )
            ELSE
               REFFI(IJ,K)  = -999.D0
            ENDIF

            !! Raindrop Effective Radius
*              Note1: 0 < Reff (rain) < 2000 micron
            IF ( PREFRC(IJ,K) .GT. MINCLD  .AND.
     &           GDQR  (IJ,K) .GT. 1.D-10  .AND.
     &           GDNR  (IJ,K) .GT. 0.D0          ) THEN
               DUM1 = (GDQR(IJ,K)*RHO(IJ,K)) / (PI*RHOW*GDNR(IJ,K))
               DUM2 = (3.D0 / 4.D0) * DUM1
               DUM1 = CBRT( DUM1 )
               DUM2 = CBRT( DUM2 )
               REFFR(IJ,K) = 1.5D0 * DUM1 * 1.D6  !! [m] --> [um]
               REFFR(IJ,K) = MIN( MAX(REFFR(IJ,K),0.D0), 2000.D0 )
#ifdef OPT_SNWRAD
               !! Mean Volume Radius (rain) for Radiation
               RPPCL(IJ,K,1) = MIN( MAX(25.D-6,DUM2),2000.D-6 ) * 1.D2 !! rain [cm]
#endif
            ELSE
               REFFR(IJ,K)   = -999.D0
            ENDIF

            !! Snowflake Effective Radius
*              Note1: 150 < Reff (snow) < 2000 micron
            IF ( SNWFRC(IJ,K) .GT. MINCLD  .AND.
     &           GDQS  (IJ,K) .GT. 1.D-10  .AND.
     &           GDNS  (IJ,K) .GT. 0.D0          ) THEN
               DUM1 = (GDQS(IJ,K)*RHO(IJ,K)) / (PI*RHOS*GDNS(IJ,K))
               DUM2 = (3.D0 / 4.D0) * DUM1
               DUM1 = CBRT( DUM1 )
               DUM2 = CBRT( DUM2 )
               REFFS(IJ,K) = 1.5D0 * DUM1 * 1.D6
               REFFS(IJ,K) = MIN( MAX(REFFS(IJ,K),150.D0), 2000.D0 )
#ifdef OPT_SNWRAD
               !! Mean Volume Radius (snow) for Radiation
               RPPCL(IJ,K,2) = MIN( MAX(150.D-6,DUM2),2000.D-6 ) * 1.D2 !! snow [cm]
#endif
            ELSE
               REFFS(IJ,K)   = -999.D0
            ENDIF

            !! Graupel Effective Radius
*              Note1: 300 < Reff (graupel) < 200000 micron
            IF ( GRPFRC(IJ,K) .GT. MINCLD  .AND.
     &           GDQG  (IJ,K) .GT. 1.D-10  .AND.
     &           GDNG  (IJ,K) .GT. 0.D0          ) THEN
               DUM1 = (GDQG(IJ,K)*RHO(IJ,K)) / (PI*RHOG*GDNG(IJ,K))
               DUM2 = (3.D0 / 4.D0) * DUM1
               DUM1 = CBRT( DUM1 )
               DUM2 = CBRT( DUM2 )
               REFFG(IJ,K) = 1.5D0 * DUM1 * 1.D6
               REFFG(IJ,K) = MIN( MAX(REFFG(IJ,K),300.D0), 200000.D0 )
!#ifdef OPT_SNWRAD
!               !! Mean Volume Radius (graupel) for Radiation
!               RPPCL(IJ,K,2) = MIN( MAX(300.D-6,DUM2),200000.D-6 )*1.D2 !! grapel [cm]
!#endif               
            ELSE
               REFFG(IJ,K)   = -999.D0
            ENDIF
         ENDDO
      ENDDO
*
*     << Column Integrated Hydrometeors and Process Rates >>
*
      WVM    = 0.D0     !! water vapor mass (precipitable water) [kg m-2]
      CLWP   = 0.D0     !! cloud liquid water path [kg m-2]
      CIWP   = 0.D0     !! cloud ice water path [kg m-2]
      RWP    = 0.D0     !! rain water path [kg m-2]
      RWPCL  = 0.D0     !! rain water path [kg m-2] (cloud layer)
      RWPBC  = 0.D0     !! rain water path [kg m-2] (below cloud)
      SWP    = 0.D0     !! snow water path [kg m-2]
      GWP    = 0.D0     !! graupel water path [kg m-2]
      COLNC  = 0.D0
      COLNI  = 0.D0
      COLNR  = 0.D0
      COLNS  = 0.D0
      COLNG  = 0.D0
      ACVS   = 0.D0     !! autoconversion rate [kg m-2 s-1]
      ACCS   = 0.D0     !! accretion rate      [kg m-2 s-1]

      DO K = 1, KMAX
         DO IJ = ISTS, IENS
            WVM  (IJ) =   WVM(IJ) + GDQX(IJ,K)*RHO(IJ,K)*DELZ(IJ,K)  !! [kg m-2]
            CLWP (IJ) =  CLWP(IJ) + GDQC(IJ,K)*RHO(IJ,K)*DELZ(IJ,K)  !! [kg m-2]
            CIWP (IJ) =  CIWP(IJ) + GDQI(IJ,K)*RHO(IJ,K)*DELZ(IJ,K)  !! [kg m-2]
            RWP  (IJ) =   RWP(IJ) + GDQR(IJ,K)*RHO(IJ,K)*DELZ(IJ,K)  !! [kg m-2]
            SWP  (IJ) =   SWP(IJ) + GDQS(IJ,K)*RHO(IJ,K)*DELZ(IJ,K)  !! [kg m-2]
            GWP  (IJ) =   GWP(IJ) + GDQG(IJ,K)*RHO(IJ,K)*DELZ(IJ,K)  !! [kg m-2]
            COLNC(IJ) = COLNC(IJ) + GDNC(IJ,K)*DELZ(IJ,K)            !! [m-2]
            COLNI(IJ) = COLNI(IJ) + GDNI(IJ,K)*DELZ(IJ,K)            !! [m-2]
            COLNR(IJ) = COLNR(IJ) + GDNR(IJ,K)*DELZ(IJ,K)            !! [m-2]
            COLNS(IJ) = COLNS(IJ) + GDNS(IJ,K)*DELZ(IJ,K)            !! [m-2]
            COLNG(IJ) = COLNG(IJ) + GDNG(IJ,K)*DELZ(IJ,K)            !! [m-2]
            IF ( GDQC(IJ,K) .GT. 0.D0 .AND. GDQR(IJ,K) .GT. 0.D0 ) THEN
               RWPCL(IJ) = RWPCL(IJ) + GDQR(IJ,K)*RHO(IJ,K)*DELZ(IJ,K)
            ELSE
               RWPBC(IJ) = RWPBC(IJ) + GDQR(IJ,K)*RHO(IJ,K)*DELZ(IJ,K)
            ENDIF
            ACVS(IJ) = ACVS(IJ) + QTD(IJ,K,7)*RHO(IJ,K)*DELZ(IJ,K)  !! [kg m-2 s-1]
            ACCS(IJ) = ACCS(IJ) + QTD(IJ,K,8)*RHO(IJ,K)*DELZ(IJ,K)  !! [kg m-2 s-1]
         ENDDO
      ENDDO
*
*     << Lower Tropospheric Stability (LTS) >>
*
      KP700 = -10
      KPSFC = -10
      DIFF_P700  = 1.D10
      DIFF_P1000 = 1.D10
      DO K = 1, KMAX
         DO IJ = ISTS, IENS
            THETA(IJ,K) = GDT(IJ,K)
     &                    * ( GDP(IJ,K) / GDPM(IJ,1) )**(-0.28573)
            IF( ABS( GDP(IJ,K) - 700.D2 ) .LT. DIFF_P700(IJ) ) THEN
               DIFF_P700(IJ) = ABS( GDP(IJ,K) - 700.D2  )
               KP700(IJ) = K
            ENDIF
            IF( ABS( GDP(IJ,K) - 1000.D2 ) .LT. DIFF_P1000(IJ) )THEN
               DIFF_P1000(IJ) = ABS( GDP(IJ,K) - 1000.D2  )
               KPSFC(IJ) = K
            ENDIF
         ENDDO
      ENDDO
      DO IJ = ISTS, IENS
         KP7 = KP700(IJ)
         KPS = KPSFC(IJ)
         IF( KP7 .GT. 0 .AND. KPS .GT. 0 ) THEN
            LTS(IJ) = THETA(IJ,KP7) - THETA(IJ,KPS)
            LTS(IJ) = MAX( 0.D0, LTS(IJ) )
         ELSE
            LTS(IJ) = -999.D0
         ENDIF
      ENDDO
*
*     << Acc/Aut ratio >>
*
      DO IJ = ISTS, IENS
         IF ( ACVS(IJ) .GT. 0.D0 ) THEN
            ACAUS(IJ) = ACCS(IJ) / ACVS(IJ)
         ELSE
            ACAUS(IJ) = -999.0
         ENDIF
      ENDDO
*
*
*==============================================================================*
*    7. FINALIZE BLOCK
*==============================================================================*
*
*    << Update Tracers of Prognostic Hydrometeors >>
*
      DO K = 1, KMAX
         DO IJ = ISTS, IENS
            RHO(IJ,K) = GDP(IJ,K) / ( RAIR*GDTX(IJ,K) )

            !! Qr and Nr
            IF ( GDQR(IJ,K) .GT. QMIN ) THEN
               DUM1 = (6.D0*RHO(IJ,K)*GDQR(IJ,K))
     &              / (PI*RHOW*LMTMDR(1)**3.0)
               DUM2 = (6.D0*RHO(IJ,K)*GDQR(IJ,K))
     &              / (PI*RHOW*LMTMDR(2)**3.0)
               GDNR(IJ,K) = MIN( MAX( GDNR(IJ,K), DUM2 ), DUM1 )
            ELSE
               GDQR(IJ,K) = 0.D0
               GDNR(IJ,K) = 0.D0
            ENDIF
            !! Qs and Ns
            IF ( GDQS(IJ,K) .GT. QMIN ) THEN
               DUM1 = (6.D0*RHO(IJ,K)*GDQS(IJ,K))
     &              / (PI*RHOS*LMTMDS(1)**3.0)
               DUM2 = (6.D0*RHO(IJ,K)*GDQS(IJ,K))
     &              / (PI*RHOS*LMTMDS(2)**3.0)
               GDNS(IJ,K) = MIN( MAX( GDNS(IJ,K), DUM2 ), DUM1 )
            ELSE
               GDQS(IJ,K) = 0.D0
               GDNS(IJ,K) = 0.D0
            ENDIF
            !! Qg and Ng
            IF ( GDQG(IJ,K) .GT. QMIN ) THEN
               DUM1 = (6.D0*RHO(IJ,K)*GDQG(IJ,K))
     &              / (PI*RHOG*LMTMDG(1)**3.0)
               DUM2 = (6.D0*RHO(IJ,K)*GDQG(IJ,K))
     &              / (PI*RHOG*LMTMDG(2)**3.0)
               GDNG(IJ,K) = MIN( MAX( GDNG(IJ,K), DUM2 ), DUM1 )
               DUM1 = 1.D-7 * (RHO(IJ,K)*GDQG(IJ,K))/1.6D-10  ! Reisner et al. (1998) Eq.70
               DUM2 = 1.D2  * (RHO(IJ,K)*GDQG(IJ,K))/1.6D-10  ! Reisner et al. (1998) Eq.70
               GDNG(IJ,K) = MIN( MAX( GDNG(IJ,K), DUM1 ), DUM2 )
            ELSE
               GDQG(IJ,K) = 0.D0
               GDNG(IJ,K) = 0.D0
            ENDIF
         ENDDO
      ENDDO
      GDQ(:,:,INC) = GDNC(:,:)
     &             * ( RAIR * GDTV(:,:) * (18.D-3*RVAP/RAIR) )
     &             / GDP(:,:) / AVOG          !! Nc [kg/kg] back to SPRINTARS
      GDQ(:,:,INI) = GDNI(:,:)
     &             * ( RAIR * GDTV(:,:) * (18.D-3*RVAP/RAIR) )
     &             / GDP(:,:) / AVOG          !! Ni [kg/kg] back to SPRINTARS
      GDQ(:,:,IQR) = GDQR(:,:)                !! Qr [kg/kg]
      GDQ(:,:,INR) = GDNR(:,:) / RHO(:,:)     !! Nr [#/kg]
      GDQ(:,:,IQS) = GDQS(:,:)                !! Qs [kg/kg]
      GDQ(:,:,INS) = GDNS(:,:) / RHO(:,:)     !! Ns [#/kg]
      GDQ(:,:,IQG) = GDQG(:,:)                !! Qg [kg/kg]
      GDQ(:,:,ING) = GDNG(:,:) / RHO(:,:)     !! Ng [#/kg]

*
*
*    <<  Total Precipitation, Total Energy, and Total Water Mass >>
*
      DO IJ = ISTS, IENS
         GPREC (IJ,KMAX+1) = 0.D0
         GPRECL(IJ,KMAX+1) = 0.D0
         GPRECS(IJ,KMAX+1) = 0.D0
      ENDDO
      DO K = KMAX, 1, -1
         DO IJ = ISTS, IENS

            !! Precipitation
*              Note: GPREC = GPRECL(liq.) + GPRECS(solid)
            GPREC (IJ,K) = RFLUX(IJ,K) + SFLUX(IJ,K)  !! 3-D precip. flux    [kg m-2 s-1] (OUT)
            GPRECL(IJ,K) = RFLUX(IJ,K)                !! liq precip. flux    [kg m-2 s-1]
            GPRECS(IJ,K) = SFLUX(IJ,K)                !! ice precip. flux    [kg m-2 s-1]

            !! Energy and Mass Budget Conservation
!            HBGTA( IJ ) = HBGTA( IJ )
!     &                  + ( CP*GDT(IJ,K)            !! temperature
!     &                    + (EL+EMELT)*GDQ(IJ,K,1)  !! water vapor
!     &                    + EMELT*GDQ(IJ,K,ITL)     !! cloud water
!     &                    ) * RDZ(IJ,K)
            HBGTA( IJ ) =  HBGTA( IJ )
     &                  + ( CP*GDTX(IJ,K)            !! temperature after microphysics
     &                    + (EL+EMELT)*GDQX(IJ,K)    !! water vapor after microphysics
     &                    + EMELT*GDQC(IJ,K)         !! cloud water
     &                    + EMELT*GDQR(IJ,K)         !! rain water
     &                    + EMELT*HBGTC1(IJ,K)*DELT  !! melted cloud_ice to rain ??
     &                    + EMELT*HBGTC2(IJ,K)*DELT  !! melted cloud_ice to rain ??
     &                    - CP*HBGTC3(IJ,K)          !! phase change of rain/snow ??
     &                    - EMELT*HBGTC4(IJ,K)*DELT  !! evap of rain ??
     &                    ) * RDZ(IJ,K)

            DUM1 = DELP(IJ,K)/GRAV
            WBGTA(IJ) = WBGTA(IJ)
     &                  + ( GDQX(IJ,K)   !! water vapor after microphysics
     &                    + GDQC(IJ,K)   !! cloud water after microphysics
     &                    + GDQI(IJ,K)   !! cloud ice after microphysics
     &                    + GDQR(IJ,K)   !! rain water after microphysics
     &                    + GDQS(IJ,K)   !! snow water after microphysics
     &                    ) * DUM1
         ENDDO
      ENDDO

      !! Inbalance Energy and Water Budgets
      HBGTA(:) = ( HBGTA(:)-HBGTB(:) ) / DELT    !! [J/m**2/s]
      WBGTA(:) = ( ( WBGTA(:)-DSEDRS(:) ) - WBGTB(:) ) / DELT    !! [kg/m**2/s]
      DWATER(:)= DWATER(:) / DELT                !! [kg/kg/s] ++ dummy for confirm input
*
*
*    << Return Arguments (OUT, INOUT attributes) >>
*
      DO K = 1, KMAX
         DO IJ = ISTS, IENS
            GDCLW(IJ,K  ) = GDQC(IJ,K) + GDQI(IJ,K)              !! cloud water liq+ice
            GTQ(IJ,K,  1) = ( GDQX(IJ,K)-GDQ(IJ,K,  1) ) / DELT

            GTQ(IJ,K,ITL) = ( GDQC(IJ,K)-GDQ(IJ,K,ITL) ) / DELT  !! Qc tendency [kg/kg/s]
            GTQ(IJ,K,ITI) = ( GDQI(IJ,K)-GDQ(IJ,K,ITI) ) / DELT  !! Qi tendency [kg/kg/s]
            GTT(IJ,K    ) = ( GDTX(IJ,K)-GDT(IJ,K    ) ) / DELT  !! T  tendency [kg/kg/s]
            QSAT          = FQSAT( GDTX(IJ,K),GDP(IJ,K) )
            RH (IJ,K    ) = MAX( GDQX(IJ,K)/QSAT, 0.D0 )
            RHLIQ(IJ,K)   = MAX(GDQX(IJ,K)/FQSATL(GDTX(IJ,K),GDP(IJ,K))
     &                          , 0.D0 )
            RHICE(IJ,K)   = MAX(GDQX(IJ,K)/FQSATI(GDTX(IJ,K),GDP(IJ,K))
     &                          , 0.D0)
            FTD           = LOG( MAX( GDQX(IJ,K), 1.D-300 )
     &                      * GDP(IJ,K) / FTD1 )
            GDTD( IJ,K )  = FTD * FTD2 / ( FTD*RVAP - FTD3 )

            !! Liquid Fraction, Cloud Condensate >>
*              Note: FLIQAR is liquid fraction (FLIQL) for the AeRosol scheme.
*              Homogeneous/heterogeneous nucleation is neglected in FLIQAR, so that
*              influence of the nucleating liquid water on cloud ice number concentration
*              can be evaluated in the aerosol scheme.
            IF ( GDQC(IJ,K)+GDQI(IJ,K) .GT. 0.D0 ) THEN
                FLIQL (IJ,K) = GDQC(IJ,K) / (GDQC(IJ,K)+GDQI(IJ,K) )
                FLIQL (IJ,K) = MIN( MAX( FLIQL(IJ,K),0.D0 ), 1.D0 )
                FLIQAR(IJ,K) = GDCLWX(IJ,K) / ( GDQC(IJ,K)+GDQI(IJ,K) )
                FLIQAR(IJ,K) = MIN( MAX( FLIQAR(IJ,K),0.D0 ), 1.D0 )
                FLIQOU(IJ,K) = FLIQL(IJ,K)
            ENDIF

            !! interpolation for CloudSat/CALIPSO simulator (COSP)
            GPLINT(IJ,K) = GPRECL(IJ,K)
     &                   + ( (GDZ(IJ,K)-GDZM(IJ,K))
     &                       / (GDZM(IJ,K+1)-GDZM(IJ,K)) )
     &                     * ( GPRECL(IJ,K+1)-GPRECL(IJ,K) )
            GPSINT(IJ,K) = GPRECS(IJ,K)
     &                   + ( (GDZ(IJ,K)-GDZM(IJ,K))
     &                       / (GDZM(IJ,K+1)-GDZM(IJ,K)) )
     &                     * ( GPRECS(IJ,K+1)-GPRECS(IJ,K) )
            QLIQL(IJ,K) = GDQC(IJ,K)
            QICEL(IJ,K) = GDQI(IJ,K)
            QLIQ (IJ,K) = GDQC(IJ,K)
            QICE (IJ,K) = GDQI(IJ,K)
         ENDDO
      ENDDO
*
*
*    << Precipitation Flux to Mixing Ratio >>
*
!      CALL PF2MR( IJSDIM,  KMAX,
!     I            GDP,     GDT,     GDZM,
!     I            GPLINT,  GPSINT,
!     O            DIAGQR,  DIAGRWP, DIAGQS,  DIAGSWP  )
*
*
*    << History Output >>
*
!      CALL HISTIN( RHO,    'RHOOUT', 'atmospheric density (out)',
!     &                                      'kg m-3',    'ALEV', HCLAS )
!      CALL HISTIN( RDZ,    'RDZOUT',  'RHO * dZ = dP / GRAV',
!     &                                       'kg m-2',   'ALEV', HCLAS )
!      CALL HISTIN( DELZ,   'DZOUT',  'dZ in CLDPHYS',
!     &                                      'm',         'ALEV', HCLAS )
!      CALL HISTIN( DELP,   'DPOUT',  'dP in CLDPHYS',
!     &                                      'Pa',        'ALEV', HCLAS )
      CALL HISTIN( GPREC,  'FPRCL',  'LSC precip. flux',
     &                                      'kg/m**2/s', 'AMLV', HCLAS )
      CALL HISTIN( GPRECL, 'FRANL',  'LSC rain flux',
     &                                      'kg/m**2/s', 'AMLV', HCLAS )
      CALL HISTIN( GPRECS, 'FSNWL',  'LSC snow flux',
     &                                      'kg/m**2/s', 'AMLV', HCLAS )
      CALL HISTIN( GPLINT, 'FRANLF', 'LSC rain flux full-level',
     &                                      'kg/m**2/s', 'ALEV', HCLAS )
      CALL HISTIN( GPSINT, 'FSNWLF', 'LSC snow flux full-level',
     &                                      'kg/m**2/s', 'ALEV', HCLAS )
      CALL HISTIN( RH,     'RHADJ',  'adjusted relative humidity',
     &                                      ' ',         'ALEV', HCLAS )
!      CALL HISTIN( GDTD,   'TD',     'dew point temperature',
!     &                                      'K',         'ALEV', HCLAS )
      CALL HISTIN( UAPCL,  'UAPCL',  'CCN conc.',
     &                                      ' ',         'ALEV', HCLAS )
      CALL HISTIN( QLIQ,   'QLIQL',  'stariform cloud liquid water',
     &                                      'kg/kg',     'ALEV', HCLAS )
      CALL HISTIN( QICE,   'QICEL',  'stratiform cloud ice',
     &                                      'kg/kg',     'ALEV', HCLAS )
      CALL HISTIN( GDCFRC, 'CFRCOUT','tot. cloud frac. after microphys',
     &                                      ' ',         'ALEV', HCLAS )
      CALL HISTIN( GDIFRC, 'IFRCOUT','ice cloud frac. after microphys',
     &                                      ' ',         'ALEV', HCLAS )
      CALL HISTIN( RHLIQ,  'RHADJL',  'adjusted relative humidity liq',
     &                                      ' ',         'ALEV', HCLAS )
      CALL HISTIN( RHICE,  'RHADJI',  'adjusted relative humidity ice',
     &                                      ' ',         'ALEV', HCLAS )
      CALL HISTIN( FLIQOU, 'FLIQL',   'LSC cloud liquid fraction',
     &                                      ' ',         'ALEV', HCLAS )
      CALL HISTIN( FLIQAR, 'FLIQAR',  'FLIQ for aerosol scheme',
     &                                      ' ',         'ALEV', HCLAS )
      CALL HISTIN( ESWAGG, 'ESWAGG', 'riming collection efficiency',
     &                                      'none',      'ALEV', HCLAS )
      CALL HISTIN( LTS,    'LTS',    'lower tropospheric stability',
     &                                      'K',        'ASFC', HCLAS )
*
*    !! 2018.06.30: PROGNOSTIC RAIN+SNOW
      CALL HISTIN( GDQX, 'GDQVOUT', 'grid-mean water vapor m.x. ratio',
     &                                      'kg/kg', 'ALEV', HCLAS )
      CALL HISTIN( GDQC, 'GDQCOUT', 'grid-mean cloud water m.x. ratio',
     &                                      'kg/kg', 'ALEV', HCLAS )
      DUMIJK(:,:) = GDQ(:,:,INC) * GDP(:,:) / RAIR
     &            / GDTV(:,:) * AVOG / (18.D-3*RVAP/RAIR)  !! confirm [#/m-3]
      CALL HISTIN( DUMIJK, 'GDNCOUT', 'grid-mean cloud number conc.',
     &                                      'm-3',   'ALEV', HCLAS )
      CALL HISTIN( GDQI, 'GDQIOUT', 'grid-mean cloud ice m.x. ratio',
     &                                      'kg/kg', 'ALEV', HCLAS )
      DUMIJK(:,:) = GDQ(:,:,INI) * GDP(:,:) / RAIR
     &            / GDTV(:,:) * AVOG / (18.D-3*RVAP/RAIR)  !! confirm [#/m-3]
      CALL HISTIN( DUMIJK, 'GDNIOUT', 'grid-mean ice number conc.',
     &                                      'm-3',   'ALEV', HCLAS )
      CALL HISTIN( GDQR, 'GDQROUT', 'grid-mean rainwater m.x. ratio',
     &                                      'kg/kg', 'ALEV', HCLAS )
      CALL HISTIN( GDNR, 'GDNROUT', 'grid-mean rain number conc.',
     &                                      'm-3',   'ALEV', HCLAS )
      CALL HISTIN( GDQS, 'GDQSOUT', 'grid-mean snow mass m.x. ratio',
     &                                      'kg/kg', 'ALEV', HCLAS )
      CALL HISTIN( GDNS, 'GDNSOUT', 'grid-mean snow number conc.',
     &                                      'm-3',   'ALEV', HCLAS )
      CALL HISTIN( GDQG, 'GDQGOUT', 'grid-mean graupel mass m.x. ratio',
     &                                      'kg/kg', 'ALEV', HCLAS )
      CALL HISTIN( GDNG, 'GDNGOUT', 'grid-mean graupel number conc.',
     &                                      'm-3',   'ALEV', HCLAS )
      CALL HISTIN( PREFRC,'PREFRC','prec.frac. after microphy',
     &                                      'none',     'ALEV', HCLAS )
      CALL HISTIN( SNWFRC,'SNWFRC','snow frac. after microphy',
     &                                      'none',     'ALEV', HCLAS )
      CALL HISTIN( GRPFRC,'GRPFRC','graupel frac. after microphy',
     &                                      'none',     'ALEV', HCLAS )
      CALL HISTIN( RFLUX, 'RFLUX', 'LSC rain flux (prognosed)',
     &                                      'kg/m2/s',  'ALEV', HCLAS )
      CALL HISTIN( SFLUX, 'SFLUX', 'LSC snow flux (prognosed)',
     &                                      'kg/m2/s',  'ALEV', HCLAS )
!      CALL HISTIN( LAMC,  'LAMC',  'lambda (cloud liquid)',
!     &                                      'm-1',      'ALEV', HCLAS )
!      CALL HISTIN( LAMI,  'LAMI',  'lambda (cloud ice)',
!     &                                      'm-1',      'ALEV', HCLAS )
!      CALL HISTIN( LAMR,  'LAMR',  'lambda (rain)',
!     &                                      'm-1',      'ALEV', HCLAS )
!      CALL HISTIN( LAMS,  'LAMS',  'lambda (snow)',
!     &                                      'm-1',      'ALEV', HCLAS )
!      CALL HISTIN( MASSR, 'MASSR', 'rain mass',
!     &                                      'kg',       'ALEV', HCLAS )
!      CALL HISTIN( MASSS, 'MASSS', 'snow mass',
!     &                                      'kg',       'ALEV', HCLAS )
!      CALL HISTIN( DIAMR, 'DIAMR', 'raindrop diameter',
!     &                                      'micron',   'ALEV', HCLAS )
!      CALL HISTIN( DIAMS, 'DIAMS', 'snowflake diameter',
!     &                                      'micron',   'ALEV', HCLAS )
      CALL HISTIN( VQR,   'VQR',   'mass-weighted raindrop fall veloc.',
     &                                      'm/s',      'ALEV', HCLAS )
!      CALL HISTIN( VNR,   'VNR',   'num-weighted raindrop fall veloc.',
!     &                                      'm/s',      'ALEV', HCLAS )
      CALL HISTIN( VQI,   'VQI',   'mass-weighted cld ice fall veloc.',
     &                                      'm/s',      'ALEV', HCLAS )
!      CALL HISTIN( VNI,   'VNI',   'num-weighted cld ice fall veloc.',
!     &                                      'm/s',      'ALEV', HCLAS )
      CALL HISTIN( VQS,   'VQS',   'mass-weighted snowflake fall velo',
     &                                      'm/s',      'ALEV', HCLAS )
!      CALL HISTIN( VNS,   'VNS',   'num-weighted snowflake fall velo',
!     &                                      'm/s',      'ALEV', HCLAS )
      CALL HISTIN( VQG,   'VQG',   'mass-weighted graupel fall veloc.',
     &                                      'm/s',      'ALEV', HCLAS )
      CALL HISTIN( VNG,   'VNG',   'num-weighted graupel fall veloc',
     &                                      'm/s',      'ALEV', HCLAS )
      CALL HISTIN( REFFC, 'REFFC', 'effective radius (cloud)',
     &                                      'micron',   'ALEV', HCLAS )
      CALL HISTIN( REFFR, 'REFFR', 'effective radius (drizzle+rain)',
     &                                      'micron',   'ALEV', HCLAS )
      CALL HISTIN( REFFI, 'REFFI', 'effective radius (ice)',
     &                                      'micron',   'ALEV', HCLAS )
      CALL HISTIN( REFFS, 'REFFS', 'effective radius (snowflake)',
     &                                      'micron',   'ALEV', HCLAS )
      CALL HISTIN( REFFG, 'REFFG', 'effective radius (graupel)',
     &                                      'micron',   'ALEV', HCLAS )
#ifdef OPT_SNWRAD
      CALL HISTIN( RPPCL(1,1,1), 'RPPCL1', 'mean volume radius (rain)',
     &                                          'cm',   'ALEV', HCLAS )
      CALL HISTIN( RPPCL(1,1,2), 'RPPCL2', 'mean volume radius (snow)',
     &                                          'cm',   'ALEV', HCLAS )
#endif
      CALL HISTIN( WVM,   'WVM',   'column water vapor mass',
     &                                      'kg/m2',    'ASFC', HCLAS )
      CALL HISTIN( CLWP,  'CLWP',  'cloud liquid water path',
     &                                      'kg/m2',    'ASFC', HCLAS )
      CALL HISTIN( CIWP,  'CIWP',  'cloud ice water path',
     &                                      'kg/m2',    'ASFC', HCLAS )
      CALL HISTIN( RWP,   'RWP',   'rain water path',
     &                                      'kg/m2',    'ASFC', HCLAS )
      CALL HISTIN( RWPCL, 'RWPCL', 'rain water path (cld layer)',
     &                                      'kg/m2',    'ASFC', HCLAS )
      CALL HISTIN( RWPBC, 'RWPBC', 'rain water path (below cld)',
     &                                      'kg/m2',    'ASFC', HCLAS )
      CALL HISTIN( SWP,   'SWP',   'snow water path',
     &                                      'kg/m2',    'ASFC', HCLAS )
      CALL HISTIN( GWP,   'GWP',   'graupel water path',
     &                                      'kg/m2',    'ASFC', HCLAS )
      CALL HISTIN( COLCCN,'COLCCN','column ccn burden',
     &                                      'm-2',      'ASFC', HCLAS )
      CALL HISTIN( COLNC, 'COLNC', 'column Nc burden',
     &                                      'm-2',      'ASFC', HCLAS )
      CALL HISTIN( COLNI, 'COLNI', 'column Ni burden',
     &                                      'm-2',      'ASFC', HCLAS )
      CALL HISTIN( COLNR, 'COLNR', 'column Nr burden',
     &                                      'm-2',      'ASFC', HCLAS )
      CALL HISTIN( COLNS, 'COLNS', 'column Ns burden',
     &                                      'm-2',      'ASFC', HCLAS )
      CALL HISTIN( COLNG, 'COLNG', 'column Ng burden',
     &                                      'm-2',      'ASFC', HCLAS )
      CALL HISTIN( ACVS,  'ACVS',  'autoconversion rate',
     &                                    'kg m-2 s-1', 'ASFC', HCLAS )
      CALL HISTIN( ACCS,  'ACCS',  'accretion rate',
     &                                    'kg m-2 s-1', 'ASFC', HCLAS )
      CALL HISTIN( ACAUS, 'ACAUS', 'Acc/Aut ratio',
     &                                          'none', 'ASFC', HCLAS )
      CALL HISTIN( VCFLP, 'VCFLP', 'CFL (p-system) for sedimentation',
     &                                      'sec',      'ASFC', HCLAS )
      CALL HISTIN( VCFLZ, 'VCFLZ', 'CFL (z-system) for sedimentation',
     &                                      'sec',      'ASFC', HCLAS )
*** New Tendency Diagnostic Monitor (2018.08.29 2021.09.09)
      CALL HISTAD( QTD(1,1, 1),'QTDCNEV', 1.D0 )
      CALL HISTIN( QTD(1,1, 2),'QTDHOMF', 'dQ/dt homo.freez.: c -> i',
     &                                      'kg/kg/s',   'ALEV', HCLAS )
      CALL HISTIN( QTD(1,1, 3),'QTDHETF', 'dQ/dt hetero.frz.: c -> i',
     &                                      'kg/kg/s',   'ALEV', HCLAS )
      CALL HISTIN( QTD(1,1, 4),'QTDMLTS', 'dQ/dt melting snow: s -> r',
     &                                      'kg/kg/s',   'ALEV', HCLAS )
      CALL HISTIN( QTD(1,1, 5),'QTDFRZRI','dQ/dt rain freezing: r -> i',
     &                                      'kg/kg/s',   'ALEV', HCLAS )
      CALL HISTIN( QTD(1,1, 6),'QTDFRZRS','dQ/dt rain freezing: r -> s',
     &                                      'kg/kg/s',   'ALEV', HCLAS )
      CALL HISTIN( QTD(1,1, 7),'QTDAUTL', 'dQ/dt autoconv.: c+c -> r',
     &                                      'kg/kg/s',   'ALEV', HCLAS )
      CALL HISTIN( QTD(1,1, 8),'QTDACCR', 'dQ/dt accretion: c+r -> r',
     &                                      'kg/kg/s',   'ALEV', HCLAS )
      CALL HISTIN( QTD(1,1, 9),'QTDHALM', 'dQ/dt H-M process: c -> i',
     &                                      'kg/kg/s',   'ALEV', HCLAS )
      CALL HISTIN( QTD(1,1,10),'QTDACCS', 'dQ/dt accretion: c+s -> s',
     &                                      'kg/kg/s',   'ALEV', HCLAS )
      CALL HISTIN( QTD(1,1,11),'QTDBEGI', 'dQ/dt B-F process: c -> i',
     &                                      'kg/kg/s',   'ALEV', HCLAS )
      CALL HISTIN( QTD(1,1,12),'QTDBEGS', 'dQ/dt B-F process: c -> s',
     &                                      'kg/kg/s',   'ALEV', HCLAS )
      CALL HISTIN( QTD(1,1,13),'QTDEVPR', 'dQ/dt rain evap.: r -> v',
     &                                      'kg/kg/s',   'ALEV', HCLAS )
      CALL HISTIN( QTD(1,1,14),'QTDACAU', 'Acc/Aut ratio (liquid)',
     &                                      'kg/kg/s',   'ALEV', HCLAS )
      CALL HISTIN( QTD(1,1,15),'QTDDEPI', 'dQ/dt ice deposit.: v -> i',
     &                                      'kg/kg/s',   'ALEV', HCLAS )
      CALL HISTIN( QTD(1,1,16),'QTDSUBI', 'dQ/dt ice sublimat.: i -> v',
     &                                      'kg/kg/s',   'ALEV', HCLAS )
      CALL HISTIN( QTD(1,1,17),'QTDAUTI', 'dQ/dt autoconv.: i+i -> s',
     &                                      'kg/kg/s',   'ALEV', HCLAS )
      CALL HISTIN( QTD(1,1,18),'QTDACIS', 'dQ/dt accretion: i+s -> s',
     &                                      'kg/kg/s',   'ALEV', HCLAS )
      CALL HISTIN( QTD(1,1,19),'QTDACRS', 'dQ/dt accretion: r+s -> s',
     &                                      'kg/kg/s',   'ALEV', HCLAS )
      CALL HISTIN( QTD(1,1,20),'QTDSUBS', 'dQ/dt snow sublim.: s -> v',
     &                                      'kg/kg/s',   'ALEV', HCLAS )
      CALL HISTIN( QTD(1,1,21),'QTDSEDR', 'dQ/dt sedimentation (rain)',
     &                                      'kg/kg/s',   'ALEV', HCLAS )
      CALL HISTIN( QTD(1,1,22),'QTDSEDS', 'dQ/dt sedimentation (snow)',
     &                                      'kg/kg/s',   'ALEV', HCLAS )
      CALL HISTIN( QTD(1,1,23),'QTDSEDI', 'dQ/dt sedimentation (ice)',
     &                                      'kg/kg/s',   'ALEV', HCLAS )
      CALL HISTIN( QTD(1,1,24),'QTDMLTI', 'dQ/dt melting ice: i -> c',
     &                                      'kg/kg/s',   'ALEV', HCLAS )
      CALL HISTIN( QTD(1,1,25),'QTDSEDG', 'dQ/dt sedimentat. (graupel)',
     &                                      'kg/kg/s',   'ALEV', HCLAS )
      CALL HISTIN( QTD(1,1,26),'QTDSUBG', 'dQ/dt graup subli.: g -> v',
     &                                      'kg/kg/s',   'ALEV', HCLAS )
      CALL HISTIN( QTD(1,1,27),'QTDDEPG', 'dQ/dt graup depos.: v -> g',
     &                                      'kg/kg/s',   'ALEV', HCLAS )
      CALL HISTIN( QTD(1,1,28),'QTDBEGG', 'dQ/dt B-F process: c -> g',
     &                                      'kg/kg/s',   'ALEV', HCLAS )
      CALL HISTIN( QTD(1,1,29),'QTDPSACR', 'dQ/dt PSACR: r + s -> g',
     &                                      'kg/kg/s',   'ALEV', HCLAS )
      CALL HISTIN( QTD(1,1,30),'QTDMLTG', 'dQ/dt melting graup: g -> r',
     &                                      'kg/kg/s',   'ALEV', HCLAS )
      CALL HISTIN( QTD(1,1,31),'QTDFRZRG','dQ/dt rain freezing: r -> g',
     &                                      'kg/kg/s',   'ALEV', HCLAS )
      CALL HISTIN( QTD(1,1,32),'QTDPSACWG', 'dQ/dt PSACWG: g + c -> g',
     &                                      'kg/kg/s',   'ALEV', HCLAS )
      CALL HISTIN( NTD(1,1, 1),'NTDHOMFC','dNc/dt homo.freez.: c -> i',
     &                                      'm-3 s-1',   'ALEV', HCLAS )
      CALL HISTIN( NTD(1,1, 2),'NTDHOMFI','dNi/dt homo.freez.: c -> i',
     &                                      'm-3 s-1',   'ALEV', HCLAS )
      CALL HISTIN( NTD(1,1, 3),'NTDHETF', 'dN/dt hetero.frz.: c -> i',
     &                                      'm-3 s-1',   'ALEV', HCLAS )
      CALL HISTIN( NTD(1,1, 4),'NTDMLTS', 'dN/dt melting snow: s -> r',
     &                                      'm-3 s-1',   'ALEV', HCLAS )
      CALL HISTIN( NTD(1,1, 5),'NTDFRZRI','dN/dt rain freezing: r -> i',
     &                                      'm-3 s-1',   'ALEV', HCLAS )
      CALL HISTIN( NTD(1,1, 6),'NTDFRZRS','dN/dt rain freezing: r -> s',
     &                                      'm-3 s-1',   'ALEV', HCLAS )
      CALL HISTIN( NTD(1,1, 7),'NTDEVPR', 'dN/dt rain evap.: r -> v',
     &                                      'm-3 s-1',   'ALEV', HCLAS )
      CALL HISTIN( NTD(1,1, 8),'NTDAUTR', 'dNr/dt autoconv.: c+c -> r',
     &                                      'm-3 s-1',   'ALEV', HCLAS )
      CALL HISTIN( NTD(1,1, 9),'NTDAUTC', 'dNc/dt autoconv.: c+c -> r',
     &                                      'm-3 s-1',   'ALEV', HCLAS )
      CALL HISTIN( NTD(1,1,10),'NTDACCR', 'dNc/dt accretion: c+r -> r',
     &                                      'm-3 s-1',   'ALEV', HCLAS )
      CALL HISTIN( NTD(1,1,11),'NTDSCLR', 'dNr/dt self-collection',
     &                                      'm-3 s-1',   'ALEV', HCLAS )
      CALL HISTIN( NTD(1,1,12),'NTDSUBI', 'dN/dt ice sublimat.: i -> v',
     &                                      'm-3 s-1',   'ALEV', HCLAS )
      CALL HISTIN( NTD(1,1,13),'NTDAUTI', 'dN/dt autoconv.: i+i -> s',
     &                                      'm-3 s-1',   'ALEV', HCLAS )
      CALL HISTIN( NTD(1,1,14),'NTDACCS', 'dNc/dt accretion: c+s -> s',
     &                                      'm-3 s-1',   'ALEV', HCLAS )
      CALL HISTIN( NTD(1,1,15),'NTDHALM', 'dN/dt H-M process: c -> i',
     &                                      'm-3 s-1',   'ALEV', HCLAS )
      CALL HISTIN( NTD(1,1,16),'NTDACIS', 'dNi/dt accretion: i+s -> s',
     &                                      'm-3 s-1',   'ALEV', HCLAS )
      CALL HISTIN( NTD(1,1,17),'NTDACRS', 'dNr/dt accretion: r+s -> s',
     &                                      'm-3 s-1',   'ALEV', HCLAS )
      CALL HISTIN( NTD(1,1,18),'NTDSAGS', 'dNs/dt self-aggregation',
     &                                      'm-3 s-1',   'ALEV', HCLAS )
      CALL HISTIN( NTD(1,1,19),'NTDSEDR', 'dN/dt sedimentation (rain)',
     &                                      'm-3 s-1',   'ALEV', HCLAS )
      CALL HISTIN( NTD(1,1,20),'NTDSEDS', 'dN/dt sedimentation (snow)',
     &                                      'm-3 s-1',   'ALEV', HCLAS )
      CALL HISTIN( NTD(1,1,21),'NTDSEDI', 'dN/dt sedimentation (ice)',
     &                                      'm-3 s-1',   'ALEV', HCLAS )
      CALL HISTIN( NTD(1,1,22),'NTDMLTIC','dNc/dt melting ice: i -> c',
     &                                      'm-3 s-1',   'ALEV', HCLAS )
      CALL HISTIN( NTD(1,1,23),'NTDMLTI', 'dNi/dt melting ice: i -> c',
     &                                      'm-3 s-1',   'ALEV', HCLAS )
      CALL HISTIN( NTD(1,1,24),'NTDSEDG', 'dN/dt sedimentat. (graupel)',
     &                                      'm-3 s-1',   'ALEV', HCLAS )
      CALL HISTIN( NTD(1,1,25),'NTDSUBG', 'dN/dt graup sublim.: g -> v',
     &                                      'm-3 s-1',   'ALEV', HCLAS )
      CALL HISTIN( NTD(1,1,26),'NTDPSACRG', 'dN/dt PSACR: r + s -> g',
     &                                      'm-3 s-1',   'ALEV', HCLAS )
      CALL HISTIN( NTD(1,1,27),'NTDMLTG', 'dN/dt melting graup: g -> r',
     &                                      'm-3 s-1',   'ALEV', HCLAS )
      CALL HISTIN( NTD(1,1,28),'NTDFRZRG','dN/dt rain freezing: r -> g',
     &                                      'm-3 s-1',   'ALEV', HCLAS )
      CALL HISTIN( NTD(1,1,29),'NTDPSACWG', 'dN/dt PSACWG: g + c -> g',
     &                                      'm-3 s-1',   'ALEV', HCLAS )
      CALL HISTIN( TTD(1,1,1), 'TTD1', 'dT/dt due to cloud homo. frz.',
     &                                      'K/day', 'ALEV', HCLAS )
      CALL HISTIN( TTD(1,1,2), 'TTD2', 'dT/dt due to cloud hete. frz.',
     &                                      'K/day', 'ALEV', HCLAS )
      CALL HISTIN( TTD(1,1,3), 'TTD3', 'dT/dt due to snow melting',
     &                                      'K/day', 'ALEV', HCLAS )
      CALL HISTIN( TTD(1,1,4), 'TTD4', 'dT/dt due to rain freezing',
     &                                      'K/day', 'ALEV', HCLAS )
      CALL HISTIN( TTD(1,1,5), 'TTD5', 'dT/dt due to rain evaporation',
     &                                      'K/day', 'ALEV', HCLAS )
      CALL HISTIN( TTD(1,1,6), 'TTD6', 'dT/dt due to snow sublimation',
     &                                      'K/day', 'ALEV', HCLAS )
      CALL HISTIN( TTD(1,1,7), 'TTD7', 'dT/dt due to melting ice',
     &                                      'K/day', 'ALEV', HCLAS )
      CALL HISTIN( TTD(1,1,8), 'TTD8', 'dT/dt due to ice deposition',
     &                                      'K/day', 'ALEV', HCLAS )
      CALL HISTIN( TTD(1,1,9), 'TTD9', 'dT/dt due to ice sublimation',
     &                                      'K/day', 'ALEV', HCLAS )
      CALL HISTIN( TTD(1,1,10),'TTD10','dT/dt due to Bergeron ice',
     &                                      'K/day', 'ALEV', HCLAS )
      CALL HISTIN( TTD(1,1,11),'TTD11','dT/dt due to Bergeron snow',
     &                                      'K/day', 'ALEV', HCLAS )
      CALL HISTIN( TTD(1,1,12),'TTD12','dT/dt due to acc c+s -> s',
     &                                      'K/day', 'ALEV', HCLAS )
      CALL HISTIN( TTD(1,1,13), 'TTD13', 'dT/dt due to snow melting',
     &                                      'K/day', 'ALEV', HCLAS )
!      CALL HISTIN( QVTEND, 'QVTEND', 'dQv/dt due to all processes',
!     &                                    'kg/kg/s', 'ALEV', HCLAS )
!      CALL HISTIN( QCTEND, 'QCTEND', 'dQc/dt due to all processes',
!     &                                    'kg/kg/s', 'ALEV', HCLAS )
!      CALL HISTIN( QITEND, 'QITEND', 'dQi/dt due to all processes',
!     &                                    'kg/kg/s', 'ALEV', HCLAS )
!      CALL HISTIN( QRTEND, 'QRTEND', 'dQr/dt due to all processes',
!     &                                    'kg/kg/s', 'ALEV', HCLAS )
!      CALL HISTIN( QSTEND, 'QSTEND', 'dQs/dt due to all processes',
!     &                                    'kg/kg/s', 'ALEV', HCLAS )
      CALL HISTIN( QGTEND, 'QGTEND', 'dQg/dt due to all processes',
     &                                    'kg/kg/s', 'ALEV', HCLAS )
!      CALL HISTIN( NCTEND, 'NCTEND', 'dNc/dt due to all processes',
!     &                                    'm-3/s', 'ALEV', HCLAS )
!      CALL HISTIN( NITEND, 'NITEND', 'dNi/dt due to all processes',
!     &                                    'm-3/s', 'ALEV', HCLAS )
!      CALL HISTIN( NRTEND, 'NRTEND', 'dNr/dt due to all processes',
!     &                                    'm-3/s', 'ALEV', HCLAS )
!      CALL HISTIN( NSTEND, 'NSTEND', 'dNs/dt due to all processes',
!     &                                    'm-3/s', 'ALEV', HCLAS )
      CALL HISTIN( NGTEND, 'NGTEND', 'dNg/dt due to all processes',
     &                                    'm-3/s', 'ALEV', HCLAS )
!      CALL HISTIN( LHTEND, 'LHTEND', 'dT/dt due to latent heating',
!     &                                    'K/day', 'ALEV', HCLAS )
***
      CALL HISTIN( HBGTB, 'HBGTL',  'column moist energy',
     &                                    'J/m**2',   'ASFC', HCLAS )
      CALL HISTIN( HBGTA, 'DHBGTL', 'imbalance in column moist energy',
     &                                    'J/m**2/s', 'ASFC', HCLAS )
      CALL HISTIN( WBGTB, 'WBGTL',  'column water mass',
     &                                    'kg/m**2',  'ASFC', HCLAS )
      CALL HISTIN( WBGTA, 'DWBGTL', 'imbalance in column water mass',
     &                                    'kg/m**2/s','ASFC', HCLAS )
!      CALL HISTIN( DQTEND,'DQTEND', 'imbalance in water transfer',
!     &                                    'kg/kg',    'ASFC', HCLAS )
!      CALL HISTIN( DWATER,'DWATER', 'imbalance in total water flux',
!     &                                    'kg/kg/s',  'ASFC', HCLAS )
      CALL HISTIN( DSEDR, 'DSEDR',  'imbalance in sedimentation flux',
     &                                    'kg/kg',    'ASFC', HCLAS )
      CALL HISTIN( DSEDS, 'DSEDS',  'imbalance in sedimentation flux',
     &                                    'kg/kg',    'ASFC', HCLAS )
      CALL HISTIN( DSEDG, 'DSEDG',  'imbalance in sedimentation flux',
     &                                    'kg/kg',    'ASFC', HCLAS )
      CALL HISTIN( DSEDRS,'DSEDRS', 'imbalance in sedimentation flux',
     &                                    'kg/kg',    'ASFC', HCLAS )
*
      RETURN
      END
************************************************************************
      DOUBLE PRECISION FUNCTION GAMM( X )
      IMPLICIT NONE
      REAL*8, INTENT(IN) :: X
      REAL*8, PARAMETER :: COF1 = 76.18009172947146D0
      REAL*8, PARAMETER :: COF2 = -86.50532032941677D0
      REAL*8, PARAMETER :: COF3 = 24.01409824083091D0
      REAL*8, PARAMETER :: COF4 = -1.231739572450155D0
      REAL*8, PARAMETER :: COF5 = 1.208650973866179D-3
      REAL*8, PARAMETER :: COF6 = -5.395239384953D-6
      REAL*8, PARAMETER :: STP = 2.5066282746310005D0
      REAL*8  :: SER, TMP

      TMP = X + 5.5D0
      TMP = ( X + 0.5D0 ) * LOG( TMP ) - TMP
      SER = 1.000000000190015D0
     &     + COF1 / (X + 1.D0)
     &     + COF2 / (X + 2.D0)
     &     + COF3 / (X + 3.D0)
     &     + COF4 / (X + 4.D0)
     &     + COF5 / (X + 5.D0)
     &     + COF6 / (X + 6.D0)
      GAMM = EXP( TMP ) * ( STP * SER / X )
      END
**************************************
***   Precipitation Flux to Mixing Ratio for Rain and Snow
*
*     original code: pf_to_mr.f of COSP Radar Simulator
*     script modified by T.Michibata on 2018.07.01, for MIROC version
*     method from Khairoutdinov and Randall (JAS'03)
*
      SUBROUTINE PF2MR( IJSDIM,  KMAX,
     I                  GDP,     GDT,     GDZM,
     I                  GPRECL,  GPRECS,
     O                  DIAGQR,  DIAGRWP, DIAGQS,  DIAGSWP  )

      IMPLICIT NONE

*     [INPUT]
      INTEGER    IJSDIM
      INTEGER    KMAX
      REAL*8     GDP    ( IJSDIM, KMAX )      !! pressure
      REAL*8     GDT    ( IJSDIM, KMAX )      !! temperature
      REAL*8     GDZM   ( IJSDIM, KMAX+1 )    !! altitude
      REAL*8     GPRECL ( IJSDIM, KMAX )      !! large-scale precipitation flux (liquid)
      REAL*8     GPRECS ( IJSDIM, KMAX )      !! large-scale precipitation flux (solid)

*     [OUTPUT]
      REAL*8     DIAGQR ( IJSDIM, KMAX )      !! diagnosed Qr  [kg/kg]
      REAL*8     DIAGQS ( IJSDIM, KMAX )      !! diagnosed Qs  [kg/kg]
      REAL*8     DIAGRWP( IJSDIM )            !! diagnosed RWP [kg m-2]
      REAL*8     DIAGSWP( IJSDIM )            !! diagnosed SWP [kg m-2]

*     [LOCAL]
      INTEGER    IJ, K
      REAL*8     RHO
      REAL*8     DELZ
      REAL*8     AR, AS!, AG
      REAL*8     BR, BS!, BG
      REAL*8     NR, NS!, NG
      REAL*8     RHO0, RHOR, RHOS
      REAL*8     TERM1R, TERM1S
      REAL*8     TERM2R, TERM2S
      REAL*8     TERM3
      REAL*8     TERM4R_LS,TERM4S_LS
      REAL*8     TERM1X2R, TERM1X2S
      REAL*8     T123R, T123S
      REAL*8     PW

      !--- Initialize
      DIAGRWP(:)   = 0.D0
      DIAGSWP(:)   = 0.D0
      DIAGQR (:,:) = 0.D0
      DIAGQS (:,:) = 0.D0

      !--- List of constants from Appendix B
      !! Constant in fall speed formula
      AR = 842.D0
      AS = 4.84D0
      !! Exponent in fall speed formula
      BR = 0.8D0
      BS = 0.25D0
      !! Intercept parameter
      NR = 8.D0*1000.D0*1000.D0
      NS = 3.D0*1000.D0*1000.D0
      !! Densities for air and hydrometeors
      RHO0 = 1.29D0
      RHOR = 1000.D0
      RHOS = 100.D0
      !! Term 1 of Eq. (A19).
      TERM1R = AR*17.8379D0/6.D0
      TERM1S = AS*8.28508D0/6.D0
      !! Term 2 of Eq. (A19).
      TERM2R = (3.14159265*RHOR*NR)**(-BR/4.D0)
      TERM2S = (3.14159265*RHOS*NS)**(-BS/4.D0)

      TERM1X2R = TERM1R*TERM2R
      TERM1X2S = TERM1S*TERM2S

      PW = 1.D0/(1.D0+BR/4.D0)

      DO K = 1, KMAX
         DO IJ = 1, IJSDIM
            RHO = GDP(IJ,K)/(287.05D0*GDT(IJ,K))
            DELZ = GDZM( IJ,K+1 ) - GDZM(IJ,K)
            TERM3 = SQRT(RHO0/RHO)
            !! Term 4 of Eq. (A19).
            T123R = TERM1X2R*TERM3
            T123S = TERM1X2S*TERM3
            TERM4R_LS = GPRECL(IJ,K)/(T123R)
            TERM4S_LS = GPRECS(IJ,K)/(T123S)
            !! Flux to M.X.Ratio
            DIAGQR(IJ,K) = TERM4R_LS**PW / RHO
            DIAGQS(IJ,K) = TERM4S_LS**PW / RHO
            !! Vertical Accumulated Path
            DIAGRWP(IJ)  = DIAGRWP(IJ) + RHO*DIAGQR(IJ,K)*DELZ
            DIAGSWP(IJ)  = DIAGSWP(IJ) + RHO*DIAGQS(IJ,K)*DELZ
         ENDDO
      ENDDO

      RETURN
      END 
