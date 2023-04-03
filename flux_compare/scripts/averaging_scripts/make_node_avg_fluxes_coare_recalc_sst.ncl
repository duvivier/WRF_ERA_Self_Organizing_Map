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
  datatitle1  = "wrf10_200511_200703_6h"
  datatitle2 = "wrf50_200511_200703_6h"
; ******************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; BEGIN SCRIPT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Dates from data array index and visual file that places each date at a given node
print("Loading data for re-calculating fluxes")
; get tag to let us know if it needs interpolation
title1_ch  = stringtocharacter(datatitle1)
title1_sub = title1_ch(0:4)
tag_1 = chartostring(title1_sub)
title2_ch  = stringtocharacter(datatitle2)
title2_sub = title2_ch(0:4)
tag_2 = chartostring(title2_sub)

; Calculate node counts and frequencies for comparison of interest
  nx_node = stringtoint(nx_input)
  ny_node = stringtoint(ny_input)
  nnode = nx_node*ny_node

; set directory info for data in and data out
indir= "/data3/duvivier/SOM/analysis/flux_compare/node_avgs/"
outdir = "/data3/duvivier/SOM/analysis/flux_compare/node_avgs/fluxes_recalc-sst/"

if (tag_1 .eq. "wrf10")then
  ; get weights and indicies for regridding (WRF50 and era weightings are identical)
  weightin = addfile("/data3/duvivier/SOM/DATA/weightings_WRF50_to_WRF10.nc","r")
  interp_ind = weightin->interp_ind
  interp_wgt = weightin->interp_wgt
end if

;;;;;;;;;;
; Load information for two files
;;;;;;;;;;
; Set constants for flux calculations
   zu    = 10.            ; Height of wind measurement 
   zt    = 2.             ; Height of temperature measurement
   zq    = 2.             ; Height of moisture measurement
   zi    = 600.           ; Height of PBL (taken from COARE algorithm for assumed height)
   Rgas  = 287.1          ; Dry gas constant J/(kg*K)
   cpa   = 1004.67        ; Specific heat at constant pressure J/(kg*K) 
   Beta  = 1.2            ; Constant from COARE algorithm
   von   = 0.4            ; Von Karman constant (unitless)
   c1    = 0.0052790414   ; constant for gravity calculations
   c2    = 0.0000232718   ; constant for gravity calculations
   c3    = 0.0000001262   ; constant for gravity calculations
   c4    = 0.0000000007   ; constant for gravity calculations
   tdk   = 273.16         ; conversion between K and C

n = 0
;;;;;;;;;
; calculate Node averages for flux variables
;;;;;;;;;;
; Load lat/lon/sfc terrain for later use
   ; Load file 1 lat/lon data
   f0 = addfile(indir + "fluxes_fromnodeavgs-sst/node_0x_0y_"+datatitle1+"-fluxes_fromnodeavgs-sst.nc","r")
   lat2d_1 = f0->lat
   lon2d_1 = f0->lon
   z_sfc_1 = f0->Z_sfc
   if (tag_1 .eq. "wrf10")then
     mask_50km = f0->mask_50km_terrain
   end if
   delete(f0)
   dims = dimsizes(lat2d_1)     ; get lat/lon dimensions
   n_sn_1 = dims(0)              ; get south/north points
   n_we_1 = dims(1)              ; get west/east points
   n_tot_1 = n_sn_1*n_we_1              ; get total number of points in high res domain

   fill = new((/1/),"float")

; loop through each node
do y = 0, ny_node - 1
 do x = 0, nx_node - 1
   print("node: "+x+","+y)
   
   ; Load file 1 data
   fname1 = "node_"+x+"x_"+y+"y_"+datatitle1
   f1 = addfile(indir +"fluxes-sst/"+ fname1 + "-fluxes-sst.nc","r")
   f1_fluxes = addfile(indir +"fluxes_fromnodeavgs-sst/"+ fname1 + "-fluxes_fromnodeavgs-sst.nc","r")

   ; Load file 2 data
   fname2 = "node_"+x+"x_"+y+"y_"+datatitle2
   f2 = addfile(indir +"fluxes-sst/"+ fname2 + "-fluxes-sst.nc","r")
   f2_fluxes = addfile(indir +"fluxes_fromnodeavgs-sst/"+ fname2 + "-fluxes_fromnodeavgs-sst.nc","r")

   ; Load data we'll need for calculations
   seaice_1 = f1->SeaIce_avg
   P_sfc_1  = f1->P_sfc_avg
   winds_1  = f1->wspd_10m_avg
   SST_1    = f1->SST_avg
   copy_VarCoords(winds_1, SST_1)
   T_2m_1   = f1->T_2m_avg
   q_sfc_1  = f1->q_sfc_avg
   q_2m_1   = f1->q_2m_avg
   shflx_1  = f1_fluxes->SHFlx_avg
   lhflx_1  = f1_fluxes->LHFlx_avg
   tau_1    = f1_fluxes->tau_avg

   seaice_2 = f2->SeaIce_avg
   P_sfc_2  = f2->P_sfc_avg
   winds_2  = f2->wspd_10m_avg
   SST_2    = f2->SST_avg
   T_2m_2   = f2->T_2m_avg
   q_sfc_2  = f2->q_sfc_avg
   q_2m_2   = f2->q_2m_avg
   shflx_2  = f2_fluxes->SHFlx_avg
   lhflx_2  = f2_fluxes->LHFlx_avg
   tau_2    = f2_fluxes->tau_avg
   z_sfc_2  = f2->Z_sfc

   delete(f1_fluxes)
   delete(f2_fluxes)

   ; Assign fill values
   seaice_1@_FillValue = fill
   P_sfc_1@_FillValue = fill
   winds_1@_FillValue = fill
   SST_1@_FillValue = fill
   T_2m_1@_FillValue = fill 
   q_sfc_1@_FillValue = fill
   q_2m_1@_FillValue = fill 
   shflx_1@_FillValue = fill
   lhflx_1@_FillValue = fill
   tau_1@_FillValue = fill  
   seaice_2@_FillValue = fill
   P_sfc_2@_FillValue = fill
   winds_2@_FillValue = fill
   SST_2@_FillValue = fill
   T_2m_2@_FillValue = fill 
   q_sfc_2@_FillValue = fill
   q_2m_2@_FillValue = fill 
   shflx_2@_FillValue = fill
   lhflx_2@_FillValue = fill
   tau_2@_FillValue = fill 

;;;;;;;;;;
; Interpolate to WRF10 size (if needed)
;;;;;;;;;;
if (tag_1 .eq. "wrf10" .and. tag_2 .ne. "wrf10")then
  print("Interpolating between resolutions")
  ; Make arrays we'll need in interpolation
  seaice_2_new     = new((/n_sn_1,n_we_1/),"float") 
  seaice_2_tmp_1d  = new((/n_tot_1/),"float")
  P_sfc_2_new      = new((/n_sn_1,n_we_1/),"float") 
  P_sfc_2_tmp_1d   = new((/n_tot_1/),"float")
  winds_2_new      = new((/n_sn_1,n_we_1/),"float") 
  winds_2_tmp_1d   = new((/n_tot_1/),"float")
  SST_2_new        = new((/n_sn_1,n_we_1/),"float") 
  SST_2_tmp_1d     = new((/n_tot_1/),"float")
  T_2m_2_new       = new((/n_sn_1,n_we_1/),"float") 
  T_2m_2_tmp_1d    = new((/n_tot_1/),"float")
  q_sfc_2_new      = new((/n_sn_1,n_we_1/),"float") 
  q_sfc_2_tmp_1d   = new((/n_tot_1/),"float")
  q_2m_2_new       = new((/n_sn_1,n_we_1/),"float") 
  q_2m_2_tmp_1d    = new((/n_tot_1/),"float")
  shflx_2_new      = new((/n_sn_1,n_we_1/),"float") 
  shflx_2_tmp_1d   = new((/n_tot_1/),"float")
  lhflx_2_new      = new((/n_sn_1,n_we_1/),"float") 
  lhflx_2_tmp_1d   = new((/n_tot_1/),"float")
  tau_2_new        = new((/n_sn_1,n_we_1/),"float") 
  tau_2_tmp_1d     = new((/n_tot_1/),"float")

  ; Make 1D arrays
  seaice_2_1d = ndtooned(seaice_2(:,:))
  P_sfc_2_1d  = ndtooned(P_sfc_2(:,:))  
  winds_2_1d  = ndtooned(winds_2(:,:)) 
  SST_2_1d    = ndtooned(SST_2(:,:))  
  T_2m_2_1d   = ndtooned(T_2m_2(:,:))
  q_sfc_2_1d  = ndtooned(q_sfc_2(:,:))  
  q_2m_2_1d   = ndtooned(q_2m_2(:,:))
  shflx_2_1d  = ndtooned(shflx_2(:,:))  
  lhflx_2_1d  = ndtooned(lhflx_2(:,:))
  tau_2_1d    = ndtooned(tau_2(:,:))

  ; Need terrain array
  Z_sfc_tmp_1d = ndtooned(z_sfc_2)

  ; Start interpolation loop
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
      if (n_sealevel .ne. 0.0)then
         seaice_2_tmp_1d(i) = sum(seaice_2_1d(indices(sealevel))*weight(sealevel)/sum(weight(sealevel)))
         P_sfc_2_tmp_1d(i)  = sum(P_sfc_2_1d(indices(sealevel))*weight(sealevel)/sum(weight(sealevel)))
         winds_2_tmp_1d(i)  = sum(winds_2_1d(indices(sealevel))*weight(sealevel)/sum(weight(sealevel)))
         SST_2_tmp_1d(i)    = sum(SST_2_1d(indices(sealevel))*weight(sealevel)/sum(weight(sealevel)))
         T_2m_2_tmp_1d(i)   = sum(T_2m_2_1d(indices(sealevel))*weight(sealevel)/sum(weight(sealevel)))
         q_sfc_2_tmp_1d(i)  = sum(q_sfc_2_1d(indices(sealevel))*weight(sealevel)/sum(weight(sealevel)))
         q_2m_2_tmp_1d(i)   = sum(q_2m_2_1d(indices(sealevel))*weight(sealevel)/sum(weight(sealevel)))
         shflx_2_tmp_1d(i)  = sum(shflx_2_1d(indices(sealevel))*weight(sealevel)/sum(weight(sealevel)))
         lhflx_2_tmp_1d(i)  = sum(lhflx_2_1d(indices(sealevel))*weight(sealevel)/sum(weight(sealevel)))
         tau_2_tmp_1d(i)    = sum(tau_2_1d(indices(sealevel))*weight(sealevel)/sum(weight(sealevel)))
       end if	
      delete(indices)
      delete(weight)
      delete(terrain_sub)
      delete(sealevel)
    end if
  end do

  ; redimensionalize
  seaice_2_new(:,:) = onedtond(seaice_2_tmp_1d,(/n_sn_1,n_we_1/))
  P_sfc_2_new(:,:)  = onedtond(P_sfc_2_tmp_1d,(/n_sn_1,n_we_1/))
  winds_2_new(:,:)  = onedtond(winds_2_tmp_1d,(/n_sn_1,n_we_1/))
  SST_2_new(:,:)  = onedtond(SST_2_tmp_1d,(/n_sn_1,n_we_1/))
  T_2m_2_new(:,:)   = onedtond(T_2m_2_tmp_1d,(/n_sn_1,n_we_1/))
  q_sfc_2_new(:,:)  = onedtond(q_sfc_2_tmp_1d,(/n_sn_1,n_we_1/))
  q_2m_2_new(:,:)   = onedtond(q_2m_2_tmp_1d,(/n_sn_1,n_we_1/))
  shflx_2_new(:,:)  = onedtond(shflx_2_tmp_1d,(/n_sn_1,n_we_1/))
  lhflx_2_new(:,:)  = onedtond(lhflx_2_tmp_1d,(/n_sn_1,n_we_1/))
  tau_2_new(:,:)    = onedtond(tau_2_tmp_1d,(/n_sn_1,n_we_1/))

  ; rewrite variable names for later
  delete(seaice_2)
  seaice_2 = seaice_2_new
  delete(seaice_2_new)
  copy_VarMeta(seaice_1, seaice_2)
  delete(P_sfc_2)
  P_sfc_2 = P_sfc_2_new
  delete(P_sfc_2_new)
  copy_VarMeta(P_sfc_1, P_sfc_2)
  delete(winds_2)
  winds_2 = winds_2_new
  delete(winds_2_new)
  copy_VarMeta(winds_1, winds_2)
  delete(SST_2)
  SST_2 = SST_2_new
  delete(SST_2_new)
  copy_VarMeta(SST_1, SST_2)
  delete(T_2m_2)
  T_2m_2 = T_2m_2_new
  delete(T_2m_2_new)
  copy_VarMeta(T_2m_1, T_2m_2)
  delete(q_sfc_2)
  q_sfc_2 = q_sfc_2_new
  delete(q_sfc_2_new)
  copy_VarMeta(q_sfc_1, q_sfc_2)
  delete(q_2m_2)
  q_2m_2 = q_2m_2_new
  delete(q_2m_2_new)
  copy_VarMeta(q_2m_1, q_2m_2)
  delete(shflx_2)
  shflx_2 = shflx_2_new
  delete(shflx_2_new)
  copy_VarMeta(shflx_1, shflx_2)
  delete(lhflx_2)
  lhflx_2 = lhflx_2_new
  delete(lhflx_2_new)
  copy_VarMeta(lhflx_1, lhflx_2)
  delete(tau_2)
  tau_2 = tau_2_new
  delete(tau_2_new)
  copy_VarMeta(tau_1, tau_2)
  print("Finished interpolating")
end if

  ; mask terrain - focus on ocean, flux calcs not valid over land anyway
  seaice_1(:,:) = where(z_sfc_1 .lt. 10., seaice_1(:,:), seaice_1@_FillValue)
  seaice_2(:,:) = where(z_sfc_1 .lt. 10., seaice_2(:,:), seaice_2@_FillValue)
  P_sfc_1(:,:) = where(z_sfc_1 .lt. 10., P_sfc_1(:,:), P_sfc_1@_FillValue)
  P_sfc_2(:,:) = where(z_sfc_1 .lt. 10., P_sfc_2(:,:), P_sfc_2@_FillValue)
  winds_1(:,:) = where(z_sfc_1 .lt. 10., winds_1(:,:), winds_1@_FillValue)
  winds_2(:,:) = where(z_sfc_1 .lt. 10., winds_2(:,:), winds_2@_FillValue)
  SST_1(:,:)   = where(z_sfc_1 .lt. 10., SST_1(:,:), SST_1@_FillValue)
  SST_2(:,:)   = where(z_sfc_1 .lt. 10., SST_2(:,:), SST_2@_FillValue)
  T_2m_1(:,:)  = where(z_sfc_1 .lt. 10., T_2m_1(:,:), T_2m_1@_FillValue)
  T_2m_2(:,:)  = where(z_sfc_1 .lt. 10., T_2m_2(:,:), T_2m_2@_FillValue)
  q_sfc_1(:,:) = where(z_sfc_1 .lt. 10., q_sfc_1(:,:), q_sfc_1@_FillValue)
  q_sfc_2(:,:) = where(z_sfc_1 .lt. 10., q_sfc_2(:,:), q_sfc_2@_FillValue)
  q_2m_1(:,:)  = where(z_sfc_1 .lt. 10., q_2m_1(:,:), q_2m_1@_FillValue)
  q_2m_2(:,:)  = where(z_sfc_1 .lt. 10., q_2m_2(:,:), q_2m_2@_FillValue)
  shflx_1(:,:) = where(z_sfc_1 .lt. 10., shflx_1(:,:), shflx_1@_FillValue)
  shflx_2(:,:) = where(z_sfc_1 .lt. 10., shflx_2(:,:), shflx_2@_FillValue)
  lhflx_1(:,:) = where(z_sfc_1 .lt. 10., lhflx_1(:,:), lhflx_1@_FillValue)
  lhflx_2(:,:) = where(z_sfc_1 .lt. 10., lhflx_2(:,:), lhflx_2@_FillValue)
  tau_1(:,:)   = where(z_sfc_1 .lt. 10., tau_1(:,:), tau_1@_FillValue)
  tau_2(:,:)   = where(z_sfc_1 .lt. 10., tau_2(:,:), tau_2@_FillValue)

print("Creating new node average file")
  ; Create new file that corresponds to this node for fluxes
  fout_node = "node_"+x+"x_"+y+"y_"+tag_1+"_"+tag_2+"_200511_200703_6h-fluxes-recalc-sst"
  node_avg = addfile(outdir+fout_node+".nc","c")

; Write initial values to the file
  ; write to new average file
   node_avg ->lat = lat2d_1
   print("latitude")
   node_avg ->lon = lon2d_1
   print("longitude") 
   node_avg ->Z_sfc = z_sfc_1
   print("Terrain height")
   if (tag_1 .eq. "wrf10")then
     node_avg ->mask_50km_terrain = mask_50km
   end if

  ; Calculate gravity based on latitude
   dum=sin(lat2d_1*(3.14159/180.))
   grav = 9.7803267715*(1+c1*dum^2+c2*dum^4+c3*dum^6+c4*dum^8)
   node_avg ->grav = grav
   delete(dum)

  ;; Sea Ice Concentration
   seaice_1@original_source = tag_1
   seaice_2@original_source = tag_2
   node_avg ->seaice_1 = seaice_1
   node_avg ->seaice_2 = seaice_2
   print("Seaice")
  ;; Sfc Pressure
   P_sfc_1@original_source = tag_1
   P_sfc_2@original_source = tag_2
   node_avg ->P_sfc_1 = P_sfc_1
   node_avg ->P_sfc_2 = P_sfc_2
   print("Surface Pressure")
  ;; 10m winds
   winds_1@original_source = tag_1
   winds_2@original_source = tag_2
   node_avg ->winds_1 = winds_1
   node_avg ->winds_2 = winds_2
   print("10m winds")
  ;; Sfc Temperature
   SST_1@original_source = tag_1
   SST_2@original_source = tag_2
   node_avg ->SST_1 = SST_1
   node_avg ->SST_2 = SST_2
   print("Surface Temperature")
  ;; 2m Temperature
   T_2m_1@original_source = tag_1
   T_2m_2@original_source = tag_2
   node_avg ->T_2m_1 = T_2m_1
   node_avg ->T_2m_2 = T_2m_2
   print("2m Temperature")
  ;; Temperature gradient (sfc - 2m)
   T_grad_1 = SST_1 - T_2m_1
   copy_VarMeta(SST_1, T_grad_1)
   T_grad_1@long_name  = "Temperature gradient (sfc - 2m)"
   T_grad_2 = SST_2 - T_2m_2
   copy_VarMeta(SST_2, T_grad_2)
   T_grad_2@long_name  = "Temperature gradient (sfc - 2m)"
   T_grad_1@original_source = tag_1
   T_grad_2@original_source = tag_2
   node_avg ->T_grad_1 = T_grad_1
   node_avg ->T_grad_2 = T_grad_2
   print("Temperature Gradient")
  ;; Sfc Mixing Ratio
   q_sfc_1@original_source = tag_1
   q_sfc_2@original_source = tag_2
   node_avg ->q_sfc_1 = q_sfc_1
   node_avg ->q_sfc_2 = q_sfc_2
   print("Surface mixing ratio")
  ;; 2m Mixing Ratio
   q_2m_1@original_source = tag_1
   q_2m_2@original_source = tag_2
   node_avg ->q_2m_1 = q_2m_1
   node_avg ->q_2m_2 = q_2m_2
   print("2m Mixing Ratio")
  ;; Mixing Ratio gradient (sfc - 2m)
   q_grad_1 = q_sfc_1 - q_2m_1
   copy_VarMeta(q_sfc_1, q_grad_1)
   q_grad_1@long_name  = "Mixing Ratio gradient (sfc - 2m)"
   q_grad_2 = q_sfc_2 - q_2m_2
   copy_VarMeta(q_sfc_2, q_grad_2)
   q_grad_2@long_name  = "Mixing Ratio gradient (sfc - 2m)"
   q_grad_1@original_source = tag_1
   q_grad_2@original_source = tag_2
   node_avg ->q_grad_1 = q_grad_1
   node_avg ->q_grad_2 = q_grad_2
   print("Mixing Ratio Gradient")
  ;; Sensible Heat flux - original
   shflx_1@original_source = tag_1
   shflx_2@original_source = tag_2
   node_avg ->shflx_orig_1 = shflx_1
   node_avg ->shflx_orig_2 = shflx_2
   print("Sensible Heat Flux")
   ;delete(shflx_1); keep for meta data
   delete(shflx_2)
  ;; Latent Heat flux - original
   lhflx_1@original_source = tag_1
   lhflx_2@original_source = tag_2
   node_avg ->lhflx_orig_1 = lhflx_1
   node_avg ->lhflx_orig_2 = lhflx_2
   print("Latent Heat Flux")
   ;delete(lhflx_1); keep for meta data
   delete(lhflx_2)
  ;; Momentum Flux - original
   tau_1@original_source = tag_1
   tau_2@original_source = tag_2
   node_avg ->tau_orig_1 = tau_1
   node_avg ->tau_orig_2 = tau_2
   print("Momentum Flux")
   ;delete(tau_1) ; keep for meta data
   delete(tau_2)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Recalculate fluxes - loop 1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Replace file 1 winds with file 2 winds, keep the T, q, P variables from file 1
   P  = P_sfc_1
   ts = SST_1
   t  = T_2m_1
   qs = q_sfc_1
   q  = q_2m_1
   u  = winds_2

; Calculate constants
  ; surface saturated mixing ratio
   es = 6.112*exp(17.502*ts/(ts+240.97))*.98*(1.007+3.46E-6*P)
;   qs = es*621.97/(P-0.378*es)
;   copy_VarMeta(q, qs)
;   delete(es)
  ; latent heat of evaporation
   Le = (2.501-0.00237*ts)*1.0E6
  ; Density
   rhoa = P*100./(Rgas*(t+tdk)*(1.0+0.61*q/1000.))
   delete(P)
  ; constant for COARE
   visa = 1.326E-5*(1.0+6.542E-3*t+8.301E-6*t*t-4.84E-9*t*t*t)

   ;delete(grav)  ; for now just use single value
   ;grav = 9.81  ; set to constant

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
   delete(ts)
   delete(dt)
   delete(q)
   delete(qs)
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
   copy_VarMeta(tau_1, tau)

   shflx = -rhoa*cpa*usr*tsr      ; sensible  
   shflx_one = -rhoa*cpa*usr_keep*tsr_keep
   shflx = where(zetu .gt. 50.0, shflx_one, shflx)
   delete(shflx_one)
   delete(tsr_keep)
   shflx = where(shflx .eq. "nan", shflx@_FillValue, shflx)
   shflx = where(shflx .eq. "-nan", shflx@_FillValue, shflx)
   copy_VarMeta(shflx_1, shflx)

   lhflx = -rhoa*Le*usr*qsr       ; latent
   lhflx_one = -rhoa*cpa*usr_keep*qsr_keep
   lhflx = where(zetu .gt. 50.0, lhflx_one, lhflx)
   delete(lhflx_one)
   delete(usr_keep)
   delete(qsr_keep)
   lhflx = where(lhflx .eq. "nan", lhflx@_FillValue, lhflx)
   lhflx = where(lhflx .eq. "-nan", lhflx@_FillValue, lhflx)
   copy_VarMeta(lhflx_1, lhflx)

   ; delete everything else we don't need anymore
   delete(zetu)
   delete(u)
   delete(ut)
   delete(rhoa)
   delete(Le)
   delete(usr)
   delete(tsr)
   delete(qsr)

;;;;;;;;;;
; Write "new" fluxes with wind replaced
;;;;;;;;;; 
  ;; Sensible Heat flux - new wind
   shflx@original_source = "wind from "+tag_2+" temperature from "+tag_1
   node_avg ->shflx_wind_recalc = shflx
   print("Sensible Heat Flux - wind replaced")
   delete(shflx)
  ;; Latent Heat flux - new wind
   lhflx@original_source = "wind from "+tag_2+" moisture from "+tag_1
   node_avg ->lhflx_wind_recalc = lhflx
   print("Latent Heat Flux - wind replaced")
   delete(lhflx)
  ;; Momentum Flux - new wind
   tau@original_source = "wind from "+tag_2
   node_avg ->tau_wind_recalc = tau
   print("Momentum Flux - wind replaced")
   delete(tau)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Recalculate fluxes - loop 2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Replace file 1 T, q, P with file 2, keep winds from file 1
   P  = P_sfc_2
   ts = SST_2
   ; for surface temperatures, how to deal with the marginal ice zone
   ; for fractions above 15%, set surface temperature to 
   ; -1.8C (freezing pt) or SST, whichever is greater
;   ts = where(seaice_2 .gt. 0.15 .and. ts .lt. -1.8, -1.8, ts)
   t  = T_2m_2
   qs = q_sfc_2
   q  = q_2m_2
   u  = winds_1
   
; Calculate constants
  ; surface saturated mixing ratio
   es = 6.112*exp(17.502*ts/(ts+240.97))*.98*(1.007+3.46E-6*P)
;   qs = es*621.97/(P-0.378*es)
;   copy_VarMeta(q, qs)
;   delete(es)
  ; latent heat of evaporation
   Le = (2.501-0.00237*ts)*1.0E6
  ; Density
   rhoa = P*100./(Rgas*(t+tdk)*(1.0+0.61*q/1000.))
   delete(P)
  ; constant for COARE
   visa = 1.326E-5*(1.0+6.542E-3*t+8.301E-6*t*t-4.84E-9*t*t*t)

   ;delete(grav)  ; for now just use single value
   ;grav = 9.81  ; set to constant

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
   delete(ts)
   delete(dt)
   delete(q)
   delete(qs)
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
   copy_VarMeta(tau_1, tau)

   shflx = -rhoa*cpa*usr*tsr      ; sensible  
   shflx_one = -rhoa*cpa*usr_keep*tsr_keep
   shflx = where(zetu .gt. 50.0, shflx_one, shflx)
   delete(shflx_one)
   delete(tsr_keep)
   shflx = where(shflx .eq. "nan", shflx@_FillValue, shflx)
   shflx = where(shflx .eq. "-nan", shflx@_FillValue, shflx)
   copy_VarMeta(shflx_1, shflx)

   lhflx = -rhoa*Le*usr*qsr       ; latent
   lhflx_one = -rhoa*cpa*usr_keep*qsr_keep
   lhflx = where(zetu .gt. 50.0, lhflx_one, lhflx)
   delete(lhflx_one)
   delete(usr_keep)
   delete(qsr_keep)
   lhflx = where(lhflx .eq. "nan", lhflx@_FillValue, lhflx)
   lhflx = where(lhflx .eq. "-nan", lhflx@_FillValue, lhflx)
   copy_VarMeta(lhflx_1, lhflx)

   ; delete everything else we don't need anymore
   delete(zetu)
   delete(u)
   delete(ut)
   delete(rhoa)
   delete(Le)
   delete(usr)
   delete(tsr)
   delete(qsr)

;;;;;;;;;;
; Write "new" fluxes with wind replaced
;;;;;;;;;; 
  ;; Sensible Heat flux -  new sfc_vars
   shflx@original_source = "wind from "+tag_1+" temperature from "+tag_2
   node_avg ->shflx_thermo_vars_recalc = shflx
   print("Sensible Heat Flux - thermo vars replaced")
   delete(shflx)
  ;; Latent Heat flux -  new sfc_vars
   lhflx@original_source = "wind from "+tag_1+" moisture from "+tag_2
   node_avg ->lhflx_thermo_vars_recalc = lhflx
   print("Latent Heat Flux - thermo vars replaced")
   delete(lhflx)
  ;; Momentum Flux - new sfc_vars
   tau@original_source = "wind from "+tag_1
   node_avg ->tau_thermo_vars_recalc = tau
   print("Momentum Flux - thermo vars replaced")
   delete(tau)

; Delete variables from this node for next node loading
   delete(P_sfc_1)
   delete(P_sfc_2)
   delete(shflx_1)
   delete(lhflx_1)
   delete(tau_1)
   delete(winds_1)
   delete(winds_2)
   delete(SST_1)
   delete(SST_2)
   delete(T_2m_1)
   delete(T_2m_2)
   delete(q_sfc_1)
   delete(q_sfc_2)
   delete(q_2m_1)
   delete(q_2m_2)
   delete(seaice_1)
   delete(seaice_2)

end do 
end do




;;;;;;;;;;;;;;;;;;;;;; END script
end
