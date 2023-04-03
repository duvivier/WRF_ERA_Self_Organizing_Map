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
  fname1 = "wrf50_200511_200703_6h"
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

;;;;;;;;;;
; Load information for each file type
;;;;;;;;;;
; Dates from data array index and visual file that places each date at a given node
print("Loading data")

; Create new file that corresponds to this node for averages/variances
fout_avg = "net_avg_"+fname1+"-fluxes-fracice"
net_avg = addfile("./"+fout_avg+".nc","c")

;;;;;;;;;;
; Calculate averages for each data type
;;;;;;;;;;
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

  ; files that do not need to be averaged
  Z_sfc = node_files->Z_sfc
  lat = node_files->lat
  lon = node_files->lon

  ; write to new average file
  net_avg ->lat = lat
  print("latitude")
  net_avg ->lon = lon
  print("longitude")
  net_avg ->Z_sfc = Z_sfc
  print("Terrain height")
  ;delete(lat)
  delete(lon)
  delete(Z_sfc)

  ; Calculate gravity based on latitude
   dum=sin(lat*(3.14159/180.));
   grav = 9.7803267715*(1+c1*dum^2+c2*dum^4+c3*dum^6+c4*dum^8)
   net_avg ->grav = grav
   delete(dum)
   delete(lat)

  ; Go through each type of surface variable and calculate average and variance
  ;; Sea Ice Concentration
  SeaIce = node_files->SeaIce
  SeaIce_avg = dim_avg_n_Wrap(SeaIce,0)
  SeaIce_var = dim_variance_n_Wrap(SeaIce,0)
  net_avg ->SeaIce_avg = SeaIce_avg
  net_avg ->SeaIce_var = SeaIce_var
  print("Seaice")

  ; get dimensions for # times
  dims = dimsizes(SeaIce)
  times = dims(0)
  net_avg ->number_dates = times
  ;delete(SeaIce) 
  delete(SeaIce_avg)
  delete(SeaIce_var)
  delete(dims)

;;;;;;;;;
; Do FLUX CALCULATIONS
;;;;;;;;;
  ;; winds at 10m
   u_10m = node_files->u_10m_tr
   v_10m = node_files->v_10m_tr
   u = sqrt(u_10m^2 + v_10m^2)
   copy_VarMeta(u_10m, u)
   delete(u_10m)
   delete(v_10m)
   u@long_name = "10m wind speed"
   wspd_10m_avg = dim_avg_n_Wrap(u,0)
   wspd_10m_var = dim_variance_n_Wrap(u,0)
   net_avg ->wspd_10m_avg = wspd_10m_avg
   net_avg ->wspd_10m_var = wspd_10m_var
   print("10m wind speed")
   delete(wspd_10m_avg)
   delete(wspd_10m_var)

; get dimensions going into average
  dims = dimsizes(u)
  dims0 = dims(0)
  dims1 = dims(1)
  dims2 = dims(2)

  ;; Load surface and 2m variables
   P  = node_files->p_sfc
   ts = node_files->T_sfc
   ts = ts - tdk
   ts@units = "C"
   ; for surface temperatures, how to deal with the marginal ice zone
   ; for fractions above 15%, set surface temperature to 
   ; -1.8C (freezing pt) or SST, whichever is greater
   ts = where(SeaIce .gt. 0.15 .and. ts .lt. -1.8, -1.8, ts)
   t  = node_files->T_2m
   if (tag_1 .eq. "met_em")then
   else
     t = t - tdk
     t@units = "C"
   end if
   q  = node_files->q_2m
   q = q*1000. 
   q@units = "g/kg"

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

   delete(grav)  ; for now just use single value
   grav = 9.81  ; set to constant

;;;;;;;;;
; Write variables at sfc and 2m
;;;;;;;;;;
  ;; Temperature gradient and sfc and 2m variables
   T_grad = (ts - t)
   copy_VarMeta(t,T_grad)
   T_grad@long_name = "Temperature gradient (sfc - 2m)"
   T_grad@standard_name = "Temp_grad"
   T_grad_avg = dim_avg_n_Wrap(T_grad,0)
   T_grad_var = dim_variance_n_Wrap(T_grad,0)   
   net_avg ->T_grad_avg = T_grad_avg
   net_avg ->T_grad_var = T_grad_var
   print("Temperature gradient")
   delete(T_grad) 
   delete(T_grad_avg)
   delete(T_grad_var)
   T_sfc_avg = dim_avg_n_Wrap(ts,0)
   T_sfc_var = dim_variance_n_Wrap(ts,0)
   net_avg ->T_sfc_avg = T_sfc_avg
   net_avg ->T_sfc_var = T_sfc_var
   print("Temperature at surface")
   delete(T_sfc_avg)
   delete(T_sfc_var)
   T_2m_avg = dim_avg_n_Wrap(t,0)
   T_2m_var = dim_variance_n_Wrap(t,0)
   net_avg ->T_2m_avg = T_2m_avg
   net_avg ->T_2m_var = T_2m_var
   print("Temperature at 2m")
   delete(T_2m_avg)
   delete(T_2m_var)
  ;; Mixing Ratio gradient and sfc and 2m variables
   q_grad = (qs - q)
   copy_VarMeta(qs,q_grad)
   q_grad@long_name = "Mixing Ratio gradient (sfc - 2m)"
   q_grad@standard_name = "Mix_Rad_grad"
   q_grad_avg = dim_avg_n_Wrap(q_grad,0)
   q_grad_var = dim_variance_n_Wrap(q_grad,0)   
   net_avg ->q_grad_avg = q_grad_avg
   net_avg ->q_grad_var = q_grad_var
   print("Mixing Ratio gradient")
   delete(q_grad) 
   delete(q_grad_avg)
   delete(q_grad_var)
   q_sfc_avg = dim_avg_n_Wrap(qs,0)
   q_sfc_var = dim_variance_n_Wrap(qs,0)
   net_avg ->q_sfc_avg = q_sfc_avg
   net_avg ->q_sfc_var = q_sfc_var
   print("Mixing Ratio at surface")
   delete(q_sfc_avg)
   delete(q_sfc_var)  
   q_2m_avg = dim_avg_n_Wrap(q,0)
   q_2m_var = dim_variance_n_Wrap(q,0)
   net_avg ->q_2m_avg = q_2m_avg
   net_avg ->q_2m_var = q_2m_var
   print("Mixing Ratio at 2m")
   delete(q_2m_avg)
   delete(q_2m_var)

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

   ; net turbulent fluxes
   Turb_net = lhflx+shflx

   ; Write fluxes to variable
   copy_VarMeta(u,tau)
   tau@long_name = "Surface stress"
   tau@standard_name = "sfc_stress"
   tau@units = "N m-2"
   tau_avg = dim_avg_n_Wrap(tau,0)
   tau_var = dim_variance_n_Wrap(tau,0) 
   delete(tau)
   net_avg ->tau_avg = tau_avg
   net_avg ->tau_var = tau_var
   delete(tau_avg)
   delete(tau_var)
   print("Wind stress")
   
   copy_VarMeta(u,shflx)
   shflx@long_name = "Surface Sensible Heat Flux from COARE (+up)"
   shflx@standard_name = "shflx"
   shflx@units = "W m-2"
   shflx_avg = dim_avg_n_Wrap(shflx,0)
   shflx_var = dim_variance_n_Wrap(shflx,0) 
   delete(shflx)
   net_avg ->SHFlx_avg = shflx_avg
   net_avg ->SHFlx_var = shflx_var
   delete(shflx_avg)
   delete(shflx_var)
   print("Sensible heat flux")
   copy_VarMeta(u,shflx_fracice)
   shflx_fracice@long_name = "Surface Sensible Heat Flux from COARE (+up) corrected for fraction open ocean"
   shflx_fracice@standard_name = "shflx_fracice"
   shflx_fracice@units = "W m-2"
   shflx_fracice_avg = dim_avg_n_Wrap(shflx_fracice,0)
   shflx_fracice_var = dim_variance_n_Wrap(shflx_fracice,0)
   delete(shflx_fracice)
   net_avg ->SHFlx_fracice_avg = shflx_fracice_avg
   net_avg ->SHFlx_fracice_var = shflx_fracice_var
   delete(shflx_fracice_avg)
   delete(shflx_fracice_var)
   print("Sensible heat flux- corrected for ice fraction")

   copy_VarMeta(u,lhflx)
   lhflx@long_name = "Surface Latent Heat Flux from COARE (+up)"
   lhflx@standard_name = "lhflx"
   lhflx@units = "W m-2"
   lhflx_avg = dim_avg_n_Wrap(lhflx,0)
   lhflx_var = dim_variance_n_Wrap(lhflx,0) 
   delete(lhflx)
   net_avg ->LHFlx_avg = lhflx_avg
   net_avg ->LHFlx_var = lhflx_var
   delete(lhflx_avg)
   delete(lhflx_var)
   print("Latent heat flux")
   copy_VarMeta(u,lhflx_fracice)
   lhflx_fracice@long_name = "Surface Latent Heat Flux from COARE (+up) corrected for fraction open ocean"
   lhflx_fracice@standard_name = "lhflx_fracice"
   lhflx_fracice@units = "W m-2"
   lhflx_fracice_avg = dim_avg_n_Wrap(lhflx_fracice,0)
   lhflx_fracice_var = dim_variance_n_Wrap(lhflx_fracice,0)
   delete(lhflx_fracice)
   net_avg ->LHFlx_fracice_avg = lhflx_fracice_avg
   net_avg ->LHFlx_fracice_var = lhflx_fracice_var
   delete(lhflx_fracice_avg)
   delete(lhflx_fracice_var)
   print("Latent heat flux- corrected for ice fraction")

   copy_VarMeta(u,Turb_net)
   Turb_net@long_name = "Net turbulent fluxes from COARE (+up)"
   Turb_net@standard_name = "net_turb_fluxes"
   Turb_net@units = "W m-2"
   Turb_net_avg = dim_avg_n_Wrap(Turb_net,0)
   Turb_net_var = dim_variance_n_Wrap(Turb_net,0) 
   delete(Turb_net)
   net_avg ->Turb_net_avg = Turb_net_avg
   net_avg ->Turb_net_var = Turb_net_var
   delete(Turb_net_avg)
   delete(Turb_net_var)
   print("Net Turbulent heat fluxes")

   ; Delete other variables that muck up the next loop
   delete(u)
   delete(ut)
   delete(rhoa)
   delete(usr)
   delete(tsr)
   delete(qsr)
   delete(fout_avg)
   delete(net_avg)
   delete(node_files)
   delete(Le)
   delete(SeaIce)

print("Finished averaging variables for "+fname1)


;;;;;;;;;;;;;;;;;;;;;; END script
end
