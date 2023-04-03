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
fout_avg = "net_"+fname1+"-extremes"
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
   grav = 9.81       ; gravity

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
  delete(lat)
  delete(lon)
  ;delete(Z_sfc)

  ; Go through each type of surface variable and calculate average and variance
  ;; Sea Ice Concentration
  SeaIce = node_files->SeaIce
  SeaIce_avg = dim_avg_n_Wrap(SeaIce,0)
  net_avg ->SeaIce_avg = SeaIce_avg
  print("Seaice")

  ; get dimensions for # times
  dims = dimsizes(SeaIce)
  times = dims(0)
  net_avg ->number_dates = times
  delete(SeaIce) 
  delete(SeaIce_avg)
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

   print("Completed flux calculations")

;;;;;;;;;
; Do Array sorting and finding of percentiles
;;;;;;;;;
   print("Starting deterimination of percentiles")
   ; get integer location for each percentile
   loc_max = dims0 - 1
   loc_99  = round(((99./100.)*(dims0-1)),3) 
   loc_95  = round(((95./100.)*(dims0-1)),3)
   loc_90  = round(((90./100.)*(dims0-1)),3)
   loc_75  = round(((75./100.)*(dims0-1)),3)
   loc_50  = round(((50./100.)*(dims0-1)),3)

   ; preallocate arrays for data
   ; maximums
   ws_10m_max = new((/dims1,dims2/),"float") 
   tau_max    = new((/dims1,dims2/),"float")
   lhflx_max  = new((/dims1,dims2/),"float")
   shflx_max  = new((/dims1,dims2/),"float")
   ; 99th percentile
   ws_10m_99  = new((/dims1,dims2/),"float") 
   tau_99     = new((/dims1,dims2/),"float")
   lhflx_99   = new((/dims1,dims2/),"float")
   shflx_99   = new((/dims1,dims2/),"float")
   ; 95th percentile
   ws_10m_95  = new((/dims1,dims2/),"float") 
   tau_95     = new((/dims1,dims2/),"float")
   lhflx_95   = new((/dims1,dims2/),"float")
   shflx_95   = new((/dims1,dims2/),"float") 
   ; 90th percentile
   ws_10m_90  = new((/dims1,dims2/),"float") 
   tau_90     = new((/dims1,dims2/),"float") 
   lhflx_90   = new((/dims1,dims2/),"float")
   shflx_90   = new((/dims1,dims2/),"float")
   ; 75th percentile
   ws_10m_75  = new((/dims1,dims2/),"float") 
   tau_75     = new((/dims1,dims2/),"float")
   lhflx_75   = new((/dims1,dims2/),"float")
   shflx_75   = new((/dims1,dims2/),"float") 
   ; 50th percentile
   ws_10m_50  = new((/dims1,dims2/),"float")
   tau_50     = new((/dims1,dims2/),"float") 
   lhflx_50   = new((/dims1,dims2/),"float")
   shflx_50   = new((/dims1,dims2/),"float")

   ; loop through each point and sort the values to get the extreme values
   sn = 0
   we = 0
do we = 0, dims2 - 1
 do sn = 0, dims1 - 1
   ; sort the wind values
   dum = u(:,sn,we)
   qsort(dum)
   ws_10m_max(sn,we) = dum(loc_max)
   ws_10m_99(sn,we) = dum(loc_99)
   ws_10m_95(sn,we) = dum(loc_95)
   ws_10m_90(sn,we) = dum(loc_90)
   ws_10m_75(sn,we) = dum(loc_75)
   ws_10m_50(sn,we) = dum(loc_50)
   delete(dum)

   ; sort the momentum flux values
   dum = tau(:,sn,we)
   qsort(dum)
   tau_max(sn,we) = dum(loc_max)
   tau_99(sn,we) = dum(loc_99)
   tau_95(sn,we) = dum(loc_95)
   tau_90(sn,we) = dum(loc_90)
   tau_75(sn,we) = dum(loc_75)
   tau_50(sn,we) = dum(loc_50)
   delete(dum)

   ; sort the latent heat flux values
   dum = lhflx(:,sn,we)
   qsort(dum)
   lhflx_max(sn,we) = dum(loc_max)
   lhflx_99(sn,we) = dum(loc_99)
   lhflx_95(sn,we) = dum(loc_95)
   lhflx_90(sn,we) = dum(loc_90)
   lhflx_75(sn,we) = dum(loc_75)
   lhflx_50(sn,we) = dum(loc_50)
   delete(dum)

   ; sort the sensible heat flux values
   dum = shflx(:,sn,we)
   qsort(dum)
   shflx_max(sn,we) = dum(loc_max)
   shflx_99(sn,we) = dum(loc_99)
   shflx_95(sn,we) = dum(loc_95)
   shflx_90(sn,we) = dum(loc_90)
   shflx_75(sn,we) = dum(loc_75)
   shflx_50(sn,we) = dum(loc_50)
   delete(dum)

 end do
end do
delete(sn)
delete(we)
delete(u)
delete(tau)
delete(lhflx)
delete(shflx)

print("completed percentile calculations")

;;;;;;;;;
; Write extreme values to file
;;;;;;;;;

   ; Write wind information
   copy_VarMeta(Z_sfc,ws_10m_max)
   ws_10m_max@long_name = "Maximum wind speed"
   ws_10m_max@standard_name = "max_speed"
   ws_10m_max@units = "m s-1"
   net_avg ->ws_10m_max = ws_10m_max
   copy_VarMeta(ws_10m_max,ws_10m_99)
   ws_10m_99@long_name = "99th percentile wind speed"
   ws_10m_99@standard_name = "99th_speed"
   net_avg ->ws_10m_99 = ws_10m_99
   delete(ws_10m_99)
   copy_VarMeta(ws_10m_max,ws_10m_95)
   ws_10m_95@long_name = "95th percentile wind speed"
   ws_10m_95@standard_name = "95th_speed"
   net_avg ->ws_10m_95 = ws_10m_95
   delete(ws_10m_95)
   copy_VarMeta(ws_10m_max,ws_10m_90)
   ws_10m_90@long_name = "90th percentile wind speed"
   ws_10m_90@standard_name = "90th_speed"
   net_avg ->ws_10m_90 = ws_10m_90
   delete(ws_10m_90)
   copy_VarMeta(ws_10m_max,ws_10m_75)
   ws_10m_75@long_name = "75th percentile wind speed"
   ws_10m_75@standard_name = "75th_speed"
   net_avg ->ws_10m_75 = ws_10m_75
   delete(ws_10m_75)
   copy_VarMeta(ws_10m_max,ws_10m_50)
   ws_10m_50@long_name = "50th percentile wind speed"
   ws_10m_50@standard_name = "50th_speed"
   net_avg ->ws_10m_50 = ws_10m_50
   delete(ws_10m_50)
   delete(ws_10m_max)
   print("10m wind speed values")

   ; Write wind stress information
   copy_VarMeta(Z_sfc,tau_max)
   tau_max@long_name = "Maximum surface stress"
   tau_max@standard_name = "max_stress"
   tau_max@units = "N m-2"
   net_avg ->tau_max = tau_max
   copy_VarMeta(tau_max,tau_99)
   tau_99@long_name = "99th percentile surface stress"
   tau_99@standard_name = "99th_stress"
   net_avg ->tau_99 = tau_99
   delete(tau_99)
   copy_VarMeta(tau_max,tau_95)
   tau_95@long_name = "95th percentile surface stress"
   tau_95@standard_name = "95th_stress"
   net_avg ->tau_95 = tau_95
   delete(tau_95)
   copy_VarMeta(tau_max,tau_90)
   tau_90@long_name = "90th percentile surface stress"
   tau_90@standard_name = "90th_stress"
   net_avg ->tau_90 = tau_90
   delete(tau_90)
   copy_VarMeta(tau_max,tau_75)
   tau_75@long_name = "75th percentile surface stress"
   tau_75@standard_name = "75th_stress"
   net_avg ->tau_75 = tau_75
   delete(tau_75)
   copy_VarMeta(tau_max,tau_50)
   tau_50@long_name = "50th percentile surface stress"
   tau_50@standard_name = "50th_stress"
   net_avg ->tau_50 = tau_50
   delete(tau_50)
   delete(tau_max)
   print("Wind stress")

   ; Write latent heat flux information
   copy_VarMeta(Z_sfc,lhflx_max)
   lhflx_max@long_name = "Maximum latent heat flux"
   lhflx_max@standard_name = "max_lhflx"
   lhflx_max@units = "W m-2"
   net_avg ->lhflx_max = lhflx_max
   copy_VarMeta(lhflx_max,lhflx_99)
   lhflx_99@long_name = "99th percentile latent heat flux"
   lhflx_99@standard_name = "99th_lhflx"
   net_avg ->lhflx_99 = lhflx_99
   delete(lhflx_99)
   copy_VarMeta(lhflx_max,lhflx_95)
   lhflx_95@long_name = "95th percentile latent heat flux"
   lhflx_95@standard_name = "95th_lhflx"
   net_avg ->lhflx_95 = lhflx_95
   delete(lhflx_95)
   copy_VarMeta(lhflx_max,lhflx_90)
   lhflx_90@long_name = "90th percentile latent heat flux"
   lhflx_90@standard_name = "90th_lhflx"
   net_avg ->lhflx_90 = lhflx_90
   delete(lhflx_90)
   copy_VarMeta(lhflx_max,lhflx_75)
   lhflx_75@long_name = "75th percentile latent heat flux"
   lhflx_75@standard_name = "75th_lhflx"
   net_avg ->lhflx_75 = lhflx_75
   delete(lhflx_75)
   copy_VarMeta(lhflx_max,lhflx_50)
   lhflx_50@long_name = "50th percentile latent heat flux"
   lhflx_50@standard_name = "50th_lhflx"
   net_avg ->lhflx_50 = lhflx_50
   delete(lhflx_50)
   delete(lhflx_max)
   print("Latent Heat flux")

   ; Write sensible heat flux information
   copy_VarMeta(Z_sfc,shflx_max)
   shflx_max@long_name = "Maximum sensible heat flux"
   shflx_max@standard_name = "max_shflx"
   shflx_max@units = "W m-2"
   net_avg ->shflx_max = shflx_max
   copy_VarMeta(shflx_max,shflx_99)
   shflx_99@long_name = "99th percentile sensible heat flux"
   shflx_99@standard_name = "99th_shflx"
   net_avg ->shflx_99 = shflx_99
   delete(shflx_99)
   copy_VarMeta(shflx_max,shflx_95)
   shflx_95@long_name = "95th percentile sensible heat flux"
   shflx_95@standard_name = "95th_shflx"
   net_avg ->shflx_95 = shflx_95
   delete(shflx_95)
   copy_VarMeta(shflx_max,shflx_90)
   shflx_90@long_name = "90th percentile sensible heat flux"
   shflx_90@standard_name = "90th_shflx"
   net_avg ->shflx_90 = shflx_90
   delete(shflx_90)
   copy_VarMeta(shflx_max,shflx_75)
   shflx_75@long_name = "75th percentile sensible heat flux"
   shflx_75@standard_name = "75th_shflx"
   net_avg ->shflx_75 = shflx_75
   delete(shflx_75)
   copy_VarMeta(shflx_max,shflx_50)
   shflx_50@long_name = "50th percentile sensible heat flux"
   shflx_50@standard_name = "50th_shflx"
   net_avg ->shflx_50 = shflx_50
   delete(shflx_50)
   delete(shflx_max)
   print("Sensible Heat flux")

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

print("Finished averaging variables for "+fname1)


;;;;;;;;;;;;;;;;;;;;;; END script
end
