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
  node_files = addfile("/data3/duvivier/SOM/analysis/flux_compare/wrf10_coare_fluxes/coare_fluxes-sst/"+fname1+"-fluxes-sst-all.nc","r")
end if
; wrf50 data
if (fname1 .eq. "wrf50_200511_200703_6h")then
  tag_0 = "wrf50"
  node_files = addfile("/data3/duvivier/SOM/analysis/flux_compare/wrf50_coare_fluxes/coare_fluxes-sst/"+fname1+"-fluxes-sst-all.nc","r")
end if
; era_i data
if (fname1 .eq. "era_i_200511_200703_6h")then
  tag_0 = "era_i"
  node_files = addfile("/data3/duvivier/SOM/analysis/flux_compare/era_i_coare_fluxes/coare_fluxes-sst/"+fname1+"-fluxes-sst-all.nc","r")
end if
;;;;;;;;;;
; Load information for each file type
;;;;;;;;;;
; Dates from data array index and visual file that places each date at a given node
print("Loading data")

; Create new file that corresponds to this node for averages/variances
fout_avg = "net_"+fname1+"-extremes-sst"
net_avg = addfile("./"+fout_avg+".nc","c")

;;;;;;;;;;
; Load all data
;;;;;;;;;;
; List of percentiles of interest
percentiles = (/10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 75.0, 80.0, 90.0, 92.0, 94.0, 95.0, 96.0, 98.0, 100.0/)
dims_pcnt = dimsizes(percentiles)

; files that do not need to be averaged
Z_sfc = node_files->Z_sfc
lat = node_files->lat
lon = node_files->lon
grav = node_files->grav
if(tag_0 .eq. "wrf10")then
  mask_50km_all = node_files->mask_50km_terrain
  mask_50km = mask_50km_all(0,:,:)
  delete(mask_50km_all)
end if

dims = dimsizes(Z_sfc)
dim_files = dims(0)
dims1 = dims(1)
dims2 = dims(2)

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
if (tag_0 .eq. "wrf10")then
  net_avg ->mask_50km_terrain = mask_50km
  delete(mask_50km)
end if
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

   print("Starting determination of percentiles")
  ;; winds at 10m
   print("Windspeed")
   u = node_files->wspd_10m
   ; preallocate arrays for data
   ws_10m_pcnt = new((/dims_pcnt, dims1,dims2/),"float") 
   ; loop through each point and sort the values to get the extreme values
   sn = 0
   we = 0
   p = 0
   do we = 0, dims2 - 1
     do sn = 0, dims1 - 1
       ; sort the wind values
       dum = u(:,sn,we)
       qsort(dum)
       do p = 0, dims_pcnt -1
         pcnt_loc = round(((percentiles(p)/100.)*(dim_files-1)),3)
         ; write values
         ws_10m_pcnt(p,sn,we) = dum(pcnt_loc)
         delete(pcnt_loc)
       end do
       delete(dum)
     end do
   end do
   ; write wind speed percentiles to a file
   ws_10m_pcnt@pcntiles= "10,20,30,40,50,60,70,75,80,90,92,94,95,96,98,100"
   net_avg ->ws_10m_pcnt = ws_10m_pcnt
   delete(sn)
   delete(we)
   delete(p)
   delete(u)
   delete(ws_10m_pcnt)
   print("Windspeed percentiles written")

  ;; windstress from 10m winds
   print("Wind stress")
   tau = node_files->tau
   ; preallocate arrays for data
   tau_pcnt = new((/dims_pcnt, dims1,dims2/),"float") 
   ; loop through each point and sort the values to get the extreme values
   sn = 0
   we = 0
   p = 0
   do we = 0, dims2 - 1
     do sn = 0, dims1 - 1
       ; sort the wind values
       dum = tau(:,sn,we)
       qsort(dum)
       do p = 0, dims_pcnt -1
         pcnt_loc = round(((percentiles(p)/100.)*(dim_files-1)),3)
         ; write values
         tau_pcnt(p,sn,we) = dum(pcnt_loc)
         delete(pcnt_loc)
       end do
       delete(dum)
     end do
   end do
   ; write wind stress percentiles to file
   tau_pcnt@pcntiles= "10,20,30,40,50,60,70,75,80,90,92,94,95,96,98,100"
   net_avg ->tau_pcnt = tau_pcnt
   delete(sn)
   delete(we)
   delete(p)
   delete(tau)
   delete(tau_pcnt)
   print("Wind stress percentiles written")

  ;; LHFlx
   print("LHFlx")
   LHFlx = node_files->LHFlx
   ; preallocate arrays for data
   LHFlx_pcnt = new((/dims_pcnt, dims1,dims2/),"float") 
   ; loop through each point and sort the values to get the extreme values
   sn = 0
   we = 0
   p = 0
   do we = 0, dims2 - 1
     do sn = 0, dims1 - 1
       ; sort the wind values
       dum = LHFlx(:,sn,we)
       qsort(dum)
       do p = 0, dims_pcnt -1
         pcnt_loc = round(((percentiles(p)/100.)*(dim_files-1)),3)
         ; write values
         LHFlx_pcnt(p,sn,we) = dum(pcnt_loc)
         delete(pcnt_loc)
       end do
       delete(dum)
     end do
   end do
   ; write LHFlx percentiles to file
   LHFlx_pcnt@pcntiles= "10,20,30,40,50,60,70,75,80,90,92,94,95,96,98,100"
   net_avg ->LHFlx_pcnt = LHFlx_pcnt
   delete(sn)
   delete(we)
   delete(p)
   delete(LHFlx)
   delete(LHFlx_pcnt)
   print("LHFlx percentiles written")

  ;; SHFlx
   print("SHFlx")
   SHFlx = node_files->SHFlx
   ; preallocate arrays for data
   SHFlx_pcnt = new((/dims_pcnt, dims1,dims2/),"float") 
   ; loop through each point and sort the values to get the extreme values
   sn = 0
   we = 0
   p = 0
   do we = 0, dims2 - 1
     do sn = 0, dims1 - 1
       ; sort the wind values
       dum = SHFlx(:,sn,we)
       qsort(dum)
       do p = 0, dims_pcnt -1
         pcnt_loc = round(((percentiles(p)/100.)*(dim_files-1)),3)
         ; write values
         SHFlx_pcnt(p,sn,we) = dum(pcnt_loc)
         delete(pcnt_loc)
       end do
       delete(dum)
     end do
   end do
   ; write SHFlx percentiles to file
   SHFlx_pcnt@pcntiles= "10,20,30,40,50,60,70,75,80,90,92,94,95,96,98,100"
   net_avg ->SHFlx_pcnt = SHFlx_pcnt
   delete(sn)
   delete(we)
   delete(p)
   delete(SHFlx)
   delete(SHFlx_pcnt)
   print("SHFlx percentiles written")

print("completed percentile calculations")

  ;; delete variables to use again
  delete(fout_avg)
  delete(net_avg)
  delete(dim_files)
  delete(node_files)

;;;;;;;;;;;;;;;;;;;;;; END script
end
