;***************************************
; PROGRAM DESCRIPTION: This script plots single panel plots of 
;                      diagnostic variables
; INPUT DATA: WRF output or RACM-WRF output post processed with wrfout-to-cf.ncl
;             and then made into yearly seasonal mean files
; OUTPUT DATA: One Panel plot of specified variable
; Note: This can be looped with 01_wrfsinglepanel_akd_seasonal.csh 
;       to evaluate at multiple hours or variables
; CREATOR: Modified by Alice DuVivier - August 2013
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************
begin
; MANUAL INPUTS - for testing purposes
; ******************************************************
;  nx_input = "7"
;  ny_input = "5"
;  master_vals = "winds0.01_rlen1000000_r4"
;  datatitle1  = "wrf50_200511_200703_6h"
;  datatitle1b = "era_i_200511_200703_6h"
;  varcode = "SLP_anom"
 ;; options: "era_i_200511_200703_6h"
  ;; "wrf10_200511_200703_6h" "wrf50_200511_200703_6h"
; ******************************************************
; NOTE: plots of wind do not have vector overlay. NCL memory has problems with the high
; resolution data in this volume and plotting vectors. For vector plots please use script
; that is less complex (node_avgs or winter_avg_diffs)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Set which plots to print out
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Processing all graphs for "+varcode)
; create plots!
plot01  = True ; plot 1 - 4 panel with total winter difference and sum for each term of difference  w/%contribution - group1
plot02  = True ; plot 2 - 4 panel with total winter difference and sum for each term of difference  w/%contribution - group2
plot03  = True ; plot 3 - 4 panel with total winter difference and sum for each term of difference  w/%contribution - group3
plot04  = True ; plot 4 - 4 panel with total winter difference and sum for each term of difference  w/%contribution - group4
plot05  = True ; plot 5 - 4 panel with total winter difference and sum for each term of difference  w/%contribution - group5
plot06  = True ; plot 6 - 4 panel with total winter difference and sum for each term of difference  w/%contribution - group6
plot07  = True ; plot 7 - 4 panel with total winter difference and sum for each term of difference  w/%contribution - group7
plot08  = True ; plot 8 - 4 panel with total winter difference and sum for each term of difference  w/%contribution - group8
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; BEGIN SCRIPT
print("Calculating why averages differ for: "+varcode)

; get tag to let us know if it needs interpolation
title1_ch  = stringtocharacter(datatitle1)
title1_sub = title1_ch(0:4)
tag_1 = chartostring(title1_sub)
title1b_ch  = stringtocharacter(datatitle1b)
title1b_sub = title1b_ch(0:4)
tag_1b = chartostring(title1b_sub)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Calculate frequencies and change in frequencies
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;
; Load input files
;;;;;;;;;;
; Dates from data array index and visual file that places each date at a given node
print("Loading dates and SOM visual data")

if (tag_1 .eq. "wrf10")then
  datatitle_1 = "wrf10_200511_200703"
  datefile_1 = "/data3/duvivier/SOM/training/dates/"+datatitle_1+"_dates.txt"
  visfile_1  = "/data3/duvivier/SOM/training/som_"+nx_input+ny_input+"/master/"+datatitle_1+"_"+master_vals+".vis"
end if
if (tag_1 .eq. "wrf50")then
  datatitle_1 = "wrf50_199701_200712"
  datefile_1 = "/data3/duvivier/SOM/training/dates/"+datatitle_1+"_dates.txt"
  visfile_1  = "/data3/duvivier/SOM/training/som_"+nx_input+ny_input+"/master/"+datatitle_1+"_"+master_vals+".vis"
end if
if (tag_1b .eq. "era_i")then
  datatitle_1b = "era_i_199701_200712"
  datefile_1b = "/data3/duvivier/SOM/training/dates/"+datatitle_1b+"_dates.txt"
  visfile_1b  = "/data3/duvivier/SOM/training/som_"+nx_input+ny_input+"/master/"+datatitle_1b+"_"+master_vals+".vis"
end if
if (tag_1b .eq. "wrf50")then
  datatitle_1b = "wrf50_199701_200712"
  datefile_1b = "/data3/duvivier/SOM/training/dates/"+datatitle_1b+"_dates.txt"
  visfile_1b  = "/data3/duvivier/SOM/training/som_"+nx_input+ny_input+"/master/"+datatitle_1b+"_"+master_vals+".vis"
end if

;;;;;;;;;;
; Load information for two files
;;;;;;;;;;
; file1 - either wrf10 or wrf50
  dates_1 = ndtooned(readAsciiTable(datefile_1,1,"string",0)) ; ignores no rows
  ndates_1 = dimsizes(dates_1)
  dateschar_1 = stringtochar(dates_1)
  sdateym_1 = chartostring(dateschar_1(:,0:5))
  sdatehrs_1 = chartostring(dateschar_1(:,8:9))
  vis_1 = new((/ndates_1,3/),integer)
  vis_1 = readAsciiTable(visfile_1,3,"integer",1) ; ignores first row
; file1b - either wrf50 or era_i
  dates_1b = ndtooned(readAsciiTable(datefile_1b,1,"string",0)) ; ignores no rows
  ndates_1b = dimsizes(dates_1b)
  dateschar_1b = stringtochar(dates_1b)
  sdateym_1b = chartostring(dateschar_1b(:,0:5))
  sdatehrs_1b = chartostring(dateschar_1b(:,8:9))
  vis_1b = new((/ndates_1b,3/),integer)
  vis_1b = readAsciiTable(visfile_1b,3,"integer",1) ; ignores first row

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
  ;sdateym_tmp = sdateym_1(dateind_1)
  delete(dateind_1)
  dateind_1 = ind(sdatehrs_tmp.eq.hrs_6(0).or.sdatehrs_tmp.eq.hrs_6(1).or.sdatehrs_tmp.eq.hrs_6(2).or.sdatehrs_tmp.eq.hrs_6(3))
  visall_1 = visall_1_tmp(dateind_1,:)
  ndates_1 = dimsizes(visall_1(:,0))
  delete(sdatehrs_tmp)
  delete(visall_1_tmp)
end if
if (tag_1b .eq. "era_i")then    ; era interim - just need to narrow down years/months
  dateind_1b = ind(sdateym_1b.eq.ym_sub(0).or.sdateym_1b.eq.ym_sub(1).or.sdateym_1b.eq.ym_sub(2).or.sdateym_1b.eq.ym_sub(3).or.sdateym_1b.eq.ym_sub(4).or.sdateym_1b.eq.ym_sub(5).or.sdateym_1b.eq.ym_sub(6).or.sdateym_1b.eq.ym_sub(7).or.sdateym_1b.eq.ym_sub(8).or.sdateym_1b.eq.ym_sub(9))
  visall_1b = vis_1b(dateind_1b,:)
  ndates_1b = dimsizes(visall_1b(:,0))
end if
if (tag_1b .eq. "wrf50")then     ; wrf 50km - narrow down years/months/hours
  dateind_1b = ind(sdateym_1b.eq.ym_sub(0).or.sdateym_1b.eq.ym_sub(1).or.sdateym_1b.eq.ym_sub(2).or.sdateym_1b.eq.ym_sub(3).or.sdateym_1b.eq.ym_sub(4).or.sdateym_1b.eq.ym_sub(5).or.sdateym_1b.eq.ym_sub(6).or.sdateym_1b.eq.ym_sub(7).or.sdateym_1b.eq.ym_sub(8).or.sdateym_1b.eq.ym_sub(9))
  visall_1b_tmp = vis_1b(dateind_1b,:)
  sdatehrs_tmp = sdatehrs_1b(dateind_1b)
  ;sdateym_tmp = sdateym_1b(dateind_1b)
  delete(dateind_1b)
  dateind_1b = ind(sdatehrs_tmp.eq.hrs_6(0).or.sdatehrs_tmp.eq.hrs_6(1).or.sdatehrs_tmp.eq.hrs_6(2).or.sdatehrs_tmp.eq.hrs_6(3))
  visall_1b = visall_1b_tmp(dateind_1b,:)
  ndates_1b = dimsizes(visall_1b(:,0))
  delete(sdatehrs_tmp)
  delete(visall_1b_tmp)
end if

;;;;;;;;;;
; Calculate frequencies for each data type
;;;;;;;;;;
; Calculate node counts and frequencies for comparison of interest
  nx_node = stringtoint(nx_input)
  ny_node = stringtoint(ny_input)
  nnode = nx_node*ny_node

; variable 1
  nodefreq_1   = new((/nx_node,ny_node/),"float") 
  freq_nodes_1     = new((/nnode/),"float") 
  nodecount_1    = new((/nnode/),"integer") 
; variable_1b
  nodefreq_1b   = new((/nx_node,ny_node/),"float") 
  freq_nodes_1b     = new((/nnode/),"float") 
  nodecount_1b    = new((/nnode/),"integer") 

; set default check values
  check1 = 0
  check1b = 0
  n = 0
; loop through each node
do y = 0, ny_node - 1
 do x = 0, nx_node - 1

  print("node: "+x+","+y)
  ; These are the dates for this particular node:
  dateindices_1 = ind(visall_1(:,0).eq.x.and.(visall_1(:,1).eq.y))
  dateindices_1b = ind(visall_1b(:,0).eq.x.and.(visall_1b(:,1).eq.y))
        
  ; Calculate frequencies
  ; variable 1
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
  ; variable 1b
  if (all(ismissing(dateindices_1b))) then
    node_ndates_1b = 0
    nodefreq_1b(n) = 0
    nodecount_1b(n) = 0
  end if
  if (.not.all(ismissing(dateindices_1b))) then
    node_ndates_1b = dimsizes(dateindices_1b)
    nodefreq_1b(x,y) = (int2flt(node_ndates_1b)/int2flt(ndates_1b))*100.
    freq_nodes_1b(n) = (int2flt(node_ndates_1b)/int2flt(ndates_1b))*100.
    nodecount_1b(n) = node_ndates_1b
  end if
  check1b = check1b + node_ndates_1b  ; make sure all dates are counted

   n = n + 1
   delete(dateindices_1)
   delete(dateindices_1b)
 end do
end do

; Check the dates and print error messages if calculation fails
if (check1.ne.ndates_1) then
 print("Error.  Number of dates is not equal to total number of indices.")
 print("Num. dates: "+ndates_1+"   Tot indices: "+check1)
end if
if (check1b.ne.ndates_1b) then
 print("Error.  Number of dates is not equal to total number of indices.")
 print("Num. dates: "+ndates_1b+"   Tot indices: "+check1b)
end if

;;;;;;;;;;
; Calculate if frequencies are statistically different
;;;;;;;;;;
; make new array to plot
test_stat = new((/nx_node,ny_node/),double)
test_stat = 0.
freq_diff = nodefreq_1 - nodefreq_1b ; get difference in frequencies
test_stat_num = freq_diff/100.
nf1 = nodefreq_1/100.  ; convert from % to just ratio
nf1b = nodefreq_1b/100.
test_stat_den = sqrt((nf1b*(1-nf1b)/ndates_1b) + (nf1*(1-nf1)/ndates_1))
test_stat_den = where(test_stat_den.eq.0,test_stat_den@_FillValue,test_stat_den) ; set 0 to missing to avoid divide by zero error
test_stat = test_stat_num/test_stat_den
test_stat = where(ismissing(test_stat),0,test_stat)

; statistical significance meanings:
; if test_stat .gt. 2.58 then it's 95% statistically significant
; if test_stat .ge. 1.96 and .lt. 2.58 then it's 95% statistically significant
; if test_stat .ge. 1.645 and .lt. 1.96 then it's 95% statistically significant
; NOTE: the same is true in reverse for negative values of these numbers

print("completed frequency calculations")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Calculate node differences
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;
; Set information for variable
;;;;;;;;;;
; add each variable set in the c-shell 'varcode' and assign it a title and other necessary information
if (varcode.eq."SLP_anom") then
  vartitle1 = "Avg SLP anom"
  invar1 = "slp_anom_avg"
  invar_v = "slp_anom_var"
  vartype = "2d"
  cmaptype = "press_anom"
  zoom = True
end if
if (varcode.eq."T_sfc") then
  vartitle1 = "Avg Temp @sfc"
  invar1 = "T_sfc_avg"
  invar_v = "T_sfc_var"
  vartype = "2d"
  cmaptype = "temperature"
  zoom = True
  convert_to_C = True
end if
if (varcode.eq."T_2m") then
  vartitle1 = "Avg Temp @2m"
  invar1 = "T_2m_avg"
  invar_v = "T_2m_var"
  vartype = "2d"
  cmaptype = "temperature"
  zoom = True
  convert_to_C = True
end if
if (varcode.eq."Tgrad_2m_diff") then
  vartitle1 = "Avg Temp grad (sfc-2m)"
  invar1 = "T_sfc_avg"
  invar2 = "T_2m_avg"
  vartype = "2d"
  cmaptype = "temp_grad"
  zoom2 = True
end if
if (varcode.eq."q_2m") then
  vartitle1 = "Avg mixing ratio @2m"
  invar1 = "q_2m_avg"
  invar_v = "q_2m_var"
  vartype = "2d"
  cmaptype = "mix_rad"
  zoom = True
end if
if (varcode.eq."qgrad_2m_diff") then
  vartitle1 = "Avg Mixing Ratio grad (sfc-2m)"
  invar1 = "T_sfc_avg"
  invar2 = "q_2m_avg"
  vartype = "2d"
  cmaptype = "mix_grad"
  zoom2 = True
end if
if (varcode.eq."precip_tot") then
  vartitle1 = "Avg Tot Precip"
  invar1 = "precip_tot_avg"
  invar_v = "precip_tot_var"
  vartype = "2d"
  cmaptype = "precip"
  zoom2 = True
  precip_convert = True
end if
if (varcode.eq."U10_field") then
  vartitle1 = "Avg Wind Field at 10m"
  invar1 = "u_10m_tr_avg"
  invar_v = "u_10m_tr_var"
  invar2 = "v_10m_tr_avg"
  invar_v2 = "v_10m_tr_var"
  vartype = "2d"
  cmaptype = "wind"
  find_field = True
  zoom2 = True
  load2 = True
end if
if (varcode.eq."U10_speed") then
  vartitle1 = "Avg Wind Speed at 10m"
  invar1 = "ws_10m_avg"
  invar_v = "ws_10m_var"
  vartype = "2d"
  cmaptype = "wind"
  zoom2 = True
end if
if (varcode.eq."SH") then
  vartitle1 = "Avg SH Flux at sfc (Native)"
  invar1 = "hfss_avg"
  invar_v = "hfss_var"
  vartype = "2d"
  cmaptype = "shflux"
  zoom2 = True
end if
if (varcode.eq."LH") then
  vartitle1 = "Avg LH Flux at sfc (Native)"
  invar1 = "hfls_avg"
  invar_v = "hfls_var"
  vartype = "2d"
  cmaptype = "lhflux"
  zoom2 = True
end if
if (varcode.eq."SWUS") then
  vartitle1 = "Avg SW up at sfc"
  invar1 = "rsus_avg"
  invar_v = "rsus_var"
  vartype = "2d"
  cmaptype = "swflux"
  zoom2 = True
end if
if (varcode.eq."SWDS") then
  vartitle1 = "Avg SW dn at sfc"
  invar1 =  "rsds_avg"
  invar_v =  "rsds_var"
  vartype = "2d"
  cmaptype = "swflux"
  zoom2 = True
end if
if (varcode.eq."SW_net") then
  vartitle1 = "Avg SW net at sfc"
  invar1 = "SW_deac_net_avg"
  invar_v = "SW_deac_net_var"
  vartype = "2d"
  cmaptype = "swflux"
  zoom2 = True
end if
if (varcode.eq."LWUS") then
  vartitle1 = "Avg LW up at sfc"
  invar1 = "rlus_avg"
  invar_v = "rlus_var"
  vartype = "2d"
  cmaptype = "lwdflux"
  zoom2 = True
end if
if (varcode.eq."LWDS") then
  vartitle1 = "Avg LW dn at sfc"
  invar1 = "rlds_avg"
  invar_v = "rlds_var"
  vartype = "2d"
  cmaptype = "lwdflux"
  zoom2 = True
end if
if (varcode.eq."LW_net") then
  vartitle1 = "Avg LW net at sfc"
  invar1 = "LW_deac_net_avg"
  invar_v = "LW_deac_net_var"
  vartype = "2d"
  cmaptype = "lwflux"
  zoom2 = True
end if
if (varcode.eq."TurbFlx") then
  vartitle1 = "Avg Net Turb Flux at sfc"
  invar1 = "Turb_deac_net_avg"
  invar_v = "Turb_deac_net_var"
  vartype = "2d"
  cmaptype = "netflux"
  zoom2 = True
  netflx = True
end if
if (varcode.eq."RadFlx") then
  vartitle1 = "Avg Net Rad Flux at sfc"
  invar1 = "Rad_deac_net_avg"
  invar_v = "Rad_deac_net_var"
  vartype = "2d"
  cmaptype = "radflux"
  vartype = "2d"
  zoom2 = True
  netflx = True
end if
if (varcode.eq."NetFlx") then
  vartitle1 = "Avg Net Flux at sfc (Rad+Turb: + up)"
  invar1 = "Flux_deac_net_avg"
  invar_v = "Flux_deac_net_var"
  vartype = "2d"
  cmaptype = "netflux"
  zoom2 = True
  netflx = True
end if

; Set the contour interval for each input variable   
; set contour limits manually:
  if (cmaptype.eq."pressure") then
    cmin1               = -1.
    cmax1               = 1.
    clev1               = 0.1
    stride1             = 2                 ; label stride
    cmin2               = -5.
    cmax2               = 5.
    clev2               = 1.
    stride2             = 2                 ; label stride for diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False              ; lines for diff plot
    cntype              = "AreaFill"
    spreadstart1        = 2                 ; start at color
    spreadend1          = 74                ; end at color
    spreadstart2        = 2                ; start at color
    spreadend2          = 102               ; end at color
    colormap            = "BlWhRe"
  end if
  if (cmaptype.eq."press_anom") then
    cmin1               = -1.
    cmax1               = 1.
    clev1               = 0.1
    stride1             = 2                 ; label stride
    cmin2               = -5.
    cmax2               = 5.
    clev2               = 1.
    stride2             = 1                 ; label stride for diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False              ; lines for diff plot
    cntype              = "AreaFill"
    spreadstart1        = 2                 ; start at color
    spreadend1          = 102                ; end at color
    spreadstart2        = 2                ; start at color
    spreadend2          = 102               ; end at coprecip_tot_diff"lor
    colormap            = "BlWhRe"
  end if
  if (cmaptype.eq."temperature") then
    cmin1               = -1.
    cmax1               = 1.
    clev1               = 0.1
    stride1             = 2                 ; label stride
    cmin2               = -5.
    cmax2               = 5.
    clev2               = 0.5
    stride2             = 2                 ; label stride diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False              ; lines for diff plot
    cntype              = "AreaFill"      ; type of contour fill
    spreadstart1        = 67                 ; start at color
    spreadend1          = 106                ; end at color
    spreadstart2        = 67                ; start at color
    spreadend2          = 106 
    colormap            = "temp64_anoms.dave"
  end if
  if (cmaptype.eq."mix_rad") then
    cmin1               =  -10.
    cmax1               =  10.
    clev1               =  1.0
    stride1             =  2                 ; label stride
    cmin2               =  -100.
    cmax2               =  100.
    clev2               =  10.
    stride2             = 2                 ; label stride diff plot
    plotlines           = True              ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"        ; type of contour fill
    spreadstart1        = 44                ; start at color
    spreadend1          = 85                ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 85                ; end at color
    colormap            = "BrownBlue_mod"
  end if
  if (cmaptype.eq."wind") then
    cmin1               = -2.
    cmax1               = 2.0
    clev1               = 0.2
    stride1             = 2                 ; label stride
    cmin2               = -10.
    cmax2               = 10.
    clev2               = 1.
    stride2             = 2                 ; label stride for diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False              ; lines for diff plot
    cntype              = "AreaFill"
    spreadstart1        = 37                ; start at color
    spreadend1          = 132               ; end at color
    spreadstart2        = 37                ; start at color
    spreadend2          = 132               ; end at color
    colormap            = "SOM_wind_table"
  end if
  if (cmaptype.eq."precip") then
    cmin1               =  -0.1
    cmax1               =  0.1
    clev1               =  0.01
    stride1             = 2                 ; label stride
    cmin2               = -1.
    cmax2               =  1.
    clev2               =  0.1
    stride2             = 2                 ; label stride diff plot
    plotlines           = False             ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"        ; type of contour fill
    spreadstart1        = 44                ; start at color
    spreadend1          = 85                ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 85                ; end at color
    colormap            = "BrownBlue_mod"
  end if
  if (cmaptype.eq."lhflux") then
    cmin1               =  -20.
    cmax1               =  20.
    clev1               =  2.
    stride1             = 2                 ; label stride
    cmin2               = -100.
    cmax2               =  100.
    clev2               =  10.
    stride2             = 2                 ; label stride diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"      ; type of fill for contours 
    spreadstart1        = 2                 ; start at color
    spreadend1          = 250               ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 250               ; end at color
    colormap            = "BlueYellowRed_mod"
  end if
  if (cmaptype.eq."shflux") then
    cmin1               =  -20.
    cmax1               =  20.
    clev1               =  2.
    stride1             = 2                 ; label stride
    cmin2               = -150.
    cmax2               =  150.
    clev2               =  10.
    stride2             = 2                 ; label stride diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"      ; type of fill for contours 
    spreadstart1        = 2                 ; start at color
    spreadend1          = 250               ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 250               ; end at color
    colormap            = "BlueYellowRed_mod"
  end if
  if (cmaptype.eq."netflux") then
    cmin1               =  -40.
    cmax1               =  40.
    clev1               =  4.
    stride1             = 2                 ; label stride
    cmin2               = -200.
    cmax2               =  200.
    clev2               =  20.
    stride2             = 2                 ; label stride diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"      ; type of fill for contours 
    spreadstart1        = 2                 ; start at color
    spreadend1          = 250               ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 250               ; end at color
    colormap            = "BlueYellowRed_mod"
  end if
  if (cmaptype.eq."radflux") then
    cmin1               =  -10.
    cmax1               =  10.
    clev1               =  2.
    stride1             = 2                 ; label stride
    cmin2               = -50.
    cmax2               =  50.
    clev2               =  5.
    stride2             = 2                 ; label stride diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"      ; type of fill for contours 
    spreadstart1        = 2                 ; start at color
    spreadend1          = 250               ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 250               ; end at color
    colormap            = "BlueYellowRed_mod"
  end if
  if (cmaptype.eq."swflux") then
    cmin1               =  -1.
    cmax1               =  1.
    clev1               =  0.1
    stride1             = 2                 ; label stride
    cmin2               = -15.
    cmax2               =  15.
    clev2               =  1.
    stride2             = 2                 ; label stride diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"      ; type of fill for contours 
    spreadstart1        = 2                 ; start at color
    spreadend1          = 250               ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 250               ; end at color
    colormap            = "BlueYellowRed_mod"
  end if
  if (cmaptype.eq."lwflux") then
    cmin1               =  -1.
    cmax1               =  1.
    clev1               =  0.1
    stride1             = 2                 ; label stride
    cmin2               = -50.
    cmax2               =  50.
    clev2               =  5.
    stride2             = 2                 ; label stride diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"      ; type of fill for contours 
    spreadstart1        = 2                 ; start at color
    spreadend1          = 250               ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 250               ; end at color
    colormap            = "BlueYellowRed_mod"
  end if
  if (cmaptype.eq."lwdflux") then
    cmin1               =  -5.0
    cmax1               =  5.0
    clev1               =  1.0
    stride1             = 2                 ; label stride
    cmin2               = -50.
    cmax2               =  50.
    clev2               =  5.
    stride2             = 2                 ; label stride diff plot
    plotlines           = False             ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"        ; type of fill for contours 
    spreadstart1        = 127               ; start at color
    spreadend1          = 250               ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 250               ; end at color
    colormap            = "BlueYellowRed_mod"
  end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Data Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dir1 = "/data3/duvivier/SOM/training/som_"+nx_input+ny_input+"/master/node_avgs/"

;;;;;;;;;;
; load in node averages
;;;;;;;;;;
; Load in lat/lon to get information for WRF10 domain
  fname0 = "node_0x_0y_"+datatitle1
  f0 = addfile(dir1 + fname0 + ".nc","r")
  lat2d_1 = f0->lat
  lon2d_1 = f0->lon
  z_sfc_1 = f0->Z_sfc
  obs_1 = f0->number_dates
  delete(fname0)
  delete(f0)

  dims = dimsizes(lat2d_1)     ; get lat/lon dimensions
  n_sn_1 = dims(0)              ; get south/north points
  n_we_1 = dims(1)              ; get west/east points
  n_tot_1 = n_sn_1*n_we_1              ; get total number of points in high res domain
  delete(dims)

; Load in lat/lon to get information for WRF10 domain
  fname0b = "node_0x_0y_"+datatitle1b
  f0b = addfile(dir1 + fname0b + ".nc","r")
  lat2d_1b = f0b->lat
  lon2d_1b = f0b->lon
  z_sfc_1b = f0b->Z_sfc
  obs_1b = f0b->number_dates
  delete(fname0b)
  delete(f0b)

  dims = dimsizes(lat2d_1b)     ; get lat/lon dimensions
  n_sn_1b = dims(0)              ; get south/north points
  n_we_1b = dims(1)              ; get west/east points
  n_tot_1b = n_sn_1b*n_we_1b              ; get total number of points in high res domain
  delete(dims)

  ; get weights and indicies for regridding (WRF50 and era weightings are identical)
  weightin = addfile("/data3/duvivier/SOM/DATA/weightings_WRF50_to_WRF10.nc","r")
  interp_ind = weightin->interp_ind
  interp_wgt = weightin->interp_wgt

  ; create all-node array for node average variable
  if (invar1.eq."q_eta0_avg" .or. invar1.eq."T_eta0_avg") then
    var1 = new((/nnode,n_sn_1,n_we_1/),"double")
    var1b = new((/nnode,n_sn_1b,n_we_1b/),"double")
    variance1 = new((/nnode,n_sn_1,n_we_1/),"double")
    variance1b = new((/nnode,n_sn_1b,n_we_1b/),"double")
  else ;(every other variable)
    var1 = new((/nnode,n_sn_1,n_we_1/),"float")
    var1b = new((/nnode,n_sn_1b,n_we_1b/),"float")
    variance1 = new((/nnode,n_sn_1,n_we_1/),"float")
    variance1b = new((/nnode,n_sn_1b,n_we_1b/),"float")
  end if
  fill = var1@_FillValue

; create variables for other combinations
  if (isvar("load2").and.(load2))
    var2 = new((/nnode,n_sn_1,n_we_1/),"float")
    var2b = new((/nnode,n_sn_1b,n_we_1b/),"float") 
    variance2 = new((/nnode,n_sn_1,n_we_1/),"float")
    variance2b = new((/nnode,n_sn_1b,n_we_1b/),"float")  
  end if
  ; make sea ice var - overlay with everything
  seaice_1 = new((/nnode,n_sn_1,n_we_1/),"float")
  seaice_1b = new((/nnode,n_sn_1b,n_we_1b/),"float")

;;;;;;;;;;
; Load in actual data for analysis
;;;;;;;;;;
n = 0
; loop through each node
do y = 0, ny_node - 1
 do x = 0, nx_node - 1
  print("node: "+x+","+y)

  fname1 = "node_"+x+"x_"+y+"y_"+datatitle1
  f1 = addfile(dir1 + fname1 + ".nc","r")
  var1(n,:,:) = f1->$invar1$(south_north|:,west_east|:)
  variance1(n,:,:) = f1->$invar_v$(south_north|:,west_east|:)

  fname1b = "node_"+x+"x_"+y+"y_"+datatitle1b
  f1b = addfile(dir1 + fname1b + ".nc","r")
  var1b(n,:,:) = f1b->$invar1$(south_north|:,west_east|:)
  variance1b(n,:,:) = f1b->$invar_v$(south_north|:,west_east|:)

  if (isvar("load2").and.(load2)) then
    var2(n,:,:) = f1->$invar2$(south_north|:,west_east|:)
    var2b(n,:,:) = f1b->$invar2$(south_north|:,west_east|:)
    variance2(n,:,:) = f1->$invar_v$(south_north|:,west_east|:)
    variance2b(n,:,:) = f1b->$invar_v2$(south_north|:,west_east|:)

    ; calculate variance
    variance1(n,:,:) = variance1(n,:,:) + variance2(n,:,:)
    variance1b(n,:,:) = variance1b(n,:,:) + variance2b(n,:,:)
  end if
  seaice_1(n,:,:) = f1->SeaIce_avg(south_north|:,west_east|:)
  seaice_1b(n,:,:) = f1b->SeaIce_avg(south_north|:,west_east|:)

  ; delete vars to use in next loop
  delete(fname1)
  delete(f1)
  delete(fname1b)
  delete(f1b)
  n = n+1
 end do
end do
delete(n)

print("Loaded "+varcode+" from both files")
;;;;;;;;;;
; manipulate arrays as needed - post interpolation
;;;;;;;;;;
print("Manipulating vars as needed")
if (isvar("convert_to_C").and.(convert_to_C)) then
    var1 = var1 - 273.15
   if (varcode .eq. "T_sfc")then
     var1b = var1b - 273.15
   end if 
   if(varcode .eq. "T_2m" .and. tag_1b .ne. "era_i")then
     var1b = var1b -273.15
   end if
    var1@units = "C" 
end if
if (isvar("precip_convert").and.(precip_convert)) then
  var1 = var1*(60*60*3)
  if (tag_1b .eq. "era_i")then
    var1b = var1b*(60*60*3)* (60*60*3)  ; I accidentally divided by the #seconds twice for era_i. fix it here.   
  else
    var1b = var1b*(60*60*3)
  end if
  var1@units = "mm"
end if

;;;;;;;;;;
; Interpolate to WRF10 size (if needed)
;;;;;;;;;;
if (tag_1 .eq. "wrf10" .and. tag_1b .ne. "wrf10")then
  print("Interpolating between resolutions")
  ; Make arrays we'll need in interpolation
  var1b_new = new((/nnode,n_sn_1,n_we_1/),"float") 
  var1b_tmp_1d  = new((/n_tot_1/),"float")
  variance1b_new = new((/nnode,n_sn_1,n_we_1/),"float") 
  variance1b_tmp_1d  = new((/n_tot_1/),"float")
  seaice_1b_new = new((/nnode,n_sn_1,n_we_1/),"float") 
  seaice_1b_tmp_1d  = new((/n_tot_1/),"float")
  if (isvar("find_field").and.(find_field))then
    var2b_new = new((/nnode,n_sn_1,n_we_1/),"float") 
    var2b_tmp_1d  = new((/n_tot_1/),"float")
  end if

  do n = 0, nnode - 1
    var1b_1d = ndtooned(var1b(n,:,:))
    variance1b_1d = ndtooned(variance1b(n,:,:))
    seaice_1b_1d = ndtooned(seaice_1b(n,:,:))
     if (isvar("find_field").and.(find_field))then
       var2b_1d = ndtooned(var2b(n,:,:))
     end if
    do i = 0, n_tot_1 - 1
      indices_all = interp_ind(i,:)
      n_indices = num(.not.ismissing(indices_all))
      if (n_indices .ne. 0.0) then
        indices = indices_all(0:n_indices-1)
        weight_all = interp_wgt(i,:)
        weight = weight_all(0:n_indices-1)
        var1b_tmp_1d(i) = sum(var1b_1d(indices)*weight/sum(weight))
        variance1b_tmp_1d(i) = sum(variance1b_1d(indices)*weight/sum(weight))
        seaice_1b_tmp_1d(i) = sum(seaice_1b_1d(indices)*weight/sum(weight))
        if (isvar("find_field").and.(find_field))then
          var2b_tmp_1d(i) = sum(var2b_1d(indices)*weight/sum(weight))
        end if
        delete(indices)
        delete(weight)
      end if
    end do
    ; redimensionalize
    var1b_new(n,:,:) = onedtond(var1b_tmp_1d,(/n_sn_1,n_we_1/))
    variance1b_new(n,:,:) = onedtond(variance1b_tmp_1d,(/n_sn_1,n_we_1/))
    seaice_1b_new(n,:,:) = onedtond(seaice_1b_tmp_1d,(/n_sn_1,n_we_1/))
    if (isvar("find_field").and.(find_field))then
      var2b_new(n,:,:) = onedtond(var2b_tmp_1d,(/n_sn_1,n_we_1/))
    end if

   ; counter
    print("created node avg "+n+" of "+nnode)
  end do

  delete(var1b)
  var1b = var1b_new
  delete(var1b_new)
  copy_VarMeta(var1, var1b)
  copy_VarCoords(var1,var1b)
  var1b@_FillValue = fill
  if (isvar("find_field") .and. (find_field))then
    delete(var2b)
    var2b = var2b_new
    delete(var2b_new)
    copy_VarMeta(var2, var2b)
    copy_VarCoords(var2,var2b)
    var2b@_FillValue = fill
  end if
  delete(variance1b)
  variance1b = variance1b_new
  delete(variance1b_new)
  copy_VarMeta(variance1, variance1b)
  copy_VarCoords(variance1,variance1b)
  variance1b@_FillValue = fill
  delete(seaice_1b)
  seaice_1b = seaice_1b_new
  delete(seaice_1b_new)
  copy_VarMeta(seaice_1, seaice_1b)
  copy_VarCoords(seaice_1,seaice_1b)
  seaice_1b@_FillValue = fill
end if

print("Masking terrain - nodes")
n = 0
; loop through each node
do n = 0, nnode - 1
  ; mask terrain - focus on ocean
  var1(n,:,:) = where(z_sfc_1 .lt. 50., var1(n,:,:), var1@_FillValue)
  var1b(n,:,:) = where(z_sfc_1 .lt. 50., var1b(n,:,:), var1b@_FillValue)
  seaice_1(n,:,:) = where(z_sfc_1 .lt. 50., seaice_1(n,:,:), seaice_1@_FillValue)
  seaice_1b(n,:,:) = where(z_sfc_1 .lt. 50., seaice_1b(n,:,:), seaice_1b@_FillValue)

  ; mask lat/lons - focus on S. Greenland region
  var1(n,:,:) = where(lat2d_1 .gt. 55. .and. lat2d_1 .lt. 71. .and. lon2d_1 .lt. -19. .and. lon2d_1 .gt. -55., var1(n,:,:), var1@_FillValue)
  var1b(n,:,:) = where(lat2d_1 .gt. 55. .and. lat2d_1 .lt. 71. .and. lon2d_1 .lt. -19. .and. lon2d_1 .gt. -55., var1b(n,:,:), var1b@_FillValue)
  seaice_1(n,:,:) = where(lat2d_1 .gt. 55. .and. lat2d_1 .lt. 71. .and. lon2d_1 .lt. -19. .and. lon2d_1 .gt. -55., seaice_1(n,:,:), seaice_1@_FillValue)
  seaice_1b(n,:,:) = where(lat2d_1 .gt. 55. .and. lat2d_1 .lt. 71. .and. lon2d_1 .lt. -19. .and. lon2d_1 .gt. -55., seaice_1b(n,:,:), seaice_1b@_FillValue)
end do

;;;;;;;;;;
; Find difference
;;;;;;;;;;
if (isvar("find_field").and.(find_field)) then
  ; find wind field speed post interpolation
  U_1 = var1
  V_1 = var2
  U_1b = var1b
  V_1b = var2b
  var1 = sqrt(var1^2+var2^2)
  var1b = sqrt(var1b^2+var2b^2)
  var1@long_name = "Net Wind Field"
  var1@standard_name = "Wind Field"
  delete(var2)
  delete(var2b)
end if

  diff = var1 - var1b
  title_diff = "Diff: ("+datatitle1+" - "+datatitle1b+")"

; assign lat/lon info
var1@lat2d = lat2d_1
var1@lon2d = lon2d_1
var1b@lat2d = lat2d_1
var1b@lon2d = lon2d_1
diff@lat2d = lat2d_1
diff@lon2d = lon2d_1
seaice_1@lat2d = lat2d_1
seaice_1@lon2d = lon2d_1
seaice_1b@lat2d = lat2d_1
seaice_1b@lon2d = lon2d_1

; prints together the variable title (set above for each type of data) with title1 (defined in cshell as the wrf or met info) and the max and min values
  print(vartitle1+" min: "+min(diff)+"  max: "+max(diff)) 

;;;;;;;;;;
; Calculate statistical significance
;;;;;;;;;;
; Uses student's t-test. If the probability is less than 0.1 then we know at a 90% confidence level
; that the two means are statistically significant.
prob = new((/nnode,n_sn_1,n_we_1/),"float")
n = 0
do n = 0, nnode - 1
  prob(n,:,:) = 100.*(1. - ttest(var1(n,:,:),variance1(n,:,:),nodecount_1(n), var1b(n,:,:),variance1b(n,:,:),nodecount_1b(n), False, False))    
end do

prob@lat2d = lat2d_1
prob@lon2d = lon2d_1

print("completed node calculations")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Calculate difference terms for analysis
; delta U = sigma (delta_freq*U + freq*delta_U + delta_freq*delta_U)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
var = var1b             ; era or wrf50 as control
freq = freq_nodes_1b/100.      ; era or wrf50 as control
delta_var = diff        ; var_1 - var_1b
delta_freq = (freq_nodes_1 - freq_nodes_1b)/100.     ; freq_1 - freq_1b

  ; Make arrays for each term for each node
  term1 = new((/nnode,n_sn_1,n_we_1/),"float")
  term1@_FillValue = fill
  term1_sum = new((/n_sn_1,n_we_1/),"float")
  term1_sum = 0.0
  term2 = new((/nnode,n_sn_1,n_we_1/),"float")
  term2@_FillValue = fill
  term2_sum = new((/n_sn_1,n_we_1/),"float")
  term2_sum = 0.0
  term3 = new((/nnode,n_sn_1,n_we_1/),"float")
  term3@_FillValue = fill
  term3_sum = new((/n_sn_1,n_we_1/),"float")
  term3_sum = 0.0
  winter_nodes_1 = new((/nnode,n_sn_1,n_we_1/),"float")
  winter_nodes_1b = new((/nnode,n_sn_1,n_we_1/),"float")
  winter_avg_1 = new((/n_sn_1,n_we_1/),"float")
  winter_avg_1 = 0.0
  winter_avg_1b = new((/n_sn_1,n_we_1/),"float")
  winter_avg_1b = 0.0
  seaice_nodes_1 = new((/nnode,n_sn_1,n_we_1/),"float")
  seaice_nodes_1b = new((/nnode,n_sn_1,n_we_1/),"float")
  seaice_avg_1 = new((/n_sn_1,n_we_1/),"float")
  seaice_avg_1 = 0.0
  seaice_avg_1b = new((/n_sn_1,n_we_1/),"float")
  seaice_avg_1b = 0.0
  if(isvar("find_field").and.(find_field))then
    term1_U = new((/nnode,n_sn_1,n_we_1/),"float")
    term1_U@_FillValue = fill
    term1_U_sum = new((/n_sn_1,n_we_1/),"float")
    term1_U_sum = 0.0
    term2_U = new((/nnode,n_sn_1,n_we_1/),"float")
    term2_U@_FillValue = fill
    term2_U_sum = new((/n_sn_1,n_we_1/),"float")
    term2_U_sum = 0.0
    term3_U = new((/nnode,n_sn_1,n_we_1/),"float")
    term3_U@_FillValue = fill
    term3_U_sum = new((/n_sn_1,n_we_1/),"float")
    term3_U_sum = 0.0
    winter_nodes_U_1 = new((/nnode,n_sn_1,n_we_1/),"float")
    winter_nodes_U_1b = new((/nnode,n_sn_1,n_we_1/),"float")
    winter_avg_U_1 = new((/n_sn_1,n_we_1/),"float")
    winter_avg_U_1 = 0.0
    winter_avg_U_1b = new((/n_sn_1,n_we_1/),"float")
    winter_avg_U_1b = 0.0
    term1_V = new((/nnode,n_sn_1,n_we_1/),"float")
    term1_V@_FillValue = fill
    term1_V_sum = new((/n_sn_1,n_we_1/),"float")
    term1_V_sum = 0.0
    term2_V = new((/nnode,n_sn_1,n_we_1/),"float")
    term2_V@_FillValue = fill
    term2_V_sum = new((/n_sn_1,n_we_1/),"float")
    term2_V_sum = 0.0
    term3_V = new((/nnode,n_sn_1,n_we_1/),"float")
    term3_V@_FillValue = fill
    term3_V_sum = new((/n_sn_1,n_we_1/),"float")
    term3_V_sum = 0.0
    winter_nodes_V_1 = new((/nnode,n_sn_1,n_we_1/),"float")
    winter_nodes_V_1b = new((/nnode,n_sn_1,n_we_1/),"float")
    winter_avg_V_1 = new((/n_sn_1,n_we_1/),"float")
    winter_avg_V_1 = 0.0
    winter_avg_V_1b = new((/n_sn_1,n_we_1/),"float")
    winter_avg_V_1b = 0.0
  end if

  ; Make arrays for each term for individual groups
  ;group1  = ("0" "1" "7")
  ;group2  = ("2" "8" "9" "16" "17")
  ;group3  = ("3" "4" "10" "11" "18" "19")
  ;group4  = ("5" "6" "12" "13" "20")
  ;group5  = ("14" "21" "28" "29")
  ;group6  = ("15" "22" "23" "30")
  ;group7  = ("24" "25" "31" "32")
  ;group8  = ("26" "27" "33" "34")

  term1_sum_group1 = new((/n_sn_1,n_we_1/),"float")
  term1_sum_group1 = 0.0
  term2_sum_group1 = new((/n_sn_1,n_we_1/),"float")
  term2_sum_group1 = 0.0
  term3_sum_group1 = new((/n_sn_1,n_we_1/),"float")
  term3_sum_group1 = 0.0
  term1_sum_group2 = new((/n_sn_1,n_we_1/),"float")
  term1_sum_group2 = 0.0
  term2_sum_group2 = new((/n_sn_1,n_we_1/),"float")
  term2_sum_group2 = 0.0
  term3_sum_group2 = new((/n_sn_1,n_we_1/),"float")
  term3_sum_group2 = 0.0
  term1_sum_group3 = new((/n_sn_1,n_we_1/),"float")
  term1_sum_group3 = 0.0
  term2_sum_group3 = new((/n_sn_1,n_we_1/),"float")
  term2_sum_group3 = 0.0
  term3_sum_group3 = new((/n_sn_1,n_we_1/),"float")
  term3_sum_group3 = 0.0
  term1_sum_group4 = new((/n_sn_1,n_we_1/),"float")
  term1_sum_group4 = 0.0
  term2_sum_group4 = new((/n_sn_1,n_we_1/),"float")
  term2_sum_group4 = 0.0
  term3_sum_group4 = new((/n_sn_1,n_we_1/),"float")
  term3_sum_group4 = 0.0
  term1_sum_group5 = new((/n_sn_1,n_we_1/),"float")
  term1_sum_group5 = 0.0
  term2_sum_group5 = new((/n_sn_1,n_we_1/),"float")
  term2_sum_group5 = 0.0
  term3_sum_group5 = new((/n_sn_1,n_we_1/),"float")
  term3_sum_group5 = 0.0
  term1_sum_group6 = new((/n_sn_1,n_we_1/),"float")
  term1_sum_group6 = 0.0
  term2_sum_group6 = new((/n_sn_1,n_we_1/),"float")
  term2_sum_group6 = 0.0
  term3_sum_group6 = new((/n_sn_1,n_we_1/),"float")
  term3_sum_group6 = 0.0
  term1_sum_group7 = new((/n_sn_1,n_we_1/),"float")
  term1_sum_group7 = 0.0
  term2_sum_group7 = new((/n_sn_1,n_we_1/),"float")
  term2_sum_group7 = 0.0
  term3_sum_group7 = new((/n_sn_1,n_we_1/),"float")
  term3_sum_group7 = 0.0
  term1_sum_group8 = new((/n_sn_1,n_we_1/),"float")
  term1_sum_group8 = 0.0
  term2_sum_group8 = new((/n_sn_1,n_we_1/),"float")
  term2_sum_group8 = 0.0
  term3_sum_group8 = new((/n_sn_1,n_we_1/),"float")
  term3_sum_group8 = 0.0

  do n = 0, nnode - 1
    ;Calculate each term for all nodes
    term1(n,:,:) = delta_freq(n)*var(n,:,:)
    term2(n,:,:) = freq(n)*delta_var(n,:,:)
    term3(n,:,:) = delta_freq(n)*delta_var(n,:,:)

    ; Do sums over various terms
    term1_sum(:,:) = term1_sum(:,:) + term1(n,:,:)
    term2_sum(:,:) = term2_sum(:,:) + term2(n,:,:)
    term3_sum(:,:) = term3_sum(:,:) + term3(n,:,:)

    ; Do sums over various terms for groups
    ;; group1 - northeastery flow
    if(n .eq. 0 .or. n .eq. 1 .or. n .eq. 7)then
      term1_sum_group1(:,:) = term1_sum_group1(:,:) + term1(n,:,:)
      term2_sum_group1(:,:) = term2_sum_group1(:,:) + term2(n,:,:)
      term3_sum_group1(:,:) = term3_sum_group1(:,:) + term3(n,:,:)
    end if
    ;; group2 - northeasterly flow in DSN
    if(n .eq. 2 .or. n .eq. 8 .or. n .eq. 9 .or. n .eq. 16 .or. n .eq. 17)then
      term1_sum_group2(:,:) = term1_sum_group2(:,:) + term1(n,:,:)
      term2_sum_group2(:,:) = term2_sum_group2(:,:) + term2(n,:,:)
      term3_sum_group2(:,:) = term3_sum_group2(:,:) + term3(n,:,:)
    end if
    ;; group3 - WTJ with barrier flow
    if(n .eq. 3 .or. n .eq. 4 .or. n .eq. 10 .or. n .eq. 11 .or. n .eq. 18 .or. n .eq. 19)then
      term1_sum_group3(:,:) = term1_sum_group3(:,:) + term1(n,:,:)
      term2_sum_group3(:,:) = term2_sum_group3(:,:) + term2(n,:,:)
      term3_sum_group3(:,:) = term3_sum_group3(:,:) + term3(n,:,:)
    end if
    ;; group4 - Strong WTJ with barrier flow
    if(n .eq. 5 .or. n .eq. 6 .or. n .eq. 12 .or. n .eq. 13 .or. n .eq. 20)then
      term1_sum_group4(:,:) = term1_sum_group4(:,:) + term1(n,:,:)
      term2_sum_group4(:,:) = term2_sum_group4(:,:) + term2(n,:,:)
      term3_sum_group4(:,:) = term3_sum_group4(:,:) + term3(n,:,:)
    end if
    ;; group5 - Strong ETJ
    if(n .eq. 14 .or. n .eq. 21 .or. n .eq. 28 .or. n .eq. 29)then
      term1_sum_group5(:,:) = term1_sum_group5(:,:) + term1(n,:,:)
      term2_sum_group5(:,:) = term2_sum_group5(:,:) + term2(n,:,:)
      term3_sum_group5(:,:) = term3_sum_group5(:,:) + term3(n,:,:)
    end if
    ;; group6 - ETJ
    if(n .eq. 15 .or. n .eq. 22 .or. n .eq. 23 .or. n .eq. 30)then
      term1_sum_group6(:,:) = term1_sum_group6(:,:) + term1(n,:,:)
      term2_sum_group6(:,:) = term2_sum_group6(:,:) + term2(n,:,:)
      term3_sum_group6(:,:) = term3_sum_group6(:,:) + term3(n,:,:)
    end if
    ;; group7 - southerly flow
    if(n .eq. 24 .or. n .eq. 25 .or. n .eq. 31 .or. n .eq. 32)then
      term1_sum_group7(:,:) = term1_sum_group7(:,:) + term1(n,:,:)
      term2_sum_group7(:,:) = term2_sum_group7(:,:) + term2(n,:,:)
      term3_sum_group7(:,:) = term3_sum_group7(:,:) + term3(n,:,:)
    end if
    ;; group8 - WTJ without barrier flow
    if(n .eq. 26 .or. n .eq. 27 .or. n .eq. 33 .or. n .eq. 34)then
      term1_sum_group8(:,:) = term1_sum_group8(:,:) + term1(n,:,:)
      term2_sum_group8(:,:) = term2_sum_group8(:,:) + term2(n,:,:)
      term3_sum_group8(:,:) = term3_sum_group8(:,:) + term3(n,:,:)
    end if

    ; Find winter net average
    winter_nodes_1(n,:,:)  = (freq_nodes_1(n)/100.) * var1(n,:,:)
    winter_nodes_1b(n,:,:) = (freq_nodes_1b(n)/100.) * var1b(n,:,:)    
    winter_avg_1 = winter_avg_1(:,:) + winter_nodes_1(n,:,:)
    winter_avg_1b = winter_avg_1b(:,:) + winter_nodes_1b(n,:,:)

    ; Find U and V averages if needed
    if(isvar("find_field").and.(find_field))then
      ;Calculate each term for all nodes
      term1_U(n,:,:) = delta_freq(n)*U_1b(n,:,:)
      term2_U(n,:,:) = freq(n)*(U_1(n,:,:)-U_1b(n,:,:))
      term3_U(n,:,:) = delta_freq(n)*(U_1(n,:,:)-U_1b(n,:,:))
      
      term1_V(n,:,:) = delta_freq(n)*V_1b(n,:,:)
      term2_V(n,:,:) = freq(n)*(V_1(n,:,:)-V_1b(n,:,:))
      term3_V(n,:,:) = delta_freq(n)*(V_1(n,:,:)-V_1b(n,:,:))

      ; Do sums over various terms
      term1_U_sum(:,:) = term1_U_sum(:,:) + term1_U(n,:,:)
      term2_U_sum(:,:) = term2_U_sum(:,:) + term2_U(n,:,:)
      term3_U_sum(:,:) = term3_U_sum(:,:) + term3_U(n,:,:)

      term1_V_sum(:,:) = term1_V_sum(:,:) + term1_V(n,:,:)
      term2_V_sum(:,:) = term2_V_sum(:,:) + term2_V(n,:,:)
      term3_V_sum(:,:) = term3_V_sum(:,:) + term3_V(n,:,:)

      ; Find winter net average
      winter_nodes_U_1(n,:,:)  = (freq_nodes_1(n)/100.) * U_1(n,:,:)
      winter_nodes_U_1b(n,:,:) = (freq_nodes_1b(n)/100.) * U_1b(n,:,:)    
      winter_avg_U_1 = winter_avg_U_1(:,:) + winter_nodes_U_1(n,:,:)
      winter_avg_U_1b = winter_avg_U_1b(:,:) + winter_nodes_U_1b(n,:,:)

      winter_nodes_V_1(n,:,:)  = (freq_nodes_1(n)/100.) * V_1(n,:,:)
      winter_nodes_V_1b(n,:,:) = (freq_nodes_1b(n)/100.) * V_1b(n,:,:)    
      winter_avg_V_1 = winter_avg_V_1(:,:) + winter_nodes_V_1(n,:,:)
      winter_avg_V_1b = winter_avg_V_1b(:,:) + winter_nodes_V_1b(n,:,:)
    end if      

    ; Find seaice winter net average
    seaice_nodes_1(n,:,:)  = (freq_nodes_1(n)/100.) * seaice_1(n,:,:)
    seaice_nodes_1b(n,:,:) = (freq_nodes_1b(n)/100.) * seaice_1b(n,:,:)    
    seaice_avg_1 = seaice_avg_1(:,:) + seaice_nodes_1(n,:,:)
    seaice_avg_1b = seaice_avg_1b(:,:) + seaice_nodes_1b(n,:,:)
  end do

  ; Find winter differences
  ; Winter net difference
  winter_diff = winter_avg_1 - winter_avg_1b
  ; Do sums over various terms for why the difference exists
  nodes_sum_all = term1 + term2 + term3
  net_diff = term1_sum + term2_sum + term3_sum

  ; Find the "net" difference for each group
  net_group1 = term1_sum_group1 + term2_sum_group1 + term3_sum_group1
  net_group2 = term1_sum_group2 + term2_sum_group2 + term3_sum_group2
  net_group3 = term1_sum_group3 + term2_sum_group3 + term3_sum_group3
  net_group4 = term1_sum_group4 + term2_sum_group4 + term3_sum_group4   
  net_group5 = term1_sum_group5 + term2_sum_group5 + term3_sum_group5
  net_group6 = term1_sum_group6 + term2_sum_group6 + term3_sum_group6
  net_group7 = term1_sum_group7 + term2_sum_group7 + term3_sum_group7
  net_group8 = term1_sum_group8 + term2_sum_group8 + term3_sum_group8    

  ; assign lat/lon data for plotting
  var1@_FillValue = fill
  copy_VarMeta(var1,nodes_sum_all)
  copy_VarMeta(var1,term1)
  copy_VarMeta(var1,term2)
  copy_VarMeta(var1,term3)

  z_sfc_1@_FillValue = fill
  copy_VarMeta(z_sfc_1,net_diff)
  net_diff@lat2d = lat2d_1
  net_diff@lon2d = lon2d_1
  copy_VarMeta(net_diff,term1_sum)
  copy_VarMeta(net_diff,term2_sum)
  copy_VarMeta(net_diff,term3_sum)
  copy_VarMeta(net_diff,term1_sum_group1)
  copy_VarMeta(net_diff,term2_sum_group1)
  copy_VarMeta(net_diff,term3_sum_group1)
  copy_VarMeta(net_diff,net_group1)
  copy_VarMeta(net_diff,term1_sum_group2)
  copy_VarMeta(net_diff,term2_sum_group2)
  copy_VarMeta(net_diff,term3_sum_group2)
  copy_VarMeta(net_diff,net_group2)
  copy_VarMeta(net_diff,term1_sum_group3)
  copy_VarMeta(net_diff,term2_sum_group3)
  copy_VarMeta(net_diff,term3_sum_group3)
  copy_VarMeta(net_diff,net_group3)
  copy_VarMeta(net_diff,term1_sum_group4)
  copy_VarMeta(net_diff,term2_sum_group4)
  copy_VarMeta(net_diff,term3_sum_group4)
  copy_VarMeta(net_diff,net_group4)
  copy_VarMeta(net_diff,term1_sum_group5)
  copy_VarMeta(net_diff,term2_sum_group5)
  copy_VarMeta(net_diff,term3_sum_group5)
  copy_VarMeta(net_diff,net_group5)
  copy_VarMeta(net_diff,term1_sum_group6)
  copy_VarMeta(net_diff,term2_sum_group6)
  copy_VarMeta(net_diff,term3_sum_group6)
  copy_VarMeta(net_diff,net_group6)
  copy_VarMeta(net_diff,term1_sum_group7)
  copy_VarMeta(net_diff,term2_sum_group7)
  copy_VarMeta(net_diff,term3_sum_group7)
  copy_VarMeta(net_diff,net_group7)
  copy_VarMeta(net_diff,term1_sum_group8)
  copy_VarMeta(net_diff,term2_sum_group8)
  copy_VarMeta(net_diff,term3_sum_group8)
  copy_VarMeta(net_diff,net_group8)
  copy_VarMeta(net_diff,winter_avg_1)
  copy_VarMeta(net_diff,winter_avg_1b)
  copy_VarMeta(net_diff,winter_diff)
  copy_VarMeta(net_diff,seaice_avg_1)
  copy_VarMeta(net_diff,seaice_avg_1b)
 
  print("Completed calculations for assessing why differences exist")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Use net average files to calculate difference
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Load in lat/lon to get information for WRF10 domain
  f1 = addfile("/data3/duvivier/SOM/training/averages/all/net_avg_"+datatitle1+".nc","r")
  obs_1 = f1->number_dates

; Load in lat/lon to get information for WRF10 domain
  f1b = addfile("/data3/duvivier/SOM/training/averages/all/net_avg_"+datatitle1b+".nc","r")

  ; create all-node array for node average variable
  avg1 = new((/n_sn_1,n_we_1/),"float")
  avg1b = new((/n_sn_1b,n_we_1b/),"float")
  avg_variance1 = new((/n_sn_1,n_we_1/),"float")
  avg_variance1b = new((/n_sn_1b,n_we_1b/),"float")
  fill = var1@_FillValue

; create variables for other combinations
  if (isvar("load2").and.(load2))
    avg2 = new((/n_sn_1,n_we_1/),"float") 
    avg2b = new((/n_sn_1b,n_we_1b/),"float")
    avg_variance2 = new((/n_sn_1,n_we_1/),"float") 
    avg_variance2b = new((/n_sn_1b,n_we_1b/),"float")
  end if
  ; make sea ice var - overlay with everything
  avg_seaice_1 = new((/n_sn_1,n_we_1/),"float")
  avg_seaice_1b = new((/n_sn_1b,n_we_1b/),"float")

;;;;;;;;;;
; Load in actual data for analysis
;;;;;;;;;;
  avg1(:,:) = f1->$invar1$(south_north|:,west_east|:)
  avg1b(:,:) = f1b->$invar1$(south_north|:,west_east|:)
  avg_variance1(:,:) = f1->$invar_v$(south_north|:,west_east|:)
  avg_variance1b(:,:) = f1b->$invar_v$(south_north|:,west_east|:)

  if (isvar("load2").and.(load2)) then
    avg2(:,:)  = f1->$invar2$(south_north|:,west_east|:)
    avg2b(:,:) = f1b->$invar2$(south_north|:,west_east|:)
    avg_variance2(:,:) = f1->$invar_v2$(south_north|:,west_east|:)
    avg_variance2b(:,:) = f1b->$invar_v2$(south_north|:,west_east|:)

    ; get total variance  (sum of two variances - assumes independence)
    avg_variance1 = avg_variance1 + avg_variance2
    avg_variance1b = avg_variance1b + avg_variance2b
    delete(avg_variance2)
    delete(avg_variance2b)
  end if
  avg_seaice_1(:,:) = f1->SeaIce_avg(south_north|:,west_east|:)
  avg_seaice_1b(:,:) = f1b->SeaIce_avg(south_north|:,west_east|:)

  ; delete vars to use in next loop
  delete(f1)
  delete(f1b)

print("Loaded variables from both files")

;;;;;;;;;;
; manipulate arrays as needed - post interpolation
;;;;;;;;;;
print("Manipulating vars as needed")
if (isvar("convert_to_C").and.(convert_to_C)) then
    avg1 = avg1 - 273.15
   if (varcode .eq. "T_sfc")then
     avg1b = avg1b - 273.15
   end if 
   if(varcode .eq. "T_2m" .and. tag_1b .ne. "era_i")then
     avg1b = avg1b -273.15
   end if
    avg1@units = "C"
    avg1b@units = "C"
end if
if (isvar("precip_convert").and.(precip_convert)) then
  avg1 = avg1*(60*60*3)
  if (tag_1b .eq. "era_i")then
    avg1b = avg1b*(60*60*3)* (60*60*3)  ; I accidentally divided by the #seconds twice for era_i. fix it here.   
  else
    avg1b = avg1b*(60*60*3)
  end if
  avg1@units = "mm"
end if
if (isvar("Tgrad").and.(Tgrad)) then
  if (invar2.eq."T_eta0_avg") then ; WRF files need type conversion
    tmp2 = doubletofloat(avg2)
    delete(avg2)
    avg2 = tmp2
    delete(tmp2)
    tmp2b = doubletofloat(avg2b)
    delete(avg2b)
    avg2b = tmp2b
    delete(tmp2b)
  end if
  if (tag_1b.eq."era_i") then ;ERA-I files have sfc temp in C
    avg1b = avg1b-273.15 
    avg1b@units = "degC"
  end if
  avg1 = avg1 - avg2
  avg1@units = "C"
  delete(avg2)
  avg1b = avg1b-avg2b
  delete(avg2b)
end if
if (isvar("qgrad").and.(qgrad)) then
  if (invar2.eq."q_eta0_avg") then ; WRF files need type conversion
    tmp2 = doubletofloat(avg2)
    delete(avg2)
    avg2 = tmp2
    delete(tmp2)
    tmp2b = doubletofloat(avg2b)
    delete(avg2b)
    avg2b = tmp2b
    delete(tmp2b)
  end if
    ; calculate surface saturation mixing ratio
  avg1  = avg1-273.15  ; convert sfc temp to Celsius (okay for both wrf and era)
  satvp = 0.6112*exp((17.67*avg1)/(243.5+avg1))*10.0 ; Saturation vap. press in hPa    
  satmr = 0.622*(satvp/(slp-satvp)) ; Saturation mixing ratio in kg/kg
  delete(avg1)
  avg1 = satmr
  delete(satvp)
  delete(satmr)
  ; now calculate gradient  
  avg1 = avg1 - avg2
  avg1@units = "kg kg-1"
  delete(avg2)
  ; calculate surface saturation mixing ratio
  avg1b  = avg1b-273.15  ; convert sfc temp to Celsius
  satvp = 0.6112*exp((17.67*avg1b)/(243.5+avg1b))*10.0 ; Saturation vap. press in hPa    
  satmr = 0.622*(satvp/(slpb-satvp)) ; Saturation mixing ratio in kg/kg
  delete(avg1b)
  avg1b = satmr
  delete(satvp)
  delete(satmr)
  ; now calculate gradient  
  avg1b = avg1b - avg2b
  avg1b@units = "kg kg-1"
  delete(avg2b)
end if

;;;;;;;;;;
; Interpolate to WRF10 size (if needed)
;;;;;;;;;;
if (tag_1 .eq. "wrf10" .and. tag_1b .ne. "wrf10")then
  print("Interpolating between resolutions")
  ; Make arrays we'll need in interpolation
  avg1b_new = new((/n_sn_1,n_we_1/),"float") 
  avg1b_tmp_1d  = new((/n_tot_1/),"float")
  avg_variance1b_new = new((/n_sn_1,n_we_1/),"float") 
  avg_variance1b_tmp_1d  = new((/n_tot_1/),"float")
  avg_seaice_1b_new = new((/n_sn_1,n_we_1/),"float") 
  avg_seaice_1b_tmp_1d  = new((/n_tot_1/),"float")
  if (isvar("find_field").and.(find_field))then
    avg2b_new = new((/n_sn_1,n_we_1/),"float") 
    avg2b_tmp_1d  = new((/n_tot_1/),"float")
  end if

    avg1b_1d = ndtooned(avg1b(:,:))
    avg_variance1b_1d = ndtooned(avg_variance1b(:,:))
    avg_seaice_1b_1d = ndtooned(avg_seaice_1b(:,:))
    if (isvar("find_field").and.(find_field))then
      avg2b_1d = ndtooned(avg2b(:,:))
    end if
    do i = 0, n_tot_1 - 1
      indices_all = interp_ind(i,:)
      n_indices = num(.not.ismissing(indices_all))
      if (n_indices .ne. 0.0) then
        indices = indices_all(0:n_indices-1)
        weight_all = interp_wgt(i,:)
        weight = weight_all(0:n_indices-1)
        avg1b_tmp_1d(i) = sum(avg1b_1d(indices)*weight/sum(weight))
        avg_variance1b_tmp_1d(i) = sum(avg_variance1b_1d(indices)*weight/sum(weight))
        avg_seaice_1b_tmp_1d(i) = sum(avg_seaice_1b_1d(indices)*weight/sum(weight))
        if (isvar("find_field").and.(find_field))then
          avg2b_tmp_1d(i) = sum(avg2b_1d(indices)*weight/sum(weight))
        end if
        delete(indices)
        delete(weight)
      end if
    end do
    ; redimensionalize
    avg1b_new(:,:) = onedtond(avg1b_tmp_1d,(/n_sn_1,n_we_1/))
    avg_variance1b_new(:,:) = onedtond(avg_variance1b_tmp_1d,(/n_sn_1,n_we_1/))
    avg_seaice_1b_new(:,:) = onedtond(avg_seaice_1b_tmp_1d,(/n_sn_1,n_we_1/))

    if (isvar("find_field").and.(find_field))then
      avg2b_new(:,:) = onedtond(avg2b_tmp_1d,(/n_sn_1,n_we_1/))
      delete(avg2b)
      avg2b = avg2b_new
      delete(avg2b_new)
      copy_VarMeta(avg2,avg2b)
    end if

  delete(avg1b)
  delete(avg_variance1b)
  delete(avg_seaice_1b)
  avg1b = avg1b_new
  avg_variance1b = avg_variance1b_new
  avg_seaice_1b = avg_seaice_1b_new
  delete(avg1b_new)
  delete(avg_variance1b_new)
  delete(avg_seaice_1b_new)
  copy_VarMeta(avg1, avg1b)
  copy_VarCoords(avg1,avg1b)
  copy_VarMeta(avg_variance1, avg_variance1b)
  copy_VarCoords(avg_variance1,avg_variance1b)
  copy_VarMeta(avg_seaice_1, avg_seaice_1b)
  copy_VarCoords(avg_seaice_1,avg_seaice_1b)
  avg1b@_FillValue = fill
  avg_variance1b@_FillValue = fill
  avg_seaice_1b@_FillValue = fill
end if

print("Masking terrain - net")
  ; mask terrain - focus on ocean
  avg1(:,:) = where(z_sfc_1 .lt. 50., avg1(:,:), avg1@_FillValue)
  avg1b(:,:) = where(z_sfc_1 .lt. 50., avg1b(:,:), avg1b@_FillValue)
  avg_seaice_1(:,:) = where(z_sfc_1 .lt. 50., avg_seaice_1(:,:), avg_seaice_1@_FillValue)
  avg_seaice_1b(:,:) = where(z_sfc_1 .lt. 50., avg_seaice_1b(:,:), avg_seaice_1b@_FillValue)

  ; mask lat/lons - focus on S. Greenland region
  avg1(:,:) = where(lat2d_1 .gt. 55. .and. lat2d_1 .lt. 71. .and. lon2d_1 .lt. -19. .and. lon2d_1 .gt. -55., avg1(:,:), avg1@_FillValue)
  avg1b(:,:) = where(lat2d_1 .gt. 55. .and. lat2d_1 .lt. 71. .and. lon2d_1 .lt. -19. .and. lon2d_1 .gt. -55., avg1b(:,:), avg1b@_FillValue)
  avg_seaice_1(:,:) = where(lat2d_1 .gt. 55. .and. lat2d_1 .lt. 71. .and. lon2d_1 .lt. -19. .and. lon2d_1 .gt. -55., avg_seaice_1(:,:), avg_seaice_1@_FillValue)
  avg_seaice_1b(:,:) = where(lat2d_1 .gt. 55. .and. lat2d_1 .lt. 71. .and. lon2d_1 .lt. -19. .and. lon2d_1 .gt. -55., avg_seaice_1b(:,:), avg_seaice_1b@_FillValue)

;;;;;;;;;;
; Find difference
;;;;;;;;;;
if (isvar("find_field").and.(find_field)) then
  ; find wind field speed post interpolation
  avg_u1 = avg1
  avg_v1 = avg2
  avg_u1b = avg1b
  avg_v1b = avg2b
  avg1 = sqrt(avg1^2+avg2^2)
  avg1b = sqrt(avg1b^2+avg2b^2)
  avg1@long_name = "Net Wind Field"
  avg1@standard_name = "Wind Field"
  delete(avg2)
  delete(avg2b)
end if

; for precip and mixing ratio fields, make %diff field instead
avg_diff = avg1 - avg1b
title_diff = "Diff: ("+datatitle1+" - "+datatitle1b+")"

; assign lat/lon info
avg1@lat2d = lat2d_1
avg1@lon2d = lon2d_1
avg1b@lat2d = lat2d_1
avg1b@lon2d = lon2d_1
avg_diff@lat2d = lat2d_1
avg_diff@lon2d = lon2d_1
avg_seaice_1@lat2d = lat2d_1
avg_seaice_1@lon2d = lon2d_1
avg_seaice_1b@lat2d = lat2d_1
avg_seaice_1b@lon2d = lon2d_1

if (isvar("find_field").and.(find_field))then
  avg_u1@lat2d = lat2d_1
  avg_u1@lon2d = lon2d_1
  copy_VarMeta(avg_u1,avg_v1)
  copy_VarMeta(avg_u1,avg_u1b)
  copy_VarMeta(avg_u1,avg_v1b)
end if

; prints together the variable title (set above for each type of data) with title1 (defined in cshell as the wrf or met info) and the max and min values
  print(vartitle1+" min: "+min(avg_diff)+"  max: "+max(avg_diff)) 

;;;;;;;;;;
; Calculate statistical significance
;;;;;;;;;;
; Uses student's t-test. If the probability is less than 0.1 then we know at a 90% confidence level
; that the two means are statistically significant.

avg_prob = 100.*(1. - ttest(avg1,avg_variance1,obs_1, avg1b,avg_variance1b,obs_1, False, False))
avg_prob@lat2d = lat2d_1
avg_prob@lon2d = lon2d_1

; make mask of points that are statistically significant at 95% level
mask_95_prob = where(avg_prob .gt. 95. , 1, fill)

print("completed calculations with net avg files")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Calculate percent contributions to net avg
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Calculate percent contribution for each term
term1_pcnt = avg((term1_sum*mask_95_prob)/avg_diff)*100.
term2_pcnt = avg((term2_sum*mask_95_prob)/avg_diff)*100.
term3_pcnt = avg((term3_sum*mask_95_prob)/avg_diff)*100.
term_total_pcnt = term1_pcnt + term2_pcnt + term3_pcnt
print("Total term contribution = "+term_total_pcnt)

; get percents for groups
group1_pcnt = avg((net_group1*mask_95_prob)/avg_diff)*100.
term1_group1_pcnt = avg((term1_sum_group1*mask_95_prob)/net_group1)*100.
term2_group1_pcnt = avg((term2_sum_group1*mask_95_prob)/net_group1)*100.
term3_group1_pcnt = avg((term3_sum_group1*mask_95_prob)/net_group1)*100.
group2_pcnt = avg((net_group2*mask_95_prob)/avg_diff)*100.
term1_group2_pcnt = avg((term1_sum_group2*mask_95_prob)/net_group2)*100.
term2_group2_pcnt = avg((term2_sum_group2*mask_95_prob)/net_group2)*100.
term3_group2_pcnt = avg((term3_sum_group2*mask_95_prob)/net_group2)*100.
group3_pcnt = avg((net_group3*mask_95_prob)/avg_diff)*100.
term1_group3_pcnt = avg((term1_sum_group3*mask_95_prob)/net_group3)*100.
term2_group3_pcnt = avg((term2_sum_group3*mask_95_prob)/net_group3)*100.
term3_group3_pcnt = avg((term3_sum_group3*mask_95_prob)/net_group3)*100.
group4_pcnt = avg((net_group4*mask_95_prob)/avg_diff)*100.
term1_group4_pcnt = avg((term1_sum_group4*mask_95_prob)/net_group4)*100.
term2_group4_pcnt = avg((term2_sum_group4*mask_95_prob)/net_group4)*100.
term3_group4_pcnt = avg((term3_sum_group4*mask_95_prob)/net_group4)*100.
group5_pcnt = avg((net_group5*mask_95_prob)/avg_diff)*100.
term1_group5_pcnt = avg((term1_sum_group5*mask_95_prob)/net_group5)*100.
term2_group5_pcnt = avg((term2_sum_group5*mask_95_prob)/net_group5)*100.
term3_group5_pcnt = avg((term3_sum_group5*mask_95_prob)/net_group5)*100.
group6_pcnt = avg((net_group6*mask_95_prob)/avg_diff)*100.
term1_group6_pcnt = avg((term1_sum_group6*mask_95_prob)/net_group6)*100.
term2_group6_pcnt = avg((term2_sum_group6*mask_95_prob)/net_group6)*100.
term3_group6_pcnt = avg((term3_sum_group6*mask_95_prob)/net_group6)*100.
group7_pcnt = avg((net_group7*mask_95_prob)/avg_diff)*100.
term1_group7_pcnt = avg((term1_sum_group7*mask_95_prob)/net_group7)*100.
term2_group7_pcnt = avg((term2_sum_group7*mask_95_prob)/net_group7)*100.
term3_group7_pcnt = avg((term3_sum_group7*mask_95_prob)/net_group7)*100.
group8_pcnt = avg((net_group8*mask_95_prob)/avg_diff)*100.
term1_group8_pcnt = avg((term1_sum_group8*mask_95_prob)/net_group8)*100.
term2_group8_pcnt = avg((term2_sum_group8*mask_95_prob)/net_group8)*100.
term3_group8_pcnt = avg((term3_sum_group8*mask_95_prob)/net_group8)*100.

; Calculate percent contribution for each node (sum of all terms and terms individually)
nodes_all_pcnt = new((/nnode/),"float")
nodes_term1_pcnt = new((/nnode/),"float")
nodes_term2_pcnt = new((/nnode/),"float")
nodes_term3_pcnt = new((/nnode/),"float")

total_pcnt = 0.0
do n = 0, nnode - 1
  nodes_all_pcnt(n) = avg((nodes_sum_all(n,:,:)*mask_95_prob)/avg_diff)*100.
  total_pcnt = total_pcnt + nodes_all_pcnt(n)
  ; each term individually
  nodes_term1_pcnt(n) = avg((term1(n,:,:)*mask_95_prob)/avg_diff)*100.
  nodes_term2_pcnt(n) = avg((term2(n,:,:)*mask_95_prob)/avg_diff)*100.
  nodes_term3_pcnt(n) = avg((term3(n,:,:)*mask_95_prob)/avg_diff)*100.
end do
print("Total nodes contribution = "+total_pcnt)
delete(total_pcnt)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Processing all graphs for "+varcode)
; create plots!
; plot 1 - 4 panel with total winter difference and sum for each term of difference  w/%contribution - group1
; plot 2 - 4 panel with total winter difference and sum for each term of difference  w/%contribution - group2
; plot 3 - 4 panel with total winter difference and sum for each term of difference  w/%contribution - group3
; plot 4 - 4 panel with total winter difference and sum for each term of difference  w/%contribution - group4
; plot 5 - 4 panel with total winter difference and sum for each term of difference  w/%contribution - group5
; plot 6 - 4 panel with total winter difference and sum for each term of difference  w/%contribution - group6
; plot 7 - 4 panel with total winter difference and sum for each term of difference  w/%contribution - group7
; plot 8 - 4 panel with total winter difference and sum for each term of difference  w/%contribution - group8
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; set outdir and fout names
outdir = "./"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 01 - Net difference and difference terms - group1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot01").and.(plot01))then  ; if plotting is turned on
print("Plot 01 - net difference and frequency/node terms - group1")
fout01   = varcode+"_net_difference_contributing_terms-"+datatitle1+"_"+datatitle1b+"-group1"

  wks01 = gsn_open_wks("ps" ,fout01)
  additional_colors = (/"black","gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks01,colormap,additional_colors)
  plot = new(4, graphic)

;;;;;;;;;;;;;
; Set resources for variable plots
;;;;;;;;;;;;

  res                             = True              ; plot mods desired
  ;res@gsnRightString              = ""
  ;res@gsnLeftString               = ""               ; Set this in loop
  res@gsnFrame                    = False             ; Do not draw plot 
  res@gsnDraw                     = False             ; Do not advance fr
  res@gsnAddCyclic                = False             ; regional - not cyclic
  res@gsnMaximize                 = True              ; Make it as big as possible
  res@mpProjection                = "Stereographic"   ; map projection
  res@mpCenterLonF                = -30.             ; set the center lat/lon
  res@mpCenterLatF                = 63.               
  res@mpGridAndLimbOn             = True             ; Turn on lat/lon grid
  res@mpGridLineDashPattern       = 2                ; Change dash pattern
  res@mpFillOn                    = True             ; Enables map fill
  res@mpGeophysicalLineColor      = "black"          ; Color of continents
  res@mpGeophysicalLineThicknessF = 1.5              ; Make continents thinner
 
  if (isvar("zoom").and.(zoom))then
    res@mpLimitMode                 = "LatLon"	     ; how to zoom in on map
    res@mpMinLatF                   = 56.              ; set the minimum latitude 
    res@mpMaxLatF                   = 72.              ; set the maximum latitude 
    res@mpMinLonF                   = -54.0            ; set the minimum longitude 
    res@mpMaxLonF                   = -15.0            ; set the maximum longitude 
  end if
  if (isvar("zoom2").and.(zoom2))then
    res@mpLimitMode                 = "LatLon"	     ; how to zoom in on map
    res@mpMinLatF                   = 56.              ; set the minimum latitude 
    res@mpMaxLatF                   = 70.              ; set the maximum latitude 
    res@mpMinLonF                   = -54.0            ; set the minimum longitude 
    res@mpMaxLonF                   = -20.0            ; set the maximum longitude 
  end if

  ; set contour information
  res@cnFillMode                 = cntype
  res@cnFillOn                   = True              ; turn on filled contours
  res@gsnSpreadColors            = True              ; use full colormap
  res@gsnSpreadColorStart        = spreadstart2      ; start at color specified for each variable above
  res@gsnSpreadColorEnd          = spreadend2        ; end at color specified above
  res@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  res@cnMinLevelValF             = cmin2             ; set min contour level specified above
  res@cnMaxLevelValF             = cmax2             ; set max contour level specified above
  res@cnLevelSpacingF            = clev2             ; set contour spacing specified above
  res@lbLabelStride              = stride2
  res@cnLinesOn                  = plotlines         ; contour lines specified above
  res@cnLineLabelsOn             = plotlines         ; line labels on specified above
  res@cnMissingValFillColor      = "gray85"          ; missing value color
  res@cnMissingValFillPattern    = 0                 ; fill in
  res@cnMissingValPerimOn        = True
  res@cnMissingValPerimColor     = "black"
  res@lbLabelBarOn               = True ;False             ; single label bar for whole plot

; set resources for 95% statistical significance overlay
  res_95                            = True               ; reset options
  res_95@gsnLeftString              = ""
  res_95@gsnRightString             = ""
  res_95@gsnFrame                   = False             ; Do not draw plot 
  res_95@gsnDraw                    = False             ; Do not advance fr
  res_95@cnInfoLabelOn              = False             ; Turn off info on contours at bottom
  res_95@cnFillOn                   = True             ; turn on filled contours
  res_95@cnMonoFillColor            = True
  res_95@cnMonoFillPattern          = False
  res_95@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  res_95@cnMinLevelValF             = 0.                ; set min contour level specified above
  res_95@cnMaxLevelValF             = 95.              ; set max contour level specified above
  res_95@cnLevelSpacingF            = 95.              ; set contour spacing specified above
  res_95@cnFillPatterns             = (/-1,-1,17/)      ; stipling over areas where >99% sig. diff
  res_95@lbLabelBarOn               = False             ; have single label bar
 
  opts = res
  opts@cnMinLevelValF             = cmin2/4.0             ; set min contour level specified above
  opts@cnMaxLevelValF             = cmax2/4.0             ; set max contour level specified above
  opts@cnLevelSpacingF            = clev2/4.0             ; set contour spacing specified above 

;;;;;;;;;;;;;
; Make plot 0 - net difference
;;;;;;;;;;;;;
  title0 = "Net difference For Group1"
  opts0 = res
  opts0@gsnLeftString              = "Group1 contribution to overall difference"
  opts0@gsnRightString             = sprintf("%5.2f",group1_pcnt)+"%"
  opts0@tiMainString               = title0            ; title string specified from cshell
  cplot0  = gsn_csm_contour_map(wks01,net_group1,opts0)
  cplot0b = gsn_csm_contour(wks01,avg_prob,res_95)          ; add 95% stat sig
  overlay(cplot0,cplot0b)
  plot(0) = cplot0
  delete(opts0)

;;;;;;;;;;;;;
; Make plot 1 - Frequency difference term
;;;;;;;;;;;;;
  title1 = "Frequency Component"
  opts@gsnLeftString              = "Contribution to Group1 Net difference"
  opts@gsnRightString             = sprintf("%5.2f",term1_group1_pcnt)+"%"
  opts@tiMainString               = title1            ; title string specified from cshell
  cplot1  = gsn_csm_contour_map(wks01,term1_sum_group1,opts)
  plot(1) = cplot1
  delete(opts@gsnRightString)
  delete(opts@tiMainString)
  
;;;;;;;;;;;;;
; Make plot 2 - Difference in nodes
;;;;;;;;;;;;;
  title2 = "Intrapattern Variability Component"
  opts@gsnLeftString              = "Contribution to Group1 Net difference"
  opts@gsnRightString             = sprintf("%5.2f",term2_group1_pcnt)+"%"
  opts@tiMainString               = title2            ; title string specified from cshell
  cplot2  = gsn_csm_contour_map(wks01,term2_sum_group1,opts)
  plot(2) = cplot2
  delete(opts@gsnRightString)
  delete(opts@tiMainString)

;;;;;;;;;;;;;
; Make plot 3 - Combined term
;;;;;;;;;;;;;
  title3 = "Combined Component"
  opts@gsnLeftString              = "Contribution to Group1 Net difference"
  opts@gsnRightString             = sprintf("%5.2f",term3_group1_pcnt)+"%"
  opts@tiMainString               = title3            ; title string specified from cshell
  cplot3  = gsn_csm_contour_map(wks01,term3_sum_group1,opts)
  plot(3) = cplot3
  delete(opts@gsnRightString)
  delete(opts@tiMainString)

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
title_fin = vartitle1 + " Diff ("+var1@units+") ~C~ Group1 - Northeasterly flow"

  res_pan                            = True
  res_pan@txString                   = title_fin        ; main title
  res_pan@txFontHeightF              = 0.02
  res_pan@gsnPaperOrientation        = "landscape"      ; landscape mode
  res_pan@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  res_pan@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  res_pan@gsnPanelScalePlotIndex     = 1
  res_pan@gsnMaximize                = True	       ; fill the page
;  res_pan@gsnPanelLabelBar           = True
;  res_pan@lbTitleString              = var1@units
;  res_pan@lbTitlePosition            = "right"
;  res_pan@lbLabelStride              = stride2
;  res_pan@lbLabelFontHeightF         = 0.01
;  res_pan@lbTitleJust                = "CenterLeft"
;  res_pan@lbTitleFontHeightF         = 0.01
;  res_pan@lbTitleDirection           = "Across"
  gsn_panel(wks01,(/plot/),(/2,2/),res_pan)               ; create final panel plot

  print("converting plot 1 to png")
; convert to png 
  convert_cmd = "convert -density 300 "+fout01+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout01+".png"

  system(convert_cmd)

delete(res_pan)
delete(plot)
delete(additional_colors)
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 02 - Net difference and difference terms - group2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot02").and.(plot02))then  ; if plotting is turned on
print("Plot 02 - net difference and frequency/node terms - group2")
fout02   = varcode+"_net_difference_contributing_terms-"+datatitle1+"_"+datatitle1b+"-group2"

  wks02 = gsn_open_wks("ps" ,fout02)
  additional_colors = (/"black","gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks02,colormap,additional_colors)
  plot = new(4, graphic)

; keep previous resources

;;;;;;;;;;;;;
; Make plot 0 - net difference
;;;;;;;;;;;;;
  title0 = "Net difference For Group2"
  opts0 = res
  opts0@gsnLeftString              = "Group2 contribution to overall difference"
  opts0@gsnRightString             = sprintf("%5.2f",group2_pcnt)+"%"
  opts0@tiMainString               = title0            ; title string specified from cshell
  cplot0  = gsn_csm_contour_map(wks02,net_group2,opts0)
  cplot0b = gsn_csm_contour(wks02,avg_prob,res_95)          ; add 95% stat sig
  overlay(cplot0,cplot0b)
  plot(0) = cplot0
  delete(opts0)

;;;;;;;;;;;;;
; Make plot 1 - Frequency difference term
;;;;;;;;;;;;;
  title1 = "Frequency Component"
  opts@gsnLeftString              = "Contribution to Group2 Net difference"
  opts@gsnRightString             = sprintf("%5.2f",term1_group2_pcnt)+"%"
  opts@tiMainString               = title1            ; title string specified from cshell
  cplot1  = gsn_csm_contour_map(wks02,term1_sum_group2,opts)
  plot(1) = cplot1
  delete(opts@gsnRightString)
  delete(opts@tiMainString)
  
;;;;;;;;;;;;;
; Make plot 2 - Difference in nodes
;;;;;;;;;;;;;
  title2 = "Intrapattern Variability Component"
  opts@gsnLeftString              = "Contribution to Group2 Net difference"
  opts@gsnRightString             = sprintf("%5.2f",term2_group2_pcnt)+"%"
  opts@tiMainString               = title2            ; title string specified from cshell
  cplot2  = gsn_csm_contour_map(wks02,term2_sum_group2,opts)
  plot(2) = cplot2
  delete(opts@gsnRightString)
  delete(opts@tiMainString)

;;;;;;;;;;;;;
; Make plot 3 - Combined term
;;;;;;;;;;;;;
  title3 = "Combined Component"
  opts@gsnLeftString              = "Contribution to Group2 Net difference"
  opts@gsnRightString             = sprintf("%5.2f",term3_group2_pcnt)+"%"
  opts@tiMainString               = title3            ; title string specified from cshell
  cplot3  = gsn_csm_contour_map(wks02,term3_sum_group2,opts)
  plot(3) = cplot3
  delete(opts@gsnRightString)
  delete(opts@tiMainString)

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
title_fin = vartitle1 + " Diff ("+var1@units+") ~C~ Group2 - Northeasterly flow in Denmark Strait"

  res_pan                            = True
  res_pan@txString                   = title_fin        ; main title
  res_pan@txFontHeightF              = 0.02
  res_pan@gsnPaperOrientation        = "landscape"      ; landscape mode
  res_pan@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  res_pan@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  res_pan@gsnPanelScalePlotIndex     = 1
  res_pan@gsnMaximize                = True	       ; fill the page
  gsn_panel(wks02,(/plot/),(/2,2/),res_pan)               ; create final panel plot

  print("converting plot 02 to png")
; convert to png 
  convert_cmd = "convert -density 300 "+fout02+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout02+".png"

  system(convert_cmd)

delete(res_pan)
delete(plot)
delete(additional_colors)
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 03 - Net difference and difference terms - group3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot03").and.(plot03))then  ; if plotting is turned on
print("Plot 03 - net difference and frequency/node terms - group3")
fout03   = varcode+"_net_difference_contributing_terms-"+datatitle1+"_"+datatitle1b+"-group3"

  wks03 = gsn_open_wks("ps" ,fout03)
  additional_colors = (/"black","gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks03,colormap,additional_colors)
  plot = new(4, graphic)

; keep previous resources

;;;;;;;;;;;;;
; Make plot 0 - net difference
;;;;;;;;;;;;;
  title0 = "Net difference For Group3"
  opts0 = res
  opts0@gsnLeftString              = "Group3 contribution to overall difference"
  opts0@gsnRightString             = sprintf("%5.2f",group3_pcnt)+"%"
  opts0@tiMainString               = title0            ; title string specified from cshell
  cplot0  = gsn_csm_contour_map(wks03,net_group3,opts0)
  cplot0b = gsn_csm_contour(wks03,avg_prob,res_95)          ; add 95% stat sig
  overlay(cplot0,cplot0b)
  plot(0) = cplot0
  delete(opts0)

;;;;;;;;;;;;;
; Make plot 1 - Frequency difference term
;;;;;;;;;;;;;
  title1 = "Frequency Component"
  opts@gsnLeftString              = "Contribution to Group3 Net difference"
  opts@gsnRightString             = sprintf("%5.2f",term1_group3_pcnt)+"%"
  opts@tiMainString               = title1            ; title string specified from cshell
  cplot1  = gsn_csm_contour_map(wks03,term1_sum_group3,opts)
  plot(1) = cplot1
  delete(opts@gsnRightString)
  delete(opts@tiMainString)
  
;;;;;;;;;;;;;
; Make plot 2 - Difference in nodes
;;;;;;;;;;;;;
  title2 = "Intrapattern Variability Component"
  opts@gsnLeftString              = "Contribution to Group3 Net difference"
  opts@gsnRightString             = sprintf("%5.2f",term2_group3_pcnt)+"%"
  opts@tiMainString               = title2            ; title string specified from cshell
  cplot2  = gsn_csm_contour_map(wks03,term2_sum_group3,opts)
  plot(2) = cplot2
  delete(opts@gsnRightString)
  delete(opts@tiMainString)

;;;;;;;;;;;;;
; Make plot 3 - Combined term
;;;;;;;;;;;;;
  title3 = "Combined Component"
  opts@gsnLeftString              = "Contribution to Group3 Net difference"
  opts@gsnRightString             = sprintf("%5.2f",term3_group3_pcnt)+"%"
  opts@tiMainString               = title3            ; title string specified from cshell
  cplot3  = gsn_csm_contour_map(wks03,term3_sum_group3,opts)
  plot(3) = cplot3
  delete(opts@gsnRightString)
  delete(opts@tiMainString)

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
title_fin = vartitle1 + " Diff ("+var1@units+") ~C~ Group3 - Westerly Tip Jet with Barrier Flow"

  res_pan                            = True
  res_pan@txString                   = title_fin        ; main title
  res_pan@txFontHeightF              = 0.02
  res_pan@gsnPaperOrientation        = "landscape"      ; landscape mode
  res_pan@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  res_pan@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  res_pan@gsnPanelScalePlotIndex     = 1
  res_pan@gsnMaximize                = True	       ; fill the page
  gsn_panel(wks03,(/plot/),(/2,2/),res_pan)               ; create final panel plot

  print("converting plot 03 to png")
; convert to png 
  convert_cmd = "convert -density 300 "+fout03+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout03+".png"

  system(convert_cmd)

delete(res_pan)
delete(plot)
delete(additional_colors)
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 04 - Net difference and difference terms - group4
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot04").and.(plot04))then  ; if plotting is turned on
print("Plot 04 - net difference and frequency/node terms - group4")
fout04   = varcode+"_net_difference_contributing_terms-"+datatitle1+"_"+datatitle1b+"-group4"

  wks04 = gsn_open_wks("ps" ,fout04)
  additional_colors = (/"black","gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks04,colormap,additional_colors)
  plot = new(4, graphic)

; keep previous resources

;;;;;;;;;;;;;
; Make plot 0 - net difference
;;;;;;;;;;;;;
  title0 = "Net difference For Group4"
  opts0 = res
  opts0@gsnLeftString              = "Group4 contribution to overall difference"
  opts0@gsnRightString             = sprintf("%5.2f",group4_pcnt)+"%"
  opts0@tiMainString               = title0            ; title string specified from cshell
  cplot0  = gsn_csm_contour_map(wks04,net_group4,opts0)
  cplot0b = gsn_csm_contour(wks04,avg_prob,res_95)          ; add 95% stat sig
  overlay(cplot0,cplot0b)
  plot(0) = cplot0
  delete(opts0)

;;;;;;;;;;;;;
; Make plot 1 - Frequency difference term
;;;;;;;;;;;;;
  title1 = "Frequency Component"
  opts@gsnLeftString              = "Contribution to Group4 Net difference"
  opts@gsnRightString             = sprintf("%5.2f",term1_group4_pcnt)+"%"
  opts@tiMainString               = title1            ; title string specified from cshell
  cplot1  = gsn_csm_contour_map(wks04,term1_sum_group4,opts)
  plot(1) = cplot1
  delete(opts@gsnRightString)
  delete(opts@tiMainString)
  
;;;;;;;;;;;;;
; Make plot 2 - Difference in nodes
;;;;;;;;;;;;;
  title2 = "Intrapattern Variability Component"
  opts@gsnLeftString              = "Contribution to Group4 Net difference"
  opts@gsnRightString             = sprintf("%5.2f",term2_group4_pcnt)+"%"
  opts@tiMainString               = title2            ; title string specified from cshell
  cplot2  = gsn_csm_contour_map(wks04,term2_sum_group4,opts)
  plot(2) = cplot2
  delete(opts@gsnRightString)
  delete(opts@tiMainString)

;;;;;;;;;;;;;
; Make plot 3 - Combined term
;;;;;;;;;;;;;
  title3 = "Combined Component"
  opts@gsnLeftString              = "Contribution to Group4 Net difference"
  opts@gsnRightString             = sprintf("%5.2f",term3_group4_pcnt)+"%"
  opts@tiMainString               = title3            ; title string specified from cshell
  cplot3  = gsn_csm_contour_map(wks04,term3_sum_group4,opts)
  plot(3) = cplot3
  delete(opts@gsnRightString)
  delete(opts@tiMainString)

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
title_fin = vartitle1 + " Diff ("+var1@units+") ~C~ Group4 - Strong Westerly Tip Jet with Barrier Flow"

  res_pan                            = True
  res_pan@txString                   = title_fin        ; main title
  res_pan@txFontHeightF              = 0.02
  res_pan@gsnPaperOrientation        = "landscape"      ; landscape mode
  res_pan@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  res_pan@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  res_pan@gsnPanelScalePlotIndex     = 1
  res_pan@gsnMaximize                = True	       ; fill the page
  gsn_panel(wks04,(/plot/),(/2,2/),res_pan)               ; create final panel plot

  print("converting plot 04 to png")
; convert to png 
  convert_cmd = "convert -density 300 "+fout04+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout04+".png"

  system(convert_cmd)

delete(res_pan)
delete(plot)
delete(additional_colors)
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 05 - Net difference and difference terms - group5
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot05").and.(plot05))then  ; if plotting is turned on
print("Plot 05 - net difference and frequency/node terms - group5")
fout05   = varcode+"_net_difference_contributing_terms-"+datatitle1+"_"+datatitle1b+"-group5"

  wks05 = gsn_open_wks("ps" ,fout05)
  additional_colors = (/"black","gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks05,colormap,additional_colors)
  plot = new(4, graphic)

; keep previous resources

;;;;;;;;;;;;;
; Make plot 0 - net difference
;;;;;;;;;;;;;
  title0 = "Net difference For Group5"
  opts0 = res
  opts0@gsnLeftString              = "Group5 contribution to overall difference"
  opts0@gsnRightString             = sprintf("%5.2f",group5_pcnt)+"%"
  opts0@tiMainString               = title0            ; title string specified from cshell
  cplot0  = gsn_csm_contour_map(wks05,net_group5,opts0)
  cplot0b = gsn_csm_contour(wks05,avg_prob,res_95)          ; add 95% stat sig
  overlay(cplot0,cplot0b)
  plot(0) = cplot0
  delete(opts0)

;;;;;;;;;;;;;
; Make plot 1 - Frequency difference term
;;;;;;;;;;;;;
  title1 = "Frequency Component"
  opts@gsnLeftString              = "Contribution to Group5 Net difference"
  opts@gsnRightString             = sprintf("%5.2f",term1_group5_pcnt)+"%"
  opts@tiMainString               = title1            ; title string specified from cshell
  cplot1  = gsn_csm_contour_map(wks05,term1_sum_group5,opts)
  plot(1) = cplot1
  delete(opts@gsnRightString)
  delete(opts@tiMainString)
  
;;;;;;;;;;;;;
; Make plot 2 - Difference in nodes
;;;;;;;;;;;;;
  title2 = "Intrapattern Variability Component"
  opts@gsnLeftString              = "Contribution to Group5 Net difference"
  opts@gsnRightString             = sprintf("%5.2f",term2_group5_pcnt)+"%"
  opts@tiMainString               = title2            ; title string specified from cshell
  cplot2  = gsn_csm_contour_map(wks05,term2_sum_group5,opts)
  plot(2) = cplot2
  delete(opts@gsnRightString)
  delete(opts@tiMainString)

;;;;;;;;;;;;;
; Make plot 3 - Combined term
;;;;;;;;;;;;;
  title3 = "Combined Component"
  opts@gsnLeftString              = "Contribution to Group5 Net difference"
  opts@gsnRightString             = sprintf("%5.2f",term3_group5_pcnt)+"%"
  opts@tiMainString               = title3            ; title string specified from cshell
  cplot3  = gsn_csm_contour_map(wks05,term3_sum_group5,opts)
  plot(3) = cplot3
  delete(opts@gsnRightString)
  delete(opts@tiMainString)

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
title_fin = vartitle1 + " Diff ("+var1@units+") ~C~ Group5 - Strong Easterly Tip Jet"

  res_pan                            = True
  res_pan@txString                   = title_fin        ; main title
  res_pan@txFontHeightF              = 0.02
  res_pan@gsnPaperOrientation        = "landscape"      ; landscape mode
  res_pan@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  res_pan@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  res_pan@gsnPanelScalePlotIndex     = 1
  res_pan@gsnMaximize                = True	       ; fill the page
  gsn_panel(wks05,(/plot/),(/2,2/),res_pan)               ; create final panel plot

  print("converting plot 05 to png")
; convert to png 
  convert_cmd = "convert -density 300 "+fout05+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout05+".png"

  system(convert_cmd)

delete(res_pan)
delete(plot)
delete(additional_colors)
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 06 - Net difference and difference terms - group6
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot06").and.(plot06))then  ; if plotting is turned on
print("Plot 06 - net difference and frequency/node terms - group6")
fout06   = varcode+"_net_difference_contributing_terms-"+datatitle1+"_"+datatitle1b+"-group6"

  wks06 = gsn_open_wks("ps" ,fout06)
  additional_colors = (/"black","gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks06,colormap,additional_colors)
  plot = new(4, graphic)

; keep previous resources

;;;;;;;;;;;;;
; Make plot 0 - net difference
;;;;;;;;;;;;;
  title0 = "Net difference For Group6"
  opts0 = res
  opts0@gsnLeftString              = "Group6 contribution to overall difference"
  opts0@gsnRightString             = sprintf("%5.2f",group6_pcnt)+"%"
  opts0@tiMainString               = title0            ; title string specified from cshell
  cplot0  = gsn_csm_contour_map(wks06,net_group6,opts0)
  cplot0b = gsn_csm_contour(wks06,avg_prob,res_95)          ; add 95% stat sig
  overlay(cplot0,cplot0b)
  plot(0) = cplot0
  delete(opts0)

;;;;;;;;;;;;;
; Make plot 1 - Frequency difference term
;;;;;;;;;;;;;
  title1 = "Frequency Component"
  opts@gsnLeftString              = "Contribution to Group6 Net difference"
  opts@gsnRightString             = sprintf("%5.2f",term1_group6_pcnt)+"%"
  opts@tiMainString               = title1            ; title string specified from cshell
  cplot1  = gsn_csm_contour_map(wks06,term1_sum_group6,opts)
  plot(1) = cplot1
  delete(opts@gsnRightString)
  delete(opts@tiMainString)
  
;;;;;;;;;;;;;
; Make plot 2 - Difference in nodes
;;;;;;;;;;;;;
  title2 = "Intrapattern Variability Component"
  opts@gsnLeftString              = "Contribution to Group6 Net difference"
  opts@gsnRightString             = sprintf("%5.2f",term2_group6_pcnt)+"%"
  opts@tiMainString               = title2            ; title string specified from cshell
  cplot2  = gsn_csm_contour_map(wks06,term2_sum_group6,opts)
  plot(2) = cplot2
  delete(opts@gsnRightString)
  delete(opts@tiMainString)

;;;;;;;;;;;;;
; Make plot 3 - Combined term
;;;;;;;;;;;;;
  title3 = "Combined Component"
  opts@gsnLeftString              = "Contribution to Group6 Net difference"
  opts@gsnRightString             = sprintf("%5.2f",term3_group6_pcnt)+"%"
  opts@tiMainString               = title3            ; title string specified from cshell
  cplot3  = gsn_csm_contour_map(wks06,term3_sum_group6,opts)
  plot(3) = cplot3
  delete(opts@gsnRightString)
  delete(opts@tiMainString)

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
title_fin = vartitle1 + " Diff ("+var1@units+") ~C~ Group6 - Easterly Tip Jet"

  res_pan                            = True
  res_pan@txString                   = title_fin        ; main title
  res_pan@txFontHeightF              = 0.02
  res_pan@gsnPaperOrientation        = "landscape"      ; landscape mode
  res_pan@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  res_pan@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  res_pan@gsnPanelScalePlotIndex     = 1
  res_pan@gsnMaximize                = True	       ; fill the page
  gsn_panel(wks06,(/plot/),(/2,2/),res_pan)               ; create final panel plot

  print("converting plot 06 to png")
; convert to png 
  convert_cmd = "convert -density 300 "+fout06+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout06+".png"

  system(convert_cmd)

delete(res_pan)
delete(plot)
delete(additional_colors)
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 07 - Net difference and difference terms - group7
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot07").and.(plot07))then  ; if plotting is turned on
print("Plot 07 - net difference and frequency/node terms - group7")
fout07   = varcode+"_net_difference_contributing_terms-"+datatitle1+"_"+datatitle1b+"-group7"

  wks07 = gsn_open_wks("ps" ,fout07)
  additional_colors = (/"black","gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks07,colormap,additional_colors)
  plot = new(4, graphic)

; keep previous resources

;;;;;;;;;;;;;
; Make plot 0 - net difference
;;;;;;;;;;;;;
  title0 = "Net difference For Group7"
  opts0 = res
  opts0@gsnLeftString              = "Group7 contribution to overall difference"
  opts0@gsnRightString             = sprintf("%5.2f",group7_pcnt)+"%"
  opts0@tiMainString               = title0            ; title string specified from cshell
  cplot0  = gsn_csm_contour_map(wks07,net_group7,opts0)
  cplot0b = gsn_csm_contour(wks07,avg_prob,res_95)          ; add 95% stat sig
  overlay(cplot0,cplot0b)
  plot(0) = cplot0
  delete(opts0)

;;;;;;;;;;;;;
; Make plot 1 - Frequency difference term
;;;;;;;;;;;;;
  title1 = "Frequency Component"
  opts@gsnLeftString              = "Contribution to Group7 Net difference"
  opts@gsnRightString             = sprintf("%5.2f",term1_group7_pcnt)+"%"
  opts@tiMainString               = title1            ; title string specified from cshell
  cplot1  = gsn_csm_contour_map(wks07,term1_sum_group7,opts)
  plot(1) = cplot1
  delete(opts@gsnRightString)
  delete(opts@tiMainString)
  
;;;;;;;;;;;;;
; Make plot 2 - Difference in nodes
;;;;;;;;;;;;;
  title2 = "Intrapattern Variability Component"
  opts@gsnLeftString              = "Contribution to Group7 Net difference"
  opts@gsnRightString             = sprintf("%5.2f",term2_group7_pcnt)+"%"
  opts@tiMainString               = title2            ; title string specified from cshell
  cplot2  = gsn_csm_contour_map(wks07,term2_sum_group7,opts)
  plot(2) = cplot2
  delete(opts@gsnRightString)
  delete(opts@tiMainString)

;;;;;;;;;;;;;
; Make plot 3 - Combined term
;;;;;;;;;;;;;
  title3 = "Combined Component"
  opts@gsnLeftString              = "Contribution to Group7 Net difference"
  opts@gsnRightString             = sprintf("%5.2f",term3_group7_pcnt)+"%"
  opts@tiMainString               = title3            ; title string specified from cshell
  cplot3  = gsn_csm_contour_map(wks07,term3_sum_group7,opts)
  plot(3) = cplot3
  delete(opts@gsnRightString)
  delete(opts@tiMainString)

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
title_fin = vartitle1 + " Diff ("+var1@units+") ~C~ Group7 - Southerly Flow"

  res_pan                            = True
  res_pan@txString                   = title_fin        ; main title
  res_pan@txFontHeightF              = 0.02
  res_pan@gsnPaperOrientation        = "landscape"      ; landscape mode
  res_pan@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  res_pan@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  res_pan@gsnPanelScalePlotIndex     = 1
  res_pan@gsnMaximize                = True	       ; fill the page
  gsn_panel(wks07,(/plot/),(/2,2/),res_pan)               ; create final panel plot

  print("converting plot 07 to png")
; convert to png 
  convert_cmd = "convert -density 300 "+fout07+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout07+".png"

  system(convert_cmd)

delete(res_pan)
delete(plot)
delete(additional_colors)
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 08 - Net difference and difference terms - group8
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot08").and.(plot08))then  ; if plotting is turned on
print("Plot 08 - net difference and frequency/node terms - group8")
fout08   = varcode+"_net_difference_contributing_terms-"+datatitle1+"_"+datatitle1b+"-group8"

  wks08 = gsn_open_wks("ps" ,fout08)
  additional_colors = (/"black","gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks08,colormap,additional_colors)
  plot = new(4, graphic)

; keep previous resources

;;;;;;;;;;;;;
; Make plot 0 - net difference
;;;;;;;;;;;;;
  title0 = "Net difference For Group8"
  opts0 = res
  opts0@gsnLeftString              = "Group8 contribution to overall difference"
  opts0@gsnRightString             = sprintf("%5.2f",group8_pcnt)+"%"
  opts0@tiMainString               = title0            ; title string specified from cshell
  cplot0  = gsn_csm_contour_map(wks08,net_group8,opts0)
  cplot0b = gsn_csm_contour(wks08,avg_prob,res_95)          ; add 95% stat sig
  overlay(cplot0,cplot0b)
  plot(0) = cplot0
  delete(opts0)

;;;;;;;;;;;;;
; Make plot 1 - Frequency difference term
;;;;;;;;;;;;;
  title1 = "Frequency Component"
  opts@gsnLeftString              = "Contribution to Group8 Net difference"
  opts@gsnRightString             = sprintf("%5.2f",term1_group8_pcnt)+"%"
  opts@tiMainString               = title1            ; title string specified from cshell
  cplot1  = gsn_csm_contour_map(wks08,term1_sum_group8,opts)
  plot(1) = cplot1
  delete(opts@gsnRightString)
  delete(opts@tiMainString)
  
;;;;;;;;;;;;;
; Make plot 2 - Difference in nodes
;;;;;;;;;;;;;
  title2 = "Intrapattern Variability Component"
  opts@gsnLeftString              = "Contribution to Group8 Net difference"
  opts@gsnRightString             = sprintf("%5.2f",term2_group8_pcnt)+"%"
  opts@tiMainString               = title2            ; title string specified from cshell
  cplot2  = gsn_csm_contour_map(wks08,term2_sum_group8,opts)
  plot(2) = cplot2
  delete(opts@gsnRightString)
  delete(opts@tiMainString)

;;;;;;;;;;;;;
; Make plot 3 - Combined term
;;;;;;;;;;;;;
  title3 = "Combined Component"
  opts@gsnLeftString              = "Contribution to Group8 Net difference"
  opts@gsnRightString             = sprintf("%5.2f",term3_group8_pcnt)+"%"
  opts@tiMainString               = title3            ; title string specified from cshell
  cplot3  = gsn_csm_contour_map(wks08,term3_sum_group8,opts)
  plot(3) = cplot3
  delete(opts@gsnRightString)
  delete(opts@tiMainString)

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
title_fin = vartitle1 + " Diff ("+var1@units+") ~C~ Group8 - Westery Tip Jet without Barrier Flow"

  res_pan                            = True
  res_pan@txString                   = title_fin        ; main title
  res_pan@txFontHeightF              = 0.02
  res_pan@gsnPaperOrientation        = "landscape"      ; landscape mode
  res_pan@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  res_pan@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  res_pan@gsnPanelScalePlotIndex     = 1
  res_pan@gsnMaximize                = True	       ; fill the page
  gsn_panel(wks08,(/plot/),(/2,2/),res_pan)               ; create final panel plot

  print("converting plot 08 to png")
; convert to png 
  convert_cmd = "convert -density 300 "+fout08+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout08+".png"

  system(convert_cmd)

delete(res_pan)
delete(plot)
delete(additional_colors)
end if





print("Completed all plots for "+varcode)
print("Good job!")
;;;;;;;;;;;;;;;;;;;;;; END script
end
