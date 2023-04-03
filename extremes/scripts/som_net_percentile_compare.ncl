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
  varcode = "SH"
  datatitle1 = "wrf50_200511_200703_6h"
  datatitle2 = "era_i_200511_200703_6h"
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
if (varcode.eq."LH") then
  vartitle1 = "COARE Latent Heat Flux at surface"
  invar1 = "LHFlx_pcnt"
  cmaptype = "lhflux"
  units = "(W m-2)"
end if
if (varcode.eq."SH") then
  vartitle1 = "COARE Sensible Heat Flux at surface"
  invar1 = "SHFlx_pcnt"
  cmaptype = "shflux"
  units = "(W m-2)"
end if
if (varcode.eq."U10")then
  vartitle1 = "Windspeed at 10m"
  invar1 = "ws_10m_pcnt"
  cmaptype = "wspd"
  units = "(m s-1)"
end if

; Set the contour interval for each input variable   
; set contour limits manually:
  if (cmaptype.eq."lhflux")then
    cmin1               = 20.0
    cmax1               = 200.0
    clev1               = 10.0
    stride1             = 2
    cmin2               = 25.0
    cmax2               = 275.0
    clev2               = 10.0
    stride2             = 2
    cmin3               = 100.0
    cmax3               = 400.0
    clev3               = 10.0
    stride3             = 4
    cmin_d              = -170.0
    cmax_d              = 170.0
    clev_d              = 10.0
    stride_d            = 2
    spreadstart1        = 2                 ; start at color
    spreadend1          = 35                ; end at color
    spreadstart_d       = 37                ; start at color
    spreadend_d         = 132               ; end at color
    colormap            = "SOM_wind_table"
  end if
  if (cmaptype.eq."shflux")then
    cmin1               = 20.0
    cmax1               = 400.0
    clev1               = 20.0
    stride1             = 2
    cmin2               = 25.0
    cmax2               = 600.0
    clev2               = 25.0
    stride2             = 2
    cmin3               = 100.0
    cmax3               = 1000.0
    clev3               = 30.0
    stride3             = 4
    cmin_d              = -170.0
    cmax_d              = 170.0
    clev_d              = 10.0
    stride_d            = 2
    spreadstart1        = 2                 ; start at color
    spreadend1          = 35                ; end at color
    spreadstart_d       = 37                ; start at color
    spreadend_d         = 132               ; end at color
    colormap            = "SOM_wind_table"
  end if
  if (cmaptype.eq."wspd") then
    cmin1               = 5.0  ;0.0
    cmax1               = 30.0 ;14.0
    clev1               = 1.0
    stride1             = 2
    cmin2               = 5.0  ;0.0
    cmax2               = 30.0 ;20.0
    clev2               = 1.0
    stride2             = 2
    cmin3               = 5.0
    cmax3               = 30.0
    clev3               = 1.0
    stride3             = 2
    cmin_d              = -7.0
    cmax_d              = 7.0
    clev_d              = 0.5
    stride_d            = 2
    spreadstart1        = 2                 ; start at color
    spreadend1          = 35                ; end at color
    spreadstart_d       = 37                ; start at color
    spreadend_d         = 132               ; end at color
    colormap            = "SOM_wind_table"
  end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Data Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; percentile names
percentiles = (/"50","75","95"/)
dim_pcnt = dimsizes(percentiles)

;;;;;;;;;;
; Load all percentiles for each group
;;;;;;;;;;
; first get lat/lon and dimesions for each file type
f0 = addfile(dir1+"net_"+datatitle1+"-extremes-sst.nc","r")
lat2d_1 = f0->lat
lon2d_1 = f0->lon
z_sfc_1 = f0->Z_sfc
mask_50km = f0->mask_50km_terrain
dims1 = dimsizes(lat2d_1)
n_sn_1 = dims1(0)              ; get south/north points
n_we_1 = dims1(1)              ; get west/east points
n_tot_1 = n_sn_1*n_we_1              ; get total number of points in high res domain
var1 = f0->$invar1$
delete(f0)

f0 = addfile(dir1+"net_"+datatitle2+"-extremes-sst.nc","r")
lat2d_2 = f0->lat
lon2d_2 = f0->lon
z_sfc_2 = f0->Z_sfc
dims2 = dimsizes(lat2d_2)
var2 = f0->$invar1$
delete(f0)
print("Loaded "+ varcode+" percentiles from all files")

; subset to just get values of interest
var1_sub = new((/dim_pcnt,dims1(0),dims1(1)/),"float")
var2_sub = new((/dim_pcnt,dims2(0),dims2(1)/),"float")

var1_sub(0,:,:) = var1(4,:,:)  ;50th
var1_sub(1,:,:) = var1(7,:,:)  ;75th
var1_sub(2,:,:) = var1(12,:,:) ;95th
var2_sub(0,:,:) = var2(4,:,:)  ;50th
var2_sub(1,:,:) = var2(7,:,:)  ;75th
var2_sub(2,:,:) = var2(12,:,:) ;95th

delete(var1)
var1 = var1_sub
delete(var1_sub)
delete(var2)
var2 = var2_sub
delete(var2_sub)

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
p = 0
do p = 0, dim_pcnt -1
  var2_1d = ndtooned(var2(p,:,:))
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
  var2_new(p,:,:) = onedtond(var2_tmp_1d,(/n_sn_1,n_we_1/))
  print("Finished percentile: "+percentiles(p))
end do
delete(var2)
var2 = var2_new
delete(var2_new)
copy_VarMeta(var1, var2)

; mask terrain and lat/lons - focus on S. Greenland region ocean
p = 0
do p = 0, dim_pcnt-1
  var1(p,:,:) = where(mask_50km.eq.1. .and. lat2d_1.gt.55. .and. lat2d_1.lt.71. .and. lon2d_1.lt.-19. .and. lon2d_1.gt.-55., var1(p,:,:), var1@_FillValue)
  var2(p,:,:) = where(mask_50km.eq.1. .and. lat2d_1.gt.55. .and. lat2d_1.lt.71. .and. lon2d_1.lt.-19. .and. lon2d_1.gt.-55., var2(p,:,:), var2@_FillValue)
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
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Processing all graphs for "+varcode)
; create plots!
; plot 1 - 9 panel of net percentiles and differences
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; set outdir and fout names
outdir = "./"

print("Processing all graphs for "+varcode)
  ; Set resources for all plots
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
  res@mpLimitMode                 = "LatLon"	     ; how to zoom in on map
  res@mpMinLatF                   = 56.              ; set the minimum latitude 
  res@mpMaxLatF                   = 70.              ; set the maximum latitude 
  res@mpMinLonF                   = -54.0            ; set the minimum longitude 
  res@mpMaxLonF                   = -20.0            ; set the maximum longitude 

  res@cnFillMode                 = "AreaFill"
  res@cnFillOn                   = True              ; turn on filled contours
  res@gsnSpreadColors            = True              ; use full colormap
  res@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  res@cnLinesOn                  = False             ; contour lines specified above
  res@cnLineLabelsOn             = False             ; line labels on specified above
  res@cnMissingValFillColor      = "gray85"          ; missing value color
  res@cnMissingValFillPattern    = 0                 ; fill in
  res@cnMissingValPerimOn        = False
  res@cnMissingValPerimColor     = "black"
  res@tiMainFontHeightF          = 0.013
  res@lbLabelBarOn               = True 
  res@pmLabelBarOrthogonalPosF   = -0.01             ; move label bar closer
  res@pmLabelBarHeightF          = 0.075             ; set height of labelbar


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 1 - all percentiles plot
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Plot 1 - Net percentiles")
fout1   = varcode+"_net_percentile-"+datatitle1+"_"+datatitle2

  wks1 = gsn_open_wks("ps" ,fout1)
  additional_colors = (/"black","gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks1,colormap,additional_colors)
  plot = new(9, graphic)

  opts1 = res
  opts1@gsnSpreadColorStart        = spreadstart1      ; start at color specified for each variable above
  opts1@gsnSpreadColorEnd          = spreadend1        ; end at color specified above
  opts1@cnMinLevelValF             = cmin1             ; set min contour level specified above
  opts1@cnMaxLevelValF             = cmax1             ; set max contour level specified above
  opts1@cnLevelSpacingF            = clev1             ; set contour spacing specified above
  opts1@lbLabelStride              = stride1

  opts2 = res
  opts2@gsnSpreadColorStart        = spreadstart1      ; start at color specified for each variable above
  opts2@gsnSpreadColorEnd          = spreadend1        ; end at color specified above
  opts2@cnMinLevelValF             = cmin2             ; set min contour level specified above
  opts2@cnMaxLevelValF             = cmax2             ; set max contour level specified above
  opts2@cnLevelSpacingF            = clev2             ; set contour spacing specified above
  opts2@lbLabelStride              = stride2

  opts3 = res
  opts3@gsnSpreadColorStart        = spreadstart1      ; start at color specified for each variable above
  opts3@gsnSpreadColorEnd          = spreadend1        ; end at color specified above
  opts3@cnMinLevelValF             = cmin3             ; set min contour level specified above
  opts3@cnMaxLevelValF             = cmax3             ; set max contour level specified above
  opts3@cnLevelSpacingF            = clev3             ; set contour spacing specified above
  opts3@lbLabelStride              = stride3

  optsd = res
  optsd@gsnSpreadColorStart       = spreadstart_d      ; start at color specified for each variable above
  optsd@gsnSpreadColorEnd         = spreadend_d        ; end at color specified above
  optsd@cnMinLevelValF            = cmin_d             ; set min contour level specified above
  optsd@cnMaxLevelValF            = cmax_d             ; set max contour level specified above
  optsd@cnLevelSpacingF           = clev_d             ; set contour spacing specified above
  optsd@lbLabelStride             = stride_d

;;;;;;;;;;;;;
; Make plots for tag1 all groups
;;;;;;;;;;;;;
  ; plot0
  opts1@gsnCenterString              = tag1+": 50th"
  cplot0  = gsn_csm_contour_map(wks1,var1(0,:,:),opts1)
  plot(0) = cplot0
  delete(opts1@gsnCenterString)
  ; plot1
  opts1@gsnCenterString              = tag2+": 50th"
  cplot1  = gsn_csm_contour_map(wks1,var2(0,:,:),opts1)
  plot(1) = cplot1
  delete(opts1@gsnCenterString)
  ; plot2
  optsd@gsnCenterString              = tag1+"-"+tag2+": 50th"
  cplot2  = gsn_csm_contour_map(wks1,diff(0,:,:),optsd)
  plot(2) = cplot2
  delete(optsd@gsnCenterString)
  ; plot3
  opts2@gsnCenterString              = tag1+": 75th"
  cplot3  = gsn_csm_contour_map(wks1,var1(1,:,:),opts2)
  plot(3) = cplot3
  delete(opts2@gsnCenterString)
  ; plot4
  opts2@gsnCenterString              = tag2+": 75th"
  cplot4  = gsn_csm_contour_map(wks1,var2(1,:,:),opts2)
  plot(4) = cplot4
  delete(opts2@gsnCenterString)
  ; plot5
  optsd@gsnCenterString              = tag1+"-"+tag2+": 75th"
  cplot5  = gsn_csm_contour_map(wks1,diff(1,:,:),optsd)
  plot(5) = cplot5
  delete(optsd@gsnCenterString)
  ; plot6
  opts3@gsnCenterString              = tag1+": 95th"
  cplot6  = gsn_csm_contour_map(wks1,var1(2,:,:),opts3)
  plot(6) = cplot6
  delete(opts3@gsnCenterString)
  ; plot7
  opts3@gsnCenterString              = tag2+": 95th"
  cplot7  = gsn_csm_contour_map(wks1,var2(2,:,:),opts3)
  plot(7) = cplot7
  delete(opts3@gsnCenterString)
  ; plot8
  optsd@gsnCenterString              = tag1+"-"+tag2+": 95th"
  cplot8  = gsn_csm_contour_map(wks1,diff(2,:,:),optsd)
  plot(8) = cplot8
  delete(optsd@gsnCenterString)

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
title_fin = vartitle1+" "+units+" Net percentiles and difference"

  res_pan                            = True
  res_pan@txString                   = title_fin        ; main title
  res_pan@txFontHeightF              = 0.012
  res_pan@gsnPaperOrientation        = "landscape"      ; landscape mode
  res_pan@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  res_pan@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  res_pan@gsnPanelScalePlotIndex     = 1
  res_pan@gsnMaximize                = True	       ; fill the page
;  res_pan@gsnPanelLabelBar           = True
;  res_pan@lbTitleString              = units
;  res_pan@lbTitlePosition            = "right"
;  res_pan@lbLabelStride              = stride1
;  res_pan@lbLabelFontHeightF         = 0.01
;  res_pan@lbTitleJust                = "CenterLeft"
;  res_pan@lbTitleFontHeightF         = 0.01
;  res_pan@lbTitleDirection           = "Across"
  gsn_panel(wks1,(/plot/),(/3,3/),res_pan)               ; create final panel plot

  print("converting plot 1 to png")
; convert to png 
  convert_cmd = "convert -density 300 "+fout1+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 257 -depth 8 "+fout1+".png"

  system(convert_cmd)

delete(res_pan)
delete(plot)
delete(additional_colors)

print("Completed all percentile plots for "+varcode)
print("Good job!")
;;;;;;;;;;;;;;;;;;;;;; END script
end
