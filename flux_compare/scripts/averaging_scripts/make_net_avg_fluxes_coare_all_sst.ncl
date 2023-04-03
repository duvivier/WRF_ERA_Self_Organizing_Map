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
  fname1 = "wrf10_200511_200703_6h"
; ******************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; BEGIN SCRIPT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Running node average/variance calculations")
;;;;;;;;;;
; set input file information
;;;;;;;;;;
; wrf10 data
if (fname1 .eq. "wrf10_200511_200703_6h")then
  tag_0 = "wrf10"
end if
if (fname1 .eq. "wrf50_200511_200703_6h")then
  tag_0 = "wrf50"
end if
if (fname1 .eq. "era_i_200511_200703_6h")then
  tag_0 = "era_i"
end if
  node_files = addfile("/data3/duvivier/SOM/analysis/flux_compare/"+tag_0+"_coare_fluxes/coare_fluxes-sst/"+fname1+"-fluxes-sst-all.nc","r")

;;;;;;;;;;
; Load information for each file type
;;;;;;;;;;
; Dates from data array index and visual file that places each date at a given node
print("Loading data")

; Create new file that corresponds to this node for averages/variances
fout_avg = "net_avg_"+fname1+"-fluxes-sst"
net_avg = addfile("./"+fout_avg+".nc","c")

;;;;;;;;;;
; Calculate averages data
;;;;;;;;;;

; files that do not need to be averaged
Z_sfc = node_files->Z_sfc
lat = node_files->lat
lon = node_files->lon
grav = node_files->grav
if (tag_0 .eq. "wrf10")then
  mask_50km_terrain = node_files->mask_50km_terrain
end if

dims = dimsizes(Z_sfc)
dim_files = dims(0)
dim_sn = dims(1)
dim_we = dims(2)

; write to new average file
net_avg ->lat = lat
print("latitude")
net_avg ->lon = lon
print("longitude") 
Z_sfc_avg = dim_avg_n_Wrap(Z_sfc,0)
delete(Z_sfc)
net_avg ->Z_sfc = Z_sfc_avg
print("Terrain height")
grav_avg = dim_avg_n_Wrap(grav,0)
delete(grav)
net_avg ->grav = grav_avg
print("Gravity")
if (tag_0 .eq. "wrf10")then
  mask_avg = dim_avg_n_Wrap(mask_50km_terrain,0)
  net_avg ->mask_50km_terrain = mask_avg
  delete(mask_50km_terrain)
  delete(mask_avg)
end if
delete(lat)
delete(lon)
delete(grav_avg)
delete(Z_sfc_avg)

; write the number of files going into the average for later statistical tests
net_avg ->number_dates = dim_files

; Go through each type of surface variable and calculate average and variance
  ;; Sea Ice Concentration
   SeaIce = node_files->SeaIce
   SeaIce_avg = dim_avg_n_Wrap(SeaIce,0)
   SeaIce_var = dim_variance_n_Wrap(SeaIce,0)
   delete(SeaIce) 
   net_avg ->SeaIce_avg = SeaIce_avg
   net_avg ->SeaIce_var = SeaIce_var
   print("Seaice")
   delete(SeaIce_avg)
   delete(SeaIce_var)

  ;; winds at 10m
   u = node_files->wspd_10m
   wspd_10m_avg = dim_avg_n_Wrap(u,0)
   wspd_10m_var = dim_variance_n_Wrap(u,0)
   delete(u)
   net_avg ->wspd_10m_avg = wspd_10m_avg
   net_avg ->wspd_10m_var = wspd_10m_var
   print("10m wind speed")
   delete(wspd_10m_avg)
   delete(wspd_10m_var) 
   
  ;; Temperature gradient - sfc and 2m 
   T_grad = node_files->T_grad
   T_grad_avg = dim_avg_n_Wrap(T_grad,0)
   T_grad_var = dim_variance_n_Wrap(T_grad,0)
   delete(T_grad)    
   net_avg ->T_grad_avg = T_grad_avg
   net_avg ->T_grad_var = T_grad_var
   print("Temperature gradient")
   delete(T_grad_avg)
   delete(T_grad_var)

  ;; Temperature at surface
   SST = node_files->SST
   SST_avg = dim_avg_n_Wrap(SST,0)
   SST_var = dim_variance_n_Wrap(SST,0)
   delete(SST)
   net_avg ->SST_avg = SST_avg
   net_avg ->SST_var = SST_var
   print("Temperature at surface")
   delete(SST_avg)
   delete(SST_var)

  ;; Temperature at 2m
   T_2m = node_files->T_2m
   T_2m_avg = dim_avg_n_Wrap(T_2m,0)
   T_2m_var = dim_variance_n_Wrap(T_2m,0)
   delete(T_2m)
   net_avg ->T_2m_avg = T_2m_avg
   net_avg ->T_2m_var = T_2m_var
   print("Temperature at 2m")
   delete(T_2m_avg)
   delete(T_2m_var)

  ;; Mixing Ratio gradient - sfc and 2m 
   q_grad = node_files->q_grad
   q_grad_avg = dim_avg_n_Wrap(q_grad,0)
   q_grad_var = dim_variance_n_Wrap(q_grad,0) 
   delete(q_grad)   
   net_avg ->q_grad_avg = q_grad_avg
   net_avg ->q_grad_var = q_grad_var
   print("Mixing Ratio gradient")
   delete(q_grad_avg)
   delete(q_grad_var)

  ;; Mixing Ratio at surface
   q_sfc = node_files->q_sfc
   q_sfc_avg = dim_avg_n_Wrap(q_sfc,0)
   q_sfc_var = dim_variance_n_Wrap(q_sfc,0)
   delete(q_sfc)
   net_avg ->q_sfc_avg = q_sfc_avg
   net_avg ->q_sfc_var = q_sfc_var
   print("Mixing Ratio at surface")
   delete(q_sfc_avg)
   delete(q_sfc_var)

  ;; Mixing Ratio at 2m
   q_2m = node_files->q_2m
   q_2m_avg = dim_avg_n_Wrap(q_2m,0)
   q_2m_var = dim_variance_n_Wrap(q_2m,0)
   delete(q_2m)
   net_avg ->q_2m_avg = q_2m_avg
   net_avg ->q_2m_var = q_2m_var
   print("Mixing Ratio at 2m")
   delete(q_2m_avg)
   delete(q_2m_var)

  ;; Wind stress
   tau = node_files->tau
   tau_avg = dim_avg_n_Wrap(tau,0)
   tau_var = dim_variance_n_Wrap(tau,0)  
   delete(tau)  
   net_avg ->tau_avg = tau_avg
   net_avg ->tau_var = tau_var
   print("Wind stress")
   delete(tau_avg)
   delete(tau_var)

  ;; Wind stress curl
   curl_tau = node_files->curl_tau
   curl_tau_avg = dim_avg_n_Wrap(curl_tau,0)
   curl_tau_var = dim_variance_n_Wrap(curl_tau,0)  
   delete(curl_tau)  
   net_avg ->curl_tau_avg = curl_tau_avg
   net_avg ->curl_tau_var = curl_tau_var
   print("Wind stress curl")
   delete(curl_tau_avg)
   delete(curl_tau_var)

  ;; Sensible Heat Flux
   SHFlx = node_files->SHFlx
   SHFlx_avg = dim_avg_n_Wrap(SHFlx,0)
   SHFlx_var = dim_variance_n_Wrap(SHFlx,0)
   delete(SHFlx)   
   net_avg ->SHFlx_avg = SHFlx_avg
   net_avg ->SHFlx_var = SHFlx_var
   print("Sensible Heat Flux")
   delete(SHFlx_avg)
   delete(SHFlx_var) 

  ;; Latent Heat Flux
   LHFlx = node_files->LHFlx
   LHFlx_avg = dim_avg_n_Wrap(LHFlx,0)
   LHFlx_var = dim_variance_n_Wrap(LHFlx,0) 
   delete(LHFlx)   
   net_avg ->LHFlx_avg = LHFlx_avg
   net_avg ->LHFlx_var = LHFlx_var
   print("Latent Heat Flux")
   delete(LHFlx_avg)
   delete(LHFlx_var) 

  ;; Turbulent Heat Flux
   Turb_net = node_files->Turb_net
   Turb_net_avg = dim_avg_n_Wrap(Turb_net,0)
   Turb_net_var = dim_variance_n_Wrap(Turb_net,0) 
   delete(Turb_net)   
   net_avg ->Turb_net_avg = Turb_net_avg
   net_avg ->Turb_net_var = Turb_net_var
   print("Turbulent Heat Flux")
   delete(Turb_net_avg)
   delete(Turb_net_var)

   delete(node_files)

; add u/v vector info
  node_files = addfile("/data3/duvivier/SOM/training/averages/all/"+fname1+"-all.nc","r")

  ;; u vector speed
   u = node_files->u_10m_tr
   u_10m_tr_avg = dim_avg_n_Wrap(u,0)
   u_10m_tr_var = dim_variance_n_Wrap(u,0)
   delete(u)
   net_avg ->u_10m_tr_avg = u_10m_tr_avg
   net_avg ->u_10m_tr_var = u_10m_tr_var
   print("u vector")
   delete(u_10m_tr_avg)
   delete(u_10m_tr_var)

  ;; v vector speed
   v = node_files->v_10m_tr
   v_10m_tr_avg = dim_avg_n_Wrap(v,0)
   v_10m_tr_var = dim_variance_n_Wrap(v,0)
   delete(v)
   net_avg ->v_10m_tr_avg = v_10m_tr_avg
   net_avg ->v_10m_tr_var = v_10m_tr_var
   print("v vector")
   delete(v_10m_tr_avg)
   delete(v_10m_tr_var)

  ;; delete variables to use again
  delete(fout_avg)
  delete(net_avg)
  delete(dim_files)
  delete(node_files)

;;;;;;;;;;;;;;;;;;;;;; END script
end
