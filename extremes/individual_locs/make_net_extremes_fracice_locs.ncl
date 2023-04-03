;***************************************
; PROGRAM DESCRIPTION: This script plots frequency information for
;                      a SOM trained with three data sets
; INPUT DATA: SOM date and visual files for three data types
; OUTPUT DATA: One  plot of frequency comparisons
; CREATOR: Matt Higgins(Oct 2008), Melissa Nigro (Aug 2011)
;          Modified by Alice DuVivier - April 2012
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************
begin
; MANUAL INPUTS - for testing purposes
; ******************************************************
  fname1 = "era_i_200511_200703_6h"
; ******************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; BEGIN SCRIPT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Running net average/variance calculations")

;;;;;;;;;;
; set input file information
;;;;;;;;;;
; wrf data
if (fname1 .eq. "wrf10_200511_200703_6h")then
  tag_0 = "wrf10"
  tag_1 = "wrf"
  node_files = addfile("/data3/duvivier/SOM/training/averages/all/"+fname1+"-all.nc","r")
end if
if (fname1 .eq. "wrf50_200511_200703_6h")then
  tag_0 = "wrf50"
  tag_1 = "wrf"
  node_files = addfile("/data3/duvivier/SOM/training/averages/all/"+fname1+"-all.nc","r")
end if
if (fname1 .eq. "era_i_200511_200703_6h") then
  tag_0 = "era_i"
  tag_1 = "met_em"
  node_files = addfile("/data3/duvivier/SOM/training/averages/all/"+fname1+"-all.nc","r")
end if
; Dates from data array index and visual file that places each date at a given node
print("Loading data")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Do FLUX CALCULATIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set constants
   zu = 10.          ; Height of wind measurement
   zt = 2.           ; Height of temperature measurement
   zq = 2.           ; Height of moisture measurement
   zi = 600.         ; Height of PBL (taken from COARE algorithm for assumed height)
   Rgas = 287.1      ; Dry gas constant J/(kg*K)
   cpa = 1004.67     ; Specific heat at constant pressure J/(kg*K) 
   Beta = 1.2        ; Constant from COARE algorithm
   von = 0.4         ; Von Karman constant (unitless)
   c1=0.0052790414   ; constant for gravity calculations
   c2=0.0000232718   ; constant for gravity calculations
   c3=0.0000001262   ; constant for gravity calculations
   c4=0.0000000007   ; constant for gravity calculations
   tdk = 273.16      ; conversion between K and C
   grav = 9.81       ; gravity

;;;;;;;;;;
; Load information for file
;;;;;;;;;;
  ; files that do not need to be averaged
  Z_sfc = node_files->Z_sfc
  lat = node_files->lat
  lon = node_files->lon

  ; point lat and lons to get extremes info
  lats = (/59.0, 64.5, 67.0/)
  lons = (/-43.0, -35.5, -23.0/)
  locs = (/"CF", "DSS", "DSN"/)
  n_locs = dimsizes(locs)

  ; get indices of data at chosen locations
  inds = new((/n_locs,2/),"integer")
  do i = 0, n_locs -1
    indices = getind_latlon2d(lat,lon,lats(i),lons(i))
    inds(i,:) = indices
    delete(indices)
  end do

  ;;;; Load initial files to get dimensions;;;;;
  ;; Sea Ice Concentration
  SeaIce = node_files->SeaIce
; get dimensions going into average
  dims = dimsizes(SeaIce)
  times0 = dims(0)
  delete(dims)
  ; loop through locations to get only ones we need
  SeaIce_locs = new((/times0,n_locs/),"float")
  l = 0
  do l = 0, n_locs -1
    SeaIce_locs(:,l) = SeaIce(:,inds(l,0),inds(l,1))
  end do
  delete(SeaIce)
  SeaIce = SeaIce_locs
  delete(SeaIce_locs)
  ; get new dimensions of just the three points
  dims = dimsizes(SeaIce)
  dims0 = dims(0)
  dims1 = dims(1)

;;;;;;;;;;
; Load flux input data
;;;;;;;;;;
  ; Now, get the rest of the variables we need
  ;; winds at 10m
  u_10m = node_files->u_10m_tr
  v_10m = node_files->v_10m_tr
  U10 = sqrt(u_10m^2 + v_10m^2)
  copy_VarMeta(u_10m, U10)
  delete(u_10m)
  delete(v_10m)
  U10@long_name = "10m wind speed"
  U10_locs = new((/times0,n_locs/),"float")
  l = 0
  do l = 0, n_locs -1
    U10_locs(:,l) = U10(:,inds(l,0),inds(l,1))
  end do
  delete(U10)
  U10 = U10_locs
  delete(U10_locs)
  u = U10

  ;; Sfc Pressure
  P  = node_files->p_sfc
  P_locs = new((/times0,n_locs/),"float")
  l = 0
  do l = 0, n_locs -1
    P_locs(:,l) = P(:,inds(l,0),inds(l,1))
  end do
  delete(P)
  P = P_locs
  delete(P_locs)

  ;; Sfc Temperature
  ts = node_files->T_sfc
  ts = ts - tdk
  ts@units = "C"
  ts_locs = new((/times0,n_locs/),"float")
  l = 0
  do l = 0, n_locs -1
    ts_locs(:,l) = ts(:,inds(l,0),inds(l,1))
  end do
  delete(ts)
  ts = ts_locs
  delete(ts_locs)
  ; for surface temperatures, how to deal with the marginal ice zone
  ; for fractions above 15%, set surface temperature to 
  ; -1.8C (freezing pt) or SST, whichever is greater
  ts = where(SeaIce .gt. 0.15 .and. ts .lt. -1.8, -1.8, ts)

  ;; 2m Temperature
  t  = node_files->T_2m
  if (tag_1 .eq. "met_em")then
  else
    t = t - tdk
    t@units = "C"
  end if
  t_locs = new((/times0,n_locs/),"float")
  l = 0
  do l = 0, n_locs -1
    t_locs(:,l) = t(:,inds(l,0),inds(l,1))
  end do
  delete(t)
  t = t_locs
  delete(t_locs)

  ;; 2m Mixing Ratio
  q  = node_files->q_2m
  q = q*1000. 
  q@units = "g/kg"
  q_locs = new((/times0,n_locs/),"float")
  l = 0
  do l = 0, n_locs -1
    q_locs(:,l) = q(:,inds(l,0),inds(l,1))
  end do
  delete(q)
  q = q_locs
  delete(q_locs)

;;;;;;;;;
; Set Constants and Calculate variables that use WRF info
;;;;;;;;;;
; Calculate variables from WRF vars
  ; surface saturated mixing ratio
   es = 6.112*exp(17.502*ts/(ts+240.97))*.98*(1.007+3.46E-6*P)
   qs = es*621.97/(P-0.378*es)
   copy_VarMeta(q, qs)
   delete(es)
  ; latent heat of evaporation
   Le = (2.501-0.00237*ts)*1.0E6
  ; Density
   rhoa = P*100./(Rgas*(t+tdk)*(1.0+0.61*q/1000.))
   delete(P)
  ; constant for COARE
   visa = 1.326E-5*(1.0+6.542E-3*t+8.301E-6*t*t-4.84E-9*t*t*t)

;;;;;;;;;
; Make first guesses before iterations
;;;;;;;;;;
   dt    = ts-t-0.0098*zt
   dq    = (qs/1000.)-(q/1000.)
   ug    = 0.5
   ut    = sqrt(u*u+ug*ug)
   u10   = ut*log(10./1e-4)/log(zu/1e-4) ; u10 = u because zu = 10
   usr   = 0.035*u10
   zo10  = 0.011*usr*usr/grav+0.11*visa/usr
   Cd10  = (von/log(10./zo10))^2
   Ch10  = 0.00115
   Ct10  = Ch10/sqrt(Cd10)
   zot10 = 10./exp(von/Ct10)
   Cd    = (von/log(zu/zo10))^2
   Ct    = von/log(zt/zot10)
   CC    = von*Ct/Cd
   Ribcu = -zu/zi/0.004/Beta^3
   ; Calculate richardson number
   Ribu = -grav*zu/(t+tdk)*((dt+0.61*(t+tdk)*dq)/ut^2)
   nits = 3
   ; Calculate different richardson number situations
   zetu = new(dims,"float")
   zetu = where(Ribu .lt. 0.0, CC*Ribu/(1+Ribu/Ribcu), zetu)
   zetu = where(Ribu .ge. 0.0, CC*Ribu*(1+27./9.*Ribu/CC), zetu)
   L10 = zu/zetu

; Addressed below in the loop, not here
;	if zetu>50;
;		nits=1;
;	end;

   ; Calculate stability for momentum transfer
   dumx = (1.-15.*(zu/L10))^(0.25)
   psik = 2.*log((1.+dumx)/2.)+log((1.+dumx*dumx)/2.)-2*atan(dumx)+2*atan(1)
   psik = where(psik .eq. "-nan", psik@_FillValue, psik)
   delete(dumx)
   dumx = (1.-10.15*(zu/L10))^(0.3333)
   psic_tmp1 = 1.5*log((1+dumx+dumx*dumx)/3.)-sqrt(3.)*atan((1.+2.*dumx)/sqrt(3.))
   delete(dumx)
   psic_tmp1 = where(psic_tmp1 .eq. "-nan", psic_tmp1@_FillValue, psic_tmp1)
   psic = psic_tmp1 + 4.*atan(1.)/sqrt(3.)
   delete(psic_tmp1)
   f = (zu/L10)*(zu/L10)/(1.+(zu/L10)*(zu/L10))
   psiu = (1.0 - f)*psik+f*psic
   delete(f)
   c = 0.35*(zu/L10)
   c = where(c .gt. 50.0, 50.0, c)
   denom = exp(c)
   denom = where(denom .eq. 0.0, denom@_FillValue,denom)
   dum = -((1.0+(zu/L10))^1.0+0.667*((zu/L10)-14.28)/denom+8.525)
   psiu = where((zu/L10) .gt. 0.0, dum, psiu)
   delete(c)
   delete(denom)
   delete(dum)
   delete(psik)
   delete(psic)

   ; Calculate stability for temperature/moisture transfer
   dumx = (1.-15.*(zt/L10))^0.5
   psik = 2.*log((1.+dumx)/2.)
   psik = where(psik .eq. "-nan", psik@_FillValue, psik)
   delete(dumx)
   dumx = (1.-34.15*(zt/L10))^(0.3333)
   psic_tmp1 = 1.5*log((1+dumx+dumx*dumx)/3.)-sqrt(3.)*atan((1.+2.*dumx)/sqrt(3.))
   delete(dumx)
   psic_tmp1 = where(psic_tmp1 .eq. "-nan", psic_tmp1@_FillValue, psic_tmp1)
   psic = psic_tmp1 + 4.*atan(1.)/sqrt(3.)
   delete(psic_tmp1)
   f = (zt/L10)*(zt/L10)/(1+(zt/L10)*(zt/L10))
   psit = (1.0 - f)*psik+f*psic
   delete(f)
   c = 0.35*(zt/L10)
   c = where(c .gt. 50.0, 50.0, c)
   denom = exp(c)
   denom = where(denom .eq. 0.0, denom@_FillValue,denom)
   dum = -((1.0+2.0/3.0*(zt/L10))^1.5+0.6667*((zt/L10)-14.28)/denom+8.525)
   psit = where((zt/L10) .gt. 0.0, dum, psit)
   delete(c)
   delete(denom)
   delete(dum)
   delete(psik)
   delete(psic)
   delete(L10)

   usr = ut*von/(log(zu/zo10)-psiu)
   tsr = -dt*von/(log(zt/zot10)-psit)
   qsr = -dq*von/(log(zq/zot10)-psit)

   ; Calculate charnock parameter
   charn = new(dims,"float")
   charn = 0.011 ; for speeds below 10m/s
   dum = 0.011+(ut-10.0)/(18.0-10.0)*(0.018-0.011)
   charn = where(ut .gt. 10.0, dum, charn)
   delete(dum)
   charn = where(ut .gt. 18.0, 0.018, charn)

   ; delete unnecessary vars
   delete(ug)
   delete(u10)
   delete(zo10)
   delete(Cd10)
   delete(Ch10)
   delete(Ct10)
   delete(zot10)
   delete(Cd)
   delete(Ct)
   delete(CC)
   delete(Ribcu)
   delete(Ribu)
;   delete(zetu)

; Go over iteration loop to "close" turbulence
   print("Starting iterations for turbulence")
   i = 0
   do i = 0,nits-1
     zet = von*grav*zu/(t+tdk)*(tsr*(1.0+0.61*(q/1000.))+0.61*(t+tdk)*qsr)/(usr*usr)/(1.0+0.61*(q/1000.))
     zo = charn*usr*usr/grav+0.11*visa/usr  ; roughness length
     rr = zo*usr/visa
     L = zu/zet
     L = where(L .eq. 0.0, L@_FillValue, L) ; divide by L later, so can't = 0
     zoq = 5.5E-5/rr^0.6
     zoq = where(zoq .lt. 1.15E-4, 1.15E-4, zoq)
     zot = zoq

     ; Calculate new stability for momentum transfer
     dumx = (1.-15.*(zu/L))^(0.25)
     psik = 2.*log((1.+dumx)/2.)+log((1.+dumx*dumx)/2.)-2*atan(dumx)+2*atan(1)
     psik = where(psik .eq. "-nan", psik@_FillValue, psik)
     delete(dumx)
     dumx = (1.-10.15*(zu/L))^(0.3333)
     psic_tmp1 = 1.5*log((1+dumx+dumx*dumx)/3.)-sqrt(3.)*atan((1.+2.*dumx)/sqrt(3.))
     delete(dumx)
     psic_tmp1 = where(psic_tmp1 .eq. "-nan", psic_tmp1@_FillValue, psic_tmp1)
     psic = psic_tmp1 + 4.*atan(1.)/sqrt(3.)
     delete(psic_tmp1)
     f = (zu/L)*(zu/L)/(1.+(zu/L)*(zu/L))
     psiu = (1.0 - f)*psik+f*psic
     delete(f)
     c = 0.35*(zu/L)
     c = where(c .gt. 50.0, 50.0, c)
     denom = exp(c)
     denom = where(denom .eq. 0.0, denom@_FillValue,denom)
     dum = -((1.+(zu/L))^1.0+0.667*((zu/L)-14.28)/denom+8.525)
     psiu = where((zu/L) .gt. 0.0, dum, psiu)
     delete(c)
     delete(denom)
     delete(dum)
     delete(psik)
     delete(psic)

     ; Calculate new stability for temperature/moisture transfer
     dumx = (1.-15.*(zt/L))^0.5
     psik = 2.*log((1.+dumx)/2.)
     psik = where(psik .eq. "-nan", psik@_FillValue, psik)
     delete(dumx)
     dumx = (1.-34.15*(zt/L))^(0.3333)
     psic_tmp1 = 1.5*log((1+dumx+dumx*dumx)/3.)-sqrt(3.)*atan((1.+2.*dumx)/sqrt(3.))
     delete(dumx)
     psic_tmp1 = where(psic_tmp1 .eq. "-nan", psic_tmp1@_FillValue, psic_tmp1)
     psic = psic_tmp1 + 4.*atan(1.)/sqrt(3.)
     delete(psic_tmp1)
     f = (zt/L)*(zt/L)/(1+(zt/L)*(zt/L))
     psit = (1.0 - f)*psik+f*psic
     delete(f)
     c = 0.35*(zt/L)
     c = where(c .gt. 50.0, 50.0, c)
     denom = exp(c)
     denom = where(denom .eq. 0.0, denom@_FillValue,denom)
     dum = -((1.0+2./3.*(zt/L))^1.5+0.6667*((zt/L)-14.28)/denom+8.525)
     psit = where((zt/L) .gt. 0.0, dum, psit)
     delete(c)
     delete(denom)
     delete(dum)
     delete(psik)
     delete(psic)

     ; Calculate ustar, tstar, qstar
     usr = ut*von/(log(zu/zo)-psiu)
     tsr = -dt*von/(log(zt/zot)-psit)
     qsr = -dq*von/(log(zq/zoq)-psit)

     ; Calculate gustiness of wind (turbulence)
     Bf = -grav/(t+tdk)*usr*(tsr+0.61*(t+tdk)*qsr) 
     ug = Beta*(Bf*zi)^(0.3333)          ; For values of Bf .gt. 0.0
     ug = where(Bf .le. 0.0, 0.2, ug)   ; For values of Bf .lt. 0.0
     ut = sqrt(u*u + ug*ug)

     if (i .eq. 1) then
       ; for rare instances of zetu > 50.0, just need one iteration
       usr_keep = usr
       tsr_keep = tsr
       qsr_keep = qsr
       ut_keep = ut
     end if

     print("done with iteration "+ (i+1) +" of "+nits)
   end do

   ; Delete unneded vars
   delete(ug)
   delete(t)
   delete(dt)
   delete(q)
   delete(dq)
   delete(visa)
   delete(charn)
   delete(zet)
   delete(zo)
   delete(zoq)
   delete(zot)
   delete(psiu)
   delete(psit)
   delete(Bf)
   delete(rr)
   delete(L)
   if (tag_0 .ne. "wrf50")then
     delete(ts)
     delete(qs)
     delete(dims)
     delete(grav)
   end if

   ; Calculate fluxes
   tau = rhoa*usr*usr*u/ut        ; stress
   tau_one = rhoa*usr_keep*usr_keep*u/ut_keep
   tau = where(zetu .gt. 50.0, tau_one, tau)
   delete(tau_one)
   delete(ut_keep)
   tau = where(tau .eq. "nan", tau@_FillValue, tau)
   tau = where(tau .eq. "-nan", tau@_FillValue, tau)

   shflx = -rhoa*cpa*usr*tsr      ; sensible  
   shflx_one = -rhoa*cpa*usr_keep*tsr_keep
   shflx = where(zetu .gt. 50.0, shflx_one, shflx)
   delete(shflx_one)
   delete(tsr_keep)
   shflx = where(shflx .eq. "nan", shflx@_FillValue, shflx)
   shflx = where(shflx .eq. "-nan", shflx@_FillValue, shflx)

   lhflx = -rhoa*Le*usr*qsr       ; latent
   lhflx_one = -rhoa*cpa*usr_keep*qsr_keep
   lhflx = where(zetu .gt. 50.0, lhflx_one, lhflx)
   delete(lhflx_one)
   delete(usr_keep)
   delete(qsr_keep)
   delete(zetu)
   lhflx = where(lhflx .eq. "nan", lhflx@_FillValue, lhflx)
   lhflx = where(lhflx .eq. "-nan", lhflx@_FillValue, lhflx)

   ; in marginal ice zone, multiply flux by ice fraction (seaice_1, to match sfc vars)
   lhflx_fracice = where(.not.ismissing(SeaIce) .and. SeaIce .gt. 0.15, lhflx*(1-SeaIce), lhflx)
   shflx_fracice = where(.not.ismissing(SeaIce) .and. SeaIce .gt. 0.15, shflx*(1-SeaIce), shflx)

   print("Completed flux calculations")

;;;;;;;;;
; Do Array sorting and finding of percentiles for each point
;;;;;;;;;

   ;; Cape Farewell: grab data and sort it
   print("Calculating Cape Farewell percentiles")
   CF_U10 = U10(:,0)
   qsort(CF_U10)
   CF_lhflx = lhflx(:,0)
   qsort(CF_lhflx)
   CF_shflx = lhflx(:,0)
   qsort(CF_shflx)   
   CF_lhflx_frac = lhflx_fracice(:,0)
   qsort(CF_lhflx_frac)
   CF_shflx_frac = lhflx_fracice(:,0)
   qsort(CF_shflx_frac)   

   ; preallocate arrays for percentiles
   CF_U10_pcnt = new((/101/),"float")
   CF_lhflx_pcnt = new((/101/),"float")
   CF_shflx_pcnt = new((/101/),"float")
   CF_lhflx_frac_pcnt = new((/101/),"float")
   CF_shflx_frac_pcnt = new((/101/),"float")

   p =0
   do p = 0,101-1
     dum = tofloat(p)
     pcnt_loc = round(((dum/100.)*(times0-1)),3)
     ; write values
     CF_U10_pcnt(p) = CF_U10(pcnt_loc)
     CF_lhflx_pcnt(p) = CF_lhflx(pcnt_loc)
     CF_shflx_pcnt(p) = CF_shflx(pcnt_loc)
     CF_lhflx_frac_pcnt(p) = CF_lhflx_frac(pcnt_loc)
     CF_shflx_frac_pcnt(p) = CF_shflx_frac(pcnt_loc)
     delete(dum)
     delete(pcnt_loc)
   end do

   ; delete sorted data
   delete(CF_U10)
   delete(CF_lhflx)
   delete(CF_shflx)
   delete(CF_lhflx_frac)
   delete(CF_shflx_frac)
   print("Completed Cape Farewell calculations")

   ;; Denmark Strait South: grab data and sort it
   print("Calculating Denmark Strait South percentiles")
   DSS_U10 = U10(:,1)
   qsort(DSS_U10)
   DSS_lhflx = lhflx(:,1)
   qsort(DSS_lhflx)
   DSS_shflx = lhflx(:,1)
   qsort(DSS_shflx)   
   DSS_lhflx_frac = lhflx_fracice(:,1)
   qsort(DSS_lhflx_frac)
   DSS_shflx_frac = lhflx_fracice(:,1)
   qsort(DSS_shflx_frac)   

   ; preallocate arrays for percentiles
   DSS_U10_pcnt = new((/101/),"float")
   DSS_lhflx_pcnt = new((/101/),"float")
   DSS_shflx_pcnt = new((/101/),"float")
   DSS_lhflx_frac_pcnt = new((/101/),"float")
   DSS_shflx_frac_pcnt = new((/101/),"float")

   p =0
   do p = 0,101-1
     dum = tofloat(p)
     pcnt_loc = round(((dum/100.)*(times0-1)),3)
     ; write values
     DSS_U10_pcnt(p) = DSS_U10(pcnt_loc)
     DSS_lhflx_pcnt(p) = DSS_lhflx(pcnt_loc)
     DSS_shflx_pcnt(p) = DSS_shflx(pcnt_loc)
     DSS_lhflx_frac_pcnt(p) = DSS_lhflx_frac(pcnt_loc)
     DSS_shflx_frac_pcnt(p) = DSS_shflx_frac(pcnt_loc)
     delete(dum)
     delete(pcnt_loc)
   end do

   ; delete sorted data
   delete(DSS_U10)
   delete(DSS_lhflx)
   delete(DSS_shflx)
   delete(DSS_lhflx_frac)
   delete(DSS_shflx_frac)
   print("Completed Denmark Strait South calculations")

   ;; Denmark Strait North: grab data and sort it
   print("Calculating Denmark Strait North percentiles")
   DSN_U10 = U10(:,2)
   qsort(DSN_U10)
   DSN_lhflx = lhflx(:,2)
   qsort(DSN_lhflx)
   DSN_shflx = lhflx(:,2)
   qsort(DSN_shflx)   
   DSN_lhflx_frac = lhflx_fracice(:,2)
   qsort(DSN_lhflx_frac)
   DSN_shflx_frac = lhflx_fracice(:,2)
   qsort(DSN_shflx_frac)   

   ; preallocate arrays for percentiles
   DSN_U10_pcnt = new((/101/),"float")
   DSN_lhflx_pcnt = new((/101/),"float")
   DSN_shflx_pcnt = new((/101/),"float")
   DSN_lhflx_frac_pcnt = new((/101/),"float")
   DSN_shflx_frac_pcnt = new((/101/),"float")

   p =0
   do p = 0,101-1
     dum = tofloat(p)
     pcnt_loc = round(((dum/100.)*(times0-1)),3)
     ; write values
     DSN_U10_pcnt(p) = DSN_U10(pcnt_loc)
     DSN_lhflx_pcnt(p) = DSN_lhflx(pcnt_loc)
     DSN_shflx_pcnt(p) = DSN_shflx(pcnt_loc)
     DSN_lhflx_frac_pcnt(p) = DSN_lhflx_frac(pcnt_loc)
     DSN_shflx_frac_pcnt(p) = DSN_shflx_frac(pcnt_loc)
     delete(dum)
     delete(pcnt_loc)
   end do

   ; delete sorted data
   delete(DSN_U10)
   delete(DSN_lhflx)
   delete(DSN_shflx)
   delete(DSN_lhflx_frac)
   delete(DSN_shflx_frac)
   print("Completed Denmark Strait North calculations")
print("completed percentile calculations")

; assign metadata
CF_U10_pcnt@long_name = "10m wind percentiles"
CF_U10_pcnt@units = "m s-1"
CF_U10_pcnt@lat = lats(0)
CF_U10_pcnt@lon = lons(0)
copy_VarMeta(CF_U10_pcnt, CF_lhflx_pcnt)
CF_lhflx_pcnt@long_name = "Latent Heat Flux percentiles"
CF_lhflx_pcnt@units = "W m-2"
copy_VarMeta(CF_lhflx_pcnt, CF_shflx_pcnt)
CF_shflx_pcnt@long_name = "Sensible Heat Flux percentiles"
copy_VarMeta(CF_lhflx_pcnt, CF_lhflx_frac_pcnt)
CF_lhflx_frac_pcnt@long_name = "Latent Heat Flux (with ocn weight) percentiles"
copy_VarMeta(CF_lhflx_pcnt, CF_shflx_frac_pcnt)
CF_shflx_frac_pcnt@long_name = "Sensible Heat Flux (with ocn weight) percentiles"

DSS_U10_pcnt@long_name = "10m wind percentiles"
DSS_U10_pcnt@units = "m s-1"
DSS_U10_pcnt@lat = lats(1)
DSS_U10_pcnt@lon = lons(1)
copy_VarMeta(DSS_U10_pcnt, DSS_lhflx_pcnt)
DSS_lhflx_pcnt@long_name = "Latent Heat Flux percentiles"
DSS_lhflx_pcnt@units = "W m-2"
copy_VarMeta(DSS_lhflx_pcnt, DSS_shflx_pcnt)
DSS_shflx_pcnt@long_name = "Sensible Heat Flux percentiles"
copy_VarMeta(DSS_lhflx_pcnt, DSS_lhflx_frac_pcnt)
DSS_lhflx_frac_pcnt@long_name = "Latent Heat Flux (with ocn weight) percentiles"
copy_VarMeta(DSS_lhflx_pcnt, DSS_shflx_frac_pcnt)
DSS_shflx_frac_pcnt@long_name = "Sensible Heat Flux (with ocn weight) percentiles"

DSN_U10_pcnt@long_name = "10m wind percentiles"
DSN_U10_pcnt@units = "m s-1"
DSN_U10_pcnt@lat = lats(2)
DSN_U10_pcnt@lon = lons(2)
copy_VarMeta(DSN_U10_pcnt, DSN_lhflx_pcnt)
DSN_lhflx_pcnt@long_name = "Latent Heat Flux percentiles"
DSN_lhflx_pcnt@units = "W m-2"
copy_VarMeta(DSN_lhflx_pcnt, DSN_shflx_pcnt)
DSN_shflx_pcnt@long_name = "Sensible Heat Flux percentiles"
copy_VarMeta(DSN_lhflx_pcnt, DSN_lhflx_frac_pcnt)
DSN_lhflx_frac_pcnt@long_name = "Latent Heat Flux (with ocn weight) percentiles"
copy_VarMeta(DSN_lhflx_pcnt, DSN_shflx_frac_pcnt)
DSN_shflx_frac_pcnt@long_name = "Sensible Heat Flux (with ocn weight) percentiles"

;;;;;;;;;
; Write extreme values to file
;;;;;;;;;

; Create new file that corresponds to this node for averages/variances
fout_avg = "net_"+fname1+"-extremes-fracice-point-percentiles"
net_avg = addfile("./"+fout_avg+".nc","c")

; Write percentile information
net_avg ->CF_U10_pcnt = CF_U10_pcnt
net_avg ->CF_lhflx_pcnt = CF_lhflx_pcnt
net_avg ->CF_shflx_pcnt = CF_shflx_pcnt
net_avg ->CF_lhflx_frac_pcnt = CF_lhflx_frac_pcnt
net_avg ->CF_shflx_frac_pcnt = CF_shflx_frac_pcnt
 
net_avg ->DSS_U10_pcnt = DSS_U10_pcnt
net_avg ->DSS_lhflx_pcnt = DSS_lhflx_pcnt
net_avg ->DSS_shflx_pcnt = DSS_shflx_pcnt
net_avg ->DSS_lhflx_frac_pcnt = DSS_lhflx_frac_pcnt
net_avg ->DSS_shflx_frac_pcnt = DSS_shflx_frac_pcnt

net_avg ->DSN_U10_pcnt = DSN_U10_pcnt
net_avg ->DSN_lhflx_pcnt = DSN_lhflx_pcnt
net_avg ->DSN_shflx_pcnt = DSN_shflx_pcnt
net_avg ->DSN_lhflx_frac_pcnt = DSN_lhflx_frac_pcnt
net_avg ->DSN_shflx_frac_pcnt = DSN_shflx_frac_pcnt

   ; Delete other variables that muck up the next loop
   delete(ut)
   delete(rhoa)
   delete(usr)
   delete(tsr)
   delete(qsr)
   delete(Z_sfc)

  ;; delete variables to use again
  delete(fout_avg)
  delete(net_avg)
  delete(node_files)
  delete(Le)
  delete(SeaIce)

print("Finished averaging variables for "+fname1)


;;;;;;;;;;;;;;;;;;;;;; END script
end
