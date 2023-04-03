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
  tag_1 = "wrf"
  node_files = addfile("/data3/duvivier/SOM/analysis/flux_compare/wrf10_coare_fluxes/coare_fluxes/"+fname1+"-fluxes-all.nc","r")
end if

;;;;;;;;;;
; Load information for each file type
;;;;;;;;;;
; Dates from data array index and visual file that places each date at a given node
print("Loading data")

; Create new file that corresponds to this node for averages/variances
fout_avg = "net_avg_"+fname1+"-extremes"
net_avg = addfile("./"+fout_avg+".nc","c")

;;;;;;;;;;
; Calculate averages data
;;;;;;;;;;

; files that do not need to be averaged
Z_sfc = node_files->Z_sfc
lat = node_files->lat
lon = node_files->lon
grav = node_files->grav

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
delete(lat)
delete(lon)
;delete(Z_sfc_avg)

; write the number of files going into the average for later statistical tests
net_avg ->number_dates = dim_files

; Go through each type of surface variable and calculate average and variance
  ;; Sea Ice Concentration
   SeaIce = node_files->SeaIce
   SeaIce_avg = dim_avg_n_Wrap(SeaIce,0)
   delete(SeaIce) 
   net_avg ->SeaIce_avg = SeaIce_avg
   print("Seaice")
   delete(SeaIce_avg)

  ;; winds at 10m
   u = node_files->wspd_10m

  ;; Wind stress
   tau = node_files->tau

  ;; Latent Heat Flux
   LHFlx = node_files->LHFlx

  ;; Sensible Heat Flux
   SHFlx = node_files->SHFlx


;;;;;;;;;
; Do Array sorting and finding of percentiles
;;;;;;;;;
   print("Starting deterimination of percentiles")
   ; get integer location for each percentile
   loc_max = dim_files - 1
   loc_99  = round(((99./100.)*(dim_files-1)),3) 
   loc_95  = round(((95./100.)*(dim_files-1)),3)
   loc_90  = round(((90./100.)*(dim_files-1)),3)
   loc_75  = round(((75./100.)*(dim_files-1)),3)
   loc_50  = round(((50./100.)*(dim_files-1)),3)

   ; preallocate arrays for data
   ; maximums
   ws_10m_max = new((/dim_sn,dim_we/),"float") 
   tau_max    = new((/dim_sn,dim_we/),"float")
   lhflx_max  = new((/dim_sn,dim_we/),"float")
   shflx_max  = new((/dim_sn,dim_we/),"float")
   ; 99th percentile
   ws_10m_99  = new((/dim_sn,dim_we/),"float") 
   tau_99     = new((/dim_sn,dim_we/),"float")
   lhflx_99   = new((/dim_sn,dim_we/),"float")
   shflx_99   = new((/dim_sn,dim_we/),"float")
   ; 95th percentile
   ws_10m_95  = new((/dim_sn,dim_we/),"float") 
   tau_95     = new((/dim_sn,dim_we/),"float")
   lhflx_95   = new((/dim_sn,dim_we/),"float")
   shflx_95   = new((/dim_sn,dim_we/),"float") 
   ; 90th percentile
   ws_10m_90  = new((/dim_sn,dim_we/),"float") 
   tau_90     = new((/dim_sn,dim_we/),"float") 
   lhflx_90   = new((/dim_sn,dim_we/),"float")
   shflx_90   = new((/dim_sn,dim_we/),"float")
   ; 75th percentile
   ws_10m_75  = new((/dim_sn,dim_we/),"float") 
   tau_75     = new((/dim_sn,dim_we/),"float")
   lhflx_75   = new((/dim_sn,dim_we/),"float")
   shflx_75   = new((/dim_sn,dim_we/),"float") 
   ; 50th percentile
   ws_10m_50  = new((/dim_sn,dim_we/),"float")
   tau_50     = new((/dim_sn,dim_we/),"float") 
   lhflx_50   = new((/dim_sn,dim_we/),"float")
   shflx_50   = new((/dim_sn,dim_we/),"float")

   ; loop through each point and sort the values to get the extreme values
   sn = 0
   we = 0
do we = 0, dim_we - 1
 do sn = 0, dim_sn - 1
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
   dum = LHFlx(:,sn,we)
   qsort(dum)
   lhflx_max(sn,we) = dum(loc_max)
   lhflx_99(sn,we) = dum(loc_99)
   lhflx_95(sn,we) = dum(loc_95)
   lhflx_90(sn,we) = dum(loc_90)
   lhflx_75(sn,we) = dum(loc_75)
   lhflx_50(sn,we) = dum(loc_50)
   delete(dum)

   ; sort the sensible heat flux values
   dum = SHFlx(:,sn,we)
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
delete(LHFlx)
delete(SHFlx)

print("completed percentile calculations")

;;;;;;;;;
; Write extreme values to file
;;;;;;;;;

   ; Write wind information
   copy_VarMeta(Z_sfc_avg,ws_10m_max)
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
   copy_VarMeta(Z_sfc_avg,tau_max)
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
   copy_VarMeta(Z_sfc_avg,lhflx_max)
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
   copy_VarMeta(Z_sfc_avg,shflx_max)
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

  ;; delete variables to use again
  delete(fout_avg)
  delete(net_avg)
  delete(dim_files)
  delete(node_files)

;;;;;;;;;;;;;;;;;;;;;; END script
end
