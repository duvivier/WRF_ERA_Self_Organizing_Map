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
;  datatitle1  = "wrf10_200511_200703_6h"
;  datatitle1b = "wrf50_200511_200703_6h"
;  type = "1"  ;1 = "correct" fluxes, 2 = fluxes from nodeavg values
;  varcode = "Tgrad"
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
plot1  = True ; plot 1 - Frequency and frequency differences of all nodes (only needed once)
plot2  = True ; plot 2 - 3 panel of winter average values and difference
plot3  = True ; plot 3 - 3 panel of winter average values and difference using net avg files (w/stat sig)
plot4  = True ; plot 4 - winter average for all nodes of datatitle1
plot5  = True ; plot 5 - winter average for all nodes of datatitle1b
plot6  = True ; plot 6 - winter average difference for all nodes (datatitle1 - datatitle1b)
plot7  = True ; plot 7 - 4 panel with total winter difference and sum for each term of difference  w/%contribution
plot8  = False ; plot 8 - 4 panel with total winter difference and ratio of each term difference to the total
plot9  = True ; plot 9 - all nodes with sum of each term of difference  w/%contribution
plot10 = True ; plot 10 - all nodes with difference term 1  w/%contribution
plot11 = True ; plot 11 - all nodes with difference term 2  w/%contribution
plot12 = True ; plot 12 - all nodes with difference term 3  w/%contribution
plot13 = True ; plot 13 - % contribution of nodes to net difference - sum of terms - simple box plot
plot14 = True ; plot 14 - % contribution of nodes to net difference - individual terms - simple box plot
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
if (varcode.eq."U10")then
  vartitle1 = "Avg 10m Wind speed"
  invar1 = "wspd_10m_avg"
  invar_v = "wspd_10m_var"
  vartype = "2d"
  cmaptype = "wind"
  zoom2 = True
end if
if (varcode.eq."curltau")then
  vartitle1 = "Avg 10m wind stress curl"
  invar1 = "curl_tau_avg"
  invar_v = "curl_tau_var"
  vartype = "2d"
  cmaptype = "curlt"
  zoom2 = True
end if
if (varcode.eq."Tgrad") then
  vartitle1 = "Avg Temp grad (sfc-2m)"
  invar1 = "T_grad_avg"
  invar_v = "T_grad_var"
  vartype = "2d"
  cmaptype = "temp_grad"
  zoom2 = True
end if
if (varcode.eq."T_sfc")then
  vartitle1 = "Avg Sea Sfc Temp"
  invar1 = "SST_avg"
  invar_v = "SST_var"
  vartype = "2d"
  cmaptype = "temperature"
  zoom2 = True
end if
if (varcode.eq."T_2m")then
  vartitle1 = "Avg Temp at 2m"
  invar1 = "T_2m_avg"
  invar_v = "T_2m_var"
  vartype = "2d"
  cmaptype = "temperature"
  zoom2 = True
end if
if (varcode.eq."qgrad") then
  vartitle1 = "Avg Mixing Ratio grad (sfc-2m)"
  invar1 = "q_grad_avg"
  invar_v = "q_grad_var"
  vartype = "2d"
  cmaptype = "mix_grad"
  zoom2 = True
end if
if (varcode.eq."q_sfc")then
  vartitle1 = "Avg Mixing Ratio at sfc"
  invar1 = "q_sfc_avg"
  invar_v = "q_sfc_var"
  vartype = "2d"
  cmaptype = "mix_rad"
  zoom2 = True
end if
if (varcode.eq."q_2m")then
  vartitle1 = "Avg Mixing Ratio at 2m"
  invar1 = "q_2m_avg"
  invar_v = "q_2m_var"
  vartype = "2d"
  cmaptype = "mix_rad"
  zoom2 = True
end if
if (varcode.eq."SH") then
  vartitle1 = "Avg SH Flux at sfc"
  invar1 = "SHFlx_avg"
  invar_v = "SHFlx_var"
  vartype = "2d"
  cmaptype = "shflux"
  zoom2 = True
end if
if (varcode.eq."LH") then
  vartitle1 = "Avg LH Flux at sfc"
  invar1 = "LHFlx_avg"
  invar_v = "LHFlx_var"
  vartype = "2d"
  cmaptype = "lhflux"
  zoom2 = True
end if
if (varcode.eq."TurbFlx") then
  vartitle1 = "Avg Total Turb Flux at sfc"
  invar1 = "Turb_net_avg"
  invar_v = "Turb_net_var"
  vartype = "2d"
  cmaptype = "flux"
  zoom2 = True
end if

; Set the contour interval for each input variable   
; set contour limits manually:
  if (cmaptype.eq."wind") then
    cmin1               = 0.
    cmax1               = 18.
    clev1               = 1.
    stride1             = 2                 ; label stride
    cmin2               = -10.
    cmax2               = 10.
    clev2               = 1.
    stride2             = 2                 ; label stride for diff plot
    cmin3               = 0.
    cmax3               = 22.
    clev3               = 1.
    stride3             = 2                 ; label stride
    cmin4               = -20.
    cmax4               = 20.
    clev4               = 2.
    stride4             = 1                 ; label stride for diff plot
    cmin5               = -1.5
    cmax5               = 1.5
    clev5               = 0.1
    stride5             = 2                 ; label stride for diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False              ; lines for diff plot
    cntype              = "AreaFill"
    spreadstart1        = 2                 ; start at color
    spreadend1          = 35                ; end at color
    spreadstart2        = 37                ; start at color
    spreadend2          = 132               ; end at color
    spreadstart3        = 2                 ; start at color
    spreadend3          = 35                ; end at color
    spreadstart4        = 37                ; start at color
    spreadend4          = 132               ; end at color
    colormap            = "SOM_wind_table"
  end if
  if (cmaptype.eq."curlt") then
    cmin1               = -4.
    cmax1               = 4.
    clev1               = 0.2
    stride1             = 4                 ; label stride
    cmin2               = -3.
    cmax2               = 3.
    clev2               = 0.2
    stride2             = 2                 ; label stride for diff plot
    cmin3               = -5.
    cmax3               = 5.
    clev3               = 0.2
    stride3             = 4                 ; label stride
    cmin4               = -5.
    cmax4               = 5.
    clev4               = 0.2
    stride4             = 4                 ; label stride for diff plot
    cmin5               = -1.0
    cmax5               = 1.0
    clev5               = 0.1
    stride5             = 2                 ; label stride for diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False              ; lines for diff plot
    cntype              = "AreaFill"
    spreadstart1        = 2                 ; start at color
    spreadend1          = 250               ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 250               ; end at color
    spreadstart3        = 2                 ; start at color
    spreadend3          = 250                ; end at color
    spreadstart4        = 2                 ; start at color
    spreadend4          = 250                ; end at color
    colormap            = "BlueYellowRed_mod"
  end if
  if (cmaptype.eq."temp_grad")then
    cmin1               = -10.
    cmax1               = 10.
    clev1               = 1.0
    stride1             = 2                 ; label stride
    cmin2               = -5.
    cmax2               = 5.
    clev2               = 0.5
    stride2             = 2                 ; label stride diff plot
    cmin3               = -7.
    cmax3               = 7.
    clev3               = 0.5
    stride3             = 2                 ; label stride
    cmin4               = -5.
    cmax4               = 5.
    clev4               = 0.5 
    stride4             = 2                 ; label stride for diff plot
    cmin5               = -0.5
    cmax5               = 0.5
    clev5               = 0.025 
    stride5             = 4                 ; label stride for diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False              ; lines for diff plot
    cntype              = "AreaFill"      ; type of contour fill
    spreadstart1        = 67                 ; start at color
    spreadend1          = 106                ; end at color
    spreadstart2        = 67                ; start at color
    spreadend2          = 106 
    spreadstart3        = 67                 ; start at color
    spreadend3          = 106                ; end at color
    spreadstart4        = 67                ; start at color
    spreadend4          = 106               ; end at color
    colormap            = "temp64_anoms.dave"
  end if
  if (cmaptype.eq."temperature") then
    cmin1               = -10.
    cmax1               = 10.
    clev1               = 1.
    stride1             = 2                 ; label stride
    cmin2               = -5.
    cmax2               = 5.
    clev2               = 0.5
    stride2             = 2                 ; label stride diff plot
    cmin3               = -20.
    cmax3               = 10.
    clev3               = 2.
    stride3             = 2                 ; label stride
    cmin4               = -5.
    cmax4               = 5.
    clev4               = 0.5 
    stride4             = 2                 ; label stride for diff plot
    cmin5               = -1.
    cmax5               = 1.
    clev5               = 0.1 
    stride5             = 2                 ; label stride for diff plot
    plotlines           = False             ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"        ; type of contour fill
    spreadstart1        = 67                ; start at color
    spreadend1          = 106               ; end at color
    spreadstart2        = 67                ; start at color
    spreadend2          = 106 
    spreadstart3        = 67                ; start at color
    spreadend3          = 106               ; end at color
    spreadstart4        = 67                ; start at color
    spreadend4          = 106               ; end at color
    colormap            = "temp64_anoms.dave"
  end if
  if (cmaptype.eq."mix_grad") then
    cmin1               =  .0
    cmax1               =  4.0
    clev1               =  0.2
    stride1             = 4                 ; label stride
    cmin2               =  -1.0
    cmax2               =  1.0
    clev2               =  0.1
    stride2             = 4                 ; label stride diff plot
    cmin3               = -4.0
    cmax3               = 4.0
    clev3               = 0.4
    stride3             = 4                 ; label stride
    cmin4               = -2.0
    cmax4               = 2.0
    clev4               = 0.2
    stride4             = 4                 ; label stride for diff plot
    cmin5               =  -0.1
    cmax5               =  0.1
    clev5               =  0.01
    stride5             = 2                 ; label stride diff plot
    plotlines           = False             ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"        ; type of contour fill
    spreadstart1        = 44                ; start at color
    spreadend1          = 85                ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 85                ; end at color
    spreadstart3        = 2                 ; start at color
    spreadend3          = 85                ; end at color
    spreadstart4        = 2                 ; start at color
    spreadend4          = 85                ; end at color
    colormap            = "BrownBlue_mod"
  end if
  if (cmaptype.eq."mix_rad") then
    cmin1               =  0.
    cmax1               =  8.0
    clev1               =  0.5
    stride1             = 4                 ; label stride
    cmin2               =  -1.0
    cmax2               =  1.0
    clev2               =  0.1
    stride2             = 2                 ; label stride diff plot
    cmin3               = 0.
    cmax3               = 8.0
    clev3               = 0.5
    stride3             = 2                 ; label stride
    cmin4               = -2.0
    cmax4               = 2.0
    clev4               = 0.2
    stride4             = 2                 ; label stride for diff plot
    cmin5               =  -10.
    cmax5               =  10.
    clev5               =  1.
    stride5             = 2                 ; label stride diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"        ; type of contour fill
    spreadstart1        = 44                ; start at color
    spreadend1          = 85                ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 85                ; end at color
    spreadstart3        = 2                 ; start at color
    spreadend3          = 85                ; end at color
    spreadstart4        = 2                 ; start at color
    spreadend4          = 85                ; end at color
    colormap            = "BrownBlue_mod"
  end if
  if (cmaptype.eq."lhflux") then
    cmin1               =  -200.
    cmax1               =  200.
    clev1               =  20.
    stride1             = 2                 ; label stride
    cmin2               = -100.
    cmax2               =  100.
    clev2               =  10.
    stride2             = 2                 ; label stride diff plot
    cmin3               = -300.
    cmax3               = 300.
    clev3               = 20.
    stride3             = 2                 ; label stride
    cmin4               = -150.
    cmax4               = 150.
    clev4               = 10.
    stride4             = 2                 ; label stride for diff plot 
    cmin5               = -10.
    cmax5               =  10.
    clev5               =  1.
    stride5             = 2                 ; label stride diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"      ; type of fill for contours 
    spreadstart1        = 2                 ; start at color
    spreadend1          = 250               ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 250               ; end at color
    spreadstart3        = 2                 ; start at color
    spreadend3          = 250                ; end at color
    spreadstart4        = 2                ; start at color
    spreadend4          = 250               ; end at color
    colormap            = "BlueYellowRed_mod"
  end if
  if (cmaptype.eq."shflux") then
    cmin1               =  -200.
    cmax1               =  200.
    clev1               =  20.
    stride1             = 2                 ; label stride
    cmin2               = -150.
    cmax2               =  150.
    clev2               =  10.
    stride2             = 2                 ; label stride diff plot
    cmin3               = -300.
    cmax3               = 300.
    clev3               = 20.
    stride3             = 2                 ; label stride
    cmin4               = -150.
    cmax4               = 150.
    clev4               = 10.
    stride4             = 2                 ; label stride for diff plot
    cmin5               = -15.
    cmax5               =  15.
    clev5               =  1.
    stride5             = 2                 ; label stride diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"      ; type of fill for contours 
    spreadstart1        = 2                 ; start at color
    spreadend1          = 250               ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 250               ; end at color
    spreadstart3        = 2                 ; start at color
    spreadend3          = 250                ; end at color
    spreadstart4        = 2                ; start at color
    spreadend4          = 250               ; end at color
    colormap            = "BlueYellowRed_mod"
  end if
  if (cmaptype.eq."flux") then
    cmin1               =  -300.
    cmax1               =  300.
    clev1               =  20.
    stride1             = 2                 ; label stride
    cmin2               = -150.
    cmax2               =  150.
    clev2               =  20.
    stride2             = 2                 ; label stride diff plot
    cmin3               = -500.
    cmax3               = 500.
    clev3               = 20.
    stride3             = 2                 ; label stride
    cmin4               = -150.
    cmax4               = 150.
    clev4               = 20.
    stride4             = 2                 ; label stride for diff plot
    cmin5               = -15.
    cmax5               =  15.
    clev5               =  1.
    stride5             = 2                 ; label stride diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"      ; type of fill for contours 
    spreadstart1        = 2                 ; start at color
    spreadend1          = 250               ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 250               ; end at color
    spreadstart3        = 2                 ; start at color
    spreadend3          = 250                ; end at color
    spreadstart4        = 2                ; start at color
    spreadend4          = 250               ; end at color
    colormap            = "BlueYellowRed_mod"
  end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Data Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dir1 = "/data3/duvivier/SOM/analysis/flux_compare/node_avgs/"

;;;;;;;;;;
; load in node averages
;;;;;;;;;;
; Load in lat/lon to get information for WRF10 domain
  fname0 = "node_0x_0y_"+datatitle1
  if (type .eq. "1")then
    f0 = addfile(dir1 + "fluxes-sst/"+ fname0 + "-fluxes-sst.nc","r")
  end if
  if (type .eq. "2")then
    f0 = addfile(dir1 + "fluxes_fromnodeavgs-sst/"+ fname0 + "-fluxes_fromnodeavgs-sst.nc","r")
  end if
  lat2d_1 = f0->lat
  lon2d_1 = f0->lon
  z_sfc_1 = f0->Z_sfc
  if(tag_1 .eq. "wrf10")then
    mask_50km = f0->mask_50km_terrain
  end if
  delete(fname0)
  delete(f0)

  dims = dimsizes(lat2d_1)     ; get lat/lon dimensions
  n_sn_1 = dims(0)              ; get south/north points
  n_we_1 = dims(1)              ; get west/east points
  n_tot_1 = n_sn_1*n_we_1              ; get total number of points in high res domain
  delete(dims)

; Load in lat/lon to get information for WRF10 domain
  fname0b = "node_0x_0y_"+datatitle1b
  if (type .eq. "1")then
    f0b = addfile(dir1 + "fluxes-sst/"+ fname0b + "-fluxes-sst.nc","r")
  end if
  if (type .eq. "2")then
    f0b = addfile(dir1 + "fluxes_fromnodeavgs-sst/"+ fname0b + "-fluxes_fromnodeavgs-sst.nc","r")
  end if
  lat2d_1b = f0b->lat
  lon2d_1b = f0b->lon
  z_sfc_1b = f0b->Z_sfc
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
  var1 = new((/nnode,n_sn_1,n_we_1/),"float")
  var1b = new((/nnode,n_sn_1b,n_we_1b/),"float")
  fill = var1@_FillValue

  ; make sea ice var - overlay with everything
  if(type .eq. "1")then
    variance1 = new((/nnode,n_sn_1,n_we_1/),"float")
    variance1b = new((/nnode,n_sn_1b,n_we_1b/),"float")
  end if
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
  if (type .eq. "1")then
    f1 = addfile(dir1 + "fluxes-sst/"+ fname1 + "-fluxes-sst.nc","r")
  end if
  if (type .eq. "2")then
    f1 = addfile(dir1 + "fluxes_fromnodeavgs-sst/"+ fname1 + "-fluxes_fromnodeavgs-sst.nc","r")
  end if
  var1(n,:,:) = f1->$invar1$(south_north|:,west_east|:)
  seaice_1(n,:,:) = f1->SeaIce_avg(south_north|:,west_east|:)
  if(type .eq. "1")then
    variance1(n,:,:) = f1->$invar_v$(south_north|:,west_east|:)
  end if

  fname1b = "node_"+x+"x_"+y+"y_"+datatitle1b
  if (type .eq. "1")then
    f1b = addfile(dir1 + "fluxes-sst/"+ fname1b + "-fluxes-sst.nc","r")
  end if
  if (type .eq. "2")then
    f1b = addfile(dir1 + "fluxes_fromnodeavgs-sst/"+ fname1b + "-fluxes_fromnodeavgs-sst.nc","r")
  end if

  var1b(n,:,:) = f1b->$invar1$(south_north|:,west_east|:)
  seaice_1b(n,:,:) = f1b->SeaIce_avg(south_north|:,west_east|:)
  if(type .eq. "1")then
    variance1b(n,:,:) = f1b->$invar_v$(south_north|:,west_east|:)
  end if

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

; change units for curltau variable and get rid of nans, etc.
if (varcode .eq. "curltau")then
  var1 = where(var1 .eq. "nan" .or. var1 .eq. "-nan" .or. var1 .eq. "inf" .or. var1 .eq. "-inf", fill, var1)
  var1b = where(var1b .eq. "nan" .or. var1b .eq. "-nan" .or. var1b .eq. "inf" .or. var1b .eq. "-inf", fill, var1b)
  var1 = var1*10.0E5
  var1b = var1b*10.0E5
  var1@units = "10E-5 N m-3"
  var1b@units = "10E-5 N m-3"
end if

;;;;;;;;;;
; Interpolate to WRF10 size (if needed)
;;;;;;;;;;
if (tag_1 .eq. "wrf10" .and. tag_1b .ne. "wrf10")then
  print("Interpolating between resolutions")
  ; Make arrays we'll need in interpolation
  var1b_new = new((/nnode,n_sn_1,n_we_1/),"float") 
  var1b_tmp_1d  = new((/n_tot_1/),"float")
  seaice_1b_new = new((/nnode,n_sn_1,n_we_1/),"float") 
  seaice_1b_tmp_1d  = new((/n_tot_1/),"float")
  if(type .eq. "1")then
    variance1b_new = new((/nnode,n_sn_1,n_we_1/),"float") 
    variance1b_tmp_1d  = new((/n_tot_1/),"float")
  end if

  do n = 0, nnode - 1
    var1b_1d = ndtooned(var1b(n,:,:))
    seaice_1b_1d = ndtooned(seaice_1b(n,:,:))
    if(type .eq. "1")then
      variance1b_1d = ndtooned(variance1b(n,:,:))
    end if
    do i = 0, n_tot_1 - 1
      indices_all = interp_ind(i,:)
      n_indices = num(.not.ismissing(indices_all))
      if (n_indices .ne. 0.0) then
        indices = indices_all(0:n_indices-1)
        weight_all = interp_wgt(i,:)
        weight = weight_all(0:n_indices-1)
        var1b_tmp_1d(i) = sum(var1b_1d(indices)*weight/sum(weight))
        seaice_1b_tmp_1d(i) = sum(seaice_1b_1d(indices)*weight/sum(weight))
        if(type .eq. "1")then
          variance1b_tmp_1d(i) = sum(variance1b_1d(indices)*weight/sum(weight))
        end if
        delete(indices)
        delete(weight)
      end if
    end do
    ; redimensionalize
    var1b_new(n,:,:) = onedtond(var1b_tmp_1d,(/n_sn_1,n_we_1/))
    seaice_1b_new(n,:,:) = onedtond(seaice_1b_tmp_1d,(/n_sn_1,n_we_1/))
     
    if(type .eq. "1")then
      variance1b_new(n,:,:) = onedtond(variance1b_tmp_1d,(/n_sn_1,n_we_1/))
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
  delete(seaice_1b)
  seaice_1b = seaice_1b_new
  delete(seaice_1b_new)
  copy_VarMeta(seaice_1, seaice_1b)
  copy_VarCoords(seaice_1,seaice_1b)
  seaice_1b@_FillValue = fill
  if(type .eq. "1")then
    delete(variance1b)
    variance1b = variance1b_new
    delete(variance1b_new)
    copy_VarMeta(variance1, variance1b)
    copy_VarCoords(variance1,variance1b)
    variance1b@_FillValue = fill
  end if
end if

print("Masking terrain - nodes")
n = 0
; loop through each node
do n = 0, nnode - 1
  ; mask terrain - focus on ocean
  ; WRF10 we need the same mask as 50km to be sure we're comparing all ocean
  ; points. Use this as the mask instead of terrain; the cutoff is also 10m.
  if (tag_1 .eq. "wrf10")then
    var1(n,:,:) = where(mask_50km .eq. 1, var1(n,:,:),var1@_FillValue)
    var1b(n,:,:) = where(mask_50km .eq. 1, var1b(n,:,:),var1b@_FillValue)
    seaice_1(n,:,:) = where(mask_50km .eq. 1, seaice_1(n,:,:), seaice_1@_FillValue)
    seaice_1b(n,:,:) = where(mask_50km .eq. 1, seaice_1b(n,:,:), seaice_1b@_FillValue)
  else
    var1(n,:,:) = where(z_sfc_1 .lt. 10., var1(n,:,:), var1@_FillValue)
    var1b(n,:,:) = where(z_sfc_1 .lt. 10., var1b(n,:,:), var1b@_FillValue)
    seaice_1(n,:,:) = where(z_sfc_1 .lt. 10., seaice_1(n,:,:), seaice_1@_FillValue)
    seaice_1b(n,:,:) = where(z_sfc_1 .lt. 10., seaice_1b(n,:,:), seaice_1b@_FillValue)
  end if

  ; mask lat/lons - focus on S. Greenland region
  var1(n,:,:) = where(lat2d_1 .gt. 55. .and. lat2d_1 .lt. 71. .and. lon2d_1 .lt. -19. .and. lon2d_1 .gt. -55., var1(n,:,:), var1@_FillValue)
  var1b(n,:,:) = where(lat2d_1 .gt. 55. .and. lat2d_1 .lt. 71. .and. lon2d_1 .lt. -19. .and. lon2d_1 .gt. -55., var1b(n,:,:), var1b@_FillValue)
  seaice_1(n,:,:) = where(lat2d_1 .gt. 55. .and. lat2d_1 .lt. 71. .and. lon2d_1 .lt. -19. .and. lon2d_1 .gt. -55., seaice_1(n,:,:), seaice_1@_FillValue)
  seaice_1b(n,:,:) = where(lat2d_1 .gt. 55. .and. lat2d_1 .lt. 71. .and. lon2d_1 .lt. -19. .and. lon2d_1 .gt. -55., seaice_1b(n,:,:), seaice_1b@_FillValue)
end do

;;;;;;;;;;
; Find difference and probability
;;;;;;;;;;
; find difference
diff = var1 - var1b
title_diff = "Diff: ("+datatitle1+" - "+datatitle1b+")"

; Calculate statistical significance
; Uses student's t-test. If the probability is less than 0.1 then we know at a 90% confidence level
; that the two means are statistically significant.
if(type .eq. "1")then
  prob = new((/nnode,n_sn_1,n_we_1/),"float")
  n = 0
  do n = 0, nnode - 1
    prob(n,:,:) = 100.*(1. - ttest(var1(n,:,:),variance1(n,:,:),nodecount_1(n), var1b(n,:,:),variance1b(n,:,:),nodecount_1b(n), False, False))    
  end do
end if

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
if (type .eq. "1")then
  prob@lat2d = lat2d_1
  prob@lon2d = lon2d_1
end if

; prints together the variable title (set above for each type of data) with title1 (defined in cshell as the wrf or met info) and the max and min values
print(vartitle1+" min: "+min(diff)+"  max: "+max(diff)) 

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

    ; Find seaice winter net average
    seaice_nodes_1(n,:,:)  = (freq_nodes_1(n)/100.) * seaice_1(n,:,:)
    seaice_nodes_1b(n,:,:) = (freq_nodes_1b(n)/100.) * seaice_1b(n,:,:)    
    seaice_avg_1 = seaice_avg_1(:,:) + seaice_nodes_1(n,:,:)
    seaice_avg_1b = seaice_avg_1b(:,:) + seaice_nodes_1b(n,:,:)
  end do

  ; Find winter differences
  ; Winter net difference
  winter_diff = winter_avg_1 - winter_avg_1b
  winter_seaice_diff = seaice_avg_1 - seaice_avg_1b
  ; Do sums over various terms for why the difference exists
  nodes_sum_all = term1 + term2 + term3
  net_diff = term1_sum + term2_sum + term3_sum    

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
  copy_VarMeta(net_diff,term1_sum_group2)
  copy_VarMeta(net_diff,term2_sum_group2)
  copy_VarMeta(net_diff,term3_sum_group2)
  copy_VarMeta(net_diff,term1_sum_group3)
  copy_VarMeta(net_diff,term2_sum_group3)
  copy_VarMeta(net_diff,term3_sum_group3)
  copy_VarMeta(net_diff,term1_sum_group4)
  copy_VarMeta(net_diff,term2_sum_group4)
  copy_VarMeta(net_diff,term3_sum_group4)
  copy_VarMeta(net_diff,term1_sum_group5)
  copy_VarMeta(net_diff,term2_sum_group5)
  copy_VarMeta(net_diff,term3_sum_group5)
  copy_VarMeta(net_diff,term1_sum_group6)
  copy_VarMeta(net_diff,term2_sum_group6)
  copy_VarMeta(net_diff,term3_sum_group6)
  copy_VarMeta(net_diff,term1_sum_group7)
  copy_VarMeta(net_diff,term2_sum_group7)
  copy_VarMeta(net_diff,term3_sum_group7)
  copy_VarMeta(net_diff,term1_sum_group8)
  copy_VarMeta(net_diff,term2_sum_group8)
  copy_VarMeta(net_diff,term3_sum_group8)
  copy_VarMeta(net_diff,winter_avg_1)
  copy_VarMeta(net_diff,winter_avg_1b)
  copy_VarMeta(net_diff,winter_diff)
  copy_VarMeta(net_diff,winter_seaice_diff)
  copy_VarMeta(net_diff,seaice_avg_1)
  copy_VarMeta(net_diff,seaice_avg_1b)

  print("Completed calculations for assessing why differences exist")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Use net average files to calculate difference
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  fname1 = "net_avg_"+datatitle1
  fname1b = "net_avg_"+datatitle1b
  if (type .eq. "1")then
    f1 = addfile(dir1+"fluxes-sst/"+fname1+"-fluxes-sst.nc","r")
    f1b = addfile(dir1+"fluxes-sst/"+fname1b+"-fluxes-sst.nc","r")
    obs_1 = f1->number_dates
  end if
  if (type .eq. "2")then
    f1 = addfile(dir1+"fluxes_fromnodeavgs-sst/"+fname1+"-fluxes_fromnodeavgs-sst.nc","r")
    f1b = addfile(dir1+"fluxes_fromnodeavgs-sst/"+fname1b+"-fluxes_fromnodeavgs-sst.nc","r")
    obs_1 = 35.  ; from each node
  end if

  ; create all-node array for node average variable
  avg1 = new((/n_sn_1,n_we_1/),"float")
  avg1b = new((/n_sn_1b,n_we_1b/),"float")
  avg_variance1 = new((/n_sn_1,n_we_1/),"float")
  avg_variance1b = new((/n_sn_1b,n_we_1b/),"float")
  fill = var1@_FillValue

  ; make sea ice var - overlay with everything
  avg_seaice_1 = new((/n_sn_1,n_we_1/),"float")
  avg_seaice_1b = new((/n_sn_1b,n_we_1b/),"float")

;;;;;;;;;;
; Load in actual data for analysis
;;;;;;;;;;
  avg1(:,:) = f1->$invar1$(:,:) ;(south_north|:,west_east|:)
  avg_variance1(:,:) = f1->$invar_v$(:,:) ;(south_north|:,west_east|:)
  avg_seaice_1(:,:) = f1->SeaIce_avg(:,:) ;(south_north|:,west_east|:)

  avg1b(:,:) = f1b->$invar1$(:,:) ;(south_north|:,west_east|:)
  avg_variance1b(:,:) = f1b->$invar_v$(:,:) ;(south_north|:,west_east|:)
  avg_seaice_1b(:,:) = f1b->SeaIce_avg(:,:) ;(south_north|:,west_east|:)

  if (varcode .eq. "curltau")then
    avg1 = where(avg1 .eq. "nan" .or. avg1 .eq. "-nan" .or. avg1 .eq. "inf" .or. avg1 .eq. "-inf", fill, avg1)
    avg1b = where(avg1b .eq. "nan" .or. avg1b .eq. "-nan" .or. avg1b .eq. "inf" .or. avg1b .eq. "-inf", fill, avg1b)
    avg1 = avg1*10.0E5
    avg1b = avg1b*10.0E5
    avg1@units = "10E-5 N m-3"
    avg1b@units = "10E-5 N m-3"
  end if

  ; delete vars to use in next loop
  delete(f1)
  delete(f1b)

print("Loaded variables from both files")

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

  avg1b_1d = ndtooned(avg1b(:,:))
  avg_variance1b_1d = ndtooned(avg_variance1b(:,:))
  avg_seaice_1b_1d = ndtooned(avg_seaice_1b(:,:))
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
      delete(indices)
      delete(weight)
    end if
  end do
  ; redimensionalize
  avg1b_new(:,:) = onedtond(avg1b_tmp_1d,(/n_sn_1,n_we_1/))
  avg_variance1b_new(:,:) = onedtond(avg_variance1b_tmp_1d,(/n_sn_1,n_we_1/))
  avg_seaice_1b_new(:,:) = onedtond(avg_seaice_1b_tmp_1d,(/n_sn_1,n_we_1/))

  delete(avg1b)
  avg1b = avg1b_new
  delete(avg1b_new)
  copy_VarMeta(avg1, avg1b)
  avg1b@_FillValue = fill
  delete(avg_variance1b)
  avg_variance1b = avg_variance1b_new
  delete(avg_variance1b_new)
  copy_VarMeta(avg_variance1, avg_variance1b)
  avg_variance1b@_FillValue = fill
  delete(avg_seaice_1b)
  avg_seaice_1b = avg_seaice_1b_new
  delete(avg_seaice_1b_new)
  copy_VarMeta(avg_seaice_1, avg_seaice_1b)
  avg_seaice_1b@_FillValue = fill
end if

print("Masking terrain - net")
  ; mask terrain - focus on ocean
  ; WRF10 we need the same mask as 50km to be sure we're comparing all ocean
  ; points. Use this as the mask instead of terrain; the cutoff is also 10m.
  if (tag_1 .eq. "wrf10")then
    avg1(:,:) = where(mask_50km .eq. 1, avg1(:,:), avg1@_FillValue)
    avg1b(:,:) = where(mask_50km .eq. 1, avg1b(:,:), avg1b@_FillValue)
    avg_seaice_1(:,:) = where(mask_50km .eq. 1, avg_seaice_1(:,:), avg_seaice_1@_FillValue)
    avg_seaice_1b(:,:) = where(mask_50km .eq. 1, avg_seaice_1b(:,:), avg_seaice_1b@_FillValue)
  else
    avg1(:,:) = where(z_sfc_1 .lt. 10., avg1(:,:), avg1@_FillValue)
    avg1b(:,:) = where(z_sfc_1 .lt. 10., avg1b(:,:), avg1b@_FillValue)
    avg_seaice_1(:,:) = where(z_sfc_1 .lt. 10., avg_seaice_1(:,:), avg_seaice_1@_FillValue)
    avg_seaice_1b(:,:) = where(z_sfc_1 .lt. 10., avg_seaice_1b(:,:), avg_seaice_1b@_FillValue)
  end if

  ; mask lat/lons - focus on S. Greenland region
  avg1(:,:) = where(lat2d_1 .gt. 55. .and. lat2d_1 .lt. 71. .and. lon2d_1 .lt. -19. .and. lon2d_1 .gt. -55., avg1(:,:), avg1@_FillValue)
  avg1b(:,:) = where(lat2d_1 .gt. 55. .and. lat2d_1 .lt. 71. .and. lon2d_1 .lt. -19. .and. lon2d_1 .gt. -55., avg1b(:,:), avg1b@_FillValue)
  avg_seaice_1(:,:) = where(lat2d_1 .gt. 55. .and. lat2d_1 .lt. 71. .and. lon2d_1 .lt. -19. .and. lon2d_1 .gt. -55., avg_seaice_1(:,:), avg_seaice_1@_FillValue)
  avg_seaice_1b(:,:) = where(lat2d_1 .gt. 55. .and. lat2d_1 .lt. 71. .and. lon2d_1 .lt. -19. .and. lon2d_1 .gt. -55., avg_seaice_1b(:,:), avg_seaice_1b@_FillValue)

;;;;;;;;;;
; Find difference
;;;;;;;;;;
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
; and fulfill cutoff of minimum differences
if (varcode .eq. "U10") then
  ; 1 m/s difference cutoff (~10% max diff)
  mask_95_prob = where(avg_prob .gt. 95., 1, fill)
  mask_min_diff = where(abs(winter_diff) .gt. 0.95, 1, fill)
  mask_all = where(mask_95_prob .eq. 1 .and. mask_min_diff .eq. 1, 1, fill)
end if
if (varcode .eq. "LH" .or. varcode .eq. "SH") then
  ; 10 W/m2 difference cutoff (~10% max diff)
  mask_95_prob = where(avg_prob .gt. 95., 1, fill)
  mask_min_diff = where(abs(winter_diff) .gt. 10., 1, fill)
  mask_all = where(mask_95_prob .eq. 1 .and. mask_min_diff .eq. 1, 1, fill)
end if
if (varcode .eq. "curltau")then
  ; 0.3X10E-5 N/m3 difference cutoff (~10% max diff)
  mask_95_prob = where(avg_prob .gt. 95., 1, fill)
  mask_min_diff = where(abs(winter_diff) .gt. 0.3, 1, fill)
  mask_all = where(mask_95_prob .eq. 1 .and. mask_min_diff .eq. 1, 1, fill)
end if
if (varcode .ne. "U10" .and. varcode .ne. "LH" .and. varcode .ne. "SH" .and. varcode .ne. "curltau")then
  ; all other variables
  mask_95_prob = where(avg_prob .gt. 95., 1, fill)
  mask_all = mask_95_prob
end if

; now get values for the mask so that we can actually plot it
; get numbers between 95 and 100 for the values this fits so we can contour properly
low =  95
high = 99.5
con = (high-low)/32766.0

dum1 = ndtooned(mask_all)
dum2 = ndtooned(var1)
dims = dimsizes(dum1)
dum3 = new((/dims/),"float")
do i = 0, dims - 1
  value = dum1(i)
  if(.not.ismissing(value))then
    dum3(i) = low+con*rand()
  end if
  if(ismissing(value) .and. .not.ismissing(dum2(i)))then
    dum3(i) = 50.0
  end if
  delete(value)
end do
prob_plot = onedtond(dum3,(/n_sn_1,n_we_1/))
delete(dum1)
delete(dum2)
delete(dum3)
delete(dims)

; assign lat/lon
avg_prob@lat2d = lat2d_1
avg_prob@lon2d = lon2d_1
prob_plot@lat2d = lat2d_1
prob_plot@lon2d = lon2d_1

print("completed calculations with net avg files")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Calculate percent contributions to net avg
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

avg_diff = where(avg_diff .eq. 0.0, avg_diff@_FillValue, avg_diff)

; Calculate percent contribution for each term
term1_pcnt = avg((term1_sum*mask_all)/avg_diff)*100.
term2_pcnt = avg((term2_sum*mask_all)/avg_diff)*100.
term3_pcnt = avg((term3_sum*mask_all)/avg_diff)*100.
term_total_pcnt = term1_pcnt + term2_pcnt + term3_pcnt

; get percents for groups
term1_group1_pcnt = avg((term1_sum_group1*mask_all)/avg_diff)*100.
term2_group1_pcnt = avg((term2_sum_group1*mask_all)/avg_diff)*100.
term3_group1_pcnt = avg((term3_sum_group1*mask_all)/avg_diff)*100.
term1_group2_pcnt = avg((term1_sum_group2*mask_all)/avg_diff)*100.
term2_group2_pcnt = avg((term2_sum_group2*mask_all)/avg_diff)*100.
term3_group2_pcnt = avg((term3_sum_group2*mask_all)/avg_diff)*100.
term1_group3_pcnt = avg((term1_sum_group3*mask_all)/avg_diff)*100.
term2_group3_pcnt = avg((term2_sum_group3*mask_all)/avg_diff)*100.
term3_group3_pcnt = avg((term3_sum_group3*mask_all)/avg_diff)*100.
term1_group4_pcnt = avg((term1_sum_group4*mask_all)/avg_diff)*100.
term2_group4_pcnt = avg((term2_sum_group4*mask_all)/avg_diff)*100.
term3_group4_pcnt = avg((term3_sum_group4*mask_all)/avg_diff)*100.
term1_group5_pcnt = avg((term1_sum_group5*mask_all)/avg_diff)*100.
term2_group5_pcnt = avg((term2_sum_group5*mask_all)/avg_diff)*100.
term3_group5_pcnt = avg((term3_sum_group5*mask_all)/avg_diff)*100.
term1_group6_pcnt = avg((term1_sum_group6*mask_all)/avg_diff)*100.
term2_group6_pcnt = avg((term2_sum_group6*mask_all)/avg_diff)*100.
term3_group6_pcnt = avg((term3_sum_group6*mask_all)/avg_diff)*100.
term1_group7_pcnt = avg((term1_sum_group7*mask_all)/avg_diff)*100.
term2_group7_pcnt = avg((term2_sum_group7*mask_all)/avg_diff)*100.
term3_group7_pcnt = avg((term3_sum_group7*mask_all)/avg_diff)*100.
term1_group8_pcnt = avg((term1_sum_group8*mask_all)/avg_diff)*100.
term2_group8_pcnt = avg((term2_sum_group8*mask_all)/avg_diff)*100.
term3_group8_pcnt = avg((term3_sum_group8*mask_all)/avg_diff)*100.

print("Total term contribution = "+term_total_pcnt)

; Calculate percent contribution for each node (sum of all terms and terms individually)
nodes_all_pcnt = new((/nnode/),"float")
nodes_term1_pcnt = new((/nnode/),"float")
nodes_term2_pcnt = new((/nnode/),"float")
nodes_term3_pcnt = new((/nnode/),"float")

total_pcnt = 0.0
do n = 0, nnode - 1
  nodes_all_pcnt(n) = avg((nodes_sum_all(n,:,:)*mask_all)/avg_diff)*100.
  total_pcnt = total_pcnt + nodes_all_pcnt(n)
  ; each term individually
  nodes_term1_pcnt(n) = avg((term1(n,:,:)*mask_all)/avg_diff)*100.
  nodes_term2_pcnt(n) = avg((term2(n,:,:)*mask_all)/avg_diff)*100.
  nodes_term3_pcnt(n) = avg((term3(n,:,:)*mask_all)/avg_diff)*100.
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
; plot 1 - Frequency and frequency differences of all nodes (only needed once)
; plot 2 - 3 panel of winter average values and difference
; plot 3 - 3 panel of winter average values and difference using net avg files (w/stat sig)
; plot 4 - winter average for all nodes of datatitle1
; plot 5 - winter average for all nodes of datatitle1b
; plot 6 - winter average difference for all nodes (datatitle1 - datatitle1b)
; plot 7 - 4 panel with total winter difference and sum for each term of difference  w/%contribution
; plot 8 - 4 panel with total winter difference and ratio of each term difference to the total
; plot 9 - all nodes with sum of each term of difference  w/%contribution
; plot 10 - all nodes with difference term 1  w/%contribution
; plot 11 - all nodes with difference term 2  w/%contribution
; plot 12 - all nodes with difference term 3  w/%contribution
; plot 13 - % contribution of nodes to net difference - sum of terms - simple box plot
; plot 14 - % contribution of nodes to net difference - individual terms - simple box plot
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; set outdir and fout names
outdir = "./"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 1 - Frequency differences
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot1").and.(plot1))then  ; if plotting is turned on
  print("Plot 1 - frequency differences")
  fout1 = "frequency_"+datatitle1+"-"+datatitle1b
  title_1 = tag_1b
  title_2 = tag_1+"-"+tag_1b
  title = nx_input+"x"+ny_input+" pattern frequency: 2005-2007 "+tag_1+" and "+tag_1b

  wks1 = gsn_open_wks("ps",fout1)
  gsn_define_colormap(wks1,"gsdtol")
  gsn_reverse_colormap(wks1)
  colors = gsn_retrieve_colormap(wks1) ; load fixed map into "colors"
  additional_colors = (/"forestgreen", "blue", "red", "lightblue", "pink"/)
  gsn_merge_colormaps(wks1,colors,additional_colors)

; Reverse rows(for plotting purposes) and get max frequencies
  nodefreq_1     = nodefreq_1(:,::-1)
  nodefreq_1b     = nodefreq_1b(:,::-1)
  ; reverse the statistical information as well
  test_stat = test_stat(:,::-1)
  freq_diff = freq_diff(:,::-1)

; Begin plotting:    
  plot = new(1, graphic)
  dum1  = new((/nnode/),graphic)
  dum2  = new((/nnode/),graphic)
  dum3  = new((/nnode/),graphic)
  dum4  = new((/nnode/),graphic)

; Resources for blank plot:
  res_blank                                = True
  res_blank@gsnFrame                       = False  ; do not frame yet (so we can panel)
  res_blank@gsnDraw                        = False   ; do not draw yet (so we can panel)
  res_blank@gsnMaximize                    = True
  res_blank@trXMinF                        = 0
  res_blank@trXMaxF                        = nx_node
  res_blank@trYMinF                        = 0
  res_blank@trYMaxF                        = ny_node
  res_blank@vpWidthF                       = 0.6           ; this is default
  res_blank@vpHeightF                      = 0.6*ny_node / nx_node  ; set height so each node is square
  res_blank@tiMainFontHeightF              = 0.01
  res_blank@tiMainPosition                 = "Left"
  res_blank@tiMainJust                     = "centerleft"
  res_blank@tmEqualizeXYSizes              = True    ; Equal sizes for tick labels
  res_blank@tmXBMajorLengthF               = 0.0      ; effectively turn off tick marks
  res_blank@tmYLMajorLengthF               = 0.0      ; effectively turn off tick marks
  res_blank@tmXBMode                       = "Explicit"
  res_blank@tmXBLabels                     = ispan(0,nx_node-1,1)+""            ; tick marks
  res_blank@tmXBValues                     = fspan(0, nx_node-1, nx_node) + 0.5 ; position for tick labels
  res_blank@tmYLMode                       = "Explicit"
  res_blank@tmYLLabels                     = ispan(ny_node-1,0,1)+""            ; backwards tick marks
  res_blank@tmYLValues                     = fspan(0, ny_node-1, ny_node) + 0.5 ; position for tick labels
  res_blank@tmXBLabelFontHeightF           = res_blank@tiMainFontHeightF
  res_blank@tiXAxisString                  = "SOM Pattern"
  res_blank@tiYAxisString                  = "SOM Pattern"
  res_blank@tiXAxisFontHeightF             = 0.01
  res_blank@tiYAxisFontHeightF             = 0.01
  res_blank@tiMainString                   = title

  plot = gsn_blank_plot(wks1,res_blank)

; Add in squares:
  xx = (/0., 0., 1., 1., 0./)
  yy = (/0., 1., 1., 0., 0./)

; Polygon resources for color shading:
  res_poly = True
; Text resources for count and freq:
  res_txt = True
  res_txt@txFontHeightF = 0.0125 ;0.0085
  res_txt@txFont = 22
  res_txt@txFontColor = "white" ;"black"
; loop through each node to plot
n = 0
do y = 0, ny_node - 1
  do x = 0, nx_node - 1 
    xp = xx + x
    yp = yy + y  
    ; Get grey scales(same used for all data sets)
    maxnodefreq = max(nodefreq_1b)
    minnodefreq = 0.
    if (maxnodefreq.ne.0) then
      slope = (32. - 2.) / (maxnodefreq - minnodefreq)  ; use 32 because there are 32 colors
    else
      slope = 0
    end if
    ; variable 1
    gray_index = slope * nodefreq_1b(x,y) + 2.
    if(gray_index.eq.2.) then
      gray_index = 0. ; to get actual white because our color table is flaky
    end if 
    ; Color squares
    res_poly@gsFillColor = "white" ;gray_index ; should auto round
    dum1(n) = gsn_add_polygon(wks1, plot, xp, yp, res_poly)
    dum2(n) = gsn_add_polyline(wks1, plot, xp, yp, res_poly)
    ; Frequency text:
    res_txt1 = res_txt
    res_txt1@txBackgroundFillColor = gray_index ;"white" "black"
    text_1 = title_1+":~C~ "+sprintf("%5.2f",nodefreq_1b(x,y))+"%"
    dum3(n) = gsn_add_text(wks1, plot, text_1, xp(0)+.5, yp(0)+.75, res_txt1)
    delete(text_1)

    res_txt2 = res_txt
    res_txt2@txFontColor = "black"
    res_txt2@txBackgroundFillColor = "white"
    if(test_stat(x,y).ge.1.645).and.(test_stat(x,y).lt.1.96) then
      res_txt2@txBackgroundFillColor = "pink"
      res_txt2@txFontColor = "white"
    end if
    if(test_stat(x,y).ge.1.96) then
      res_txt2@txBackgroundFillColor = "red"
      res_txt2@txFontColor = "white"
    end if
    if(test_stat(x,y).le.-1.645).and.(test_stat(x,y).gt.-1.96) then
      res_txt2@txBackgroundFillColor = "lightblue"
      res_txt2@txFontColor = "white"
    end if
    if(test_stat(x,y).le.-1.96) then
      res_txt2@txBackgroundFillColor = "blue"
      res_txt2@txFontColor = "white"
    end if
    text_2 = title_2+":~C~ "+sprintf("%5.2f",freq_diff(x,y))+"%"
    dum4(n) = gsn_add_text(wks1, plot, text_2, xp(0)+.5, yp(0)+.25, res_txt2)   
    delete(text_2)
    n = n+1
  end do 
end do
  
; Finally - make plot
  draw(plot)
  frame(wks1)
  print("converting plot 1 to png")
  convert_cmd = "convert -density 300 "+fout1+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout1+".png"
  system(convert_cmd)

delete(res_blank)
delete(res_poly)
delete(res_txt)
delete(title_1)
delete(title_2)
delete(title)
delete(additional_colors)
delete(plot)

end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 2 - Winter averages and difference
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot2").and.(plot2))then  ; if plotting is turned on
print("Plot 2 - winter averages and difference")
fout2   = varcode+"_diff_"+datatitle1+"_"+datatitle1b+"_winter_net_diff_from_nodes-case"+type

  wks2 = gsn_open_wks("ps" ,fout2)
  additional_colors = (/"gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks2,colormap,additional_colors)
  plot = new(4, graphic)

  ; Set resources for plot
  res                             = True              ; plot mods desired
  res@gsnRightString              = ""
  res@gsnLeftString               = ""               ; Set this in loop
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

;;;;;;;;;;;;;
; Set resources for overlay plots
;;;;;;;;;;;;
; set resources for sea ice overlay
  res_ice                            = True               ; reset options
  res_ice@gsnLeftString              = ""
  res_ice@gsnRightString             = ""
  res_ice@gsnFrame                   = False             ; Do not draw plot 
  res_ice@gsnDraw                    = False             ; Do not advance fr
  res_ice@cnInfoLabelOn              = False             ; Turn off info on contours at bottom
  res_ice@cnFillOn                   = False             ; turn on filled contours
  res_ice@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  res_ice@cnMinLevelValF             = 0.                ; set min contour level specified above
  res_ice@cnMaxLevelValF             = 0.15              ; set max contour level specified above
  res_ice@cnLevelSpacingF            = 0.15              ; set contour spacing specified above
  res_ice@cnLinesOn                  = True              ; contour lines specified above
  res_ice@cnLineLabelsOn             = True             ; line labels on specified above
  res_ice@cnLineColor                = "black" ;"gray85"
  res_ice@cnLineThicknessF           = 2.0
  res_ice@tiXAxisOn                  = False
  res_ice@tiYAxisOn                  = False

; set resources for sea ice overlay
  res_ice2                            = res_ice               ; reset options
  res_ice2@cnMinLevelValF             = 0.                ; set min contour level specified above
  res_ice2@cnMaxLevelValF             = 0.85              ; set max contour level specified above
  res_ice2@cnLevelSpacingF            = 0.85              ; set contour spacing specified above
  res_ice2@cnLineColor                = "black" ;"gray85"
  res_ice2@cnLineThicknessF           = 2.0
  res_ice2@cnLineDashPattern          = 6

; set resources for 95% statistical significance overlay
;  res_95                            = True               ; reset options
;  res_95@gsnLeftString              = ""
;  res_95@gsnRightString             = ""
;  res_95@gsnFrame                   = False             ; Do not draw plot 
;  res_95@gsnDraw                    = False             ; Do not advance fr
;  res_95@cnInfoLabelOn              = False             ; Turn off info on contours at bottom
;  res_95@cnFillOn                   = True             ; turn on filled contours
;  res_95@cnMonoFillColor            = True
;  res_95@cnMonoFillPattern          = False
;  res_95@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
;  res_95@cnMinLevelValF             = 0.                ; set min contour level specified above
;  res_95@cnMaxLevelValF             = 95.              ; set max contour level specified above
;  res_95@cnLevelSpacingF            = 95.              ; set contour spacing specified above
;  res_95@cnFillPatterns             = (/-1,-1,17/)      ; dots over areas where >95% sig. diff

;;;;;;;;;;;;;
; Make normal plots
;;;;;;;;;;;;;
  opts                            = res               ; reset options
  opts@cnFillMode                 = cntype
  opts@cnFillOn                   = True              ; turn on filled contours
  opts@gsnSpreadColors            = True              ; use full colormap
  opts@gsnSpreadColorStart        = spreadstart1      ; start at color specified for each variable above
  opts@gsnSpreadColorEnd          = spreadend1        ; end at color specified above
  opts@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  opts@cnMinLevelValF             = cmin1             ; set min contour level specified above
  opts@cnMaxLevelValF             = cmax1             ; set max contour level specified above
  opts@cnLevelSpacingF            = clev1             ; set contour spacing specified above
  opts@cnLinesOn                  = plotlines         ; contour lines specified above
  opts@cnLineLabelsOn             = plotlines         ; line labels on specified above
  opts@cnMissingValFillColor      = "gray85"          ; missing value color
  opts@cnMissingValFillPattern    = 0                 ; fill in
  opts@cnMissingValPerimOn        = True
  opts@cnMissingValPerimColor     = "black"
  opts@tiMainFontHeightF          = 0.013
  opts@lbLabelStride              = stride1
  opts@pmLabelBarOrthogonalPosF   = -0.01             ; move label bar closer
  opts@pmLabelBarHeightF          = 0.075             ; set height of labelbar

  opts@tiMainString               = datatitle1            ; title string specified from cshell
  cplot0  = gsn_csm_contour_map(wks2,winter_avg_1,opts)
  cplot0b = gsn_csm_contour(wks2,seaice_avg_1,res_ice)
  overlay(cplot0,cplot0b)
  cplot0c = gsn_csm_contour(wks2,seaice_avg_1,res_ice2)
  overlay(cplot0,cplot0c)  
  plot(0) = cplot0
    
  opts@tiMainString               = datatitle1b            ; title string specified from cshell
  cplot1  = gsn_csm_contour_map(wks2,winter_avg_1b,opts)
  cplot1b = gsn_csm_contour(wks2,seaice_avg_1b,res_ice)
  overlay(cplot1,cplot1b)
  cplot1c = gsn_csm_contour(wks2,seaice_avg_1b,res_ice2)
  overlay(cplot1,cplot1c)  
  plot(1) = cplot1

delete(opts)

;;;;;;;;;;;;;
; Make difference plot
;;;;;;;;;;;;;
  opts                            = res
  opts@cnFillMode                 = cntype
  opts@cnFillOn                   = True
  opts@gsnSpreadColors            = True              ; use full colormap
  opts@gsnSpreadColorStart        = spreadstart2      ; start at color specified above
  opts@gsnSpreadColorEnd          = spreadend2        ; end at color specified above
  opts@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  opts@cnMinLevelValF             = cmin2             ; set min contour level specified above
  opts@cnMaxLevelValF             = cmax2             ; set max contour level specified above
  opts@cnLevelSpacingF            = clev2             ; set contour spacing specified above
  opts@cnLinesOn                  = difflines         ; contour lines specified above
  opts@cnLineLabelsOn             = difflines
  opts@cnMissingValFillColor      = "gray85"          ; missing value color
  opts@cnMissingValFillPattern    = 0                 ; fill in
  opts@tiMainFontHeightF          = 0.013
  opts@lbLabelStride              = stride2
  opts@pmLabelBarOrthogonalPosF   = -0.01             ; move label bar closer
  opts@pmLabelBarHeightF          = 0.075

  opts@tiMainString               = vartitle1+" Diff: "+tag_1+" - "+tag_1b        ; set title for difference plot
  cplot3  = gsn_csm_contour_map(wks2,winter_diff,opts)
;  cplot3b = gsn_csm_contour(wks,prob,res_95)          ; add 95% stat sig
;  overlay(cplot3,cplot3b)
  cplot3c = gsn_csm_contour(wks2,seaice_avg_1,res_ice)
  overlay(cplot3,cplot3c) 
  cplot3d = gsn_csm_contour(wks2,seaice_avg_1,res_ice2)
  overlay(cplot3,cplot3d)  
  plot(3) = cplot3
 
delete(opts)

;;;;;;;;;;;;;
; Make difference plot of seaice
;;;;;;;;;;;;;
  opts                            = res
  opts@cnFillMode                 = cntype
  opts@cnFillOn                   = True
  opts@gsnSpreadColors            = True              ; use full colormap
  opts@gsnSpreadColorStart        = spreadstart2      ; start at color specified above
  opts@gsnSpreadColorEnd          = spreadend2        ; end at color specified above
  opts@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  opts@cnMinLevelValF             = -0.2              ; set min contour level specified above
  opts@cnMaxLevelValF             =  0.2              ; set max contour level specified above
  opts@cnLevelSpacingF            = 0.02               ; set contour spacing specified above
  opts@cnLinesOn                  = difflines         ; contour lines specified above
  opts@cnLineLabelsOn             = difflines
  opts@cnMissingValFillColor      = "gray85"          ; missing value color
  opts@cnMissingValFillPattern    = 0                 ; fill in
  opts@tiMainFontHeightF          = 0.013
  opts@lbLabelStride              = 2
  opts@pmLabelBarOrthogonalPosF   = -0.01             ; move label bar closer
  opts@pmLabelBarHeightF          = 0.075

  opts@tiMainString               = "Seaice frac Diff: "+tag_1+" - "+tag_1b        ; set title for difference plot
  cplot4  = gsn_csm_contour_map(wks2,winter_seaice_diff,opts)  
  plot(2) = cplot4
 
delete(opts)

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
title_fin = vartitle1 + " ("+var1@units+")"

  res_pan                            = True
  res_pan@txString                   = title_fin        ; main title
  res_pan@txFontHeightF              = 0.02
  res_pan@gsnPaperOrientation        = "landscape"      ; landscape mode
  res_pan@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  res_pan@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  res_pan@gsnPanelScalePlotIndex     = 1
  res_pan@gsnMaximize                = True	       ; fill the page
  gsn_panel(wks2,(/plot/),(/2,2/),res_pan)               ; create final panel plot


; Finally - make plot
  print("converting plot 2 to png")
  convert_cmd = "convert -density 300 "+fout2+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout2+".png"
  system(convert_cmd)

  ;delete(res)
  ;delete(res_ice)
  ;delete(res_pan)
  delete(title_fin)
  delete(additional_colors)
  delete(plot)
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 3 - Winter averages and difference from net avg files
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot3").and.(plot3))then  ; if plotting is turned on
print("Plot 3 - winter averages and difference from net avgs")
fout3   = varcode+"_diff_"+datatitle1+"_"+datatitle1b+"_winter_net_diff-case"+type
  wks3 = gsn_open_wks("ps" ,fout3)
  additional_colors = (/"gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks3,colormap,additional_colors)
  plot = new(4, graphic)

;;;;;;;;;;;;;
; Set resources for variable plots
;;;;;;;;;;;;
; Same resources, except we add 95% stat significance

; set resources for 95% statistical significance overlay
  res_95                            = True               ; reset options
  res_95@gsnLeftString              = ""
  res_95@gsnRightString             = ""
  res_95@gsnFrame                   = False             ; Do not draw plot 
  res_95@gsnDraw                    = False             ; Do not advance fr
  res_95@cnInfoLabelOn              = False             ; Turn off info on contours at bottom
  res_95@lbLabelBarOn               = False             ; Turn off label bar

;  res_95@cnLevelSelectionMode       = "ExplicitLevels"
;  res_95@cnLevels                   = (/0., 95./)
;  res_95@cnFillOn                   = True
;  res_95@cnMonoFillPattern          = False
;  res_95@cnFillPatterns             = (/3, -1/) 
;  res_95@lbLabelBarOn               = True

  res_95@cnFillOn                   = True             ; turn on filled contours
  res_95@cnMonoFillColor            = True
  res_95@cnMonoFillPattern          = False
  res_95@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  res_95@cnMinLevelValF             = 0.                ; set min contour level specified above
  res_95@cnMaxLevelValF             = 95.              ; set max contour level specified above
  res_95@cnLevelSpacingF            = 95.              ; set contour spacing specified above
  res_95@cnFillPatterns             = (/-1,-1,17/)      ; hatch marks over areas where >99% sig. diff
  ;res_95@cnLinesOn                  = True              ; contour lines specified above
  ;res_95@cnLineLabelsOn             = True             ; line labels on specified above
  ;res_95@cnLineColor                = "black"
  ;res_95@cnLineThicknessF           = 2.0

;  res_95@tiXAxisOn                  = False
;  res_95@tiYAxisOn                  = False
;;;;;;;;;;;;;
; Make normal plots
;;;;;;;;;;;;;
  opts                            = res               ; reset options
  opts@cnFillMode                 = cntype
  opts@cnFillOn                   = True              ; turn on filled contours
  opts@gsnSpreadColors            = True              ; use full colormap
  opts@gsnSpreadColorStart        = spreadstart1      ; start at color specified for each variable above
  opts@gsnSpreadColorEnd          = spreadend1        ; end at color specified above
  opts@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  opts@cnMinLevelValF             = cmin1             ; set min contour level specified above
  opts@cnMaxLevelValF             = cmax1             ; set max contour level specified above
  opts@cnLevelSpacingF            = clev1             ; set contour spacing specified above
  opts@cnLinesOn                  = plotlines         ; contour lines specified above
  opts@cnLineLabelsOn             = plotlines         ; line labels on specified above
  opts@cnMissingValFillColor      = "gray85"          ; missing value color
  opts@cnMissingValFillPattern    = 0                 ; fill in
  opts@cnMissingValPerimOn        = True
  opts@cnMissingValPerimColor     = "black"
  opts@tiMainFontHeightF          = 0.013
  opts@lbLabelStride              = stride1
  opts@pmLabelBarOrthogonalPosF   = -0.01             ; move label bar closer
  opts@pmLabelBarHeightF          = 0.075             ; set height of labelbar

  opts@tiMainString               = datatitle1            ; title string specified from cshell
  cplot0  = gsn_csm_contour_map(wks3,avg1,opts)
  cplot0b = gsn_csm_contour(wks3,avg_seaice_1,res_ice)
  overlay(cplot0,cplot0b)
  cplot0c = gsn_csm_contour(wks3,avg_seaice_1,res_ice2)
  overlay(cplot0,cplot0c)
  plot(0) = cplot0
    
  opts@tiMainString               = datatitle1b            ; title string specified from cshell
  cplot1  = gsn_csm_contour_map(wks3,avg1b,opts)
  cplot1b = gsn_csm_contour(wks3,avg_seaice_1b,res_ice)
  overlay(cplot1,cplot1b)
  cplot1c = gsn_csm_contour(wks3,avg_seaice_1b,res_ice2)
  overlay(cplot1,cplot1c)
  plot(1) = cplot1

delete(opts)

;;;;;;;;;;;;;
; Make difference plot
;;;;;;;;;;;;;
  opts                            = res
  opts@cnFillMode                 = cntype
  opts@cnFillOn                   = True
  opts@gsnSpreadColors            = True              ; use full colormap
  opts@gsnSpreadColorStart        = spreadstart2      ; start at color specified above
  opts@gsnSpreadColorEnd          = spreadend2        ; end at color specified above
  opts@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  opts@cnMinLevelValF             = cmin2             ; set min contour level specified above
  opts@cnMaxLevelValF             = cmax2             ; set max contour level specified above
  opts@cnLevelSpacingF            = clev2             ; set contour spacing specified above
  opts@cnLinesOn                  = difflines         ; contour lines specified above
  opts@cnLineLabelsOn             = difflines
  opts@cnMissingValFillColor      = "gray85"          ; missing value color
  opts@cnMissingValFillPattern    = 0                 ; fill in
  opts@tiMainFontHeightF          = 0.013
  opts@lbLabelStride              = stride2
  opts@pmLabelBarOrthogonalPosF   = -0.01             ; move label bar closer
  opts@pmLabelBarHeightF          = 0.075

  opts@tiMainString               = vartitle1+" Diff: "+tag_1+" - "+tag_1b        ; set title for difference plot
  cplot3  = gsn_csm_contour_map(wks3,avg_diff,opts)
  cplot3b = gsn_csm_contour(wks3,avg_prob,res_95)          ; add 95% stat sig
  overlay(cplot3,cplot3b)
  cplot3c = gsn_csm_contour(wks3,seaice_avg_1,res_ice)
  overlay(cplot3,cplot3c) 
  cplot3d = gsn_csm_contour(wks3,seaice_avg_1,res_ice2)
  overlay(cplot3,cplot3d) 
  plot(3) = cplot3
 
delete(opts)

;;;;;;;;;;;;;
; Make difference plot of seaice
;;;;;;;;;;;;;
  opts                            = res
  opts@cnFillMode                 = cntype
  opts@cnFillOn                   = True
  opts@gsnSpreadColors            = True              ; use full colormap
  opts@gsnSpreadColorStart        = spreadstart2      ; start at color specified above
  opts@gsnSpreadColorEnd          = spreadend2        ; end at color specified above
  opts@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  opts@cnMinLevelValF             = -0.2              ; set min contour level specified above
  opts@cnMaxLevelValF             =  0.2              ; set max contour level specified above
  opts@cnLevelSpacingF            = 0.02               ; set contour spacing specified above
  opts@cnLinesOn                  = difflines         ; contour lines specified above
  opts@cnLineLabelsOn             = difflines
  opts@cnMissingValFillColor      = "gray85"          ; missing value color
  opts@cnMissingValFillPattern    = 0                 ; fill in
  opts@tiMainFontHeightF          = 0.013
  opts@lbLabelStride              = 2
  opts@pmLabelBarOrthogonalPosF   = -0.01             ; move label bar closer
  opts@pmLabelBarHeightF          = 0.075

  opts@tiMainString               = "Seaice frac Diff: "+tag_1+" - "+tag_1b        ; set title for difference plot
  cplot4  = gsn_csm_contour_map(wks3,winter_seaice_diff,opts)  
  plot(2) = cplot4
 
delete(opts)

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
title_fin = vartitle1 + " ("+var1@units+")"

  pnlres                            = True
  pnlres@txString                   = title_fin        ; main title
  pnlres@txFontHeightF              = 0.02
  pnlres@gsnPaperOrientation        = "landscape"      ; landscape mode
  pnlres@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelScalePlotIndex     = 1
  pnlres@gsnMaximize                = True	       ; fill the page
  gsn_panel(wks3,(/plot/),(/2,2/),pnlres)               ; create final panel plot

  print("converting plot 3 to png")
; convert to png 
  convert_cmd = "convert -density 300 "+fout3+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout3+".png"

  system(convert_cmd)

  delete(res)
  delete(res_ice)
  delete(res_pan)
  delete(title_fin)
  delete(additional_colors)
  delete(plot)
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 4 - Winter averages for nodes - variable 1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot4").and.(plot4))then  ; if plotting is turned on
print("Plot 4 - winter node averages for "+datatitle1)
fout4   = varcode+"_"+datatitle1+"_node_avg-case"+type

  wks4 = gsn_open_wks("ps" ,fout4)
  additional_colors = (/"black","gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks4,colormap,additional_colors)
  plot = new(nnode, graphic)

;;;;;;;;;;;;;
; Set resources used for all plots
;;;;;;;;;;;;

  res                             = True              ; plot mods desired
  res@gsnRightString              = ""
 ; res@gsnLeftString               = ""               ; Set this in loop
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
  res@gsnSpreadColorStart        = spreadstart3      ; start at color specified for each variable above
  res@gsnSpreadColorEnd          = spreadend3        ; end at color specified above
  res@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  res@cnMinLevelValF             = cmin3             ; set min contour level specified above
  res@cnMaxLevelValF             = cmax3             ; set max contour level specified above
  res@cnLevelSpacingF            = clev3             ; set contour spacing specified above
  res@cnLinesOn                  = plotlines         ; contour lines specified above
  res@cnLineLabelsOn             = plotlines         ; line labels on specified above
  res@cnMissingValFillColor      = "gray85"          ; missing value color
  res@cnMissingValFillPattern    = 0                 ; fill in
  res@cnMissingValPerimOn        = True
  res@cnMissingValPerimColor     = "black"
  res@lbLabelBarOn               = False             ; have single label bar

; set resources for sea ice overlay
  res_ice                            = True               ; reset options
  res_ice@gsnLeftString              = ""
  res_ice@gsnRightString             = ""
  res_ice@gsnFrame                   = False             ; Do not draw plot 
  res_ice@gsnDraw                    = False             ; Do not advance fr
  res_ice@cnInfoLabelOn              = False             ; Turn off info on contours at bottom
  res_ice@cnFillOn                   = False             ; turn on filled contours
  res_ice@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  res_ice@cnMinLevelValF             = 0.                ; set min contour level specified above
  res_ice@cnMaxLevelValF             = 0.15              ; set max contour level specified above
  res_ice@cnLevelSpacingF            = 0.15              ; set contour spacing specified above
  res_ice@cnLinesOn                  = True              ; contour lines specified above
  res_ice@cnLineLabelsOn             = False             ; line labels on specified above
  res_ice@cnLineThicknessF           = 1.5
  res_ice@tiXAxisOn                  = False
  res_ice@tiYAxisOn                  = False
  res_ice@cnLineColor                = "black" ;"gray85"

; set resources for sea ice overlay
  res_ice2                            = res_ice               ; reset options
  res_ice2@cnMinLevelValF             = 0.                ; set min contour level specified above
  res_ice2@cnMaxLevelValF             = 0.85              ; set max contour level specified above
  res_ice2@cnLevelSpacingF            = 0.85              ; set contour spacing specified above
  res_ice2@cnLineColor                = "black" ;"gray85"
  res_ice2@cnLineThicknessF           = 2.0
  res_ice2@cnLineDashPattern          = 6
 
xpos = 0
ypos = 0

do n = 0, nnode-1
  ;print("Plotting graph "+n+" ("+xpos+","+ypos+")")
  var1_2d = var1(n,:,:)
  seaice_1_2d = seaice_1(n,:,:)

  res@gsnLeftString = "("+xpos+","+ypos+")"  ; (this changes)
  res@gsnLeftStringParallelPosF = 0.02 ; scoot it in just a bit as well

  cplot  = gsn_csm_contour_map(wks4,var1_2d,res)
  cplot2 = gsn_csm_contour(wks4,seaice_1_2d,res_ice)
  overlay(cplot,cplot2)
  cplot2b = gsn_csm_contour(wks4,seaice_1_2d,res_ice2)
  overlay(cplot,cplot2b)
  plot(n) = cplot

; Update xpos and ypos for next time through:
  xpos = xpos + 1
  if (xpos.eq.nx_node) then
    xpos = 0
    ypos = ypos + 1
  end if
end do

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
print("Paneling...")
title_fin = "Node "+vartitle1+" : "+datatitle1

res_pan                       = True ; panel resources
res_pan@txString              = title_fin
res_pan@txFontHeightF         = 0.015 ; title font height
res_pan@gsnPaperOrientation   = "landscape" ; landscape mode
res_pan@gsnMaximize           = True ; make it big
res_pan@gsnPanelLabelBar      = True ; common label bar
res_pan@lbTitleString         = var1@units
res_pan@lbTitlePosition       = "right"
res_pan@lbLabelStride         = stride3
res_pan@lbLabelFontHeightF    = 0.01
res_pan@lbTitleJust           = "CenterLeft"
res_pan@lbTitleFontHeightF    = 0.01 
res_pan@lbTitleDirection      = "Across"

gsn_panel(wks4,(/plot/),(/ny_node, nx_node/),res_pan)

  print("converting plot 4 to png")
  convert_cmd = "convert -density 300 "+fout4+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout4+".png"

  system(convert_cmd)

delete(res_pan)
delete(additional_colors)
delete(plot)
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 5 - Winter averages for nodes - variable 1b
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot5").and.(plot5))then  ; if plotting is turned on
print("Plot 5 - winter node averages for "+datatitle1b)
fout5   = varcode+"_"+datatitle1b+"_node_avg-case"+type

  wks5 = gsn_open_wks("ps" ,fout5)
  additional_colors = (/"black","gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks5,colormap,additional_colors)
  plot = new(nnode, graphic)

  ; resources are the same as the previous set of plots so don't set anything
 
xpos = 0
ypos = 0

do n = 0, nnode-1
  ;print("Plotting graph "+n+" ("+xpos+","+ypos+")")
  var1b_2d = var1b(n,:,:)
  seaice_1b_2d = seaice_1b(n,:,:)

  res@gsnLeftString = "("+xpos+","+ypos+")"  ; (this changes)
  res@gsnLeftStringParallelPosF = 0.02 ; scoot it in just a bit as well

  cplot  = gsn_csm_contour_map(wks5,var1b_2d,res)
  cplot2 = gsn_csm_contour(wks5,seaice_1b_2d,res_ice)
  overlay(cplot,cplot2)
  cplot2b = gsn_csm_contour(wks5,seaice_1b_2d,res_ice2)
  overlay(cplot,cplot2b)
  plot(n) = cplot

; Update xpos and ypos for next time through:
  xpos = xpos + 1
  if (xpos.eq.nx_node) then
    xpos = 0
    ypos = ypos + 1
  end if
end do

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
print("Paneling...")
title_fin = "Node "+vartitle1+" : "+datatitle1b

res_pan                       = True ; panel resources
res_pan@txString              = title_fin
res_pan@txFontHeightF         = 0.015 ; title font height
res_pan@gsnPaperOrientation   = "landscape" ; landscape mode
res_pan@gsnMaximize           = True ; make it big
res_pan@gsnPanelLabelBar      = True ; common label bar
res_pan@lbTitleString         = var1@units
res_pan@lbTitlePosition       = "right"
res_pan@lbLabelStride         = stride3
res_pan@lbLabelFontHeightF    = 0.01
res_pan@lbTitleJust           = "CenterLeft"
res_pan@lbTitleFontHeightF    = 0.01 
res_pan@lbTitleDirection      = "Across"

gsn_panel(wks5,(/plot/),(/ny_node, nx_node/),res_pan)

  print("converting plot 5 to png")
  convert_cmd = "convert -density 300 "+fout5+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout5+".png"

  system(convert_cmd)

delete(res)
delete(res_ice)
delete(res_pan)
delete(additional_colors)
delete(plot)
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 6 - Winter averages differences for nodes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot6").and.(plot6))then  ; if plotting is turned on
print("Plot 6 - winter node differences averages for "+datatitle1+" and "+datatitle1b)
fout6   = varcode+"_diff_"+datatitle1+"_"+datatitle1b+"_node_avg-case"+type

  wks6 = gsn_open_wks("ps" ,fout6)
  additional_colors = (/"black","gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks6,colormap,additional_colors)
  plot = new(nnode, graphic)

;;;;;;;;;;;;;
; Set resources used for all plots
;;;;;;;;;;;;

  res                             = True              ; plot mods desired
  res@gsnRightString              = ""
 ; res@gsnLeftString               = ""               ; Set this in loop
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
  res@gsnSpreadColorStart        = spreadstart4      ; start at color specified for each variable above
  res@gsnSpreadColorEnd          = spreadend4        ; end at color specified above
  res@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  res@cnMinLevelValF             = cmin4             ; set min contour level specified above
  res@cnMaxLevelValF             = cmax4             ; set max contour level specified above
  res@cnLevelSpacingF            = clev4             ; set contour spacing specified above
  res@cnLinesOn                  = plotlines         ; contour lines specified above
  res@cnLineLabelsOn             = plotlines         ; line labels on specified above
  res@cnMissingValFillColor      = "gray85"          ; missing value color
  res@cnMissingValFillPattern    = 0                 ; fill in
  res@cnMissingValPerimOn        = True
  res@cnMissingValPerimColor     = "black"
  res@lbLabelBarOn               = False             ; have single label bar

; set resources for sea ice overlay
  res_ice                            = True               ; reset options
  res_ice@gsnLeftString              = ""
  res_ice@gsnRightString             = ""
  res_ice@gsnFrame                   = False             ; Do not draw plot 
  res_ice@gsnDraw                    = False             ; Do not advance fr
  res_ice@cnInfoLabelOn              = False             ; Turn off info on contours at bottom
  res_ice@cnFillOn                   = False             ; turn on filled contours
  res_ice@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  res_ice@cnMinLevelValF             = 0.                ; set min contour level specified above
  res_ice@cnMaxLevelValF             = 0.15              ; set max contour level specified above
  res_ice@cnLevelSpacingF            = 0.15              ; set contour spacing specified above
  res_ice@cnLinesOn                  = True              ; contour lines specified above
  res_ice@cnLineLabelsOn             = False             ; line labels on specified above
  res_ice@cnLineThicknessF           = 1.5
  res_ice@tiXAxisOn                  = False
  res_ice@tiYAxisOn                  = False
  res_ice@cnLineColor                = "black" ;"gray85"

; set resources for sea ice overlay
  res_ice2                            = res_ice               ; reset options
  res_ice2@cnMinLevelValF             = 0.                ; set min contour level specified above
  res_ice2@cnMaxLevelValF             = 0.85              ; set max contour level specified above
  res_ice2@cnLevelSpacingF            = 0.85              ; set contour spacing specified above
  res_ice2@cnLineColor                = "black" ;"gray85"
  res_ice2@cnLineThicknessF           = 2.0
  res_ice2@cnLineDashPattern          = 6

; set resources for 95% statistical significance overlay
  res_95                            = True               ; reset options
  res_95@gsnLeftString              = ""
  res_95@gsnRightString             = ""
  res_95@gsnFrame                   = False             ; Do not draw plot 
  res_95@gsnDraw                    = False             ; Do not advance fr
  res_95@cnInfoLabelOn              = False             ; Turn off info on contours at bottom
  res_95@lbLabelBarOn               = False             ; Turn off label bar
  res_95@cnFillOn                   = True             ; turn on filled contours
  res_95@cnMonoFillColor            = True
  res_95@cnMonoFillPattern          = False
  res_95@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  res_95@cnMinLevelValF             = 0.                ; set min contour level specified above
  res_95@cnMaxLevelValF             = 95.              ; set max contour level specified above
  res_95@cnLevelSpacingF            = 95.              ; set contour spacing specified above
  res_95@cnFillPatterns             = (/-1,-1,17/)      ; stipling over areas where >99% sig. diff
  res_95@lbLabelBarOn               = False             ; have single label bar
 
xpos = 0
ypos = 0

do n = 0, nnode-1
  ;print("Plotting graph "+n+" ("+xpos+","+ypos+")")
  diff_2d = diff(n,:,:)
  seaice_2d = seaice_1(n,:,:)
  if (type .eq. "1")
    prob_2d = prob(n,:,:)
  end if
  res@gsnLeftString = "("+xpos+","+ypos+")"  ; (this changes)
  res@gsnLeftStringParallelPosF = 0.02 ; scoot it in just a bit as well

  cplot  = gsn_csm_contour_map(wks6,diff_2d,res)
  cplot2 = gsn_csm_contour(wks6,seaice_2d,res_ice)
  overlay(cplot,cplot2)
  cplot2b = gsn_csm_contour(wks6,seaice_2d,res_ice2)
  overlay(cplot,cplot2b)
  if(type .eq. "1")then
    cplot3 = gsn_csm_contour(wks6,prob_2d,res_95)
    overlay(cplot,cplot3)
  end if
  plot(n) = cplot

; Update xpos and ypos for next time through:
  xpos = xpos + 1
  if (xpos.eq.nx_node) then
    xpos = 0
    ypos = ypos + 1
  end if
end do

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
print("Paneling...")
title_fin = "Node Diff "+vartitle1+"~C~ ("+datatitle1+" - "+datatitle1b+")"

res_pan                       = True ; panel resources
res_pan@txString              = title_fin
res_pan@txFontHeightF         = 0.015 ; title font height
res_pan@gsnPaperOrientation   = "landscape" ; landscape mode
res_pan@gsnMaximize           = True ; make it big
res_pan@gsnPanelLabelBar      = True ; common label bar
res_pan@lbTitleString         = var1@units
res_pan@lbTitlePosition       = "right"
res_pan@lbLabelStride         = stride3
res_pan@lbLabelFontHeightF    = 0.01
res_pan@lbTitleJust           = "CenterLeft"
res_pan@lbTitleFontHeightF    = 0.01 
res_pan@lbTitleDirection      = "Across"

gsn_panel(wks6,(/plot/),(/ny_node, nx_node/),res_pan)

 print("converting plot 6 to png")
; convert to png
  convert_cmd = "convert -density 300 "+fout6+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout6+".png"

  system(convert_cmd)

delete(res)
delete(res_ice)
delete(res_95)
delete(res_pan)
delete(plot)
delete(additional_colors)
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 7 - Net difference and difference terms
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot7").and.(plot7))then  ; if plotting is turned on
print("Plot 7 - net difference and frequency/node terms")
fout7   = varcode+"_net_difference_contributing_terms-"+datatitle1+"_"+datatitle1b+"-case"+type

  wks7 = gsn_open_wks("ps" ,fout7)
  additional_colors = (/"black","gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks7,colormap,additional_colors)
  plot = new(4, graphic)

;;;;;;;;;;;;;
; Set resources for variable plots
;;;;;;;;;;;;

  res                             = True              ; plot mods desired
  ;res@gsnRightString              = ""
  res@gsnLeftString               = ""               ; Set this in loop
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
  res@cnLinesOn                  = plotlines         ; contour lines specified above
  res@cnLineLabelsOn             = plotlines         ; line labels on specified above
  res@cnMissingValFillColor      = "gray85"          ; missing value color
  res@cnMissingValFillPattern    = 0                 ; fill in
  res@cnMissingValPerimOn        = True
  res@cnMissingValPerimColor     = "black"
  res@lbLabelBarOn               = False             ; single label bar for whole plot

;;;;;;;;;;;;;
; Set resources for variable plots
;;;;;;;;;;;;
; Same resources, except we add 95% stat significance

; set resources for 95% statistical significance overlay
  res_95                            = True               ; reset options
  res_95@gsnLeftString              = ""
  res_95@gsnRightString             = ""
  res_95@gsnFrame                   = False             ; Do not draw plot 
  res_95@gsnDraw                    = False             ; Do not advance fr
  res_95@cnInfoLabelOn              = False             ; Turn off info on contours at bottom
  res_95@lbLabelBarOn               = False             ; Turn off label bar

;  res_95@cnLevelSelectionMode       = "ExplicitLevels"
;  res_95@cnLevels                   = (/0., 95./)
;  res_95@cnFillOn                   = True
;  res_95@cnMonoFillPattern          = False
;  res_95@cnFillPatterns             = (/3, -1/) 
;  res_95@lbLabelBarOn               = True

  res_95@cnFillOn                   = True             ; turn on filled contours
  res_95@cnMonoFillColor            = True
  res_95@cnMonoFillPattern          = False
  res_95@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  res_95@cnMinLevelValF             = 0.                ; set min contour level specified above
  res_95@cnMaxLevelValF             = 95.              ; set max contour level specified above
  res_95@cnLevelSpacingF            = 95.              ; set contour spacing specified above
  res_95@cnFillPatterns             = (/-1,-1,17/)      ; hatch marks over areas where >99% sig. diff
  ;res_95@cnLinesOn                  = True              ; contour lines specified above
  ;res_95@cnLineLabelsOn             = True             ; line labels on specified above
  ;res_95@cnLineColor                = "black"
  ;res_95@cnLineThicknessF           = 2.0

;  res_95@tiXAxisOn                  = False
;  res_95@tiYAxisOn                  = False

;;;;;;;;;;;;;
; Make plot 0 - net difference
;;;;;;;;;;;;;
  title0 = "Net difference"
  opts = res
  opts@gsnRightString             = term_total_pcnt+"%"
  opts@tiMainString               = title0            ; title string specified from cshell
  cplot0  = gsn_csm_contour_map(wks7,net_diff,opts)
  cplot0b = gsn_csm_contour(wks7,avg_prob,res_95)          ; add 95% stat sig
  overlay(cplot0,cplot0b)
  plot(0) = cplot0
  delete(opts)

;;;;;;;;;;;;;
; Make plot 1 - Frequency difference term
;;;;;;;;;;;;;
  title1 = "Frequency Component"
  opts = res
  opts@gsnRightString             = sprintf("%5.2f",term1_pcnt)+"%"
  opts@tiMainString               = title1            ; title string specified from cshell
  cplot1  = gsn_csm_contour_map(wks7,term1_sum,opts)
  plot(1) = cplot1
  delete(opts)
  
;;;;;;;;;;;;;
; Make plot 2 - Difference in nodes
;;;;;;;;;;;;;
  title2 = "Intrapattern Variability Component"
  opts = res
  opts@gsnRightString             = sprintf("%5.2f",term2_pcnt)+"%"
  opts@tiMainString               = title2            ; title string specified from cshell
  cplot2  = gsn_csm_contour_map(wks7,term2_sum,opts)
  plot(2) = cplot2
  delete(opts)

;;;;;;;;;;;;;
; Make plot 3 - Combined term
;;;;;;;;;;;;;
  title3 = "Combined Component"
  opts = res
  opts@gsnRightString             = sprintf("%5.2f",term3_pcnt)+"%"
  opts@tiMainString               = title3            ; title string specified from cshell
  cplot3  = gsn_csm_contour_map(wks7,term3_sum,opts)
  plot(3) = cplot3
  delete(opts)

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
title_fin = vartitle1 + " Diff ("+var1@units+") ~C~"+datatitle1+" - "+datatitle1b

  res_pan                            = True
  res_pan@txString                   = title_fin        ; main title
  res_pan@txFontHeightF              = 0.02
  res_pan@gsnPaperOrientation        = "landscape"      ; landscape mode
  res_pan@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  res_pan@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  res_pan@gsnPanelScalePlotIndex     = 1
  res_pan@gsnMaximize                = True	       ; fill the page
  res_pan@gsnPanelLabelBar           = True
  res_pan@lbTitleString              = var1@units
  res_pan@lbTitlePosition            = "right"
  res_pan@lbLabelStride              = stride2
  res_pan@lbLabelFontHeightF         = 0.01
  res_pan@lbTitleJust                = "CenterLeft"
  res_pan@lbTitleFontHeightF         = 0.01
  res_pan@lbTitleDirection           = "Across"
  gsn_panel(wks7,(/plot/),(/2,2/),res_pan)               ; create final panel plot

  print("converting plot 7 to png")
; convert to png 
  convert_cmd = "convert -density 300 "+fout7+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout7+".png"

  system(convert_cmd)

delete(res)
delete(res_pan)
delete(plot)
delete(additional_colors)
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 8 - Net difference and difference terms
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot8").and.(plot8))then  ; if plotting is turned on
print("Plot 8 - ratio of frequency/node terms to net difference")
fout8   = varcode+"_ratio_contributing_terms_to_net_difference_-"+datatitle1+"_"+datatitle1b+"-case"+type

  wks8 = gsn_open_wks("ps" ,fout8)
  additional_colors = (/"black","gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks8,colormap,additional_colors)
  plot = new(4, graphic)

;;;;;;;;;;;;;
; Set resources for variable plots
;;;;;;;;;;;;

  res                             = True              ; plot mods desired
  res@gsnRightString              = ""
  res@gsnLeftString               = ""               ; Set this in loop
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
  res@cnLinesOn                  = plotlines         ; contour lines specified above
  res@cnLineLabelsOn             = plotlines         ; line labels on specified above
  res@cnMissingValFillColor      = "gray85"          ; missing value color
  res@cnMissingValFillPattern    = 0                 ; fill in
  res@cnMissingValPerimOn        = True
  res@cnMissingValPerimColor     = "black"
  res@lbLabelStride              = stride2
  res@tiMainFontHeightF          = 0.02

;;;;;;;;;;;;;
; Make plot 0 - net difference
;;;;;;;;;;;;;
  title0 = "Net difference"
  opts = res
  
  opts@tiMainString               = title0            ; title string specified from cshell
  cplot0  = gsn_csm_contour_map(wks8,net_diff,opts)
  plot(0) = cplot0
  delete(opts)

  res@cnMinLevelValF             = -1.5              ; set min contour level specified above
  res@cnMaxLevelValF             = 1.5               ; set max contour level specified above
  res@cnLevelSpacingF            = 0.1               ; set contour spacing specified above
  res@lbLabelStride              = 2

  ; eliminate very small differences
  net_diff = where(net_diff .lt. 1.0 .and. net_diff .gt. -1.0, fill, net_diff)

;;;;;;;;;;;;;
; Make plot 1 - Frequency difference term
;;;;;;;;;;;;;
  title1 = "Frequency Component/Net difference"
  dum = term1_sum/net_diff
  copy_VarMeta(term1_sum,dum)
  opts = res
  opts@tiMainString               = title1            ; title string specified from cshell
  cplot1  = gsn_csm_contour_map(wks8,dum,opts)
  plot(1) = cplot1
  delete(opts)
  delete(dum)
  
;;;;;;;;;;;;;
; Make plot 2 - Difference in nodes
;;;;;;;;;;;;;
  title2 = "Intrapattern Variability Component/Net difference"
  dum = term2_sum/net_diff
  copy_VarMeta(term2_sum,dum)
  opts = res
  opts@tiMainString               = title2            ; title string specified from cshell
  cplot2  = gsn_csm_contour_map(wks8,dum,opts)
  plot(2) = cplot2
  delete(opts)
  delete(dum)

;;;;;;;;;;;;;
; Make plot 3 - Combined term
;;;;;;;;;;;;;
  title3 = "Combined Component/Net difference"
  dum = term3_sum/net_diff
  copy_VarMeta(term3_sum,dum)
  opts = res
  opts@tiMainString               = title3            ; title string specified from cshell
  cplot3  = gsn_csm_contour_map(wks8,dum,opts)
  plot(3) = cplot3
  delete(opts)
  delete(dum)

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
title_fin = vartitle1 + " Ratio components of Difference ("+var1@units+") ~C~"+datatitle1+" - "+datatitle1b

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
  gsn_panel(wks8,(/plot/),(/2,2/),res_pan)               ; create final panel plot

  print("converting plot 8 to png")
; convert to png 
  convert_cmd = "convert -density 300 "+fout8+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout8+".png"

  system(convert_cmd)

delete(res)
delete(res_pan)
delete(additional_colors)
delete(plot)
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 9 - Nodes with sums of three difference terms
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot9").and.(plot9))then  ; if plotting is turned on
print("Plot 9 - winter node differences for "+datatitle1+" and "+datatitle1b)
fout9   = varcode+"_nodes_sum_difference_components_"+datatitle1+"_"+datatitle1b+"-case"+type

  wks9 = gsn_open_wks("ps" ,fout9)
  additional_colors = (/"black","gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks9,colormap,additional_colors)
  plot = new(nnode, graphic)

;;;;;;;;;;;;;
; Set resources used for all plots
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
  res@cnMinLevelValF             = cmin5             ; set min contour level specified above
  res@cnMaxLevelValF             = cmax5             ; set max contour level specified above
  res@cnLevelSpacingF            = clev5             ; set contour spacing specified above
  res@cnLinesOn                  = plotlines         ; contour lines specified above
  res@cnLineLabelsOn             = plotlines         ; line labels on specified above
  res@cnMissingValFillColor      = "gray85"          ; missing value color
  res@cnMissingValFillPattern    = 0                 ; fill in
  res@cnMissingValPerimOn        = True
  res@cnMissingValPerimColor     = "black"
  res@lbLabelBarOn               = False             ; have single label bar
 
xpos = 0
ypos = 0

do n = 0, nnode-1
  ;print("Plotting graph "+n+" ("+xpos+","+ypos+")")
  sum_2d = nodes_sum_all(n,:,:)
  res@gsnLeftString = "("+xpos+","+ypos+")"  ; (this changes)
  res@gsnLeftStringParallelPosF = 0.02 ; scoot it in just a bit as well
  res@gsnRightString             = sprintf("%5.2f",nodes_all_pcnt(n))+"%"

  if(nx_input .eq. "7")then
    if(abs(nodes_all_pcnt(n)) .gt. 2.8)then
      res@gsnRightStringFontColor = "black"
    else
      res@gsnRightStringFontColor = "gray85"
    end if
  end if
  if(nx_input .eq. "8")then
    if(abs(nodes_all_pcnt(n)) .gt. 2.1)then
      res@gsnRightStringFontColor = "black"
    else
      res@gsnRightStringFontColor = "gray85"
    end if
  end if

  cplot  = gsn_csm_contour_map(wks9,sum_2d,res)
  plot(n) = cplot

; Update xpos and ypos for next time through:
  xpos = xpos + 1
  if (xpos.eq.nx_node) then
    xpos = 0
    ypos = ypos + 1
  end if
end do

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
print("Paneling...")
title_fin = "Nodes Diff all components for "+vartitle1+" ~C~ "+datatitle1+" - "+datatitle1b

res_pan                       = True ; panel resources
res_pan@txString              = title_fin
res_pan@txFontHeightF         = 0.015 ; title font height
res_pan@gsnPaperOrientation   = "landscape" ; landscape mode
res_pan@gsnMaximize           = True ; make it big
res_pan@gsnPanelLabelBar      = True ; common label bar
res_pan@lbTitleString         = var1@units
res_pan@lbTitlePosition       = "right"
res_pan@lbLabelStride         = stride2
res_pan@lbLabelFontHeightF    = 0.01
res_pan@lbTitleJust           = "CenterLeft"
res_pan@lbTitleFontHeightF    = 0.01 
res_pan@lbTitleDirection      = "Across"

gsn_panel(wks9,(/plot/),(/ny_node, nx_node/),res_pan)

  print("converting plot 9 to png")
  convert_cmd = "convert -density 300 "+fout9+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout9+".png"

  system(convert_cmd)
  delete(plot)
  delete(res_pan)
  delete(additional_colors)
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 10 - Nodes with sums frequency component
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot10").and.(plot10))then  ; if plotting is turned on
print("Plot 10 - winter node frequency component differences for "+datatitle1+" and "+datatitle1b)
fout10   = varcode+"_nodes_frequency_component_difference_"+datatitle1+"_"+datatitle1b+"-case"+type

  wks10 = gsn_open_wks("ps" ,fout10)
  additional_colors = (/"black","gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks10,colormap,additional_colors)
  plot = new(nnode, graphic)

  ; Resources are the same as the previous plot
 
xpos = 0
ypos = 0

do n = 0, nnode-1
  ;print("Plotting graph "+n+" ("+xpos+","+ypos+")")
  term1_2d = term1(n,:,:)
  res@gsnLeftString = "("+xpos+","+ypos+")"  ; (this changes)
  res@gsnLeftStringParallelPosF = 0.02 ; scoot it in just a bit as well
  res@gsnRightString             = sprintf("%5.2f",nodes_term1_pcnt(n))+"%"

  if(nx_input .eq. "7")then
    if(abs(nodes_term1_pcnt(n)) .gt. 2.8)then
      res@gsnRightStringFontColor = "black"
    else
      res@gsnRightStringFontColor = "gray85"
    end if
  end if
  if(nx_input .eq. "8")then
    if(abs(nodes_term1_pcnt(n)) .gt. 2.1)then
      res@gsnRightStringFontColor = "black"
    else
      res@gsnRightStringFontColor = "gray85"
    end if
  end if

  cplot  = gsn_csm_contour_map(wks10,term1_2d,res)
  plot(n) = cplot

; Update xpos and ypos for next time through:
  xpos = xpos + 1
  if (xpos.eq.nx_node) then
    xpos = 0
    ypos = ypos + 1
  end if
end do

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
print("Paneling...")
title_fin = "Nodes Diff frequency component for "+vartitle1+" ~C~ "+datatitle1+" - "+datatitle1b

res_pan                       = True ; panel resources
res_pan@txString              = title_fin
res_pan@txFontHeightF         = 0.015 ; title font height
res_pan@gsnPaperOrientation   = "landscape" ; landscape mode
res_pan@gsnMaximize           = True ; make it big
res_pan@gsnPanelLabelBar      = True ; common label bar
res_pan@lbTitleString         = var1@units
res_pan@lbTitlePosition       = "right"
res_pan@lbLabelStride         = stride2
res_pan@lbLabelFontHeightF    = 0.01
res_pan@lbTitleJust           = "CenterLeft"
res_pan@lbTitleFontHeightF    = 0.01 
res_pan@lbTitleDirection      = "Across"

gsn_panel(wks10,(/plot/),(/ny_node, nx_node/),res_pan)

  print("converting plot 10 to png")
  convert_cmd = "convert -density 300 "+fout10+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout10+".png"

  system(convert_cmd)
  delete(plot)
  delete(res_pan)
  delete(additional_colors)
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 11 - Nodes with sums frequency component
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot11").and.(plot11))then  ; if plotting is turned on
print("Plot 11 - winter node frequency component differences for "+datatitle1+" and "+datatitle1b)
fout11   = varcode+"_nodes_intrapattern_component_difference_"+datatitle1+"_"+datatitle1b+"-case"+type

  wks11 = gsn_open_wks("ps" ,fout11)
  additional_colors = (/"black","gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks11,colormap,additional_colors)
  plot = new(nnode, graphic)

  ; Resources are the same as the previous plot
 
xpos = 0
ypos = 0

do n = 0, nnode-1
  ;print("Plotting graph "+n+" ("+xpos+","+ypos+")")
  term2_2d = term2(n,:,:)
  res@gsnLeftString = "("+xpos+","+ypos+")"  ; (this changes)
  res@gsnLeftStringParallelPosF = 0.02 ; scoot it in just a bit as well
  res@gsnRightString             = sprintf("%5.2f",nodes_term2_pcnt(n))+"%"

  if(nx_input .eq. "7")then
    if(abs(nodes_term2_pcnt(n)) .gt. 2.8)then
      res@gsnRightStringFontColor = "black"
    else
      res@gsnRightStringFontColor = "gray85"
    end if
  end if
  if(nx_input .eq. "8")then
    if(abs(nodes_term2_pcnt(n)) .gt. 2.1)then
      res@gsnRightStringFontColor = "black"
    else
      res@gsnRightStringFontColor = "gray85"
    end if
  end if

  cplot  = gsn_csm_contour_map(wks11,term2_2d,res)
  plot(n) = cplot

; Update xpos and ypos for next time through:
  xpos = xpos + 1
  if (xpos.eq.nx_node) then
    xpos = 0
    ypos = ypos + 1
  end if
end do

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
print("Paneling...")
title_fin = "Nodes Diff intrapattern component for "+vartitle1+" ~C~ "+datatitle1+" - "+datatitle1b

res_pan                       = True ; panel resources
res_pan@txString              = title_fin
res_pan@txFontHeightF         = 0.015 ; title font height
res_pan@gsnPaperOrientation   = "landscape" ; landscape mode
res_pan@gsnMaximize           = True ; make it big
res_pan@gsnPanelLabelBar      = True ; common label bar
res_pan@lbTitleString         = var1@units
res_pan@lbTitlePosition       = "right"
res_pan@lbLabelStride         = stride2
res_pan@lbLabelFontHeightF    = 0.01
res_pan@lbTitleJust           = "CenterLeft"
res_pan@lbTitleFontHeightF    = 0.01 
res_pan@lbTitleDirection      = "Across"

gsn_panel(wks11,(/plot/),(/ny_node, nx_node/),res_pan)

  print("converting plot 11 to png")
  convert_cmd = "convert -density 300 "+fout11+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout11+".png"

  system(convert_cmd)
  delete(plot)
  delete(additional_colors)
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 12 - Nodes with sums frequency component
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot12").and.(plot12))then  ; if plotting is turned on
print("Plot 12 - winter node combined component differences for "+datatitle1+" and "+datatitle1b)
fout12   = varcode+"_nodes_combined_component_difference_"+datatitle1+"_"+datatitle1b+"-case"+type

  wks12 = gsn_open_wks("ps" ,fout12)
  additional_colors = (/"black","gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks12,colormap,additional_colors)
  plot = new(nnode, graphic)

  ; Resources are the same as the previous plot
 
xpos = 0
ypos = 0

do n = 0, nnode-1
  ;print("Plotting graph "+n+" ("+xpos+","+ypos+")")
  term3_2d = term3(n,:,:)
  res@gsnLeftString = "("+xpos+","+ypos+")"  ; (this changes)
  res@gsnLeftStringParallelPosF = 0.02 ; scoot it in just a bit as well
  res@gsnRightString             = sprintf("%5.2f",nodes_term3_pcnt(n))+"%"

  if(nx_input .eq. "7")then
    if(abs(nodes_term3_pcnt(n)) .gt. 2.8)then
      res@gsnRightStringFontColor = "black"
    else
      res@gsnRightStringFontColor = "gray85"
    end if
  end if
  if(nx_input .eq. "8")then
    if(abs(nodes_term3_pcnt(n)) .gt. 2.1)then
      res@gsnRightStringFontColor = "black"
    else
      res@gsnRightStringFontColor = "gray85"
    end if
  end if

  cplot  = gsn_csm_contour_map(wks12,term3_2d,res)
  plot(n) = cplot

; Update xpos and ypos for next time through:
  xpos = xpos + 1
  if (xpos.eq.nx_node) then
    xpos = 0
    ypos = ypos + 1
  end if
end do

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
print("Paneling...")
title_fin = "Nodes Diff combined component for "+vartitle1+" ~C~ "+datatitle1+" - "+datatitle1b

res_pan                       = True ; panel resources
res_pan@txString              = title_fin
res_pan@txFontHeightF         = 0.015 ; title font height
res_pan@gsnPaperOrientation   = "landscape" ; landscape mode
res_pan@gsnMaximize           = True ; make it big
res_pan@gsnPanelLabelBar      = True ; common label bar
res_pan@lbTitleString         = var1@units
res_pan@lbTitlePosition       = "right"
res_pan@lbLabelStride         = stride2
res_pan@lbLabelFontHeightF    = 0.01
res_pan@lbTitleJust           = "CenterLeft"
res_pan@lbTitleFontHeightF    = 0.01 
res_pan@lbTitleDirection      = "Across"

gsn_panel(wks12,(/plot/),(/ny_node, nx_node/),res_pan)

  print("converting plot 12 to png")
  convert_cmd = "convert -density 300 "+fout12+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout12+".png"

  system(convert_cmd)

delete(res_pan)
delete(additional_colors)
delete(plot)
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 13 - Percent difference for each node, sum of all terms
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot13").and.(plot13))then  ; if plotting is turned on
print("Plot 13 - Percent contribution of nodes")
fout13   = varcode+"_nodes_pcnt_contribution_all_terms_"+datatitle1+"_"+datatitle1b+"-case"+type

  title = nx_input+"x"+ny_input+" pattern contribution to net difference: 2005-2007 "+tag_1+" and "+tag_1b
  wks13 = gsn_open_wks("ps",fout13)
  gsn_define_colormap(wks13, "BlueRed")

  ; make data into som size for plotting
  nodes_all_pcnt_plot = onedtond(nodes_all_pcnt, (/ny_node,nx_node/))
  ;; Reverse rows(for plotting purposes)
  ;nodes_all_pcnt_plot = nodes_all_pcnt_plot(:,::-1)
  ; Reverse columns(for plotting purposes)
  nodes_all_pcnt_plot = nodes_all_pcnt_plot(::-1,:)

; Begin plotting:    
  plot = new(1, graphic)
  dum1  = new((/nnode/),graphic)
  dum2  = new((/nnode/),graphic)
  dum3  = new((/nnode/),graphic)

; Resources for blank plot:
  res_blank                                = True
  res_blank@gsnFrame                       = False  ; do not frame yet (so we can panel)
  res_blank@gsnDraw                        = False   ; do not draw yet (so we can panel)
  res_blank@gsnMaximize                    = True
  res_blank@trXMinF                        = 0
  res_blank@trXMaxF                        = nx_node
  res_blank@trYMinF                        = 0
  res_blank@trYMaxF                        = ny_node
  res_blank@vpWidthF                       = 0.6           ; this is default
  res_blank@vpHeightF                      = 0.6*ny_node / nx_node  ; set height so each node is square
  res_blank@tiMainFontHeightF              = 0.01
  res_blank@tiMainPosition                 = "Left"
  res_blank@tiMainJust                     = "centerleft"
  res_blank@tmEqualizeXYSizes              = True    ; Equal sizes for tick labels
  res_blank@tmXBMajorLengthF               = 0.0      ; effectively turn off tick marks
  res_blank@tmYLMajorLengthF               = 0.0      ; effectively turn off tick marks
  res_blank@tmXBMode                       = "Explicit"
  res_blank@tmXBLabels                     = ispan(0,nx_node-1,1)+""            ; tick marks
  res_blank@tmXBValues                     = fspan(0, nx_node-1, nx_node) + 0.5 ; position for tick labels
  res_blank@tmYLMode                       = "Explicit"
  res_blank@tmYLLabels                     = ispan(ny_node-1,0,1)+""            ; backwards tick marks
  res_blank@tmYLValues                     = fspan(0, ny_node-1, ny_node) + 0.5 ; position for tick labels
  res_blank@tmXBLabelFontHeightF           = res_blank@tiMainFontHeightF
  res_blank@tiXAxisString                  = "SOM Pattern"
  res_blank@tiYAxisString                  = "SOM Pattern"
  res_blank@tiXAxisFontHeightF             = 0.01
  res_blank@tiYAxisFontHeightF             = 0.01
  res_blank@tiMainString                   = title

  plot = gsn_blank_plot(wks13,res_blank)

; Add in squares:
  xx = (/0., 0., 1., 1., 0./)
  yy = (/0., 1., 1., 0., 0./)

; Polygon resources for color shading:
  res_poly = True
; Text resources for count and freq:
  res_txt = True
  res_txt@txFontHeightF = 0.01
  res_txt@txFont = 22
  res_txt@txFontColor = "white" ;"black"

; get color scales for + and - contribution
  slope = 4./(max(abs(nodes_all_pcnt_plot))-2.8)

; loop through each node to plot
n = 0
do y = 0, ny_node - 1
  do x = 0, nx_node - 1 
    xp = xx + x
    yp = yy + y 
 
    ; Draw boxes
    res_poly@gsFillColor = "white" 
    dum1(n) = gsn_add_polygon(wks13, plot, xp, yp, res_poly)
    dum2(n) = gsn_add_polyline(wks13, plot, xp, yp, res_poly)

    ; color squares by influence
    if (abs(nodes_all_pcnt_plot(y,x)).gt.2.8)then
      color_index = round(slope*nodes_all_pcnt_plot(y,x),3)
      if(color_index .gt. 4)
        res_poly@gsFillColor = 9
        res_txt@txBackgroundFillColor = 9
        res_txt@txFontColor = "black"
      end if
      if(color_index .eq. 4)
        res_poly@gsFillColor = 9
        res_txt@txBackgroundFillColor = 9
        res_txt@txFontColor = "black"
      end if
      if(color_index .eq. 3)
        res_poly@gsFillColor = 8
        res_txt@txBackgroundFillColor = 8
        res_txt@txFontColor = "black"
      end if
      if(color_index .eq. 2)
        res_poly@gsFillColor = 7
        res_txt@txBackgroundFillColor = 7
        res_txt@txFontColor = "black"
      end if
      if(color_index .eq. 1)
        res_poly@gsFillColor = 6
        res_txt@txBackgroundFillColor = 6
        res_txt@txFontColor = "black"
      end if
      if(color_index .lt. 1 .and. color_index .gt. -1)
        res_txt@txBackgroundFillColor = "white"
        res_txt@txFontColor = "black"
      end if
      if(color_index .eq. -1)
        res_poly@gsFillColor = 5
        res_txt@txBackgroundFillColor = 5
        res_txt@txFontColor = "black"
      end if
      if(color_index .eq. -2)
        res_poly@gsFillColor = 4
        res_txt@txBackgroundFillColor = 4
        res_txt@txFontColor = "black"
      end if
      if(color_index .eq. -3)
        res_poly@gsFillColor = 3
        res_txt@txBackgroundFillColor = 3
        res_txt@txFontColor = "black"
      end if
      if(color_index .eq. -4)
        res_poly@gsFillColor = 2
        res_txt@txBackgroundFillColor = 2
        res_txt@txFontColor = "black" ; "white"
      end if
      if(color_index .lt. -4)
        res_poly@gsFillColor = 2
        res_txt@txBackgroundFillColor = 2
        res_txt@txFontColor = "black"
      end if
    end if
    if (abs(nodes_all_pcnt_plot(y,x)).lt.2.8) then
      res_poly@gsFillColor = "white"
      res_txt@txBackgroundFillColor = "white"
      res_txt@txFontColor = "black"
    end if

    ; ; Color squares
   ; ; 2.8% is the contribution we'd have from each if all nodes contributed equally
   ; ; I've set the 6% cutoff arbitrarily to easily see which nodes contribute most
   ; res_txt@txFontColor = "black"
   ; res_txt@txBackgroundFillColor = "white"
   ; if(nodes_all_pcnt_plot(y,x).gt.2.8.and.nodes_all_pcnt_plot(y,x).lt.10.0) then
   ;   res_txt@txBackgroundFillColor = "pink"
   ;   res_txt@txFontColor = "white"
   ; end if
   ; if(nodes_all_pcnt_plot(y,x).ge.10.0)then
   ;   res_txt@txBackgroundFillColor = "red"
   ;   res_txt@txFontColor = "white"
   ; end if
   ; if(nodes_all_pcnt_plot(y,x).lt.-2.8.and.nodes_all_pcnt_plot(y,x).gt.-10.0) then
   ;   res_txt@txBackgroundFillColor = "lightblue"
   ;   res_txt@txFontColor = "white"
   ; end if
   ; if(nodes_all_pcnt_plot(y,x).lt.-10.0) then
   ;   res_txt@txBackgroundFillColor = "blue"
   ;   res_txt@txFontColor = "white"
   ; end if
    text = "Total % of mean: ~C~"+sprintf("%5.2f",nodes_all_pcnt_plot(y,x))+"%"
    dum3(n) = gsn_add_text(wks13, plot, text, xp(0)+.5, yp(0)+.5, res_txt)   
    delete(text)
    delete(res_txt@txBackgroundFillColor)
    delete(res_txt@txFontColor)
    n = n+1
  end do 
end do
  
; Finally - make plot
  draw(plot)
  frame(wks13)
  print("converting plot 13 to png")
  convert_cmd = "convert -density 300 "+fout13+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout13+".png"
  system(convert_cmd)

delete(res_blank)
delete(res_poly)
delete(res_txt)
delete(title)
;delete(additional_colors)
delete(plot)

end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 14 - Percent difference for each node, sum of all terms
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot14").and.(plot14))then  ; if plotting is turned on
print("Plot 14 - Percent contribution of node terms")
fout14   = varcode+"_nodes_pcnt_contribution_terms_"+datatitle1+"_"+datatitle1b+"-case"+type

  title = nx_input+"x"+ny_input+" pattern contribution to net difference: 2005-2007 "+tag_1+" and "+tag_1b
  wks14 = gsn_open_wks("ps",fout14)
  gsn_define_colormap(wks14,"redscale")
  ;gsn_reverse_colormap(wks14)
  ;colors = gsn_retrieve_colormap(wks14) ; load fixed map into "colors"
  ;additional_colors = (/"forestgreen", "blue", "red", "lightblue", "pink"/)
  ;gsn_merge_colormaps(wks14,colors,additional_colors)

  ; make data into som size for plotting
  nodes_term1_pcnt_plot = onedtond(nodes_term1_pcnt, (/ny_node,nx_node/))
  nodes_term2_pcnt_plot = onedtond(nodes_term2_pcnt, (/ny_node,nx_node/))
  nodes_term3_pcnt_plot = onedtond(nodes_term3_pcnt, (/ny_node,nx_node/))
  ; Reverse columns(for plotting purposes)
  nodes_term1_pcnt_plot = nodes_term1_pcnt_plot(::-1,:)
  nodes_term2_pcnt_plot = nodes_term2_pcnt_plot(::-1,:)
  nodes_term3_pcnt_plot = nodes_term3_pcnt_plot(::-1,:)

; Begin plotting:    
  plot = new(1, graphic)
  dum1  = new((/nnode/),graphic)
  dum2  = new((/nnode/),graphic)
  dum3  = new((/nnode/),graphic)
  dum4  = new((/nnode/),graphic)
  dum5  = new((/nnode/),graphic)

; Resources for blank plot:
  res_blank                                = True
  res_blank@gsnFrame                       = False  ; do not frame yet (so we can panel)
  res_blank@gsnDraw                        = False   ; do not draw yet (so we can panel)
  res_blank@gsnMaximize                    = True
  res_blank@trXMinF                        = 0
  res_blank@trXMaxF                        = nx_node
  res_blank@trYMinF                        = 0
  res_blank@trYMaxF                        = ny_node
  res_blank@vpWidthF                       = 0.6           ; this is default
  res_blank@vpHeightF                      = 0.6*ny_node / nx_node  ; set height so each node is square
  res_blank@tiMainFontHeightF              = 0.01
  res_blank@tiMainPosition                 = "Left"
  res_blank@tiMainJust                     = "centerleft"
  res_blank@tmEqualizeXYSizes              = True    ; Equal sizes for tick labels
  res_blank@tmXBMajorLengthF               = 0.0      ; effectively turn off tick marks
  res_blank@tmYLMajorLengthF               = 0.0      ; effectively turn off tick marks
  res_blank@tmXBMode                       = "Explicit"
  res_blank@tmXBLabels                     = ispan(0,nx_node-1,1)+""            ; tick marks
  res_blank@tmXBValues                     = fspan(0, nx_node-1, nx_node) + 0.5 ; position for tick labels
  res_blank@tmYLMode                       = "Explicit"
  res_blank@tmYLLabels                     = ispan(ny_node-1,0,1)+""            ; backwards tick marks
  res_blank@tmYLValues                     = fspan(0, ny_node-1, ny_node) + 0.5 ; position for tick labels
  res_blank@tmXBLabelFontHeightF           = res_blank@tiMainFontHeightF
  res_blank@tiXAxisString                  = "SOM Pattern"
  res_blank@tiYAxisString                  = "SOM Pattern"
  res_blank@tiXAxisFontHeightF             = 0.01
  res_blank@tiYAxisFontHeightF             = 0.01
  res_blank@tiMainString                   = title

  plot = gsn_blank_plot(wks14,res_blank)

; Add in squares:
  xx = (/0., 0., 1., 1., 0./)
  yy = (/0., 1., 1., 0., 0./)

; Polygon resources for color shading:
  res_poly = True
; Text resources for count and freq:
  res_txt = True
  res_txt@txFontHeightF = 0.0085
  res_txt@txFont = 22
  res_txt@txFontColor = "white" ;"black"

; loop through each node to plot
n = 0
do y = 0, ny_node - 1
  do x = 0, nx_node - 1 
    xp = xx + x
    yp = yy + y  
    ; Draw boxes
    res_poly@gsFillColor = "white" 
    dum1(n) = gsn_add_polygon(wks14, plot, xp, yp, res_poly)
    dum2(n) = gsn_add_polyline(wks14, plot, xp, yp, res_poly)
    ; Color squares - just set these all white!
    res_txt@txFontColor = "black"
    res_txt@txBackgroundFillColor = "white"
    text_1 = "Frequency term: ~C~ "+sprintf("%5.2f",nodes_term1_pcnt_plot(y,x))+"%"
    dum3(n) = gsn_add_text(wks14, plot, text_1, xp(0)+.5, yp(0)+.25, res_txt)
    text_2 = "Intrapattern term: ~C~ "+sprintf("%5.2f",nodes_term2_pcnt_plot(y,x))+"%"
    dum4(n) = gsn_add_text(wks14, plot, text_2, xp(0)+.5, yp(0)+.5, res_txt) 
    text_3 = "Combined term: ~C~ "+sprintf("%5.2f",nodes_term3_pcnt_plot(y,x))+"%"
    dum5(n) = gsn_add_text(wks14, plot, text_3, xp(0)+.5, yp(0)+.75, res_txt)   
    delete(text_1)
    delete(text_2)
    delete(text_3)
    n = n+1
  end do 
end do
  
; Finally - make plot
  draw(plot)
  frame(wks14)
  print("converting plot 14 to png")
  convert_cmd = "convert -density 300 "+fout14+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout14+".png"
  system(convert_cmd)

delete(res_blank)
delete(res_poly)
delete(res_txt)
delete(title)
;delete(additional_colors)
delete(plot)

end if

print("Completed all plots for "+varcode)
print("Good job!")
;;;;;;;;;;;;;;;;;;;;;; END script
end
