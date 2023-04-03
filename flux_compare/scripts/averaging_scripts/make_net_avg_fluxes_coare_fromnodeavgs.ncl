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
  nx_input = "7"
  ny_input = "5"
  master_vals = "winds0.01_rlen1000000_r4"
; ******************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; BEGIN SCRIPT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Running net average/variance calculations")

; Calculate node counts and frequencies for comparison of interest
  nx_node = stringtoint(nx_input)
  ny_node = stringtoint(ny_input)
  nnode = nx_node*ny_node

dir1 = "/data3/duvivier/SOM/analysis/flux_compare/node_avgs/"

;;;;;;;;;;
; set input file information
;;;;;;;;;;
; wrf data
if (datatitle1 .eq. "wrf10_200511_200703_6h")then
  tag_0 = "wrf10"
  datatitle_1 = "wrf10_200511_200703"
  datefile_1 = "/data3/duvivier/SOM/training/dates/"+datatitle_1+"_dates.txt"
  visfile_1  = "/data3/duvivier/SOM/training/som_"+nx_input+ny_input+"/master/"+datatitle_1+"_"+master_vals+".vis"
end if
if (datatitle1 .eq. "wrf50_200511_200703_6h")then
  tag_0 = "wrf50"
  datatitle_1 = "wrf50_199701_200712"
  datefile_1 = "/data3/duvivier/SOM/training/dates/"+datatitle_1+"_dates.txt"
  visfile_1  = "/data3/duvivier/SOM/training/som_"+nx_input+ny_input+"/master/"+datatitle_1+"_"+master_vals+".vis"
end if
if (datatitle1 .eq. "era_i_200511_200703_6h") then
  tag_0 = "era_i"
  datatitle_1 = "era_i_199701_200712"
  datefile_1 = "/data3/duvivier/SOM/training/dates/"+datatitle_1+"_dates.txt"
  visfile_1  = "/data3/duvivier/SOM/training/som_"+nx_input+ny_input+"/master/"+datatitle_1+"_"+master_vals+".vis"
end if
;title1_ch  = stringtocharacter(fname1)
;title1_sub = title1_ch(0:4)
;tag_0 = chartostring(title1_sub)

  innames = systemfunc("ls /data3/duvivier/SOM/analysis/flux_compare/node_avgs/fluxes_fromnodeavgs/node*_"+tag_0+"_*fromnodeavgs.nc")

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

;;;;;;;;;;
; Get just dates we want
;;;;;;;;;;
  hrs_6 = (/"00","06","12","18"/)
  ym_sub = (/"200511","200512","200601","200602","200603","200611","200612","200701","200702","200703"/)

;;;;;;;;;;
; Loop through plotting options
;;;;;;;;;;
if (tag_0 .eq. "wrf10")then     ; wrf 10km - just narrow down hours
  dateind_1 = ind(sdatehrs_1.eq.hrs_6(0).or.sdatehrs_1.eq.hrs_6(1).or.sdatehrs_1.eq.hrs_6(2).or.sdatehrs_1.eq.hrs_6(3))
  visall_1 = vis_1(dateind_1,:) ; get only every 6 hours
  ndates_1 = dimsizes(visall_1(:,0))
end if
if (tag_0 .eq. "wrf50")then     ; wrf 50km - narrow down years/months/hours
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
if (tag_0 .eq. "era_i")then    ; era interim - just need to narrow down years/months
  dateind_1 = ind(sdateym_1.eq.ym_sub(0).or.sdateym_1.eq.ym_sub(1).or.sdateym_1.eq.ym_sub(2).or.sdateym_1.eq.ym_sub(3).or.sdateym_1.eq.ym_sub(4).or.sdateym_1.eq.ym_sub(5).or.sdateym_1.eq.ym_sub(6).or.sdateym_1.eq.ym_sub(7).or.sdateym_1.eq.ym_sub(8).or.sdateym_1.eq.ym_sub(9))
  visall_1 = vis_1(dateind_1,:)
  ndates_1 = dimsizes(visall_1(:,0))
end if

;;;;;;;;;;
; Calculate frequencies for each data type
;;;;;;;;;;

; variable 1
  nodefreq_1   = new((/nx_node,ny_node/),"float") 
  freq_nodes_1     = new((/nnode/),"float") 
  nodecount_1    = new((/nnode/),"integer") 

; set default check values
  check1 = 0
  n = 0
; loop through each node
do y = 0, ny_node - 1
 do x = 0, nx_node - 1

  print("node: "+x+","+y)
  ; These are the dates for this particular node:
  dateindices_1 = ind(visall_1(:,0).eq.x.and.(visall_1(:,1).eq.y))
        
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

   n = n + 1
   delete(dateindices_1)
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
; Dates from data array index and visual file that places each date at a given node
print("Loading data")

; Create new file that corresponds to this node for averages/variances
  fout_avg = "net_avg_"+datatitle1+"-fluxes_fromnodeavgs"
  net_avg = addfile("./"+fout_avg+".nc","c")

  ;get domain info
  wrf = addfile(innames(0),"r")

  Z_sfc = wrf->Z_sfc
  lat   = wrf->lat
  lon   = wrf->lon
  delete(wrf)

  ; get dimensions
  dims = dimsizes(Z_sfc)

  ; write domain info to new average file
  net_avg ->Z_sfc = Z_sfc
  net_avg ->lat = lat
  net_avg ->lon = lon
  delete(Z_sfc)
  delete(lat)
  delete(lon)

;;;;;;;;;;
; Load variables
;;;;;;;;;;
 ; make new arrays for incoming data
  tau_files = new((/nnode,dims(0),dims(1)/),"float")
  lhflx_files = new((/nnode,dims(0),dims(1)/),"float")
  shflx_files = new((/nnode,dims(0),dims(1)/),"float") 

n = 0
; loop through each node
do y = 0, ny_node - 1
 do x = 0, nx_node - 1
  print("node: "+x+","+y)
  fname1 = "node_"+x+"x_"+y+"y_"+datatitle1
  f1 = addfile(dir1 + "fluxes_fromnodeavgs/"+ fname1 + "-fluxes_fromnodeavgs.nc","r")
  tau_files(n,:,:) = f1->tau_avg
  lhflx_files(n,:,:) = f1->LHFlx_avg
  shflx_files(n,:,:) = f1->SHFlx_avg

  ; delete vars to use in next loop
  delete(fname1)
  delete(f1)
  n = n+1
 end do
end do

;;;;;;;;;;
; Get averages by using frequencies
;;;;;;;;;;
  ; Make arrays for each term for incoming data
  tau_nodes = new((/nnode,dims(0),dims(1)/),"float")
  tau_avg = new((/dims(0),dims(1)/),"float")
  tau_avg = 0.0
  lhflx_nodes = new((/nnode,dims(0),dims(1)/),"float")
  lhflx_avg = new((/dims(0),dims(1)/),"float")
  lhflx_avg = 0.0
  shflx_nodes = new((/nnode,dims(0),dims(1)/),"float")
  shflx_avg = new((/dims(0),dims(1)/),"float")
  shflx_avg = 0.0

  do n = 0, nnode - 1
    ; Find winter net average
    tau_nodes(n,:,:) = (freq_nodes_1(n)/100.) * tau_files(n,:,:)    
    tau_avg = tau_avg(:,:) + tau_nodes(n,:,:)
    lhflx_nodes(n,:,:) = (freq_nodes_1(n)/100.) * lhflx_files(n,:,:)    
    lhflx_avg = lhflx_avg(:,:) + lhflx_nodes(n,:,:)
    shflx_nodes(n,:,:) = (freq_nodes_1(n)/100.) * shflx_files(n,:,:)    
    shflx_avg = shflx_avg(:,:) + shflx_nodes(n,:,:)
  end do

;;;;;;;;;
; Write net avg variables
;;;;;;;;;;
  ;; Wind stress
   ;tau_avg = dim_avg_n_Wrap(tau_freq,0)
   tau_var = dim_variance_n_Wrap(tau_files,0)
   net_avg ->tau_avg = tau_avg
   net_avg ->tau_var = tau_var
   print("Windstress")
  ;; Latent heat flux
   ;lhflx_avg = dim_avg_n_Wrap(lhflx_files,0)
   lhflx_var = dim_variance_n_Wrap(lhflx_files,0)
   net_avg ->LHFlx_avg = lhflx_avg
   net_avg ->LHFlx_var = lhflx_var
   print("Latent Heat Flux")
  ;; Sensible heat flux
   ;shflx_avg = dim_avg_n_Wrap(shflx_files,0)
   shflx_var = dim_variance_n_Wrap(shflx_files,0)
   net_avg ->SHFlx_avg = shflx_avg
   net_avg ->SHFlx_var = shflx_var
   print("Sensible Heat Flux")

print("Finished averaging variables")


;;;;;;;;;;;;;;;;;;;;;; END script
end
