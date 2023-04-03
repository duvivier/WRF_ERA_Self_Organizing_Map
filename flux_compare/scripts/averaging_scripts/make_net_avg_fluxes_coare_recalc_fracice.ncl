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
  datatitle1 = "wrf10_200511_200703_6h"
  datatitle2 = "wrf50_200511_200703_6h"
  nx_input = "7"
  ny_input = "5"
  master_vals = "winds0.01_rlen1000000_r4"
; ******************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; BEGIN SCRIPT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Running net average/variance calculations")

dir1 = "/data3/duvivier/SOM/analysis/flux_compare/node_avgs/"

; get tag to let us know if it needs interpolation
title1_ch  = stringtocharacter(datatitle1)
title1_sub = title1_ch(0:4)
tag_1 = chartostring(title1_sub)
title2_ch  = stringtocharacter(datatitle2)
title2_sub = title2_ch(0:4)
tag_2 = chartostring(title2_sub)

  innames = systemfunc("ls /data3/duvivier/SOM/analysis/flux_compare/node_avgs/fluxes_recalc-fracice/node*_"+tag_1+"_"+tag_2+"_*recalc-fracice.nc")

;;;;;;;;;;
; Load information for each file type
;;;;;;;;;;
; Dates from data array index and visual file that places each date at a given node
print("Loading data")
  nx_node = stringtoint(nx_input)
  ny_node = stringtoint(ny_input)
  nnode = nx_node*ny_node

;;;;;;;;;;
; set input file information
;;;;;;;;;;
; wrf data
if (datatitle1 .eq. "wrf10_200511_200703_6h")then
  datatitle_1 = "wrf10_200511_200703"
  datefile_1 = "/data3/duvivier/SOM/training/dates/"+datatitle_1+"_dates.txt"
  visfile_1  = "/data3/duvivier/SOM/training/som_"+nx_input+ny_input+"/master/"+datatitle_1+"_"+master_vals+".vis"
end if
if (datatitle1 .eq. "wrf50_200511_200703_6h")then
  datatitle_1 = "wrf50_199701_200712"
  datefile_1 = "/data3/duvivier/SOM/training/dates/"+datatitle_1+"_dates.txt"
  visfile_1  = "/data3/duvivier/SOM/training/som_"+nx_input+ny_input+"/master/"+datatitle_1+"_"+master_vals+".vis"
end if
if (datatitle1 .eq. "era_i_200511_200703_6h") then
  datatitle_1 = "era_i_199701_200712"
  datefile_1 = "/data3/duvivier/SOM/training/dates/"+datatitle_1+"_dates.txt"
  visfile_1  = "/data3/duvivier/SOM/training/som_"+nx_input+ny_input+"/master/"+datatitle_1+"_"+master_vals+".vis"
end if

if (datatitle2 .eq. "wrf50_200511_200703_6h")then
  datatitle_2 = "wrf50_199701_200712"
  datefile_2 = "/data3/duvivier/SOM/training/dates/"+datatitle_2+"_dates.txt"
  visfile_2  = "/data3/duvivier/SOM/training/som_"+nx_input+ny_input+"/master/"+datatitle_2+"_"+master_vals+".vis"
end if
if (datatitle2 .eq. "era_i_200511_200703_6h") then
  datatitle_2 = "era_i_199701_200712"
  datefile_2 = "/data3/duvivier/SOM/training/dates/"+datatitle_2+"_dates.txt"
  visfile_2  = "/data3/duvivier/SOM/training/som_"+nx_input+ny_input+"/master/"+datatitle_2+"_"+master_vals+".vis"
end if
;;;;;;;;;;
; Do frequency calculations
;;;;;;;;;;
; file1 - either wrf10 or wrf50
  dates_1 = ndtooned(readAsciiTable(datefile_1,1,"string",0)) ; ignores no rows
  ndates_1 = dimsizes(dates_1)
  dateschar_1 = stringtochar(dates_1)
  sdateym_1 = chartostring(dateschar_1(:,0:5))
  sdatehrs_1 = chartostring(dateschar_1(:,8:9))
  vis_1 = new((/ndates_1,3/),integer)
  vis_1 = readAsciiTable(visfile_1,3,"integer",1) ; ignores first row

; file2 - either wrf50 or erai
  dates_2 = ndtooned(readAsciiTable(datefile_2,1,"string",0)) ; ignores no rows
  ndates_2 = dimsizes(dates_2)
  dateschar_2 = stringtochar(dates_2)
  sdateym_2 = chartostring(dateschar_2(:,0:5))
  sdatehrs_2 = chartostring(dateschar_2(:,8:9))
  vis_2 = new((/ndates_2,3/),integer)
  vis_2 = readAsciiTable(visfile_2,3,"integer",1) ; ignores first row

;;;;;;;;;;
; Get just dates we want
;;;;;;;;;;
  hrs_6 = (/"00","06","12","18"/)
  ym_sub = (/"200511","200512","200601","200602","200603","200611","200612","200701","200702","200703"/)

;;;;;;;;;;
; Loop through plotting options
;;;;;;;;;;
if (tag_1 .eq. "wrf10")then     ; wrf 10km - just narrow down hours
  dateind_1 = ind(sdatehrs_1.eq.hrs_6(0).or.sdatehrs_1.eq.hrs_6(1).or.sdatehrs_1.eq.hrs_6(2).or.sdatehrs_1.eq.hrs_6(3))
  visall_1 = vis_1(dateind_1,:) ; get only every 6 hours
  ndates_1 = dimsizes(visall_1(:,0))
end if
if (tag_1 .eq. "wrf50")then     ; wrf 50km - narrow down years/months/hours
  dateind_1 = ind(sdateym_1.eq.ym_sub(0).or.sdateym_1.eq.ym_sub(1).or.sdateym_1.eq.ym_sub(2).or.sdateym_1.eq.ym_sub(3).or.sdateym_1.eq.ym_sub(4).or.sdateym_1.eq.ym_sub(5).or.sdateym_1.eq.ym_sub(6).or.sdateym_1.eq.ym_sub(7).or.sdateym_1.eq.ym_sub(8).or.sdateym_1.eq.ym_sub(9))
  visall_1_tmp = vis_1(dateind_1,:)
  sdatehrs_tmp = sdatehrs_1(dateind_1)
  delete(dateind_1)
  dateind_1 = ind(sdatehrs_tmp.eq.hrs_6(0).or.sdatehrs_tmp.eq.hrs_6(1).or.sdatehrs_tmp.eq.hrs_6(2).or.sdatehrs_tmp.eq.hrs_6(3))
  visall_1 = visall_1_tmp(dateind_1,:)
  ndates_1 = dimsizes(visall_1(:,0))
  delete(sdatehrs_tmp)
  delete(visall_1_tmp)
end if
if (tag_1 .eq. "era_i")then    ; era interim - just need to narrow down years/months
  dateind_1 = ind(sdateym_1.eq.ym_sub(0).or.sdateym_1.eq.ym_sub(1).or.sdateym_1.eq.ym_sub(2).or.sdateym_1.eq.ym_sub(3).or.sdateym_1.eq.ym_sub(4).or.sdateym_1.eq.ym_sub(5).or.sdateym_1.eq.ym_sub(6).or.sdateym_1.eq.ym_sub(7).or.sdateym_1.eq.ym_sub(8).or.sdateym_1.eq.ym_sub(9))
  visall_1 = vis_1(dateind_1,:)
  ndates_1 = dimsizes(visall_1(:,0))
end if
if (tag_2 .eq. "wrf50")then     ; wrf 50km - narrow down years/months/hours
  dateind_2 = ind(sdateym_2.eq.ym_sub(0).or.sdateym_2.eq.ym_sub(1).or.sdateym_2.eq.ym_sub(2).or.sdateym_2.eq.ym_sub(3).or.sdateym_2.eq.ym_sub(4).or.sdateym_2.eq.ym_sub(5).or.sdateym_2.eq.ym_sub(6).or.sdateym_2.eq.ym_sub(7).or.sdateym_2.eq.ym_sub(8).or.sdateym_2.eq.ym_sub(9))
  visall_2_tmp = vis_2(dateind_2,:)
  sdatehrs_tmp = sdatehrs_2(dateind_2)
  delete(dateind_2)
  dateind_2 = ind(sdatehrs_tmp.eq.hrs_6(0).or.sdatehrs_tmp.eq.hrs_6(1).or.sdatehrs_tmp.eq.hrs_6(2).or.sdatehrs_tmp.eq.hrs_6(3))
  visall_2 = visall_2_tmp(dateind_2,:)
  ndates_2 = dimsizes(visall_2(:,0))
  delete(sdatehrs_tmp)
  delete(visall_2_tmp)
end if
if (tag_2 .eq. "era_i")then    ; era interim - just need to narrow down years/months
  dateind_2 = ind(sdateym_2.eq.ym_sub(0).or.sdateym_2.eq.ym_sub(1).or.sdateym_2.eq.ym_sub(2).or.sdateym_2.eq.ym_sub(3).or.sdateym_2.eq.ym_sub(4).or.sdateym_2.eq.ym_sub(5).or.sdateym_2.eq.ym_sub(6).or.sdateym_2.eq.ym_sub(7).or.sdateym_2.eq.ym_sub(8).or.sdateym_2.eq.ym_sub(9))
  visall_2 = vis_2(dateind_2,:)
  ndates_2 = dimsizes(visall_2(:,0))
end if

;;;;;;;;;;
; Calculate frequencies for each data type
;;;;;;;;;;
; variable 1
  nodefreq_1   = new((/nx_node,ny_node/),"float") 
  freq_nodes_1     = new((/nnode/),"float") 
  nodecount_1    = new((/nnode/),"integer") 

; variable 2
  nodefreq_2   = new((/nx_node,ny_node/),"float") 
  freq_nodes_2     = new((/nnode/),"float") 
  nodecount_2    = new((/nnode/),"integer") 

; set default check values
  check1 = 0
  check2 = 0
  n = 0
; loop through each node
do y = 0, ny_node - 1
 do x = 0, nx_node - 1

  print("node: "+x+","+y)
  ; These are the dates for this particular node:
  dateindices_1 = ind(visall_1(:,0).eq.x.and.(visall_1(:,1).eq.y))
  dateindices_2 = ind(visall_2(:,0).eq.x.and.(visall_2(:,1).eq.y))
       
  ; Calculate frequencies
  if (all(ismissing(dateindices_1))) then
    node_ndates_1 = 0
    nodefreq_1(n) = 0
    nodecount_1(n) = 0
  end if
  if (.not.all(ismissing(dateindices_1))) then
    node_ndates_1 = dimsizes(dateindices_1)
    nodefreq_1(x,y) = (int2flt(node_ndates_1)/int2flt(ndates_1))*100.
    freq_nodes_1(n) = (int2flt(node_ndates_1)/int2flt(ndates_1))*100.
    nodecount_1(n) = node_ndates_1
  end if
  check1 = check1 + node_ndates_1  ; make sure all dates are counted

  ; Calculate frequencies
  if (all(ismissing(dateindices_2))) then
    node_ndates_2 = 0
    nodefreq_2(n) = 0
    nodecount_2(n) = 0
  end if
  if (.not.all(ismissing(dateindices_2))) then
    node_ndates_2 = dimsizes(dateindices_2)
    nodefreq_2(x,y) = (int2flt(node_ndates_2)/int2flt(ndates_2))*100.
    freq_nodes_2(n) = (int2flt(node_ndates_2)/int2flt(ndates_2))*100.
    nodecount_2(n) = node_ndates_2
  end if
  check2 = check2 + node_ndates_2  ; make sure all dates are counted

   n = n + 1
   delete(dateindices_1)
   delete(dateindices_2)
 end do
end do

; Check the dates and print error messages if calculation fails
if (check1.ne.ndates_1) then
 print("Error.  Number of dates is not equal to total number of indices.")
 print("Num. dates: "+ndates_1+"   Tot indices: "+check1)
end if

;;;;;;;;;;
; Load actual variable information for file
;;;;;;;;;;
; Create new file that corresponds to this node for averages/variances
  outdir = "/data3/duvivier/SOM/analysis/flux_compare/node_avgs/fluxes_recalc-fracice/"
  fout_avg = "net_avg_"+tag_1+"_"+tag_2+"_200511_200703_6h-fluxes-recalc-fracice"
net_avg = addfile("./"+fout_avg+".nc","c")  
;net_avg = addfile(outdir+fout_avg+".nc","c")

  ;get domain info
  wrf = addfile(innames(0),"r")

  Z_sfc = wrf->Z_sfc
  lat   = wrf->lat
  lon   = wrf->lon
  grav  = wrf->grav
  delete(wrf)

  ; get dimensions
  dims = dimsizes(Z_sfc)

  ; write domain info to new average file
  net_avg ->Z_sfc = Z_sfc
  net_avg ->lat = lat
  net_avg ->lon = lon
  net_avg ->grav = grav
  delete(Z_sfc)
  delete(lat)
  delete(lon)

  ; make new arrays for incoming data
  seaice_1_files = new((/nnode,dims(0),dims(1)/),"float")
  P_sfc_1_files = new((/nnode,dims(0),dims(1)/),"float")
  winds_1_files = new((/nnode,dims(0),dims(1)/),"float")
  T_sfc_1_files = new((/nnode,dims(0),dims(1)/),"float")
  T_2m_1_files = new((/nnode,dims(0),dims(1)/),"float")
  T_grad_1_files = new((/nnode,dims(0),dims(1)/),"float")
  q_sfc_1_files = new((/nnode,dims(0),dims(1)/),"float")
  q_2m_1_files = new((/nnode,dims(0),dims(1)/),"float")
  q_grad_1_files = new((/nnode,dims(0),dims(1)/),"float")
  tau_orig_1_files = new((/nnode,dims(0),dims(1)/),"float")
  lhflx_orig_1_files = new((/nnode,dims(0),dims(1)/),"float")
  shflx_orig_1_files = new((/nnode,dims(0),dims(1)/),"float") 
  lhflx_fracice_orig_1_files = new((/nnode,dims(0),dims(1)/),"float")
  shflx_fracice_orig_1_files = new((/nnode,dims(0),dims(1)/),"float")

  seaice_2_files = new((/nnode,dims(0),dims(1)/),"float")
  P_sfc_2_files = new((/nnode,dims(0),dims(1)/),"float")
  winds_2_files = new((/nnode,dims(0),dims(1)/),"float")
  T_sfc_2_files = new((/nnode,dims(0),dims(1)/),"float")
  T_2m_2_files = new((/nnode,dims(0),dims(1)/),"float")
  T_grad_2_files = new((/nnode,dims(0),dims(1)/),"float")
  q_sfc_2_files = new((/nnode,dims(0),dims(1)/),"float")
  q_2m_2_files = new((/nnode,dims(0),dims(1)/),"float")
  q_grad_2_files = new((/nnode,dims(0),dims(1)/),"float")
  tau_orig_2_files = new((/nnode,dims(0),dims(1)/),"float")
  lhflx_orig_2_files = new((/nnode,dims(0),dims(1)/),"float")
  shflx_orig_2_files = new((/nnode,dims(0),dims(1)/),"float")
  lhflx_fracice_orig_2_files = new((/nnode,dims(0),dims(1)/),"float")
  shflx_fracice_orig_2_files = new((/nnode,dims(0),dims(1)/),"float")

  tau_wind_recalc_files = new((/nnode,dims(0),dims(1)/),"float")
  lhflx_wind_recalc_files = new((/nnode,dims(0),dims(1)/),"float") 
  shflx_wind_recalc_files = new((/nnode,dims(0),dims(1)/),"float")
  lhflx_wind_fracice_recalc_files = new((/nnode,dims(0),dims(1)/),"float") 
  shflx_wind_fracice_recalc_files = new((/nnode,dims(0),dims(1)/),"float")
  tau_thermo_vars_recalc_files = new((/nnode,dims(0),dims(1)/),"float")
  lhflx_thermo_vars_recalc_files = new((/nnode,dims(0),dims(1)/),"float")
  shflx_thermo_vars_recalc_files = new((/nnode,dims(0),dims(1)/),"float")
  lhflx_thermo_vars_fracice_recalc_files = new((/nnode,dims(0),dims(1)/),"float")
  shflx_thermo_vars_fracice_recalc_files = new((/nnode,dims(0),dims(1)/),"float")
;;;;;;;;;;
; Load variables
;;;;;;;;;;

n = 0
; loop through each node
do y = 0, ny_node - 1
 do x = 0, nx_node - 1
  print("node: "+x+","+y)
  fname1 = "node_"+x+"x_"+y+"y_"+tag_1+"_"+tag_2+"_200511_200703_6h"
  f1 = addfile(dir1 + "fluxes_recalc-fracice/"+ fname1 + "-fluxes-recalc-fracice.nc","r")

  seaice_1_files(n,:,:) = f1->seaice_1
  P_sfc_1_files(n,:,:) = f1->P_sfc_1
  winds_1_files(n,:,:) = f1->winds_1
  T_sfc_1_files(n,:,:) = f1->T_sfc_1
  T_2m_1_files(n,:,:) = f1->T_2m_1
  T_grad_1_files(n,:,:) = f1->T_grad_1
  q_sfc_1_files(n,:,:) = f1->q_sfc_1
  q_2m_1_files(n,:,:) = f1->q_2m_1
  q_grad_1_files(n,:,:) = f1->q_grad_1
  tau_orig_1_files(n,:,:) = f1->tau_orig_1
  lhflx_orig_1_files(n,:,:) = f1->lhflx_orig_1
  shflx_orig_1_files(n,:,:) = f1->shflx_orig_1
  lhflx_fracice_orig_1_files(n,:,:) = f1->lhflx_fracice_orig_1
  shflx_fracice_orig_1_files(n,:,:) = f1->shflx_fracice_orig_1

  seaice_2_files(n,:,:) = f1->seaice_2
  P_sfc_2_files(n,:,:) = f1->P_sfc_2
  winds_2_files(n,:,:) = f1->winds_2
  T_sfc_2_files(n,:,:) = f1->T_sfc_2
  T_2m_2_files(n,:,:) = f1->T_2m_2
  T_grad_2_files(n,:,:) = f1->T_grad_2
  q_sfc_2_files(n,:,:) = f1->q_sfc_2
  q_2m_2_files(n,:,:) = f1->q_2m_2
  q_grad_2_files(n,:,:) = f1->q_grad_2
  tau_orig_2_files(n,:,:) = f1->tau_orig_2
  lhflx_orig_2_files(n,:,:) = f1->lhflx_orig_2
  shflx_orig_2_files(n,:,:) = f1->shflx_orig_2
  lhflx_fracice_orig_2_files(n,:,:) = f1->lhflx_fracice_orig_2
  shflx_fracice_orig_2_files(n,:,:) = f1->shflx_fracice_orig_2

  tau_wind_recalc_files(n,:,:) = f1->tau_wind_recalc
  lhflx_wind_recalc_files(n,:,:) = f1->lhflx_wind_recalc
  shflx_wind_recalc_files(n,:,:) = f1->shflx_wind_recalc
  lhflx_wind_fracice_recalc_files(n,:,:) = f1->lhflx_wind_fracice_recalc
  shflx_wind_fracice_recalc_files(n,:,:) = f1->shflx_wind_fracice_recalc
  tau_thermo_vars_recalc_files(n,:,:) = f1->tau_thermo_vars_recalc
  lhflx_thermo_vars_recalc_files(n,:,:) = f1->lhflx_thermo_vars_recalc
  shflx_thermo_vars_recalc_files(n,:,:) = f1->shflx_thermo_vars_recalc
  lhflx_thermo_vars_fracice_recalc_files(n,:,:) = f1->lhflx_thermo_vars_fracice_recalc
  shflx_thermo_vars_fracice_recalc_files(n,:,:) = f1->shflx_thermo_vars_fracice_recalc
  ; delete vars to use in next loop
  delete(fname1)
  delete(f1)
  n = n+1
 end do
end do

;;;;;;;;;
; Calculate averages
;;;;;;;;;;
; Assumes frequencies of the "base" dataset
  ; Make arrays for each term for incoming data
  seaice_1_nodes = new((/nnode,dims(0),dims(1)/),"float")
  seaice_1_avg = new((/dims(0),dims(1)/),"float")
  seaice_1_avg = 0.0
  seaice_2_nodes = new((/nnode,dims(0),dims(1)/),"float")
  seaice_2_avg = new((/dims(0),dims(1)/),"float")
  seaice_2_avg = 0.0
  P_sfc_1_nodes = new((/nnode,dims(0),dims(1)/),"float")
  P_sfc_1_avg = new((/dims(0),dims(1)/),"float")
  P_sfc_1_avg = 0.0
  P_sfc_2_nodes = new((/nnode,dims(0),dims(1)/),"float")
  P_sfc_2_avg = new((/dims(0),dims(1)/),"float")
  P_sfc_2_avg = 0.0
  winds_1_nodes = new((/nnode,dims(0),dims(1)/),"float")
  winds_1_avg = new((/dims(0),dims(1)/),"float")
  winds_1_avg = 0.0
  winds_2_nodes = new((/nnode,dims(0),dims(1)/),"float")
  winds_2_avg = new((/dims(0),dims(1)/),"float")
  winds_2_avg = 0.0
  T_sfc_1_nodes = new((/nnode,dims(0),dims(1)/),"float")
  T_sfc_1_avg = new((/dims(0),dims(1)/),"float")
  T_sfc_1_avg = 0.0
  T_sfc_2_nodes = new((/nnode,dims(0),dims(1)/),"float")
  T_sfc_2_avg = new((/dims(0),dims(1)/),"float")
  T_sfc_2_avg = 0.0
  T_2m_1_nodes = new((/nnode,dims(0),dims(1)/),"float")
  T_2m_1_avg = new((/dims(0),dims(1)/),"float")
  T_2m_1_avg = 0.0
  T_2m_2_nodes = new((/nnode,dims(0),dims(1)/),"float")
  T_2m_2_avg = new((/dims(0),dims(1)/),"float")
  T_2m_2_avg = 0.0
  T_grad_1_nodes = new((/nnode,dims(0),dims(1)/),"float")
  T_grad_1_avg = new((/dims(0),dims(1)/),"float")
  T_grad_1_avg = 0.0
  T_grad_2_nodes = new((/nnode,dims(0),dims(1)/),"float")
  T_grad_2_avg = new((/dims(0),dims(1)/),"float")
  T_grad_2_avg = 0.0
  q_sfc_1_nodes = new((/nnode,dims(0),dims(1)/),"float")
  q_sfc_1_avg = new((/dims(0),dims(1)/),"float")
  q_sfc_1_avg = 0.0
  q_sfc_2_nodes = new((/nnode,dims(0),dims(1)/),"float")
  q_sfc_2_avg = new((/dims(0),dims(1)/),"float")
  q_sfc_2_avg = 0.0
  q_2m_1_nodes = new((/nnode,dims(0),dims(1)/),"float")
  q_2m_1_avg = new((/dims(0),dims(1)/),"float")
  q_2m_1_avg = 0.0
  q_2m_2_nodes = new((/nnode,dims(0),dims(1)/),"float")
  q_2m_2_avg = new((/dims(0),dims(1)/),"float")
  q_2m_2_avg = 0.0
  q_grad_1_nodes = new((/nnode,dims(0),dims(1)/),"float")
  q_grad_1_avg = new((/dims(0),dims(1)/),"float")
  q_grad_1_avg = 0.0
  q_grad_2_nodes = new((/nnode,dims(0),dims(1)/),"float")
  q_grad_2_avg = new((/dims(0),dims(1)/),"float")
  q_grad_2_avg = 0.0
  tau_orig_1_nodes = new((/nnode,dims(0),dims(1)/),"float")
  tau_orig_1_avg = new((/dims(0),dims(1)/),"float")
  tau_orig_1_avg = 0.0
  tau_orig_2_nodes = new((/nnode,dims(0),dims(1)/),"float")
  tau_orig_2_avg = new((/dims(0),dims(1)/),"float")
  tau_orig_2_avg = 0.0
  lhflx_orig_1_nodes = new((/nnode,dims(0),dims(1)/),"float")
  lhflx_orig_1_avg = new((/dims(0),dims(1)/),"float")
  lhflx_orig_1_avg = 0.0
  lhflx_orig_2_nodes = new((/nnode,dims(0),dims(1)/),"float")
  lhflx_orig_2_avg = new((/dims(0),dims(1)/),"float")
  lhflx_orig_2_avg = 0.0
  shflx_orig_1_nodes = new((/nnode,dims(0),dims(1)/),"float")
  shflx_orig_1_avg = new((/dims(0),dims(1)/),"float")
  shflx_orig_1_avg = 0.0
  shflx_orig_2_nodes = new((/nnode,dims(0),dims(1)/),"float")
  shflx_orig_2_avg = new((/dims(0),dims(1)/),"float")
  shflx_orig_2_avg = 0.0
  lhflx_fracice_orig_1_nodes = new((/nnode,dims(0),dims(1)/),"float")
  lhflx_fracice_orig_1_avg = new((/dims(0),dims(1)/),"float")
  lhflx_fracice_orig_1_avg = 0.0
  lhflx_fracice_orig_2_nodes = new((/nnode,dims(0),dims(1)/),"float")
  lhflx_fracice_orig_2_avg = new((/dims(0),dims(1)/),"float")
  lhflx_fracice_orig_2_avg = 0.0
  shflx_fracice_orig_1_nodes = new((/nnode,dims(0),dims(1)/),"float")
  shflx_fracice_orig_1_avg = new((/dims(0),dims(1)/),"float")
  shflx_fracice_orig_1_avg = 0.0
  shflx_fracice_orig_2_nodes = new((/nnode,dims(0),dims(1)/),"float")
  shflx_fracice_orig_2_avg = new((/dims(0),dims(1)/),"float")
  shflx_fracice_orig_2_avg = 0.0
  tau_wind_recalc_nodes = new((/nnode,dims(0),dims(1)/),"float")
  tau_wind_recalc_avg = new((/dims(0),dims(1)/),"float")
  tau_wind_recalc_avg = 0.0
  tau_thermo_vars_recalc_nodes = new((/nnode,dims(0),dims(1)/),"float")
  tau_thermo_vars_recalc_avg = new((/dims(0),dims(1)/),"float")
  tau_thermo_vars_recalc_avg = 0.0
  lhflx_wind_recalc_nodes = new((/nnode,dims(0),dims(1)/),"float")
  lhflx_wind_recalc_avg = new((/dims(0),dims(1)/),"float")
  lhflx_wind_recalc_avg = 0.0
  lhflx_thermo_vars_recalc_nodes = new((/nnode,dims(0),dims(1)/),"float")
  lhflx_thermo_vars_recalc_avg = new((/dims(0),dims(1)/),"float")
  lhflx_thermo_vars_recalc_avg = 0.0
  shflx_wind_recalc_nodes = new((/nnode,dims(0),dims(1)/),"float")
  shflx_wind_recalc_avg = new((/dims(0),dims(1)/),"float")
  shflx_wind_recalc_avg = 0.0
  shflx_thermo_vars_recalc_nodes = new((/nnode,dims(0),dims(1)/),"float")
  shflx_thermo_vars_recalc_avg = new((/dims(0),dims(1)/),"float")
  shflx_thermo_vars_recalc_avg = 0.0
  lhflx_wind_fracice_recalc_nodes = new((/nnode,dims(0),dims(1)/),"float")
  lhflx_wind_fracice_recalc_avg = new((/dims(0),dims(1)/),"float")
  lhflx_wind_fracice_recalc_avg = 0.0
  lhflx_thermo_vars_fracice_recalc_nodes = new((/nnode,dims(0),dims(1)/),"float")
  lhflx_thermo_vars_fracice_recalc_avg = new((/dims(0),dims(1)/),"float")
  lhflx_thermo_vars_fracice_recalc_avg = 0.0
  shflx_wind_fracice_recalc_nodes = new((/nnode,dims(0),dims(1)/),"float")
  shflx_wind_fracice_recalc_avg = new((/dims(0),dims(1)/),"float")
  shflx_wind_fracice_recalc_avg = 0.0
  shflx_thermo_vars_fracice_recalc_nodes = new((/nnode,dims(0),dims(1)/),"float")
  shflx_thermo_vars_fracice_recalc_avg = new((/dims(0),dims(1)/),"float")
  shflx_thermo_vars_fracice_recalc_avg = 0.0
  do n = 0, nnode - 1
    ; Find winter net average
    seaice_1_nodes(n,:,:) = (freq_nodes_1(n)/100.) * seaice_1_files(n,:,:)    
    seaice_1_avg = seaice_1_avg(:,:) + seaice_1_nodes(n,:,:)
    seaice_2_nodes(n,:,:) = (freq_nodes_2(n)/100.) * seaice_2_files(n,:,:)    
    seaice_2_avg = seaice_2_avg(:,:) + seaice_2_nodes(n,:,:)
    P_sfc_1_nodes(n,:,:) = (freq_nodes_1(n)/100.) * P_sfc_1_files(n,:,:)    
    P_sfc_1_avg = P_sfc_1_avg(:,:) + P_sfc_1_nodes(n,:,:)
    P_sfc_2_nodes(n,:,:) = (freq_nodes_2(n)/100.) * P_sfc_2_files(n,:,:)    
    P_sfc_2_avg = P_sfc_2_avg(:,:) + P_sfc_2_nodes(n,:,:)
    winds_1_nodes(n,:,:) = (freq_nodes_1(n)/100.) * winds_1_files(n,:,:)    
    winds_1_avg = winds_1_avg(:,:) + winds_1_nodes(n,:,:)
    winds_2_nodes(n,:,:) = (freq_nodes_2(n)/100.) * winds_2_files(n,:,:)    
    winds_2_avg = winds_2_avg(:,:) + winds_2_nodes(n,:,:)
    T_sfc_1_nodes(n,:,:) = (freq_nodes_1(n)/100.) * T_sfc_1_files(n,:,:)    
    T_sfc_1_avg = T_sfc_1_avg(:,:) + T_sfc_1_nodes(n,:,:)
    T_sfc_2_nodes(n,:,:) = (freq_nodes_2(n)/100.) * T_sfc_2_files(n,:,:)    
    T_sfc_2_avg = T_sfc_2_avg(:,:) + T_sfc_2_nodes(n,:,:)
    T_2m_1_nodes(n,:,:) = (freq_nodes_1(n)/100.) * T_2m_1_files(n,:,:)    
    T_2m_1_avg = T_2m_1_avg(:,:) + T_2m_1_nodes(n,:,:)
    T_2m_2_nodes(n,:,:) = (freq_nodes_2(n)/100.) * T_2m_2_files(n,:,:)    
    T_2m_2_avg = T_2m_2_avg(:,:) + T_2m_2_nodes(n,:,:)
    T_grad_1_nodes(n,:,:) = (freq_nodes_1(n)/100.) * T_grad_1_files(n,:,:)    
    T_grad_1_avg = T_grad_1_avg(:,:) + T_grad_1_nodes(n,:,:)
    T_grad_2_nodes(n,:,:) = (freq_nodes_2(n)/100.) * T_grad_2_files(n,:,:)    
    T_grad_2_avg = T_grad_2_avg(:,:) + T_grad_2_nodes(n,:,:)
    q_sfc_1_nodes(n,:,:) = (freq_nodes_1(n)/100.) * q_sfc_1_files(n,:,:)    
    q_sfc_1_avg = q_sfc_1_avg(:,:) + q_sfc_1_nodes(n,:,:)
    q_sfc_2_nodes(n,:,:) = (freq_nodes_2(n)/100.) * q_sfc_2_files(n,:,:)    
    q_sfc_2_avg = q_sfc_2_avg(:,:) + q_sfc_2_nodes(n,:,:)
    q_2m_1_nodes(n,:,:) = (freq_nodes_1(n)/100.) * q_2m_1_files(n,:,:)    
    q_2m_1_avg = q_2m_1_avg(:,:) + q_2m_1_nodes(n,:,:)
    q_2m_2_nodes(n,:,:) = (freq_nodes_2(n)/100.) * q_2m_2_files(n,:,:)    
    q_2m_2_avg = q_2m_2_avg(:,:) + q_2m_2_nodes(n,:,:)
    q_grad_1_nodes(n,:,:) = (freq_nodes_1(n)/100.) * q_grad_1_files(n,:,:)    
    q_grad_1_avg = q_grad_1_avg(:,:) + q_grad_1_nodes(n,:,:)
    q_grad_2_nodes(n,:,:) = (freq_nodes_2(n)/100.) * q_grad_2_files(n,:,:)    
    q_grad_2_avg = q_grad_2_avg(:,:) + q_grad_2_nodes(n,:,:)
    tau_orig_1_nodes(n,:,:) = (freq_nodes_1(n)/100.) * tau_orig_1_files(n,:,:)    
    tau_orig_1_avg = tau_orig_1_avg(:,:) + tau_orig_1_nodes(n,:,:)
    tau_orig_2_nodes(n,:,:) = (freq_nodes_2(n)/100.) * tau_orig_2_files(n,:,:)    
    tau_orig_2_avg = tau_orig_2_avg(:,:) + tau_orig_2_nodes(n,:,:)
    lhflx_orig_1_nodes(n,:,:) = (freq_nodes_1(n)/100.) * lhflx_orig_1_files(n,:,:)    
    lhflx_orig_1_avg = lhflx_orig_1_avg(:,:) + lhflx_orig_1_nodes(n,:,:)
    lhflx_orig_2_nodes(n,:,:) = (freq_nodes_2(n)/100.) * lhflx_orig_2_files(n,:,:)    
    lhflx_orig_2_avg = lhflx_orig_2_avg(:,:) + lhflx_orig_2_nodes(n,:,:)
    shflx_orig_1_nodes(n,:,:) = (freq_nodes_1(n)/100.) * shflx_orig_1_files(n,:,:)    
    shflx_orig_1_avg = shflx_orig_1_avg(:,:) + shflx_orig_1_nodes(n,:,:)
    shflx_orig_2_nodes(n,:,:) = (freq_nodes_2(n)/100.) * shflx_orig_2_files(n,:,:)    
    shflx_orig_2_avg = shflx_orig_2_avg(:,:) + shflx_orig_2_nodes(n,:,:)
    lhflx_fracice_orig_1_nodes(n,:,:) = (freq_nodes_1(n)/100.) * lhflx_fracice_orig_1_files(n,:,:)    
    lhflx_fracice_orig_1_avg = lhflx_fracice_orig_1_avg(:,:) + lhflx_fracice_orig_1_nodes(n,:,:)
    lhflx_fracice_orig_2_nodes(n,:,:) = (freq_nodes_2(n)/100.) * lhflx_fracice_orig_2_files(n,:,:)    
    lhflx_fracice_orig_2_avg = lhflx_fracice_orig_2_avg(:,:) + lhflx_fracice_orig_2_nodes(n,:,:)
    shflx_fracice_orig_1_nodes(n,:,:) = (freq_nodes_1(n)/100.) * shflx_fracice_orig_1_files(n,:,:)    
    shflx_fracice_orig_1_avg = shflx_fracice_orig_1_avg(:,:) + shflx_fracice_orig_1_nodes(n,:,:)
    shflx_fracice_orig_2_nodes(n,:,:) = (freq_nodes_2(n)/100.) * shflx_fracice_orig_2_files(n,:,:)    
    shflx_fracice_orig_2_avg = shflx_fracice_orig_2_avg(:,:) + shflx_fracice_orig_2_nodes(n,:,:)
    tau_wind_recalc_nodes(n,:,:) = (freq_nodes_1(n)/100.) * tau_wind_recalc_files(n,:,:)    
    tau_wind_recalc_avg = tau_wind_recalc_avg(:,:) + tau_wind_recalc_nodes(n,:,:)
    tau_thermo_vars_recalc_nodes(n,:,:) = (freq_nodes_1(n)/100.) * tau_thermo_vars_recalc_files(n,:,:)    
    tau_thermo_vars_recalc_avg = tau_thermo_vars_recalc_avg(:,:) + tau_thermo_vars_recalc_nodes(n,:,:)
    lhflx_wind_recalc_nodes(n,:,:) = (freq_nodes_1(n)/100.) * lhflx_wind_recalc_files(n,:,:)    
    lhflx_wind_recalc_avg = lhflx_wind_recalc_avg(:,:) + lhflx_wind_recalc_nodes(n,:,:)
    lhflx_thermo_vars_recalc_nodes(n,:,:) = (freq_nodes_1(n)/100.) * lhflx_thermo_vars_recalc_files(n,:,:)    
    lhflx_thermo_vars_recalc_avg = lhflx_thermo_vars_recalc_avg(:,:) + lhflx_thermo_vars_recalc_nodes(n,:,:)
    shflx_wind_recalc_nodes(n,:,:) = (freq_nodes_1(n)/100.) * shflx_wind_recalc_files(n,:,:)    
    shflx_wind_recalc_avg = shflx_wind_recalc_avg(:,:) + shflx_wind_recalc_nodes(n,:,:)
    shflx_thermo_vars_recalc_nodes(n,:,:) = (freq_nodes_1(n)/100.) * shflx_thermo_vars_recalc_files(n,:,:)    
    shflx_thermo_vars_recalc_avg = shflx_thermo_vars_recalc_avg(:,:) + shflx_thermo_vars_recalc_nodes(n,:,:)
    lhflx_wind_fracice_recalc_nodes(n,:,:) = (freq_nodes_1(n)/100.) * lhflx_wind_fracice_recalc_files(n,:,:)    
    lhflx_wind_fracice_recalc_avg = lhflx_wind_fracice_recalc_avg(:,:) + lhflx_wind_fracice_recalc_nodes(n,:,:)
    lhflx_thermo_vars_fracice_recalc_nodes(n,:,:) = (freq_nodes_1(n)/100.) * lhflx_thermo_vars_fracice_recalc_files(n,:,:)    
    lhflx_thermo_vars_fracice_recalc_avg = lhflx_thermo_vars_fracice_recalc_avg(:,:) + lhflx_thermo_vars_fracice_recalc_nodes(n,:,:)
    shflx_wind_fracice_recalc_nodes(n,:,:) = (freq_nodes_1(n)/100.) * shflx_wind_fracice_recalc_files(n,:,:)    
    shflx_wind_fracice_recalc_avg = shflx_wind_fracice_recalc_avg(:,:) + shflx_wind_fracice_recalc_nodes(n,:,:)
    shflx_thermo_vars_fracice_recalc_nodes(n,:,:) = (freq_nodes_1(n)/100.) * shflx_thermo_vars_fracice_recalc_files(n,:,:)    
    shflx_thermo_vars_fracice_recalc_avg = shflx_thermo_vars_fracice_recalc_avg(:,:) + shflx_thermo_vars_fracice_recalc_nodes(n,:,:)
  end do

;;;;;;;;;
; Write net avg variables
;;;;;;;;;;
  ;; Seaice
   ;seaice_1_avg = dim_avg_n_Wrap(seaice_1_files,0)
   seaice_1_var = dim_variance_n_Wrap(seaice_1_files,0)
   net_avg ->seaice_1_avg = seaice_1_avg
   net_avg ->seaice_1_var = seaice_1_var
   ;seaice_2_avg = dim_avg_n_Wrap(seaice_2_files,0)
   seaice_2_var = dim_variance_n_Wrap(seaice_2_files,0)
   net_avg ->seaice_2_avg = seaice_2_avg
   net_avg ->seaice_2_var = seaice_2_var
   print("Seaice")
  ;; Surface pressure
   ;P_sfc_1_avg = dim_avg_n_Wrap(P_sfc_1_files,0)
   P_sfc_1_var = dim_variance_n_Wrap(P_sfc_1_files,0)
   net_avg ->P_sfc_1_avg = P_sfc_1_avg
   net_avg ->P_sfc_1_var = P_sfc_1_var
   ;P_sfc_2_avg = dim_avg_n_Wrap(P_sfc_2_files,0)
   P_sfc_2_var = dim_variance_n_Wrap(P_sfc_2_files,0)
   net_avg ->P_sfc_2_avg = P_sfc_2_avg
   net_avg ->P_sfc_2_var = P_sfc_2_var
   print("Surface Pressure")
  ;; 10m winds
   ;winds_1_avg = dim_avg_n_Wrap(winds_1_files,0)
   winds_1_var = dim_variance_n_Wrap(winds_1_files,0)
   net_avg ->winds_1_avg = winds_1_avg
   net_avg ->winds_1_var = winds_1_var
   ;winds_2_avg = dim_avg_n_Wrap(winds_2_files,0)
   winds_2_var = dim_variance_n_Wrap(winds_2_files,0)
   net_avg ->winds_2_avg = winds_2_avg
   net_avg ->winds_2_var = winds_2_var
   print("10m winds")
  ;; T surface
   ;T_sfc_1_avg = dim_avg_n_Wrap(T_sfc_1_files,0)
   T_sfc_1_var = dim_variance_n_Wrap(T_sfc_1_files,0)
   net_avg ->T_sfc_1_avg = T_sfc_1_avg
   net_avg ->T_sfc_1_var = T_sfc_1_var
   ;T_sfc_2_avg = dim_avg_n_Wrap(T_sfc_2_files,0)
   T_sfc_2_var = dim_variance_n_Wrap(T_sfc_2_files,0)
   net_avg ->T_sfc_2_avg = T_sfc_2_avg
   net_avg ->T_sfc_2_var = T_sfc_2_var
   print("Surface Temperature")
  ;; T 2m
   ;T_2m_1_avg = dim_avg_n_Wrap(T_2m_1_files,0)
   T_2m_1_var = dim_variance_n_Wrap(T_2m_1_files,0)
   net_avg ->T_2m_1_avg = T_2m_1_avg
   net_avg ->T_2m_1_var = T_2m_1_var
   ;T_2m_2_avg = dim_avg_n_Wrap(T_2m_2_files,0)
   T_2m_2_var = dim_variance_n_Wrap(T_2m_2_files,0)
   net_avg ->T_2m_2_avg = T_2m_2_avg
   net_avg ->T_2m_2_var = T_2m_2_var
   print("2m Temperature")
  ;; T grad
   ;T_grad_1_avg = dim_avg_n_Wrap(T_grad_1_files,0)
   T_grad_1_var = dim_variance_n_Wrap(T_grad_1_files,0)
   net_avg ->T_grad_1_avg = T_grad_1_avg
   net_avg ->T_grad_1_var = T_grad_1_var
   ;T_grad_2_avg = dim_avg_n_Wrap(T_grad_2_files,0)
   T_grad_2_var = dim_variance_n_Wrap(T_grad_2_files,0)
   net_avg ->T_grad_2_avg = T_grad_2_avg
   net_avg ->T_grad_2_var = T_grad_2_var
   print("Temperature Gradient")
  ;; q surface
   ;q_sfc_1_avg = dim_avg_n_Wrap(q_sfc_1_files,0)
   q_sfc_1_var = dim_variance_n_Wrap(q_sfc_1_files,0)
   net_avg ->q_sfc_1_avg = q_sfc_1_avg
   net_avg ->q_sfc_1_var = q_sfc_1_var
   ;q_sfc_2_avg = dim_avg_n_Wrap(q_sfc_2_files,0)
   q_sfc_2_var = dim_variance_n_Wrap(q_sfc_2_files,0)
   net_avg ->q_sfc_2_avg = q_sfc_2_avg
   net_avg ->q_sfc_2_var = q_sfc_2_var
   print("Surface Mixing Ratio")
  ;; q 2m
   ;q_2m_1_avg = dim_avg_n_Wrap(q_2m_1_files,0)
   q_2m_1_var = dim_variance_n_Wrap(q_2m_1_files,0)
   net_avg ->q_2m_1_avg = q_2m_1_avg
   net_avg ->q_2m_1_var = q_2m_1_var
   ;q_2m_2_avg = dim_avg_n_Wrap(q_2m_2_files,0)
   q_2m_2_var = dim_variance_n_Wrap(q_2m_2_files,0)
   net_avg ->q_2m_2_avg = q_2m_2_avg
   net_avg ->q_2m_2_var = q_2m_2_var
   print("2m Mixing Ratio")
  ;; q grad
   ;q_grad_1_avg = dim_avg_n_Wrap(q_grad_1_files,0)
   q_grad_1_var = dim_variance_n_Wrap(q_grad_1_files,0)
   net_avg ->q_grad_1_avg = q_grad_1_avg
   net_avg ->q_grad_1_var = q_grad_1_var
   ;q_grad_2_avg = dim_avg_n_Wrap(q_grad_2_files,0)
   q_grad_2_var = dim_variance_n_Wrap(q_grad_2_files,0)
   net_avg ->q_grad_2_avg = q_grad_2_avg
   net_avg ->q_grad_2_var = q_grad_2_var
   print("Mixing Ratio Gradient")
  ;; Surface stress
   ;tau_orig_1_avg = dim_avg_n_Wrap(tau_orig_1_files,0)
   tau_orig_1_var = dim_variance_n_Wrap(tau_orig_1_files,0)
   net_avg ->tau_orig_1_avg = tau_orig_1_avg
   net_avg ->tau_orig_1_var = tau_orig_1_var
   ;tau_orig_2_avg = dim_avg_n_Wrap(tau_orig_2_files,0)
   tau_orig_2_var = dim_variance_n_Wrap(tau_orig_2_files,0)
   net_avg ->tau_orig_2_avg = tau_orig_2_avg
   net_avg ->tau_orig_2_var = tau_orig_2_var
   print("Surface Stress - original")
  ;; Latent heat flux
   ;lhflx_orig_1_avg = dim_avg_n_Wrap(lhflx_orig_1_files,0)
   lhflx_orig_1_var = dim_variance_n_Wrap(lhflx_orig_1_files,0)
   net_avg ->lhflx_orig_1_avg = lhflx_orig_1_avg
   net_avg ->lhflx_orig_1_var = lhflx_orig_1_var
   ;lhflx_orig_2_avg = dim_avg_n_Wrap(lhflx_orig_2_files,0)
   lhflx_orig_2_var = dim_variance_n_Wrap(lhflx_orig_2_files,0)
   net_avg ->lhflx_orig_2_avg = lhflx_orig_2_avg
   net_avg ->lhflx_orig_2_var = lhflx_orig_2_var
   print("Latent Heat Flux - original")
  ;; Sensible heat flux
   ;shflx_orig_1_avg = dim_avg_n_Wrap(shflx_orig_1_files,0)
   shflx_orig_1_var = dim_variance_n_Wrap(shflx_orig_1_files,0)
   net_avg ->shflx_orig_1_avg = shflx_orig_1_avg
   net_avg ->shflx_orig_1_var = shflx_orig_1_var
   ;shflx_orig_2_avg = dim_avg_n_Wrap(shflx_orig_2_files,0)
   shflx_orig_2_var = dim_variance_n_Wrap(shflx_orig_2_files,0)
   net_avg ->shflx_orig_2_avg = shflx_orig_2_avg
   net_avg ->shflx_orig_2_var = shflx_orig_2_var
   print("Sensible Heat Flux - original")
  ;; Latent heat flux - with seaice fraction
   ;lhflx_orig_1_avg = dim_avg_n_Wrap(lhflx_orig_1_files,0)
   lhflx_fracice_orig_1_var = dim_variance_n_Wrap(lhflx_fracice_orig_1_files,0)
   net_avg ->lhflx_fracice_orig_1_avg = lhflx_fracice_orig_1_avg
   net_avg ->lhflx_fracice_orig_1_var = lhflx_fracice_orig_1_var
   ;lhflx_orig_2_avg = dim_avg_n_Wrap(lhflx_orig_2_files,0)
   lhflx_fracice_orig_2_var = dim_variance_n_Wrap(lhflx_fracice_orig_2_files,0)
   net_avg ->lhflx_fracice_orig_2_avg = lhflx_fracice_orig_2_avg
   net_avg ->lhflx_fracice_orig_2_var = lhflx_fracice_orig_2_var
   print("Latent Heat Flux - original with seaice fraction")
  ;; Sensible heat flux - with seaice fraction
   ;shflx_orig_1_avg = dim_avg_n_Wrap(shflx_orig_1_files,0)
   shflx_fracice_orig_1_var = dim_variance_n_Wrap(shflx_fracice_orig_1_files,0)
   net_avg ->shflx_fracice_orig_1_avg = shflx_fracice_orig_1_avg
   net_avg ->shflx_fracice_orig_1_var = shflx_fracice_orig_1_var
   ;shflx_orig_2_avg = dim_avg_n_Wrap(shflx_orig_2_files,0)
   shflx_fracice_orig_2_var = dim_variance_n_Wrap(shflx_fracice_orig_2_files,0)
   net_avg ->shflx_fracice_orig_2_avg = shflx_fracice_orig_2_avg
   net_avg ->shflx_fracice_orig_2_var = shflx_fracice_orig_2_var
   print("Sensible Heat Flux - original with seaice fraction")
  ;; Surface stress
   ;tau_wind_recalc_avg = dim_avg_n_Wrap(tau_wind_recalc_files,0)
   tau_wind_recalc_var = dim_variance_n_Wrap(tau_wind_recalc_files,0)
   net_avg ->tau_wind_recalc_avg = tau_wind_recalc_avg
   net_avg ->tau_wind_recalc_var = tau_wind_recalc_var
   ;tau_thermo_vars_recalc_avg = dim_avg_n_Wrap(tau_thermo_vars_recalc_files,0)
   tau_thermo_vars_recalc_var = dim_variance_n_Wrap(tau_thermo_vars_recalc_files,0)
   net_avg ->tau_thermo_vars_recalc_avg = tau_thermo_vars_recalc_avg
   net_avg ->tau_thermo_vars_recalc_var = tau_thermo_vars_recalc_var
   print("Surface Stress - recalculated")
  ;; Latent Heat Flux
   ;lhflx_wind_recalc_avg = dim_avg_n_Wrap(lhflx_wind_recalc_files,0)
   lhflx_wind_recalc_var = dim_variance_n_Wrap(lhflx_wind_recalc_files,0)
   net_avg ->lhflx_wind_recalc_avg = lhflx_wind_recalc_avg
   net_avg ->lhflx_wind_recalc_var = lhflx_wind_recalc_var
   ;lhflx_thermo_vars_recalc_avg = dim_avg_n_Wrap(lhflx_thermo_vars_recalc_files,0)
   lhflx_thermo_vars_recalc_var = dim_variance_n_Wrap(lhflx_thermo_vars_recalc_files,0)
   net_avg ->lhflx_thermo_vars_recalc_avg = lhflx_thermo_vars_recalc_avg
   net_avg ->lhflx_thermo_vars_recalc_var = lhflx_thermo_vars_recalc_var
   print("Latent Heat Flux - recalculated")
  ;; Sensible Heat Flux
   ;shflx_wind_recalc_avg = dim_avg_n_Wrap(shflx_wind_recalc_files,0)
   shflx_wind_recalc_var = dim_variance_n_Wrap(shflx_wind_recalc_files,0)
   net_avg ->shflx_wind_recalc_avg = shflx_wind_recalc_avg
   net_avg ->shflx_wind_recalc_var = shflx_wind_recalc_var
   ;shflx_thermo_vars_recalc_avg = dim_avg_n_Wrap(shflx_thermo_vars_recalc_files,0)
   shflx_thermo_vars_recalc_var = dim_variance_n_Wrap(shflx_thermo_vars_recalc_files,0)
   net_avg ->shflx_thermo_vars_recalc_avg = shflx_thermo_vars_recalc_avg
   net_avg ->shflx_thermo_vars_recalc_var = shflx_thermo_vars_recalc_var
   print("Sensible Heat Flux - recalculated ")
  ;; Latent Heat Flux - with seaice fraction
   ;lhflx_wind_recalc_avg = dim_avg_n_Wrap(lhflx_wind_recalc_files,0)
   lhflx_wind_fracice_recalc_var = dim_variance_n_Wrap(lhflx_wind_fracice_recalc_files,0)
   net_avg ->lhflx_wind_fracice_recalc_avg = lhflx_wind_fracice_recalc_avg
   net_avg ->lhflx_wind_fracice_recalc_var = lhflx_wind_fracice_recalc_var
   ;lhflx_thermo_vars_recalc_avg = dim_avg_n_Wrap(lhflx_thermo_vars_recalc_files,0)
   lhflx_thermo_vars_fracice_recalc_var = dim_variance_n_Wrap(lhflx_thermo_vars_fracice_recalc_files,0)
   net_avg ->lhflx_thermo_vars_fracice_recalc_avg = lhflx_thermo_vars_fracice_recalc_avg
   net_avg ->lhflx_thermo_vars_fracice_recalc_var = lhflx_thermo_vars_fracice_recalc_var
   print("Latent Heat Flux - recalculated with seaice fraction")
  ;; Sensible Heat Flux - with seaice fraction
   ;shflx_wind_recalc_avg = dim_avg_n_Wrap(shflx_wind_recalc_files,0)
   shflx_wind_fracice_recalc_var = dim_variance_n_Wrap(shflx_wind_fracice_recalc_files,0)
   net_avg ->shflx_wind_fracice_recalc_avg = shflx_wind_fracice_recalc_avg
   net_avg ->shflx_wind_fracice_recalc_var = shflx_wind_fracice_recalc_var
   ;shflx_thermo_vars_recalc_avg = dim_avg_n_Wrap(shflx_thermo_vars_recalc_files,0)
   shflx_thermo_vars_fracice_recalc_var = dim_variance_n_Wrap(shflx_thermo_vars_fracice_recalc_files,0)
   net_avg ->shflx_thermo_vars_fracice_recalc_avg = shflx_thermo_vars_fracice_recalc_avg
   net_avg ->shflx_thermo_vars_fracice_recalc_var = shflx_thermo_vars_fracice_recalc_var
   print("Sensible Heat Flux - recalculated with seaice fraction")

print("Finished averaging variables")


;;;;;;;;;;;;;;;;;;;;;; END script
end
