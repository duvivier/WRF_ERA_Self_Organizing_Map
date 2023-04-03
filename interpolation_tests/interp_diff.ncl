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
zoom1 = False
zoom2 = False
zoom3 = True
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Set which plots to print out
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; BEGIN SCRIPT

  f0 = addfile("./wrf-2005-11-01_00.green10.cf.nc","r")
  f1 = addfile("./wrf-2005-11-01_00.green10-coare-sst.nc","r")
  f2 = addfile("./wrf-2005-11-01_00.green50.cf.nc","r")
  fill = new((/1/),"float")

  ; 10km file
  lat10 = f0->lat
  lon10 = f0->lon
  Z_sfc_10 = f0->Z_sfc
  mask_50 = f1->mask_50km_terrain
  sst_10 = f0->SST(0,:,:)
  sst_10 = sst_10 - 273.15
  sst_grad = f1->SST
  sst_raw = f1->SST_raw
  sst_10@lat2d = lat10
  sst_10@lon2d = lon10
  sst_10@_FillValue = fill
  copy_VarMeta(sst_10, sst_grad)
  copy_VarMeta(sst_10, sst_raw)

  ; 50km file
  lat50 = f2->lat
  lon50 = f2->lon
  Z_sfc_50 = f2->Z_sfc
  sst_50 = f2->SST(0,:,:)
  sst_50 = sst_50 - 273.15
  sst_50@units = "C"
  sst_50@lat2d = lat50
  sst_50@lon2d = lon50
  sst_50@_FillValue = fill

  ; mask land
  sst_10 = where(mask_50 .eq. 1, sst_10, fill)
  sst_grad = where(mask_50 .eq. 1, sst_grad, fill)
  sst_raw = where(mask_50 .eq. 1, sst_raw, fill)
  sst_50 = where(Z_sfc_50 .lt. 10.0, sst_50, fill)

  ; get 10km difference
  diff1 = sst_grad - sst_10
  copy_VarMeta(sst_10, diff1)
  diff2 = sst_raw - sst_10
  copy_VarMeta(sst_10, diff2)
  diff3 = sst_grad - sst_raw
  copy_VarMeta(sst_10, diff3)

  ; plotting options
  cmin1               = -5. ;-10.
  cmax1               = 10.
  clev1               = 1.
  stride1             = 2                 ; label stride
  cmin2               = -3.
  cmax2               = 3.
  clev2               = 0.2
  stride2             = 2                 ; label stride diff plot
  plotlines           = False             ; lines for reg plot
  difflines           = False             ; lines for diff plot
  cntype              = "RasterFill"        ; type of contour fill
  spreadstart1        = 67                ; start at color
  spreadend1          = 106               ; end at color
  colormap            = "temp64_anoms.dave"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  if (zoom1 .eq. True) then
    fout01 = "SST_interpolation_tests_zoom1"
  end if
  if (zoom2 .eq. True) then
    fout01 = "SST_interpolation_tests_zoom2"
  end if
  if (zoom3 .eq. True) then
    fout01 = "SST_interpolation_tests_zoom3"
  end if
  
wks01 = gsn_open_wks("ps" ,fout01)
additional_colors = (/"black","gray85", "forestgreen", "yellow"/)
gsn_merge_colormaps(wks01,colormap,additional_colors)
plot = new(8, graphic)

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
  res@mpLimitMode                 = "LatLon"
  if (isvar("zoom1").and.(zoom1))then
    res@mpMinLatF                   = 56.              ; set the minimum latitude 
    res@mpMaxLatF                   = 70.              ; set the maximum latitude 
    res@mpMinLonF                   = -54.0            ; set the minimum longitude 
    res@mpMaxLonF                   = -20.0            ; set the maximum longitude 
  end if
  if (isvar("zoom2").and.(zoom2))then
    res@mpMinLatF                   = 58.              ; set the minimum latitude 
    res@mpMaxLatF                   = 61.              ; set the maximum latitude 
    res@mpMinLonF                   = -47.0            ; set the minimum longitude 
    res@mpMaxLonF                   = -40.0            ; set the maximum longitude 
  end if
  if (isvar("zoom3").and.(zoom3))then
    res@mpMinLatF                   = 61.              ; set the minimum latitude 
    res@mpMaxLatF                   = 66.              ; set the maximum latitude 
    res@mpMinLonF                   = -41.0            ; set the minimum longitude 
    res@mpMaxLonF                   = -30.0            ; set the maximum longitude 
  end if

  ; set contour information
  res@cnFillMode                 = cntype
  res@cnFillOn                   = True              ; turn on filled contours
  res@gsnSpreadColors            = True              ; use full colormap
  res@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  res@cnLinesOn                  = plotlines         ; contour lines specified above
  res@cnLineLabelsOn             = plotlines         ; line labels on specified above
  res@cnMissingValFillColor      = "gray85"          ; missing value color
  res@cnMissingValFillPattern    = 0                 ; fill in
  res@cnMissingValPerimOn        = False ;True
  res@cnMissingValPerimColor     = "black"
  res@lbLabelBarOn               = True

  ; set "regular" options
  res1                            = res
  res1@gsnSpreadColorStart        = spreadstart1      ; start at color specified for each variable above
  res1@gsnSpreadColorEnd          = spreadend1        ; end at color specified above
  res1@cnMinLevelValF             = cmin1             ; set min contour level specified above
  res1@cnMaxLevelValF             = cmax1             ; set max contour level specified above
  res1@cnLevelSpacingF            = clev1             ; set contour spacing specified above
  res1@lbLabelStride              = stride1 

  ; set "difference" options
  resd                            = res
  resd@gsnSpreadColorStart        = spreadstart1      ; start at color specified for each variable above
  resd@gsnSpreadColorEnd          = spreadend1        ; end at color specified above
  resd@cnMinLevelValF             = cmin2             ; set min contour level specified above
  resd@cnMaxLevelValF             = cmax2             ; set max contour level specified above
  resd@cnLevelSpacingF            = clev2             ; set contour spacing specified above
  resd@lbLabelStride              = stride2

;;;;;;;;;;;;;
; Make plot 0 - native wrf50
;;;;;;;;;;;;;
  opts0 = res1
  opts0@tiMainString               = "WRF50: orig met_em"
  cplot0  = gsn_csm_contour_map(wks01,sst_50,opts0)
  plot(0) = cplot0
  delete(opts0)

;;;;;;;;;;;;;
; Make plot 1 - native wrf10
;;;;;;;;;;;;;
  opts1 = res1
  opts1@tiMainString               = "WRF10: orig met_em"
  cplot1  = gsn_csm_contour_map(wks01,sst_10,opts1)
  plot(1) = cplot1
  delete(opts1)
  
;;;;;;;;;;;;;
; Make plot 2 - wrf10 weighted avg interpolation
;;;;;;;;;;;;;
  opts2 = res1
  opts2@tiMainString               = "WRF10: weighted avg interp"
  cplot2  = gsn_csm_contour_map(wks01,sst_grad,opts2)
  plot(2) = cplot2
  delete(opts2)

;;;;;;;;;;;;;
; Make plot 3 - wrf10 assign wrf50 values
;;;;;;;;;;;;;
  opts3 = res1
  opts3@tiMainString               = "WRF10: assign direct interp"
  cplot3  = gsn_csm_contour_map(wks01,sst_raw,opts3)
  plot(3) = cplot3
  delete(opts3)

;;;;;;;;;;;;;
; Make plot 4 - wrf10 difference1
;;;;;;;;;;;;;
  opts4 = resd
  opts4@tiMainString               = "WRF10: wgtavg - orig"
  cplot4  = gsn_csm_contour_map(wks01,diff1,opts4)
  plot(5) = cplot4
  delete(opts4)

;;;;;;;;;;;;;
; Make plot 5 - wrf10 difference2
;;;;;;;;;;;;;
  opts5 = resd
  opts5@tiMainString               = "WRF10: assign - orig"
  cplot5  = gsn_csm_contour_map(wks01,diff2,opts5)
  plot(6) = cplot5
  delete(opts5)

;;;;;;;;;;;;;
; Make plot 6 - wrf10 difference3
;;;;;;;;;;;;;
  opts6 = resd
  opts6@tiMainString               = "WRF10: wgtavg - assign"
  cplot6  = gsn_csm_contour_map(wks01,diff3,opts6)
  plot(7) = cplot6
  delete(opts6)


;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
title_fin = "SST interpolation comparison for WRF50->WRF10"

  res_pan                            = True
  res_pan@txString                   = title_fin        ; main title
  res_pan@txFontHeightF              = 0.02
  res_pan@gsnPaperOrientation        = "landscape"      ; landscape mode
  res_pan@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  res_pan@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  res_pan@gsnPanelScalePlotIndex     = 1
  res_pan@gsnMaximize                = True	       ; fill the page
  gsn_panel(wks01,(/plot/),(/2,4/),res_pan)               ; create final panel plot

  print("converting plot 1 to png")
; convert to png 
  convert_cmd = "convert -density 300 "+fout01+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout01+".png"

  system(convert_cmd)

delete(res_pan)
delete(plot)
delete(additional_colors)

print("Good job!")
;;;;;;;;;;;;;;;;;;;;;; END script
end
