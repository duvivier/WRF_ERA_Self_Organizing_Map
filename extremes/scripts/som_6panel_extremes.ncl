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
  datatitle3 = "era_i_200511_200703_6h"
  ; set input/output directories
  dir1 = "/data3/duvivier/SOM/analysis/extremes/"
  outdir = "./"
; ******************************************************
print("Processing all graphs for "+varcode)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; BEGIN SCRIPT
; get tag to let us know if it needs interpolation
title1_ch  = stringtocharacter(datatitle1)
title1_sub = title1_ch(0:4)
tag_1 = chartostring(title1_sub)
title2_ch  = stringtocharacter(datatitle2)
title2_sub = title2_ch(0:4)
tag_2 = chartostring(title2_sub)
title3_ch  = stringtocharacter(datatitle3)
title3_sub = title3_ch(0:4)
tag_3 = chartostring(title3_sub)

;;;;;;;;;;
; Set information for variable
;;;;;;;;;;
if (varcode.eq."LH") then
  vartitle1 = "COARE Latent Heat Flux at surface"
  invar1 = "LHFlx_pcnt"
  cmaptype = "lhflux"
end if
if (varcode.eq."SH") then
  vartitle1 = "COARE Sensible Heat Flux at surface"
  invar1 = "SHFlx_pcnt"
  cmaptype = "shflux"
end if
if (varcode.eq."U10")then
  vartitle1 = "Windspeed at 10m"
  invar1 = "ws_10m_pcnt"
  cmaptype = "wspd"
end if

; percentile names
percentiles = (/"10", "20" ,"30", "40", "50", "60", "70", "80", "90", "92", "94", "95", "96", "98", "100"/)
dim_pcnt = dimsizes(percentiles)

; Set the contour interval for each input variable   
; set contour limits manually:
  if (cmaptype.eq."lhflux")then
    cmin1               = 0.0
    cmax1               = 500.0
    clev1               = 25.0
    stride1             = 2
    cmin2               = -300.0
    cmax2               = 300.0
    clev2               = 20.0
    stride2             = 3
    spreadstart1        = 127               ; start at color (yellow->red)
    spreadend1          = 250               ; end at color
    spreadstart2        = 2                 ; start at color(blue->red)
    spreadend2          = 250               ; end at color
    colormap            = "BlueYellowRed_mod"
  end if
  if (cmaptype.eq."shflux")then
    cmin1               = 0.0
    cmax1               = 600.0
    clev1               = 30.0
    stride1             = 2
    cmin2               = -300.0
    cmax2               = 300.0
    clev2               = 20.0
    stride2             = 3
    spreadstart1        = 127               ; start at color (yellow->red)
    spreadend1          = 250               ; end at color
    spreadstart2        = 2                 ; start at color(blue->red)
    spreadend2          = 250               ; end at color
    colormap            = "BlueYellowRed_mod"
  end if
  if (cmaptype.eq."wspd") then
    cmin1               = 5.0
    cmax1               = 40.0
    clev1               = 1.0
    stride1             = 5
    cmin2               = -20.0
    cmax2               = 20.0
    clev2               = 1.0
    stride2             = 4
    spreadstart1        = 2                 ; start at color
    spreadend1          = 35                ; end at color
    spreadstart2        = 37                ; start at color
    spreadend2          = 141               ; end at color
    colormap            = "SOM_wind_table"
  end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Data Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;
; Load all percentiles
;;;;;;;;;;
  dum = new((/1/),"float")
  fill = dum@_FillValue

; net avgs
  fname1 = "net_"+datatitle1+"-extremes-sst"
  fname2 = "net_"+datatitle2+"-extremes-sst"
  fname3 = "net_"+datatitle3+"-extremes-sst"

  f1 = addfile(dir1+fname1+".nc","r")
  f2 = addfile(dir1+fname2+".nc","r")
  f3 = addfile(dir1+fname3+".nc","r")

  ; load lat/lon
  lat2d_1 = f1->lat
  lon2d_1 = f1->lon
  lat2d_2 = f2->lat
  lon2d_2 = f2->lon
  z_sfc_1 = f1->Z_sfc
  z_sfc_2 = f2->Z_sfc

  dims = dimsizes(lat2d_1)     ; get lat/lon dimensions
  n_sn_1 = dims(0)              ; get south/north points
  n_we_1 = dims(1)              ; get west/east points
  n_tot_1 = n_sn_1*n_we_1              ; get total number of points in high res domain
  delete(dims)

  ; get weights and indicies for regridding (WRF50 and era weightings are identical)
  weightin = addfile("/data3/duvivier/SOM/DATA/weightings_WRF50_to_WRF10.nc","r")
  interp_ind = weightin->interp_ind
  interp_wgt = weightin->interp_wgt

  ; load the variables
  var1 = f1->$invar1$
  var1@_FillValue = fill
  var1@units = "W m-2"
  var2 = f2->$invar1$
  var2@_FillValue = fill
  var3 = f3->$invar1$
  var3@_FillValue = fill

  seaice_1_avg  = f1->SeaIce_avg(:,:)
  seaice_1_avg@_FillValue = fill
  seaice_2_avg  = f2->SeaIce_avg(:,:)
  seaice_2_avg@_FillValue = fill
  seaice_3_avg  = f2->SeaIce_avg(:,:)
  seaice_3_avg@_FillValue = fill

print("Loaded "+ varcode+" percentiles from all files")
;;;;;;;;;;
; Interpolate to WRF10 size (if needed)
;;;;;;;;;;
  print("Interpolating between resolutions")
  ; Make arrays we'll need in interpolation
  var2_new = new((/dim_pcnt,n_sn_1,n_we_1/),"float") 
  var2_tmp_1d  = new((/n_tot_1/),"float")
  seaice_2_avg_new = new((/n_sn_1,n_we_1/),"float") 
  seaice_2_avg_tmp_1d  = new((/n_tot_1/),"float")
  var3_new = new((/dim_pcnt,n_sn_1,n_we_1/),"float") 
  var3_tmp_1d  = new((/n_tot_1/),"float")
  seaice_3_avg_new = new((/n_sn_1,n_we_1/),"float") 
  seaice_3_avg_tmp_1d  = new((/n_tot_1/),"float")
  
do p = 0, dim_pcnt -1
  var2_1d = ndtooned(var2(p,:,:))
  var3_1d = ndtooned(var3(p,:,:))
  if (p .eq. 0) then
    seaice_2_avg_1d = ndtooned(seaice_2_avg(:,:))
    seaice_3_avg_1d = ndtooned(seaice_3_avg(:,:))
  end if
  do i = 0, n_tot_1 - 1
    indices_all = interp_ind(i,:)
    n_indices = num(.not.ismissing(indices_all))
    if (n_indices .ne. 0.0) then
      indices = indices_all(0:n_indices-1)
      weight_all = interp_wgt(i,:)
      weight = weight_all(0:n_indices-1)
      var2_tmp_1d(i) = sum(var2_1d(indices)*weight/sum(weight))
      var3_tmp_1d(i) = sum(var3_1d(indices)*weight/sum(weight))
      if (p.eq.0)then
        seaice_2_avg_tmp_1d(i)=sum(seaice_2_avg_1d(indices)*weight/sum(weight))
        seaice_3_avg_tmp_1d(i)=sum(seaice_3_avg_1d(indices)*weight/sum(weight))
      end if
      delete(indices)
      delete(weight)
    end if
  end do
  ; redimensionalize
  var2_new(p,:,:) = onedtond(var2_tmp_1d,(/n_sn_1,n_we_1/))
  var3_new(p,:,:) = onedtond(var3_tmp_1d,(/n_sn_1,n_we_1/))
  if (p .eq. 0) then
    seaice_2_avg_new(:,:) = onedtond(seaice_2_avg_tmp_1d,(/n_sn_1,n_we_1/))
    seaice_3_avg_new(:,:) = onedtond(seaice_3_avg_tmp_1d,(/n_sn_1,n_we_1/))
  end if
  print("Finished percentile: "+percentiles(p))
end do
  
  delete(var2)
  var2 = var2_new
  delete(var2_new)
  copy_VarMeta(var1, var2)
  var2@_FillValue = fill
  delete(seaice_2_avg)
  seaice_2_avg = seaice_2_avg_new
  delete(seaice_2_avg_new)
  copy_VarMeta(seaice_1_avg, seaice_2_avg)
  seaice_2_avg@_FillValue = fill
  delete(var3)
  var3 = var3_new
  delete(var3_new)
  copy_VarMeta(var1, var3)
  var3@_FillValue = fill
  delete(seaice_3_avg)
  seaice_3_avg = seaice_3_avg_new
  delete(seaice_3_avg_new)
  copy_VarMeta(seaice_1_avg, seaice_3_avg)
  seaice_3_avg@_FillValue = fill

  ; mask terrain and lat/lons - focus on S. Greenland region ocean
  p = 0
  do p = 0, dim_pcnt-1
    var1(p,:,:) = where(z_sfc_1.lt.10. .and. lat2d_1.gt.55. .and. lat2d_1.lt.71. .and. lon2d_1.lt.-19. .and. lon2d_1.gt.-55., var1(p,:,:), var1@_FillValue)
    var2(p,:,:) = where(z_sfc_1.lt.10. .and. lat2d_1.gt.55. .and. lat2d_1.lt.71. .and. lon2d_1.lt.-19. .and. lon2d_1.gt.-55., var2(p,:,:), var2@_FillValue)
    var3(p,:,:) = where(z_sfc_1.lt.10. .and. lat2d_1.gt.55. .and. lat2d_1.lt.71. .and. lon2d_1.lt.-19. .and. lon2d_1.gt.-55., var3(p,:,:), var3@_FillValue)
  end do
  seaice_1_avg = where(z_sfc_1.lt.10. .and. lat2d_1.gt.55. .and. lat2d_1.lt.71. .and. lon2d_1.lt.-19. .and. lon2d_1.gt.-55., seaice_1_avg, seaice_1_avg@_FillValue)
  seaice_2_avg = where(z_sfc_1.lt.10. .and. lat2d_1.gt.55. .and. lat2d_1.lt.71. .and. lon2d_1.lt.-19. .and. lon2d_1.gt.-55., seaice_2_avg, seaice_2_avg@_FillValue)
  seaice_3_avg = where(z_sfc_1.lt.10. .and. lat2d_1.gt.55. .and. lat2d_1.lt.71. .and. lon2d_1.lt.-19. .and. lon2d_1.gt.-55., seaice_3_avg, seaice_3_avg@_FillValue)

;;;;;;;;;;
;  Calculate differences
;;;;;;;;;;
  diff12 = var1-var2
  diff13 = var1-var3

;;;;;;;;;;
;  Assign lat/lon data
;;;;;;;;;;
  var1@lat2d = lat2d_1
  var1@lon2d = lon2d_1
  var2@lat2d = lat2d_2
  var2@lon2d = lon2d_2
  var3@lat2d = lat2d_2
  var3@lon2d = lon2d_2
  diff12@lat2d = lat2d_2
  diff12@lon2d = lon2d_2
  diff13@lat2d = lat2d_2
  diff13@lon2d = lon2d_2
  seaice_1_avg@lat2d = lat2d_1
  seaice_1_avg@lon2d = lon2d_1
  seaice_2_avg@lat2d = lat2d_1
  seaice_2_avg@lon2d = lon2d_1
  seaice_3_avg@lat2d = lat2d_1
  seaice_3_avg@lon2d = lon2d_1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

;;;;;;;;;;;;;
; Set resources for seaice overlays
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

; set resources for sea ice overlay
  res_ice2                            = res_ice               ; reset options
  res_ice2@cnMinLevelValF             = 0.                ; set min contour level specified above
  res_ice2@cnMaxLevelValF             = 0.85              ; set max contour level specified above
  res_ice2@cnLevelSpacingF            = 0.85              ; set contour spacing specified above
  res_ice2@cnLineColor                = "gray85"
  res_ice2@cnLineThicknessF           = 2.0
  res_ice2@cnLineDashPattern          = 6

;;;;;;;;;;;;
; loop through percentiles
;;;;;;;;;;;;
do p = 0, dim_pcnt -1
  print("Plotting "+varcode+" for percentile: "+percentiles(p))
  fout1   = varcode+"_"+percentiles(p)+"_pcnt_200511_200703_6h"
  wks1 = gsn_open_wks("ps" ,fout1)
  additional_colors = (/"gray85"/)
  gsn_merge_colormaps(wks1,colormap,additional_colors)
  plot = new(6, graphic)

  ; subset data
  var1_sub = var1(p,:,:)
  var2_sub = var2(p,:,:)
  var3_sub = var3(p,:,:)
  diff12_sub = diff12(p,:,:)
  diff13_sub = diff13(p,:,:)

  ; find levels for plots
  var1_sub@lat2d = lat2d_1
  var1_sub@lon2d = lon2d_1
  copy_VarMeta(var1_sub, var2_sub)
  copy_VarMeta(var1_sub, var3_sub)
  copy_VarMeta(var1_sub, diff12_sub)
  copy_VarMeta(var1_sub, diff13_sub)

  ; set "normal plot" resources
  opts                            = res               ; reset options
  opts@gsnSpreadColorStart        = spreadstart1      ; start at color specified for each variable above
  opts@gsnSpreadColorEnd          = spreadend1        ; end at color specified above
  opts@cnMinLevelValF             = cmin1             ; set min contour level specified above
  opts@cnMaxLevelValF             = cmax1             ; set max contour level specified above
  opts@cnLevelSpacingF            = clev1             ; set contour spacing specified above
  opts@lbLabelStride              = stride1

  opts_d                          = res
  opts_d@gsnSpreadColorStart      = spreadstart2
  opts_d@gsnSpreadColorEnd        = spreadend2
  opts_d@cnMinLevelValF           = cmin2             ; set min contour level specified above
  opts_d@cnMaxLevelValF           = cmax2             ; set max contour level specified above
  opts_d@cnLevelSpacingF          = clev2             ; set contour spacing specified above
  opts_d@lbLabelStride            = stride2

; plot 1 - wrf10
  title = tag_1
  opts@tiMainString               = title            ; title string specified from cshell
  cplot0  = gsn_csm_contour_map(wks1,var1_sub,opts)
  if (varcode .eq. "LH" .or. varcode .eq. "SH")then
    cplot0b = gsn_csm_contour(wks1,seaice_1_avg,res_ice)
    overlay(cplot0,cplot0b)
    cplot0c = gsn_csm_contour(wks1,seaice_1_avg,res_ice2)
    overlay(cplot0,cplot0c)
  end if
  plot(0) = cplot0
  delete(title)

; plot2 - wrf50
  title = tag_2
  opts@tiMainString               = title            ; title string specified from cshell
  cplot1  = gsn_csm_contour_map(wks1,var2_sub,opts)
  if (varcode .eq. "LH" .or. varcode .eq. "SH")then
    cplot1b = gsn_csm_contour(wks1,seaice_2_avg,res_ice)
    overlay(cplot1,cplot1b)
    cplot1c = gsn_csm_contour(wks1,seaice_2_avg,res_ice2)
    overlay(cplot1,cplot1c)
  end if
  plot(1) = cplot1
  delete(title)

; plot3 - era_i
  title = tag_3
  opts@tiMainString               = title            ; title string specified from cshell
  cplot2  = gsn_csm_contour_map(wks1,var3_sub,opts)
  if (varcode .eq. "LH" .or. varcode .eq. "SH")then
    cplot2b = gsn_csm_contour(wks1,seaice_3_avg,res_ice)
    overlay(cplot2,cplot2b)
    cplot2c = gsn_csm_contour(wks1,seaice_3_avg,res_ice2)
    overlay(cplot2,cplot2c)
  end if
  plot(2) = cplot2
  delete(title)

; plot5 - wrf10-wrf50
  title = tag_1+"-"+tag_2
  opts_d@tiMainString               = title            ; title string specified from cshell
  cplot4  = gsn_csm_contour_map(wks1,diff12_sub,opts_d)
  plot(4) = cplot4
  delete(title)

; plot6 - wrf10 - era_i
  title = tag_1+"-"+tag_3
  opts_d@tiMainString               = title            ; title string specified from cshell
  cplot5  = gsn_csm_contour_map(wks1,diff13_sub,opts_d)
  plot(5) = cplot5
  delete(title)

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
title_fin = vartitle1+ " "+percentiles(p)+ " percentile: "+var1@units

  res_pan                            = True
  res_pan@txString                   = title_fin        ; main title
  res_pan@txFontHeightF              = 0.017
  res_pan@gsnPaperOrientation        = "landscape"      ; landscape mode
  res_pan@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  res_pan@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  res_pan@gsnPanelScalePlotIndex     = 1
  res_pan@gsnMaximize                = True	       ; fill the page
;  res_pan@gsnPanelLabelBar           = True
;  res_pan@lbTitleString              = var3_net@units
;  res_pan@lbTitlePosition            = "right"
;  res_pan@lbLabelStride              = stride1
;  res_pan@lbLabelFontHeightF         = 0.01
;  res_pan@lbTitleJust                = "CenterLeft"
;  res_pan@lbTitleFontHeightF         = 0.01
;  res_pan@lbTitleDirection           = "Across"
  
  gsn_panel(wks1,(/plot/),(/2,3/),res_pan)               ; create final panel plot

; Finally - make plot
  print("converting plot to png")
  convert_cmd = "convert -density 300 "+fout1+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout1+".png"
  system(convert_cmd)

  delete(res_pan)
  delete(title_fin)
  delete(additional_colors)
  delete(plot)
  delete(var1_sub)
  delete(var2_sub)
  delete(var3_sub)
  delete(diff12_sub)
  delete(diff13_sub)
end do

print("Completed all plots for "+varcode)
print("Good job!")
;;;;;;;;;;;;;;;;;;;;;; END script
end
