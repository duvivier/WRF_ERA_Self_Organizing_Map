;***************************************
; PROGRAM DESCRIPTION: This script plots single panel plots of 
;                      diagnostic variables
; INPUT DATA: WRF output or RACM-WRF output post processed with wrfout-to-cf.ncl
;             and then made into yearly seasonal mean files
; OUTPUT DATA: One Panel plot of specified variable
; Note: This can be looped with 01_wrfsinglepanel_akd_seasonal.csh 
;       to evaluate at multiple hours or variables
; CREATOR: Matt Higgins
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
  varcode = "U10_speed"
  datatitle1  = "era_i_200511_200703_6h"
  datatitle1b = "era_i_200511_200703_6h"
; ******************************************************

; BEGIN SCRIPT
print("Creating node average plot for: "+varcode)
dir1 = "/data3/duvivier/SOM/training/averages/all/"

; set outdir and fout names
outdir = "./"
fout   = varcode+"_era_i_interpolation"

; get tag to let us know if it needs interpolation
title1_ch  = stringtocharacter(datatitle1)
title1_sub = title1_ch(0:4)
tag1 = chartostring(title1_sub)
title1b_ch  = stringtocharacter(datatitle1b)
title1b_sub = title1b_ch(0:4)
tag1b = chartostring(title1b_sub)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Set preferences for vartypes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; add each variable set in the c-shell 'varcode' and assign it a title and other necessary information
; Which variables need to be loaded?
if (varcode.eq."SLP_diff") then
  vartitle1 = "Average Sea Level Pressure"
  invar1 = "slp"
  vartype = "2d"
  cmaptype = "pressure"
  zoom = True
end if
if (varcode.eq."U10_speed") then
  vartitle1 = "Average Wind Speed at 10m"
  invar1 = "ws_10m_avg"
  vartype = "2d"
  cmaptype = "wind"
  zoom2 = True
end if

; Set the contour interval for each input variable   
; set contour limits manually:
  if (cmaptype.eq."pressure") then
    cmin1               = 980.
    cmax1               = 1020.
    clev1               = 2.
    cmin2               = -5.
    cmax2               = 5.
    clev2               = 1.
    stride1             = 4                 ; label stride
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
  if (cmaptype.eq."wind") then
    cmin1               = 0.
    cmax1               = 15.
    clev1               = 1.
    cmin2               = -3.
    cmax2               = 3.
    clev2               = 0.5
    stride1             = 2                 ; label stride
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
; Data Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;
; load in node averages
;;;;;;;;;;
; Load in lat/lon to get information for WRF10 domain
  fname1 = "net_avg_wrf10_200511_200703_6h"
  f1 = addfile(dir1 + fname1 + ".nc","r")
  lat2d_1 = f1->lat
  lon2d_1 = f1->lon
  z_sfc_1 = f1->Z_sfc
;  obs_1 = f1->number_dates

  dims = dimsizes(lat2d_1)     ; get lat/lon dimensions
  n_sn_1 = dims(0)              ; get south/north points
  n_we_1 = dims(1)              ; get west/east points
  n_tot_1 = n_sn_1*n_we_1              ; get total number of points in high res domain
  delete(dims)

; Load in lat/lon to get information for WRF10 domain
  fname1b = "net_avg_"+datatitle1b
  f1b = addfile(dir1 + fname1b + ".nc","r")
  lat2d_1b = f1b->lat
  lon2d_1b = f1b->lon
  z_sfc_1b = f1b->Z_sfc
;  obs_1b = f1b->number_dates

  dims = dimsizes(lat2d_1b)     ; get lat/lon dimensions
  n_sn_1b = dims(0)              ; get south/north points
  n_we_1b = dims(1)              ; get west/east points
  n_tot_1b = n_sn_1b*n_we_1b              ; get total number of points in high res domain
  delete(dims)

  ; get weights and indicies for regridding (WRF50 and era weightings are identical)
  weightin = addfile("/data3/duvivier/SOM/DATA/weightings_WRF50_to_WRF10.nc","r")
  interp_ind = weightin->interp_ind
  interp_wgt = weightin->interp_wgt

  var1 = new((/n_sn_1b,n_we_1b/),"float")
  var1b = new((/n_sn_1b,n_we_1b/),"float")
  fill = var1@_FillValue

;;;;;;;;;;
; Load in actual data for analysis
;;;;;;;;;;
  var1(:,:) = f1b->$invar1$(south_north|:,west_east|:)
  var1b(:,:) = f1b->$invar1$(south_north|:,west_east|:)

  ; delete vars to use in next loop
  delete(fname1)
  delete(f1)
  delete(fname1b)
  delete(f1b)

print("Loaded variables from both files")
;;;;;;;;;;
; Interpolate to WRF10 size (if needed)
;;;;;;;;;;
;if (tag1 .eq. "wrf10" .and. tag1b .ne. "wrf10")then
  print("Interpolating between resolutions")
  ; Make arrays we'll need in interpolation
  var1b_new = new((/n_sn_1,n_we_1/),"float") 
  var1b_tmp_1d  = new((/n_tot_1/),"float")
  var1b_1d = ndtooned(var1b(:,:))
  do i = 0, n_tot_1 - 1
    indices_all = interp_ind(i,:)
    n_indices = num(.not.ismissing(indices_all))
    if (n_indices .ne. 0.0) then
      indices = indices_all(0:n_indices-1)
      weight_all = interp_wgt(i,:)
      weight = weight_all(0:n_indices-1)
      var1b_tmp_1d(i) = sum(var1b_1d(indices)*weight/sum(weight))
      delete(indices)
      delete(weight)
    end if
  end do
  ; redimensionalize
  var1b_new(:,:) = onedtond(var1b_tmp_1d,(/n_sn_1,n_we_1/))

  delete(var1b)
  var1b = var1b_new
  delete(var1b_new)
 ; copy_VarMeta(var1, var1b)
 ; copy_VarCoords(var1,var1b)
  var1b@_FillValue = fill
;end if

; assign lat/lon info
var1@lat2d = lat2d_1b
var1@lon2d = lon2d_1b
var1b@lat2d = lat2d_1
var1b@lon2d = lon2d_1

; mask terrain - focus on ocean
var1(:,:) = where(z_sfc_1b .lt. 10., var1(:,:), var1@_FillValue)

f_mask = addfile("/data3/duvivier/SOM/analysis/flux_compare/node_avgs/fluxes-sst/net_avg_wrf10_200511_200703_6h-fluxes-sst.nc","r")
mask_50km = f_mask->mask_50km_terrain
var1b(:,:) = where(mask_50km .eq. 1, var1b(:,:), var1b@_FillValue)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; create plots!
print("Processing average graphs for "+varcode)

  wks = gsn_open_wks("ps" ,fout)
  additional_colors = (/"gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks,colormap,additional_colors)
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
  res@gsnSpreadColorStart        = spreadstart1      ; start at color specified for each variable above
  res@gsnSpreadColorEnd          = spreadend1        ; end at color specified above
  res@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  res@cnMinLevelValF             = cmin1             ; set min contour level specified above
  res@cnMaxLevelValF             = cmax1             ; set max contour level specified above
  res@cnLevelSpacingF            = clev1             ; set contour spacing specified above
  res@cnLinesOn                  = plotlines         ; contour lines specified above
  res@cnLineLabelsOn             = plotlines         ; line labels on specified above
  res@cnMissingValFillColor      = "gray85"          ; missing value color
  res@cnMissingValFillPattern    = 0                 ; fill in
  res@cnMissingValPerimOn        = True
  res@cnMissingValPerimColor     = "black"

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

;  res_ice@cnLevelSelectionMode       = "ExplicitLevels"
;  res_ice@cnLevels                   = (/0., 0.15/)
;  res_ice@cnFillOn                   = True
;  res_ice@cnMonoFillPattern          = False
;  res_ice@cnFillPatterns             = (/6, -1/) 
;  res_ice@lbLabelBarOn               = False

  res_ice@cnFillOn                   = False             ; turn on filled contours
  res_ice@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  res_ice@cnMinLevelValF             = 0.                ; set min contour level specified above
  res_ice@cnMaxLevelValF             = 0.15              ; set max contour level specified above
  res_ice@cnLevelSpacingF            = 0.15              ; set contour spacing specified above
  res_ice@cnLinesOn                  = True              ; contour lines specified above
  res_ice@cnLineLabelsOn             = True             ; line labels on specified above
  res_ice@cnLineColor                = "gray85"
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
  opts@tiMainFontHeightF          = 0.013
  opts@lbLabelStride              = stride1
  opts@pmLabelBarOrthogonalPosF   = -0.01             ; move label bar closer
  opts@pmLabelBarHeightF          = 0.075             ; set height of labelbar

  opts@tiMainString               = "ERA-I: native"            ; title string specified from cshell
  cplot0  = gsn_csm_contour_map(wks,var1,opts)
  plot(0) = cplot0

  opts@tiMainString               = "ERA-I: interpolated"            ; title string specified from cshell
  cplot1  = gsn_csm_contour_map(wks,var1b,opts)
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

;  opts@tiMainString               = title_diff        ; set title for difference plot
;  cplot3  = gsn_csm_contour_map(wks,diff,opts)
;  plot(2) = cplot3


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
  gsn_panel(wks,(/plot/),(/1,2/),pnlres)               ; create final panel plot

 print("converting to png")
; convert to png 
  convert_cmd = "convert -density 300 "+fout+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout+".png"

  system(convert_cmd)
;;;;;;;;;;;;;;;;;;;;;; END script
end
