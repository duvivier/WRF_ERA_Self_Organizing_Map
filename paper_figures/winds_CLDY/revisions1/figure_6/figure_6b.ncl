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
  datatitle1  = "wrf50_199701_200712_6h"
  datatitle1b = "era_i_199701_200712_6h"
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
dir1 = "/vardar/data3/duvivier/SOM/analysis/flux_compare/group_avgs/"

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
    plotlines           = False              ; lines for reg plot
    difflines           = False              ; lines for diff plot
    cntype              = "AreaFill"
    spreadstart1        = 2                 ; start at color
    spreadend1          = 18                ; end at color
    spreadstart2        = 20                ; start at color
    spreadend2          = 115               ; end at color
    colormap            = "SOM_wind_table_mod"
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
  weightin = addfile("/vardar/data3/duvivier/SOM/DATA/weightings_WRF50_to_WRF10.nc","r")
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; set outdir and fout names
outdir = "./"
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
res@mpCenterLonF                = -35. ;-30.             ; set the center lat/lon
res@mpCenterLatF                = 63.               
res@mpGridAndLimbOn             = False            ; Turn on lat/lon grid
;res@mpGridLineDashPattern       = 2                ; Change dash pattern
res@mpFillOn                    = True             ; Enables map fill
res@mpGeophysicalLineColor      = "black"          ; Color of continents
res@mpGeophysicalLineThicknessF = 1.5              ; Make continents thinner
 
res@mpLimitMode                 = "LatLon"	     ; how to zoom in on map
res@mpMinLatF                   = 56.              ; set the minimum latitude 
res@mpMaxLatF                   = 70.              ; set the maximum latitude 
res@mpMinLonF                   = -54.0            ; set the minimum longitude 
res@mpMaxLonF                   = -20.0            ; set the maximum longitude 

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
res@lbLabelBarOn               = False
res@cnInfoLabelOn              = False
;res@pmLabelBarOrthogonalPosF   = -0.01             ; move label bar closer
;res@pmLabelBarHeightF          = 0.075             ; set height of labelbar

opts                            = res               ; reset options
opts@gsnSpreadColorStart        = spreadstart1      ; start at color specified for each variable above
opts@gsnSpreadColorEnd          = spreadend1        ; end at color specified above
opts@cnMinLevelValF             = cmin1             ; set min contour level specified above
opts@cnMaxLevelValF             = cmax1             ; set max contour level specified above
opts@cnLevelSpacingF            = clev1             ; set contour spacing specified above
;opts@lbLabelStride              = stride1

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

; label lat/lon
lat_t = 69.0
lon_t = -40.5
txres                             = True
txres@txFontHeightF               = 0.06
txres@txFontThicknessF            = 2.0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 5 - Winter mean wind speed
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  print("Plot 5a - winter mean wind speed")
;  fout1   = "winds_figure_5a"
;
;  wks = gsn_open_wks("ps" ,fout1)
;  additional_colors = (/"gray85", "forestgreen", "yellow"/)
;  gsn_merge_colormaps(wks,colormap,additional_colors)
;  plot = new(8, graphic)
;
;; Variable 1
;  ; group 1 
;  cplot  = gsn_csm_contour_map(wks,var1b(0,:,:),opts)
;;  cplot2 = gsn_csm_contour(wks,seaice_1b(0,:,:),res_ice)
;;  overlay(cplot,cplot2)
;  dum0 = new(1,graphic)
;  dum0 = gsn_add_text(wks,cplot, "NE", lon_t, lat_t, txres)
;  plot(0) = cplot
;  ; group 2 
;  cplot  = gsn_csm_contour_map(wks,var1b(1,:,:),opts)
;;  cplot2 = gsn_csm_contour(wks,seaice_1b(1,:,:),res_ice)
;;  overlay(cplot,cplot2)
;  dum1 = new(1,graphic)
;  dum1 = gsn_add_text(wks,cplot, "NE-DS", lon_t, lat_t, txres)
;  plot(1) = cplot
;  ; group 3 
;  cplot  = gsn_csm_contour_map(wks,var1b(2,:,:),opts)
;;  cplot2 = gsn_csm_contour(wks,seaice_1b(2,:,:),res_ice)
;;  overlay(cplot,cplot2)
;  dum2 = new(1,graphic)
;  dum2 = gsn_add_text(wks,cplot, "WTJ-BF", lon_t, lat_t, txres)
;  plot(2) = cplot
;  ; group 4 
;  cplot  = gsn_csm_contour_map(wks,var1b(3,:,:),opts)
;;  cplot2 = gsn_csm_contour(wks,seaice_1b(3,:,:),res_ice)
;;  overlay(cplot,cplot2)
;  dum3 = new(1,graphic)
;  dum3 = gsn_add_text(wks,cplot, "SWTJ-BF", lon_t, lat_t, txres)
;  plot(3) = cplot
;  ; group 5 
;  cplot  = gsn_csm_contour_map(wks,var1b(4,:,:),opts)
;;  cplot2 = gsn_csm_contour(wks,seaice_1b(4,:,:),res_ice)
;;  overlay(cplot,cplot2)
;  dum4 = new(1,graphic)
;  dum4 = gsn_add_text(wks,cplot, "SETJ", lon_t, lat_t, txres)
;  plot(4) = cplot
;  ; group 6 
;  cplot  = gsn_csm_contour_map(wks,var1b(5,:,:),opts)
;;  cplot2 = gsn_csm_contour(wks,seaice_1b(5,:,:),res_ice)
;;  overlay(cplot,cplot2)
;  dum5 = new(1,graphic)
;  dum5 = gsn_add_text(wks,cplot, "ETJ", lon_t, lat_t, txres)
;  plot(5) = cplot
;  ; group 7 
;  cplot  = gsn_csm_contour_map(wks,var1b(6,:,:),opts)
;;  cplot2 = gsn_csm_contour(wks,seaice_1b(6,:,:),res_ice)
;;  overlay(cplot,cplot2)
;  dum6 = new(1,graphic)
;  dum6 = gsn_add_text(wks,cplot, "S", lon_t, lat_t, txres)
;  plot(6) = cplot
;  ; group 8 
;  cplot  = gsn_csm_contour_map(wks,var1b(7,:,:),opts)
;;  cplot2 = gsn_csm_contour(wks,seaice_1b(7,:,:),res_ice)
;;  overlay(cplot,cplot2)
;  dum7 = new(1,graphic)
;  dum7 = gsn_add_text(wks,cplot, "WTJ", lon_t, lat_t, txres)
;  plot(7) = cplot
;
;;;;;;;;;;;;;;
;; Plot final - panel plot set 
;;;;;;;;;;;;;; 
;title_fin = "a. ERA-I group mean 10m wind speed"
;
;  res_pan                            = True
;  res_pan@txString                   = title_fin        ; main title
;  res_pan@txFontHeightF              = 0.015
;  res_pan@gsnPaperOrientation        = "landscape"      ; landscape mode
;  res_pan@gsnPanelYWhiteSpacePercent = 2                ; Add white space b/w plots.
;  res_pan@gsnPanelXWhiteSpacePercent = 2                ; Add white space b/w plots.
;  res_pan@gsnPanelScalePlotIndex     = 1
;  res_pan@gsnMaximize                = True	       ; fill the page
;  res_pan@gsnPanelLabelBar           = True
;  res_pan@lbOrientation              = "Vertical"
;  res_pan@lbTitleString              = "m s-1"
;  res_pan@lbTitlePosition            = "Bottom"
;  res_pan@lbTitleDirection           = "Across"
;  res_pan@lbLabelStride              = stride1
;  res_pan@lbLabelFontHeightF         = 0.01
;  res_pan@lbTitleJust                = "CenterLeft"
;  res_pan@lbTitleFontHeightF         = 0.0075
;  res_pan@pmLabelBarWidthF           = 0.065
;  res_pan@pmLabelBarHeightF          = 0.375
;
;  gsn_panel(wks,(/plot/),(/2,4/),res_pan)               ; create final panel plot
;
;
;; Finally - make plot
;print("plot complete - converting figure 5a to png")
;  delete(wks)
;  system("convert -trim -border 10 -bordercolor white -density 300 "+  \
;         "-rotate -90 "+fout1+".ps "+fout1+".png")
;  delete(title_fin)
;  delete(additional_colors)
;  delete(plot)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 5b - difference plot
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  print("Plot 6b - winter wind speed difference")
  fout2   = "winds_figure_6b"

  wks2 = gsn_open_wks("ps" ,fout2)
  additional_colors = (/"gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks2,colormap,additional_colors)
  plot = new(8, graphic)

; Variable 1
  ; group 1 
  cplot  = gsn_csm_contour_map(wks2,diff(0,:,:),optsd)
  cplot2 = gsn_csm_contour(wks2,prob(0,:,:),res_95)
  overlay(cplot,cplot2)
  dum0 = new(1,graphic)
  dum0 = gsn_add_text(wks2,cplot, "NE", lon_t, lat_t, txres)
  plot(0) = cplot
  ; group 2 
  cplot  = gsn_csm_contour_map(wks2,diff(1,:,:),optsd)
  cplot2 = gsn_csm_contour(wks2,prob(1,:,:),res_95)
  overlay(cplot,cplot2)
  dum1 = new(1,graphic)
  dum1 = gsn_add_text(wks2,cplot, "NE-DS", lon_t, lat_t, txres)
  plot(1) = cplot
  ; group 3 
  cplot  = gsn_csm_contour_map(wks2,diff(2,:,:),optsd)
  cplot2 = gsn_csm_contour(wks2,prob(2,:,:),res_95)
  overlay(cplot,cplot2)
  dum2 = new(1,graphic)
  dum2 = gsn_add_text(wks2,cplot, "WTJ-BF", lon_t, lat_t, txres)
  plot(2) = cplot
  ; group 4 
  cplot  = gsn_csm_contour_map(wks2,diff(3,:,:),optsd)
  cplot2 = gsn_csm_contour(wks2,prob(3,:,:),res_95)
  overlay(cplot,cplot2)
  dum3 = new(1,graphic)
  dum3 = gsn_add_text(wks2,cplot, "SWTJ-BF", lon_t, lat_t, txres)
  plot(3) = cplot
  ; group 5 
  cplot  = gsn_csm_contour_map(wks2,diff(4,:,:),optsd)
  cplot2 = gsn_csm_contour(wks2,prob(4,:,:),res_95)
  overlay(cplot,cplot2)
  dum4 = new(1,graphic)
  dum4 = gsn_add_text(wks2,cplot, "SETJ", lon_t, lat_t, txres)
  plot(4) = cplot
  ; group 6 
  cplot  = gsn_csm_contour_map(wks2,diff(5,:,:),optsd)
  cplot2 = gsn_csm_contour(wks2,prob(5,:,:),res_95)
  overlay(cplot,cplot2)
  dum5 = new(1,graphic)
  dum5 = gsn_add_text(wks2,cplot, "ETJ", lon_t, lat_t, txres)
  plot(5) = cplot
  ; group 7 
  cplot  = gsn_csm_contour_map(wks2,diff(6,:,:),optsd)
  cplot2 = gsn_csm_contour(wks2,prob(6,:,:),res_95)
  overlay(cplot,cplot2)
  dum6 = new(1,graphic)
  dum6 = gsn_add_text(wks2,cplot, "S", lon_t, lat_t, txres)
  plot(6) = cplot
  ; group 8 
  cplot  = gsn_csm_contour_map(wks2,diff(7,:,:),optsd)
  cplot2 = gsn_csm_contour(wks2,prob(7,:,:),res_95)
  overlay(cplot,cplot2)
  dum7 = new(1,graphic)
  dum7 = gsn_add_text(wks2,cplot, "WTJ", lon_t, lat_t, txres)
  plot(7) = cplot

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
title_fin = "b. Difference in group mean 10m wind speed (WRF50 - ERA-I)"

  res_pan                            = True
  res_pan@txString                   = title_fin        ; main title
  res_pan@txFontHeightF              = 0.015
  res_pan@gsnPaperOrientation        = "landscape"      ; landscape mode
  res_pan@gsnPanelYWhiteSpacePercent = 2                ; Add white space b/w plots.
  res_pan@gsnPanelXWhiteSpacePercent = 2                ; Add white space b/w plots.
  res_pan@gsnPanelScalePlotIndex     = 1
  res_pan@gsnMaximize                = True	       ; fill the page
  res_pan@gsnPanelLabelBar           = True
  res_pan@lbOrientation              = "Vertical"
  res_pan@lbTitleString              = "m s-1"
  res_pan@lbTitlePosition            = "Bottom"
  res_pan@lbTitleDirection           = "Across"
  res_pan@lbLabelStride              = stride2
  res_pan@lbLabelFontHeightF         = 0.01
  res_pan@lbTitleJust                = "CenterLeft"
  res_pan@lbTitleFontHeightF         = 0.0075
  res_pan@pmLabelBarWidthF           = 0.065
  res_pan@pmLabelBarHeightF          = 0.375

  gsn_panel(wks2,(/plot/),(/2,4/),res_pan)               ; create final panel plot


; Finally - make plot
print("plot complete - converting figure 5a to png")
  delete(wks2)
  system("convert -trim -border 10 -bordercolor white -density 300 "+  \
         "-rotate -90 -trim -border 10 "+fout2+".ps "+fout2+".png")
  delete(title_fin)
  delete(additional_colors)
  delete(plot)


print("Completed all plots for "+varcode)
print("Good job!")
;;;;;;;;;;;;;;;;;;;;;; END script
end
