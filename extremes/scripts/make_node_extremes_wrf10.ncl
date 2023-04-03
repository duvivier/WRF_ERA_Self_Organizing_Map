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
print("Running node average/variance calculations")
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
  files_1 = "/data3/duvivier/SOM/analysis/flux_compare/wrf10_coare_fluxes/coare_fluxes/"+tag_1+"-"+yy+"-"+mm+"-"+dd+"_"+hh+"."+tag_2+"-coare.nc"
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
  fout = "wrf10_200511_200703_6h-extremes"
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
  fout = "wrf50_200511_200703_6h-extremes"
end if
if (p .eq. 6)
  print("2005-2007 era_i 6hrly")
  dateind_1 = ind(yearmonth.eq.ym_sub(0) .or. yearmonth.eq.ym_sub(1) .or. yearmonth.eq.ym_sub(2) .or. yearmonth.eq.ym_sub(3) .or. yearmonth.eq.ym_sub(4) .or. yearmonth.eq.ym_sub(5) .or. yearmonth.eq.ym_sub(6) .or. yearmonth.eq.ym_sub(7) .or. yearmonth.eq.ym_sub(8) .or. yearmonth.eq.ym_sub(9))
  visall_1 = vis_1(dateind_1,:)
  filesall_1 = files_1(dateind_1)
  fout = "era_i_200511_200703_6h-extremes"
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
;;;;;;;;;
; calculate Node averages for flux variables
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

   dims = dimsizes(Z_sfc)
   dims1 = dims(0)
   dims2 = dims(1)

  ; write to new average file
   node_avg ->lat = lat
   print("latitude")
   node_avg ->lon = lon
   print("longitude") 
   node_avg ->Z_sfc = Z_sfc
   print("Terrain height")
   delete(wrf)
   delete(lat)
   delete(lon)
;   delete(Z_sfc)

  ; write the number of files going into the average for later statistical tests
   node_avg ->number_dates = dim_files
;;;;;;;;;
; Load files and get averages
;;;;;;;;;
  ; loop through each file to load data because otherwise it doesn't load properly

  ; Go through each type of surface variable and calculate average and variance
   SeaIce = new((/dim_files,dims1,dims2/),"float")
   f = 0
   do f = 0,dim_files - 1
     wrf = addfile(files_sub(f),"r")
     SeaIce(f,:,:) = wrf->SeaIce
     delete(wrf)
   end do
   SeaIce_avg = dim_avg_n_Wrap(SeaIce,0)
   node_avg ->SeaIce_avg = SeaIce_avg
   print("Seaice")
   delete(SeaIce) 
   delete(SeaIce_avg)

  ;; winds at 10m
   u = new((/dim_files,dims1,dims2/),"float")
   f = 0
   do f = 0,dim_files - 1
     wrf = addfile(files_sub(f),"r")
     u(f,:,:) = wrf->wspd_10m
     delete(wrf)
   end do

  ;; Wind stress
   tau = new((/dim_files,dims1,dims2/),"float")
   f = 0
   do f = 0,dim_files - 1
     wrf = addfile(files_sub(f),"r")
     tau(f,:,:) = wrf->tau
     delete(wrf)
   end do

  ;; Latent Heat Flux
   LHFlx = new((/dim_files,dims1,dims2/),"float")
   f = 0
   do f = 0,dim_files - 1
     wrf = addfile(files_sub(f),"r")
     LHFlx(f,:,:) = wrf->LHFlx
     delete(wrf)
   end do

  ;; Sensible Heat Flux
   SHFlx = new((/dim_files,dims1,dims2/),"float")
   f = 0
   do f = 0,dim_files - 1
     wrf = addfile(files_sub(f),"r")
     SHFlx(f,:,:) = wrf->SHFlx
     delete(wrf)
   end do


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
   copy_VarMeta(Z_sfc,ws_10m_max)
   ws_10m_max@long_name = "Maximum wind speed"
   ws_10m_max@standard_name = "max_speed"
   ws_10m_max@units = "m s-1"
   node_avg ->ws_10m_max = ws_10m_max
   copy_VarMeta(ws_10m_max,ws_10m_99)
   ws_10m_99@long_name = "99th percentile wind speed"
   ws_10m_99@standard_name = "99th_speed"
   node_avg ->ws_10m_99 = ws_10m_99
   delete(ws_10m_99)
   copy_VarMeta(ws_10m_max,ws_10m_95)
   ws_10m_95@long_name = "95th percentile wind speed"
   ws_10m_95@standard_name = "95th_speed"
   node_avg ->ws_10m_95 = ws_10m_95
   delete(ws_10m_95)
   copy_VarMeta(ws_10m_max,ws_10m_90)
   ws_10m_90@long_name = "90th percentile wind speed"
   ws_10m_90@standard_name = "90th_speed"
   node_avg ->ws_10m_90 = ws_10m_90
   delete(ws_10m_90)
   copy_VarMeta(ws_10m_max,ws_10m_75)
   ws_10m_75@long_name = "75th percentile wind speed"
   ws_10m_75@standard_name = "75th_speed"
   node_avg ->ws_10m_75 = ws_10m_75
   delete(ws_10m_75)
   copy_VarMeta(ws_10m_max,ws_10m_50)
   ws_10m_50@long_name = "50th percentile wind speed"
   ws_10m_50@standard_name = "50th_speed"
   node_avg ->ws_10m_50 = ws_10m_50
   delete(ws_10m_50)
   delete(ws_10m_max)
   print("10m wind speed values")

   ; Write wind stress information
   copy_VarMeta(Z_sfc,tau_max)
   tau_max@long_name = "Maximum surface stress"
   tau_max@standard_name = "max_stress"
   tau_max@units = "N m-2"
   node_avg ->tau_max = tau_max
   copy_VarMeta(tau_max,tau_99)
   tau_99@long_name = "99th percentile surface stress"
   tau_99@standard_name = "99th_stress"
   node_avg ->tau_99 = tau_99
   delete(tau_99)
   copy_VarMeta(tau_max,tau_95)
   tau_95@long_name = "95th percentile surface stress"
   tau_95@standard_name = "95th_stress"
   node_avg ->tau_95 = tau_95
   delete(tau_95)
   copy_VarMeta(tau_max,tau_90)
   tau_90@long_name = "90th percentile surface stress"
   tau_90@standard_name = "90th_stress"
   node_avg ->tau_90 = tau_90
   delete(tau_90)
   copy_VarMeta(tau_max,tau_75)
   tau_75@long_name = "75th percentile surface stress"
   tau_75@standard_name = "75th_stress"
   node_avg ->tau_75 = tau_75
   delete(tau_75)
   copy_VarMeta(tau_max,tau_50)
   tau_50@long_name = "50th percentile surface stress"
   tau_50@standard_name = "50th_stress"
   node_avg ->tau_50 = tau_50
   delete(tau_50)
   delete(tau_max)
   print("Wind stress")

   ; Write latent heat flux information
   copy_VarMeta(Z_sfc,lhflx_max)
   lhflx_max@long_name = "Maximum latent heat flux"
   lhflx_max@standard_name = "max_lhflx"
   lhflx_max@units = "W m-2"
   node_avg ->lhflx_max = lhflx_max
   copy_VarMeta(lhflx_max,lhflx_99)
   lhflx_99@long_name = "99th percentile latent heat flux"
   lhflx_99@standard_name = "99th_lhflx"
   node_avg ->lhflx_99 = lhflx_99
   delete(lhflx_99)
   copy_VarMeta(lhflx_max,lhflx_95)
   lhflx_95@long_name = "95th percentile latent heat flux"
   lhflx_95@standard_name = "95th_lhflx"
   node_avg ->lhflx_95 = lhflx_95
   delete(lhflx_95)
   copy_VarMeta(lhflx_max,lhflx_90)
   lhflx_90@long_name = "90th percentile latent heat flux"
   lhflx_90@standard_name = "90th_lhflx"
   node_avg ->lhflx_90 = lhflx_90
   delete(lhflx_90)
   copy_VarMeta(lhflx_max,lhflx_75)
   lhflx_75@long_name = "75th percentile latent heat flux"
   lhflx_75@standard_name = "75th_lhflx"
   node_avg ->lhflx_75 = lhflx_75
   delete(lhflx_75)
   copy_VarMeta(lhflx_max,lhflx_50)
   lhflx_50@long_name = "50th percentile latent heat flux"
   lhflx_50@standard_name = "50th_lhflx"
   node_avg ->lhflx_50 = lhflx_50
   delete(lhflx_50)
   delete(lhflx_max)
   print("Latent Heat flux")

   ; Write sensible heat flux information
   copy_VarMeta(Z_sfc,shflx_max)
   shflx_max@long_name = "Maximum sensible heat flux"
   shflx_max@standard_name = "max_shflx"
   shflx_max@units = "W m-2"
   node_avg ->shflx_max = shflx_max
   copy_VarMeta(shflx_max,shflx_99)
   shflx_99@long_name = "99th percentile sensible heat flux"
   shflx_99@standard_name = "99th_shflx"
   node_avg ->shflx_99 = shflx_99
   delete(shflx_99)
   copy_VarMeta(shflx_max,shflx_95)
   shflx_95@long_name = "95th percentile sensible heat flux"
   shflx_95@standard_name = "95th_shflx"
   node_avg ->shflx_95 = shflx_95
   delete(shflx_95)
   copy_VarMeta(shflx_max,shflx_90)
   shflx_90@long_name = "90th percentile sensible heat flux"
   shflx_90@standard_name = "90th_shflx"
   node_avg ->shflx_90 = shflx_90
   delete(shflx_90)
   copy_VarMeta(shflx_max,shflx_75)
   shflx_75@long_name = "75th percentile sensible heat flux"
   shflx_75@standard_name = "75th_shflx"
   node_avg ->shflx_75 = shflx_75
   delete(shflx_75)
   copy_VarMeta(shflx_max,shflx_50)
   shflx_50@long_name = "50th percentile sensible heat flux"
   shflx_50@standard_name = "50th_shflx"
   node_avg ->shflx_50 = shflx_50
   delete(shflx_50)
   delete(shflx_max)
   print("Sensible Heat flux")

  n = n + 1

  ;; delete variables to use again
  delete(fout_node)
  delete(node_avg)
  delete(dim_files)
  delete(node_files)
  delete(dateindices_1)
  delete(files_sub)
  delete(Z_sfc)

 end do
end do

; Check the dates and print error messages if calculation fails
if (check1.ne.ndates_1) then
 print("Error.  Number of dates is not equal to total number of indices.")
 print("Num. dates: "+ndates_1+"   Tot indices: "+check1)
end if

;;;;;;;;;;;;;;;;;;;;;; END script
end
