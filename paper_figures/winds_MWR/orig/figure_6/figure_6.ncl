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
  nx_input = "7"
  ny_input = "5"
  master_vals = "winds0.01_rlen1000000_r4"
  datatitle1  = "wrf50_200511_200703_6h"
  datatitle1b = "era_i_200511_200703_6h"
  type = "1"  ;1 = "correct" fluxes, 2 = fluxes from nodeavg values
  varcode = "U10"
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
plot8  = False ;True ; plot 8 - % contribution of nodes to net difference - sum of terms - simple box plot
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
  plot_title1 = "WRF 10km"
  datefile_1 = "/data3/duvivier/SOM/training/dates/"+datatitle_1+"_dates.txt"
  visfile_1  = "/data3/duvivier/SOM/training/som_"+nx_input+ny_input+"/master/"+datatitle_1+"_"+master_vals+".vis"
end if
if (tag_1 .eq. "wrf50")then
  datatitle_1 = "wrf50_199701_200712"
  plot_title1 = "WRF 50km"
  datefile_1 = "/data3/duvivier/SOM/training/dates/"+datatitle_1+"_dates.txt"
  visfile_1  = "/data3/duvivier/SOM/training/som_"+nx_input+ny_input+"/master/"+datatitle_1+"_"+master_vals+".vis"
end if
if (tag_1b .eq. "era_i")then
  datatitle_1b = "era_i_199701_200712"
  plot_title1b = "ERA Interim"
  datefile_1b = "/data3/duvivier/SOM/training/dates/"+datatitle_1b+"_dates.txt"
  visfile_1b  = "/data3/duvivier/SOM/training/som_"+nx_input+ny_input+"/master/"+datatitle_1b+"_"+master_vals+".vis"
end if
if (tag_1b .eq. "wrf50")then
  datatitle_1b = "wrf50_199701_200712"
  plot_title1b = "WRF 50km"
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
    cmax1               = 15.
    clev1               = 1.
    stride1             = 1                 ; label stride
    cmin2               = -10.
    cmax2               = 10.
    clev2               = 1.
    stride2             = 2                 ; label stride for diff plot
    cmin3               = -3.0
    cmax3               = 3.0
    clev3               = 0.25
    stride3             = 2                 ; label stride
    cmin4               = -2.0
    cmax4               = 2.0
    clev4               = 0.2
    stride4             = 2                 ; label stride for diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False              ; lines for diff plot
    cntype              = "AreaFill"
    spreadstart1        = 2 ;2                 ; start at color
    spreadend1          = 18 ;35                ; end at color
    spreadstart2        = 20 ;37                ; start at color
    spreadend2          = 115 ;132               ; end at color
    spreadstart3        = 20 ;37                ; start at color
    spreadend3          = 115 ;132               ; end at color
    colormap            = "SOM_wind_table_mod" ;"SOM_wind_table"
  end if
  if (cmaptype.eq."curlt") then
    cmin1               =  -4.
    cmax1               =  4.
    clev1               =  0.2
    stride1             =  4                ; label stride
    cmin2               = -3.
    cmax2               =  3.
    clev2               =  0.2
    stride2             =  3                ; label stride diff plot
    cmin3               = -1.0
    cmax3               =  1.0
    clev3               =  0.1
    stride3             =  2                ; label stride
    cmin4               = -0.8
    cmax4               =  0.8
    clev4               =  0.05
    stride4             =  4                 ; label stride for diff plot 
    plotlines           = False              ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"      ; type of fill for contours 
    spreadstart1        = 2                 ; start at color
    spreadend1          = 250               ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 250               ; end at color
    spreadstart3        = 2                 ; start at color
    spreadend3          = 250                ; end at color
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
    cmin3               = -2.0
    cmax3               = 2.0
    clev3               = 0.2
    stride3             = 2                 ; label stride
    cmin4               = -1.5
    cmax4               = 1.5
    clev4               = 0.1 
    stride4             = 2                 ; label stride for diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False              ; lines for diff plot
    cntype              = "AreaFill"      ; type of contour fill
    spreadstart1        = 67                 ; start at color
    spreadend1          = 106                ; end at color
    spreadstart2        = 67                ; start at color
    spreadend2          = 106 
    spreadstart3        = 67                 ; start at color
    spreadend3          = 106                ; end at color
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
    cmin3               = -2.0
    cmax3               = 2.0
    clev3               = 0.2
    stride3             = 2                 ; label stride
    cmin4               = -1.5
    cmax4               = 1.5
    clev4               = 0.1 
    stride4             = 2                 ; label stride for diff plot
    plotlines           = False             ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"        ; type of contour fill
    spreadstart1        = 67                ; start at color
    spreadend1          = 106               ; end at color
    spreadstart2        = 67                ; start at color
    spreadend2          = 106 
    spreadstart3        = 67                ; start at color
    spreadend3          = 106               ; end at color
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
    cmin3               = -0.5
    cmax3               = 0.5
    clev3               = 0.02
    stride3             = 4                 ; label stride
    cmin4               = -0.4
    cmax4               = 0.4
    clev4               = 0.02
    stride4             = 2                 ; label stride for diff plot
    plotlines           = False             ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"        ; type of contour fill
    spreadstart1        = 44                ; start at color
    spreadend1          = 85                ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 85                ; end at color
    spreadstart3        = 2                 ; start at color
    spreadend3          = 85                ; end at color
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
    cmin3               = -0.5
    cmax3               = 0.5
    clev3               = 0.02
    stride3             = 4                 ; label stride
    cmin4               = -0.5
    cmax4               = 0.5
    clev4               = 0.02
    stride4             = 2                 ; label stride for diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"        ; type of contour fill
    spreadstart1        = 44                ; start at color
    spreadend1          = 85                ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 85                ; end at color
    spreadstart3        = 2                 ; start at color
    spreadend3          = 85                ; end at color
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
    cmin3               = -40.
    cmax3               = 40.
    clev3               = 5.
    stride3             = 2                 ; label stride
    cmin4               = -25.
    cmax4               = 25.
    clev4               = 2.5
    stride4             = 2                 ; label stride for diff plot 
    plotlines           = False              ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"      ; type of fill for contours 
    spreadstart1        = 2                 ; start at color
    spreadend1          = 250               ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 250               ; end at color
    spreadstart3        = 2                 ; start at color
    spreadend3          = 250                ; end at color
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
    cmin3               = -50.
    cmax3               = 50.
    clev3               = 5.
    stride3             = 2                 ; label stride
    cmin4               = -25.
    cmax4               = 25.
    clev4               = 2.5
    stride4             = 2                 ; label stride for diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"      ; type of fill for contours 
    spreadstart1        = 2                 ; start at color
    spreadend1          = 250               ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 250               ; end at color
    spreadstart3        = 2                 ; start at color
    spreadend3          = 250                ; end at color
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
    cmin3               = -100.
    cmax3               = 100.
    clev3               = 10.
    stride3             = 2                 ; label stride
    cmin4               = -50.
    cmax4               = 50.
    clev4               = 5.
    stride4             = 2                 ; label stride for diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"      ; type of fill for contours 
    spreadstart1        = 2                 ; start at color
    spreadend1          = 250               ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 250               ; end at color
    spreadstart3        = 2                 ; start at color
    spreadend3          = 250                ; end at color
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
  ; get terrain array so we can keep high points out of interpolation
  Z_sfc_tmp_1d = ndtooned(z_sfc_1b)
  ; interpolate
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
       ; just include points with terrain height less than 10m
       ; or coastal pts too cold. Can't just use land mask because
       ; that includes sea ice points too.
        terrain_sub = Z_sfc_tmp_1d(indices)
        sealevel = ind(terrain_sub .lt. 10.0)
        n_sealevel = num(.not.ismissing(sealevel))
        if (n_sealevel .ne. 0.0) then
          var1b_tmp_1d(i) = sum(var1b_1d(indices(sealevel))*weight(sealevel)/sum(weight(sealevel)))
          seaice_1b_tmp_1d(i) = sum(seaice_1b_1d(indices(sealevel))*weight(sealevel)/sum(weight(sealevel)))
          if(type .eq. "1")then
            variance1b_tmp_1d(i) = sum(variance1b_1d(indices(sealevel))*weight(sealevel)/sum(weight(sealevel)))
          end if
        end if
        delete(indices)
        delete(weight)
        delete(terrain_sub)
        delete(sealevel)
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
  
  ; still have terrain array to keep high points out of interpolation
  ; Z_sfc_tmp_1d
  ; interpolate
  do i = 0, n_tot_1 - 1
    indices_all = interp_ind(i,:)
    n_indices = num(.not.ismissing(indices_all))
    if (n_indices .ne. 0.0) then
      indices = indices_all(0:n_indices-1)
      weight_all = interp_wgt(i,:)
      weight = weight_all(0:n_indices-1)
      ; just include points with terrain height less than 10m
      ; or coastal pts too cold. Can't just use land mask because
      ; that includes sea ice points too.
      terrain_sub = Z_sfc_tmp_1d(indices)
      sealevel = ind(terrain_sub .lt. 10.0)
      n_sealevel = num(.not.ismissing(sealevel))

      if (n_sealevel .ne. 0.0) then
        avg1b_tmp_1d(i) = sum(avg1b_1d(indices(sealevel))*weight(sealevel)/sum(weight(sealevel)))
        avg_variance1b_tmp_1d(i) = sum(avg_variance1b_1d(indices(sealevel))*weight(sealevel)/sum(weight(sealevel)))
        avg_seaice_1b_tmp_1d(i) = sum(avg_seaice_1b_1d(indices(sealevel))*weight(sealevel)/sum(weight(sealevel)))
      end if
      delete(indices)
      delete(weight)
      delete(terrain_sub)
      delete(sealevel)
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
avg_prob = 100.*(1. - ttest(avg1,avg_variance1,obs_1(0), avg1b,avg_variance1b,obs_1(0), False, False))

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
  ; 0.4X10E-5 N/m3 difference cutoff (~10% max diff)
  mask_95_prob = where(avg_prob .gt. 95., 1, fill)
  mask_min_diff = where(abs(winter_diff) .gt. 0.4, 1, fill)
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

; get total points going into the averages
dum = ind(.not.ismissing(ndtooned(mask_all)))
pts_tot = dimsizes(dum)
delete(dum)

;;;;;;;;;;;;;;
; get percents for net terms
;;;;;;;;;;;;;;
; get % contribution for each point that is both within the 95% 
; confidence level *and* above the threshold of differences set earlier.
; Get the total percent contribution and the positive and negative
; percent contributions for each of these terms. Make sure to weight the
; pos/neg values by the number of points in each so the total adds to 100%.
; term1_pcnt = term1_pcnt_pos + term1_pcnt_neg

;;; term1 - net ;;;
term1_all = ((term1_sum*mask_all)/avg_diff)*100.
term1_pcnt = avg(term1_all)

term1_pos = where(term1_all .ge. 0.0, term1_all, fill)
term1_pos_dum = ind(.not.ismissing(ndtooned(term1_pos)))
pts_pos = int2flt(dimsizes(term1_pos_dum))
term1_pcnt_pos = avg(term1_pos)*(pts_pos/pts_tot)
delete(term1_pos)
delete(term1_pos_dum)
delete(pts_pos)

term1_neg = where(term1_all .le. 0.0, term1_all, fill)
term1_neg_dum = ind(.not.ismissing(ndtooned(term1_neg)))
pts_neg = int2flt(dimsizes(term1_neg_dum))
term1_pcnt_neg = avg(term1_neg)*(pts_neg/pts_tot)
delete(term1_neg)
delete(term1_neg_dum)
delete(pts_neg)

;;; term2 - net ;;;
term2_all = ((term2_sum*mask_all)/avg_diff)*100.
term2_pcnt = avg(term2_all)

term2_pos = where(term2_all .ge. 0.0, term2_all, fill)
term2_pos_dum = ind(.not.ismissing(ndtooned(term2_pos)))
pts_pos = int2flt(dimsizes(term2_pos_dum))
term2_pcnt_pos = avg(term2_pos)*(pts_pos/pts_tot)
delete(term2_pos)
delete(term2_pos_dum)
delete(pts_pos)

term2_neg = where(term2_all .le. 0.0, term2_all, fill)
term2_neg_dum = ind(.not.ismissing(ndtooned(term2_neg)))
pts_neg = int2flt(dimsizes(term2_neg_dum))
term2_pcnt_neg = avg(term2_neg)*(pts_neg/pts_tot)
delete(term2_neg)
delete(term2_neg_dum)
delete(pts_neg)

;;; term3 - net ;;;
term3_all = ((term3_sum*mask_all)/avg_diff)*100.
term3_pcnt = avg(term3_all)

term3_pos = where(term3_all .ge. 0.0, term3_all, fill)
term3_pos_dum = ind(.not.ismissing(ndtooned(term3_pos)))
pts_pos = int2flt(dimsizes(term3_pos_dum))
term3_pcnt_pos = avg(term3_pos)*(pts_pos/pts_tot)
delete(term3_pos)
delete(term3_pos_dum)
delete(pts_pos)

term3_neg = where(term3_all .le. 0.0, term3_all, fill)
term3_neg_dum = ind(.not.ismissing(ndtooned(term3_neg)))
pts_neg = int2flt(dimsizes(term3_neg_dum))
term3_pcnt_neg = avg(term3_neg)*(pts_neg/pts_tot)
delete(term3_neg)
delete(term3_neg_dum)
delete(pts_neg)

;;; total pcnt ;;;
term_total_pcnt = term1_pcnt + term2_pcnt + term3_pcnt

;;;;;;;;;;;;;;
; get percents for groups
;;;;;;;;;;;;;;
;;; Group1 ;;;
group1_all = ((net_group1*mask_all)/avg_diff)*100.
group1_pcnt = avg(group1_all)

group1_pos = where(group1_all .ge. 0.0, group1_all, fill)
group1_pos_dum = ind(.not.ismissing(ndtooned(group1_pos)))
pts_pos = int2flt(dimsizes(group1_pos_dum))
group1_pcnt_pos = avg(group1_pos)*(pts_pos/pts_tot)
delete(group1_pos)
delete(group1_pos_dum)
delete(pts_pos)

group1_neg = where(group1_all .le. 0.0, group1_all, fill)
group1_neg_dum = ind(.not.ismissing(ndtooned(group1_neg)))
pts_neg = int2flt(dimsizes(group1_neg_dum))
group1_pcnt_neg = avg(group1_neg)*(pts_neg/pts_tot)
delete(group1_neg)
delete(group1_neg_dum)
delete(pts_neg)

term1_group1_all = ((term1_sum_group1*mask_all)/term1_sum)*100.
term1_group1_pcnt = avg(term1_group1_all)

term1_group1_pos = where(term1_group1_all .ge. 0.0, term1_group1_all, fill)
term1_group1_pos_dum = ind(.not.ismissing(ndtooned(term1_group1_pos)))
pts_pos = int2flt(dimsizes(term1_group1_pos_dum))
term1_group1_pcnt_pos = avg(term1_group1_pos)*(pts_pos/pts_tot)
delete(term1_group1_pos)
delete(term1_group1_pos_dum)
delete(pts_pos)

term1_group1_neg = where(term1_group1_all .le. 0.0, term1_group1_all, fill)
term1_group1_neg_dum = ind(.not.ismissing(ndtooned(term1_group1_neg)))
pts_neg = int2flt(dimsizes(term1_group1_neg_dum))
term1_group1_pcnt_neg = avg(term1_group1_neg)*(pts_neg/pts_tot)
delete(term1_group1_neg)
delete(term1_group1_neg_dum)
delete(pts_neg)

term2_group1_all = ((term2_sum_group1*mask_all)/term2_sum)*100.
term2_group1_pcnt = avg(term2_group1_all)

term2_group1_pos = where(term2_group1_all .ge. 0.0, term2_group1_all, fill)
term2_group1_pos_dum = ind(.not.ismissing(ndtooned(term2_group1_pos)))
pts_pos = int2flt(dimsizes(term2_group1_pos_dum))
term2_group1_pcnt_pos = avg(term2_group1_pos)*(pts_pos/pts_tot)
delete(term2_group1_pos)
delete(term2_group1_pos_dum)
delete(pts_pos)

term2_group1_neg = where(term2_group1_all .le. 0.0, term2_group1_all, fill)
term2_group1_neg_dum = ind(.not.ismissing(ndtooned(term2_group1_neg)))
pts_neg = int2flt(dimsizes(term2_group1_neg_dum))
term2_group1_pcnt_neg = avg(term2_group1_neg)*(pts_neg/pts_tot)
delete(term2_group1_neg)
delete(term2_group1_neg_dum)
delete(pts_neg)

term3_group1_all = ((term3_sum_group1*mask_all)/term3_sum)*100.
term3_group1_pcnt = avg(term3_group1_all)

term3_group1_pos = where(term3_group1_all .ge. 0.0, term3_group1_all, fill)
term3_group1_pos_dum = ind(.not.ismissing(ndtooned(term3_group1_pos)))
pts_pos = int2flt(dimsizes(term3_group1_pos_dum))
term3_group1_pcnt_pos = avg(term3_group1_pos)*(pts_pos/pts_tot)
delete(term3_group1_pos)
delete(term3_group1_pos_dum)
delete(pts_pos)

term3_group1_neg = where(term3_group1_all .le. 0.0, term3_group1_all, fill)
term3_group1_neg_dum = ind(.not.ismissing(ndtooned(term3_group1_neg)))
pts_neg = int2flt(dimsizes(term3_group1_neg_dum))
term3_group1_pcnt_neg = avg(term3_group1_neg)*(pts_neg/pts_tot)
delete(term3_group1_neg)
delete(term3_group1_neg_dum)
delete(pts_neg)

;;; Group2 ;;;
group2_all = ((net_group2*mask_all)/avg_diff)*100.
group2_pcnt = avg(group2_all)

group2_pos = where(group2_all .ge. 0.0, group2_all, fill)
group2_pos_dum = ind(.not.ismissing(ndtooned(group2_pos)))
pts_pos = int2flt(dimsizes(group2_pos_dum))
group2_pcnt_pos = avg(group2_pos)*(pts_pos/pts_tot)
delete(group2_pos)
delete(group2_pos_dum)
delete(pts_pos)

group2_neg = where(group2_all .le. 0.0, group2_all, fill)
group2_neg_dum = ind(.not.ismissing(ndtooned(group2_neg)))
pts_neg = int2flt(dimsizes(group2_neg_dum))
group2_pcnt_neg = avg(group2_neg)*(pts_neg/pts_tot)
delete(group2_neg)
delete(group2_neg_dum)
delete(pts_neg)

term1_group2_all = ((term1_sum_group2*mask_all)/term1_sum)*100.
term1_group2_pcnt = avg(term1_group2_all)

term1_group2_pos = where(term1_group2_all .ge. 0.0, term1_group2_all, fill)
term1_group2_pos_dum = ind(.not.ismissing(ndtooned(term1_group2_pos)))
pts_pos = int2flt(dimsizes(term1_group2_pos_dum))
term1_group2_pcnt_pos = avg(term1_group2_pos)*(pts_pos/pts_tot)
delete(term1_group2_pos)
delete(term1_group2_pos_dum)
delete(pts_pos)

term1_group2_neg = where(term1_group2_all .le. 0.0, term1_group2_all, fill)
term1_group2_neg_dum = ind(.not.ismissing(ndtooned(term1_group2_neg)))
pts_neg = int2flt(dimsizes(term1_group2_neg_dum))
term1_group2_pcnt_neg = avg(term1_group2_neg)*(pts_neg/pts_tot)
delete(term1_group2_neg)
delete(term1_group2_neg_dum)
delete(pts_neg)

term2_group2_all = ((term2_sum_group2*mask_all)/term2_sum)*100.
term2_group2_pcnt = avg(term2_group2_all)

term2_group2_pos = where(term2_group2_all .ge. 0.0, term2_group2_all, fill)
term2_group2_pos_dum = ind(.not.ismissing(ndtooned(term2_group2_pos)))
pts_pos = int2flt(dimsizes(term2_group2_pos_dum))
term2_group2_pcnt_pos = avg(term2_group2_pos)*(pts_pos/pts_tot)
delete(term2_group2_pos)
delete(term2_group2_pos_dum)
delete(pts_pos)

term2_group2_neg = where(term2_group2_all .le. 0.0, term2_group2_all, fill)
term2_group2_neg_dum = ind(.not.ismissing(ndtooned(term2_group2_neg)))
pts_neg = int2flt(dimsizes(term2_group2_neg_dum))
term2_group2_pcnt_neg = avg(term2_group2_neg)*(pts_neg/pts_tot)
delete(term2_group2_neg)
delete(term2_group2_neg_dum)
delete(pts_neg)

term3_group2_all = ((term3_sum_group2*mask_all)/term3_sum)*100.
term3_group2_pcnt = avg(term3_group2_all)

term3_group2_pos = where(term3_group2_all .ge. 0.0, term3_group2_all, fill)
term3_group2_pos_dum = ind(.not.ismissing(ndtooned(term3_group2_pos)))
pts_pos = int2flt(dimsizes(term3_group2_pos_dum))
term3_group2_pcnt_pos = avg(term3_group2_pos)*(pts_pos/pts_tot)
delete(term3_group2_pos)
delete(term3_group2_pos_dum)
delete(pts_pos)

term3_group2_neg = where(term3_group2_all .le. 0.0, term3_group2_all, fill)
term3_group2_neg_dum = ind(.not.ismissing(ndtooned(term3_group2_neg)))
pts_neg = int2flt(dimsizes(term3_group2_neg_dum))
term3_group2_pcnt_neg = avg(term3_group2_neg)*(pts_neg/pts_tot)
delete(term3_group2_neg)
delete(term3_group2_neg_dum)
delete(pts_neg)

;;; Group3 ;;;
group3_all = ((net_group3*mask_all)/avg_diff)*100.
group3_pcnt = avg(group3_all)

group3_pos = where(group3_all .ge. 0.0, group3_all, fill)
group3_pos_dum = ind(.not.ismissing(ndtooned(group3_pos)))
pts_pos = int2flt(dimsizes(group3_pos_dum))
group3_pcnt_pos = avg(group3_pos)*(pts_pos/pts_tot)
delete(group3_pos)
delete(group3_pos_dum)
delete(pts_pos)

group3_neg = where(group3_all .le. 0.0, group3_all, fill)
group3_neg_dum = ind(.not.ismissing(ndtooned(group3_neg)))
pts_neg = int2flt(dimsizes(group3_neg_dum))
group3_pcnt_neg = avg(group3_neg)*(pts_neg/pts_tot)
delete(group3_neg)
delete(group3_neg_dum)
delete(pts_neg)

term1_group3_all = ((term1_sum_group3*mask_all)/term1_sum)*100.
term1_group3_pcnt = avg(term1_group3_all)

term1_group3_pos = where(term1_group3_all .ge. 0.0, term1_group3_all, fill)
term1_group3_pos_dum = ind(.not.ismissing(ndtooned(term1_group3_pos)))
pts_pos = int2flt(dimsizes(term1_group3_pos_dum))
term1_group3_pcnt_pos = avg(term1_group3_pos)*(pts_pos/pts_tot)
delete(term1_group3_pos)
delete(term1_group3_pos_dum)
delete(pts_pos)

term1_group3_neg = where(term1_group3_all .le. 0.0, term1_group3_all, fill)
term1_group3_neg_dum = ind(.not.ismissing(ndtooned(term1_group3_neg)))
pts_neg = int2flt(dimsizes(term1_group3_neg_dum))
term1_group3_pcnt_neg = avg(term1_group3_neg)*(pts_neg/pts_tot)
delete(term1_group3_neg)
delete(term1_group3_neg_dum)
delete(pts_neg)

term2_group3_all = ((term2_sum_group3*mask_all)/term2_sum)*100.
term2_group3_pcnt = avg(term2_group3_all)

term2_group3_pos = where(term2_group3_all .ge. 0.0, term2_group3_all, fill)
term2_group3_pos_dum = ind(.not.ismissing(ndtooned(term2_group3_pos)))
pts_pos = int2flt(dimsizes(term2_group3_pos_dum))
term2_group3_pcnt_pos = avg(term2_group3_pos)*(pts_pos/pts_tot)
delete(term2_group3_pos)
delete(term2_group3_pos_dum)
delete(pts_pos)

term2_group3_neg = where(term2_group3_all .le. 0.0, term2_group3_all, fill)
term2_group3_neg_dum = ind(.not.ismissing(ndtooned(term2_group3_neg)))
pts_neg = int2flt(dimsizes(term2_group3_neg_dum))
term2_group3_pcnt_neg = avg(term2_group3_neg)*(pts_neg/pts_tot)
delete(term2_group3_neg)
delete(term2_group3_neg_dum)
delete(pts_neg)

term3_group3_all = ((term3_sum_group3*mask_all)/term3_sum)*100.
term3_group3_pcnt = avg(term3_group3_all)

term3_group3_pos = where(term3_group3_all .ge. 0.0, term3_group3_all, fill)
term3_group3_pos_dum = ind(.not.ismissing(ndtooned(term3_group3_pos)))
pts_pos = int2flt(dimsizes(term3_group3_pos_dum))
term3_group3_pcnt_pos = avg(term3_group3_pos)*(pts_pos/pts_tot)
delete(term3_group3_pos)
delete(term3_group3_pos_dum)
delete(pts_pos)

term3_group3_neg = where(term3_group3_all .le. 0.0, term3_group3_all, fill)
term3_group3_neg_dum = ind(.not.ismissing(ndtooned(term3_group3_neg)))
pts_neg = int2flt(dimsizes(term3_group3_neg_dum))
term3_group3_pcnt_neg = avg(term3_group3_neg)*(pts_neg/pts_tot)
delete(term3_group3_neg)
delete(term3_group3_neg_dum)
delete(pts_neg)

;;; Group4 ;;;
group4_all = ((net_group4*mask_all)/avg_diff)*100.
group4_pcnt = avg(group4_all)

group4_pos = where(group4_all .ge. 0.0, group4_all, fill)
group4_pos_dum = ind(.not.ismissing(ndtooned(group4_pos)))
pts_pos = int2flt(dimsizes(group4_pos_dum))
group4_pcnt_pos = avg(group4_pos)*(pts_pos/pts_tot)
delete(group4_pos)
delete(group4_pos_dum)
delete(pts_pos)

group4_neg = where(group4_all .le. 0.0, group4_all, fill)
group4_neg_dum = ind(.not.ismissing(ndtooned(group4_neg)))
pts_neg = int2flt(dimsizes(group4_neg_dum))
group4_pcnt_neg = avg(group4_neg)*(pts_neg/pts_tot)
delete(group4_neg)
delete(group4_neg_dum)
delete(pts_neg)

term1_group4_all = ((term1_sum_group4*mask_all)/term1_sum)*100.
term1_group4_pcnt = avg(term1_group4_all)

term1_group4_pos = where(term1_group4_all .ge. 0.0, term1_group4_all, fill)
term1_group4_pos_dum = ind(.not.ismissing(ndtooned(term1_group4_pos)))
pts_pos = int2flt(dimsizes(term1_group4_pos_dum))
term1_group4_pcnt_pos = avg(term1_group4_pos)*(pts_pos/pts_tot)
delete(term1_group4_pos)
delete(term1_group4_pos_dum)
delete(pts_pos)

term1_group4_neg = where(term1_group4_all .le. 0.0, term1_group4_all, fill)
term1_group4_neg_dum = ind(.not.ismissing(ndtooned(term1_group4_neg)))
pts_neg = int2flt(dimsizes(term1_group4_neg_dum))
term1_group4_pcnt_neg = avg(term1_group4_neg)*(pts_neg/pts_tot)
delete(term1_group4_neg)
delete(term1_group4_neg_dum)
delete(pts_neg)

term2_group4_all = ((term2_sum_group4*mask_all)/term2_sum)*100.
term2_group4_pcnt = avg(term2_group4_all)

term2_group4_pos = where(term2_group4_all .ge. 0.0, term2_group4_all, fill)
term2_group4_pos_dum = ind(.not.ismissing(ndtooned(term2_group4_pos)))
pts_pos = int2flt(dimsizes(term2_group4_pos_dum))
term2_group4_pcnt_pos = avg(term2_group4_pos)*(pts_pos/pts_tot)
delete(term2_group4_pos)
delete(term2_group4_pos_dum)
delete(pts_pos)

term2_group4_neg = where(term2_group4_all .le. 0.0, term2_group4_all, fill)
term2_group4_neg_dum = ind(.not.ismissing(ndtooned(term2_group4_neg)))
pts_neg = int2flt(dimsizes(term2_group4_neg_dum))
term2_group4_pcnt_neg = avg(term2_group4_neg)*(pts_neg/pts_tot)
delete(term2_group4_neg)
delete(term2_group4_neg_dum)
delete(pts_neg)

term3_group4_all = ((term3_sum_group4*mask_all)/term3_sum)*100.
term3_group4_pcnt = avg(term3_group4_all)

term3_group4_pos = where(term3_group4_all .ge. 0.0, term3_group4_all, fill)
term3_group4_pos_dum = ind(.not.ismissing(ndtooned(term3_group4_pos)))
pts_pos = int2flt(dimsizes(term3_group4_pos_dum))
term3_group4_pcnt_pos = avg(term3_group4_pos)*(pts_pos/pts_tot)
delete(term3_group4_pos)
delete(term3_group4_pos_dum)
delete(pts_pos)

term3_group4_neg = where(term3_group4_all .le. 0.0, term3_group4_all, fill)
term3_group4_neg_dum = ind(.not.ismissing(ndtooned(term3_group4_neg)))
pts_neg = int2flt(dimsizes(term3_group4_neg_dum))
term3_group4_pcnt_neg = avg(term3_group4_neg)*(pts_neg/pts_tot)
delete(term3_group4_neg)
delete(term3_group4_neg_dum)
delete(pts_neg)

;;; Group5 ;;;
group5_all = ((net_group5*mask_all)/avg_diff)*100.
group5_pcnt = avg(group5_all)

group5_pos = where(group5_all .ge. 0.0, group5_all, fill)
group5_pos_dum = ind(.not.ismissing(ndtooned(group5_pos)))
pts_pos = int2flt(dimsizes(group5_pos_dum))
group5_pcnt_pos = avg(group5_pos)*(pts_pos/pts_tot)
delete(group5_pos)
delete(group5_pos_dum)
delete(pts_pos)

group5_neg = where(group5_all .le. 0.0, group5_all, fill)
group5_neg_dum = ind(.not.ismissing(ndtooned(group5_neg)))
pts_neg = int2flt(dimsizes(group5_neg_dum))
group5_pcnt_neg = avg(group5_neg)*(pts_neg/pts_tot)
delete(group5_neg)
delete(group5_neg_dum)
delete(pts_neg)

term1_group5_all = ((term1_sum_group5*mask_all)/term1_sum)*100.
term1_group5_pcnt = avg(term1_group5_all)

term1_group5_pos = where(term1_group5_all .ge. 0.0, term1_group5_all, fill)
term1_group5_pos_dum = ind(.not.ismissing(ndtooned(term1_group5_pos)))
pts_pos = int2flt(dimsizes(term1_group5_pos_dum))
term1_group5_pcnt_pos = avg(term1_group5_pos)*(pts_pos/pts_tot)
delete(term1_group5_pos)
delete(term1_group5_pos_dum)
delete(pts_pos)

term1_group5_neg = where(term1_group5_all .le. 0.0, term1_group5_all, fill)
term1_group5_neg_dum = ind(.not.ismissing(ndtooned(term1_group5_neg)))
pts_neg = int2flt(dimsizes(term1_group5_neg_dum))
term1_group5_pcnt_neg = avg(term1_group5_neg)*(pts_neg/pts_tot)
delete(term1_group5_neg)
delete(term1_group5_neg_dum)
delete(pts_neg)

term2_group5_all = ((term2_sum_group5*mask_all)/term2_sum)*100.
term2_group5_pcnt = avg(term2_group5_all)

term2_group5_pos = where(term2_group5_all .ge. 0.0, term2_group5_all, fill)
term2_group5_pos_dum = ind(.not.ismissing(ndtooned(term2_group5_pos)))
pts_pos = int2flt(dimsizes(term2_group5_pos_dum))
term2_group5_pcnt_pos = avg(term2_group5_pos)*(pts_pos/pts_tot)
delete(term2_group5_pos)
delete(term2_group5_pos_dum)
delete(pts_pos)

term2_group5_neg = where(term2_group5_all .le. 0.0, term2_group5_all, fill)
term2_group5_neg_dum = ind(.not.ismissing(ndtooned(term2_group5_neg)))
pts_neg = int2flt(dimsizes(term2_group5_neg_dum))
term2_group5_pcnt_neg = avg(term2_group5_neg)*(pts_neg/pts_tot)
delete(term2_group5_neg)
delete(term2_group5_neg_dum)
delete(pts_neg)

term3_group5_all = ((term3_sum_group5*mask_all)/term3_sum)*100.
term3_group5_pcnt = avg(term3_group5_all)

term3_group5_pos = where(term3_group5_all .ge. 0.0, term3_group5_all, fill)
term3_group5_pos_dum = ind(.not.ismissing(ndtooned(term3_group5_pos)))
pts_pos = int2flt(dimsizes(term3_group5_pos_dum))
term3_group5_pcnt_pos = avg(term3_group5_pos)*(pts_pos/pts_tot)
delete(term3_group5_pos)
delete(term3_group5_pos_dum)
delete(pts_pos)

term3_group5_neg = where(term3_group5_all .le. 0.0, term3_group5_all, fill)
term3_group5_neg_dum = ind(.not.ismissing(ndtooned(term3_group5_neg)))
pts_neg = int2flt(dimsizes(term3_group5_neg_dum))
term3_group5_pcnt_neg = avg(term3_group5_neg)*(pts_neg/pts_tot)
delete(term3_group5_neg)
delete(term3_group5_neg_dum)
delete(pts_neg)

;;; Group6 ;;;
group6_all = ((net_group6*mask_all)/avg_diff)*100.
group6_pcnt = avg(group6_all)

group6_pos = where(group6_all .ge. 0.0, group6_all, fill)
group6_pos_dum = ind(.not.ismissing(ndtooned(group6_pos)))
pts_pos = int2flt(dimsizes(group6_pos_dum))
group6_pcnt_pos = avg(group6_pos)*(pts_pos/pts_tot)
delete(group6_pos)
delete(group6_pos_dum)
delete(pts_pos)

group6_neg = where(group6_all .le. 0.0, group6_all, fill)
group6_neg_dum = ind(.not.ismissing(ndtooned(group6_neg)))
pts_neg = int2flt(dimsizes(group6_neg_dum))
group6_pcnt_neg = avg(group6_neg)*(pts_neg/pts_tot)
delete(group6_neg)
delete(group6_neg_dum)
delete(pts_neg)

term1_group6_all = ((term1_sum_group6*mask_all)/term1_sum)*100.
term1_group6_pcnt = avg(term1_group6_all)

term1_group6_pos = where(term1_group6_all .ge. 0.0, term1_group6_all, fill)
term1_group6_pos_dum = ind(.not.ismissing(ndtooned(term1_group6_pos)))
pts_pos = int2flt(dimsizes(term1_group6_pos_dum))
term1_group6_pcnt_pos = avg(term1_group6_pos)*(pts_pos/pts_tot)
delete(term1_group6_pos)
delete(term1_group6_pos_dum)
delete(pts_pos)

term1_group6_neg = where(term1_group6_all .le. 0.0, term1_group6_all, fill)
term1_group6_neg_dum = ind(.not.ismissing(ndtooned(term1_group6_neg)))
pts_neg = int2flt(dimsizes(term1_group6_neg_dum))
term1_group6_pcnt_neg = avg(term1_group6_neg)*(pts_neg/pts_tot)
delete(term1_group6_neg)
delete(term1_group6_neg_dum)
delete(pts_neg)

term2_group6_all = ((term2_sum_group6*mask_all)/term2_sum)*100.
term2_group6_pcnt = avg(term2_group6_all)

term2_group6_pos = where(term2_group6_all .ge. 0.0, term2_group6_all, fill)
term2_group6_pos_dum = ind(.not.ismissing(ndtooned(term2_group6_pos)))
pts_pos = int2flt(dimsizes(term2_group6_pos_dum))
term2_group6_pcnt_pos = avg(term2_group6_pos)*(pts_pos/pts_tot)
delete(term2_group6_pos)
delete(term2_group6_pos_dum)
delete(pts_pos)

term2_group6_neg = where(term2_group6_all .le. 0.0, term2_group6_all, fill)
term2_group6_neg_dum = ind(.not.ismissing(ndtooned(term2_group6_neg)))
pts_neg = int2flt(dimsizes(term2_group6_neg_dum))
term2_group6_pcnt_neg = avg(term2_group6_neg)*(pts_neg/pts_tot)
delete(term2_group6_neg)
delete(term2_group6_neg_dum)
delete(pts_neg)

term3_group6_all = ((term3_sum_group6*mask_all)/term3_sum)*100.
term3_group6_pcnt = avg(term3_group6_all)

term3_group6_pos = where(term3_group6_all .ge. 0.0, term3_group6_all, fill)
term3_group6_pos_dum = ind(.not.ismissing(ndtooned(term3_group6_pos)))
pts_pos = int2flt(dimsizes(term3_group6_pos_dum))
term3_group6_pcnt_pos = avg(term3_group6_pos)*(pts_pos/pts_tot)
delete(term3_group6_pos)
delete(term3_group6_pos_dum)
delete(pts_pos)

term3_group6_neg = where(term3_group6_all .le. 0.0, term3_group6_all, fill)
term3_group6_neg_dum = ind(.not.ismissing(ndtooned(term3_group6_neg)))
pts_neg = int2flt(dimsizes(term3_group6_neg_dum))
term3_group6_pcnt_neg = avg(term3_group6_neg)*(pts_neg/pts_tot)
delete(term3_group6_neg)
delete(term3_group6_neg_dum)
delete(pts_neg)

;;; Group7 ;;;
group7_all = ((net_group7*mask_all)/avg_diff)*100.
group7_pcnt = avg(group7_all)

group7_pos = where(group7_all .ge. 0.0, group7_all, fill)
group7_pos_dum = ind(.not.ismissing(ndtooned(group7_pos)))
pts_pos = int2flt(dimsizes(group7_pos_dum))
group7_pcnt_pos = avg(group7_pos)*(pts_pos/pts_tot)
delete(group7_pos)
delete(group7_pos_dum)
delete(pts_pos)

group7_neg = where(group7_all .le. 0.0, group7_all, fill)
group7_neg_dum = ind(.not.ismissing(ndtooned(group7_neg)))
pts_neg = int2flt(dimsizes(group7_neg_dum))
group7_pcnt_neg = avg(group7_neg)*(pts_neg/pts_tot)
delete(group7_neg)
delete(group7_neg_dum)
delete(pts_neg)

term1_group7_all = ((term1_sum_group7*mask_all)/term1_sum)*100.
term1_group7_pcnt = avg(term1_group7_all)

term1_group7_pos = where(term1_group7_all .ge. 0.0, term1_group7_all, fill)
term1_group7_pos_dum = ind(.not.ismissing(ndtooned(term1_group7_pos)))
pts_pos = int2flt(dimsizes(term1_group7_pos_dum))
term1_group7_pcnt_pos = avg(term1_group7_pos)*(pts_pos/pts_tot)
delete(term1_group7_pos)
delete(term1_group7_pos_dum)
delete(pts_pos)

term1_group7_neg = where(term1_group7_all .le. 0.0, term1_group7_all, fill)
term1_group7_neg_dum = ind(.not.ismissing(ndtooned(term1_group7_neg)))
pts_neg = int2flt(dimsizes(term1_group7_neg_dum))
term1_group7_pcnt_neg = avg(term1_group7_neg)*(pts_neg/pts_tot)
delete(term1_group7_neg)
delete(term1_group7_neg_dum)
delete(pts_neg)

term2_group7_all = ((term2_sum_group7*mask_all)/term2_sum)*100.
term2_group7_pcnt = avg(term2_group7_all)

term2_group7_pos = where(term2_group7_all .ge. 0.0, term2_group7_all, fill)
term2_group7_pos_dum = ind(.not.ismissing(ndtooned(term2_group7_pos)))
pts_pos = int2flt(dimsizes(term2_group7_pos_dum))
term2_group7_pcnt_pos = avg(term2_group7_pos)*(pts_pos/pts_tot)
delete(term2_group7_pos)
delete(term2_group7_pos_dum)
delete(pts_pos)

term2_group7_neg = where(term2_group7_all .le. 0.0, term2_group7_all, fill)
term2_group7_neg_dum = ind(.not.ismissing(ndtooned(term2_group7_neg)))
pts_neg = int2flt(dimsizes(term2_group7_neg_dum))
term2_group7_pcnt_neg = avg(term2_group7_neg)*(pts_neg/pts_tot)
delete(term2_group7_neg)
delete(term2_group7_neg_dum)
delete(pts_neg)

term3_group7_all = ((term3_sum_group7*mask_all)/term3_sum)*100.
term3_group7_pcnt = avg(term3_group7_all)

term3_group7_pos = where(term3_group7_all .ge. 0.0, term3_group7_all, fill)
term3_group7_pos_dum = ind(.not.ismissing(ndtooned(term3_group7_pos)))
pts_pos = int2flt(dimsizes(term3_group7_pos_dum))
term3_group7_pcnt_pos = avg(term3_group7_pos)*(pts_pos/pts_tot)
delete(term3_group7_pos)
delete(term3_group7_pos_dum)
delete(pts_pos)

term3_group7_neg = where(term3_group7_all .le. 0.0, term3_group7_all, fill)
term3_group7_neg_dum = ind(.not.ismissing(ndtooned(term3_group7_neg)))
pts_neg = int2flt(dimsizes(term3_group7_neg_dum))
term3_group7_pcnt_neg = avg(term3_group7_neg)*(pts_neg/pts_tot)
delete(term3_group7_neg)
delete(term3_group7_neg_dum)
delete(pts_neg)

;;; Group8 ;;;
group8_all = ((net_group8*mask_all)/avg_diff)*100.
group8_pcnt = avg(group8_all)

group8_pos = where(group8_all .ge. 0.0, group8_all, fill)
group8_pos_dum = ind(.not.ismissing(ndtooned(group8_pos)))
pts_pos = int2flt(dimsizes(group8_pos_dum))
group8_pcnt_pos = avg(group8_pos)*(pts_pos/pts_tot)
delete(group8_pos)
delete(group8_pos_dum)
delete(pts_pos)

group8_neg = where(group8_all .le. 0.0, group8_all, fill)
group8_neg_dum = ind(.not.ismissing(ndtooned(group8_neg)))
pts_neg = int2flt(dimsizes(group8_neg_dum))
group8_pcnt_neg = avg(group8_neg)*(pts_neg/pts_tot)
delete(group8_neg)
delete(group8_neg_dum)
delete(pts_neg)

term1_group8_all = ((term1_sum_group8*mask_all)/term1_sum)*100.
term1_group8_pcnt = avg(term1_group8_all)

term1_group8_pos = where(term1_group8_all .ge. 0.0, term1_group8_all, fill)
term1_group8_pos_dum = ind(.not.ismissing(ndtooned(term1_group8_pos)))
pts_pos = int2flt(dimsizes(term1_group8_pos_dum))
term1_group8_pcnt_pos = avg(term1_group8_pos)*(pts_pos/pts_tot)
delete(term1_group8_pos)
delete(term1_group8_pos_dum)
delete(pts_pos)

term1_group8_neg = where(term1_group8_all .le. 0.0, term1_group8_all, fill)
term1_group8_neg_dum = ind(.not.ismissing(ndtooned(term1_group8_neg)))
pts_neg = int2flt(dimsizes(term1_group8_neg_dum))
term1_group8_pcnt_neg = avg(term1_group8_neg)*(pts_neg/pts_tot)
delete(term1_group8_neg)
delete(term1_group8_neg_dum)
delete(pts_neg)

term2_group8_all = ((term2_sum_group8*mask_all)/term2_sum)*100.
term2_group8_pcnt = avg(term2_group8_all)

term2_group8_pos = where(term2_group8_all .ge. 0.0, term2_group8_all, fill)
term2_group8_pos_dum = ind(.not.ismissing(ndtooned(term2_group8_pos)))
pts_pos = int2flt(dimsizes(term2_group8_pos_dum))
term2_group8_pcnt_pos = avg(term2_group8_pos)*(pts_pos/pts_tot)
delete(term2_group8_pos)
delete(term2_group8_pos_dum)
delete(pts_pos)

term2_group8_neg = where(term2_group8_all .le. 0.0, term2_group8_all, fill)
term2_group8_neg_dum = ind(.not.ismissing(ndtooned(term2_group8_neg)))
pts_neg = int2flt(dimsizes(term2_group8_neg_dum))
term2_group8_pcnt_neg = avg(term2_group8_neg)*(pts_neg/pts_tot)
delete(term2_group8_neg)
delete(term2_group8_neg_dum)
delete(pts_neg)

term3_group8_all = ((term3_sum_group8*mask_all)/term3_sum)*100.
term3_group8_pcnt = avg(term3_group8_all)

term3_group8_pos = where(term3_group8_all .ge. 0.0, term3_group8_all, fill)
term3_group8_pos_dum = ind(.not.ismissing(ndtooned(term3_group8_pos)))
pts_pos = int2flt(dimsizes(term3_group8_pos_dum))
term3_group8_pcnt_pos = avg(term3_group8_pos)*(pts_pos/pts_tot)
delete(term3_group8_pos)
delete(term3_group8_pos_dum)
delete(pts_pos)

term3_group8_neg = where(term3_group8_all .le. 0.0, term3_group8_all, fill)
term3_group8_neg_dum = ind(.not.ismissing(ndtooned(term3_group8_neg)))
pts_neg = int2flt(dimsizes(term3_group8_neg_dum))
term3_group8_pcnt_neg = avg(term3_group8_neg)*(pts_neg/pts_tot)
delete(term3_group8_neg)
delete(term3_group8_neg_dum)
delete(pts_neg)

;;;;;;;;;;;;;;
; get percents for nodes
;;;;;;;;;;;;;;
; Calculate percent contribution for each node (sum of all terms and terms individually)
; also get positive and negative contributions
nodes_all_pcnt = new((/nnode/),"float")
nodes_all_pcnt_pos = new((/nnode/),"float")
nodes_all_pcnt_neg = new((/nnode/),"float")
nodes_term1_pcnt = new((/nnode/),"float")
nodes_term1_pcnt_pos = new((/nnode/),"float")
nodes_term1_pcnt_neg = new((/nnode/),"float")
nodes_term2_pcnt = new((/nnode/),"float")
nodes_term2_pcnt_pos = new((/nnode/),"float")
nodes_term2_pcnt_neg = new((/nnode/),"float")
nodes_term3_pcnt = new((/nnode/),"float")
nodes_term3_pcnt_pos = new((/nnode/),"float")
nodes_term3_pcnt_neg = new((/nnode/),"float")

total_pcnt = 0.0
do n = 0, nnode - 1
  ; Get node contributions to net difference
   dum = ((nodes_sum_all(n,:,:)*mask_all)/avg_diff)*100.
   nodes_all_pcnt(n) = avg(dum)
   total_pcnt = total_pcnt + nodes_all_pcnt(n)
   
   nodes_all_pos = where(dum .ge. 0.0, dum, fill)
   nodes_all_pos_1d = ind(.not.ismissing(ndtooned(nodes_all_pos)))
   pts_pos = int2flt(dimsizes(nodes_all_pos_1d))
   nodes_all_pcnt_pos(n) = avg(nodes_all_pos)*(pts_pos/pts_tot)
   delete(nodes_all_pos)
   delete(nodes_all_pos_1d)
   delete(pts_pos)  

   nodes_all_neg = where(dum .lt. 0.0, dum, fill)
   nodes_all_neg_1d = ind(.not.ismissing(ndtooned(nodes_all_neg)))
   pts_neg = int2flt(dimsizes(nodes_all_neg_1d))
   nodes_all_pcnt_neg(n) = avg(nodes_all_neg)*(pts_neg/pts_tot)
   delete(nodes_all_neg)
   delete(nodes_all_neg_1d)
   delete(pts_neg) 
   delete(dum) 
  
  ; each term individually
   ; term1 ;
   dum = ((term1(n,:,:)*mask_all)/term1_sum)*100.
   nodes_term1_pcnt(n) = avg(dum)
   
   nodes_term1_pos = where(dum .ge. 0.0, dum, fill)
   nodes_term1_pos_1d = ind(.not.ismissing(ndtooned(nodes_term1_pos)))
   pts_pos = int2flt(dimsizes(nodes_term1_pos_1d))
   nodes_term1_pcnt_pos(n) = avg(nodes_term1_pos)*(pts_pos/pts_tot)
   delete(nodes_term1_pos)
   delete(nodes_term1_pos_1d)
   delete(pts_pos)  

   nodes_term1_neg = where(dum .lt. 0.0, dum, fill)
   nodes_term1_neg_1d = ind(.not.ismissing(ndtooned(nodes_term1_neg)))
   pts_neg = int2flt(dimsizes(nodes_term1_neg_1d))
   nodes_term1_pcnt_neg(n) = avg(nodes_term1_neg)*(pts_neg/pts_tot)
   delete(nodes_term1_neg)
   delete(nodes_term1_neg_1d)
   delete(pts_neg) 
   delete(dum) 

   ; term2 ;
   dum = ((term2(n,:,:)*mask_all)/term2_sum)*100.
   nodes_term2_pcnt(n) = avg(dum)
   
   nodes_term2_pos = where(dum .ge. 0.0, dum, fill)
   nodes_term2_pos_1d = ind(.not.ismissing(ndtooned(nodes_term2_pos)))
   pts_pos = int2flt(dimsizes(nodes_term2_pos_1d))
   nodes_term2_pcnt_pos(n) = avg(nodes_term2_pos)*(pts_pos/pts_tot)
   delete(nodes_term2_pos)
   delete(nodes_term2_pos_1d)
   delete(pts_pos)  

   nodes_term2_neg = where(dum .lt. 0.0, dum, fill)
   nodes_term2_neg_1d = ind(.not.ismissing(ndtooned(nodes_term2_neg)))
   pts_neg = int2flt(dimsizes(nodes_term2_neg_1d))
   nodes_term2_pcnt_neg(n) = avg(nodes_term2_neg)*(pts_neg/pts_tot)
   delete(nodes_term2_neg)
   delete(nodes_term2_neg_1d)
   delete(pts_neg) 
   delete(dum) 

   ; term3 ;
   dum = ((term3(n,:,:)*mask_all)/term2_sum)*100.
   nodes_term3_pcnt(n) = avg(dum)
   
   nodes_term3_pos = where(dum .ge. 0.0, dum, fill)
   nodes_term3_pos_1d = ind(.not.ismissing(ndtooned(nodes_term3_pos)))
   pts_pos = int2flt(dimsizes(nodes_term3_pos_1d))
   nodes_term3_pcnt_pos(n) = avg(nodes_term3_pos)*(pts_pos/pts_tot)
   delete(nodes_term3_pos)
   delete(nodes_term3_pos_1d)
   delete(pts_pos)  

   nodes_term3_neg = where(dum .lt. 0.0, dum, fill)
   nodes_term3_neg_1d = ind(.not.ismissing(ndtooned(nodes_term3_neg)))
   pts_neg = int2flt(dimsizes(nodes_term3_neg_1d))
   nodes_term3_pcnt_neg(n) = avg(nodes_term3_neg)*(pts_neg/pts_tot)
   delete(nodes_term3_neg)
   delete(nodes_term3_neg_1d)
   delete(pts_neg) 
   delete(dum)

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
; plot 6  - % contribution of nodes to net difference - sum of terms - simple box plot
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; set outdir and fout names
outdir = "./"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 6 - Percent difference for each node, sum of all terms
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Plot 6 - Percent contribution of nodes")
fout6   = "figure_6"

  title = "Node percent contribution to mean difference: 2005-2007 WRF50 and ERA-I"
  wks6 = gsn_open_wks("ps",fout6)
  gsn_define_colormap(wks6, "BlueRed")

; make data into som size for plotting
  nodes_all_pcnt_plot = onedtond(nodes_all_pcnt, (/ny_node,nx_node/))
  nodes_all_pos_plot = onedtond(nodes_all_pcnt_pos, (/ny_node,nx_node/))
  nodes_all_neg_plot = onedtond(nodes_all_pcnt_neg, (/ny_node,nx_node/))
  ;; Reverse rows(for plotting purposes)
  ;nodes_all_pcnt_plot = nodes_all_pcnt_plot(:,::-1)
  ; Reverse columns(for plotting purposes)
  nodes_all_pcnt_plot = nodes_all_pcnt_plot(::-1,:)
  nodes_all_pos_plot = nodes_all_pos_plot(::-1,:)
  nodes_all_neg_plot = nodes_all_neg_plot(::-1,:)

; Begin plotting:    
  plot = new(1, graphic)
  dum1 = new((/nnode/),graphic)
  dum2 = new((/nnode/),graphic)
  dum3 = new((/nnode/),graphic)  

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
  ;res_blank@tmXBLabels                     = ispan(0,nx_node-1,1)+""            ; tick marks
  res_blank@tmXBValues                     = fspan(0, nx_node-1, nx_node) + 0.5 ; position for tick labels
  res_blank@tmYLMode                       = "Explicit"
  ;res_blank@tmYLLabels                     = ispan(ny_node-1,0,1)+""            ; backwards tick marks
  res_blank@tmYLValues                     = fspan(0, ny_node-1, ny_node) + 0.5 ; position for tick labels
  res_blank@tmXBLabelFontHeightF           = res_blank@tiMainFontHeightF
  ;res_blank@tiXAxisString                  = "SOM Pattern"
  ;res_blank@tiYAxisString                  = "SOM Pattern"
  res_blank@tiXAxisFontHeightF             = 0.01
  res_blank@tiYAxisFontHeightF             = 0.01
  res_blank@tiMainString                   = title

  plot = gsn_blank_plot(wks6,res_blank)

; Add in squares:
  xx = (/0., 0., 1., 1., 0./)
  yy = (/0., 1., 1., 0., 0./)

; Polygon resources for color shading:
  res_poly = True
  res_poly@gsFillColor = "white" 
; get color scales for + and - contribution
  slope = 4./(max(abs(nodes_all_pcnt_plot))-0.0)
  color_indices = slope*nodes_all_pcnt_plot

; Text resources for count and freq:
  res_txt = True
  res_txt@txFontHeightF = 0.02
  res_txt@txFont = 22
  res_txt@txFontColor = "black"
  res_txt@txBackgroundFillColor = "white"

; loop through each node to plot
n = 0
do y = 0, ny_node - 1
  do x = 0, nx_node - 1 
    xp = xx + x
    yp = yy + y 
 
    ; color ALL squares by influence
    color_index = color_indices(y,x)
    if(color_index .ge. 3.0)
      res_poly@gsFillColor = 9
    end if
    if(color_index .ge. 2.0 .and. color_index .lt. 3.0)
      res_poly@gsFillColor = 8
    end if
    if(color_index .ge. 1.0 .and. color_index .lt. 2.0)
      res_poly@gsFillColor = 7
    end if
    if(color_index .gt. 0.0 .and. color_index .lt. 1.0)
      res_poly@gsFillColor = 6
    end if
    if(color_index .eq. 0.0)
      res_poly@gsFillColor = "white"
    end if
    if(color_index .lt. 0.0 .and. color_index .gt. -1.0)
      res_poly@gsFillColor = 5
    end if
    if(color_index .lt. -1.0 .and. color_index .gt. -2.0)
      res_poly@gsFillColor = 4
    end if
    if(color_index .lt. -2.0 .and. color_index .gt. -3.0)
      res_poly@gsFillColor = 3
    end if
    if(color_index .lt. -3.0)
      res_poly@gsFillColor = 2
    end if

    ; Draw boxes
    dum1(n) = gsn_add_polygon(wks6, plot, xp, yp, res_poly)
    dum2(n) = gsn_add_polyline(wks6, plot, xp, yp, res_poly)

    text = sprintf("%5.2f",nodes_all_pcnt_plot(y,x))+"%"
    dum3(n) = gsn_add_text(wks6, plot, text, xp(0)+0.5, yp(0)+0.5, res_txt)
    delete(text)
    delete(res_poly@gsFillColor)
    n = n+1
  end do 
end do
  
; Finally - make plot
  draw(plot)
  frame(wks6)
  print("converting plot 6 to png")
  convert_cmd = "convert -density 300 "+fout6+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout6+".png"
  system(convert_cmd)

delete(title)
delete(plot)

print("Completed all plots for "+varcode)
print("Good job!")
;;;;;;;;;;;;;;;;;;;;;; END script
end
