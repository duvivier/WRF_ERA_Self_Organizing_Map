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
  varcode = "U10"
  datatitle1 = "wrf10_200511_200703_6h"
  datatitle2 = "wrf50_200511_200703_6h"
  ; set input/output directories
  dir1 = "/data3/duvivier/SOM/analysis/extremes/group_avgs/"
  outdir = "./"
; ******************************************************
print("Processing all graphs for "+varcode)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; BEGIN SCRIPT
; get tag to let us know if it needs interpolation
title1_ch  = stringtocharacter(datatitle1)
title1_sub = title1_ch(0:4)
tag1 = chartostring(title1_sub)
title2_ch  = stringtocharacter(datatitle2)
title2_sub = title2_ch(0:4)
tag2 = chartostring(title2_sub)

;;;;;;;;;;
; Set information for variable
;;;;;;;;;;
if (varcode.eq."U10")then
  vartitle1 = "Windspeed at 10m"
  invar1 = "ws_10m_pcnt"
  cmaptype = "wspd"
  units = "(m s-1)"
end if

; Set the contour interval for each input variable   
; set contour limits manually:
  if (cmaptype.eq."wspd") then
    cmin1               = 0.0
    cmax1               = 34.0
    clev1               = 2.0
    stride1             = 1.0
    cmin2               = -10.0
    cmax2               = 10.0
    clev2               = 1.0
    stride2             = 2
    plotlines           = False
    difflines           = False
    cntype              = "AreaFill"
    spreadstart1        = 2                 ; start at color
    spreadend1          = 18                ; end at color
    spreadstart2       = 20                ; start at color
    spreadend2         = 115               ; end at color
    colormap            = "SOM_wind_table_mod"
  end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Data Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; percentile names
percentiles = (/"50","75","95"/)
dim_pcnt = dimsizes(percentiles)

; total groups to load (specifically for 7x5 SOM)
dim_group = 8

;;;;;;;;;;
; Load all percentiles for each group
;;;;;;;;;;
; first get lat/lon and dimesions for each file type
f0 = addfile(dir1+"group_1_"+datatitle1+"-extremes-sst.nc","r")
lat2d_1 = f0->lat
lon2d_1 = f0->lon
z_sfc_1 = f0->Z_sfc
mask_50km = f0->mask_50km_terrain
dims1 = dimsizes(lat2d_1)
n_sn_1 = dims1(0)              ; get south/north points
n_we_1 = dims1(1)              ; get west/east points
n_tot_1 = n_sn_1*n_we_1              ; get total number of points in high res domain
delete(f0)

f0 = addfile(dir1+"group_1_"+datatitle2+"-extremes-sst.nc","r")
lat2d_2 = f0->lat
lon2d_2 = f0->lon
z_sfc_2 = f0->Z_sfc
dims2 = dimsizes(lat2d_2)
delete(f0)

; preallocate arrays for the data
var1 = new((/dim_pcnt,dim_group,dims1(0),dims1(1)/),"float")
var2 = new((/dim_pcnt,dim_group,dims2(0),dims2(1)/),"float")

; loop through each group and each percentile to load data
do g = 0,dim_group -1
  g1 = g+1
  fname1 = "group_"+g1+"_"+datatitle1+"-extremes-sst"
  fname2 = "group_"+g1+"_"+datatitle2+"-extremes-sst"
  f1 = addfile(dir1+fname1+".nc","r")
  f2 = addfile(dir1+fname2+".nc","r")
  ; load data
  dum = f1->$invar1$
  var1(:,g,:,:) = dum
  delete(dum)
  dum = f2->$invar1$
  var2(:,g,:,:) = dum
  delete(g1)
  delete(dum)
end do
print("Loaded "+ varcode+" percentiles from all files")

;;;;;;;;;;
; Interpolate to WRF10 size
;;;;;;;;;;
print("Interpolating between resolutions")
; get weights and indicies for regridding (WRF50 and era weightings are identical)
weightin = addfile("/data3/duvivier/SOM/DATA/weightings_WRF50_to_WRF10.nc","r")
interp_ind = weightin->interp_ind
interp_wgt = weightin->interp_wgt

; Make arrays we'll need in interpolation
var2_new = new((/dimsizes(var1)/),"float")
var2_tmp_1d  = new((/n_tot_1/),"float")

; loop through groups and percentiles
g = 0
p = 0
do g = 0, dim_group -1
  g1 = g+1
  print("Group "+g1+" interpolation")
  do p = 0, dim_pcnt -1
    var2_1d = ndtooned(var2(p,g,:,:))
    do i = 0, n_tot_1 - 1
      indices_all = interp_ind(i,:)
      n_indices = num(.not.ismissing(indices_all))
      if (n_indices .ne. 0.0) then
        indices = indices_all(0:n_indices-1)
        weight_all = interp_wgt(i,:)
        weight = weight_all(0:n_indices-1)
        var2_tmp_1d(i) = sum(var2_1d(indices)*weight/sum(weight))
        delete(indices)
        delete(weight)
      end if
    end do
    ; redimensionalize
    var2_new(p,g,:,:) = onedtond(var2_tmp_1d,(/n_sn_1,n_we_1/))
    print("Finished percentile: "+percentiles(p))
  end do
end do
delete(var2)
var2 = var2_new
delete(var2_new)
copy_VarMeta(var1, var2)

; mask terrain and lat/lons - focus on S. Greenland region ocean
p = 0
g = 0
do p = 0, dim_pcnt-1
  do g = 0, dim_group-1
    var1(p,g,:,:) = where(mask_50km.eq.1. .and. lat2d_1.gt.55. .and. lat2d_1.lt.71. .and. lon2d_1.lt.-19. .and. lon2d_1.gt.-55., var1(p,g,:,:), var1@_FillValue)
    var2(p,g,:,:) = where(mask_50km.eq.1. .and. lat2d_1.gt.55. .and. lat2d_1.lt.71. .and. lon2d_1.lt.-19. .and. lon2d_1.gt.-55., var2(p,g,:,:), var2@_FillValue)
  end do
end do

;;;;;;;;;;
;  Calculate differences
;;;;;;;;;;
  diff = var1-var2

;;;;;;;;;;
;  Assign lat/lon data
;;;;;;;;;;
  var1@lat2d = lat2d_1
  var1@lon2d = lon2d_1
  var2@lat2d = lat2d_1
  var2@lon2d = lon2d_1
  diff@lat2d = lat2d_1
  diff@lon2d = lon2d_1

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
; Plot 9 - Winter 95th percentile wind speed
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  print("Plot 9a - winter 95th percentile wind speed")
  fout1   = "winds_figure_9a"

  wks = gsn_open_wks("ps" ,fout1)
  additional_colors = (/"gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks,colormap,additional_colors)
  plot = new(8, graphic)

; Variable 1
  ; group 1 
  cplot  = gsn_csm_contour_map(wks,var1(2,0,:,:),opts)
  dum0 = new(1,graphic)
  dum0 = gsn_add_text(wks,cplot, "Group 1", lon_t, lat_t, txres)
  plot(0) = cplot
  ; group 2 
  cplot  = gsn_csm_contour_map(wks,var1(2,1,:,:),opts)
  dum1 = new(1,graphic)
  dum1 = gsn_add_text(wks,cplot, "Group 2", lon_t, lat_t, txres)
  plot(1) = cplot
  ; group 3 
  cplot  = gsn_csm_contour_map(wks,var1(2,2,:,:),opts)
  dum2 = new(1,graphic)
  dum2 = gsn_add_text(wks,cplot, "Group 3", lon_t, lat_t, txres)
  plot(2) = cplot
  ; group 4 
  cplot  = gsn_csm_contour_map(wks,var1(2,3,:,:),opts)
  dum3 = new(1,graphic)
  dum3 = gsn_add_text(wks,cplot, "Group 4", lon_t, lat_t, txres)
  plot(3) = cplot
  ; group 5 
  cplot  = gsn_csm_contour_map(wks,var1(2,4,:,:),opts)
  dum4 = new(1,graphic)
  dum4 = gsn_add_text(wks,cplot, "Group 5", lon_t, lat_t, txres)
  plot(4) = cplot
  ; group 6 
  cplot  = gsn_csm_contour_map(wks,var1(2,5,:,:),opts)
  dum5 = new(1,graphic)
  dum5 = gsn_add_text(wks,cplot, "Group 6", lon_t, lat_t, txres)
  plot(5) = cplot
  ; group 7 
  cplot  = gsn_csm_contour_map(wks,var1(2,6,:,:),opts)
  dum6 = new(1,graphic)
  dum6 = gsn_add_text(wks,cplot, "Group 7", lon_t, lat_t, txres)
  plot(6) = cplot
  ; group 8 
  cplot  = gsn_csm_contour_map(wks,var1(2,7,:,:),opts)
  dum7 = new(1,graphic)
  dum7 = gsn_add_text(wks,cplot, "Group 8", lon_t, lat_t, txres)
  plot(7) = cplot

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
title_fin = "a. WRF10 group 95th percentile 10m wind speed"

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
  res_pan@lbLabelStride              = stride1
  res_pan@lbLabelFontHeightF         = 0.01
  res_pan@lbTitleJust                = "CenterLeft"
  res_pan@lbTitleFontHeightF         = 0.0075
  res_pan@pmLabelBarWidthF           = 0.065
  res_pan@pmLabelBarHeightF          = 0.375

  gsn_panel(wks,(/plot/),(/2,4/),res_pan)               ; create final panel plot


; Finally - make plot
  print("converting plot 9a to png")
  convert_cmd = "convert -density 300 "+fout1+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout1+".png"
  system(convert_cmd)
  delete(title_fin)
  delete(additional_colors)
  delete(plot)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 9b - difference plot
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  print("Plot 9 - winter 95th percentile wind speed difference")
  fout2   = "winds_figure_9b"

  wks2 = gsn_open_wks("ps" ,fout2)
  additional_colors = (/"gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks2,colormap,additional_colors)
  plot = new(8, graphic)

; Variable 1
  ; group 1 
  cplot  = gsn_csm_contour_map(wks2,diff(2,0,:,:),optsd)
  dum0 = new(1,graphic)
  dum0 = gsn_add_text(wks2,cplot, "Group 1", lon_t, lat_t, txres)
  plot(0) = cplot
  ; group 2 
  cplot  = gsn_csm_contour_map(wks2,diff(2,1,:,:),optsd)
  dum1 = new(1,graphic)
  dum1 = gsn_add_text(wks2,cplot, "Group 2", lon_t, lat_t, txres)
  plot(1) = cplot
  ; group 3 
  cplot  = gsn_csm_contour_map(wks2,diff(2,2,:,:),optsd)
  dum2 = new(1,graphic)
  dum2 = gsn_add_text(wks2,cplot, "Group 3", lon_t, lat_t, txres)
  plot(2) = cplot
  ; group 4 
  cplot  = gsn_csm_contour_map(wks2,diff(2,3,:,:),optsd)
  dum3 = new(1,graphic)
  dum3 = gsn_add_text(wks2,cplot, "Group 4", lon_t, lat_t, txres)
  plot(3) = cplot
  ; group 5 
  cplot  = gsn_csm_contour_map(wks2,diff(2,4,:,:),optsd)
  dum4 = new(1,graphic)
  dum4 = gsn_add_text(wks2,cplot, "Group 5", lon_t, lat_t, txres)
  plot(4) = cplot
  ; group 6 
  cplot  = gsn_csm_contour_map(wks2,diff(2,5,:,:),optsd)
  dum5 = new(1,graphic)
  dum5 = gsn_add_text(wks2,cplot, "Group 6", lon_t, lat_t, txres)
  plot(5) = cplot
  ; group 7 
  cplot  = gsn_csm_contour_map(wks2,diff(2,6,:,:),optsd)
  dum6 = new(1,graphic)
  dum6 = gsn_add_text(wks2,cplot, "Group 7", lon_t, lat_t, txres)
  plot(6) = cplot
  ; group 8 
  cplot  = gsn_csm_contour_map(wks2,diff(2,7,:,:),optsd)
  dum7 = new(1,graphic)
  dum7 = gsn_add_text(wks2,cplot, "Group 8", lon_t, lat_t, txres)
  plot(7) = cplot

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
title_fin = "b. Difference in 95th percentile 10m wind speed (WRF10 - WRF50)"

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
  print("converting plot 9b to png")
  convert_cmd = "convert -density 300 "+fout2+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout2+".png"
  system(convert_cmd)
  delete(title_fin)
  delete(additional_colors)
  delete(plot)


print("Completed all plots for "+varcode)
print("Good job!")
;;;;;;;;;;;;;;;;;;;;;; END script
end


