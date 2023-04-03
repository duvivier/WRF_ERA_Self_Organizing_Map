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
;  p = 1  ; wrf10 2005-2007 6hrly
;  p = 2  ; wrf50 2005-2007 6hrly
;  p = 3  ; erai 2005-2007 6hrly
;  p = 4  ; wrf50 1997-2007 6hrly
  p = 5  ; erai 1997-2007 6hrly
; ******************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; BEGIN SCRIPT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Running node average/variance calculations")
setfileoption("nc","SuppressClose",False)  ; don't close files automatically
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
if (p .eq. 2 .or. p .eq. 4) then
  datatitle_1 = "wrf50_199701_200712"
  tag_0 = "wrf50"
  tag_1 = "wrf"
  tag_2 = "green50"
end if
if (p .eq. 3 .or. p .eq. 5) then
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
  fout = "wrf10_200511_200703_6h-fluxes"
end if
if (p .eq. 2)
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
  fout = "wrf50_200511_200703_6h-fluxes"
end if
if (p .eq. 3)
  print("2005-2007 era_i 6hrly")
  dateind_1 = ind(yearmonth.eq.ym_sub(0) .or. yearmonth.eq.ym_sub(1) .or. yearmonth.eq.ym_sub(2) .or. yearmonth.eq.ym_sub(3) .or. yearmonth.eq.ym_sub(4) .or. yearmonth.eq.ym_sub(5) .or. yearmonth.eq.ym_sub(6) .or. yearmonth.eq.ym_sub(7) .or. yearmonth.eq.ym_sub(8) .or. yearmonth.eq.ym_sub(9))
  visall_1 = vis_1(dateind_1,:)
  filesall_1 = files_1(dateind_1)
  fout = "era_i_200511_200703_6h-fluxes"
end if
if (p .eq. 4)
  print("1997-2007 wrf50 6hrly")
  dateind_1 = ind(hh.eq.hr_sub(0) .or. hh.eq.hr_sub(1) .or. hh.eq.hr_sub(2) .or. hh.eq.hr_sub(3))
  visall_1 = vis_1(dateind_1,:)
  filesall_1 = files_1(dateind_1)
  fout = "wrf50_199701_200712_6h-fluxes"
end if
if (p .eq. 5)
  print("1997-2007 era_i 6hrly")
  visall_1 = vis_1
  filesall_1 = files_1
  fout = "era_i_199701_200712_6h-fluxes"
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
   fout_node = "group_"+g1+"_"+fout+"-sst"
   node_avg = addfile("./"+fout_node+".nc","c")
   print("Calculating percentiles for group "+g1)

  ; files that do not need to be averaged
   wrf = addfile(files_sub(0),"r")
   Z_sfc = wrf->Z_sfc
   lat = wrf->lat
   lon = wrf->lon
   grav = wrf->grav
   if (tag_0 .eq. "wrf10")then
     mask_50km_terrain = wrf->mask_50km_terrain
   end if
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
   node_avg ->grav = grav
   print("Gravity")
   if (tag_0 .eq. "wrf10")then
     node_avg ->mask_50km_terrain = mask_50km_terrain
     delete(mask_50km_terrain)
   end if
   delete(wrf)
   delete(lat)
   delete(lon)
   delete(grav)
   delete(Z_sfc)

  ; write the number of files going into the average for later statistical tests
   node_avg ->number_dates = dim_files
;;;;;;;;;
; Load files and get averages
;;;;;;;;;
  ; loop through each file to load data because otherwise it doesn't load properly

  ; Go through each type of surface variable and calculate average and variance
  ;; Sea Ice Concentration
   SeaIce = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     wrf = addfile(files_sub(f),"r")
     SeaIce(f,:,:) = wrf->SeaIce
     delete(wrf)
   end do
   SeaIce_avg = dim_avg_n_Wrap(SeaIce,0)
   SeaIce_var = dim_variance_n_Wrap(SeaIce,0)
   node_avg ->SeaIce_avg = SeaIce_avg
   node_avg ->SeaIce_var = SeaIce_var
   print("Seaice")
   delete(SeaIce) 
   delete(SeaIce_avg)
   delete(SeaIce_var)

  ;; Pressure at surface
   P_sfc = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     wrf = addfile(files_sub(f),"r")
     P_sfc(f,:,:) = wrf->P_sfc
     delete(wrf)
   end do
   P_sfc_avg = dim_avg_n_Wrap(P_sfc,0)
   P_sfc_var = dim_variance_n_Wrap(P_sfc,0)
   node_avg ->P_sfc_avg = P_sfc_avg
   node_avg ->P_sfc_var = P_sfc_var
   print("Pressure at surface")
   delete(P_sfc)
   delete(P_sfc_avg)
   delete(P_sfc_var)

  ;; winds at 10m
   u = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     wrf = addfile(files_sub(f),"r")
     u(f,:,:) = wrf->wspd_10m
     delete(wrf)
   end do
   u@long_name = "10m wind speed"
   wspd_10m_avg = dim_avg_n_Wrap(u,0)
   wspd_10m_var = dim_variance_n_Wrap(u,0)
   delete(u)
   node_avg ->wspd_10m_avg = wspd_10m_avg
   node_avg ->wspd_10m_var = wspd_10m_var
   print("10m wind speed")
   delete(wspd_10m_avg)
   delete(wspd_10m_var)

  ;; Temperature gradient - sfc and 2m 
   T_grad = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     wrf = addfile(files_sub(f),"r")
     T_grad(f,:,:) = wrf->T_grad
     delete(wrf)
   end do
   T_grad_avg = dim_avg_n_Wrap(T_grad,0)
   T_grad_var = dim_variance_n_Wrap(T_grad,0)   
   node_avg ->T_grad_avg = T_grad_avg
   node_avg ->T_grad_var = T_grad_var
   print("Temperature gradient")
   delete(T_grad) 
   delete(T_grad_avg)
   delete(T_grad_var)

  ;; Temperature at surface
   SST = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     wrf = addfile(files_sub(f),"r")
     SST(f,:,:) = wrf->SST
     delete(wrf)
   end do
   SST_avg = dim_avg_n_Wrap(SST,0)
   SST_var = dim_variance_n_Wrap(SST,0)
   node_avg ->SST_avg = SST_avg
   node_avg ->SST_var = SST_var
   print("Temperature at surface")
   delete(SST)
   delete(SST_avg)
   delete(SST_var)

  ;; Temperature at 2m
   T_2m = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     wrf = addfile(files_sub(f),"r")
     T_2m(f,:,:) = wrf->T_2m
     delete(wrf)
   end do
   T_2m_avg = dim_avg_n_Wrap(T_2m,0)
   T_2m_var = dim_variance_n_Wrap(T_2m,0)
   node_avg ->T_2m_avg = T_2m_avg
   node_avg ->T_2m_var = T_2m_var
   print("Temperature at 2m")
   delete(T_2m)
   delete(T_2m_avg)
   delete(T_2m_var)

  ;; Mixing Ratio gradient - sfc and 2m 
   q_grad = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     wrf = addfile(files_sub(f),"r")
     q_grad(f,:,:) = wrf->q_grad
     delete(wrf)
   end do
   q_grad_avg = dim_avg_n_Wrap(q_grad,0)
   q_grad_var = dim_variance_n_Wrap(q_grad,0)   
   node_avg ->q_grad_avg = q_grad_avg
   node_avg ->q_grad_var = q_grad_var
   print("Mixing Ratio gradient")
   delete(q_grad) 
   delete(q_grad_avg)
   delete(q_grad_var)

  ;; Mixing Ratio at surface
   q_sfc = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     wrf = addfile(files_sub(f),"r")
     q_sfc(f,:,:) = wrf->q_sfc
     delete(wrf)
   end do
   q_sfc_avg = dim_avg_n_Wrap(q_sfc,0)
   q_sfc_var = dim_variance_n_Wrap(q_sfc,0)
   node_avg ->q_sfc_avg = q_sfc_avg
   node_avg ->q_sfc_var = q_sfc_var
   print("Mixing Ratio at surface")
   delete(q_sfc)
   delete(q_sfc_avg)
   delete(q_sfc_var)

  ;; Mixing Ratio at 2m
   q_2m = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     wrf = addfile(files_sub(f),"r")
     q_2m(f,:,:) = wrf->q_2m
     delete(wrf)
   end do
   q_2m_avg = dim_avg_n_Wrap(q_2m,0)
   q_2m_var = dim_variance_n_Wrap(q_2m,0)
   node_avg ->q_2m_avg = q_2m_avg
   node_avg ->q_2m_var = q_2m_var
   print("Mixing Ratio at 2m")
   delete(q_2m)
   delete(q_2m_avg)
   delete(q_2m_var)

  ;; Wind stress
   tau = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     wrf = addfile(files_sub(f),"r")
     tau(f,:,:) = wrf->tau
     delete(wrf)
   end do
   tau_avg = dim_avg_n_Wrap(tau,0)
   tau_var = dim_variance_n_Wrap(tau,0)   
   node_avg ->tau_avg = tau_avg
   node_avg ->tau_var = tau_var
   print("Wind stress")
   delete(tau) 
   delete(tau_avg)
   delete(tau_var)

  ;; Wind stress curl
   curl_tau = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     wrf = addfile(files_sub(f),"r")
     curl_tau(f,:,:) = wrf->curl_tau
     delete(wrf)
   end do
   curl_tau_avg = dim_avg_n_Wrap(curl_tau,0)
   curl_tau_var = dim_variance_n_Wrap(curl_tau,0)   
   node_avg ->curl_tau_avg = curl_tau_avg
   node_avg ->curl_tau_var = curl_tau_var
   print("Wind stress curl")
   delete(curl_tau) 
   delete(curl_tau_avg)
   delete(curl_tau_var)

  ;; Sensible Heat Flux
   SHFlx = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     wrf = addfile(files_sub(f),"r")
     SHFlx(f,:,:) = wrf->SHFlx
     delete(wrf)
   end do
   SHFlx_avg = dim_avg_n_Wrap(SHFlx,0)
   SHFlx_var = dim_variance_n_Wrap(SHFlx,0)   
   node_avg ->SHFlx_avg = SHFlx_avg
   node_avg ->SHFlx_var = SHFlx_var
   print("Sensible Heat Flux")
   delete(SHFlx) 
   delete(SHFlx_avg)
   delete(SHFlx_var) 

  ;; Latent Heat Flux
   LHFlx = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     wrf = addfile(files_sub(f),"r")
     LHFlx(f,:,:) = wrf->LHFlx
     delete(wrf)
   end do
   LHFlx_avg = dim_avg_n_Wrap(LHFlx,0)
   LHFlx_var = dim_variance_n_Wrap(LHFlx,0)   
   node_avg ->LHFlx_avg = LHFlx_avg
   node_avg ->LHFlx_var = LHFlx_var
   print("Latent Heat Flux")
   delete(LHFlx) 
   delete(LHFlx_avg)
   delete(LHFlx_var) 

  ;; Turbulent Heat Flux
   Turb_net = new((/dim_files,dim_sn,dim_we/),"float")
   f = 0
   do f = 0,dim_files - 1
     wrf = addfile(files_sub(f),"r")
     Turb_net(f,:,:) = wrf->Turb_net
     delete(wrf)
   end do
   Turb_net_avg = dim_avg_n_Wrap(Turb_net,0)
   Turb_net_var = dim_variance_n_Wrap(Turb_net,0)   
   node_avg ->Turb_net_avg = Turb_net_avg
   node_avg ->Turb_net_var = Turb_net_var
   print("Turbulent Heat Flux")
   delete(Turb_net) 
   delete(Turb_net_avg)
   delete(Turb_net_var) 

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
