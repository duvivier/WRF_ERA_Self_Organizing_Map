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
;fname1 = "met_em-2005-11-01_00.era_i.all" ;"wrf-2005-11-01_00.green10"
;dir_in = "./"
;dir_out = "./"
; ******************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; BEGIN SCRIPT
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

;;;;;;;;;
; calculate Node averages for flux variables
;;;;;;;;;;
   ; get tag telling us what type of data it is and load:
   tmp_ch = stringtochar(fname1)
   tag = chartostring(tmp_ch(0:2))
   ; if wrf, get resolution
   if (tag .eq. "wrf")then
     res = chartostring(tmp_ch(23:24))
     f1 = addfile(dir_in+fname1+".cf.nc","r")
   end if
   if (tag .eq. "met")then
     res = "50"
     f1 = addfile(dir_in+fname1+"nc","r")
   end if
   delete(tmp_ch)

   ; Create new file that corresponds to this node for averages/variances
   if (tag .eq. "wrf")then
     fout = fname1+"-coare-sst"
   end if
   if (tag .eq. "met")then
     dum = stringtochar(fname1)
     fout = chartostring(dum(0:25))+"-coare-sst"
     delete(dum)
   end if
   outfile = addfile(dir_out+fout+".nc","c")

  ; files that do not need to be averaged
   Z_sfc = f1->Z_sfc
   lat   = f1->lat
   lon   = f1->lon

  ; write to new average file
   outfile ->lat = lat
   print("latitude")
   outfile ->lon = lon
   print("longitude") 
   outfile ->Z_sfc = Z_sfc
   print("Terrain height")
   ;delete(lat)
   delete(lon)
   delete(Z_sfc)

  ; Calculate gravity based on latitude
   dum=sin(lat*(3.14159/180.));
   grav = 9.7803267715*(1+c1*dum^2+c2*dum^4+c3*dum^6+c4*dum^8)
   outfile ->grav = grav
   delete(dum)
   delete(lat)

  ; Go through each type of surface variable and calculate average and variance
  ;; Sea Ice Concentration
   SeaIce = f1->SeaIce(0,:,:)
   outfile ->SeaIce = SeaIce
   print("Seaice")
   ;delete(SeaIce) 

;;;;;;;;;
; Write input variables
;;;;;;;;;
  ;; winds at 10m
   u_10m = f1->u_10m_tr(0,:,:)
   v_10m = f1->v_10m_tr(0,:,:)
   u = sqrt(u_10m^2 + v_10m^2)
   copy_VarMeta(u_10m, u)
   delete(u_10m)
   delete(v_10m)
   u@long_name = "10m wind speed"
   outfile ->wspd_10m = u
   print("10m wind speed")

; get dimensions going into average
  dims = dimsizes(u)
  dims0 = dims(0)
  dims1 = dims(1)

  ;; Load surface and 2m variables
   P  = f1->p_sfc(0,:,:)
   ; deal with SST for met_em files
   if (tag .eq. "met")then
     tmp_ch = stringtochar(fname1)
     tmp_date = chartostring(tmp_ch(7:19))
     fname_wrf = "wrf-"+tmp_date+".green50"
     dir_wrf = "/data3/duvivier/SOM/analysis/flux_compare/wrf50_coare_fluxes/orig_files/"
     f_wrf = addfile(dir_wrf+fname_wrf+".cf.nc","r")
     ts = f_wrf->T_sfc(0,:,:)
     ts = where(ts .lt. 271.35, 271.35, ts)
     delete(tmp_ch)
     delete(tmp_date)
     delete(fname_wrf)
     delete(dir_wrf)
     delete(f_wrf)
   end if
   if (tag .eq. "wrf" .and. res .eq. "50")
     ts = f1->T_sfc(0,:,:)
     ts = where(ts .lt. 271.35, 271.35, ts)
   end if
   if (tag .eq. "wrf" .and. res .eq. "10")
     print("Interpolating WRF50 SST")
     ; need to grab and interpolate WRF50 sst
     tmp_ch = stringtochar(fname1)
     tmp_date = chartostring(tmp_ch(4:16))
     fname_wrf = "wrf-"+tmp_date+".green50"
     dir_wrf = "/data3/duvivier/SOM/analysis/flux_compare/wrf50_coare_fluxes/orig_files/"
     f_wrf = addfile(dir_wrf+fname_wrf+".cf.nc","r")
     ts_tmp = f_wrf->SST(0,:,:)
     Z_sfc_tmp = f_wrf->Z_sfc
     Z_sfc_tmp_1d = ndtooned(Z_sfc_tmp)
     delete(tmp_ch)
     delete(tmp_date)
     delete(fname_wrf)
     delete(dir_wrf)
     delete(f_wrf)
     
     ; get dimensions necessary for 10km size
     dims_tmp = dimsizes(P)
     n_sn_1 = dims_tmp(0)
     n_we_1 = dims_tmp(1)
     delete(dims_tmp)
     n_tot_1 = n_sn_1*n_we_1

     ; get weights and indicies for regridding sst
     weightin = addfile("/data3/duvivier/SOM/DATA/weightings_WRF50_to_WRF10.nc","r")
     interp_ind = weightin->interp_ind
     interp_wgt = weightin->interp_wgt     
     ; Make arrays we'll need in interpolation
     ts = new((/n_sn_1,n_we_1/),"float")
     ts_1d = new((/n_tot_1/),"float")
     ts_tmp_1d = ndtooned(ts_tmp)

     do i = 0, n_tot_1 - 1
       indices_all = interp_ind(i,:)
       n_indices = num(.not.ismissing(indices_all))
       if (n_indices .ne. 0.0) then
         indices = indices_all(0:n_indices-1)
         weight_all = interp_wgt(i,:)
         weight = weight_all(0:n_indices-1)
         ; just include points with terrain height less than 10m
         ; or coastal pts too cold. Can't just use land mask because
         ; that includes sea ice points too.
         terrain_sub = Z_sfc_tmp_1d(indices)
         sealevel = ind(terrain_sub .lt. 10.0)
         n_sealevel = num(.not.ismissing(sealevel))
         if (n_sealevel .ne. 0.0) then
           ts_1d(i) = sum(ts_tmp_1d(indices(sealevel))*weight(sealevel)/sum(weight(sealevel)))
         end if
         delete(indices)
         delete(weight)
         delete(terrain_sub)
         delete(sealevel)
       end if
     end do
     ; redimensionalize
     ts(:,:) = onedtond(ts_1d,(/n_sn_1,n_we_1/))
     copy_VarCoords(P,ts)
     delete(ts_1d)
     delete(ts_tmp)
     delete(ts_tmp_1d)

     ; assign nearest neighbor value for new mask interpolated to 10km
     mask_50km_terrain = new((/n_sn_1, n_we_1/),"float")
     mask_50km_1d = new((/n_tot_1/),"float")
     mask_1d = ndtooned(Z_sfc_tmp)
     i = 0
     do i = 0, n_tot_1 -1
       indices_all = interp_ind(i,:)
       n_indices = num(.not.ismissing(indices_all))
       if(n_indices .ne. 0.0)then
         indices = indices_all(0:n_indices-1)
         weight_all = interp_wgt(i,:)
         weight = weight_all(0:n_indices-1)
         closest_pt = ind(weight .eq. max(weight))
         mask_50km_1d(i) = mask_1d(indices(closest_pt))
         delete(weight)
         delete(indices)
         delete(closest_pt)
       end if
     end do
     ; redimensionalize
     mask_50km_terrain = onedtond(mask_50km_1d, (/n_sn_1,n_we_1/))
     mask_50km_terrain = where(mask_50km_terrain .lt. 10.0, 1, 0)
     mask_50km_terrain = where(ismissing(mask_50km_terrain), 0, mask_50km_terrain)
     copy_VarCoords(P,mask_50km_terrain)
     delete(mask_50km_1d)
     delete(mask_1d)
     delete(Z_sfc_tmp)
   end if
   ts = ts - tdk
   ts@units = "C"
   t  = f1->T_2m(0,:,:)
   if (tag .eq. "wrf")then
     t = t - tdk
     t@units = "C"
   end if
   q  = f1->q_2m(0,:,:)
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
  ; constant for COARE
   visa = 1.326E-5*(1.0+6.542E-3*t+8.301E-6*t*t-4.84E-9*t*t*t)

;   delete(grav)  ; for now just use single value
;   grav = 9.81  ; set to constant

;;;;;;;;;
; Write variables at sfc and 2m
;;;;;;;;;;
   outfile ->P_sfc = P
   print("Pressure at surface")
   delete(P)
  ;; Temperature gradient and sfc and 2m variables
   T_grad = (ts - t)
   copy_VarMeta(t,T_grad)
   T_grad@long_name = "Temperature gradient (sfc - 2m)"
   T_grad@standard_name = "Temp_grad"
   outfile ->T_grad = T_grad
   print("Temperature gradient")
   delete(T_grad) 
   outfile ->SST = ts
   print("Temperature at surface")
   outfile ->T_2m = t
   print("Temperature at 2m")
   if (tag .eq. "wrf" .and. res .eq. "10")
     outfile ->mask_50km_terrain = mask_50km_terrain
     print("50km terrain mask")
   end if

  ;; Mixing Ratio gradient and sfc and 2m variables
   q_grad = (qs - q)
   copy_VarMeta(qs,q_grad)
   q_grad@long_name = "Mixing Ratio gradient (sfc - 2m)"
   q_grad@standard_name = "Mix_Rad_grad"
   outfile ->q_grad = q_grad
   print("Mixing Ratio gradient")
   delete(q_grad) 
   outfile ->q_sfc = qs
   print("Mixing Ratio at surface")
   outfile ->q_2m = q
   print("Mixing Ratio at 2m")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; 2m-sfc flux calculations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

   ; Delete other variables that muck up the next loop
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

   ; net turbulent fluxes
   Turb_net = lhflx+shflx

   ; Write fluxes to variable
   copy_VarMeta(u,tau)
   tau@long_name = "Surface stress"
   tau@standard_name = "sfc_stress"
   tau@units = "N m-2"
   outfile ->tau = tau
   delete(tau)
   print("Wind stress")
   
   copy_VarMeta(u,shflx)
   shflx@long_name = "Surface Sensible Heat Flux from COARE (+up)"
   shflx@standard_name = "shflx"
   shflx@units = "W m-2"
   outfile ->SHFlx = shflx
   delete(shflx)
   print("Sensible heat flux")

   copy_VarMeta(u,lhflx)
   lhflx@long_name = "Surface Latent Heat Flux from COARE (+up)"
   lhflx@standard_name = "lhflx"
   lhflx@units = "W m-2"
   outfile ->LHFlx = lhflx
   delete(lhflx)
   print("Latent heat flux")

   copy_VarMeta(u,Turb_net)
   Turb_net@long_name = "Net turbulent fluxes from COARE (+up)"
   Turb_net@standard_name = "net_turb_fluxes"
   Turb_net@units = "W m-2"
   outfile ->Turb_net = Turb_net
   delete(Turb_net)
   print("Net Turbulent heat fluxes")

   ; Delete other variables that muck up the next loop
   delete(u)
   delete(ut)
   delete(rhoa)
   delete(usr)
   delete(tsr)
   delete(qsr)
   delete(zu)
   delete(zt)
   delete(zq)
   delete(Le)
   delete(outfile)

;;;;;;;;;;;;;;;;;;;;;; END script
end
