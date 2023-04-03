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
;  datatitle1  = "wrf50_200511_200703_6h"
;  datatitle1b = "era_i_200511_200703_6h"
;  varcode = "q_2m"
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
plot1  = False ;True ; plot 1 - Frequency and frequency differences of all nodes (only needed once)
plot2  = True ; plot 2 - 8 panel of group averages for datatitle1
plot3  = True ; plot 3 - 8 panel of group averages for datatitle1b
plot4  = True ; plot 4 - 8 panel of group average differences
plot5  = True ; plot 5 - 24 panel of group averages and differences
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

; where to find data!
dir1 = "/data3/duvivier/SOM/analysis/flux_compare/group_avgs/"

;;;;;;;;;;
; Set information for variable
;;;;;;;;;;
; add each variable set in the c-shell 'varcode' and assign it a title and other necessary information
if (varcode.eq."U10")then
  vartitle = "Avg 10m Wind speed"
  invar1 = "wspd_10m_avg"
  invar_v = "wspd_10m_var"
  vartype = "2d"
  cmaptype = "wind"
  zoom2 = True
end if
if (varcode.eq."curltau")then
  vartitle = "Avg 10m wind stress curl"
  invar1 = "curl_tau_avg"
  invar_v = "curl_tau_var"
  vartype = "2d"
  cmaptype = "curlt"
  zoom2 = True
end if
if (varcode.eq."Tgrad") then
  vartitle = "Avg Temp grad (sfc-2m)"
  invar1 = "T_grad_avg"
  invar_v = "T_grad_var"
  vartype = "2d"
  cmaptype = "temp_grad"
  zoom2 = True
end if
if (varcode.eq."T_sfc")then
  vartitle = "Avg Sea Sfc Temp"
  invar1 = "SST_avg"
  invar_v = "SST_var"
  vartype = "2d"
  cmaptype = "temperature"
  zoom2 = True
end if
if (varcode.eq."T_2m")then
  vartitle = "Avg Temp at 2m"
  invar1 = "T_2m_avg"
  invar_v = "T_2m_var"
  vartype = "2d"
  cmaptype = "temperature"
  zoom2 = True
end if
if (varcode.eq."qgrad") then
  vartitle = "Avg Mixing Ratio grad (sfc-2m)"
  invar1 = "q_grad_avg"
  invar_v = "q_grad_var"
  vartype = "2d"
  cmaptype = "mix_grad"
  zoom2 = True
end if
if (varcode.eq."q_sfc")then
  vartitle = "Avg Mixing Ratio at sfc"
  invar1 = "q_sfc_avg"
  invar_v = "q_sfc_var"
  vartype = "2d"
  cmaptype = "mix_rad"
  zoom2 = True
end if
if (varcode.eq."q_2m")then
  vartitle = "Avg Mixing Ratio at 2m"
  invar1 = "q_2m_avg"
  invar_v = "q_2m_var"
  vartype = "2d"
  cmaptype = "mix_rad"
  zoom2 = True
end if
if (varcode.eq."SH") then
  vartitle = "Avg SH Flux at sfc"
  invar1 = "SHFlx_avg"
  invar_v = "SHFlx_var"
  vartype = "2d"
  cmaptype = "shflux"
  zoom2 = True
end if
if (varcode.eq."LH") then
  vartitle = "Avg LH Flux at sfc"
  invar1 = "LHFlx_avg"
  invar_v = "LHFlx_var"
  vartype = "2d"
  cmaptype = "lhflux"
  zoom2 = True
end if
if (varcode.eq."TurbFlx") then
  vartitle = "Avg Total Turb Flux at sfc"
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
    cmax1               = 20.
    clev1               = 1.
    stride1             = 2                 ; label stride
    cmin2               = -10.
    cmax2               = 10.
    clev2               = 0.5
    stride2             = 2                 ; label stride for diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False              ; lines for diff plot
    cntype              = "AreaFill"
    spreadstart1        = 2                 ; start at color
    spreadend1          = 35                ; end at color
    spreadstart2        = 37                ; start at color
    spreadend2          = 132               ; end at color
    colormap            = "SOM_wind_table"
  end if
  if (cmaptype.eq."curlt") then
    cmin1               = -5.
    cmax1               = 5.
    clev1               = 0.2
    stride1             = 4                 ; label stride
    cmin2               = -5.
    cmax2               = 5.
    clev2               = 0.2
    stride2             = 2                 ; label stride for diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False              ; lines for diff plot
    cntype              = "AreaFill"
    spreadstart1        = 2                 ; start at color
    spreadend1          = 250               ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 250               ; end at color
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
    plotlines           = False              ; lines for reg plot
    difflines           = False              ; lines for diff plot
    cntype              = "AreaFill"      ; type of contour fill
    spreadstart1        = 67                 ; start at color
    spreadend1          = 106                ; end at color
    spreadstart2        = 67                ; start at color
    spreadend2          = 106 
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
    plotlines           = False             ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"        ; type of contour fill
    spreadstart1        = 67                ; start at color
    spreadend1          = 106               ; end at color
    spreadstart2        = 67                ; start at color
    spreadend2          = 106 
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
    plotlines           = False             ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"        ; type of contour fill
    spreadstart1        = 44                ; start at color
    spreadend1          = 85                ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 85                ; end at color
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
    plotlines           = False              ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"        ; type of contour fill
    spreadstart1        = 44                ; start at color
    spreadend1          = 85                ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 85                ; end at color
    colormap            = "BrownBlue_mod"
  end if
  if (cmaptype.eq."lhflux") then
    cmin1               =  -300.
    cmax1               =  300.
    clev1               =  30.
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
    cmin1               =  -300.
    cmax1               =  300.
    clev1               =  30.
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
  if (cmaptype.eq."flux") then
    cmin1               =  -300.
    cmax1               =  300.
    clev1               =  20.
    stride1             = 2                 ; label stride
    cmin2               = -150.
    cmax2               =  150.
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Load in data from group averages
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ngroup = 8   ; set number of groups

; Load in lat/lon to get information for file 1 domain and if need interpolation
  fname0 = "group_1_"+datatitle1
  f0 = addfile(dir1+ fname0 + "-fluxes-sst.nc","r")
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
  fname0b = "group_1_"+datatitle1b
  f0b = addfile(dir1 + fname0b + "-fluxes-sst.nc","r")
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

  ; create all-node array for node average variable, variance, and seaice
  var1       = new((/ngroup,n_sn_1,n_we_1/),"float")
  var1b      = new((/ngroup,n_sn_1b,n_we_1b/),"float")
  variance1  = new((/ngroup,n_sn_1,n_we_1/),"float")
  variance1b = new((/ngroup,n_sn_1b,n_we_1b/),"float")
  seaice_1   = new((/ngroup,n_sn_1,n_we_1/),"float")
  seaice_1b  = new((/ngroup,n_sn_1b,n_we_1b/),"float")
  ndates_1   = new((/ngroup/),"integer")
  ndates_1b  = new((/ngroup/),"integer")
  fill = var1@_FillValue

;;;;;;;;;;
; Load in actual data for analysis
;;;;;;;;;;
n = 0
; loop through each node
do g = 0, ngroup - 1
  g1 = g+1
  print("group: "+g1)
  ; file 1
  fname1 = "group_"+g1+"_"+datatitle1
  f1 = addfile(dir1 + fname1 + "-fluxes-sst.nc","r")
  var1(g,:,:) = f1->$invar1$(south_north|:,west_east|:)
  variance1(g,:,:) = f1->$invar_v$(south_north|:,west_east|:)
  seaice_1(g,:,:) = f1->SeaIce_avg(south_north|:,west_east|:)
  ndates_1(g) = f1->number_dates
  ; file 1b
  fname1b = "group_"+g1+"_"+datatitle1b
  f1b = addfile(dir1 + fname1b + "-fluxes-sst.nc","r")
  var1b(g,:,:) = f1b->$invar1$(south_north|:,west_east|:)
  variance1b(g,:,:) = f1b->$invar_v$(south_north|:,west_east|:)
  seaice_1b(g,:,:) = f1b->SeaIce_avg(south_north|:,west_east|:)
  ndates_1b(g) = f1b->number_dates

  ; delete vars to use in next loop
  delete(fname1)
  delete(f1)
  delete(fname1b)
  delete(f1b)
  n = n+1
end do
delete(n)

; change units for curltau variable and get rid of nans, etc.
if (varcode .eq. "curltau")then
  var1 = where(var1 .eq. "nan" .or. var1 .eq. "-nan" .or. var1 .eq. "inf" .or. var1 .eq. "-inf", fill, var1)
  var1b = where(var1b .eq. "nan" .or. var1b .eq. "-nan" .or. var1b .eq. "inf" .or. var1b .eq. "-inf", fill, var1b)
  var1 = var1*10.0E5
  var1b = var1b*10.0E5
  var1@units = "10E-5 N m-3"
  var1b@units = "10E-5 N m-3"
end if

print("Loaded "+varcode+" from both files")

;;;;;;;;;;
; Calculate frequencies for each data type
;;;;;;;;;;
  ; convert the dates to floats to avoid rounding issues
  dum = int2flt(ndates_1)
  delete(ndates_1)
  ndates_1 = dum
  delete(dum)
  dum = int2flt(ndates_1b)
  delete(ndates_1b)
  ndates_1b = dum
  delete(dum)

  freq_groups_1  = (ndates_1/sum(ndates_1))*100.0
  freq_groups_1b = (ndates_1b/sum(ndates_1b))*100.0

;;;;;;;;;;
; Calculate if frequencies are statistically different
;;;;;;;;;;
; make new array to plot
test_stat = new((/ngroup/),float)
test_stat = 0.
freq_diff = freq_groups_1 - freq_groups_1b
test_stat_num = freq_diff/100.
nf1 = freq_groups_1/100.  ; convert from % to just ratio
nf1b = freq_groups_1b/100.
test_stat_den = sqrt((nf1b*(1-nf1b)/ndates_1b) + (nf1*(1-nf1)/ndates_1))
test_stat_den = where(test_stat_den.eq.0,test_stat_den@_FillValue,test_stat_den) ; set 0 to missing to avoid divide by zero error
test_stat = test_stat_num/test_stat_den
test_stat = where(ismissing(test_stat),0,test_stat)
; statistical significance meanings:
; if test_stat .gt. 2.58 then it's 99% statistically significant
; if test_stat .ge. 1.96 and .lt. 2.58 then it's 95% statistically significant
; if test_stat .ge. 1.645 and .lt. 1.96 then it's 90% statistically significant
; NOTE: the same is true in reverse for negative values of these numbers

print("completed frequency calculations")
;;;;;;;;;;
; Interpolate to WRF10 size (if needed)
;;;;;;;;;;
if (tag_1 .eq. "wrf10" .and. tag_1b .ne. "wrf10")then
  ; get weights and indicies for regridding (WRF50 and era weightings are identical)
  weightin = addfile("/data3/duvivier/SOM/DATA/weightings_WRF50_to_WRF10.nc","r")
  interp_ind = weightin->interp_ind
  interp_wgt = weightin->interp_wgt

  print("Interpolating between resolutions")
  ; Make arrays we'll need in interpolation
  var1b_new = new((/ngroup,n_sn_1,n_we_1/),"float") 
  var1b_tmp_1d  = new((/n_tot_1/),"float")
  seaice_1b_new = new((/ngroup,n_sn_1,n_we_1/),"float") 
  seaice_1b_tmp_1d  = new((/n_tot_1/),"float")
  variance1b_new = new((/ngroup,n_sn_1,n_we_1/),"float") 
  variance1b_tmp_1d  = new((/n_tot_1/),"float")

  do n = 0, ngroup - 1
    var1b_1d = ndtooned(var1b(n,:,:))
    seaice_1b_1d = ndtooned(seaice_1b(n,:,:))
    variance1b_1d = ndtooned(variance1b(n,:,:))
    do i = 0, n_tot_1 - 1
      indices_all = interp_ind(i,:)
      n_indices = num(.not.ismissing(indices_all))
      if (n_indices .ne. 0.0) then
        indices = indices_all(0:n_indices-1)
        weight_all = interp_wgt(i,:)
        weight = weight_all(0:n_indices-1)
        var1b_tmp_1d(i) = sum(var1b_1d(indices)*weight/sum(weight))
        seaice_1b_tmp_1d(i) = sum(seaice_1b_1d(indices)*weight/sum(weight))
        variance1b_tmp_1d(i) = sum(variance1b_1d(indices)*weight/sum(weight))
        delete(indices)
        delete(weight)
      end if
    end do
    ; redimensionalize
    var1b_new(n,:,:) = onedtond(var1b_tmp_1d,(/n_sn_1,n_we_1/))
    seaice_1b_new(n,:,:) = onedtond(seaice_1b_tmp_1d,(/n_sn_1,n_we_1/)) 
    variance1b_new(n,:,:) = onedtond(variance1b_tmp_1d,(/n_sn_1,n_we_1/))

   ; counter
    print("created node avg "+n+" of "+ngroup)
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
  delete(variance1b)
  variance1b = variance1b_new
  delete(variance1b_new)
  copy_VarMeta(variance1, variance1b)
  copy_VarCoords(variance1,variance1b)
  variance1b@_FillValue = fill
end if

print("Masking terrain - nodes")
n = 0
; loop through each node
do n = 0, ngroup - 1
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
title_diff = "("+tag_1+" - "+tag_1b+")"

; Calculate statistical significance
; Uses student's t-test. If the probability is less than 0.1 then we know at a 90% confidence level
; that the two means are statistically significant.
prob = new((/ngroup,n_sn_1,n_we_1/),"float")
g = 0
do g = 0, ngroup - 1
  prob(g,:,:) = 100.*(1.-ttest(var1(g,:,:),variance1(g,:,:),ndates_1(g),var1b(g,:,:),variance1b(g,:,:),ndates_1b(g),False,False))
end do

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
prob@lat2d = lat2d_1
prob@lon2d = lon2d_1

; prints together the variable title (set above for each type of data) with title1 (defined in cshell as the wrf or met info) and the max and min values
print(vartitle+" var1 min: "+min(var1)+"  max: "+max(var1))
print(vartitle+" var1 min: "+min(var1b)+"  max: "+max(var1b))
print(vartitle+" difference min: "+min(diff)+"  max: "+max(diff)) 

print("completed node calculations")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Processing all graphs for "+varcode)
; create plots!
; plot 1 - Frequency and frequency differences of all nodes (only needed once)
; plot 2 - 8 panel of group averages for datatitle1
; plot 3 - 8 panel of group averages for datatitle1b
; plot 4 - 8 panel of group average differences
; plot 5 - 24 panel of group averages and differences
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; set outdir and fout names
outdir = "./"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 1 - Frequency differences
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot1").and.(plot1))then  ; if plotting is turned on
  print("Plot 1 - frequency differences")
  fout1 = "frequency_groups_"+datatitle1+"-"+datatitle1b
  title_1 = tag_1b
  title_2 = tag_1+"-"+tag_1b
  title = "SOM group frequency: 2005-2007 "+tag_1+" and "+tag_1b

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
  dum1  = new((/ngroup/),graphic)
  dum2  = new((/ngroup/),graphic)
  dum3  = new((/ngroup/),graphic)
  dum4  = new((/ngroup/),graphic)

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
; Set resources for normal plots
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

res@cnFillMode                 = cntype
res@cnFillOn                   = True              ; turn on filled contours
res@gsnSpreadColors            = True              ; use full colormap
res@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
res@cnLinesOn                  = plotlines         ; contour lines specified above
res@cnLineLabelsOn             = plotlines         ; line labels on specified above
res@cnMissingValFillColor      = "gray85"          ; missing value color
res@cnMissingValFillPattern    = 0                 ; fill in
res@cnMissingValPerimOn        = True
res@cnMissingValPerimColor     = "black"
res@tiMainFontHeightF          = 0.013
res@pmLabelBarOrthogonalPosF   = -0.01             ; move label bar closer
res@pmLabelBarHeightF          = 0.075             ; set height of labelbar

opts                            = res               ; reset options
opts@gsnSpreadColorStart        = spreadstart1      ; start at color specified for each variable above
opts@gsnSpreadColorEnd          = spreadend1        ; end at color specified above
opts@cnMinLevelValF             = cmin1             ; set min contour level specified above
opts@cnMaxLevelValF             = cmax1             ; set max contour level specified above
opts@cnLevelSpacingF            = clev1             ; set contour spacing specified above
opts@lbLabelStride              = stride1

optsd                            = res               ; reset options
optsd@gsnSpreadColorStart        = spreadstart2      ; start at color specified for each variable above
optsd@gsnSpreadColorEnd          = spreadend2        ; end at color specified above
optsd@cnMinLevelValF             = cmin2             ; set min contour level specified above
optsd@cnMaxLevelValF             = cmax2             ; set max contour level specified above
optsd@cnLevelSpacingF            = clev2             ; set contour spacing specified above
optsd@lbLabelStride              = stride2

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
res_95                            = True               ; reset options
res_95@gsnLeftString              = ""
res_95@gsnRightString             = ""
res_95@gsnFrame                   = False             ; Do not draw plot 
res_95@gsnDraw                    = False             ; Do not advance fr
res_95@cnInfoLabelOn              = False             ; Turn off info on contours at bottom
res_95@lbLabelBarOn               = False             ; Turn off contour label bar
res_95@cnFillOn                   = True              ; turn on filled contours
res_95@cnMonoFillColor            = True
res_95@cnMonoFillPattern          = False
res_95@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
res_95@cnMinLevelValF             = 0.                ; set min contour level specified above
res_95@cnMaxLevelValF             = 95.               ; set max contour level specified above
res_95@cnLevelSpacingF            = 95.               ; set contour spacing specified above
res_95@cnFillPatterns             = (/-1,-1,17/)      ; dots over areas where >95% sig. diff

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 2 - Winter averages
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot2").and.(plot2))then  ; if plotting is turned on
  print("Plot 2 - winter averages for variable1")
  fout2   = varcode+"_group_average_"+datatitle1

  wks2 = gsn_open_wks("ps" ,fout2)
  additional_colors = (/"gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks2,colormap,additional_colors)
  plot = new(ngroup, graphic)
  g = 0
  do g = 0, ngroup-1
    g1 = g+1
    opts@gsnCenterString               = "Group "+g1
    var1_2d = var1(g,:,:)
    seaice_1_2d = seaice_1(g,:,:)
  
    cplot  = gsn_csm_contour_map(wks2,var1_2d,opts)
    cplot2 = gsn_csm_contour(wks2,seaice_1_2d,res_ice)
    overlay(cplot,cplot2)
;  cplot2b = gsn_csm_contour(wks4,seaice_1_2d,res_ice2)
;  overlay(cplot,cplot2b)
    plot(g) = cplot
  end do
    
;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
title_fin = tag_1+" "+vartitle + " ("+var1@units+")"

  res_pan                            = True
  res_pan@txString                   = title_fin        ; main title
  res_pan@txFontHeightF              = 0.02
  res_pan@gsnPaperOrientation        = "landscape"      ; landscape mode
  res_pan@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  res_pan@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  res_pan@gsnPanelScalePlotIndex     = 1
  res_pan@gsnMaximize                = True	       ; fill the page
  gsn_panel(wks2,(/plot/),(/2,4/),res_pan)               ; create final panel plot


; Finally - make plot
  print("converting plot 2 to png")
  convert_cmd = "convert -density 300 "+fout2+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout2+".png"
  system(convert_cmd)
  delete(title_fin)
  delete(additional_colors)
  delete(plot)
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 3 - Winter averages 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot3").and.(plot3))then  ; if plotting is turned on
  print("Plot 3 - winter averages for variable1")
  fout3   = varcode+"_group_average_"+datatitle1b

  wks3 = gsn_open_wks("ps" ,fout3)
  additional_colors = (/"gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks3,colormap,additional_colors)
  plot = new(ngroup, graphic)
  g = 0
  do g = 0, ngroup-1
    g1 = g+1
    opts@gsnCenterString               = "Group "+g1
    var1b_2d = var1b(g,:,:)
    seaice_1b_2d = seaice_1b(g,:,:)
  
    cplot  = gsn_csm_contour_map(wks3,var1b_2d,opts)
    cplot2 = gsn_csm_contour(wks3,seaice_1b_2d,res_ice)
    overlay(cplot,cplot2)
;  cplot2b = gsn_csm_contour(wks4,seaice_1_2d,res_ice2)
;  overlay(cplot,cplot2b)
    plot(g) = cplot
  end do

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
title_fin = tag_1b+" "+vartitle + " ("+var1@units+")"

  res_pan                            = True
  res_pan@txString                   = title_fin        ; main title
  res_pan@txFontHeightF              = 0.02
  res_pan@gsnPaperOrientation        = "landscape"      ; landscape mode
  res_pan@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  res_pan@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  res_pan@gsnPanelScalePlotIndex     = 1
  res_pan@gsnMaximize                = True	       ; fill the page
  gsn_panel(wks3,(/plot/),(/2,4/),res_pan)               ; create final panel plot


; Finally - make plot
  print("converting plot 3 to png")
  convert_cmd = "convert -density 300 "+fout3+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout3+".png"
  system(convert_cmd)
  delete(title_fin)
  delete(additional_colors)
  delete(plot)
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 4 - Winter difference
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot4").and.(plot4))then  ; if plotting is turned on
  print("Plot 4 - winter averages differences")
  fout4   = varcode+"_group_average_diff_"+datatitle1+"_"+datatitle1b

  wks4 = gsn_open_wks("ps" ,fout4)
  additional_colors = (/"gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks4,colormap,additional_colors)
  plot = new(ngroup, graphic)
  g = 0
  do g = 0, ngroup-1
    g1 = g+1
    opts@gsnCenterString               = "Group "+g1
    diff_2d = diff(g,:,:)
    prob_2d = prob(g,:,:)
  
    cplot  = gsn_csm_contour_map(wks4,diff_2d,optsd)
    cplot2 = gsn_csm_contour(wks4,prob_2d,res_95)
    overlay(cplot,cplot2)
    plot(g) = cplot
  end do

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
title_fin = vartitle + " Difference "+title_diff+" ("+var1@units+")"

  res_pan                            = True
  res_pan@txString                   = title_fin        ; main title
  res_pan@txFontHeightF              = 0.02
  res_pan@gsnPaperOrientation        = "landscape"      ; landscape mode
  res_pan@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  res_pan@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  res_pan@gsnPanelScalePlotIndex     = 1
  res_pan@gsnMaximize                = True	       ; fill the page
  gsn_panel(wks4,(/plot/),(/2,4/),res_pan)               ; create final panel plot


; Finally - make plot
  print("converting plot 4 to png")
  convert_cmd = "convert -density 300 "+fout4+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout4+".png"
  system(convert_cmd)
  delete(title_fin)
  delete(additional_colors)
  delete(plot)
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 5 - 24 panel of averages and difference
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot5").and.(plot5))then  ; if plotting is turned on
  print("Plot 5 - winter averages and differences")
  fout5   = varcode+"_group_all_avgs_diff_"+datatitle1+"_"+datatitle1b

  wks5 = gsn_open_wks("ps" ,fout5)
  additional_colors = (/"gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks5,colormap,additional_colors)
  plot = new(24, graphic)

; Variable 1
  ; group 1 
  opts@gsnCenterString                 = "Group 1: "+tag_1
  cplot  = gsn_csm_contour_map(wks5,var1(0,:,:),opts)
  cplot2 = gsn_csm_contour(wks5,seaice_1(0,:,:),res_ice)
  overlay(cplot,cplot2)
  plot(0) = cplot
  ; group 2 
  opts@gsnCenterString                 = "Group 2: "+tag_1
  cplot  = gsn_csm_contour_map(wks5,var1(1,:,:),opts)
  cplot2 = gsn_csm_contour(wks5,seaice_1(1,:,:),res_ice)
  overlay(cplot,cplot2)
  plot(1) = cplot
  ; group 3 
  opts@gsnCenterString                 = "Group 3: "+tag_1
  cplot  = gsn_csm_contour_map(wks5,var1(2,:,:),opts)
  cplot2 = gsn_csm_contour(wks5,seaice_1(2,:,:),res_ice)
  overlay(cplot,cplot2)
  plot(2) = cplot
  ; group 4 
  opts@gsnCenterString                 = "Group 4: "+tag_1
  cplot  = gsn_csm_contour_map(wks5,var1(3,:,:),opts)
  cplot2 = gsn_csm_contour(wks5,seaice_1(3,:,:),res_ice)
  overlay(cplot,cplot2)
  plot(3) = cplot
  ; group 5 
  opts@gsnCenterString                 = "Group 5: "+tag_1
  cplot  = gsn_csm_contour_map(wks5,var1(4,:,:),opts)
  cplot2 = gsn_csm_contour(wks5,seaice_1(4,:,:),res_ice)
  overlay(cplot,cplot2)
  plot(4) = cplot
  ; group 6 
  opts@gsnCenterString                 = "Group 6: "+tag_1
  cplot  = gsn_csm_contour_map(wks5,var1(5,:,:),opts)
  cplot2 = gsn_csm_contour(wks5,seaice_1(5,:,:),res_ice)
  overlay(cplot,cplot2)
  plot(5) = cplot
  ; group 7 
  opts@gsnCenterString                 = "Group 7: "+tag_1
  cplot  = gsn_csm_contour_map(wks5,var1(6,:,:),opts)
  cplot2 = gsn_csm_contour(wks5,seaice_1(6,:,:),res_ice)
  overlay(cplot,cplot2)
  plot(6) = cplot
  ; group 8 
  opts@gsnCenterString                 = "Group 8: "+tag_1
  cplot  = gsn_csm_contour_map(wks5,var1(7,:,:),opts)
  cplot2 = gsn_csm_contour(wks5,seaice_1(7,:,:),res_ice)
  overlay(cplot,cplot2)
  plot(7) = cplot
; Variable 1b
  ; group 1 
  opts@gsnCenterString                 = "Group 1: "+tag_1b
  cplot  = gsn_csm_contour_map(wks5,var1b(0,:,:),opts)
  cplot2 = gsn_csm_contour(wks5,seaice_1b(0,:,:),res_ice)
  overlay(cplot,cplot2)
  plot(8) = cplot
  ; group 2 
  opts@gsnCenterString                 = "Group 2: "+tag_1b
  cplot  = gsn_csm_contour_map(wks5,var1b(1,:,:),opts)
  cplot2 = gsn_csm_contour(wks5,seaice_1b(1,:,:),res_ice)
  overlay(cplot,cplot2)
  plot(9) = cplot
  ; group 3 
  opts@gsnCenterString                 = "Group 3: "+tag_1b
  cplot  = gsn_csm_contour_map(wks5,var1b(2,:,:),opts)
  cplot2 = gsn_csm_contour(wks5,seaice_1b(2,:,:),res_ice)
  overlay(cplot,cplot2)
  plot(10) = cplot
  ; group 4 
  opts@gsnCenterString                 = "Group 4: "+tag_1b
  cplot  = gsn_csm_contour_map(wks5,var1b(3,:,:),opts)
  cplot2 = gsn_csm_contour(wks5,seaice_1b(3,:,:),res_ice)
  overlay(cplot,cplot2)
  plot(11) = cplot
  ; group 5 
  opts@gsnCenterString                 = "Group 5: "+tag_1b
  cplot  = gsn_csm_contour_map(wks5,var1b(4,:,:),opts)
  cplot2 = gsn_csm_contour(wks5,seaice_1b(4,:,:),res_ice)
  overlay(cplot,cplot2)
  plot(12) = cplot
  ; group 6 
  opts@gsnCenterString                 = "Group 6: "+tag_1b
  cplot  = gsn_csm_contour_map(wks5,var1b(5,:,:),opts)
  cplot2 = gsn_csm_contour(wks5,seaice_1b(5,:,:),res_ice)
  overlay(cplot,cplot2)
  plot(13) = cplot
  ; group 7 
  opts@gsnCenterString                 = "Group 7: "+tag_1b
  cplot  = gsn_csm_contour_map(wks5,var1b(6,:,:),opts)
  cplot2 = gsn_csm_contour(wks5,seaice_1b(6,:,:),res_ice)
  overlay(cplot,cplot2)
  plot(14) = cplot
  ; group 8 
  opts@gsnCenterString                 = "Group 8: "+tag_1b
  cplot  = gsn_csm_contour_map(wks5,var1b(7,:,:),opts)
  cplot2 = gsn_csm_contour(wks5,seaice_1b(7,:,:),res_ice)
  overlay(cplot,cplot2)
  plot(15) = cplot
; Difference
  ; group 1 
  optsd@gsnCenterString                 = "Group 1"
  cplot  = gsn_csm_contour_map(wks5,diff(0,:,:),optsd)
  cplot2 = gsn_csm_contour(wks5,prob(0,:,:),res_95)
  overlay(cplot,cplot2)
  plot(16) = cplot
  ; group 2 
  optsd@gsnCenterString                 = "Group 2"
  cplot  = gsn_csm_contour_map(wks5,diff(1,:,:),optsd)
  cplot2 = gsn_csm_contour(wks5,prob(1,:,:),res_95)
  overlay(cplot,cplot2)
  plot(17) = cplot
  ; group 3 
  optsd@gsnCenterString                 = "Group 3"
  cplot  = gsn_csm_contour_map(wks5,diff(2,:,:),optsd)
  cplot2 = gsn_csm_contour(wks5,prob(2,:,:),res_95)
  overlay(cplot,cplot2)
  plot(18) = cplot
  ; group 4 
  optsd@gsnCenterString                 = "Group 4"
  cplot  = gsn_csm_contour_map(wks5,diff(3,:,:),optsd)
  cplot2 = gsn_csm_contour(wks5,prob(3,:,:),res_95)
  overlay(cplot,cplot2)
  plot(19) = cplot
  ; group 5 
  optsd@gsnCenterString                 = "Group 5"
  cplot  = gsn_csm_contour_map(wks5,diff(4,:,:),optsd)
  cplot2 = gsn_csm_contour(wks5,prob(4,:,:),res_95)
  overlay(cplot,cplot2)
  plot(20) = cplot
  ; group 6 
  optsd@gsnCenterString                 = "Group 6"
  cplot  = gsn_csm_contour_map(wks5,diff(5,:,:),optsd)
  cplot2 = gsn_csm_contour(wks5,prob(5,:,:),res_95)
  overlay(cplot,cplot2)
  plot(21) = cplot
  ; group 7 
  optsd@gsnCenterString                 = "Group 7"
  cplot  = gsn_csm_contour_map(wks5,diff(6,:,:),optsd)
  cplot2 = gsn_csm_contour(wks5,prob(6,:,:),res_95)
  overlay(cplot,cplot2)
  plot(22) = cplot
  ; group 8 
  optsd@gsnCenterString                 = "Group 8"
  cplot  = gsn_csm_contour_map(wks5,diff(7,:,:),optsd)
  cplot2 = gsn_csm_contour(wks5,prob(7,:,:),res_95)
  overlay(cplot,cplot2)
  plot(23) = cplot

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
title_fin = vartitle + " and "+title_diff+" ("+var1@units+")"

  res_pan                            = True
  res_pan@txString                   = title_fin        ; main title
  res_pan@txFontHeightF              = 0.015
  res_pan@gsnPaperOrientation        = "landscape"      ; landscape mode
  res_pan@gsnPanelYWhiteSpacePercent = 0 ;3                ; Add white space b/w plots.
  res_pan@gsnPanelXWhiteSpacePercent = 0 ;3                ; Add white space b/w plots.
  res_pan@gsnPanelScalePlotIndex     = 1
  res_pan@gsnMaximize                = True	       ; fill the page
  gsn_panel(wks5,(/plot/),(/6,4/),res_pan)               ; create final panel plot


; Finally - make plot
  print("converting plot 5 to png")
  convert_cmd = "convert -density 300 "+fout5+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout5+".png"
  system(convert_cmd)
  delete(title_fin)
  delete(additional_colors)
  delete(plot)
end if

print("Completed all plots for "+varcode)
print("Good job!")
;;;;;;;;;;;;;;;;;;;;;; END script
end
