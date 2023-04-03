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
;  nx_input = "7"
;  ny_input = "5"
;  varcode = "LH"
;  datatitle1  = "wrf50_200511_200703_6h"
;  datatitle1b = "wrf50_200511_200703_6h"
  ;; options: "wrf10_200511_200703_6h" "wrf50_200511_200703_6h" "era_i_200511_200703_6h"
; ******************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Set which plots to print out
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Processing all graphs for "+varcode)
; create plots!
plot1  = True ; plot 1 - 3 panel comparing fluxes with 6h and nodeavg
plot3  = True ; plot 3 - nodes with 6h avg fluxes
plot4  = True ; plot 4 - nodes with nodeavg fluxes
plot6  = True ; plot 6 - nodes with diff 
plot8  = True ; plot 8 - nodes with % diff
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

; set input directory and file name strings
dir1 = "/data3/duvivier/SOM/analysis/flux_compare/node_avgs/fluxes/"
dir1b = "/data3/duvivier/SOM/analysis/flux_compare/node_avgs/fluxes_fromnodeavgs/"

; set outdir 
outdir = "./"

; set number of nodes to process
nx_node = stringtoint(nx_input)
ny_node = stringtoint(ny_input)
nnode = nx_node*ny_node

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Calculate node differences
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;
; Set information for variable
;;;;;;;;;;
; add each variable set in the c-shell 'varcode' and assign it a title and other necessary information
if (varcode.eq."SH") then
  vartitle1 = "Average Sensible Heat Flux at surface"
  invar1 = "SHFlx_avg"
  invar2 = "SHFlx_avg"
  vartype = "2d"
  cmaptype = "shflux"
  zoom2 = True
end if
if (varcode.eq."LH") then
  vartitle1 = "Average Latent Heat Flux at surface"
  invar1 = "LHFlx_avg"
  invar2 = "LHFlx_avg"
  vartype = "2d"
  cmaptype = "lhflux"
  zoom2 = True
end if

; Set the contour interval for each input variable   
; set contour limits manually:
  if (cmaptype.eq."lhflux") then
    cmin1               =  -200.     ; for net avgs
    cmax1               =  200.
    clev1               =  20.
    stride1             = 2                 ; label stride
    cmin2               = -50.      ; for net diffs
    cmax2               =  50.
    clev2               =  5.
    stride2             = 2                 ; label stride diff plot
    cmin3               = -50.      ; for % diffs
    cmax3               = 50.
    clev3               = 5.
    stride3             = 2                 ; label stride
    cmin4               = -300.      ; for node avgs
    cmax4               = 300.
    clev4               = 30.
    stride4             = 2                 ; label stride for diff plot 
    cmin5               = -50.       ; for node diffs
    cmax5               =  50.
    clev5               =  5.
    stride5             = 2                 ; label stride diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"      ; type of fill for contours 
    spreadstart1        = 2                 ; start at color
    spreadend1          = 250               ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 250               ; end at color
    spreadstart3        = 2                 ; start at color
    spreadend3          = 250                ; end at color
    spreadstart4        = 2                ; start at color
    spreadend4          = 250               ; end at color
    colormap            = "BlueYellowRed_mod"
  end if
  if (cmaptype.eq."shflux") then
    cmin1               =  -200.     ; for net avgs
    cmax1               =  200.
    clev1               =  20.
    stride1             = 2                 ; label stride
    cmin2               = -50.      ; for net diffs
    cmax2               =  50.
    clev2               =  5.
    stride2             = 2                 ; label stride diff plot
    cmin3               = -50.      ; for % diffs
    cmax3               = 50.
    clev3               = 5.
    stride3             = 2                 ; label stride
    cmin4               = -200.      ; for node avgs
    cmax4               = 200.
    clev4               = 20.
    stride4             = 2                 ; label stride for diff plot 
    cmin5               = -50.       ; for node diffs
    cmax5               =  50.
    clev5               =  5.
    stride5             = 2                 ; label stride diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"      ; type of fill for contours 
    spreadstart1        = 2                 ; start at color
    spreadend1          = 250               ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 250               ; end at color
    spreadstart3        = 2                 ; start at color
    spreadend3          = 250                ; end at color
    spreadstart4        = 2                ; start at color
    spreadend4          = 250               ; end at color
    colormap            = "BlueYellowRed_mod"
  end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Data Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;
; load in node averages
;;;;;;;;;;
  fname0 = "node_0x_0y_"+datatitle1+"-fluxes"
; Load in lat/lon to get information for WRF10 domain
  f0 = addfile(dir1+fname0+".nc","r")
  lat2d = f0->lat
  lon2d = f0->lon
  z_sfc= f0->Z_sfc
  delete(fname0)
  delete(f0)

  dims = dimsizes(lat2d)     ; get lat/lon dimensions
  n_sn = dims(0)              ; get south/north points
  n_we = dims(1)              ; get west/east points
  n_tot = n_sn*n_we              ; get total number of points in high res domain
  delete(dims)

  ; create all-node array for node average variable
  var1 = new((/nnode,n_sn,n_we/),"float")
  var2 = new((/nnode,n_sn,n_we/),"float")
  fill = var1@_FillValue

  ; make sea ice var - overlay with everything
  seaice_1 = new((/nnode,n_sn,n_we/),"float")
  obs_1 = new((/nnode/),"float")

;;;;;;;;;;
; Load in actual data for analysis
;;;;;;;;;;
n = 0
; loop through each node
do y = 0, ny_node - 1
 do x = 0, nx_node - 1
  print("node: "+x+","+y)

  ; get node file names (load all from same file)
  fname1 = "node_"+x+"x_"+y+"y_"+datatitle1+"-fluxes"
  fname1b = "node_"+x+"x_"+y+"y_"+datatitle1+"-fluxes_fromnodeavgs"
  f1 = addfile(dir1+fname1+".nc","r")
  f1b = addfile(dir1b+fname1b+".nc","r")

  ; load variables
  var1(n,:,:) = f1->$invar1$(:,:)
  var2(n,:,:) = f1b->$invar2$(:,:)
  seaice_1(n,:,:) = f1->SeaIce_avg(:,:)
  obs_1(n) = f1->number_dates

  ; mask terrain - focus on ocean
  var1(n,:,:) = where(z_sfc .lt. 50., var1(n,:,:), var1@_FillValue)
  var2(n,:,:) = where(z_sfc .lt. 50., var2(n,:,:), var2@_FillValue)

  ; mask lat/lons - focus on S. Greenland region
  var1(n,:,:) = where(lat2d .gt. 55. .and. lat2d .lt. 71. .and. lon2d .lt. -19. .and. lon2d .gt. -55., var1(n,:,:), var1@_FillValue)
  var2(n,:,:) = where(lat2d .gt. 55. .and. lat2d .lt. 71. .and. lon2d .lt. -19. .and. lon2d .gt. -55., var2(n,:,:), var2@_FillValue)

  ; delete vars to use in next loop
  delete(fname1)
  delete(fname1b)
  delete(f1)
  delete(f1b)
  n = n+1
 end do
end do
delete(n)

print("Loaded "+varcode+" from both files")

;;;;;;;;;;
; Find difference and probability of difference
;;;;;;;;;;
; difference
diff = var2 - var1   ; dataset1 fluxes calc'ed with dataset 2 winds - dataset1 fluxes
pcnt_diff = ((var2 - var1)/var1)*100. 
pcnt_diff@_FillValue = fill
pcnt_diff = where (pcnt_diff .gt. 400., pcnt_diff@_FillValue, pcnt_diff)
pcnt_diff = where (pcnt_diff .lt. -400., pcnt_diff@_FillValue, pcnt_diff)

; assign lat/lon info
var1@lat2d = lat2d
var1@lon2d = lon2d
var2@lat2d = lat2d
var2@lon2d = lon2d
diff@lat2d = lat2d
diff@lon2d = lon2d
pcnt_diff@lat2d = lat2d
pcnt_diff@lon2d = lon2d
seaice_1@lat2d = lat2d
seaice_1@lon2d = lon2d

; prints together the variable title (set above for each type of data) with title1 (defined in cshell as the wrf or met info) and the max and min values
  print("Diff min: "+min(diff)+"  max: "+max(diff)) 
  print("Pcnt Diff min: "+min(pcnt_diff)+"  max: "+max(pcnt_diff)) 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Use net average files to calculate difference
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;
; Load net averages
;;;;;;;;;;
; net avgs
  fname1 = "net_avg_"+datatitle1+"-fluxes"
  fname1b = "net_avg_"+datatitle1+"-fluxes_fromnodeavgs"
  f1 = addfile(dir1+fname1+".nc","r")
  f1b = addfile(dir1b+fname1b+".nc","r")

  ; load the variables
  var1_avg = f1->$invar1$(:,:)
  var1_avg@_FillValue = fill
  var2_avg = f1b->$invar2$(:,:)
  var2_avg@_FillValue = fill

  ; mask terrain - focus on ocean
  var1_avg = where(z_sfc .lt. 50., var1_avg, var1_avg@_FillValue)
  var2_avg = where(z_sfc .lt. 50., var2_avg, var2_avg@_FillValue)

  ; mask lat/lons - focus on S. Greenland region
  var1_avg = where(lat2d .gt. 55. .and. lat2d .lt. 71. .and. lon2d .lt. -19. .and. lon2d .gt. -55., var1_avg, var1_avg@_FillValue)
  var2_avg = where(lat2d .gt. 55. .and. lat2d .lt. 71. .and. lon2d .lt. -19. .and. lon2d .gt. -55., var2_avg, var2_avg@_FillValue)

  seaice_1_avg  = f1->SeaIce_avg(:,:)
  obs_1 = f1->number_dates

;;;;;;;;;;
;  calculate differences
;;;;;;;;;;
  diff_avg = var2_avg - var1_avg   ; dataset1 fluxes calc'ed with dataset 2 winds - dataset1 fluxes
  pcnt_diff_avg = ((var2_avg - var1_avg)/var1_avg)*100. 

  var1_avg@lat2d = lat2d
  var1_avg@lon2d = lon2d
  var2_avg@lat2d = lat2d
  var2_avg@lon2d = lon2d
  diff_avg@lat2d = lat2d
  diff_avg@lon2d = lon2d
  pcnt_diff_avg@lat2d = lat2d
  pcnt_diff_avg@lon2d = lon2d
  seaice_1_avg@lat2d = lat2d
  seaice_1_avg@lon2d = lon2d

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Calculate probability distribution for each node
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;opts = True
;opts@bin_min = -20.0
;opts@bin_max = 300.0
;opts@bin_nice = True
;nBins = 0 ;74

;pdf1 = pdfx(var1,nBins,opts)
;pdf2 = pdfx(var2,nBins,opts)
;pdf3 = pdfx(var3,nBins,opts)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Processing all graphs for "+varcode)
; create plots!
; plot 1 - 3 panel comparing fluxes with 6h and nodeavg
; plot 3 - nodes with 6h avg fluxes
; plot 4 - nodes with nodeavg fluxes
; plot 6 - nodes with diff 
; plot 8 - nodes with % diff
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 1 - 3 panel of net fluxes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot1").and.(plot1))then  ; if plotting is turned on
  print("Plot 1 - Net fluxes and differences")
  fout1   = varcode+"_"+tag_1+"_6h_nodeavg_200511_200703_6h_winter_net_wind_diff"

  wks1 = gsn_open_wks("ps" ,fout1)
  additional_colors = (/"gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks1,colormap,additional_colors)
  plot = new(4, graphic)

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
  res_95@cnFillOn                   = True             ; turn on filled contours
  res_95@cnMonoFillColor            = True
  res_95@cnMonoFillPattern          = False
  res_95@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  res_95@cnMinLevelValF             = 0.                ; set min contour level specified above
  res_95@cnMaxLevelValF             = 95.              ; set max contour level specified above
  res_95@cnLevelSpacingF            = 95.              ; set contour spacing specified above
  res_95@cnFillPatterns             = (/-1,-1,17/)      ; hatch marks over areas where >99% sig. diff

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
  opts@cnMissingValPerimOn        = True
  opts@cnMissingValPerimColor     = "black"
  opts@tiMainFontHeightF          = 0.013
  opts@lbLabelStride              = stride1
  opts@pmLabelBarOrthogonalPosF   = -0.01             ; move label bar closer
  opts@pmLabelBarHeightF          = 0.075             ; set height of labelbar

  title = vartitle1+": uses 6h"
  opts@tiMainString               = title            ; title string specified from cshell
  cplot0  = gsn_csm_contour_map(wks1,var1_avg,opts)
  cplot0b = gsn_csm_contour(wks1,seaice_1_avg,res_ice)
  overlay(cplot0,cplot0b)
  plot(0) = cplot0
  delete(title)

  title = vartitle1+": uses nodeavg"
  opts@tiMainString               = title            ; title string specified from cshell
  cplot1  = gsn_csm_contour_map(wks1,var2_avg,opts)
  cplot1b = gsn_csm_contour(wks1,seaice_1_avg,res_ice)
  overlay(cplot1,cplot1b)
  plot(1) = cplot1
  delete(title)

delete(opts)
;;;;;;;;;;;;;
; Make difference plot
;;;;;;;;;;;;;
  opts                            = res
  opts@gsnRightString              = "avg |x|:"+sprintf("%5.2f",avg(abs(diff_avg)))
  opts@gsnLeftString               = "max |x|:"+sprintf("%5.2f",max(abs(diff_avg)))
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

  title = "difference: nodeavg - 6h"
  opts@tiMainString               = title             ; set title for difference plot
  cplot2  = gsn_csm_contour_map(wks1,diff_avg,opts)
  cplot2c = gsn_csm_contour(wks1,seaice_1_avg,res_ice)
  overlay(cplot2,cplot2c)
  plot(2) = cplot2
  delete(title)
 
delete(opts)

;;;;;;;;;;;;;
; Make percent difference plot
;;;;;;;;;;;;;
  opts                            = res
  opts@gsnRightString              = "avg |x|:"+sprintf("%5.2f",avg(abs(pcnt_diff_avg)))
  opts@gsnLeftString               = "max |x|:"+sprintf("%5.2f",max(abs(pcnt_diff_avg)))
  opts@cnFillMode                 = cntype
  opts@cnFillOn                   = True
  opts@gsnSpreadColors            = True              ; use full colormap
  opts@gsnSpreadColorStart        = spreadstart3      ; start at color specified above
  opts@gsnSpreadColorEnd          = spreadend3        ; end at color specified above
  opts@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  opts@cnMinLevelValF             = cmin3             ; set min contour level specified above
  opts@cnMaxLevelValF             = cmax3             ; set max contour level specified above
  opts@cnLevelSpacingF            = clev3             ; set contour spacing specified above
  opts@cnLinesOn                  = difflines         ; contour lines specified above
  opts@cnLineLabelsOn             = difflines
  opts@cnMissingValFillColor      = "gray85"          ; missing value color
  opts@cnMissingValFillPattern    = 0                 ; fill in
  opts@tiMainFontHeightF          = 0.013
  opts@lbLabelStride              = stride3
  opts@pmLabelBarOrthogonalPosF   = -0.01             ; move label bar closer
  opts@pmLabelBarHeightF          = 0.075

  title = "% difference: (nodeavg - 6h)/(6h)"
  opts@tiMainString               = title             ; set title for difference plot
  cplot3  = gsn_csm_contour_map(wks1,pcnt_diff_avg,opts)
  cplot3c = gsn_csm_contour(wks1,seaice_1_avg,res_ice)
  overlay(cplot3,cplot3c)
  plot(3) = cplot3
  delete(title)
 
delete(opts)

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
title_fin = vartitle1 + " ("+var1@units+")"

  res_pan                            = True
  res_pan@txString                   = title_fin        ; main title
  res_pan@txFontHeightF              = 0.02
  res_pan@gsnPaperOrientation        = "landscape"      ; landscape mode
  res_pan@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  res_pan@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  res_pan@gsnPanelScalePlotIndex     = 1
  res_pan@gsnMaximize                = True	       ; fill the page
  gsn_panel(wks1,(/plot/),(/2,2/),res_pan)               ; create final panel plot


; Finally - make plot
  print("converting plot 1 to png")
  convert_cmd = "convert -density 300 "+fout1+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout1+".png"
  system(convert_cmd)

  delete(res)
  delete(res_ice)
  delete(res_pan)
  delete(title_fin)
  delete(additional_colors)
  delete(plot)
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 3 - nodes with net flux values
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot3").and.(plot3))then  ; if plotting is turned on
print("Plot 3 - node fluxes")
fout3   = varcode+"_"+tag_1+"_6h_200511_200703_6h_node_avg"

  wks3 = gsn_open_wks("ps" ,fout3)
  additional_colors = (/"black","gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks3,colormap,additional_colors)
  plot = new(nnode, graphic)

;;;;;;;;;;;;;
; Set resources used for all plots
;;;;;;;;;;;;

  res                             = True              ; plot mods desired
  res@gsnRightString              = ""
 ; res@gsnLeftString               = ""               ; Set this in loop
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
  res@mpMaxLatF                   = 72.              ; set the maximum latitude 
  res@mpMinLonF                   = -54.0            ; set the minimum longitude 
  res@mpMaxLonF                   = -15.0            ; set the maximum longitude 

  ; set contour information
  res@cnFillMode                 = cntype
  res@cnFillOn                   = True              ; turn on filled contours
  res@gsnSpreadColors            = True              ; use full colormap
  res@gsnSpreadColorStart        = spreadstart4      ; start at color specified for each variable above
  res@gsnSpreadColorEnd          = spreadend4        ; end at color specified above
  res@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  res@cnMinLevelValF             = cmin4             ; set min contour level specified above
  res@cnMaxLevelValF             = cmax4             ; set max contour level specified above
  res@cnLevelSpacingF            = clev4             ; set contour spacing specified above
  res@cnLinesOn                  = plotlines         ; contour lines specified above
  res@cnLineLabelsOn             = plotlines         ; line labels on specified above
  res@cnMissingValFillColor      = "gray85"          ; missing value color
  res@cnMissingValFillPattern    = 0                 ; fill in
  res@cnMissingValPerimOn        = True
  res@cnMissingValPerimColor     = "black"
  res@lbLabelBarOn               = False             ; have single label bar

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
  res_ice@cnLineLabelsOn             = False             ; line labels on specified above
  res_ice@cnLineThicknessF           = 1.5
  res_ice@tiXAxisOn                  = False
  res_ice@tiYAxisOn                  = False
  res_ice@cnLineColor                = "gray85"
 
xpos = 0
ypos = 0

do n = 0, nnode-1
  ;print("Plotting graph "+n+" ("+xpos+","+ypos+")")
  var1_2d = var1(n,:,:)
  seaice_1_2d = seaice_1(n,:,:)
  res@gsnLeftString = "("+xpos+","+ypos+")"  ; (this changes)
  res@gsnLeftStringParallelPosF = 0.02 ; scoot it in just a bit as well

  cplot  = gsn_csm_contour_map(wks3,var1_2d,res)
  cplot2 = gsn_csm_contour(wks3,seaice_1_2d,res_ice)
  overlay(cplot,cplot2)
  plot(n) = cplot

; Update xpos and ypos for next time through:
  xpos = xpos + 1
  if (xpos.eq.nx_node) then
    xpos = 0
    ypos = ypos + 1
  end if
end do

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
print("Paneling...")
title_fin = "Node "+vartitle1+": uses 6h avgs"

res_pan                       = True ; panel resources
res_pan@txString              = title_fin
res_pan@txFontHeightF         = 0.015 ; title font height
res_pan@gsnPaperOrientation   = "landscape" ; landscape mode
res_pan@gsnMaximize           = True ; make it big
res_pan@gsnPanelLabelBar      = True ; common label bar
res_pan@lbTitleString         = var1@units
res_pan@lbTitlePosition       = "right"
res_pan@lbLabelStride         = stride4
res_pan@lbLabelFontHeightF    = 0.01
res_pan@lbTitleJust           = "CenterLeft"
res_pan@lbTitleFontHeightF    = 0.01 
res_pan@lbTitleDirection      = "Across"

gsn_panel(wks3,(/plot/),(/ny_node, nx_node/),res_pan)


  print("converting plot 3 to png")
; convert to png 
  convert_cmd = "convert -density 300 "+fout3+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout3+".png"

  system(convert_cmd)

  ;delete(res)
  ;delete(res_ice)
  ;delete(res_pan)
  delete(title_fin)
  delete(additional_colors)
  delete(plot)
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 4 - Winter averages for nodes - variable 2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot4").and.(plot4))then  ; if plotting is turned on
print("Plot 4 - node fluxes")
fout4   = varcode+"_"+tag_1+"_nodeavg_200511_200703_6h_node_avg"

  wks4 = gsn_open_wks("ps" ,fout4)
  additional_colors = (/"black","gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks4,colormap,additional_colors)
  plot = new(nnode, graphic)

  ; Use same resources as plot 3

xpos = 0
ypos = 0

do n = 0, nnode-1
  ;print("Plotting graph "+n+" ("+xpos+","+ypos+")")
  var2_2d = var2(n,:,:)
  seaice_1_2d = seaice_1(n,:,:)
  res@gsnLeftString = "("+xpos+","+ypos+")"  ; (this changes)
  res@gsnLeftStringParallelPosF = 0.02 ; scoot it in just a bit as well

  cplot  = gsn_csm_contour_map(wks4,var2_2d,res)
  cplot2 = gsn_csm_contour(wks4,seaice_1_2d,res_ice)
  overlay(cplot,cplot2)
  plot(n) = cplot

; Update xpos and ypos for next time through:
  xpos = xpos + 1
  if (xpos.eq.nx_node) then
    xpos = 0
    ypos = ypos + 1
  end if
end do

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
print("Paneling...")
title_fin = "Node "+vartitle1+": uses nodeavg"

res_pan                       = True ; panel resources
res_pan@txString              = title_fin
res_pan@txFontHeightF         = 0.015 ; title font height
res_pan@gsnPaperOrientation   = "landscape" ; landscape mode
res_pan@gsnMaximize           = True ; make it big
res_pan@gsnPanelLabelBar      = True ; common label bar
res_pan@lbTitleString         = var2@units
res_pan@lbTitlePosition       = "right"
res_pan@lbLabelStride         = stride4
res_pan@lbLabelFontHeightF    = 0.01
res_pan@lbTitleJust           = "CenterLeft"
res_pan@lbTitleFontHeightF    = 0.01 
res_pan@lbTitleDirection      = "Across"

gsn_panel(wks4,(/plot/),(/ny_node, nx_node/),res_pan)


  print("converting plot 4 to png")
; convert to png 
  convert_cmd = "convert -density 300 "+fout4+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout4+".png"

  system(convert_cmd)

  delete(res)
  delete(res_ice)
  delete(res_pan)
  delete(title_fin)
  delete(additional_colors)
  delete(plot)
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 6 - nodes with net flux values
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot6").and.(plot6))then  ; if plotting is turned on
print("Plot 6 - node fluxes")
fout6   = varcode+"_"+tag_1+"_diff_6h_nodeavg_diff_200511_200703_6h_node_avg"

  wks6 = gsn_open_wks("ps" ,fout6)
  additional_colors = (/"black","gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks6,colormap,additional_colors)
  plot = new(nnode, graphic)

;;;;;;;;;;;;;
; Set resources used for all plots
;;;;;;;;;;;;

  res                             = True              ; plot mods desired
  res@gsnRightString              = ""
 ; res@gsnLeftString               = ""               ; Set this in loop
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
  res@mpMaxLatF                   = 72.              ; set the maximum latitude 
  res@mpMinLonF                   = -54.0            ; set the minimum longitude 
  res@mpMaxLonF                   = -15.0            ; set the maximum longitude 

  ; set contour information
  res@cnFillMode                 = cntype
  res@cnFillOn                   = True              ; turn on filled contours
  res@gsnSpreadColors            = True              ; use full colormap
  res@gsnSpreadColorStart        = spreadstart4      ; start at color specified for each variable above
  res@gsnSpreadColorEnd          = spreadend4        ; end at color specified above
  res@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  res@cnMinLevelValF             = cmin5             ; set min contour level specified above
  res@cnMaxLevelValF             = cmax5             ; set max contour level specified above
  res@cnLevelSpacingF            = clev5             ; set contour spacing specified above
  res@cnLinesOn                  = plotlines         ; contour lines specified above
  res@cnLineLabelsOn             = plotlines         ; line labels on specified above
  res@cnMissingValFillColor      = "gray85"          ; missing value color
  res@cnMissingValFillPattern    = 0                 ; fill in
  res@cnMissingValPerimOn        = True
  res@cnMissingValPerimColor     = "black"
  res@lbLabelBarOn               = False             ; have single label bar

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
  res_ice@cnLineLabelsOn             = False             ; line labels on specified above
  res_ice@cnLineThicknessF           = 1.5
  res_ice@tiXAxisOn                  = False
  res_ice@tiYAxisOn                  = False
  res_ice@cnLineColor                = "gray85"

; set resources for 95% statistical significance overlay
  res_95                            = True               ; reset options
  res_95@gsnLeftString              = ""
  res_95@gsnRightString             = ""
  res_95@gsnFrame                   = False             ; Do not draw plot 
  res_95@gsnDraw                    = False             ; Do not advance fr
  res_95@cnInfoLabelOn              = False             ; Turn off info on contours at bottom
  res_95@cnFillOn                   = True             ; turn on filled contours
  res_95@cnMonoFillColor            = True
  res_95@cnMonoFillPattern          = False
  res_95@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  res_95@cnMinLevelValF             = 0.                ; set min contour level specified above
  res_95@cnMaxLevelValF             = 95.              ; set max contour level specified above
  res_95@cnLevelSpacingF            = 95.              ; set contour spacing specified above
  res_95@cnFillPatterns             = (/-1,-1,17/)      ; hatch marks over areas where >99% sig. diff
  res_95@lbLabelBarOn               = False             ; have single label bar
 
xpos = 0
ypos = 0

do n = 0, nnode-1
  ;print("Plotting graph "+n+" ("+xpos+","+ypos+")")
  diff_2d = diff(n,:,:)
  seaice_1_2d = seaice_1(n,:,:)

  ; get avg difference and max absolute difference/%difference
  res@gsnRightString              = "avg |x|:"+sprintf("%5.2f",avg(abs(diff_2d)))
  res@gsnLeftString               = "max |x|:"+sprintf("%5.2f",max(abs(diff_2d)))
  res@gsnCenterString = "("+xpos+","+ypos+")"  ; (this changes)
  ;res@gsnCenterStringParallelPosF = 0.02 ; scoot it in just a bit as well

  cplot  = gsn_csm_contour_map(wks6,diff_2d,res)
  cplot2 = gsn_csm_contour(wks6,seaice_1_2d,res_ice)
  overlay(cplot,cplot2)
  plot(n) = cplot

; Update xpos and ypos for next time through:
  xpos = xpos + 1
  if (xpos.eq.nx_node) then
    xpos = 0
    ypos = ypos + 1
  end if
end do

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
print("Paneling...")
title_fin = "Node "+vartitle1+" difference: nodeavg - 6h"

res_pan                       = True ; panel resources
res_pan@txString              = title_fin
res_pan@txFontHeightF         = 0.015 ; title font height
res_pan@gsnPaperOrientation   = "landscape" ; landscape mode
res_pan@gsnMaximize           = True ; make it big
res_pan@gsnPanelLabelBar      = True ; common label bar
res_pan@lbTitleString         = var1@units
res_pan@lbTitlePosition       = "right"
res_pan@lbLabelStride         = stride5
res_pan@lbLabelFontHeightF    = 0.01
res_pan@lbTitleJust           = "CenterLeft"
res_pan@lbTitleFontHeightF    = 0.01 
res_pan@lbTitleDirection      = "Across"

gsn_panel(wks6,(/plot/),(/ny_node, nx_node/),res_pan)


  print("converting plot 6 to png")
; convert to png 
  convert_cmd = "convert -density 300 "+fout6+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout6+".png"

  system(convert_cmd)

  delete(res)
  delete(res_ice)
  delete(res_pan)
  delete(title_fin)
  delete(additional_colors)
  delete(plot)
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 8 - nodes with net flux values
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot8").and.(plot8))then  ; if plotting is turned on
print("Plot 8 - node fluxes")
fout8   = varcode+"_"+tag_1+"_pcnt_diff_6h_nodeavg_diff_200511_200703_6h_node_avg"

  wks8 = gsn_open_wks("ps" ,fout8)
  additional_colors = (/"black","gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks8,colormap,additional_colors)
  plot = new(nnode, graphic)

;;;;;;;;;;;;;
; Set resources used for all plots
;;;;;;;;;;;;

  res                             = True              ; plot mods desired
  res@gsnRightString              = ""
 ; res@gsnLeftString               = ""               ; Set this in loop
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
  res@mpMaxLatF                   = 72.              ; set the maximum latitude 
  res@mpMinLonF                   = -54.0            ; set the minimum longitude 
  res@mpMaxLonF                   = -15.0            ; set the maximum longitude 

  ; set contour information
  res@cnFillMode                 = cntype
  res@cnFillOn                   = True              ; turn on filled contours
  res@gsnSpreadColors            = True              ; use full colormap
  res@gsnSpreadColorStart        = spreadstart3      ; start at color specified for each variable above
  res@gsnSpreadColorEnd          = spreadend3        ; end at color specified above
  res@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  res@cnMinLevelValF             = cmin3             ; set min contour level specified above
  res@cnMaxLevelValF             = cmax3             ; set max contour level specified above
  res@cnLevelSpacingF            = clev3             ; set contour spacing specified above
  res@cnLinesOn                  = plotlines         ; contour lines specified above
  res@cnLineLabelsOn             = plotlines         ; line labels on specified above
  res@cnMissingValFillColor      = "gray85"          ; missing value color
  res@cnMissingValFillPattern    = 0                 ; fill in
  res@cnMissingValPerimOn        = True
  res@cnMissingValPerimColor     = "black"
  res@lbLabelBarOn               = False             ; have single label bar

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
  res_ice@cnLineLabelsOn             = False             ; line labels on specified above
  res_ice@cnLineThicknessF           = 1.5
  res_ice@tiXAxisOn                  = False
  res_ice@tiYAxisOn                  = False
  res_ice@cnLineColor                = "gray85"
 
xpos = 0
ypos = 0

do n = 0, nnode-1
  ;print("Plotting graph "+n+" ("+xpos+","+ypos+")")
  pcnt_diff_2d = pcnt_diff(n,:,:)
  seaice_1_2d = seaice_1(n,:,:)

  ; get avg difference and max absolute difference/%difference
  res@gsnRightString              = "avg |x|:"+sprintf("%5.2f",avg(abs(pcnt_diff_2d)))
  res@gsnLeftString               = "max |x|:"+sprintf("%5.2f",max(abs(pcnt_diff_2d)))
  res@gsnCenterString = "("+xpos+","+ypos+")"  ; (this changes)
  ;res@gsnCenterStringParallelPosF = 0.02 ; scoot it in just a bit as well

  cplot  = gsn_csm_contour_map(wks8,pcnt_diff_2d,res)
  cplot2 = gsn_csm_contour(wks8,seaice_1_2d,res_ice)
  overlay(cplot,cplot2)
  plot(n) = cplot

; Update xpos and ypos for next time through:
  xpos = xpos + 1
  if (xpos.eq.nx_node) then
    xpos = 0
    ypos = ypos + 1
  end if
end do

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
print("Paneling...")
title_fin = "Node "+vartitle1+" percent difference: (nodeavg - 6h)/(6h)"

res_pan                       = True ; panel resources
res_pan@txString              = title_fin
res_pan@txFontHeightF         = 0.015 ; title font height
res_pan@gsnPaperOrientation   = "landscape" ; landscape mode
res_pan@gsnMaximize           = True ; make it big
res_pan@gsnPanelLabelBar      = True ; common label bar
res_pan@lbTitleString         = var1@units
res_pan@lbTitlePosition       = "right"
res_pan@lbLabelStride         = stride3
res_pan@lbLabelFontHeightF    = 0.01
res_pan@lbTitleJust           = "CenterLeft"
res_pan@lbTitleFontHeightF    = 0.01 
res_pan@lbTitleDirection      = "Across"

gsn_panel(wks8,(/plot/),(/ny_node, nx_node/),res_pan)


  print("converting plot 8 to png")
; convert to png 
  convert_cmd = "convert -density 300 "+fout8+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout8+".png"

  system(convert_cmd)

  delete(res)
  delete(res_ice)
  delete(res_pan)
  delete(title_fin)
  delete(additional_colors)
  delete(plot)
end if

print("Completed all plots for "+varcode)
print("Good job!")
;;;;;;;;;;;;;;;;;;;;;; END script
end
