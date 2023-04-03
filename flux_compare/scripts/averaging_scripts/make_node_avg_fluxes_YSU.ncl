;***************************************
; PROGRAM DESCRIPTION: This script plots frequency information for
;                      a SOM trained with three data sets
; INPUT DATA: SOM date and visual files for three data types
; OUTPUT DATA: One  plot of frequency comparisons
; CREATOR: Matt Higgins(Oct 2008), Melissa Nigro (Aug 2011)
;          Modified by Alice DuVivier - April 2012
; NOTE: To see full WRF YSU surface layer calculations see
;       flux_compare_wrf-vic-noah.ncl
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************
begin
; MANUAL INPUTS - for testing purposes
; ******************************************************
  nx_input = "7"
  ny_input = "5"
  master_vals = "winds0.01_rlen1000000_r4"
  p = 1  ; wrf10 2005-2007 6hrly
;  p = 3  ; wrf50 2005-2007 6hrly
;  p = 6  ; erai 2005-2007 6hrly
; ******************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; BEGIN SCRIPT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Running SOM frequency plot")
;;;;;;;;;;
; set input file information
;;;;;;;;;;
; wrf10 data
if (p .eq. 1) then
  datatitle_1 = "wrf10_200511_200703"
  tag_0 = "wrf10"
  tag_1 = "wrf"
  tag_2 = "green10"
end if
; wrf50 data
if (p .eq. 3) then
  datatitle_1 = "wrf50_199701_200712"
  tag_0 = "wrf50"
  tag_1 = "wrf"
  tag_2 = "green50"
end if
; era_i data
if (p .eq. 6) then
  datatitle_1 = "era_i_199701_200712"
  tag_0 = "era_i"
  tag_1 = "met_em"
  tag_2 = "era_i"
end if
  datefile_1 = "/data3/duvivier/SOM/training/dates/"+datatitle_1+"_dates.txt"
  visfile_1  = "/data3/duvivier/SOM/training/som_"+nx_input+ny_input+"/master/"+datatitle_1+"_"+master_vals+".vis"

;;;;;;;;;;
; Load information for each file type
;;;;;;;;;;
; Dates from data array index and visual file that places each date at a given node
print("Loading dates and SOM visual data")
dates_1 = ndtooned(readAsciiTable(datefile_1,1,"string",0)) ; ignores no rows
ndates_1 = dimsizes(dates_1)
dateschar_1 = stringtochar(dates_1)
yearmonth = chartostring(dateschar_1(:,0:5))
yy = chartostring(dateschar_1(:,0:3))
mm = chartostring(dateschar_1(:,4:5))
dd = chartostring(dateschar_1(:,6:7))
hh = chartostring(dateschar_1(:,8:9))

vis_1 = new((/ndates_1,3/),integer)
vis_1 = readAsciiTable(visfile_1,3,"integer",1) ; ignores first row

; create filenames array
files_1 = new((/ndates_1/),string)
if (p .eq. 6 ) then  ; if it's era_i for the short period need the flux files (don't have other flux files yet)
  files_1 = "/data3/duvivier/SOM/DATA/"+tag_0+"/"+yearmonth+"/"+tag_1+"-"+yy+"-"+mm+"-"+dd+"_"+hh+"."+tag_2+".all.cf.nc"
else
  files_1 = "/data3/duvivier/SOM/DATA/"+tag_0+"/"+yearmonth+"/"+tag_1+"-"+yy+"-"+mm+"-"+dd+"_"+hh+"."+tag_2+".cf.nc"
end if

delete(ndates_1)

;;;;;;;;;;
; Get just dates we want
;;;;;;;;;;
  hr_sub = (/"00","06","12","18"/)
  ym_sub = (/"200511","200512","200601","200602","200603","200611","200612","200701","200702","200703"/)
;;;;;;;;;;
; Loop through plotting options
;;;;;;;;;;
if (p .eq. 1)
  print("2005-2007 wrf10 6hrly")
  dateind_1 = ind(hh.eq.hr_sub(0) .or. hh.eq.hr_sub(1) .or. hh.eq.hr_sub(2) .or. hh.eq.hr_sub(3))
  visall_1 = vis_1(dateind_1,:)
  filesall_1 = files_1(dateind_1)
  fout = "wrf10_200511_200703_6h-fluxes"
end if
if (p .eq. 3)
  print("2005-2007 wrf50 6hrly")
  dateind_1 = ind(yearmonth.eq.ym_sub(0) .or. yearmonth.eq.ym_sub(1) .or. yearmonth.eq.ym_sub(2) .or. yearmonth.eq.ym_sub(3) .or. yearmonth.eq.ym_sub(4) .or. yearmonth.eq.ym_sub(5) .or. yearmonth.eq.ym_sub(6) .or. yearmonth.eq.ym_sub(7) .or. yearmonth.eq.ym_sub(8) .or. yearmonth.eq.ym_sub(9))
  visall_1_tmp = vis_1(dateind_1,:)
  filesall_1_tmp = files_1(dateind_1)
  hh_tmp = hh(dateind_1)
  delete(dateind_1)
  dateind_1 = ind(hh_tmp.eq.hr_sub(0) .or. hh_tmp.eq.hr_sub(1) .or. hh_tmp.eq.hr_sub(2) .or. hh_tmp.eq.hr_sub(3))
  visall_1 = visall_1_tmp(dateind_1,:)
  filesall_1 = filesall_1_tmp(dateind_1)
  delete(visall_1_tmp)
  delete(filesall_1_tmp)
  delete(hh_tmp)
  fout = "wrf50_200511_200703_6h-fluxes"
end if
if (p .eq. 6)
  print("2005-2007 era_i 6hrly")
  dateind_1 = ind(yearmonth.eq.ym_sub(0) .or. yearmonth.eq.ym_sub(1) .or. yearmonth.eq.ym_sub(2) .or. yearmonth.eq.ym_sub(3) .or. yearmonth.eq.ym_sub(4) .or. yearmonth.eq.ym_sub(5) .or. yearmonth.eq.ym_sub(6) .or. yearmonth.eq.ym_sub(7) .or. yearmonth.eq.ym_sub(8) .or. yearmonth.eq.ym_sub(9))
  visall_1 = vis_1(dateind_1,:)
  filesall_1 = files_1(dateind_1)
  fout = "era_i_200511_200703_6h-fluxes"
end if

ndates_1 = dimsizes(filesall_1)

;;;;;;;;;;
; Calculate averages data
;;;;;;;;;;
; Calculate node counts and frequencies for comparison of interest
  nx_node = stringtoint(nx_input)
  ny_node = stringtoint(ny_input)
  nnode = nx_node*ny_node

  fill = new((/1/),"float")

check1 = 0
n = 0

; Set constants
  R  = 287.   ; 287  J/kg*K  ; dry air
  RV = 461.6  ; moist air constant
  cp = 1004.  ; 1004 J/kg*K
  g = 9.8     ; 9.8 m/s2
  K = 0.4     ; von karman, unitless

;;;;;;;;;
; calculate arrays for unstable conditions (just once)
;;;;;;;;;;
  size = 1000
  PSIHTB  = new(size,"float")
  do i = 0,size-1
    zoln = -(i)*0.01
    x = (1.-16.*zoln)^(0.25)
    y = (1.-16.*zoln)^(0.5)
    PSIHTB(i) = 2.* log(0.5*(1+y))
  end do
  delete(x)
  delete(y)
  delete(i)
  delete(size)

;;;;;;;;;
; calculate
;;;;;;;;;;
; loop through each node
do y = 0, ny_node - 1
 do x = 0, nx_node - 1

  print("node: "+x+","+y)
  ; These are the dates for this particular node:
  dateindices_1 = ind(visall_1(:,0).eq.x.and.(visall_1(:,1).eq.y))
  if (.not.all(ismissing(dateindices_1))) then
    files_sub = filesall_1(dateindices_1)
  else
    print("All files missing for node")
  end if

  ; Load files that correspond to this node
  dim_files = dimsizes(files_sub)
  node_files = addfiles(files_sub,"r")

  ; Create new file that corresponds to this node for averages/variances
  fout_node = "node_"+x+"x_"+y+"y_"+fout
  node_avg = addfile("./"+fout_node+".nc","c")

  ; files that do not need to be averaged
  wrf = addfile(files_sub(0),"r")
  Z_sfc = wrf->Z_sfc
  lat = wrf->lat
  lon = wrf->lon

  ; write to new average file
  node_avg ->lat = lat
  print("latitude")
  node_avg ->lon = lon
  print("longitude") 
  node_avg ->Z_sfc = Z_sfc
  print("Terrain height")
  if (tag_1 .eq. "wrf") then
    LandMask = wrf->LandMask
    node_avg ->LandMask = LandMask
    delete(LandMask)
  end if
  delete(wrf)
  delete(lat)
  delete(lon)
;  delete(Z_sfc)

  ; write the number of files going into the average for later statistical tests
  node_avg ->number_dates = dim_files

  ; Go through each type of surface variable and calculate average and variance
  ;; Sea Ice Concentration
  SeaIce = addfiles_GetVar(node_files,files_sub,"SeaIce")
  SeaIce_avg = dim_avg_n_Wrap(SeaIce,0)
  SeaIce_var = dim_variance_n_Wrap(SeaIce,0)
  node_avg ->SeaIce_avg = SeaIce_avg
  node_avg ->SeaIce_var = SeaIce_var
  print("Seaice")
  delete(SeaIce) 
  delete(SeaIce_avg)
  delete(SeaIce_var)

;;;;;;;;;
; Do FLUX VARIABLES
;;;;;;;;;
;;;;;;;;;
; surface vars and calcs
;;;;;;;;;;
  P_sfc = addfiles_GetVar(node_files,files_sub,"p_sfc")
  T_sfc = addfiles_GetVar(node_files,files_sub,"T_sfc")
  TH_sfc = T_sfc*(1000./P_sfc)^(R/cp)
  copy_VarMeta(T_sfc,TH_sfc)
  SVP_sfc = 0.6112*exp((17.67*(T_sfc-273.15))/((T_sfc-273.15)+243.5)) ; sat vp [kPa], T_sfc [K], clausius clapyron
  q_sfc = (R/RV)*SVP_sfc/((P_sfc/10.)-SVP_sfc)  ; saturation mixing ratio at sfc. 
  ;THv_sfc = TH_sfc*(1+((RV/R)-1)*q_sfc)  ; virtual pot temp
  delete(SVP_sfc)

;;;;;;;;;
; 2m calcs - do this instead of eta0 because ERA doesn't have eta0 values
;;;;;;;;;;
  T_2m = addfiles_GetVar(node_files,files_sub,"T_2m")
  q_2m = addfiles_GetVar(node_files,files_sub,"q_2m")
  TH_2m = T_2m*(1000./P_sfc)^(R/cp) ; Assume sfc pressure is nearly the same as at 2m
  ;THv_2m = TH_2m*(1.+((RV/R)-1.)*q_2m)  ; virtual pot temp

;;;;;;;;;
; Write gradients
;;;;;;;;;;
  ;; Temperature gradient
  T_grad = (T_sfc - T_2m)
  copy_VarMeta(T_sfc,T_grad)
  T_grad@long_name = "Temperature gradient (sfc - 2m)"
  T_grad@standard_name = "Temp_grad"
  T_grad_avg = dim_avg_n_Wrap(T_grad,0)
  T_grad_var = dim_variance_n_Wrap(T_grad,0)   
  node_avg ->T_grad_avg = T_grad_avg
  node_avg ->T_grad_var = T_grad_var
  print("Temperature gradient")
  delete(T_grad) 
  delete(T_grad_avg)
  delete(T_grad_var)
  delete(T_sfc)
  ;delete(T_2m)

  ;; Potential Temperature gradient
  TH_grad = (TH_sfc - TH_2m)
  copy_VarMeta(TH_sfc,TH_grad)
  TH_grad@long_name = "Potential Temperature gradient (sfc - 2m)"
  TH_grad@standard_name = "Pot_Temp_grad"
  TH_grad_avg = dim_avg_n_Wrap(TH_grad,0)
  TH_grad_var = dim_variance_n_Wrap(TH_grad,0)   
  node_avg ->TH_grad_avg = TH_grad_avg
  node_avg ->TH_grad_var = TH_grad_var
  print("Potential Temperature gradient")
  ;delete(TH_grad) 
  delete(TH_grad_avg)
  delete(TH_grad_var)
  ;delete(TH_sfc)
  ;delete(TH_2m)

  ;; Mixing Ratio gradient
  q_grad = (q_sfc - q_2m)
  copy_VarMeta(q_sfc,q_grad)
  q_grad@long_name = "Mixing Ratio gradient (sfc - 2m)"
  q_grad@standard_name = "Mix_Rad_grad"
  q_grad_avg = dim_avg_n_Wrap(q_grad,0)
  q_grad_var = dim_variance_n_Wrap(q_grad,0)   
  node_avg ->q_grad_avg = q_grad_avg
  node_avg ->q_grad_var = q_grad_var
  print("Mixing Ratio gradient")
  ;delete(q_grad) 
  delete(q_grad_avg)
  delete(q_grad_var)
  delete(q_sfc)
  ;delete(q_2m)

;;;;;;;;;
; wind calculations
;;;;;;;;;;
  u_10m = addfiles_GetVar(node_files,files_sub,"u_10m_tr")
  v_10m = addfiles_GetVar(node_files,files_sub,"v_10m_tr")
;; I am conciously choosing to skip the "corrections" to the wind speed that are done in WRF for grid size and convection.
  wspd_10m = sqrt(u_10m^2 + v_10m^2)
  wspd_10m@long_name = "10m wind speed"
  copy_VarMeta(u_10m,wspd_10m)
  delete(u_10m)
  delete(v_10m)

  ;; Wind
  wspd_10m_avg = dim_avg_n_Wrap(wspd_10m,0)
  wspd_10m_var = dim_variance_n_Wrap(wspd_10m,0)
  node_avg ->wspd_10m_avg = wspd_10m_avg
  node_avg ->wspd_10m_var = wspd_10m_var
  print("10m wind speed")
  ;delete(wspd_10m)
  delete(wspd_10m_avg)
  delete(wspd_10m_var)

  ;; Ustar and roughness length
  ustar = addfiles_GetVar(node_files,files_sub,"u_star")
; over water roughness is altered based on wind speed.
  znt = 0.0185*((ustar^2)/g)+1.59E-5

  u_star_avg = dim_avg_n_Wrap(ustar,0)
  u_star_var = dim_variance_n_Wrap(ustar,0)
  node_avg ->u_star_avg = u_star_avg
  node_avg ->u_star_var = u_star_var
  delete(ustar)
  delete(u_star_avg)
  delete(u_star_var)
  print("Ustar")
  znt_avg = dim_avg_n_Wrap(znt,0)
  znt_var = dim_variance_n_Wrap(znt,0)
  node_avg ->znt_avg = znt_avg
  node_avg ->znt_var = znt_var
  delete(znt_avg)
  delete(znt_var)
  print("Roughness length")

; get dimensions going into average
  dims = dimsizes(znt)
  dims0 = dims(0)
  dims1 = dims(1)
  dims2 = dims(2)

; make flux arrays
  qfx = new(dims,"float")
  hfx = new(dims,"float")
  
;;;;;;;;;
; Calculate fluxes
;;;;;;;;;
  print("calculating WRF fluxes")
  
; loop through times
do i=0,dims0-1
;; NOTE: I am going to assume for the SOM analysis that the Bulk Richardson number (BR)
; results in unstable conditions over the ocean because the ocean is warmer than land.
; As a result the first three conditions that are possible in WRF are skipped here in 
; calculations and the Bulk Richardson number is not calculated.
;  BR(i,:,:) = ((g/TH_2m(i,:,:))*(2. - Z_sfc)*(THv_2m(i,:,:) - THv_sfc(i,:,:)))/(wspd_10m(i,:,:)^2)  ; bulk richardson number

  ; Calculate constants for later use
  gz1oz0 = log((2.-Z_sfc)/znt(i,:,:)) 
  gz1oz0 = where(gz1oz0 .eq. "nan", fill, gz1oz0)
  gz1oz0@_FillValue = fill
  govrth = g/TH_2m(i,:,:)

  ; calculate ustar
  ustar = (K*wspd_10m(i,:,:))/gz1oz0
  
  psih = new((/dims1,dims2/),"float")


;; Stability regimes: the 4 regimes depend on bulk richardson number
;; 1: Nighttime stable (BR .GE. 0.2)
;; 2: Damped mechanical turbulence (BR .LT. 0.2 and .GT. 0.0)
;; 3: Forced convection (BR .EQ. 0.0)
;; 4: Free convection (BR .LT. 0.0)
;; REMOVED OTHER REGIME CALCULATIONS HERE ;;
;; 4: Free convection (BR .LT. 0.0)
  ;; calculate 1/monin-obukhov length (zol)
  ;; Since ustar .gt. 0.001 over the water almost always, calculate zol this way only
  zol = ((K*govrth*(2.-Z_sfc))*((K*-TH_grad(i,:,:))/gz1oz0))/(ustar^2)
  ; limit size of zol
  zol = where(zol .gt. 0.0, 0.0, zol)
  zol = where(zol .lt. -9.999, -9.999, zol)
  nzol = floattointeger(-zol*100.0)  ; need this as an integer
  rzol = (-zol*100.0)-nzol
  ; Create transfer coefficient arrays. 
  psih = where(nzol .eq. 0 , PSIHTB(0)+(rzol*(PSIHTB(1)-PSIHTB(0))), psih)
  psih = where(nzol .eq. 999 , PSIHTB(999)+(rzol*(PSIHTB(999)-PSIHTB(998))), psih)
  ; Are there values between 0 and 999? I haven't seen them...
  ; limit psih values
  psih = where(psih .gt. (0.9*gz1oz0), (0.9*gz1oz0),psih)
  delete(zol)
  delete(nzol)
  delete(rzol)

  ;;;;;;;;;
  ; Additional forms of stability terms 
  ;;;;;;;;;;
  ; calculate various stability related terms
  psiq = log(((K*ustar*znt(i,:,:))/(2.4E-5))+((2. - Z_sfc)/znt(i,:,:)))- psih

  print("calculating fluxes")
  ;;;;;;;;;
  ; Moisture Flux calculations
  ;;;;;;;;;;
  mavail = 1.0 ; over water we have moisture available!
  ; calculate moisture transfer coefficient
  flqc = (((P_sfc(i,:,:)*100.)/(R*T_2m(i,:,:)))*mavail*ustar*K)/psiq
  ; calculate latent heat flux --> positive is toward atmosphere (up) 2.5E6 is latent heat vaporization
  qfx(i,:,:) = 2.5E6* flqc*q_grad(i,:,:)
  qfx(i,:,:) = where(qfx(i,:,:) .lt. 0., 0.0, qfx(i,:,:))
  
  delete(flqc)
  delete(psiq)
  ;;;;;;;;;
  ; Sensible heat flux calculations
  ;;;;;;;;;
  TH_grad(i,:,:) = where(TH_grad(i,:,:) .eq. 0.0, fill, TH_grad(i,:,:))
  flhc = (cp*(1.+0.8*(q_2m(i,:,:)))*((P_sfc(i,:,:)*100.)/(R*T_2m(i,:,:)))*ustar*((K*-TH_grad(i,:,:))/gz1oz0))/(-TH_grad(i,:,:))
  ; calculate heat flux --> positive is toward atmosphere (up)
  hfx(i,:,:) = flhc *(TH_grad(i,:,:))
end do
; END OF WRF SURFACE LAYER ROUTINE



return







return

  ;; SLP
  slp = addfiles_GetVar(node_files,files_sub,"slp")
  slp_avg = dim_avg_n_Wrap(slp,0)
  slp_var = dim_variance_n_Wrap(slp,0)
  node_avg ->slp_avg = slp_avg
  node_avg ->slp_var = slp_var
  print("SLP")
  delete(slp)
  delete(slp_avg)
  delete(slp_var)
  ;; SLP anomaly
  slp_anom = addfiles_GetVar(node_files,files_sub,"slp_anom")
  slp_anom_avg = dim_avg_n_Wrap(slp_anom,0)
  slp_anom_var = dim_variance_n_Wrap(slp_anom,0)
  node_avg ->slp_anom_avg = slp_anom_avg
  node_avg ->slp_anom_var = slp_anom_var
  print("SLP_anomaly")
  delete(slp_anom)
  delete(slp_anom_avg)
  delete(slp_anom_var)
  ;; Surface pressure
  p_sfc = addfiles_GetVar(node_files,files_sub,"p_sfc")
  p_sfc_avg = dim_avg_n_Wrap(p_sfc,0)
  p_sfc_var = dim_variance_n_Wrap(p_sfc,0)
  node_avg ->p_sfc_avg = p_sfc_avg
  node_avg ->p_sfc_var = p_sfc_var
  print("Surface pressure")
  delete(p_sfc)
  delete(p_sfc_avg)
  delete(p_sfc_var)
  ;; Surface temperature
  T_sfc = addfiles_GetVar(node_files,files_sub,"T_sfc")
  T_sfc_avg = dim_avg_n_Wrap(T_sfc,0)
  T_sfc_var = dim_variance_n_Wrap(T_sfc,0)
  node_avg ->T_sfc_avg = T_sfc_avg
  node_avg ->T_sfc_var = T_sfc_var
  print("Surface temperature")
  delete(T_sfc)
  delete(T_sfc_avg)
  delete(T_sfc_var)
  ;; 2m temperature
  T_2m = addfiles_GetVar(node_files,files_sub,"T_2m")
  T_2m_avg = dim_avg_n_Wrap(T_2m,0)
  T_2m_var = dim_variance_n_Wrap(T_2m,0)
  node_avg ->T_2m_avg = T_2m_avg
  node_avg ->T_2m_var = T_2m_var
  print("2m Temperature")
  delete(T_2m)
  delete(T_2m_avg)
  delete(T_2m_var)
  ;; eta0 temperature
  if (tag_1 .eq. "wrf") then
    T_eta0 = addfiles_GetVar(node_files,files_sub,"T_eta0")
    T_eta0_avg = dim_avg_n_Wrap(T_eta0,0)
    T_eta0_var = dim_variance_n_Wrap(T_eta0,0)
    ; convert from double to float for later ease
    T_eta0_flt = dble2flt(T_eta0_avg)
    delete(T_eta0_avg)
    T_eta0_avg = T_eta0_flt
    delete(T_eta0_flt)
    T_eta0_flt = dble2flt(T_eta0_var)
    delete(T_eta0_var)
    T_eta0_var = T_eta0_flt
    delete(T_eta0_flt)
    ; write to file
    node_avg ->T_eta0_avg = T_eta0_avg
    node_avg ->T_eta0_var = T_eta0_var
    print("eta0 Temperature")
    delete(T_eta0)
    delete(T_eta0_avg)
    delete(T_eta0_var)
    print("Averaged surface temperatures")
  end if
  ;; 2m mixing ratio
  q_2m = addfiles_GetVar(node_files,files_sub,"q_2m")
  q_2m_avg = dim_avg_n_Wrap(q_2m,0)
  q_2m_var = dim_variance_n_Wrap(q_2m,0)
  node_avg ->q_2m_avg = q_2m_avg
  node_avg ->q_2m_var = q_2m_var
  print("2m mixing ratio")
  delete(q_2m)
  delete(q_2m_avg)
  delete(q_2m_var)
  ;; eta0 mixing ratio
  if (tag_1 .eq. "wrf") then
    q_eta0 = addfiles_GetVar(node_files,files_sub,"q_eta0")
    q_eta0_avg = dim_avg_n_Wrap(q_eta0,0)
    q_eta0_var = dim_variance_n_Wrap(q_eta0,0)
    ; convert from double to float for later ease
    q_eta0_flt = dble2flt(q_eta0_avg)
    delete(q_eta0_avg)
    q_eta0_avg = q_eta0_flt
    delete(q_eta0_flt)
    q_eta0_flt = dble2flt(q_eta0_var)
    delete(q_eta0_var)
    q_eta0_var = q_eta0_flt
    delete(q_eta0_flt)
    ; write to file
    node_avg ->q_eta0_avg = q_eta0_avg
    node_avg ->q_eta0_var = q_eta0_var
    print("eta0 mixing ratio")
    delete(q_eta0)
    delete(q_eta0_avg)
    delete(q_eta0_var)
  end if
  ;; u10m
  u_10m_tr = addfiles_GetVar(node_files,files_sub,"u_10m_tr")
  u_10m_tr_avg = dim_avg_n_Wrap(u_10m_tr,0)
  u_10m_tr_var = dim_variance_n_Wrap(u_10m_tr,0)
  node_avg ->u_10m_tr_avg = u_10m_tr_avg
  node_avg ->u_10m_tr_var = u_10m_tr_var
  print("10m U")
   ;delete(u_10m_tr)
  delete(u_10m_tr_avg)
  delete(u_10m_tr_var)
  ;; v10m
  v_10m_tr = addfiles_GetVar(node_files,files_sub,"v_10m_tr")
  v_10m_tr_avg = dim_avg_n_Wrap(v_10m_tr,0)
  v_10m_tr_var = dim_variance_n_Wrap(v_10m_tr,0)
  node_avg ->v_10m_tr_avg = v_10m_tr_avg
  node_avg ->v_10m_tr_var = v_10m_tr_var
  print("10m V")
   ;delete(v_10m_tr)
  delete(v_10m_tr_avg)
  delete(v_10m_tr_var)
  ;; ws10m
  ws_10m = sqrt(u_10m_tr^2+v_10m_tr^2)
  copy_VarMeta(u_10m_tr,ws_10m)
  ws_10m@standard_name = "magnitude_wind_speed"
  ws_10m@long_name = "wind speed"
  ws_10m_avg = dim_avg_n_Wrap(ws_10m,0)
  ws_10m_var = dim_variance_n_Wrap(ws_10m,0)
  node_avg ->ws_10m_avg = ws_10m_avg
  node_avg ->ws_10m_var = ws_10m_var
  print("10m WS")
  delete(u_10m_tr)
  delete(v_10m_tr)
  delete(ws_10m)
  delete(ws_10m_avg)
  delete(ws_10m_var)
  ;; eta0 winds for wrf only
  if (tag_1 .eq. "wrf") then
    ;; u eta0
    u_tr_eta0 = addfiles_GetVar(node_files,files_sub,"u_tr_eta0")
    u_tr_eta0_avg = dim_avg_n_Wrap(u_tr_eta0,0)
    u_tr_eta0_var = dim_variance_n_Wrap(u_tr_eta0,0)
    node_avg ->u_tr_eta0_avg = u_tr_eta0_avg
    node_avg ->u_tr_eta0_var = u_tr_eta0_var
    print("eta0 U")
     ;delete(u_tr_eta0)
    delete(u_tr_eta0_avg)
    delete(u_tr_eta0_var)
    ;; v eta0
    v_tr_eta0 = addfiles_GetVar(node_files,files_sub,"v_tr_eta0")
    v_tr_eta0_avg = dim_avg_n_Wrap(v_tr_eta0,0)
    v_tr_eta0_var = dim_variance_n_Wrap(v_tr_eta0,0)
    node_avg ->v_tr_eta0_avg = v_tr_eta0_avg
    node_avg ->v_tr_eta0_var = v_tr_eta0_var
    print("eta0 V")
     ;delete(v_tr_eta0)
    delete(v_tr_eta0_avg)
    delete(v_tr_eta0_var)
    ;; ws eta0
    ws_eta0 = sqrt(u_tr_eta0^2+v_tr_eta0^2)
    copy_VarMeta(u_tr_eta0,ws_eta0)
    ws_eta0@standard_name = "magnitude_wind_speed"
    ws_eta0@long_name = "wind speed"
    ws_eta0_avg = dim_avg_n_Wrap(ws_eta0,0)
    ws_eta0_var = dim_variance_n_Wrap(ws_eta0,0)
    node_avg ->ws_eta0_avg = ws_eta0_avg
    node_avg ->ws_eta0_var = ws_eta0_var
    print("eta0 WS")
    delete(u_tr_eta0)
    delete(v_tr_eta0)
    delete(ws_eta0)
    delete(ws_eta0_avg)
    delete(ws_eta0_var)
  end if
  ;; Wind stress curl
  if (tag_1 .eq. "wrf") then
    wsc = addfiles_GetVar(node_files,files_sub,"wsc")
    wsc_avg = dim_avg_n_Wrap(wsc,0)
    wsc_var = dim_variance_n_Wrap(wsc,0)
    node_avg ->wsc_avg = wsc_avg
    node_avg ->wsc_var = wsc_var
    print("Wind Stress Curl")
    delete(wsc)
    delete(wsc_avg)
    delete(wsc_var)
  end if
  if (tag_1 .eq. "met_em") then
    taux = addfiles_GetVar(node_files,files_sub,"taux")
    taux_avg = dim_avg_n_Wrap(taux,0)
    taux_var = dim_variance_n_Wrap(taux,0)
    node_avg ->taux_avg = taux_avg
    node_avg ->taux_var = taux_var
    print("Eastward surface stress")
    delete(taux)
    delete(taux_avg)
    delete(taux_var)
    tauy = addfiles_GetVar(node_files,files_sub,"tauy")
    tauy_avg = dim_avg_n_Wrap(tauy,0)
    tauy_var = dim_variance_n_Wrap(tauy,0)
    node_avg ->tauy_avg = tauy_avg
    node_avg ->tauy_var = tauy_var
    print("Northward surface stress")
    delete(tauy)
    delete(tauy_avg)
    delete(tauy_var)
  end if
  ;; Ustar
  u_star = addfiles_GetVar(node_files,files_sub,"u_star")
  u_star_avg = dim_avg_n_Wrap(u_star,0)
  u_star_var = dim_variance_n_Wrap(u_star,0)
  node_avg ->u_star_avg = u_star_avg
  node_avg ->u_star_var = u_star_var
  print("Ustar")
  delete(u_star)
  delete(u_star_avg)
  delete(u_star_var)
  ;; Total Precipitation rate
  precip_tot = addfiles_GetVar(node_files,files_sub,"precip_tot")
  precip_tot_avg = dim_avg_n_Wrap(precip_tot,0)
  precip_tot_var = dim_variance_n_Wrap(precip_tot,0)
  node_avg ->precip_tot_avg = precip_tot_avg
  node_avg ->precip_tot_var = precip_tot_var
  print("Total precip")
  delete(precip_tot)
  delete(precip_tot_avg)
  delete(precip_tot_var)
  ;; Frozen Precipitation rate
  if (tag_1 .eq. "wrf") then
    precip_froz = addfiles_GetVar(node_files,files_sub,"precip_froz")
    precip_froz_avg = dim_avg_n_Wrap(precip_froz,0)
    precip_froz_var = dim_variance_n_Wrap(precip_froz,0)
    node_avg ->precip_froz_avg = precip_froz_avg
    node_avg ->precip_froz_var = precip_froz_var
    print("Frozen precip")
    delete(precip_froz)
    delete(precip_froz_avg)
    delete(precip_froz_var)
  end if
  ;; Shortwave down instantaneous
  if (tag_1 .eq. "wrf") then
    SW_d = addfiles_GetVar(node_files,files_sub,"SW_d")
    SW_d_avg = dim_avg_n_Wrap(SW_d,0)
    SW_d_var = dim_variance_n_Wrap(SW_d,0)
    node_avg ->SW_d_avg = SW_d_avg
    node_avg ->SW_d_var = SW_d_var
    print("Instantaneous SW down")
    ;delete(SW_d)
    delete(SW_d_avg)
    delete(SW_d_var)
  ;; Shortwave up instantaneous
    SW_u = addfiles_GetVar(node_files,files_sub,"SW_u")
    SW_u_avg = dim_avg_n_Wrap(SW_u,0)
    SW_u_var = dim_variance_n_Wrap(SW_u,0)
    node_avg ->SW_u_avg = SW_u_avg
    node_avg ->SW_u_var = SW_u_var
    print("Instantaneous SW up")
    ;delete(SW_u)
    delete(SW_u_avg)
    delete(SW_u_var)
  ;; Net shortwave instantaneous
    SW_inst_net = SW_u - SW_d
    copy_VarMeta(SW_u,SW_inst_net)
    SW_inst_net@standard_name = "net_shortwave"
    SW_inst_net@long_name = "Net shortwave radiation (+ UP)"
    SW_inst_net_avg = dim_avg_n_Wrap(SW_inst_net,0)
    SW_inst_net_var = dim_variance_n_Wrap(SW_inst_net,0)
    node_avg ->SW_inst_net_avg = SW_inst_net_avg
    node_avg ->SW_inst_net_var = SW_inst_net_var
    print("Instantaneous Net Shortwave")
    delete(SW_u)
    delete(SW_d)
    delete(SW_inst_net_avg)
    delete(SW_inst_net_var)
  ;; Longwave down instantaneous
    LW_d = addfiles_GetVar(node_files,files_sub,"LW_d")
    LW_d_avg = dim_avg_n_Wrap(LW_d,0)
    LW_d_var = dim_variance_n_Wrap(LW_d,0)
    node_avg ->LW_d_avg = LW_d_avg
    node_avg ->LW_d_var = LW_d_var
    print("Instantaneous LW down")
    ;delete(LW_d)
    delete(LW_d_avg)
    delete(LW_d_var)
  ;; Longwave up instantaneous
    LW_u = addfiles_GetVar(node_files,files_sub,"LW_u")
    LW_u_avg = dim_avg_n_Wrap(LW_u,0)
    LW_u_var = dim_variance_n_Wrap(LW_u,0)
    node_avg ->LW_u_avg = LW_u_avg
    node_avg ->LW_u_var = LW_u_var
    print("Instantaneous LW up")
    ;delete(LW_u)
    delete(LW_u_avg)
    delete(LW_u_var)
  ;; Net longwave instantaneous
    LW_inst_net = LW_u - LW_d
    copy_VarMeta(LW_u,LW_inst_net)
    LW_inst_net@standard_name = "net_longwave"
    LW_inst_net@long_name = "Net longwave radiation (+ UP)"
    LW_inst_net_avg = dim_avg_n_Wrap(LW_inst_net,0)
    LW_inst_net_var = dim_variance_n_Wrap(LW_inst_net,0)
    node_avg ->LW_inst_net_avg = LW_inst_net_avg
    node_avg ->LW_inst_net_var = LW_inst_net_var
    print("Instantaneous Net Longwave")
    delete(LW_u)
    delete(LW_d)
    delete(LW_inst_net_avg)
    delete(LW_inst_net_var)
  ;; Net radiation instantaneous
    Rad_inst_net = LW_inst_net + SW_inst_net
    copy_VarMeta(LW_inst_net,Rad_inst_net)
    Rad_inst_net@standard_name = "net_radiation"
    Rad_inst_net@long_name = "Net radiation (+ UP)"
    Rad_inst_net_avg = dim_avg_n_Wrap(Rad_inst_net,0)
    Rad_inst_net_var = dim_variance_n_Wrap(Rad_inst_net,0)
    node_avg ->Rad_inst_net_avg = Rad_inst_net_avg
    node_avg ->Rad_inst_net_var = Rad_inst_net_var
    print("Instantaneous Net radiation")
    delete(LW_inst_net)
    delete(SW_inst_net)
    delete(Rad_inst_net_avg)
    delete(Rad_inst_net_var)
  end if
  ;; Shortwave down deaccumulated
  rsds = addfiles_GetVar(node_files,files_sub,"rsds")
  rsds_avg = dim_avg_n_Wrap(rsds,0)
  rsds_var = dim_variance_n_Wrap(rsds,0)
  node_avg ->rsds_avg = rsds_avg
  node_avg ->rsds_var = rsds_var
  print("Deaccumulated SW down")
   ;delete(rsds)
  delete(rsds_avg)
  delete(rsds_var)
  ;; Shortwave up deaccumulated
  if (tag_1 .eq. "wrf") then
    rsus = addfiles_GetVar(node_files,files_sub,"rsus")
    rsus_avg = dim_avg_n_Wrap(rsus,0)
    rsus_var = dim_variance_n_Wrap(rsus,0)
    node_avg ->rsus_avg = rsus_avg
    node_avg ->rsus_var = rsus_var
    print("Deaccumulated SW up")
    ;delete(rsus)
    delete(rsus_avg)
    delete(rsus_var)
  end if
  if(tag_1 .eq. "met_em") then
    dum1 = addfiles_GetVar(node_files,files_sub,"rsds")
    dum2 = addfiles_GetVar(node_files,files_sub,"SW_deac_net")
    rsus = dum1 + dum2
    rsus_avg = dim_avg_n_Wrap(rsus,0)
    rsus_var = dim_variance_n_Wrap(rsus,0)
    node_avg ->rsus_avg = rsus_avg
    node_avg ->rsus_var = rsus_var
    print("Deaccumulated SW up")
    ;delete(rsus)
    delete(rsus_avg)
    delete(rsus_var)
    delete(dum1)
    delete(dum2)
  end if
  ;; Net shortwave deaccumulated
  if (tag_1 .eq. "wrf") then
    SW_deac_net = rsus - rsds
    copy_VarMeta(rsus,SW_deac_net)
    SW_deac_net@standard_name = "net_shortwave"
    SW_deac_net@long_name = "Net shortwave radiation (+ UP)"
    SW_deac_net_avg = dim_avg_n_Wrap(SW_deac_net,0)
    SW_deac_net_var = dim_variance_n_Wrap(SW_deac_net,0)
    node_avg ->SW_deac_net_avg = SW_deac_net_avg
    node_avg ->SW_deac_net_var = SW_deac_net_var
    print("Deaccumulated Net Shortwave")
    delete(rsus)
    delete(rsds)
    delete(SW_deac_net_avg)
    delete(SW_deac_net_var)
  end if
  if(tag_1 .eq. "met_em") then
    SW_deac_net = addfiles_GetVar(node_files,files_sub,"SW_deac_net")
    SW_deac_net_avg = dim_avg_n_Wrap(SW_deac_net,0)
    SW_deac_net_var = dim_variance_n_Wrap(SW_deac_net,0)
    node_avg ->SW_deac_net_avg = SW_deac_net_avg
    node_avg ->SW_deac_net_var = SW_deac_net_var
    print("Deaccumulated Net Shortwave")
    delete(rsus) ;saved earlier, no longer needed
    delete(rsds)
    delete(SW_deac_net_avg)
    delete(SW_deac_net_var)
  end if
  ;; Longwave down deaccumulated
  rlds = addfiles_GetVar(node_files,files_sub,"rlds")
  rlds_avg = dim_avg_n_Wrap(rlds,0)
  rlds_var = dim_variance_n_Wrap(rlds,0)
  node_avg ->rlds_avg = rlds_avg
  node_avg ->rlds_var = rlds_var
  print("Deaccumulated LW down")
   ;delete(rlds)
  delete(rlds_avg)
  delete(rlds_var)
  ;; Longwave up deaccumulated
  if (tag_1 .eq. "wrf") then
    rlus = addfiles_GetVar(node_files,files_sub,"rlus")
    rlus_avg = dim_avg_n_Wrap(rlus,0)
    rlus_var = dim_variance_n_Wrap(rlus,0)
    node_avg ->rlus_avg = rlus_avg
    node_avg ->rlus_var = rlus_var
    print("Deaccumulated LW up")
    ;delete(rlus)
    delete(rlus_avg)
    delete(rlus_var)
  end if
  if (tag_1 .eq. "met_em") then
    dum1 = addfiles_GetVar(node_files,files_sub,"rlds")
    dum2 = addfiles_GetVar(node_files,files_sub,"LW_deac_net")
    rlus = dum1 + dum2
    rlus_avg = dim_avg_n_Wrap(rlus,0)
    rlus_var = dim_variance_n_Wrap(rlus,0)
    node_avg ->rlus_avg = rlus_avg
    node_avg ->rlus_var = rlus_var
    print("Deaccumulated LW up")
    ;delete(rlus)
    delete(rlus_avg)
    delete(rlus_var)
    delete(dum1)
    delete(dum2)
  end if
  ;; Net longwave deaccumulated
  if (tag_1 .eq. "wrf") then
    LW_deac_net = rlus - rlds
    copy_VarMeta(rlus,LW_deac_net)
    LW_deac_net@standard_name = "net_longwave"
    LW_deac_net@long_name = "Net longwave radiation (+ UP)"
    LW_deac_net_avg = dim_avg_n_Wrap(LW_deac_net,0)
    LW_deac_net_var = dim_variance_n_Wrap(LW_deac_net,0)
    node_avg ->LW_deac_net_avg = LW_deac_net_avg
    node_avg ->LW_deac_net_var = LW_deac_net_var
    print("Deaccumulated Net Longwave")
    delete(rlus)
    delete(rlds)
    delete(LW_deac_net_avg)
    delete(LW_deac_net_var)
  end if
  if(tag_1 .eq. "met_em") then
    LW_deac_net = addfiles_GetVar(node_files,files_sub,"LW_deac_net")
    LW_deac_net_avg = dim_avg_n_Wrap(LW_deac_net,0)
    LW_deac_net_var = dim_variance_n_Wrap(LW_deac_net,0)
    node_avg ->LW_deac_net_avg = LW_deac_net_avg
    node_avg ->LW_deac_net_var = LW_deac_net_var
    print("Deaccumulated Net Longwave")
    delete(rlus) ; saved but no longer needed
    delete(rlds)
    delete(LW_deac_net_avg)
    delete(LW_deac_net_var)
  end if
  ;; Net radiation deaccumulated
  Rad_deac_net = LW_deac_net + SW_deac_net
  copy_VarMeta(LW_deac_net,Rad_deac_net)
  Rad_deac_net@standard_name = "net_radiation"
  Rad_deac_net@long_name = "Net radiation (+ UP)"
  Rad_deac_net_avg = dim_avg_n_Wrap(Rad_deac_net,0)
  Rad_deac_net_var = dim_variance_n_Wrap(Rad_deac_net,0)
  node_avg ->Rad_deac_net_avg = Rad_deac_net_avg
  node_avg ->Rad_deac_net_var = Rad_deac_net_var
  print("Deaccumulated Net radiation")
  delete(LW_deac_net)
  delete(SW_deac_net)
  delete(Rad_deac_net_avg)
  delete(Rad_deac_net_var)
  ;; Sensible Heat flux instantaneous
  if (tag_1 .eq. "wrf") then
    SHFlx = addfiles_GetVar(node_files,files_sub,"SHFlx")
    SHFlx_avg = dim_avg_n_Wrap(SHFlx,0)
    SHFlx_var = dim_variance_n_Wrap(SHFlx,0)
    node_avg ->SHFlx_avg = SHFlx_avg
    node_avg ->SHFlx_var = SHFlx_var
    print("Instantaneous Sensible Heat Flux")
    ;delete(SHFlx)
    delete(SHFlx_avg)
    delete(SHFlx_var)
  ;; Latent Heat flux instantaneous
    LHFlx = addfiles_GetVar(node_files,files_sub,"LHFlx")
    LHFlx_avg = dim_avg_n_Wrap(LHFlx,0)
    LHFlx_var = dim_variance_n_Wrap(LHFlx,0)
    node_avg ->LHFlx_avg = LHFlx_avg
    node_avg ->LHFlx_var = LHFlx_var
    print("Instantaneous Latent Heat Flux")
    ;delete(LHFlx)
    delete(LHFlx_avg)
    delete(LHFlx_var)
  ;; Net Turbulent flux instantaneous
    Turb_inst_net = LHFlx + SHFlx
    copy_VarMeta(LHFlx,Turb_inst_net)
    Turb_inst_net@standard_name = "net_turbulent_fluxes"
    Turb_inst_net@long_name = "Net turbulent fluxes (+ UP)"
    Turb_inst_net_avg = dim_avg_n_Wrap(Turb_inst_net,0)
    Turb_inst_net_var = dim_variance_n_Wrap(Turb_inst_net,0)
    node_avg ->Turb_inst_net_avg = Turb_inst_net_avg
    node_avg ->Turb_inst_net_var = Turb_inst_net_var
    print("Instantaneous Net Turbulent Flux") 
    delete(LHFlx)
    delete(SHFlx)
    delete(Turb_inst_net_avg)
    delete(Turb_inst_net_var)
  end if
  ;; Sensible Heat flux deaccumulated
  hfss = addfiles_GetVar(node_files,files_sub,"hfss")
  hfss_avg = dim_avg_n_Wrap(hfss,0)
  hfss_var = dim_variance_n_Wrap(hfss,0)
  node_avg ->hfss_avg = hfss_avg
  node_avg ->hfss_var = hfss_var
  print("Deaccumulated sensible heat flux")
   ;delete(hfss)
  delete(hfss_avg)
  delete(hfss_var)
  ;; Latent Heat flux deaccumulated
  hfls = addfiles_GetVar(node_files,files_sub,"hfls")
  hfls_avg = dim_avg_n_Wrap(hfls,0)
  hfls_var = dim_variance_n_Wrap(hfls,0)
  node_avg ->hfls_avg = hfls_avg
  node_avg ->hfls_var = hfls_var
  print("Deaccumulated latent heat flux")
   ;delete(hfls)
  delete(hfls_avg)
  delete(hfls_var)
  ;; Net Turbulent flux deaccumulated
  Turb_deac_net = hfls + hfss
  copy_VarMeta(hfls,Turb_deac_net)
  Turb_deac_net@standard_name = "net_turbulent_fluxes"
  Turb_deac_net@long_name = "Net turbulent fluxes (+ UP)"
  Turb_deac_net_avg = dim_avg_n_Wrap(Turb_deac_net,0)
  Turb_deac_net_var = dim_variance_n_Wrap(Turb_deac_net,0)
  node_avg ->Turb_deac_net_avg = Turb_deac_net_avg
  node_avg ->Turb_deac_net_var = Turb_deac_net_var
  print("Deaccumulated Net Turbulent Flux") 
  delete(hfls)
  delete(hfss)
  delete(Turb_deac_net_avg)
  delete(Turb_deac_net_var)

  ;; Net Radiative and Turbulent fluxes instantaneous
  if (tag_1 .eq. "wrf") then
    Flux_inst_net = Turb_inst_net + Rad_inst_net
    copy_VarMeta(Turb_inst_net, Flux_inst_net)
    Flux_inst_net@standard_name = "net_flux"
    Flux_inst_net@long_name = "Net radiative and turbulent fluxes (+ UP)"
    Flux_inst_net_avg = dim_avg_n_Wrap(Flux_inst_net,0)
    Flux_inst_net_var = dim_variance_n_Wrap(Flux_inst_net,0)
    node_avg ->Flux_inst_net_avg = Flux_inst_net_avg
    node_avg ->Flux_inst_net_var = Flux_inst_net_var
    print("Instantaneous Net Flux (turb and rad)")
    delete(Turb_inst_net)
    delete(Rad_inst_net)
    delete(Flux_inst_net)
    delete(Flux_inst_net_avg)
    delete(Flux_inst_net_var)
  end if
  ;; Net Radiative and Turbulent fluxes deaccumulated
  Flux_deac_net = Turb_deac_net + Rad_deac_net
  copy_VarMeta(Turb_deac_net, Flux_deac_net)
  Flux_deac_net@standard_name = "net_flux"
  Flux_deac_net@long_name = "Net radiative and turbulent fluxes (+ UP)"
  Flux_deac_net_avg = dim_avg_n_Wrap(Flux_deac_net,0)
  Flux_deac_net_var = dim_variance_n_Wrap(Flux_deac_net,0)
  node_avg ->Flux_deac_net_avg = Flux_deac_net_avg
  node_avg ->Flux_deac_net_var = Flux_deac_net_var
  print("Deaccumulated Net Flux (turb and rad)")
  delete(Turb_deac_net)
  delete(Rad_deac_net)
  delete(Flux_deac_net)
  delete(Flux_deac_net_avg)
  delete(Flux_deac_net_var)

  ;; add up total number of days
  check1 = check1 + dim_files
  n = n + 1

  ;; delete variables to use again
  delete(fout_node)
  delete(node_avg)
  delete(dim_files)
  delete(node_files)
  delete(dateindices_1)
  delete(files_sub)

 end do
end do

; Check the dates and print error messages if calculation fails
if (check1.ne.ndates_1) then
 print("Error.  Number of dates is not equal to total number of indices.")
 print("Num. dates: "+ndates_1+"   Tot indices: "+check1)
end if

;;;;;;;;;;;;;;;;;;;;;; END script
end
