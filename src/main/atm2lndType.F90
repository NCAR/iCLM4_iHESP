module atm2lndType

  !-----------------------------------------------------------------------
  ! !DESCRIPTION:
  ! Handle atm2lnd, lnd2atm mapping
  !
  ! !USES:
  use shr_kind_mod  , only : r8 => shr_kind_r8
  use shr_infnan_mod, only : nan => shr_infnan_nan, assignment(=)
  use shr_log_mod   , only : errMsg => shr_log_errMsg
  use clm_varpar    , only : numrad, ndst, nlevgrnd !ndst = number of dust bins.
  use clm_varcon    , only : rair, grav, cpair, hfus, tfrz, spval
  use clm_varctl    , only : iulog, use_c13, use_cn, use_lch4, use_cndv, use_ed
  use decompMod     , only : bounds_type
  use abortutils    , only : endrun
  use PatchType     , only : patch
  !
  ! !PUBLIC TYPES:
  implicit none
  private
  save
  !
  ! !PUBLIC DATA TYPES:
  !----------------------------------------------------
  ! atmosphere -> land variables structure
  !
  ! NOTE:
  ! IF there are forcing variables that are downscaled - then the
  ! non-downscaled versions SHOULD NOT be used in the code. Currently
  ! the non-downscaled versions are only used n a handful of places in
  ! the code (and needs to be used in lnd_import_export and the
  ! downscaling routines), but in general should NOT be used in new
  ! code. Instead use the datatype variables that have a _col suffix
  ! which gives the downscaled versions of these fields.
  !----------------------------------------------------
  type, public :: atm2lnd_type

     ! atm->lnd not downscaled
     real(r8), pointer :: forc_u_grc                    (:)   => null() ! atm wind speed, east direction (m/s)
     real(r8), pointer :: forc_v_grc                    (:)   => null() ! atm wind speed, north direction (m/s)
     real(r8), pointer :: forc_wind_grc                 (:)   => null() ! atmospheric wind speed
     real(r8), pointer :: forc_hgt_grc                  (:)   => null() ! atmospheric reference height (m)
     real(r8), pointer :: forc_hgt_u_grc                (:)   => null() ! obs height of wind [m] (new)
     real(r8), pointer :: forc_hgt_t_grc                (:)   => null() ! obs height of temperature [m] (new)
     real(r8), pointer :: forc_hgt_q_grc                (:)   => null() ! obs height of humidity [m] (new)
     real(r8), pointer :: forc_vp_grc                   (:)   => null() ! atmospheric vapor pressure (Pa)
     real(r8), pointer :: forc_rh_grc                   (:)   => null() ! atmospheric relative humidity (%)
     real(r8), pointer :: forc_psrf_grc                 (:)   => null() ! surface pressure (Pa)
     real(r8), pointer :: forc_pco2_grc                 (:)   => null() ! CO2 partial pressure (Pa)
     real(r8), pointer :: forc_solad_grc                (:,:) => null() ! direct beam radiation (numrad) (vis=forc_sols , nir=forc_soll )
     real(r8), pointer :: forc_solai_grc                (:,:) => null() ! diffuse radiation (numrad) (vis=forc_solsd, nir=forc_solld)
     real(r8), pointer :: forc_solar_grc                (:)   => null() ! incident solar radiation
     real(r8), pointer :: forc_ndep_grc                 (:)   => null() ! nitrogen deposition rate (gN/m2/s)
     real(r8), pointer :: forc_pc13o2_grc               (:)   => null() ! C13O2 partial pressure (Pa)
     real(r8), pointer :: forc_po2_grc                  (:)   => null() ! O2 partial pressure (Pa)
     real(r8), pointer :: forc_aer_grc                  (:,:) => null() ! aerosol deposition array
     real(r8), pointer :: forc_pch4_grc                 (:)   => null() ! CH4 partial pressure (Pa)

     real(r8), pointer :: forc_t_not_downscaled_grc     (:)   => null() ! not downscaled atm temperature (Kelvin)       
     real(r8), pointer :: forc_th_not_downscaled_grc    (:)   => null() ! not downscaled atm potential temperature (Kelvin)    
     real(r8), pointer :: forc_q_not_downscaled_grc     (:)   => null() ! not downscaled atm specific humidity (kg/kg)  
     real(r8), pointer :: forc_pbot_not_downscaled_grc  (:)   => null() ! not downscaled atm pressure (Pa)              
     real(r8), pointer :: forc_rho_not_downscaled_grc   (:)   => null() ! not downscaled atm density (kg/m**3)                      
     real(r8), pointer :: forc_rain_not_downscaled_grc  (:)   => null() ! not downscaled atm rain rate [mm/s]                       
     real(r8), pointer :: forc_snow_not_downscaled_grc  (:)   => null() ! not downscaled atm snow rate [mm/s]                       
     real(r8), pointer :: forc_lwrad_not_downscaled_grc (:)   => null() ! not downscaled atm downwrd IR longwave radiation (W/m**2) 

     ! atm->lnd downscaled
     real(r8), pointer :: forc_t_downscaled_col         (:)   => null() ! downscaled atm temperature (Kelvin)
     real(r8), pointer :: forc_th_downscaled_col        (:)   => null() ! downscaled atm potential temperature (Kelvin)
     real(r8), pointer :: forc_q_downscaled_col         (:)   => null() ! downscaled atm specific humidity (kg/kg)
     real(r8), pointer :: forc_pbot_downscaled_col      (:)   => null() ! downscaled atm pressure (Pa)
     real(r8), pointer :: forc_rho_downscaled_col       (:)   => null() ! downscaled atm density (kg/m**3)
     real(r8), pointer :: forc_rain_downscaled_col      (:)   => null() ! downscaled atm rain rate [mm/s]
     real(r8), pointer :: forc_snow_downscaled_col      (:)   => null() ! downscaled atm snow rate [mm/s]
     real(r8), pointer :: forc_lwrad_downscaled_col     (:)   => null() ! downscaled atm downwrd IR longwave radiation (W/m**2)

     !  rof->lnd
     real(r8), pointer :: forc_flood_grc                (:)   => null() ! rof flood (mm/s)
     real(r8), pointer :: volr_grc                      (:)   => null() ! rof volr (m3)

     ! anomaly forcing
     real(r8), pointer :: af_precip_grc                 (:)   => null() ! anomaly forcing 
     real(r8), pointer :: af_uwind_grc                  (:)   => null() ! anomaly forcing 
     real(r8), pointer :: af_vwind_grc                  (:)   => null() ! anomaly forcing 
     real(r8), pointer :: af_tbot_grc                   (:)   => null() ! anomaly forcing 
     real(r8), pointer :: af_pbot_grc                   (:)   => null() ! anomaly forcing 
     real(r8), pointer :: af_shum_grc                   (:)   => null() ! anomaly forcing 
     real(r8), pointer :: af_swdn_grc                   (:)   => null() ! anomaly forcing 
     real(r8), pointer :: af_lwdn_grc                   (:)   => null() ! anomaly forcing 
     real(r8), pointer :: bc_precip_grc                 (:)   => null() ! anomaly forcing - add bias correction

     ! time averaged quantities
     real(r8) , pointer :: fsd24_patch                  (:)   => null() ! patch 24hr average of direct beam radiation 
     real(r8) , pointer :: fsd240_patch                 (:)   => null() ! patch 240hr average of direct beam radiation 
     real(r8) , pointer :: fsi24_patch                  (:)   => null() ! patch 24hr average of diffuse beam radiation 
     real(r8) , pointer :: fsi240_patch                 (:)   => null() ! patch 240hr average of diffuse beam radiation 
     real(r8) , pointer :: prec365_patch                (:)   => null() ! patch 365-day running mean of tot. precipitation
     real(r8) , pointer :: prec60_patch                 (:)   => null() ! patch 60-day running mean of tot. precipitation (mm/s) 
     real(r8) , pointer :: prec10_patch                 (:)   => null() ! patch 10-day running mean of tot. precipitation (mm/s) 
     real(r8) , pointer :: prec24_patch                 (:)   => null() ! patch 24-hour running mean of tot. precipitation (mm/s) 
     real(r8) , pointer :: rh24_patch                   (:)   => null() ! patch 24-hour running mean of relative humidity
     real(r8) , pointer :: wind24_patch                 (:)   => null() ! patch 24-hour running mean of wind
     real(r8) , pointer :: t_mo_patch                   (:)   => null() ! patch 30-day average temperature (Kelvin)
     real(r8) , pointer :: t_mo_min_patch               (:)   => null() ! patch annual min of t_mo (Kelvin)

   contains

     procedure, public  :: Init
     procedure, private :: InitAllocate 
     procedure, private :: InitHistory  
     procedure, public  :: InitAccBuffer
     procedure, public  :: InitAccVars
     procedure, public  :: UpdateAccVars
     procedure, public  :: Restart

  end type atm2lnd_type
  !----------------------------------------------------

contains

  !------------------------------------------------------------------------
  subroutine Init(this, bounds)

    class(atm2lnd_type) :: this
    type(bounds_type), intent(in) :: bounds  

    call this%InitAllocate(bounds)
    call this%InitHistory(bounds)
    
  end subroutine Init

  !------------------------------------------------------------------------
  subroutine InitAllocate(this, bounds)
    !
    ! !DESCRIPTION:
    ! Initialize atm2lnd derived type
    !
    ! !ARGUMENTS:
    class(atm2lnd_type) :: this
    type(bounds_type), intent(in) :: bounds  
    !
    ! !LOCAL VARIABLES:
    real(r8) :: ival  = 0.0_r8  ! initial value
    integer  :: begg, endg
    integer  :: begc, endc
    integer  :: begp, endp
    !------------------------------------------------------------------------

    begg = bounds%begg; endg= bounds%endg
    begc = bounds%begc; endc= bounds%endc
    begp = bounds%begp; endp= bounds%endp

    ! atm->lnd
    allocate(this%forc_u_grc                    (begg:endg))        ; this%forc_u_grc                    (:)   = ival
    allocate(this%forc_v_grc                    (begg:endg))        ; this%forc_v_grc                    (:)   = ival
    allocate(this%forc_wind_grc                 (begg:endg))        ; this%forc_wind_grc                 (:)   = ival
    allocate(this%forc_rh_grc                   (begg:endg))        ; this%forc_rh_grc                   (:)   = ival
    allocate(this%forc_hgt_grc                  (begg:endg))        ; this%forc_hgt_grc                  (:)   = ival
    allocate(this%forc_hgt_u_grc                (begg:endg))        ; this%forc_hgt_u_grc                (:)   = ival
    allocate(this%forc_hgt_t_grc                (begg:endg))        ; this%forc_hgt_t_grc                (:)   = ival
    allocate(this%forc_hgt_q_grc                (begg:endg))        ; this%forc_hgt_q_grc                (:)   = ival
    allocate(this%forc_vp_grc                   (begg:endg))        ; this%forc_vp_grc                   (:)   = ival
    allocate(this%forc_psrf_grc                 (begg:endg))        ; this%forc_psrf_grc                 (:)   = ival
    allocate(this%forc_pco2_grc                 (begg:endg))        ; this%forc_pco2_grc                 (:)   = ival
    allocate(this%forc_solad_grc                (begg:endg,numrad)) ; this%forc_solad_grc                (:,:) = ival
    allocate(this%forc_solai_grc                (begg:endg,numrad)) ; this%forc_solai_grc                (:,:) = ival
    allocate(this%forc_solar_grc                (begg:endg))        ; this%forc_solar_grc                (:)   = ival
    allocate(this%forc_ndep_grc                 (begg:endg))        ; this%forc_ndep_grc                 (:)   = ival
    allocate(this%forc_pc13o2_grc               (begg:endg))        ; this%forc_pc13o2_grc               (:)   = ival
    allocate(this%forc_po2_grc                  (begg:endg))        ; this%forc_po2_grc                  (:)   = ival
    allocate(this%forc_aer_grc                  (begg:endg,14))     ; this%forc_aer_grc                  (:,:) = ival
    allocate(this%forc_pch4_grc                 (begg:endg))        ; this%forc_pch4_grc                 (:)   = ival

    ! atm->lnd not downscaled
    allocate(this%forc_t_not_downscaled_grc     (begg:endg))        ; this%forc_t_not_downscaled_grc     (:)   = ival
    allocate(this%forc_q_not_downscaled_grc     (begg:endg))        ; this%forc_q_not_downscaled_grc     (:)   = ival
    allocate(this%forc_pbot_not_downscaled_grc  (begg:endg))        ; this%forc_pbot_not_downscaled_grc  (:)   = ival
    allocate(this%forc_th_not_downscaled_grc    (begg:endg))        ; this%forc_th_not_downscaled_grc    (:)   = ival
    allocate(this%forc_rho_not_downscaled_grc   (begg:endg))        ; this%forc_rho_not_downscaled_grc   (:)   = ival
    allocate(this%forc_lwrad_not_downscaled_grc (begg:endg))        ; this%forc_lwrad_not_downscaled_grc (:)   = ival
    allocate(this%forc_rain_not_downscaled_grc  (begg:endg))        ; this%forc_rain_not_downscaled_grc  (:)   = ival
    allocate(this%forc_snow_not_downscaled_grc  (begg:endg))        ; this%forc_snow_not_downscaled_grc  (:)   = ival
    
    ! atm->lnd downscaled
    allocate(this%forc_t_downscaled_col         (begc:endc))        ; this%forc_t_downscaled_col         (:)   = ival
    allocate(this%forc_q_downscaled_col         (begc:endc))        ; this%forc_q_downscaled_col         (:)   = ival
    allocate(this%forc_pbot_downscaled_col      (begc:endc))        ; this%forc_pbot_downscaled_col      (:)   = ival
    allocate(this%forc_th_downscaled_col        (begc:endc))        ; this%forc_th_downscaled_col        (:)   = ival
    allocate(this%forc_rho_downscaled_col       (begc:endc))        ; this%forc_rho_downscaled_col       (:)   = ival
    allocate(this%forc_lwrad_downscaled_col     (begc:endc))        ; this%forc_lwrad_downscaled_col     (:)   = ival
    allocate(this%forc_rain_downscaled_col      (begc:endc))        ; this%forc_rain_downscaled_col      (:)   = ival
    allocate(this%forc_snow_downscaled_col      (begc:endc))        ; this%forc_snow_downscaled_col      (:)   = ival

    ! rof->lnd
    allocate(this%forc_flood_grc                (begg:endg))        ; this%forc_flood_grc                (:)   = ival
    allocate(this%volr_grc                      (begg:endg))        ; this%volr_grc                      (:)   = ival

    ! anomaly forcing
    allocate(this%bc_precip_grc                 (begg:endg))        ; this%bc_precip_grc                 (:)   = ival
    allocate(this%af_precip_grc                 (begg:endg))        ; this%af_precip_grc                 (:)   = ival
    allocate(this%af_uwind_grc                  (begg:endg))        ; this%af_uwind_grc                  (:)   = ival
    allocate(this%af_vwind_grc                  (begg:endg))        ; this%af_vwind_grc                  (:)   = ival
    allocate(this%af_tbot_grc                   (begg:endg))        ; this%af_tbot_grc                   (:)   = ival
    allocate(this%af_pbot_grc                   (begg:endg))        ; this%af_pbot_grc                   (:)   = ival
    allocate(this%af_shum_grc                   (begg:endg))        ; this%af_shum_grc                   (:)   = ival
    allocate(this%af_swdn_grc                   (begg:endg))        ; this%af_swdn_grc                   (:)   = ival
    allocate(this%af_lwdn_grc                   (begg:endg))        ; this%af_lwdn_grc                   (:)   = ival

    allocate(this%fsd24_patch                   (begp:endp))        ; this%fsd24_patch                   (:)   = nan
    allocate(this%fsd240_patch                  (begp:endp))        ; this%fsd240_patch                  (:)   = nan
    allocate(this%fsi24_patch                   (begp:endp))        ; this%fsi24_patch                   (:)   = nan
    allocate(this%fsi240_patch                  (begp:endp))        ; this%fsi240_patch                  (:)   = nan
    allocate(this%prec10_patch                  (begp:endp))        ; this%prec10_patch                  (:)   = nan
    allocate(this%prec60_patch                  (begp:endp))        ; this%prec60_patch                  (:)   = nan
    allocate(this%prec365_patch                 (begp:endp))        ; this%prec365_patch                 (:)   = nan
    if (use_ed) then
       allocate(this%prec24_patch               (begp:endp))        ; this%prec24_patch                  (:)   = nan
       allocate(this%rh24_patch                 (begp:endp))        ; this%rh24_patch                    (:)   = nan
       allocate(this%wind24_patch               (begp:endp))        ; this%wind24_patch                  (:)   = nan
    end if
    allocate(this%t_mo_patch                    (begp:endp))        ; this%t_mo_patch               (:)   = nan
    allocate(this%t_mo_min_patch                (begp:endp))        ; this%t_mo_min_patch           (:)   = spval ! TODO - initialize this elsewhere

  end subroutine InitAllocate

  !------------------------------------------------------------------------
  subroutine InitHistory(this, bounds)
    !
    ! !USES:
    use histFileMod, only : hist_addfld1d
    !
    ! !ARGUMENTS:
    class(atm2lnd_type) :: this
    type(bounds_type), intent(in) :: bounds  
    !
    ! !LOCAL VARIABLES:
    integer  :: begg, endg
    integer  :: begp, endp
    !---------------------------------------------------------------------

    begg = bounds%begg; endg= bounds%endg
    begp = bounds%begp; endp= bounds%endp

    this%forc_flood_grc(begg:endg) = spval
    call hist_addfld1d (fname='QFLOOD',  units='mm/s',  &
         avgflag='A', long_name='runoff from river flooding', &
         ptr_lnd=this%forc_flood_grc)

    this%volr_grc(begg:endg) = spval
    call hist_addfld1d (fname='VOLR',  units='m3',  &
         avgflag='A', long_name='river channel water storage', &
         ptr_lnd=this%volr_grc)

    this%forc_wind_grc(begg:endg) = spval
    call hist_addfld1d (fname='WIND', units='m/s',  &
         avgflag='A', long_name='atmospheric wind velocity magnitude', &
         ptr_lnd=this%forc_wind_grc)
    ! Rename of WIND for Urban intercomparision project
    call hist_addfld1d (fname='Wind', units='m/s',  &
         avgflag='A', long_name='atmospheric wind velocity magnitude', &
         ptr_gcell=this%forc_wind_grc, default = 'inactive')

    this%forc_hgt_grc(begg:endg) = spval
    call hist_addfld1d (fname='ZBOT', units='m',  &
         avgflag='A', long_name='atmospheric reference height', &
         ptr_lnd=this%forc_hgt_grc)

    this%forc_solar_grc(begg:endg) = spval
    call hist_addfld1d (fname='FSDS', units='W/m^2',  &
         avgflag='A', long_name='atmospheric incident solar radiation', &
         ptr_lnd=this%forc_solar_grc)

    this%forc_pco2_grc(begg:endg) = spval
    call hist_addfld1d (fname='PCO2', units='Pa',  &
         avgflag='A', long_name='atmospheric partial pressure of CO2', &
         ptr_lnd=this%forc_pco2_grc)

    this%forc_solar_grc(begg:endg) = spval
    call hist_addfld1d (fname='SWdown', units='W/m^2',  &
         avgflag='A', long_name='atmospheric incident solar radiation', &
         ptr_gcell=this%forc_solar_grc, default='inactive')

    this%forc_rh_grc(begg:endg) = spval
    call hist_addfld1d (fname='RH', units='%',  &
         avgflag='A', long_name='atmospheric relative humidity', &
         ptr_gcell=this%forc_rh_grc, default='inactive')

    if (use_lch4) then
       this%forc_pch4_grc(begg:endg) = spval
       call hist_addfld1d (fname='PCH4', units='Pa',  &
            avgflag='A', long_name='atmospheric partial pressure of CH4', &
            ptr_lnd=this%forc_pch4_grc)
    end if

    this%forc_t_not_downscaled_grc(begg:endg) = spval
    call hist_addfld1d (fname='Tair', units='K',  &
         avgflag='A', long_name='atmospheric air temperature', &
         ptr_gcell=this%forc_t_not_downscaled_grc, default='inactive')

    this%forc_pbot_not_downscaled_grc(begg:endg) = spval
    call hist_addfld1d (fname='PSurf', units='Pa',  &
         avgflag='A', long_name='surface pressure', &
         ptr_gcell=this%forc_pbot_not_downscaled_grc, default='inactive')

    this%forc_rain_not_downscaled_grc(begg:endg) = spval
    call hist_addfld1d (fname='Rainf', units='mm/s',  &
         avgflag='A', long_name='atmospheric rain', &
         ptr_gcell=this%forc_rain_not_downscaled_grc, default='inactive')

    this%forc_lwrad_not_downscaled_grc(begg:endg) = spval
    call hist_addfld1d (fname='LWdown', units='W/m^2',  &
         avgflag='A', long_name='atmospheric longwave radiation', &
         ptr_gcell=this%forc_lwrad_not_downscaled_grc, default='inactive')

    this%forc_rain_not_downscaled_grc(begg:endg) = spval
    call hist_addfld1d (fname='RAIN', units='mm/s',  &
         avgflag='A', long_name='atmospheric rain', &
         ptr_lnd=this%forc_rain_not_downscaled_grc)

    this%forc_snow_not_downscaled_grc(begg:endg) = spval
    call hist_addfld1d (fname='SNOW', units='mm/s',  &
         avgflag='A', long_name='atmospheric snow', &
         ptr_lnd=this%forc_snow_not_downscaled_grc)

    this%forc_t_not_downscaled_grc(begg:endg) = spval
    call hist_addfld1d (fname='TBOT', units='K',  &
         avgflag='A', long_name='atmospheric air temperature', &
         ptr_lnd=this%forc_t_not_downscaled_grc)

    this%forc_th_not_downscaled_grc(begg:endg) = spval
    call hist_addfld1d (fname='THBOT', units='K',  &
         avgflag='A', long_name='atmospheric air potential temperature', &
         ptr_lnd=this%forc_th_not_downscaled_grc)

    this%forc_q_not_downscaled_grc(begg:endg) = spval
    call hist_addfld1d (fname='QBOT', units='kg/kg',  &
         avgflag='A', long_name='atmospheric specific humidity', &
         ptr_lnd=this%forc_q_not_downscaled_grc)
    ! Rename of QBOT for Urban intercomparision project
    this%forc_q_not_downscaled_grc(begg:endg) = spval
    call hist_addfld1d (fname='Qair', units='kg/kg',  &
         avgflag='A', long_name='atmospheric specific humidity', &
         ptr_lnd=this%forc_q_not_downscaled_grc, default='inactive')

    this%forc_lwrad_not_downscaled_grc(begg:endg) = spval
    call hist_addfld1d (fname='FLDS', units='W/m^2',  &
         avgflag='A', long_name='atmospheric longwave radiation', &
         ptr_lnd=this%forc_lwrad_not_downscaled_grc)

    this%forc_pbot_not_downscaled_grc(begg:endg) = spval
    call hist_addfld1d (fname='PBOT', units='Pa',  &
         avgflag='A', long_name='atmospheric pressure', &
         ptr_lnd=this%forc_pbot_not_downscaled_grc)

    ! Time averaged quantities
    this%fsi24_patch(begp:endp) = spval
    call hist_addfld1d (fname='FSI24', units='K',  &
         avgflag='A', long_name='indirect radiation (last 24hrs)', &
         ptr_patch=this%fsi24_patch, default='inactive')

    this%fsi240_patch(begp:endp) = spval
    call hist_addfld1d (fname='FSI240', units='K',  &
         avgflag='A', long_name='indirect radiation (last 240hrs)', &
         ptr_patch=this%fsi240_patch, default='inactive')

    this%fsd24_patch(begp:endp) = spval
    call hist_addfld1d (fname='FSD24', units='K',  &
         avgflag='A', long_name='direct radiation (last 24hrs)', &
         ptr_patch=this%fsd24_patch, default='inactive')

    this%fsd240_patch(begp:endp) = spval
    call hist_addfld1d (fname='FSD240', units='K',  &
         avgflag='A', long_name='direct radiation (last 240hrs)', &
         ptr_patch=this%fsd240_patch, default='inactive')

    if (use_cndv) then
       call hist_addfld1d (fname='TDA', units='K',  &
            avgflag='A', long_name='daily average 2-m temperature', &
            ptr_patch=this%t_mo_patch)
    end if

  end subroutine InitHistory

  !-----------------------------------------------------------------------
  subroutine InitAccBuffer (this, bounds)
    !
    ! !DESCRIPTION:
    ! Initialize accumulation buffer for all required module accumulated fields
    ! This routine set defaults values that are then overwritten by the
    ! restart file for restart or branch runs
    !
    ! !USES 
    use clm_varcon  , only : spval
    use accumulMod  , only : init_accum_field
    !
    ! !ARGUMENTS:
    class(atm2lnd_type) :: this
    type(bounds_type), intent(in) :: bounds  
    !---------------------------------------------------------------------

    this%fsd24_patch(bounds%begp:bounds%endp) = spval
    call init_accum_field (name='FSD24', units='W/m2',                                             &
         desc='24hr average of direct solar radiation',  accum_type='runmean', accum_period=-1,    &
         subgrid_type='pft', numlev=1, init_value=0._r8)

    this%fsd240_patch(bounds%begp:bounds%endp) = spval
    call init_accum_field (name='FSD240', units='W/m2',                                            &
         desc='240hr average of direct solar radiation',  accum_type='runmean', accum_period=-10,  &
         subgrid_type='pft', numlev=1, init_value=0._r8)

    this%fsi24_patch(bounds%begp:bounds%endp) = spval
    call init_accum_field (name='FSI24', units='W/m2',                                             &
         desc='24hr average of diffuse solar radiation',  accum_type='runmean', accum_period=-1,   &
         subgrid_type='pft', numlev=1, init_value=0._r8)

    this%fsi240_patch(bounds%begp:bounds%endp) = spval
    call init_accum_field (name='FSI240', units='W/m2',                                            &
         desc='240hr average of diffuse solar radiation',  accum_type='runmean', accum_period=-10, &
         subgrid_type='pft', numlev=1, init_value=0._r8)

    if (use_cn) then
       call init_accum_field (name='PREC10', units='MM H2O/S', &
            desc='10-day running mean of total precipitation', accum_type='runmean', accum_period=-10, &
            subgrid_type='pft', numlev=1, init_value=0._r8)

       call init_accum_field (name='PREC60', units='MM H2O/S', &
            desc='60-day running mean of total precipitation', accum_type='runmean', accum_period=-60, &
            subgrid_type='pft', numlev=1, init_value=0._r8)
    end if

    if (use_cndv) then
       ! The following is a running mean with the accumulation period is set to -365 for a 365-day running mean.
       call init_accum_field (name='PREC365', units='MM H2O/S', &
            desc='365-day running mean of total precipitation', accum_type='runmean', accum_period=-365, &
            subgrid_type='pft', numlev=1, init_value=0._r8)
    end if

    if ( use_ed ) then
       call init_accum_field (name='PREC24', units='m', &
            desc='24hr sum of precipitation', accum_type='runmean', accum_period=-1, &
            subgrid_type='pft', numlev=1, init_value=0._r8)

       ! Fudge - this neds to be initialized from the restat file eventually. 
       call init_accum_field (name='RH24', units='m', &
            desc='24hr average of RH', accum_type='runmean', accum_period=-1, &
            subgrid_type='pft', numlev=1, init_value=100._r8) 

       call init_accum_field (name='WIND24', units='m', &
            desc='24hr average of wind', accum_type='runmean', accum_period=-1, &
            subgrid_type='pft', numlev=1, init_value=0._r8)
    end if

  end subroutine InitAccBuffer

  !-----------------------------------------------------------------------
  subroutine InitAccVars(this, bounds)
    !
    ! !DESCRIPTION:
    ! Initialize module variables that are associated with
    ! time accumulated fields. This routine is called for both an initial run
    ! and a restart run (and must therefore must be called after the restart file 
    ! is read in and the accumulation buffer is obtained)
    !
    ! !USES 
    use accumulMod       , only : extract_accum_field
    use clm_time_manager , only : get_nstep
    !
    ! !ARGUMENTS:
    class(atm2lnd_type) :: this
    type(bounds_type), intent(in) :: bounds  
    !
    ! !LOCAL VARIABLES:
    integer  :: begp, endp
    integer  :: nstep
    integer  :: ier
    real(r8), pointer :: rbufslp(:)  ! temporary
    !---------------------------------------------------------------------

    begp = bounds%begp; endp = bounds%endp

    ! Allocate needed dynamic memory for single level patch field
    allocate(rbufslp(begp:endp), stat=ier)
    if (ier/=0) then
       write(iulog,*)' in '
       call endrun(msg="extract_accum_hist allocation error for rbufslp"//&
            errMsg(__FILE__, __LINE__))
    endif

    ! Determine time step
    nstep = get_nstep()

    call extract_accum_field ('FSD24', rbufslp, nstep)
    this%fsd24_patch(begp:endp) = rbufslp(begp:endp)

    call extract_accum_field ('FSD240', rbufslp, nstep)
    this%fsd240_patch(begp:endp) = rbufslp(begp:endp)

    call extract_accum_field ('FSI24', rbufslp, nstep)
    this%fsi24_patch(begp:endp) = rbufslp(begp:endp)

    call extract_accum_field ('FSI240', rbufslp, nstep)
    this%fsi240_patch(begp:endp) = rbufslp(begp:endp)

    if (use_cn) then
       call extract_accum_field ('PREC10', rbufslp, nstep)
       this%prec10_patch(begp:endp) = rbufslp(begp:endp)

       call extract_accum_field ('PREC60', rbufslp, nstep)
       this%prec60_patch(begp:endp) = rbufslp(begp:endp)
    end if

    if (use_cndv) then
       call extract_accum_field ('PREC365' , rbufslp, nstep) 
       this%prec365_patch(begp:endp) = rbufslp(begp:endp)

       call extract_accum_field ('TDA', rbufslp, nstep) 
       this%t_mo_patch(begp:endp) = rbufslp(begp:endp)
    end if

    if (use_ed) then
       call extract_accum_field ('PREC24', rbufslp, nstep)
       this%prec24_patch(begp:endp) = rbufslp(begp:endp)

       call extract_accum_field ('RH24', rbufslp, nstep)
       this%rh24_patch(begp:endp) = rbufslp(begp:endp)

       call extract_accum_field ('WIND24', rbufslp, nstep)
       this%wind24_patch(begp:endp) = rbufslp(begp:endp)
    end if

    deallocate(rbufslp)

  end subroutine InitAccVars

  !-----------------------------------------------------------------------
  subroutine UpdateAccVars (this, bounds)
    !
    ! USES
    use clm_time_manager, only : get_nstep
    use accumulMod      , only : update_accum_field, extract_accum_field
    !
    ! !ARGUMENTS:
    class(atm2lnd_type)                 :: this
    type(bounds_type)      , intent(in) :: bounds  
    !
    ! !LOCAL VARIABLES:
    integer :: g,c,p                     ! indices
    integer :: dtime                     ! timestep size [seconds]
    integer :: nstep                     ! timestep number
    integer :: ier                       ! error status
    integer :: begp, endp
    real(r8), pointer :: rbufslp(:)      ! temporary single level - patch level
    !---------------------------------------------------------------------

    begp = bounds%begp; endp = bounds%endp

    nstep = get_nstep()

    ! Allocate needed dynamic memory for single level patch field

    allocate(rbufslp(begp:endp), stat=ier)
    if (ier/=0) then
       write(iulog,*)'update_accum_hist allocation error for rbuf1dp'
       call endrun(msg=errMsg(__FILE__, __LINE__))
    endif

    ! Accumulate and extract forc_solad24 & forc_solad240 
    do p = begp,endp
       g = patch%gridcell(p)
       rbufslp(p) = this%forc_solad_grc(g,1)
    end do
    call update_accum_field  ('FSD240', rbufslp               , nstep)
    call extract_accum_field ('FSD240', this%fsd240_patch     , nstep)
    call update_accum_field  ('FSD24' , rbufslp               , nstep)
    call extract_accum_field ('FSD24' , this%fsd24_patch      , nstep)

    ! Accumulate and extract forc_solai24 & forc_solai240 
    do p = begp,endp
       g = patch%gridcell(p)
       rbufslp(p) = this%forc_solai_grc(g,1)
    end do
    call update_accum_field  ('FSI24' , rbufslp               , nstep)
    call extract_accum_field ('FSI24' , this%fsi24_patch      , nstep)
    call update_accum_field  ('FSI240', rbufslp               , nstep)
    call extract_accum_field ('FSI240', this%fsi240_patch     , nstep)

    do p = begp,endp
       c = patch%column(p)
       rbufslp(p) = this%forc_rain_downscaled_col(c) + this%forc_snow_downscaled_col(c)
    end do

    if (use_cn) then
       ! Accumulate and extract PREC60 (accumulates total precipitation as 60-day running mean)
       call update_accum_field  ('PREC60', rbufslp, nstep)
       call extract_accum_field ('PREC60', this%prec60_patch, nstep)

       ! Accumulate and extract PREC10 (accumulates total precipitation as 10-day running mean)
       call update_accum_field  ('PREC10', rbufslp, nstep)
       call extract_accum_field ('PREC10', this%prec10_patch, nstep)
    end if

    if (use_cndv) then
       ! Accumulate and extract PREC365 (accumulates total precipitation as 365-day running mean)
       call update_accum_field  ('PREC365', rbufslp, nstep)
       call extract_accum_field ('PREC365', this%prec365_patch, nstep)

       ! Accumulate and extract TDA (accumulates TBOT as 30-day average) and 
       ! also determines t_mo_min
       
       do p = begp,endp
          c = patch%column(p)
          rbufslp(p) = this%forc_t_downscaled_col(c)
       end do
       call update_accum_field  ('TDA', rbufslp, nstep)
       call extract_accum_field ('TDA', rbufslp, nstep)
       do p = begp,endp
          this%t_mo_patch(p) = rbufslp(p)
          this%t_mo_min_patch(p) = min(this%t_mo_min_patch(p), rbufslp(p))
       end do

    end if

    if (use_ed) then
       call update_accum_field  ('PREC24', rbufslp, nstep)
       call extract_accum_field ('PREC24', this%prec24_patch, nstep)

       do p = bounds%begp,bounds%endp
          c = patch%column(p)
          rbufslp(p) = this%forc_wind_grc(g) 
       end do
       call update_accum_field  ('WIND24', rbufslp, nstep)
       call extract_accum_field ('WIND24', this%wind24_patch, nstep)

       do p = bounds%begp,bounds%endp
          c = patch%column(p)
          rbufslp(p) = this%forc_rh_grc(g) 
       end do
       call update_accum_field  ('RH24', rbufslp, nstep)
       call extract_accum_field ('RH24', this%rh24_patch, nstep)
    end if

    deallocate(rbufslp)

  end subroutine UpdateAccVars

  !------------------------------------------------------------------------
  subroutine Restart(this, bounds, ncid, flag)
    ! 
    ! !USES:
    use restUtilMod
    use ncdio_pio
    !
    ! !ARGUMENTS:
    class(atm2lnd_type) :: this
    type(bounds_type), intent(in) :: bounds  
    type(file_desc_t), intent(inout) :: ncid   
    character(len=*) , intent(in)    :: flag   
    !
    ! !LOCAL VARIABLES:
    logical            :: readvar 
    !------------------------------------------------------------------------

    call restartvar(ncid=ncid, flag=flag, varname='qflx_floodg', xtype=ncd_double, &
         dim1name='gridcell', &
         long_name='flood water flux', units='mm/s', &
         interpinic_flag='skip', readvar=readvar, data=this%forc_flood_grc)
    if (flag == 'read' .and. .not. readvar) then
       ! initial run, readvar=readvar, not restart: initialize flood to zero
       this%forc_flood_grc = 0._r8
    endif

    if (use_cndv) then
       call restartvar(ncid=ncid, flag=flag, varname='T_MO_MIN', xtype=ncd_double,  &
            dim1name='pft', long_name='', units='', &
            interpinic_flag='interp', readvar=readvar, data=this%t_mo_min_patch)
    end if

  end subroutine Restart

end module atm2lndType
