;***************************************
; PROGRAM DESCRIPTION: This script plots panels of the surface energy budget
;                      over the polar cap for each month in a year.
; INPUT DATA: Multiyear monthly averages files from ERA-I, CORE2, and two 
;             WRF simulations. The WRF simulations require two files for
;             all variables.
; OUTPUT DATA: XY plots of energy budget terms
; CREATOR: Alice DuVivier - Sept. 2013
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************
begin
; MANUAL INPUTS
title0 = "wrf10"
title1 = "wrf50"
title2 = "era_i"

en_num = 3

; BEGIN SCRIPT
print("Creating comparisons of percentiles")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Get information from files
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; addfiles
indir = "/data3/duvivier/SOM/analysis/extremes/individual_locs/"
f0 = addfile(indir+"net_"+title0+"_200511_200703_6h-extremes-fracice-point-percentiles.nc","r")
f1 = addfile(indir+"net_"+title1+"_200511_200703_6h-extremes-fracice-point-percentiles.nc","r")
f2 = addfile(indir+"net_"+title2+"_200511_200703_6h-extremes-fracice-point-percentiles.nc","r")

; Preallocate arrays for wind, lhflx, shflx data for each location and each resolution
CF_U10 = new((/3,101/),"float")
CF_lhflx = new((/3,101/),"float")
CF_shflx = new((/3,101/),"float")

DSS_U10 = new((/3,101/),"float")
DSS_lhflx = new((/3,101/),"float")
DSS_shflx = new((/3,101/),"float")

DSN_U10 = new((/3,101/),"float")
DSN_lhflx = new((/3,101/),"float")
DSN_shflx = new((/3,101/),"float")

; Load data for Cape Farewell
CF_U10(0,:) = f0->CF_U10_pcnt
CF_U10(1,:) = f1->CF_U10_pcnt
CF_U10(2,:) = f2->CF_U10_pcnt
CF_U10@units = "m s-1"

CF_lhflx(0,:) = f0->CF_lhflx_pcnt
CF_lhflx(1,:) = f1->CF_lhflx_pcnt
CF_lhflx(2,:) = f2->CF_lhflx_pcnt
CF_lhflx@units = "W m-2"

CF_shflx(0,:) = f0->CF_shflx_pcnt
CF_shflx(1,:) = f1->CF_shflx_pcnt
CF_shflx(2,:) = f2->CF_shflx_pcnt
CF_shflx@units = "W m-2"

; Load data for Denmark Strait South
DSS_U10(0,:) = f0->DSS_U10_pcnt
DSS_U10(1,:) = f1->DSS_U10_pcnt
DSS_U10(2,:) = f2->DSS_U10_pcnt
DSS_U10@units = "m s-1"

DSS_lhflx(0,:) = f0->DSS_lhflx_pcnt
DSS_lhflx(1,:) = f1->DSS_lhflx_pcnt
DSS_lhflx(2,:) = f2->DSS_lhflx_pcnt
DSS_lhflx@units = "W m-2"

DSS_shflx(0,:) = f0->DSS_shflx_pcnt
DSS_shflx(1,:) = f1->DSS_shflx_pcnt
DSS_shflx(2,:) = f2->DSS_shflx_pcnt
DSS_shflx@units = "W m-2"

; Load data for Denmark Strait North
DSN_U10(0,:) = f0->DSN_U10_pcnt
DSN_U10(1,:) = f1->DSN_U10_pcnt
DSN_U10(2,:) = f2->DSN_U10_pcnt
DSN_U10@units = "m s-1"

DSN_lhflx(0,:) = f0->DSN_lhflx_pcnt
DSN_lhflx(1,:) = f1->DSN_lhflx_pcnt
DSN_lhflx(2,:) = f2->DSN_lhflx_pcnt
DSN_lhflx@units = "W m-2"

DSN_shflx(0,:) = f0->DSN_shflx_pcnt
DSN_shflx(1,:) = f1->DSN_shflx_pcnt
DSN_shflx(2,:) = f2->DSN_shflx_pcnt
DSN_shflx@units = "W m-2"

;;;;;;;;;;;;;
; Make x axis arrays
;;;;;;;;;;;;;
; make array to plot values against (SPECIFIED MANUALLY)
xtit = new((/101/),"integer")
do i = 0,101 -1
  xtit(i) = i+1
end do

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot data from each resolution
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
outdir = "./"
fout   = "percentiles_compare_"+title0+"_"+title1+"_"+title2

print ("Plotting data")


;;;;;;;;;;;;;
; First plot - Cape Farewell
;;;;;;;;;;;;;
  fout0 = outdir+"CF-"+fout
  wks0 = gsn_open_wks("ps",fout0)
  plot = new(3, graphic)

; set resources used for all plots
  res                             = True              ; plot mods desired
  res@gsnFrame                    = False             ; Do not draw plot 
  res@gsnDraw                     = False             ; Do not advance frame
  res@gsnMaximize                 = True              ; maximize plot

; set title resources
  res@tiMainOn                    = True              ; turn on main title for each plot
  res@tiMainFontHeightF           = 0.03              ; set size of font for main plot
  res@tiMainFontThicknessF        = 1.5

; set x axis tick marks
  res@tmXTOn                      = False             ; delete top and right ticks
  res@tmYROn                      = False
  res@trXMinF                     = min(xtit)         ; set lower x limit
  res@trXMaxF                     = max(xtit)         ; set upper x limit
  ;res@tmYLMode                    = "Manual"
  res@tmXBMode                    = "Explicit"
  res@tmXBValues                  = (/1, 11, 21, 31, 41, 51, 61, 71, 81, 91, 101/)
  res@tmXBLabels                  = (/"0","10","20","30","40","50","60","70","80","90","100"/)
  res@tiXAxisString               = "Percentile"
  res@tiXAxisFontHeightF          = 0.02              ; set font size for x axis
  res@tmXBLabelFontHeightF        = 0.02              ; set tick mark label size for x axis
  res@tiYAxisFontHeightF          = 0.02              ; set font size for y axis
  res@tmYLLabelFontHeightF        = 0.02              ; set tick mark label size for y axis
  res@vpHeightF                   = 0.3               ; change aspect ratio of plot (viewport)
  res@vpWidthF                    = 0.9               
  
; arrays for different colors, etc.(requires a single array of data)
   res@xyMarkLineModes             = (/"Lines", "Lines", "Lines"/)
   res@xyLineColors                = (/"red", "blue", "black"/)
   res@xyMonoLineColor             =  False                 ; allow other line colors
   res@xyDashPatterns              = (/0, 0, 0/)
   res@xyLineThicknesses           = (/2, 2, 2/)

;;;;;;;;;;;;;
; Plot 0 - U10
;;;;;;;;;;;;;
title = "a)  10m windspeed"
  opts                            = res           ; set resources for plot 1 
  opts@tiMainString               = title         ; set title for plot. 
  opts@tiYAxisString              = CF_U10@units
  ;opts@trYMinF                    = -300.
  ;opts@trYMaxF                    = 300.
  cplot0 = gsn_csm_xy(wks0, xtit, CF_U10, opts) 
  plot(0) = cplot0                              ; make panel section of this plot
  delete(opts)
  delete(title)

;;;;;;;;;;;;;
; Plot 1 - Lhflx
;;;;;;;;;;;;;
title = "b)  Latent Heat Flux"
  opts                            = res           ; set resources for plot 1 
  opts@tiMainString               = title         ; set title for plot. 
  opts@tiYAxisString              = CF_lhflx@units
  ;opts@trYMinF                    = -300.
  ;opts@trYMaxF                    = 300.
  cplot1 = gsn_csm_xy(wks0, xtit, CF_lhflx, opts) 
  plot(1) = cplot1                              ; make panel section of this plot
  delete(opts)
  delete(title)

;;;;;;;;;;;;;
; Plot 2 - Shflx
;;;;;;;;;;;;;
title = "c)  Sensible Heat Flux"
  opts                            = res           ; set resources for plot 1 
  opts@tiMainString               = title         ; set title for plot. 
  opts@tiYAxisString              = CF_shflx@units
  ;opts@trYMinF                    = -300.
  ;opts@trYMaxF                    = 300.
  cplot2 = gsn_csm_xy(wks0, xtit, CF_shflx, opts) 
  plot(2) = cplot2                              ; make panel section of this plot
  delete(opts)
  delete(title)

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
  titlefin = "Percentile Comparison near Cape Farewell"

  pnlres                            = True
  pnlres@gsnMaximize                = True
  pnlres@gsnFrame                   = False
  pnlres@txString                   = titlefin         ; set title for whole panel plot.
  pnlres@txFontHeightF              = 0.013
  pnlres@gsnPaperOrientation        = "landscape"      ; landscape mode
  pnlres@gsnPanelYWhiteSpacePercent = 2                ; Add white space b/w plots.
  pnlres@gsnPanelXWhiteSpacePercent = 2                ; Add white space b/w plots.
  pnlres@gsnPanelScalePlotIndex     = 1
  pnlres@gsnPanelBottom             = 0.13             ; leave room for legend at bottom
  pnlres@gsnMaximize                = True	       ; fill the page
  gsn_panel(wks0,(/plot/),(/3,1/),pnlres)               ; create final panel plot

;  ; make general legend
; legend resources for all the plots
  lgres                    = True

  ;lgres@pmLegendWidthF     = 0.03
  ;lgres@pmLegendHeightF    = 0.01
  lgres@vpWidthF           = 0.5               ; width of legend (NDC)
  lgres@vpHeightF          = 0.05               ; height of legend (NDC)
  lgres@lgLabelFontHeightF = 0.015
  lgres@lgAutoManage       = False              ; false allows me to set the legend directly
  
  lgres@lgOrientation      = "horizontal" 
  lgres@lgMonoLineColor    = False
  lgres@lgMonoItemType     = False
  lgres@lgItemTypes        = res@xyMarkLineModes
  lgres@lgDashIndexes      = res@xyDashPatterns
  lgres@lgMonoLineThickness = False
  lgres@lgLineThicknesses  = res@xyLineThicknesses
  lgres@lgLineColors       = res@xyLineColors   ; make the colors for the legend
  xpos = 0.25   ; xposition 
  ypos = 0.13  ; yposition (below figures)

  gsn_legend_ndc(wks0,en_num,(/title0, title1, title2/),xpos ,ypos ,lgres) 

frame(wks0)
; Post Processing stuff 
convert_cmd = "convert -density 300 "+fout0+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout0+".png" 
system(convert_cmd)

print("Plots Completed for Cape Farewell")
; keep resources for next plots too

;;;;;;;;;;;;;
; Second plot - Denmark Strait South
;;;;;;;;;;;;;
  fout1 = outdir+"DSS-"+fout
  wks1 = gsn_open_wks("ps",fout1)
  plot = new(3, graphic)

;;;;;;;;;;;;;
; Plot 0 - U10
;;;;;;;;;;;;;
title = "a)  10m windspeed"
  opts                            = res           ; set resources for plot 1 
  opts@tiMainString               = title         ; set title for plot. 
  opts@tiYAxisString              = DSS_U10@units
  ;opts@trYMinF                    = -300.
  ;opts@trYMaxF                    = 300.
  cplot0 = gsn_csm_xy(wks1, xtit, DSS_U10, opts) 
  plot(0) = cplot0                              ; make panel section of this plot
  delete(opts)
  delete(title)

;;;;;;;;;;;;;
; Plot 1 - Lhflx
;;;;;;;;;;;;;
title = "b)  Latent Heat Flux"
  opts                            = res           ; set resources for plot 1 
  opts@tiMainString               = title         ; set title for plot. 
  opts@tiYAxisString              = DSS_lhflx@units
  ;opts@trYMinF                    = -300.
  ;opts@trYMaxF                    = 300.
  cplot1 = gsn_csm_xy(wks1, xtit, DSS_lhflx, opts) 
  plot(1) = cplot1                              ; make panel section of this plot
  delete(opts)
  delete(title)

;;;;;;;;;;;;;
; Plot 2 - Shflx
;;;;;;;;;;;;;
title = "c)  Sensible Heat Flux"
  opts                            = res           ; set resources for plot 1 
  opts@tiMainString               = title         ; set title for plot. 
  opts@tiYAxisString              = DSS_shflx@units
  ;opts@trYMinF                    = -300.
  ;opts@trYMaxF                    = 300.
  cplot2 = gsn_csm_xy(wks1, xtit, DSS_shflx, opts) 
  plot(2) = cplot2                              ; make panel section of this plot
  delete(opts)
  delete(title)

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
  titlefin = "Percentile Comparison near Denmark Strait South"
  delete(pnlres@txString)
  pnlres@txString                   = titlefin         ; set title for whole panel plot.
  gsn_panel(wks1,(/plot/),(/3,1/),pnlres)               ; create final panel plot

  ; make general legend
  gsn_legend_ndc(wks1,en_num,(/title0, title1, title2/),xpos ,ypos ,lgres) 

frame(wks1)
; Post Processing stuff 
convert_cmd = "convert -density 300 "+fout1+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout1+".png"   
system(convert_cmd)

print("Plots Completed for Denmark Strait South")
; keep resources for next plots too

;;;;;;;;;;;;;
; Third plot - Denmark Strait North
;;;;;;;;;;;;;
  fout2 = outdir+"DSN-"+fout
  wks2 = gsn_open_wks("ps",fout2)
  plot = new(3, graphic)

;;;;;;;;;;;;;
; Plot 0 - U10
;;;;;;;;;;;;;
title = "a)  10m windspeed"
  opts                            = res           ; set resources for plot 1 
  opts@tiMainString               = title         ; set title for plot. 
  opts@tiYAxisString              = DSN_U10@units
  ;opts@trYMinF                    = -300.
  ;opts@trYMaxF                    = 300.
  cplot0 = gsn_csm_xy(wks2, xtit, DSN_U10, opts) 
  plot(0) = cplot0                              ; make panel section of this plot
  delete(opts)
  delete(title)

;;;;;;;;;;;;;
; Plot 1 - Lhflx
;;;;;;;;;;;;;
title = "b)  Latent Heat Flux"
  opts                            = res           ; set resources for plot 1 
  opts@tiMainString               = title         ; set title for plot. 
  opts@tiYAxisString              = DSN_lhflx@units
  ;opts@trYMinF                    = -300.
  ;opts@trYMaxF                    = 300.
  cplot1 = gsn_csm_xy(wks2, xtit, DSN_lhflx, opts) 
  plot(1) = cplot1                              ; make panel section of this plot
  delete(opts)
  delete(title)

;;;;;;;;;;;;;
; Plot 2 - Shflx
;;;;;;;;;;;;;
title = "c)  Sensible Heat Flux"
  opts                            = res           ; set resources for plot 1 
  opts@tiMainString               = title         ; set title for plot. 
  opts@tiYAxisString              = DSN_shflx@units
  ;opts@trYMinF                    = -300.
  ;opts@trYMaxF                    = 300.
  cplot2 = gsn_csm_xy(wks2, xtit, DSN_shflx, opts) 
  plot(2) = cplot2                              ; make panel section of this plot
  delete(opts)
  delete(title)

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
  titlefin = "Percentile Comparison near Denmark Strait North"
  delete(pnlres@txString)
  pnlres@txString                   = titlefin         ; set title for whole panel plot.
  gsn_panel(wks2,(/plot/),(/3,1/),pnlres)               ; create final panel plot

  ; make general legend
  gsn_legend_ndc(wks2,en_num,(/title0, title1, title2/),xpos ,ypos ,lgres) 

frame(wks2)
; Post Processing stuff 
convert_cmd = "convert -density 300 "+fout2+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout2+".png"   
system(convert_cmd)

print("Plots Completed for Denmark Strait North")
; keep resources for next plots too

;;;;;;;;;;;;;;;;;;;;;; END script
end
