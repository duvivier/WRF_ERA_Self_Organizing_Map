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
if (p .eq. 6 ) then  ; if it's era_i for the short period need the flux files (don't have other flux files yet)
  files_1 = "/data3/duvivier/SOM/DATA/"+tag_0+"/"+yearmonth+"/"+tag_1+"-"+yy+"-"+mm+"-"+dd+"_"+hh+"."+tag_2+".all.cf.nc"
else
  files_1 = "/data3/duvivier/SOM/DATA/"+tag_0+"/"+yearmonth+"/"+tag_1+"-"+yy+"-"+mm+"-"+dd+"_"+hh+"."+tag_2+".cf.nc"
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
  fout = "wrf10_200511_200703_6h-uvwind"
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
  fout = "wrf50_200511_200703_6h-uvwind"
end if
if (p .eq. 6)
  print("2005-2007 era_i 6hrly")
  dateind_1 = ind(yearmonth.eq.ym_sub(0) .or. yearmonth.eq.ym_sub(1) .or. yearmonth.eq.ym_sub(2) .or. yearmonth.eq.ym_sub(3) .or. yearmonth.eq.ym_sub(4) .or. yearmonth.eq.ym_sub(5) .or. yearmonth.eq.ym_sub(6) .or. yearmonth.eq.ym_sub(7) .or. yearmonth.eq.ym_sub(8) .or. yearmonth.eq.ym_sub(9))
  visall_1 = vis_1(dateind_1,:)
  filesall_1 = files_1(dateind_1)
  fout = "era_i_200511_200703_6h-uvwind"
end if

ndates_1 = dimsizes(filesall_1)

;;;;;;;;;;
; Calculate averages data
;;;;;;;;;;
fill = new((/1/),"float")
n = 0
;;;;;;;;;
; calculate Group averages for flux variables
;;;;;;;;;;
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
   dims = dimsizes(Z_sfc)
   dim_sn = dims(0)
   dim_we = dims(1)

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
   delete(Z_sfc)

  ; write the number of files going into the average for later statistical tests
   node_avg ->number_dates = dim_files
;;;;;;;;;
; Load files and get averages
;;;;;;;;;
  ; loop through each file to load data because otherwise it doesn't load properly

  ; Go through each type of surface variable and calculate average and variance
  ;; U wind
   u_10m_tr = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     wrf = addfile(files_sub(f),"r")
     u_10m_tr(f,:,:) = wrf->u_10m_tr
     delete(wrf)
   end do
   u_10m_tr_avg = dim_avg_n_Wrap(u_10m_tr,0)
   u_10m_tr_var = dim_variance_n_Wrap(u_10m_tr,0)
   node_avg ->u_10m_tr_avg = u_10m_tr_avg
   node_avg ->u_10m_tr_var = u_10m_tr_var
   print("u_10m_tr")
   delete(u_10m_tr) 
   delete(u_10m_tr_avg)
   delete(u_10m_tr_var)
   delete(f)

  ;; V wind
   v_10m_tr = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     wrf = addfile(files_sub(f),"r")
     v_10m_tr(f,:,:) = wrf->v_10m_tr
     delete(wrf)
   end do
   v_10m_tr_avg = dim_avg_n_Wrap(v_10m_tr,0)
   v_10m_tr_var = dim_variance_n_Wrap(v_10m_tr,0)
   node_avg ->v_10m_tr_avg = v_10m_tr_avg
   node_avg ->v_10m_tr_var = v_10m_tr_var
   print("v_10m_tr")
   delete(v_10m_tr) 
   delete(v_10m_tr_avg)
   delete(v_10m_tr_var)
   delete(f)
  n = n + 1

  ;; delete variables to use again
  delete(fout_node)
  delete(node_avg)
  delete(dim_files)
  delete(node_files)
  delete(dateindices_1)
  delete(files_sub)

end do
;;;;;;;;;;;;;;;;;;;;;; END script
end
