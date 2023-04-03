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
  datatitle1 = "era_i_200511_200703_6h"
  datatitle2 = "wrf50_200511_200703_6h"
  datatitle3 = "wrf10_200511_200703_6h"
  varcode = "q_2m"
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; BEGIN SCRIPT
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
end if
if (varcode.eq."curltau")then
  vartitle1 = "Avg 10m wind stress curl"
  invar1 = "curl_tau_avg"
  invar_v = "curl_tau_var"
  vartype = "2d"
  cmaptype = "curlt"
end if
if (varcode.eq."Tgrad") then
  vartitle1 = "Avg Temp grad (sfc-2m)"
  invar1 = "T_grad_avg"
  invar_v = "T_grad_var"
  vartype = "2d"
  cmaptype = "temp_grad"
end if
if (varcode.eq."T_sfc")then
  vartitle1 = "Avg Sea Sfc Temp"
  invar1 = "SST_avg"
  invar_v = "SST_var"
  vartype = "2d"
  cmaptype = "temperature"
end if
if (varcode.eq."T_2m")then
  vartitle1 = "Avg Temp at 2m"
  invar1 = "T_2m_avg"
  invar_v = "T_2m_var"
  vartype = "2d"
  cmaptype = "temperature"
end if
if (varcode.eq."qgrad") then
  vartitle1 = "Avg Mixing Ratio grad (sfc-2m)"
  invar1 = "q_grad_avg"
  invar_v = "q_grad_var"
  vartype = "2d"
  cmaptype = "mix_grad"
end if
if (varcode.eq."q_sfc")then
  vartitle1 = "Avg Mixing Ratio at sfc"
  invar1 = "q_sfc_avg"
  invar_v = "q_sfc_var"
  vartype = "2d"
  cmaptype = "mix_rad"
end if
if (varcode.eq."q_2m")then
  vartitle1 = "Avg Mixing Ratio at 2m"
  invar1 = "q_2m_avg"
  invar_v = "q_2m_var"
  vartype = "2d"
  cmaptype = "mix_rad"
end if
if (varcode.eq."SH") then
  vartitle1 = "Avg SH Flux at sfc"
  invar1 = "SHFlx_avg"
  invar_v = "SHFlx_var"
  vartype = "2d"
  cmaptype = "shflux"
end if
if (varcode.eq."LH") then
  vartitle1 = "Avg LH Flux at sfc"
  invar1 = "LHFlx_avg"
  invar_v = "LHFlx_var"
  vartype = "2d"
  cmaptype = "lhflux"
end if
if (varcode.eq."TurbFlx") then
  vartitle1 = "Avg Total Turb Flux at sfc"
  invar1 = "Turb_net_avg"
  invar_v = "Turb_net_var"
  vartype = "2d"
  cmaptype = "flux"
end if

; Set the contour interval for each input variable   
; set contour limits manually:
  if (cmaptype.eq."wind") then
    cmin1               = 0.
    cmax1               = 15.
    clev1               = 1.
    stride1             = 1                 ; label stride
    cmin2               = -7.
    cmax2               = 7.
    clev2               = 0.5
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
    colormap1           = "SOM_wind_table_mod" 
    spreadstart2        = 20 ;37                ; start at color
    spreadend2          = 115 ;132               ; end at color
    colormap2           = "SOM_wind_table_mod" 
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
    colormap            = "temp64_anoms.dave"
  end if
  if (cmaptype.eq."temperature") then
    cmin1               = -10.
    cmax1               = 10.
    clev1               = 1.
    stride1             = 2                 ; label stride
    cmin2               = -7.
    cmax2               = 7.
    clev2               = 1.
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
    colormap1           = "temp64_anoms.dave"
    spreadstart2        = 20 ;37                ; start at color
    spreadend2          = 115 ;132               ; end at color
    colormap2           = "SOM_wind_table_mod" 
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
    colormap            = "BrownBlue_mod"
  end if
  if (cmaptype.eq."mix_rad") then
    cmin1               =  0.
    cmax1               =  5.0
    clev1               =  0.5
    stride1             =  2                 ; label stride
    cmin2               =  -0.5
    cmax2               =  0.5
    clev2               =  0.1
    stride2             =  1                 ; label stride diff plot
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
    spreadstart1        = 86                ; start at color
    spreadend1          = 67                ; end at color
    colormap1           = "temp64_anoms.dave"
;    spreadstart1        = 44                ; start at color
;    spreadend1          = 85                ; end at color
;    colormap1           = "BrownBlue_mod"
    spreadstart2        = 2                 ; start at color
    spreadend2          = 85                ; end at color
    colormap2           = "BrownBlue_mod"
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
    colormap            = "BlueYellowRed_mod"
  end if
  if (cmaptype.eq."flux") then
    cmin1               =  -300.
    cmax1               =  300.
    clev1               =  30.
    stride1             =  2                 ; label stride
    cmin2               = -300.
    cmax2               =  300.
    clev2               =  30.
    stride2             =  2                 ; label stride diff plot
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
    colormap            = "BlueYellowRed_mod"
  end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Data Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dir1 = "/data3/duvivier/SOM/analysis/flux_compare/node_avgs/fluxes-sst/"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Use net average files to calculate difference
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  fname1 = "net_avg_"+datatitle1
  fname2 = "net_avg_"+datatitle2
  fname3 = "net_avg_"+datatitle3
  f1 = addfile(dir1+fname1+"-fluxes-sst.nc","r")
  f2 = addfile(dir1+fname2+"-fluxes-sst.nc","r")
  f3 = addfile(dir1+fname3+"-fluxes-sst.nc","r")  
  obs_1 = f1->number_dates

;;;;;;;;;;
; Load in actual data for analysis
;;;;;;;;;;
  avg1 = f1->$invar1$
  avg_variance1 = f1->$invar_v$
  avg_seaice1 = f1->SeaIce_avg

  avg2 = f2->$invar1$
  avg_variance2 = f2->$invar_v$
  avg_seaice2 = f2->SeaIce_avg

  avg3 = f3->$invar1$
  avg_variance3 = f3->$invar_v$
  avg_seaice3 = f3->SeaIce_avg

  dum = new((/1/),"float")
  fill = dum@_FillValue
  delete(dum)

  ; special instructions for wind stress curl
  if (varcode .eq. "curltau")then
    avg1 = where(avg1.eq."nan".or.avg1.eq."-nan".or.avg1.eq."inf".or.avg1.eq."-inf", fill, avg1)
    avg2 = where(avg2.eq."nan".or.avg2.eq."-nan".or.avg2.eq."inf".or.avg2.eq."-inf", fill, avg2)
    avg3 = where(avg3.eq."nan".or.avg3.eq."-nan".or.avg3.eq."inf".or.avg3.eq."-inf", fill, avg3)

    avg1 = avg1*10.0E5
    avg1@units = "10E-5 N m-3"
    avg2 = avg2*10.0E5
    avg2@units = "10E-5 N m-3"
    avg3 = avg3*10.0E5
    avg3@units = "10E-5 N m-3"
  end if

  ; load lat and lon for 50km file
  lat2d_a = f1->lat
  lon2d_a = f1->lon
  z_sfc_a = f1->Z_sfc

  dims = dimsizes(avg1)
  n_sn_a = dims(0)
  n_we_a = dims(1)
  n_tot_a = n_sn_a*n_we_a
  delete(dims)

  ; load lat and lon for 10km file
  lat2d_b = f3->lat
  lon2d_b = f3->lon
  z_sfc_b = f3->Z_sfc
  mask_50km = f3->mask_50km_terrain

  dims = dimsizes(avg3)
  n_sn_b = dims(0)
  n_we_b = dims(1)
  n_tot_b = n_sn_b*n_we_b
  delete(dims)

  delete(f1)
  delete(f2)
  delete(f3)
print("Loaded variables from both files")

;;;;;;;;;;
; Interpolate to WRF10 size (if needed)
;;;;;;;;;;
print("Interpolating between resolutions")
; load indices and weights
weightin = addfile("/data3/duvivier/SOM/DATA/weightings_WRF50_to_WRF10.nc","r")
interp_ind = weightin->interp_ind
interp_wgt = weightin->interp_wgt

; Make arrays we'll need in interpolation
avg2b = new((/n_sn_b,n_we_b/),"float") 
avg2b_tmp_1d  = new((/n_tot_b/),"float")
avg_variance2b = new((/n_sn_b,n_we_b/),"float") 
avg_variance2b_tmp_1d  = new((/n_tot_b/),"float")
avg_seaice2b = new((/n_sn_b,n_we_b/),"float") 
avg_seaice2b_tmp_1d  = new((/n_tot_b/),"float")

avg2b_1d = ndtooned(avg2(:,:))
avg_variance2b_1d = ndtooned(avg_variance2(:,:))
avg_seaice2b_1d = ndtooned(avg_seaice2(:,:))
  
; still have terrain array to keep high points out of interpolation
 Z_sfc_tmp_1d = ndtooned(z_sfc_a)
; interpolate
do i = 0, n_tot_b - 1
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
      avg2b_tmp_1d(i) = sum(avg2b_1d(indices(sealevel))*weight(sealevel)/sum(weight(sealevel)))
      avg_variance2b_tmp_1d(i) = sum(avg_variance2b_1d(indices(sealevel))*weight(sealevel)/sum(weight(sealevel)))
      avg_seaice2b_tmp_1d(i) = sum(avg_seaice2b_1d(indices(sealevel))*weight(sealevel)/sum(weight(sealevel)))
    end if
    delete(indices)
    delete(weight)
    delete(terrain_sub)
    delete(sealevel)
  end if
end do

; redimensionalize
avg2b(:,:) = onedtond(avg2b_tmp_1d,(/n_sn_b,n_we_b/))
avg_variance2b(:,:) = onedtond(avg_variance2b_tmp_1d,(/n_sn_b,n_we_b/))
avg_seaice2b(:,:) = onedtond(avg_seaice2b_tmp_1d,(/n_sn_b,n_we_b/))

; get correct information
copy_VarMeta(avg3, avg2b)
copy_VarMeta(avg_variance3, avg_variance2b)
copy_VarMeta(avg_seaice3, avg_seaice2b)

print("Masking terrain - net")
; mask terrain and lat/lons - focus on ocean and  S. Greenland region 
; 50km domain
avg1(:,:) = where(z_sfc_a .lt. 10., avg1(:,:), fill)
avg2(:,:) = where(z_sfc_a .lt. 10., avg2(:,:), fill)
avg_seaice1(:,:) = where(z_sfc_a .lt. 10., avg_seaice1(:,:), fill)
avg_seaice2(:,:) = where(z_sfc_a .lt. 10., avg_seaice2(:,:), fill)

avg1(:,:) = where(lat2d_a .gt. 55. .and. lat2d_a .lt. 71. .and. lon2d_a .lt. -19. .and. lon2d_a .gt. -55., avg1(:,:), fill)
avg2(:,:) = where(lat2d_a .gt. 55. .and. lat2d_a .lt. 71. .and. lon2d_a .lt. -19. .and. lon2d_a .gt. -55., avg2(:,:), fill)
avg_seaice1(:,:) = where(lat2d_a .gt. 55. .and. lat2d_a .lt. 71. .and. lon2d_a .lt. -19. .and. lon2d_a .gt. -55., avg_seaice1(:,:), fill)
avg_seaice2(:,:) = where(lat2d_a .gt. 55. .and. lat2d_a .lt. 71. .and. lon2d_a .lt. -19. .and. lon2d_a .gt. -55., avg_seaice2(:,:), fill)

; 10km domain
avg3(:,:) = where(mask_50km .eq. 1, avg3(:,:), fill)
avg2b(:,:) = where(mask_50km .eq. 1, avg2b(:,:), fill)
avg_seaice3(:,:) = where(mask_50km .eq. 1, avg_seaice3(:,:), fill)
avg_seaice2b(:,:) = where(mask_50km .eq. 1, avg_seaice2b(:,:), fill)

avg3(:,:) = where(lat2d_b .gt. 55. .and. lat2d_b .lt. 71. .and. lon2d_b .lt. -19. .and. lon2d_b .gt. -55., avg3(:,:), fill)
avg2b(:,:) = where(lat2d_b .gt. 55. .and. lat2d_b .lt. 71. .and. lon2d_b .lt. -19. .and. lon2d_b .gt. -55., avg2b(:,:), fill)
avg_seaice3(:,:) = where(lat2d_b .gt. 55. .and. lat2d_b .lt. 71. .and. lon2d_b .lt. -19. .and. lon2d_b .gt. -55., avg_seaice3(:,:), fill)
avg_seaice2b(:,:) = where(lat2d_b .gt. 55. .and. lat2d_b .lt. 71. .and. lon2d_b .lt. -19. .and. lon2d_b .gt. -55., avg_seaice2b(:,:), fill)

; assign metadata as necessary
avg1@_FillValue = fill
avg2@_FillValue = fill
avg2b@_FillValue = fill
avg3@_FillValue = fill
avg_seaice1@_FillValue = fill
avg_seaice2@_FillValue = fill
avg_seaice2b@_FillValue = fill
avg_seaice3@_FillValue = fill
avg_variance1@_FillValue = fill
avg_variance2@_FillValue = fill
avg_variance2b@_FillValue = fill
avg_variance3@_FillValue = fill

; assign lat/lon info
avg1@lat2d = lat2d_a
avg1@lon2d = lon2d_a
avg2@lat2d = lat2d_a
avg2@lon2d = lon2d_a
avg2b@lat2d = lat2d_b
avg2b@lon2d = lon2d_b
avg3@lat2d = lat2d_b
avg3@lon2d = lon2d_b
avg_seaice1@lat2d = lat2d_a
avg_seaice1@lon2d = lon2d_a
avg_seaice2@lat2d = lat2d_a
avg_seaice2@lon2d = lon2d_a
avg_seaice2b@lat2d = lat2d_b
avg_seaice2b@lon2d = lon2d_b
avg_seaice3@lat2d = lat2d_b
avg_seaice3@lon2d = lon2d_b
avg_variance1@lat2d = lat2d_a
avg_variance1@lon2d = lon2d_a
avg_variance2@lat2d = lat2d_a
avg_variance2@lon2d = lon2d_a
avg_variance2b@lat2d = lat2d_b
avg_variance2b@lon2d = lon2d_b
avg_variance3@lat2d = lat2d_b
avg_variance3@lon2d = lon2d_b

;;;;;;;;;;
; Find difference
;;;;;;;;;;
diff_a = avg2 - avg1
diff_b = avg3 - avg2b

diff_a@lat2d = lat2d_a
diff_a@lon2d = lon2d_a
diff_b@lat2d = lat2d_b
diff_b@lon2d = lon2d_b

;;;;;;;;;;
; Calculate statistical significance
;;;;;;;;;;
; Uses student's t-test. If the probability is less than 0.05 then we know at a 95% confidence level
; that the two means are statistically significant.
prob_a = 100.*(1. - ttest(avg1,avg_variance1,obs_1(0), avg2,avg_variance2,obs_1(0), False, False))
mask_95_prob_a = where(prob_a .gt. 95., 1, fill)

prob_b = 100.*(1. - ttest(avg3,avg_variance3,obs_1(0), avg2b,avg_variance2b,obs_1(0), False, False))
mask_95_prob_b = where(prob_b .gt. 95., 1, fill)

; DO NOT INCLUDE MINIMUM CUTOFF
; make mask of points that are statistically significant at 95% level
; and fulfill cutoff of minimum differences
;if (varcode .eq. "U10") then
;  ; 1 m/s difference cutoff (~10% max diff)
;  mask_95_prob = where(avg_prob .gt. 95., 1, fill)
;  mask_min_diff = where(abs(winter_diff) .gt. 0.95, 1, fill)
;  mask_all = where(mask_95_prob .eq. 1 .and. mask_min_diff .eq. 1, 1, fill)
;end if
;if (varcode .eq. "LH" .or. varcode .eq. "SH") then
;  ; 10 W/m2 difference cutoff (~10% max diff)
;  mask_95_prob = where(avg_prob .gt. 95., 1, fill)
;  mask_min_diff = where(abs(winter_diff) .gt. 10., 1, fill)
;  mask_all = where(mask_95_prob .eq. 1 .and. mask_min_diff .eq. 1, 1, fill)
;  mask_all = mask_95_prob
;end if
;if (varcode .eq. "curltau")then
;  ; 0.4X10E-5 N/m3 difference cutoff (~10% max diff)
;  mask_95_prob = where(avg_prob .gt. 95., 1, fill)
;  mask_min_diff = where(abs(winter_diff) .gt. 0.4, 1, fill)
;  mask_all = where(mask_95_prob .eq. 1 .and. mask_min_diff .eq. 1, 1, fill)
;end if
;if (varcode .ne. "U10" .and. varcode .ne. "LH" .and. varcode .ne. "SH" .and. varcode .ne. "curltau")then
;  ; all other variables
;  mask_95_prob = where(avg_prob .gt. 95., 1, fill)
;  mask_all = mask_95_prob
;end if

; now get values for the mask so that we can actually plot it
; get numbers between 95 and 100 for the values this fits so we can contour properly
low =  95
high = 99.5
con = (high-low)/32766.0

dum1 = ndtooned(mask_95_prob_a)
dum2 = ndtooned(avg1)
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
prob_plot_a = onedtond(dum3,(/n_sn_a,n_we_a/))
delete(dum1)
delete(dum2)
delete(dum3)
delete(dims)

dum1 = ndtooned(mask_95_prob_b)
dum2 = ndtooned(avg3)
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
prob_plot_b = onedtond(dum3,(/n_sn_b,n_we_b/))
delete(dum1)
delete(dum2)
delete(dum3)
delete(dims)

; assign lat/lon
prob_plot_a@lat2d = lat2d_a
prob_plot_a@lon2d = lon2d_a
prob_plot_b@lat2d = lat2d_b
prob_plot_b@lon2d = lon2d_b

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Processing all graphs for "+varcode)
; create plots!
; plot 2 - 3 panel of winter average values and difference and % contribution terms
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; set outdir and fout names
outdir = "./"

  ; Set resources for plot
  res                             = True              ; plot mods desired
  res@gsnRightString              = ""
  res@gsnLeftString               = ""               ; Set this in loop
  res@gsnFrame                    = False             ; Do not draw plot 
  res@gsnDraw                     = False             ; Do not advance fr
  res@gsnAddCyclic                = False             ; regional - not cyclic
  res@gsnMaximize                 = True              ; Make it as big as possible
  res@mpProjection                = "Stereographic"   ; map projection
  res@mpCenterLonF                = -35. ;-30.             ; set the center lat/lon
  res@mpCenterLatF                = 63.               
  res@mpGridAndLimbOn             = False            ; Turn on lat/lon grid
  res@mpGridLineDashPattern       = 2                ; Change dash pattern
  res@mpFillOn                    = True             ; Enables map fill
  res@mpGeophysicalLineColor      = "black"          ; Color of continents
  res@mpGeophysicalLineThicknessF = 1.5              ; Make continents thinner
 
  res@mpLimitMode                 = "LatLon"	     ; how to zoom in on map
  res@mpMinLatF                   = 56.              ; set the minimum latitude 
  res@mpMaxLatF                   = 70.              ; set the maximum latitude 
  res@mpMinLonF                   = -54.0            ; set the minimum longitude 
  res@mpMaxLonF                   = -20.0            ; set the maximum longitude 

  ; contour resources for all plots
  res@cnFillMode                  = cntype
  res@cnFillOn                    = True              ; turn on filled contours
  res@gsnSpreadColors             = True              ; use full colormap  
  res@cnLevelSelectionMode        = "ManualLevels"    ; set manual contour
  res@cnMissingValFillColor       = "gray85"          ; missing value color
  res@cnMissingValFillPattern     = 0                 ; fill in
  res@cnMissingValPerimOn         = True
  res@cnMissingValPerimColor      = "black"
  res@tiMainFontHeightF           = 0.015
  res@lbLabelBarOn                = False
  res@cnInfoLabelOn               = False
;  res@lbLabelStride              = stride1
;  res@pmLabelBarOrthogonalPosF   = -0.01             ; move label bar closer
;  res@pmLabelBarHeightF          = 0.075             ; set height of labelbar

;;;;;;;;;;;;;
; Set resources for "normal" plots
;;;;;;;;;;;;
  opts                            = res               ; reset options
  opts@gsnSpreadColorStart        = spreadstart1      ; start at color specified for each variable above
  opts@gsnSpreadColorEnd          = spreadend1        ; end at color specified above
  opts@cnMinLevelValF             = cmin1             ; set min contour level specified above
  opts@cnMaxLevelValF             = cmax1             ; set max contour level specified above
  opts@cnLevelSpacingF            = clev1             ; set contour spacing specified above
  opts@cnLinesOn                  = plotlines         ; contour lines specified above
  opts@cnLineLabelsOn             = plotlines         ; line labels on specified above

;;;;;;;;;;;;;
; Set resources for difference and term plots
;;;;;;;;;;;;
  optsd                            = res
  optsd@gsnSpreadColorStart        = spreadstart2      ; start at color specified above
  optsd@gsnSpreadColorEnd          = spreadend2        ; end at color specified above
  optsd@cnMinLevelValF             = cmin2             ; set min contour level specified above
  optsd@cnMaxLevelValF             = cmax2             ; set max contour level specified above
  optsd@cnLevelSpacingF            = clev2             ; set contour spacing specified above
  optsd@cnLinesOn                  = difflines         ; contour lines specified above
  optsd@cnLineLabelsOn             = difflines

;;;;;;;;;;;;;
; Set resources for seaice overlay
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

;;;;;;;;;;;;;
; Set resources for 95% significance overlay
;;;;;;;;;;;;
; set resources for 95% statistical significance overlay
  res_95                            = True               ; reset options
  res_95@gsnLeftString              = ""
  res_95@gsnRightString             = ""
  res_95@gsnFrame                   = False             ; Do not draw plot 
  res_95@gsnDraw                    = False             ; Do not advance fr
  res_95@cnInfoLabelOn              = False             ; Turn off info on contours at bottom
  res_95@lbLabelBarOn               = False             ; Turn off label bar
  res_95@cnFillOn                   = True              ; turn on filled contours
  res_95@cnMonoFillColor            = True
  res_95@cnMonoFillPattern          = False
  res_95@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  res_95@cnMinLevelValF             = 0.0              ; set min contour level specified above
  res_95@cnMaxLevelValF             = 95.              ; set max contour level specified above
  res_95@cnLevelSpacingF            = 95.0              ; set contour spacing specified above
;  res_95@cnFillPatterns             = (/17, -1, 17/)    ; stipling where not significant
  res_95@cnFillPatterns             = (/-1,-1,17/)      ; stipling where significant and above threshold

; label lat/lon
lat_ta = 69.75
lon_ta = -40.0
lat_tb = 68.75
lon_tb = -40.0
lat_tc = 68.0
lon_tc = -60.0
txres                             = True
txres@txFontHeightF               = 0.035 ;0.06
txres@txFontThicknessF            = 2.0
txres2 = txres
txres2@txFontHeightF              = 0.06

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 2 - Winter averages 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Plot 2 - winter averages and difference")
fout2   = "figure_5c1"

  wks2 = gsn_open_wks("ps" ,fout2)
  additional_colors = (/"gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks2,colormap1,additional_colors)
  plot = new(1, graphic)

;;;;;;;;;;;;;
; Make plot 0  - average wrf50 field
;;;;;;;;;;;;;
  cplot  = gsn_csm_contour_map(wks2,avg2,opts)
  cplotb = gsn_csm_contour(wks2,avg_seaice2,res_ice)
  overlay(cplot,cplotb)
  dum0a = new(1,graphic)
  dum0a = gsn_add_text(wks2,cplot, "2 m mixing ratio", lon_ta, lat_ta, txres)
  dum0b = new(1,graphic)
  dum0b = gsn_add_text(wks2,cplot, "WRF50", lon_tb, lat_tb, txres)
  dum0c = new(1,graphic)
  dum0c = gsn_add_text(wks2,cplot, "g)", lon_tc, lat_tc, txres2)
  plot(0) = cplot

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 

  res_pan                            = True
  res_pan@txFontHeightF              = 0.005 ;0.015
  res_pan@gsnPaperOrientation        = "landscape"      ; landscape mode
  res_pan@gsnPanelYWhiteSpacePercent = 2                ; Add white space b/w plots.
  res_pan@gsnPanelXWhiteSpacePercent = 2                ; Add white space b/w plots.
  res_pan@gsnPanelScalePlotIndex     = 1
  res_pan@gsnMaximize                = True	       ; fill the page
  res_pan@gsnPanelLabelBar           = True
  res_pan@lbOrientation              = "Vertical"
  res_pan@lbLabelStride              = stride1
  res_pan@lbLabelFontHeightF         = 0.025
  res_pan@pmLabelBarWidthF           = 0.15
  res_pan@pmLabelBarHeightF          = 0.6
;  res_pan@lbTitleString              = avg1@units
;  res_pan@lbTitlePosition            = "Bottom"
;  res_pan@lbTitleDirection           = "Across"
;  res_pan@lbTitleJust                = "CenterLeft"
;  res_pan@lbTitleFontHeightF         = 0.005

  gsn_panel(wks2,(/plot/),(/1,1/),res_pan)               ; create final panel plot


; Finally - make plot
print("converting plot 2 to png")
convert_cmd = "convert -density 300 "+fout2+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout2+".png"
system(convert_cmd)


print("Plot 3 - winter difference")
fout3   = "figure_5c2"

  wks3 = gsn_open_wks("ps" ,fout3)
  additional_colors = (/"gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks3,colormap2,additional_colors)
  plot3 = new(2, graphic)

;;;;;;;;;;;;;
; Make plot 3  - wrf50-era difference
;;;;;;;;;;;;;
  cplot  = gsn_csm_contour_map(wks3,diff_a,optsd)
  cplotb = gsn_csm_contour(wks3,prob_plot_a,res_95)
  overlay(cplot,cplotb)
  dum3 = new(1,graphic)
  dum3 = gsn_add_text(wks3,cplot, "2 m mixing ratio", lon_ta, lat_ta, txres)
  dum3b = new(1,graphic)
  dum3b = gsn_add_text(wks3,cplot, "WRF50 - ERA-I", lon_tb, lat_tb, txres)
  dum3c = new(1,graphic)
  dum3c = gsn_add_text(wks3,cplot, "h)", lon_tc, lat_tc, txres2)
  plot3(0) = cplot

;;;;;;;;;;;;;
; Make plot 4  - wrf10-era difference
;;;;;;;;;;;;;
  cplot  = gsn_csm_contour_map(wks3,diff_b,optsd)
  cplotb = gsn_csm_contour(wks3,prob_plot_b,res_95)
  overlay(cplot,cplotb)
  dum4 = new(1,graphic)
  dum4 = gsn_add_text(wks3,cplot, "2 m mixing ratio", lon_ta, lat_ta, txres)
  dum4b = new(1,graphic)
  dum4b = gsn_add_text(wks3,cplot, "WRF10 - WRF50", lon_tb, lat_tb, txres)
  dum4c = new(1,graphic)
  dum4c = gsn_add_text(wks3,cplot, "i)", lon_tc, lat_tc, txres2)
  plot3(1) = cplot

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
delete(res_pan)

  res_pan                            = True
  res_pan@txFontHeightF              = 0.005 ;0.015
  res_pan@gsnPaperOrientation        = "landscape"      ; landscape mode
  res_pan@gsnPanelYWhiteSpacePercent = 2                ; Add white space b/w plots.
  res_pan@gsnPanelXWhiteSpacePercent = 2                ; Add white space b/w plots.
  res_pan@gsnPanelScalePlotIndex     = 1
  res_pan@gsnMaximize                = True	       ; fill the page
  res_pan@gsnPanelLabelBar           = True
  res_pan@lbOrientation              = "Vertical"
  res_pan@lbLabelStride              = stride2
  res_pan@lbLabelFontHeightF         = 0.02
  res_pan@pmLabelBarWidthF           = 0.1
  res_pan@pmLabelBarHeightF          = 0.3
;  res_pan@lbTitleString              = avg1@units
;  res_pan@lbTitlePosition            = "Bottom"
;  res_pan@lbTitleDirection           = "Across"
;  res_pan@lbTitleJust                = "CenterLeft"
;  res_pan@lbTitleFontHeightF         = 0.005

  gsn_panel(wks3,(/plot3/),(/1,2/),res_pan)               ; create final panel plot


; Finally - make plot
print("converting plot 3 to png")
convert_cmd = "convert -density 300 "+fout3+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout3+".png"
system(convert_cmd)


print("Completed all plots for "+varcode)
print("Good job!")
;;;;;;;;;;;;;;;;;;;;;; END script
end
