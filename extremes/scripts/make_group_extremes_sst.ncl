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
if (p .eq. 3) then
  datatitle_1 = "wrf50_199701_200712"
  tag_0 = "wrf50"
  tag_1 = "wrf"
  tag_2 = "green50"
end if
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
files_1 = "/data3/duvivier/SOM/analysis/flux_compare/"+tag_0+"_coare_fluxes/coare_fluxes-sst/"+tag_1+"-"+yy+"-"+mm+"-"+dd+"_"+hh+"."+tag_2+"-coare-sst.nc"
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
  fout = "wrf10_200511_200703_6h-extremes-sst"
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
  fout = "wrf50_200511_200703_6h-extremes-sst"
end if
if (p .eq. 6)
  print("2005-2007 era_i 6hrly")
  dateind_1 = ind(yearmonth.eq.ym_sub(0) .or. yearmonth.eq.ym_sub(1) .or. yearmonth.eq.ym_sub(2) .or. yearmonth.eq.ym_sub(3) .or. yearmonth.eq.ym_sub(4) .or. yearmonth.eq.ym_sub(5) .or. yearmonth.eq.ym_sub(6) .or. yearmonth.eq.ym_sub(7) .or. yearmonth.eq.ym_sub(8) .or. yearmonth.eq.ym_sub(9))
  visall_1 = vis_1(dateind_1,:)
  filesall_1 = files_1(dateind_1)
  fout = "era_i_200511_200703_6h-extremes-sst"
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
n = 0
;;;;;;;;;
; calculate Node percentiles for flux variables
;;;;;;;;;;
; List of percentiles of interest
percentiles = (/50.0, 75.0, 95.0/)
dims_pcnt = dimsizes(percentiles)

; count if all dates are included
ndates = 0

; loop through each group
n_group = 8
do g = 0,n_group - 1

  ; For each group, set the node values to load in
  ; group1: Nodes("0,0" "1,0" "0,1")
  if (g .eq. 0) then
    dateindices_1 = ind((visall_1(:,0).eq.0.and.visall_1(:,1).eq.0).or.(visall_1(:,0).eq.1.and.visall_1(:,1).eq.0).or.(visall_1(:,0).eq.0.and.visall_1(:,1).eq.1))
  end if
  ; group2: Nodes("2,0" "1,1" "2,1" "2,2" "3,2")
  if (g .eq. 1) then
    dateindices_1 = ind((visall_1(:,0).eq.2.and.visall_1(:,1).eq.0).or.(visall_1(:,0).eq.1.and.visall_1(:,1).eq.1).or.(visall_1(:,0).eq.2.and.visall_1(:,1).eq.1).or.(visall_1(:,0).eq.2.and.visall_1(:,1).eq.2).or.(visall_1(:,0).eq.3.and.visall_1(:,1).eq.2))
  end if
  ; group3: Nodes("3,0" "4,0" "3,1" "4,1" "4,2" "5,2")
  if (g .eq. 2) then
    dateindices_1 = ind((visall_1(:,0).eq.3.and.visall_1(:,1).eq.0).or.(visall_1(:,0).eq.4.and.visall_1(:,1).eq.0).or.(visall_1(:,0).eq.3.and.visall_1(:,1).eq.1).or.(visall_1(:,0).eq.4.and.visall_1(:,1).eq.1).or.(visall_1(:,0).eq.4.and.visall_1(:,1).eq.2).or.(visall_1(:,0).eq.5.and.visall_1(:,1).eq.2))
  end if
  ; group4: Nodes("5,0" "6,0" "5,1" "6,1" "6,2")
  if (g .eq. 3) then
    dateindices_1 = ind((visall_1(:,0).eq.5.and.visall_1(:,1).eq.0).or.(visall_1(:,0).eq.6.and.visall_1(:,1).eq.0).or.(visall_1(:,0).eq.5.and.visall_1(:,1).eq.1).or.(visall_1(:,0).eq.6.and.visall_1(:,1).eq.1).or.(visall_1(:,0).eq.6.and.visall_1(:,1).eq.2))
  end if
  ; group5: Nodes("0,2" "0,3" "0,4" "1,4")
  if (g .eq. 4) then
    dateindices_1 = ind((visall_1(:,0).eq.0.and.visall_1(:,1).eq.2).or.(visall_1(:,0).eq.0.and.visall_1(:,1).eq.3).or.(visall_1(:,0).eq.0.and.visall_1(:,1).eq.4).or.(visall_1(:,0).eq.1.and.visall_1(:,1).eq.4))
  end if
  ; group6: Nodes("1,2" "1,3" "2,3" "2,4")
  if (g .eq. 5) then
    dateindices_1 = ind((visall_1(:,0).eq.1.and.visall_1(:,1).eq.2).or.(visall_1(:,0).eq.1.and.visall_1(:,1).eq.3).or.(visall_1(:,0).eq.2.and.visall_1(:,1).eq.3).or.(visall_1(:,0).eq.2.and.visall_1(:,1).eq.4))
  end if
  ; group7: Nodes("3,3" "4,3" "3,4" "4,4")
  if (g .eq. 6) then
    dateindices_1 = ind((visall_1(:,0).eq.3.and.visall_1(:,1).eq.3).or.(visall_1(:,0).eq.4.and.visall_1(:,1).eq.3).or.(visall_1(:,0).eq.3.and.visall_1(:,1).eq.4).or.(visall_1(:,0).eq.4.and.visall_1(:,1).eq.4))
  end if
  ; group8: Nodes("5,3" "6,3" "5,4" "6,4")
  if (g .eq. 7) then
    dateindices_1 = ind((visall_1(:,0).eq.5.and.visall_1(:,1).eq.3).or.(visall_1(:,0).eq.6.and.visall_1(:,1).eq.3).or.(visall_1(:,0).eq.5.and.visall_1(:,1).eq.4).or.(visall_1(:,0).eq.6.and.visall_1(:,1).eq.4))
  end if
  
  ; count the number of dates going into the files
  ndates = ndates+dimsizes(dateindices_1)

  if (.not.all(ismissing(dateindices_1))) then
    files_sub = filesall_1(dateindices_1)
  else
    print("All files missing for group "+g)
  end if

  ; Load files that correspond to this node
   dim_files = dimsizes(files_sub)
   node_files = addfiles(files_sub,"r")

  ; Create new file that corresponds to this group for extremes
   g1 = g+1
   fout_node = "group_"+g1+"_"+fout
   node_avg = addfile("./"+fout_node+".nc","c")
   print("Calculating percentiles for group "+g1)

  ; files that do not need to be averaged
   wrf = addfile(files_sub(0),"r")
   Z_sfc = wrf->Z_sfc
   lat = wrf->lat
   lon = wrf->lon
   if (tag_0 .eq. "wrf10")then
     mask_50km = wrf->mask_50km_terrain
   end if

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
   if (tag_0 .eq. "wrf10")then
     node_avg ->mask_50km_terrain = mask_50km
     delete(mask_50km)
   end if
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
   print("Starting determination of percentiles")
  ;; winds at 10m
   print("Windspeed")
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
   ws_10m_pcnt@pcntiles= "50,75,95"
   node_avg ->ws_10m_pcnt = ws_10m_pcnt
   delete(sn)
   delete(we)
   delete(p)
   delete(u)
   delete(ws_10m_pcnt)
   print("Windspeed percentiles written")

  ;; windstress from 10m winds
   print("Wind stress")
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
   tau_pcnt@pcntiles= "50,75,95"
   node_avg ->tau_pcnt = tau_pcnt
   delete(sn)
   delete(we)
   delete(p)
   delete(tau)
   delete(tau_pcnt)
   print("Wind stress percentiles written")

  ;; LHFlx
   print("LHFlx")
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
   LHFlx_pcnt@pcntiles= "50,75,95"
   node_avg ->LHFlx_pcnt = LHFlx_pcnt
   delete(sn)
   delete(we)
   delete(p)
   delete(LHFlx)
   delete(LHFlx_pcnt)
   print("LHFlx percentiles written")

  ;; SHFlx
   print("SHFlx")
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
   SHFlx_pcnt@pcntiles= "50,75,95"
   node_avg ->SHFlx_pcnt = SHFlx_pcnt
   delete(sn)
   delete(we)
   delete(p)
   delete(SHFlx)
   delete(SHFlx_pcnt)
   print("SHFlx percentiles written")

print("completed percentile calculations")

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

print("total dates in dataset: "+ndates_1)
print("total dates going into groups: "+ndates)

;;;;;;;;;;;;;;;;;;;;;; END script
end
