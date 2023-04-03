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
    cmin1               = 0.0
    cmax1               = 250.0
    clev1               = 25.0
    stride1             = 2
    cmin2               = 0.0
    cmax2               = 350.0
    clev2               = 35.0
    stride2             = 4
    cmin3               = 50.0
    cmax3               = 500.0
    clev3               = 50.0
    stride3             = 4
    cmin_d              = -250.0
    cmax_d              = 250.0
    clev_d              = 25.0
    stride_d            = 4
    spreadstart1        = 2                 ; start at color
    spreadend1          = 35                ; end at color
    spreadstart_d       = 37                ; start at color
    spreadend_d         = 132               ; end at color
    colormap            = "SOM_wind_table"

;    spreadstart1        = 127               ; start at color (yellow->red)
;    spreadend1          = 250               ; end at color
;    spreadstart2        = 2                 ; start at color(blue->red)
;    spreadend2          = 250               ; end at color
;    colormap            = "BlueYellowRed_mod"
  end if
  if (cmaptype.eq."shflux")then
    cmin1               = 0.0
    cmax1               = 300.0
    clev1               = 30.0
    stride1             = 2
    cmin2               = 0.0
    cmax2               = 450.0
    clev2               = 45.0
    stride2             = 2
    cmin3               = 0.0
    cmax3               = 700.0
    clev3               = 70.0
    stride3             = 2
    cmin_d              = -250.0
    cmax_d              = 250.0
    clev_d              = 25.0
    stride_d            = 4
    spreadstart1        = 2                 ; start at color
    spreadend1          = 35                ; end at color
    spreadstart_d       = 37                ; start at color
    spreadend_d         = 132               ; end at color
    colormap            = "SOM_wind_table"
  end if
  if (cmaptype.eq."wspd") then
    cmin1               = 0.0
    cmax1               = 22.0
    clev1               = 1.0
    stride1             = 2
    cmin2               = 0.0
    cmax2               = 28.0
    clev2               = 1.0
    stride2             = 4
    cmin3               = 0.0
    cmax3               = 35.0
    clev3               = 1.0
    stride3             = 4
    cmin_d              = -10.0
    cmax_d              = 10.0
    clev_d              = 0.5
    stride_d            = 4
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
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Processing all graphs for "+varcode)
; create plots!
; plot 1 - 24 panel with group 50th percentiles and differences
; plot 2 - 24 panel with group 75th percentiles and differences
; plot 3 - 24 panel with group 95th percentiles and differences
; plot 4 - 24 panel with group 50,75,95th percentiles differences
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
; Plot 1 - 50th percentile plot
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Plot 1 - Groups 50th percentile")
fout1   = varcode+"_groups_50th_percentile-"+datatitle1+"_"+datatitle2

  wks1 = gsn_open_wks("ps" ,fout1)
  additional_colors = (/"black","gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks1,colormap,additional_colors)
  plot = new(24, graphic)

  opts = res
  opts@gsnSpreadColorStart        = spreadstart1      ; start at color specified for each variable above
  opts@gsnSpreadColorEnd          = spreadend1        ; end at color specified above
  opts@cnMinLevelValF             = cmin1             ; set min contour level specified above
  opts@cnMaxLevelValF             = cmax1             ; set max contour level specified above
  opts@cnLevelSpacingF            = clev1             ; set contour spacing specified above
  opts@lbLabelStride              = stride1

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
  opts@gsnCenterString              = tag1+": Group1"
  cplot0  = gsn_csm_contour_map(wks1,var1(0,0,:,:),opts)
  plot(0) = cplot0
  delete(opts@gsnCenterString)
  ; plot1
  opts@gsnCenterString              = tag1+": Group2"
  cplot1  = gsn_csm_contour_map(wks1,var1(0,1,:,:),opts)
  plot(1) = cplot1
  delete(opts@gsnCenterString)
  ; plot2
  opts@gsnCenterString              = tag1+": Group3"
  cplot2  = gsn_csm_contour_map(wks1,var1(0,2,:,:),opts)
  plot(2) = cplot2
  delete(opts@gsnCenterString)
  ; plot3
  opts@gsnCenterString              = tag1+": Group4"
  cplot3  = gsn_csm_contour_map(wks1,var1(0,3,:,:),opts)
  plot(3) = cplot3
  delete(opts@gsnCenterString)
  ; plot4
  opts@gsnCenterString              = tag1+": Group5"
  cplot4  = gsn_csm_contour_map(wks1,var1(0,4,:,:),opts)
  plot(4) = cplot4
  delete(opts@gsnCenterString)
  ; plot5
  opts@gsnCenterString              = tag1+": Group6"
  cplot5  = gsn_csm_contour_map(wks1,var1(0,5,:,:),opts)
  plot(5) = cplot5
  delete(opts@gsnCenterString)
  ; plot6
  opts@gsnCenterString              = tag1+": Group7"
  cplot6  = gsn_csm_contour_map(wks1,var1(0,6,:,:),opts)
  plot(6) = cplot6
  delete(opts@gsnCenterString)
  ; plot7
  opts@gsnCenterString              = tag1+": Group8"
  cplot7  = gsn_csm_contour_map(wks1,var1(0,7,:,:),opts)
  plot(7) = cplot7
  delete(opts@gsnCenterString)
;;;;;;;;;;;;;
; Make plots for tag2 all groups
;;;;;;;;;;;;;
  ; plot8
  opts@gsnCenterString              = tag2+": Group1"
  cplot8  = gsn_csm_contour_map(wks1,var2(0,0,:,:),opts)
  plot(8) = cplot8
  delete(opts@gsnCenterString)
  ; plot9
  opts@gsnCenterString              = tag2+": Group2"
  cplot9  = gsn_csm_contour_map(wks1,var2(0,1,:,:),opts)
  plot(9) = cplot9
  delete(opts@gsnCenterString)
  ; plot10
  opts@gsnCenterString              = tag2+": Group3"
  cplot10  = gsn_csm_contour_map(wks1,var2(0,2,:,:),opts)
  plot(10) = cplot10
  delete(opts@gsnCenterString)
  ; plot11
  opts@gsnCenterString              = tag2+": Group4"
  cplot11  = gsn_csm_contour_map(wks1,var2(0,3,:,:),opts)
  plot(11) = cplot11
  delete(opts@gsnCenterString)
  ; plot12
  opts@gsnCenterString              = tag2+": Group5"
  cplot12  = gsn_csm_contour_map(wks1,var2(0,4,:,:),opts)
  plot(12) = cplot12
  delete(opts@gsnCenterString)
  ; plot13
  opts@gsnCenterString              = tag2+": Group6"
  cplot13  = gsn_csm_contour_map(wks1,var2(0,5,:,:),opts)
  plot(13) = cplot13
  delete(opts@gsnCenterString)
  ; plot14
  opts@gsnCenterString              = tag2+": Group7"
  cplot14  = gsn_csm_contour_map(wks1,var2(0,6,:,:),opts)
  plot(14) = cplot14
  delete(opts@gsnCenterString)
  ; plot15
  opts@gsnCenterString              = tag2+": Group8"
  cplot15  = gsn_csm_contour_map(wks1,var2(0,7,:,:),opts)
  plot(15) = cplot15
  delete(opts@gsnCenterString)
;;;;;;;;;;;;;
; Make plots for diff all groups
;;;;;;;;;;;;;
  ; plot16
  optsd@gsnCenterString              = tag1+"-"+tag2+": Group1"
  cplot16  = gsn_csm_contour_map(wks1,diff(0,0,:,:),optsd)
  plot(16) = cplot16
  delete(optsd@gsnCenterString)
  ; plot17
  optsd@gsnCenterString              = tag1+"-"+tag2+": Group2"
  cplot17  = gsn_csm_contour_map(wks1,diff(0,1,:,:),optsd)
  plot(17) = cplot17
  delete(optsd@gsnCenterString)
  ; plot18
  optsd@gsnCenterString              = tag1+"-"+tag2+": Group3"
  cplot18  = gsn_csm_contour_map(wks1,diff(0,2,:,:),optsd)
  plot(18) = cplot18
  delete(optsd@gsnCenterString)
  ; plot19
  optsd@gsnCenterString              = tag1+"-"+tag2+": Group4"
  cplot19  = gsn_csm_contour_map(wks1,diff(0,3,:,:),optsd)
  plot(19) = cplot19
  delete(optsd@gsnCenterString)
  ; plot20
  optsd@gsnCenterString              = tag1+"-"+tag2+": Group5"
  cplot20  = gsn_csm_contour_map(wks1,diff(0,4,:,:),optsd)
  plot(20) = cplot20
  delete(optsd@gsnCenterString)
  ; plot21
  optsd@gsnCenterString              = tag1+"-"+tag2+": Group6"
  cplot21  = gsn_csm_contour_map(wks1,diff(0,5,:,:),optsd)
  plot(21) = cplot21
  delete(optsd@gsnCenterString)
  ; plot22
  optsd@gsnCenterString              = tag1+"-"+tag2+": Group7"
  cplot22  = gsn_csm_contour_map(wks1,diff(0,6,:,:),optsd)
  plot(22) = cplot22
  delete(optsd@gsnCenterString)
  ; plot23
  optsd@gsnCenterString              = tag1+"-"+tag2+": Group8"
  cplot23  = gsn_csm_contour_map(wks1,diff(0,7,:,:),optsd)
  plot(23) = cplot23
  delete(optsd@gsnCenterString)

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
title_fin = vartitle1+" "+units+" group 50th percentile values"

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
  gsn_panel(wks1,(/plot/),(/6,4/),res_pan)               ; create final panel plot

  print("converting plot 1 to png")
; convert to png 
  convert_cmd = "convert -density 300 "+fout1+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 257 -depth 8 "+fout1+".png"

  system(convert_cmd)

delete(res_pan)
delete(plot)
delete(additional_colors)
delete(opts)
delete(optsd)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 2 - 75th percentile plot
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Plot 2 - Groups 75th percentile")
fout2   = varcode+"_groups_75th_percentile-"+datatitle1+"_"+datatitle2

  wks2 = gsn_open_wks("ps" ,fout2)
  additional_colors = (/"black","gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks2,colormap,additional_colors)
  plot = new(24, graphic)

  opts = res
  opts@gsnSpreadColorStart        = spreadstart1      ; start at color specified for each variable above
  opts@gsnSpreadColorEnd          = spreadend1        ; end at color specified above
  opts@cnMinLevelValF             = cmin2             ; set min contour level specified above
  opts@cnMaxLevelValF             = cmax2             ; set max contour level specified above
  opts@cnLevelSpacingF            = clev2             ; set contour spacing specified above
  opts@lbLabelStride              = stride2

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
  opts@gsnCenterString              = tag1+": Group1"
  cplot0  = gsn_csm_contour_map(wks2,var1(1,0,:,:),opts)
  plot(0) = cplot0
  delete(opts@gsnCenterString)
  ; plot1
  opts@gsnCenterString              = tag1+": Group2"
  cplot1  = gsn_csm_contour_map(wks2,var1(1,1,:,:),opts)
  plot(1) = cplot1
  delete(opts@gsnCenterString)
  ; plot2
  opts@gsnCenterString              = tag1+": Group3"
  cplot2  = gsn_csm_contour_map(wks2,var1(1,2,:,:),opts)
  plot(2) = cplot2
  delete(opts@gsnCenterString)
  ; plot3
  opts@gsnCenterString              = tag1+": Group4"
  cplot3  = gsn_csm_contour_map(wks2,var1(1,3,:,:),opts)
  plot(3) = cplot3
  delete(opts@gsnCenterString)
  ; plot4
  opts@gsnCenterString              = tag1+": Group5"
  cplot4  = gsn_csm_contour_map(wks2,var1(1,4,:,:),opts)
  plot(4) = cplot4
  delete(opts@gsnCenterString)
  ; plot5
  opts@gsnCenterString              = tag1+": Group6"
  cplot5  = gsn_csm_contour_map(wks2,var1(1,5,:,:),opts)
  plot(5) = cplot5
  delete(opts@gsnCenterString)
  ; plot6
  opts@gsnCenterString              = tag1+": Group7"
  cplot6  = gsn_csm_contour_map(wks2,var1(1,6,:,:),opts)
  plot(6) = cplot6
  delete(opts@gsnCenterString)
  ; plot7
  opts@gsnCenterString              = tag1+": Group8"
  cplot7  = gsn_csm_contour_map(wks2,var1(1,7,:,:),opts)
  plot(7) = cplot7
  delete(opts@gsnCenterString)
;;;;;;;;;;;;;
; Make plots for tag2 all groups
;;;;;;;;;;;;;
  ; plot8
  opts@gsnCenterString              = tag2+": Group1"
  cplot8  = gsn_csm_contour_map(wks2,var2(1,0,:,:),opts)
  plot(8) = cplot8
  delete(opts@gsnCenterString)
  ; plot9
  opts@gsnCenterString              = tag2+": Group2"
  cplot9  = gsn_csm_contour_map(wks2,var2(1,1,:,:),opts)
  plot(9) = cplot9
  delete(opts@gsnCenterString)
  ; plot10
  opts@gsnCenterString              = tag2+": Group3"
  cplot10  = gsn_csm_contour_map(wks2,var2(1,2,:,:),opts)
  plot(10) = cplot10
  delete(opts@gsnCenterString)
  ; plot11
  opts@gsnCenterString              = tag2+": Group4"
  cplot11  = gsn_csm_contour_map(wks2,var2(1,3,:,:),opts)
  plot(11) = cplot11
  delete(opts@gsnCenterString)
  ; plot12
  opts@gsnCenterString              = tag2+": Group5"
  cplot12  = gsn_csm_contour_map(wks2,var2(1,4,:,:),opts)
  plot(12) = cplot12
  delete(opts@gsnCenterString)
  ; plot13
  opts@gsnCenterString              = tag2+": Group6"
  cplot13  = gsn_csm_contour_map(wks2,var2(1,5,:,:),opts)
  plot(13) = cplot13
  delete(opts@gsnCenterString)
  ; plot14
  opts@gsnCenterString              = tag2+": Group7"
  cplot14  = gsn_csm_contour_map(wks2,var2(1,6,:,:),opts)
  plot(14) = cplot14
  delete(opts@gsnCenterString)
  ; plot15
  opts@gsnCenterString              = tag2+": Group8"
  cplot15  = gsn_csm_contour_map(wks2,var2(1,7,:,:),opts)
  plot(15) = cplot15
  delete(opts@gsnCenterString)
;;;;;;;;;;;;;
; Make plots for diff all groups
;;;;;;;;;;;;;
  ; plot16
  optsd@gsnCenterString              = tag1+"-"+tag2+": Group1"
  cplot16  = gsn_csm_contour_map(wks2,diff(1,0,:,:),optsd)
  plot(16) = cplot16
  delete(optsd@gsnCenterString)
  ; plot17
  optsd@gsnCenterString              = tag1+"-"+tag2+": Group2"
  cplot17  = gsn_csm_contour_map(wks2,diff(1,1,:,:),optsd)
  plot(17) = cplot17
  delete(optsd@gsnCenterString)
  ; plot18
  optsd@gsnCenterString              = tag1+"-"+tag2+": Group3"
  cplot18  = gsn_csm_contour_map(wks2,diff(1,2,:,:),optsd)
  plot(18) = cplot18
  delete(optsd@gsnCenterString)
  ; plot19
  optsd@gsnCenterString              = tag1+"-"+tag2+": Group4"
  cplot19  = gsn_csm_contour_map(wks2,diff(1,3,:,:),optsd)
  plot(19) = cplot19
  delete(optsd@gsnCenterString)
  ; plot20
  optsd@gsnCenterString              = tag1+"-"+tag2+": Group5"
  cplot20  = gsn_csm_contour_map(wks2,diff(1,4,:,:),optsd)
  plot(20) = cplot20
  delete(optsd@gsnCenterString)
  ; plot21
  optsd@gsnCenterString              = tag1+"-"+tag2+": Group6"
  cplot21  = gsn_csm_contour_map(wks2,diff(1,5,:,:),optsd)
  plot(21) = cplot21
  delete(optsd@gsnCenterString)
  ; plot22
  optsd@gsnCenterString              = tag1+"-"+tag2+": Group7"
  cplot22  = gsn_csm_contour_map(wks2,diff(1,6,:,:),optsd)
  plot(22) = cplot22
  delete(optsd@gsnCenterString)
  ; plot23
  optsd@gsnCenterString              = tag1+"-"+tag2+": Group8"
  cplot23  = gsn_csm_contour_map(wks2,diff(1,7,:,:),optsd)
  plot(23) = cplot23
  delete(optsd@gsnCenterString)

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
title_fin = vartitle1+" "+units+" group 75th percentile values"

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
  gsn_panel(wks2,(/plot/),(/6,4/),res_pan)               ; create final panel plot

  print("converting plot 2 to png")
; convert to png 
  convert_cmd = "convert -density 300 "+fout2+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 257 -depth 8 "+fout2+".png"

  system(convert_cmd)

delete(res_pan)
delete(plot)
delete(additional_colors)
delete(opts)
delete(optsd)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 3 - 95th percentile plot
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Plot 3 - Groups 95th percentile")
fout3   = varcode+"_groups_95th_percentile-"+datatitle1+"_"+datatitle2

  wks3 = gsn_open_wks("ps" ,fout3)
  additional_colors = (/"black","gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks3,colormap,additional_colors)
  plot = new(24, graphic)

  opts = res
  opts@gsnSpreadColorStart        = spreadstart1      ; start at color specified for each variable above
  opts@gsnSpreadColorEnd          = spreadend1        ; end at color specified above
  opts@cnMinLevelValF             = cmin3             ; set min contour level specified above
  opts@cnMaxLevelValF             = cmax3             ; set max contour level specified above
  opts@cnLevelSpacingF            = clev3             ; set contour spacing specified above
  opts@lbLabelStride              = stride3

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
  opts@gsnCenterString              = tag1+": Group1"
  cplot0  = gsn_csm_contour_map(wks3,var1(2,0,:,:),opts)
  plot(0) = cplot0
  delete(opts@gsnCenterString)
  ; plot1
  opts@gsnCenterString              = tag1+": Group2"
  cplot1  = gsn_csm_contour_map(wks3,var1(2,1,:,:),opts)
  plot(1) = cplot1
  delete(opts@gsnCenterString)
  ; plot2
  opts@gsnCenterString              = tag1+": Group3"
  cplot2  = gsn_csm_contour_map(wks3,var1(2,2,:,:),opts)
  plot(2) = cplot2
  delete(opts@gsnCenterString)
  ; plot3
  opts@gsnCenterString              = tag1+": Group4"
  cplot3  = gsn_csm_contour_map(wks3,var1(2,3,:,:),opts)
  plot(3) = cplot3
  delete(opts@gsnCenterString)
  ; plot4
  opts@gsnCenterString              = tag1+": Group5"
  cplot4  = gsn_csm_contour_map(wks3,var1(2,4,:,:),opts)
  plot(4) = cplot4
  delete(opts@gsnCenterString)
  ; plot5
  opts@gsnCenterString              = tag1+": Group6"
  cplot5  = gsn_csm_contour_map(wks3,var1(2,5,:,:),opts)
  plot(5) = cplot5
  delete(opts@gsnCenterString)
  ; plot6
  opts@gsnCenterString              = tag1+": Group7"
  cplot6  = gsn_csm_contour_map(wks3,var1(2,6,:,:),opts)
  plot(6) = cplot6
  delete(opts@gsnCenterString)
  ; plot7
  opts@gsnCenterString              = tag1+": Group8"
  cplot7  = gsn_csm_contour_map(wks3,var1(2,7,:,:),opts)
  plot(7) = cplot7
  delete(opts@gsnCenterString)
;;;;;;;;;;;;;
; Make plots for tag2 all groups
;;;;;;;;;;;;;
  ; plot8
  opts@gsnCenterString              = tag2+": Group1"
  cplot8  = gsn_csm_contour_map(wks3,var2(2,0,:,:),opts)
  plot(8) = cplot8
  delete(opts@gsnCenterString)
  ; plot9
  opts@gsnCenterString              = tag2+": Group2"
  cplot9  = gsn_csm_contour_map(wks3,var2(2,1,:,:),opts)
  plot(9) = cplot9
  delete(opts@gsnCenterString)
  ; plot10
  opts@gsnCenterString              = tag2+": Group3"
  cplot10  = gsn_csm_contour_map(wks3,var2(2,2,:,:),opts)
  plot(10) = cplot10
  delete(opts@gsnCenterString)
  ; plot11
  opts@gsnCenterString              = tag2+": Group4"
  cplot11  = gsn_csm_contour_map(wks3,var2(2,3,:,:),opts)
  plot(11) = cplot11
  delete(opts@gsnCenterString)
  ; plot12
  opts@gsnCenterString              = tag2+": Group5"
  cplot12  = gsn_csm_contour_map(wks3,var2(2,4,:,:),opts)
  plot(12) = cplot12
  delete(opts@gsnCenterString)
  ; plot13
  opts@gsnCenterString              = tag2+": Group6"
  cplot13  = gsn_csm_contour_map(wks3,var2(2,5,:,:),opts)
  plot(13) = cplot13
  delete(opts@gsnCenterString)
  ; plot14
  opts@gsnCenterString              = tag2+": Group7"
  cplot14  = gsn_csm_contour_map(wks3,var2(2,6,:,:),opts)
  plot(14) = cplot14
  delete(opts@gsnCenterString)
  ; plot15
  opts@gsnCenterString              = tag2+": Group8"
  cplot15  = gsn_csm_contour_map(wks3,var2(2,7,:,:),opts)
  plot(15) = cplot15
  delete(opts@gsnCenterString)
;;;;;;;;;;;;;
; Make plots for diff all groups
;;;;;;;;;;;;;
  ; plot16
  optsd@gsnCenterString              = tag1+"-"+tag2+": Group1"
  cplot16  = gsn_csm_contour_map(wks3,diff(2,0,:,:),optsd)
  plot(16) = cplot16
  delete(optsd@gsnCenterString)
  ; plot17
  optsd@gsnCenterString              = tag1+"-"+tag2+": Group2"
  cplot17  = gsn_csm_contour_map(wks3,diff(2,1,:,:),optsd)
  plot(17) = cplot17
  delete(optsd@gsnCenterString)
  ; plot18
  optsd@gsnCenterString              = tag1+"-"+tag2+": Group3"
  cplot18  = gsn_csm_contour_map(wks3,diff(2,2,:,:),optsd)
  plot(18) = cplot18
  delete(optsd@gsnCenterString)
  ; plot19
  optsd@gsnCenterString              = tag1+"-"+tag2+": Group4"
  cplot19  = gsn_csm_contour_map(wks3,diff(2,3,:,:),optsd)
  plot(19) = cplot19
  delete(optsd@gsnCenterString)
  ; plot20
  optsd@gsnCenterString              = tag1+"-"+tag2+": Group5"
  cplot20  = gsn_csm_contour_map(wks3,diff(2,4,:,:),optsd)
  plot(20) = cplot20
  delete(optsd@gsnCenterString)
  ; plot21
  optsd@gsnCenterString              = tag1+"-"+tag2+": Group6"
  cplot21  = gsn_csm_contour_map(wks3,diff(2,5,:,:),optsd)
  plot(21) = cplot21
  delete(optsd@gsnCenterString)
  ; plot22
  optsd@gsnCenterString              = tag1+"-"+tag2+": Group7"
  cplot22  = gsn_csm_contour_map(wks3,diff(2,6,:,:),optsd)
  plot(22) = cplot22
  delete(optsd@gsnCenterString)
  ; plot23
  optsd@gsnCenterString              = tag1+"-"+tag2+": Group8"
  cplot23  = gsn_csm_contour_map(wks3,diff(2,7,:,:),optsd)
  plot(23) = cplot23
  delete(optsd@gsnCenterString)

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
title_fin = vartitle1+" "+units+" group 95th percentile values"

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
  gsn_panel(wks3,(/plot/),(/6,4/),res_pan)               ; create final panel plot

  print("converting plot 3 to png")
; convert to png 
  convert_cmd = "convert -density 300 "+fout3+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 257 -depth 8 "+fout3+".png"

  system(convert_cmd)

delete(res_pan)
delete(plot)
delete(additional_colors)
delete(opts)
delete(optsd)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 4 - percentile differences
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Plot 4 - Groups percentile differences")
fout4   = varcode+"_groups_percentile_diffs-"+datatitle1+"_"+datatitle2

  wks4 = gsn_open_wks("ps" ,fout4)
  additional_colors = (/"black","gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks4,colormap,additional_colors)
  plot = new(24, graphic)

  optsd = res
  optsd@gsnSpreadColorStart       = spreadstart_d      ; start at color specified for each variable above
  optsd@gsnSpreadColorEnd         = spreadend_d        ; end at color specified above
  optsd@cnMinLevelValF            = cmin_d             ; set min contour level specified above
  optsd@cnMaxLevelValF            = cmax_d             ; set max contour level specified above
  optsd@cnLevelSpacingF           = clev_d             ; set contour spacing specified above
  optsd@lbLabelStride             = stride_d
  delete(optsd@lbLabelBarOn)
  optsd@lbLabelBarOn              = False

;;;;;;;;;;;;;
; Make plots for diff all groups
;;;;;;;;;;;;;
  ; plot0
  optsd@gsnCenterString              = "50th: Group1"
  cplot0  = gsn_csm_contour_map(wks4,diff(0,0,:,:),optsd)
  plot(0) = cplot0
  delete(optsd@gsnCenterString)
  ; plot1
  optsd@gsnCenterString              = "50th: Group2"
  cplot1  = gsn_csm_contour_map(wks4,diff(0,1,:,:),optsd)
  plot(1) = cplot1
  delete(optsd@gsnCenterString)
  ; plot2
  optsd@gsnCenterString              = "50th: Group3"
  cplot2  = gsn_csm_contour_map(wks4,diff(0,2,:,:),optsd)
  plot(2) = cplot2
  delete(optsd@gsnCenterString)
  ; plot3
  optsd@gsnCenterString              = "50th: Group4"
  cplot3  = gsn_csm_contour_map(wks4,diff(0,3,:,:),optsd)
  plot(3) = cplot3
  delete(optsd@gsnCenterString)
  ; plot4
  optsd@gsnCenterString              = "50th: Group5"
  cplot4  = gsn_csm_contour_map(wks4,diff(0,4,:,:),optsd)
  plot(4) = cplot4
  delete(optsd@gsnCenterString)
  ; plot5
  optsd@gsnCenterString              = "50th: Group6"
  cplot5  = gsn_csm_contour_map(wks4,diff(0,5,:,:),optsd)
  plot(5) = cplot5
  delete(optsd@gsnCenterString)
  ; plot6
  optsd@gsnCenterString              = "50th: Group7"
  cplot6  = gsn_csm_contour_map(wks4,diff(0,6,:,:),optsd)
  plot(6) = cplot6
  delete(optsd@gsnCenterString)
  ; plot7
  optsd@gsnCenterString              = "50th: Group8"
  cplot7  = gsn_csm_contour_map(wks4,diff(0,7,:,:),optsd)
  plot(7) = cplot7
  delete(optsd@gsnCenterString)
;;;;;;;;;;;;;
; Make plots for diff all groups
;;;;;;;;;;;;;
  ; plot8
  optsd@gsnCenterString              = "75th: Group1"
  cplot8  = gsn_csm_contour_map(wks4,diff(1,0,:,:),optsd)
  plot(8) = cplot8
  delete(optsd@gsnCenterString)
  ; plot9
  optsd@gsnCenterString              = "75th: Group2"
  cplot9  = gsn_csm_contour_map(wks4,diff(1,1,:,:),optsd)
  plot(9) = cplot9
  delete(optsd@gsnCenterString)
  ; plot10
  optsd@gsnCenterString              = "75th: Group3"
  cplot10  = gsn_csm_contour_map(wks4,diff(1,2,:,:),optsd)
  plot(10) = cplot10
  delete(optsd@gsnCenterString)
  ; plot11
  optsd@gsnCenterString              = "75th: Group4"
  cplot11  = gsn_csm_contour_map(wks4,diff(1,3,:,:),optsd)
  plot(11) = cplot11
  delete(optsd@gsnCenterString)
  ; plot12
  optsd@gsnCenterString              = "75th: Group5"
  cplot12  = gsn_csm_contour_map(wks4,diff(1,4,:,:),optsd)
  plot(12) = cplot12
  delete(optsd@gsnCenterString)
  ; plot13
  optsd@gsnCenterString              = "75th: Group6"
  cplot13  = gsn_csm_contour_map(wks4,diff(1,5,:,:),optsd)
  plot(13) = cplot13
  delete(optsd@gsnCenterString)
  ; plot14
  optsd@gsnCenterString              = "75th: Group7"
  cplot14  = gsn_csm_contour_map(wks4,diff(1,6,:,:),optsd)
  plot(14) = cplot14
  delete(optsd@gsnCenterString)
  ; plot15
  optsd@gsnCenterString              = "75th: Group8"
  cplot15  = gsn_csm_contour_map(wks4,diff(1,7,:,:),optsd)
  plot(15) = cplot15
  delete(optsd@gsnCenterString)
;;;;;;;;;;;;;
; Make plots for diff all groups
;;;;;;;;;;;;;
  ; plot16
  optsd@gsnCenterString              = "95th: Group1"
  cplot16  = gsn_csm_contour_map(wks4,diff(2,0,:,:),optsd)
  plot(16) = cplot16
  delete(optsd@gsnCenterString)
  ; plot17
  optsd@gsnCenterString              = "95th: Group2"
  cplot17  = gsn_csm_contour_map(wks4,diff(2,1,:,:),optsd)
  plot(17) = cplot17
  delete(optsd@gsnCenterString)
  ; plot18
  optsd@gsnCenterString              = "95th: Group3"
  cplot18  = gsn_csm_contour_map(wks4,diff(2,2,:,:),optsd)
  plot(18) = cplot18
  delete(optsd@gsnCenterString)
  ; plot19
  optsd@gsnCenterString              = "95th: Group4"
  cplot19  = gsn_csm_contour_map(wks4,diff(2,3,:,:),optsd)
  plot(19) = cplot19
  delete(optsd@gsnCenterString)
  ; plot20
  optsd@gsnCenterString              = "95th: Group5"
  cplot20  = gsn_csm_contour_map(wks4,diff(2,4,:,:),optsd)
  plot(20) = cplot20
  delete(optsd@gsnCenterString)
  ; plot21
  optsd@gsnCenterString              = "95th: Group6"
  cplot21  = gsn_csm_contour_map(wks4,diff(2,5,:,:),optsd)
  plot(21) = cplot21
  delete(optsd@gsnCenterString)
  ; plot22
  optsd@gsnCenterString              = "95th: Group7"
  cplot22  = gsn_csm_contour_map(wks4,diff(2,6,:,:),optsd)
  plot(22) = cplot22
  delete(optsd@gsnCenterString)
  ; plot23
  optsd@gsnCenterString              = "95th: Group8"
  cplot23  = gsn_csm_contour_map(wks4,diff(2,7,:,:),optsd)
  plot(23) = cplot23
  delete(optsd@gsnCenterString)

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
title_fin = vartitle1+" group percentile differences ("+tag1+"-"+tag2+")"

  res_pan                            = True
  res_pan@txString                   = title_fin        ; main title
  res_pan@txFontHeightF              = 0.012
  res_pan@gsnPaperOrientation        = "landscape"      ; landscape mode
  res_pan@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  res_pan@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  res_pan@gsnPanelScalePlotIndex     = 1
  res_pan@gsnMaximize                = True	       ; fill the page
  res_pan@gsnPanelLabelBar           = True
  res_pan@lbTitleString              = units
  res_pan@lbTitlePosition            = "right"
  res_pan@lbLabelStride              = stride_d
  res_pan@lbLabelFontHeightF         = 0.01
  res_pan@lbTitleJust                = "CenterLeft"
  res_pan@lbTitleFontHeightF         = 0.01
  res_pan@lbTitleDirection           = "Across"
  gsn_panel(wks4,(/plot/),(/6,4/),res_pan)               ; create final panel plot

  print("converting plot 4 to png")
; convert to png 
  convert_cmd = "convert -density 300 "+fout4+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 257 -depth 8 "+fout4+".png"

  system(convert_cmd)

delete(res_pan)
delete(plot)
delete(additional_colors)
delete(optsd)


print("Completed all percentile plots for "+varcode)
print("Good job!")
;;;;;;;;;;;;;;;;;;;;;; END script
end
