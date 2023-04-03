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
  datatitle1  = "wrf-2007-02-27_18.green50"
; ******************************************************
; BEGIN SCRIPT
print("Checking windstress curl")

;;;;;;;;;;
; Load input files
;;;;;;;;;;
; Dates from data array index and visual file that places each date at a given node

f1 = addfile("./"+datatitle1+"-coare-sst.nc","r")
f2 = addfile("./"+datatitle1+".cf.nc","r")

Z_sfc = f1->Z_sfc
lat2d = f1->lat
lon2d = f1->lon
wspd = f1->wspd_10m
curl_tau = f1->curl_tau
u = f2->u_10m_tr(0,:,:)
v = f2->v_10m_tr(0,:,:)

; change units for plotting
curl_tau = curl_tau*(10.0^5)
curl_tau@units = "10-5 N m-3"

fill = new((/1/),"float")
wspd@_FillValue = fill
curl_tau@_FillValue = fill
u@_FillValue = fill
v@_FillValue = fill

; mask out areas not needed
wspd = where(Z_sfc .lt. 50. .and. lat2d .gt. 55. .and. lat2d .lt. 71. .and. lon2d .lt. -19. .and. lon2d .gt. -55., wspd, wspd@_FillValue)
curl_tau = where(Z_sfc .lt. 50. .and. lat2d .gt. 55. .and. lat2d .lt. 71. .and. lon2d .lt. -19. .and. lon2d .gt. -55., curl_tau, curl_tau@_FillValue)
u = where(Z_sfc .lt. 50. .and. lat2d .gt. 55. .and. lat2d .lt. 71. .and. lon2d .lt. -19. .and. lon2d .gt. -55., u, u@_FillValue)
v = where(Z_sfc .lt. 50. .and. lat2d .gt. 55. .and. lat2d .lt. 71. .and. lon2d .lt. -19. .and. lon2d .gt. -55., v, v@_FillValue)

wspd@lat2d = lat2d
wspd@lon2d = lon2d
u@lat2d = lat2d
u@lon2d = lon2d
v@lat2d = lat2d
v@lon2d = lon2d
curl_tau@lat2d = lat2d
curl_tau@lon2d = lon2d

print("Max wspd: "+max(wspd)+" , Min wspd: "+min(wspd))
print("Max curl_tau: "+max(curl_tau)+" , Min curl_tau: "+min(curl_tau))

; add each variable set in the c-shell 'varcode' and assign it a title and other necessary information
  cmin1               = 0.
  cmax1               = 35.
  clev1               = 2.5
  stride1             = 2                 ; label stride
  cmin2               = -2.
  cmax2               = 2.
  clev2               = 0.2
  stride2             = 2                 ; label stride for diff plot
  plotlines           = False              ; lines for reg plot
  difflines           = False              ; lines for diff plot
  cntype              = "AreaFill"
  spreadstart1        = 2                 ; start at color
  spreadend1          = 35                ; end at color
  spreadstart2        = 37                ; start at color
  spreadend2          = 132               ; end at color
  colormap            = "SOM_wind_table"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; set outdir and fout names
outdir = "./"
fout = "curl_tau_test_"+datatitle1

wks = gsn_open_wks("ps",fout)
additional_colors = (/"gray85", "forestgreen", "yellow"/)
gsn_merge_colormaps(wks,colormap,additional_colors)
plot = new(2, graphic)

;;;;;;;;;;;;;
; Set resources for variable plots
;;;;;;;;;;;;
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
  res@mpLimitMode                 = "LatLon"	     ; how to zoom in on map
  res@mpMinLatF                   = 56.              ; set the minimum latitude 
  res@mpMaxLatF                   = 70.              ; set the maximum latitude 
  res@mpMinLonF                   = -54.0            ; set the minimum longitude 
  res@mpMaxLonF                   = -20.0            ; set the maximum longitude 

;;;;;;;;;;;;;
; Make wspd plot
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
  opts@tiMainString               = "Wind speed"
  opts@gsnRightString             = wspd@units
  ; vector res
  opts@vcGlyphStyle               = "LineArrow"
  opts@vcRefMagnitudeF            = 3.0
  opts@vcRefLengthF               = 0.01
  opts@vcMinDistanceF             = 0.05
  opts@vcMonoLineArrowColor       = True
  opts@vcLineArrowColor           = "black"
  opts@vcRefAnnoOn                = False
  opts@gsnScalarContour           = True

  cplot0  = gsn_csm_vector_scalar_map(wks,u,v,wspd,opts)
  plot(0) = cplot0
    
;;;;;;;;;;;;;
; Make curl_tau plot
;;;;;;;;;;;;;
  opts1                            = res               ; reset options
  opts1@cnFillMode                 = cntype
  opts1@cnFillOn                   = True              ; turn on filled contours
  opts1@gsnSpreadColors            = True              ; use full colormap
  opts1@gsnSpreadColorStart        = spreadstart2      ; start at color specified for each variable above
  opts1@gsnSpreadColorEnd          = spreadend2        ; end at color specified above
  opts1@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  opts1@cnMinLevelValF             = cmin2             ; set min contour level specified above
  opts1@cnMaxLevelValF             = cmax2             ; set max contour level specified above
  opts1@cnLevelSpacingF            = clev2             ; set contour spacing specified above
  opts1@cnLinesOn                  = plotlines         ; contour lines specified above
  opts1@cnLineLabelsOn             = plotlines         ; line labels on specified above
  opts1@cnMissingValFillColor      = "gray85"          ; missing value color
  opts1@cnMissingValFillPattern    = 0                 ; fill in
  opts1@cnMissingValPerimOn        = True
  opts1@cnMissingValPerimColor     = "black"
  opts1@tiMainFontHeightF          = 0.013
  opts1@lbLabelStride              = stride2
  opts1@pmLabelBarOrthogonalPosF   = -0.01             ; move label bar closer
  opts1@pmLabelBarHeightF          = 0.075             ; set height of labelbar
  opts1@tiMainString               = "Wind stress curl"
  opts1@gsnRightString             = curl_tau@units

  cplot1  = gsn_csm_contour_map(wks,curl_tau, opts1)
  plot(1) = cplot1

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
title_fin = datatitle1

  pnlres                            = True
  pnlres@txString                   = title_fin        ; main title
  pnlres@txFontHeightF              = 0.02
  pnlres@gsnPaperOrientation        = "landscape"      ; landscape mode
  pnlres@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelScalePlotIndex     = 1
  pnlres@gsnMaximize                = True	       ; fill the page
  gsn_panel(wks,(/plot/),(/1,2/),pnlres)               ; create final panel plot

  print("converting plot to png")
; convert to png 
  convert_cmd = "convert -density 300 "+fout+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout+".png"

  system(convert_cmd)

print("Good job!")
;;;;;;;;;;;;;;;;;;;;;; END script
end
