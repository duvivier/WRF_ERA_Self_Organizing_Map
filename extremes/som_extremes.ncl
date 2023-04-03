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
;  datatitle1  = "wrf50_200511_200703_6h"
;  varcode = "LH_nodeavgs"
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
plot1  = True ; plot 1 - Histogram of net avg
plot2  = True ; plot 2 - Histogram of node avgs
plot3  = True ; plot 3 - Nodes with maximum value listed
plot4  = True ; plot 4 - Nodes with 95 percentile value listed
plot5  = True ; plot 5 - Nodes with mean value listed
plot6  = True ; plot 6 - Nodes with median value listed
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; BEGIN SCRIPT
print("Calculating extremes analysis for: "+varcode)

; get tag to let us know if it needs interpolation
title1_ch  = stringtocharacter(datatitle1)
title1_sub = title1_ch(0:4)
tag_1 = chartostring(title1_sub)

; Calculate node counts and frequencies for comparison of interest
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
if (varcode.eq."U10") then
  vartitle1 = "Wind speed at 10m"
  invar1 = "wspd_10m_avg"
  type = "1" 
  cmaptype = "wind"
  stride1 = 4.0
  fudgpc = 0.25
end if
if (varcode.eq."Tgrad") then
  vartitle1 = "Temperature gradient (sfc-2m)"
  invar1 = "T_grad_avg"
  type = "1" 
  cmaptype = "temperature"
  stride1 = 2.0
  fudgpc = 0.2
end if
if (varcode.eq."qgrad") then
  vartitle1 = "Mixing Ratio gradient (sfc-2m)"
  invar1 = "q_grad_avg"
  type = "1" 
  cmaptype = "moisture"
  stride1 = 4.0
  fudgpc = 0.3
end if
if (varcode.eq."SH") then
  vartitle1 = "Sensible Heat Flux at surface"
  invar1 = "SHFlx_avg"
  type = "1"
  cmaptype = "shflx"
  stride1 = 2.0
  fudgpc = 0.15
end if
if (varcode.eq."LH") then
  vartitle1 = "Latent Heat Flux at surface"
  invar1 = "LHFlx_avg"
  type = "1" 
  cmaptype = "lhflx"
  stride1 = 2.0
  fudgpc = 0.15
end if
if (varcode.eq."TurbFlx") then
  vartitle1 = "Total Turbulent Flux at surface"
  invar1 = "Turb_net_avg"
  type = "1"
  cmaptype = "netflx"
  stride1 = 4.0
  fudgpc = 0.15
end if
if (varcode.eq."U_eta0") then
  vartitle1 = "Wind speed at eta0"
  invar1 = "wspd_eta0_avg"
  type = "1" 
  cmaptype = "wind"
  stride1 = 4.0
  fudgpc = 0.25
end if
if (varcode.eq."Tgrad_eta0") then
  vartitle1 = "Temperature gradient (sfc-eta0)"
  invar1 = "T_grad_eta0_avg"
  type = "1" 
  cmaptype = "temperature"
  fudgpc = 0.1
end if
if (varcode.eq."qgrad_eta0") then
  vartitle1 = "Mixing Ratio gradient (sfc-eta0)"
  invar1 = "q_grad_eta0_avg"
  type = "1" 
  cmaptype = "moisture"
  fudgpc = 0.1
end if
if (varcode.eq."SH_eta0") then
  vartitle1 = "Sensible Heat Flux at surface"
  invar1 = "SHFlx_eta0_avg"
  type = "1" 
  cmaptype = "shflx"
  stride1 = 2.0
  fudgpc = 0.15
end if
if (varcode.eq."LH_eta0") then
  vartitle1 = "Latent Heat Flux at surface"
  invar1 = "LHFlx_eta0_avg"
  type = "1"
  cmaptype = "lhflx" 
  stride1 = 2.0
  fudgpc = 0.15
end if
if (varcode.eq."TurbFlx_eta0") then
  vartitle1 = "Total Turbulent Flux at surface"
  invar1 = "Turb_net_eta0_avg"
  type = "1" 
  cmaptype = "netflx"
  stride1 = 4.0 
  fudgpc = 0.15
end if
if (varcode.eq."SH_nodeavgs") then
  vartitle1 = "Sensible Heat Flux at surface"
  invar1 = "SHFlx_avg"
  type = "2" 
  cmaptype = "shflx"
  stride1 = 2.0
  fudgpc = 0.15
end if
if (varcode.eq."LH_nodeavgs") then
  vartitle1 = "Latent Heat Flux at surface"
  invar1 = "LHFlx_avg"
  type = "2" 
  cmaptype = "lhflx"
  stride1 = 2.0
  fudgpc = 0.15
end if
if (varcode.eq."SH_native") then
  vartitle1 = "Sensible Heat Flux at surface"
  invar1 = "SHFlx_avg"
  type = "3" 
  cmaptype = "shflx"
  stride1 = 2.0
  fudgpc = 0.15
end if
if (varcode.eq."LH_native") then
  vartitle1 = "Latent Heat Flux at surface"
  invar1 = "LHFlx_avg"
  type = "3" 
  cmaptype = "lhflx"
  stride1 = 2.0
  fudgpc = 0.15
end if

; Set the contour interval for each input variable   
; set contour limits manually:
  if (cmaptype.eq."wind")then
    levels = (/0.0,1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0,16.0,17.0,18.0,19.0,20.0,21.0,22.0,23.0,24.0,25.0,26.0,27.0,28.0,29.0,30.0/)
    levels_net = (/0.0,1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0,16.0/)
    colormap            = "SOM_winds_histogram"
  end if
  if (cmaptype.eq."temperature")then
    levels = (/-5.0,-4.5,-4.0,-3.5,-3.0,-2.5,-2.0,-1.5,-1.0,-0.5,0.0,0.5,1.0,1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5,7.0,7.5,8.0,8.5,9.0,9.5,10.0,10.5,11.0/)
    levels_net = (/-6.0,-5.5,-5.0,-4.5,-4.0,-3.5,-3.0,-2.5,-2.0,-1.5,-1.0,-0.5,0.0,0.5,1.0,1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5,7.0/)
    colormap            = "BlueYellowRed_mod"
  end if
  if (cmaptype.eq."moisture")then
    levels = (/-1.25,-1.0,-0.75,-0.5,-0.25,0.0,0.25,0.5,0.75,1.0,1.25,1.5,1.75,2.0,2.25,2.5,2.75,3.0,3.25,3.5/)
    levels_net = (/-0.5,-0.25,0.0,0.25,0.5,0.75,1.0,1.25,1.5,1.75,2.0,2.25,2.5/)
    colormap            = "BrownBlue"
  end if
  if (cmaptype.eq."lhflx")then
     levels = (/-175.0,-150.0,-125.0,-100.,-75.,-50.,-25.,0.0,25.0,50.0,75.0,100.0,125.0,150.0,175.0,200.0,225.0,250.0,275.0,300.0/)
     levels_net = (/-75.0,-50.,-25.,0.0,25.0,50.0,75.0,100.0,125.0,150.0,175.0,200.0/) 
     colormap            = "BlueYellowRed_mod"
  end if
  if (cmaptype.eq."shflx")then
     levels = (/-175.0,-150.0,-125.0,-100.,-75.,-50.,-25.,0.0,25.0,50.0,75.0,100.0,125.0,150.0,175.0,200.0,225.0,250.0,275.0,300.0/)
     levels_net = (/-75.0,-50.,-25.,0.0,25.0,50.0,75.0,100.0,125.0,150.0,175.0,200.0/)  
     colormap            = "BlueYellowRed_mod"
  end if
  if (cmaptype.eq."netflx")then
     levels = (/-175.0,-150.0,-125.0,-100.,-75.,-50.,-25.,0.0,25.0,50.0,75.0,100.0,125.0,150.0,175.0,200.0,225.0,250.0,275.0,300.0,325.0,350.0,375.0,400.0,425.0,450.0,475.0,500.0,525.0,550.0,575.0,600.0 /)
     levels_net = (/-175.0,-150.0,-125.0,-100.0,-75.0,0-50.0,-25.0,0.0,25.0,50.0,75.0,100.0,125.0,150.0,175.0,200.0,225.0,250.0,275.0,300.0,325.0,350.0/) 
     colormap            = "BlueYellowRed_mod"
  end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Load in Data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Load in lat/lon to get information for domain
  fname0 = "node_0x_0y_"+datatitle1
  if (type .eq. "1")then
    dir1 = "/data3/duvivier/SOM/analysis/flux_compare/node_avgs/fluxes/"
    f0 = addfile(dir1 + fname0 + "-fluxes.nc","r")
  end if
  if (type .eq. "2")then
    dir1 = "/data3/duvivier/SOM/analysis/flux_compare/node_avgs/fluxes_fromnodeavgs/"
    f0 = addfile(dir1 + fname0 + "-fluxes_fromnodeavgs.nc","r")
  end if
  if (type .eq. "3")then
    dir1 = "/data3/duvivier/SOM/training/som_"+nx_input+ny_input+"/master/node_avgs/"
    f0 = addfile(dir1 + fname0 + ".nc","r")
  end if

  lat2d = f0->lat
  lon2d = f0->lon
  z_sfc = f0->Z_sfc
  delete(fname0)
  delete(f0)

  dims = dimsizes(lat2d)     ; get lat/lon dimensions
  n_sn = dims(0)              ; get south/north points
  n_we = dims(1)              ; get west/east points
  n_tot = n_sn*n_we              ; get total number of points in high res domain
  delete(dims)

;;;;;;;;;;
; Load in node avg files
;;;;;;;;;;
  ; create all-node array for node average variable
  var1 = new((/nnode,n_sn,n_we/),"float")
  fill = var1@_FillValue

n = 0
; loop through each node
do y = 0, ny_node - 1
 do x = 0, nx_node - 1
  print("node: "+x+","+y)

  fname1 = "node_"+x+"x_"+y+"y_"+datatitle1
  if (type .eq. "1")then
    f1 = addfile(dir1 + fname1 + "-fluxes.nc","r")
  end if
  if (type .eq. "2")then
    f1 = addfile(dir1 + fname1 + "-fluxes_fromnodeavgs.nc","r")
  end if
  if (type .eq. "3")then
    f1 = addfile(dir1 + fname1 + ".nc","r")
  end if

  ; Load data
  var1(n,:,:) = f1->$invar1$(south_north|:,west_east|:)
  ; mask terrain - focus on ocean
  var1(n,:,:) = where(z_sfc .lt. 500., var1(n,:,:), var1@_FillValue)
  ; mask lat/lons - focus on S. Greenland region
  var1(n,:,:) = where(lat2d .gt. 55. .and. lat2d .lt. 71. .and. lon2d .lt. -19. .and. lon2d .gt. -55., var1(n,:,:), var1@_FillValue)

  ; delete vars to use in next loop
  delete(fname1)
  delete(f1)
  n = n+1
 end do
end do
delete(n)

;;;;;;;;;;
; Load in net avg files
;;;;;;;;;;
  fname1 = "net_avg_"+datatitle1
  if (type .eq. "1")then
    f1 = addfile(dir1 + fname1 + "-fluxes.nc","r")
  end if
  if (type .eq. "2")then
    f1 = addfile(dir1 + fname1 + "-fluxes_fromnodeavgs.nc","r")
  end if
  if (type .eq. "3")then
    f1 = addfile(dir1 + fname1 + ".nc","r")
  end if

  ; Load data
  var1_net = f1->$invar1$
  var1_net@_FillValue = fill

  ; mask terrain - focus on ocean
  var1_net(:,:) = where(z_sfc .lt. 500., var1_net(:,:), var1_net@_FillValue)

  ; mask lat/lons - focus on S. Greenland region
  var1_net(:,:) = where(lat2d .gt. 55. .and. lat2d .lt. 71. .and. lon2d .lt. -19. .and. lon2d .gt. -55., var1_net(:,:), var1_net@_FillValue)

print("Loaded "+varcode)

; prints together the variable title (set above for each type of data) with title1 (defined in cshell as the wrf or met info) and the max and min values
print(vartitle1+" node avg min: "+min(var1)+"  max: "+max(var1)) 
print(vartitle1+" net avg min: "+min(var1_net)+"  max: "+max(var1_net)) 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Do calculations of statistics
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  print("Getting extreme stats for nodes and net")
;;;;;;;;;;
; node avgs
;;;;;;;;;;
  ; create all-node array for node average variable
  maxima  = new((/nnode/),"float")
  pcnt95  = new((/nnode/),"float")
  mean    = new((/nnode/),"float")
  median  = new((/nnode/),"float")

n = 0
; loop through each node
do y = 0, ny_node - 1
 do x = 0, nx_node - 1

  dum = var1(n,:,:)
  dum_1d = ndtooned(dum)
  delete(dum)
  dims_tot = dimsizes(dum_1d)

  ; get info for percentile
  qsort(dum_1d)                       ; sort small to big
  inds = ind(.not.ismissing(dum_1d))  ; get inds where not missing
  loc = ((95./100.)*(dimsizes(inds)-1))+0.5         ; get 95th% value (add 0.5 to be sure)
  loc_int = round(loc,3)              ; get integer of location
  final_loc = inds(0)+loc_int         ; actual location in array considering the missing values

  ; get statistical information
  maxima(n)  = max(dum_1d)
  pcnt95(n)  = dum_1d(final_loc)
  mean(n)    = avg(dum_1d)
  median(n)  = dim_median(dum_1d)

  delete(dum_1d)
  n = n+1
 end do
end do
delete(n)

;;;;;;;;;;
; net avg
;;;;;;;;;;
  ; create all-node array for node average variable
  maxima_net  = new((/nnode/),"float")
  pcnt95_net  = new((/nnode/),"float")
  mean_net    = new((/nnode/),"float")
  median_net  = new((/nnode/),"float")

  ; Get info about dimensions of data
  dum = var1_net(:,:)
  dum_1d = ndtooned(dum)
  delete(dum)
  dims_tot = dimsizes(dum_1d)

  ; get info for percentile
  qsort(dum_1d)                       ; sort small to big
  inds = ind(.not.ismissing(dum_1d))  ; get inds where not missing
  loc = ((95./100.)*(dimsizes(inds)-1))+0.5         ; get 95th% value (add 0.5 to be sure)
  loc_int = round(loc,3)              ; get integer of location
  final_loc = inds(0)+loc_int         ; actual location in array considering the missing values

  ; get statistical information
  maxima_net  = max(dum_1d)
  pcnt95_net  = dum_1d(final_loc)
  mean_net    = avg(dum_1d)
  median_net  = dim_median(dum_1d)
  delete(dum_1d)
  print("Done getting extreme stats for nodes and net")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Processing all graphs for "+varcode)
; create plots!
; plot 1 - Histogram of net avg
; plot 2 - Histogram of node avgs
; plot 3 - Nodes with maximum value listed
; plot 4 - Nodes with 95 percentile value listed
; plot 5 - Nodes with mean value listed
; plot 6 - Nodes with median value listed
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; set outdir and fout names
outdir = "./"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 1 - Net avg histogram and statistics
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot1").and.(plot1))then  ; if plotting is turned on
  print("Plot 1 - Net avg histogram")
  fout1 = varcode+"_net_avg_histogram_stats_"+datatitle1

  wks1 = gsn_open_wks("ps",fout1)
  gsn_define_colormap(wks1,colormap)

  res                                             = True
  res@gsnHistogramClassIntervals                  = levels_net         ; bin levels
  res@gsnHistogramComputePercentagesNoMissing     = True
  res@tiMainString                                = vartitle1+": net avg distribution - "+datatitle1
  res@tiXAxisString                               = var1@units
  res@tiYAxisString                               = ""
  res@tiMainFontThicknessF                        = 2
  res@gsnHistogramPercentSign                     = True
  res@tmXBLabelStride                             = stride1
  res@tmYLLabelsOn                                = False

  ; get Data in 1D array
  data_1d = ndtooned(var1_net)
  plot = gsn_histogram(wks1,data_1d,res)

  print("converting plot 1 to png")
  convert_cmd = "convert -density 300 "+fout1+".ps -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout1+".png"
  system(convert_cmd)

  delete(plot)
  delete(data_1d)
  delete(res)
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 2 - Winter averages for nodes - variable 1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot2").and.(plot2))then  ; if plotting is turned on
  print("Plot 2 - Node avg histogram")
  fout2 = varcode+"_node_avg_histogram_stats_"+datatitle1

  wks2 = gsn_open_wks("ps",fout2)
  gsn_define_colormap(wks2,colormap)
  plot = new(nnode, graphic)

  res                                             = True
  res@gsnHistogramClassIntervals                  = levels          ; bin levels
  res@gsnHistogramComputePercentagesNoMissing     = True
  res@tiXAxisString                               = var1@units
  res@tiYAxisString                               = ""
  res@gsnHistogramPercentSign                     = True
  res@tmXBLabelStride                             = stride1
  res@tmYLLabelsOn                                = False
  
xpos = 0
ypos = 0

do n = 0, nnode-1
  print("Plotting graph "+n+" ("+xpos+","+ypos+")")

  ; get Data in 1D array
  data_1d = ndtooned(var1(n,:,:))
  cplot  = gsn_histogram(wks2,data_1d,res)
  plot(n) = cplot
  delete(data_1d)

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
title_fin = vartitle1+": node avg distributions - "+datatitle1

res_pan                       = True ; panel resources
res_pan@txString              = title_fin
res_pan@txFontHeightF         = 0.015 ; title font height
res_pan@gsnPaperOrientation   = "landscape" ; landscape mode
res_pan@gsnMaximize           = True ; make it big

gsn_panel(wks2,plot,(/ny_node, nx_node/),res_pan)

  print("converting plot 2 to png")
  convert_cmd = "convert -density 300 "+fout2+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout2+".png"

  system(convert_cmd)

delete(res_pan)
delete(res)
delete(plot)
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 3 - Nodes of maximum value
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot3").and.(plot3))then
  print("Plot 3 - maximum node values")
  fout3 = varcode+"_maximum_values_"+datatitle1
  title = nx_input+"x"+ny_input+" pattern maximum: "+vartitle1+" - "+datatitle1+"~C~Net Avg Maximum: "+sprintf("%5.2f",maxima_net)+" "+var1@units

  wks3 = gsn_open_wks("ps",fout3)
  gsn_define_colormap(wks3, "redscale2")  ;"gsdtol")
  ;gsn_reverse_colormap(wks3)
  ;colors = gsn_retrieve_colormap(wks3) ; load fixed map into "colors"

  ; make data into som size for plotting
  maxima_2d = onedtond(maxima, (/ny_node,nx_node/))
  maxima_2d = maxima_2d(::-1,:)

; Begin plotting:    
  plot = new(1, graphic)
  dum1  = new((/nnode/),graphic)
  dum2  = new((/nnode/),graphic)
  dum3  = new((/nnode/),graphic)

; Resources for blank plot:
  res_blank                                = True
  res_blank@gsnFrame                       = False  ; do not frame yet (so we can panel)
  res_blank@gsnDraw                        = False   ; do not draw yet (so we can panel)
  res_blank@gsnMaximize                    = True
  res_blank@trXMinF                        = 0
  res_blank@trXMaxF                        = nx_node
  res_blank@trYMinF                        = 0
  res_blank@trYMaxF                        = ny_node
  res_blank@vpWidthF                       = 0.6           ; this is default
  res_blank@vpHeightF                      = 0.6*ny_node / nx_node  ; set height so each node is square
  res_blank@tiMainFontHeightF              = 0.01
  res_blank@tiMainPosition                 = "Left"
  res_blank@tiMainJust                     = "centerleft"
  res_blank@tmEqualizeXYSizes              = True    ; Equal sizes for tick labels
  res_blank@tmXBMajorLengthF               = 0.0      ; effectively turn off tick marks
  res_blank@tmYLMajorLengthF               = 0.0      ; effectively turn off tick marks
  res_blank@tmXBMode                       = "Explicit"
  res_blank@tmXBLabels                     = ispan(0,nx_node-1,1)+""            ; tick marks
  res_blank@tmXBValues                     = fspan(0, nx_node-1, nx_node) + 0.5 ; position for tick labels
  res_blank@tmYLMode                       = "Explicit"
  res_blank@tmYLLabels                     = ispan(ny_node-1,0,1)+""            ; backwards tick marks
  res_blank@tmYLValues                     = fspan(0, ny_node-1, ny_node) + 0.5 ; position for tick labels
  res_blank@tmXBLabelFontHeightF           = res_blank@tiMainFontHeightF
  res_blank@tiXAxisString                  = "SOM Pattern"
  res_blank@tiYAxisString                  = "SOM Pattern"
  res_blank@tiXAxisFontHeightF             = 0.01
  res_blank@tiYAxisFontHeightF             = 0.01
  res_blank@tiMainString                   = title

  plot = gsn_blank_plot(wks3,res_blank)

; Add in squares:
  xx = (/0., 0., 1., 1., 0./)
  yy = (/0., 1., 1., 0., 0./)

; Polygon resources for color shading:
  res_poly = True
; Text resources for count and freq:
  res_txt = True
  res_txt@txFontHeightF = 0.0125 ;0.0085
  res_txt@txFont = 22
  res_txt@txFontColor = "black"

  ; Get grey scales(same used for all data sets)
  maxofmaxima = max(maxima_2d)
  minofmaxima = min(maxima_2d)
  fudg = maxofmaxima*fudgpc  ; give ourselves a % buffer so colors are within limits
  if (maxofmaxima.ne.0) then
    slope = (10.-2.)/((maxofmaxima+fudg) - (minofmaxima-fudg))
;      slope = (32. - 2.) / ((maxofmaxima+fudg) - (minofmaxima-fudg))  ; use 32 because there are 32 colors
  else
    slope = 0
  end if

; loop through each node to plot
n = 0
do y = 0, ny_node - 1
  do x = 0, nx_node - 1 
    xp = xx + x
    yp = yy + y  
    ; variable 1
    gray_index = slope * maxima_2d(y,x) + 2.0
    if(gray_index.eq.2.) then
      gray_index = 0. ; to get actual white because our color table is flaky
    end if 
    ; Color squares
    res_poly@gsFillColor = gray_index ; should auto round
    dum1(n) = gsn_add_polygon(wks3, plot, xp, yp, res_poly)
    dum2(n) = gsn_add_polyline(wks3, plot, xp, yp, res_poly)
    res_txt@txBackgroundFillColor = gray_index ;"white"
    text_1 = "Maximum:~C~"+sprintf("%5.2f",maxima_2d(y,x))+" "+var1@units
    dum3(n) = gsn_add_text(wks3, plot, text_1, xp(0)+.5, yp(0)+.5, res_txt)
    delete(text_1)

    n = n+1
  end do 
end do
  
; Finally - make plot
  draw(plot)
  frame(wks3)
  print("converting plot 3 to png")
  convert_cmd = "convert -density 300 "+fout3+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout3+".png"
  system(convert_cmd)

;delete(res_blank)
;delete(res_poly)
;delete(res_txt)
delete(title)
delete(plot)
delete(dum1)
delete(dum2)
delete(dum3)
delete(fudg)

end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 4 - Nodes of 95% value
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot4").and.(plot4))then
  print("Plot 4 - 95 percentile node values")
  fout4 = varcode+"_95percentile_values_"+datatitle1
  title = nx_input+"x"+ny_input+" pattern 95 percentile: "+vartitle1+" - "+datatitle1+"~C~Net Avg 95 percentile: "+sprintf("%5.2f",pcnt95_net)+" "+var1@units
  res_blank@tiMainString                   = title

  wks4 = gsn_open_wks("ps",fout4)
  gsn_define_colormap(wks4, "redscale2")  ;"gsdtol")

  ; make data into som size for plotting
  pcnt95_2d = onedtond(pcnt95, (/ny_node,nx_node/))
  pcnt95_2d = pcnt95_2d(::-1,:)

; Begin plotting:    
  plot = new(1, graphic)
  dum1  = new((/nnode/),graphic)
  dum2  = new((/nnode/),graphic)
  dum3  = new((/nnode/),graphic)

  plot = gsn_blank_plot(wks4,res_blank)

  ; Get grey scales(same used for all data sets)
  maxofpcnt95 = max(pcnt95_2d)
  minofpcnt95 = min(pcnt95_2d)
  fudg = maxofpcnt95*fudgpc  ; give ourselves a % buffer so colors are within limits
  if (maxofpcnt95.ne.0) then
    slope = (10.-2.)/((maxofpcnt95+fudg) - (minofpcnt95-fudg))
;      slope = (32. - 2.) / ((maxofmaxima+fudg) - (minofmaxima-fudg))  ; use 32 because there are 32 colors
  else
    slope = 0
  end if

; loop through each node to plot
n = 0
do y = 0, ny_node - 1
  do x = 0, nx_node - 1 
    xp = xx + x
    yp = yy + y  
    ; variable 1
    gray_index = slope * pcnt95_2d(y,x) + 2.0
    if(gray_index.eq.2.) then
      gray_index = 0. ; to get actual white because our color table is flaky
    end if 
    ; Color squares
    res_poly@gsFillColor = gray_index ; should auto round
    dum1(n) = gsn_add_polygon(wks4, plot, xp, yp, res_poly)
    dum2(n) = gsn_add_polyline(wks4, plot, xp, yp, res_poly)
    res_txt@txBackgroundFillColor = gray_index ;"white"
    text_1 = "95~C~percentile:~C~"+sprintf("%5.2f",pcnt95_2d(y,x))+" "+var1@units
    dum3(n) = gsn_add_text(wks4, plot, text_1, xp(0)+.5, yp(0)+.5, res_txt)
    delete(text_1)

    n = n+1
  end do 
end do
  
; Finally - make plot
  draw(plot)
  frame(wks4)
  print("converting plot 4 to png")
  convert_cmd = "convert -density 300 "+fout4+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout4+".png"
  system(convert_cmd)

delete(title)
delete(plot)
delete(dum1)
delete(dum2)
delete(dum3)
delete(fudg)

end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 5 - Nodes of mean value
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot5").and.(plot5))then
  print("Plot 5 - mean node values")
  fout5 = varcode+"_mean_values_"+datatitle1
  title = nx_input+"x"+ny_input+" pattern mean: "+vartitle1+" - "+datatitle1+"~C~Net Avg Mean: "+sprintf("%5.2f",mean_net)+" "+var1@units
  res_blank@tiMainString                   = title

  wks5 = gsn_open_wks("ps",fout5)
  gsn_define_colormap(wks5, "redscale2")  ;"gsdtol")

  ; make data into som size for plotting
  mean_2d = onedtond(mean, (/ny_node,nx_node/))
  mean_2d = mean_2d(::-1,:)

; Begin plotting:    
  plot = new(1, graphic)
  dum1  = new((/nnode/),graphic)
  dum2  = new((/nnode/),graphic)
  dum3  = new((/nnode/),graphic)

  plot = gsn_blank_plot(wks5,res_blank)

  ; Get grey scales(same used for all data sets)
  maxofmean = max(mean_2d)
  minofmean = min(mean_2d)
  fudg = maxofmean*fudgpc  ; give ourselves a % buffer so colors are within limits
  if (maxofmean.ne.0) then
    slope = (10.-2.)/((maxofmean+fudg) - (minofmean-fudg))
;      slope = (32. - 2.) / ((maxofmaxima+fudg) - (minofmaxima-fudg))  ; use 32 because there are 32 colors
  else
    slope = 0
  end if

; loop through each node to plot
n = 0
do y = 0, ny_node - 1
  do x = 0, nx_node - 1 
    xp = xx + x
    yp = yy + y  
    ; variable 1
    gray_index = slope * mean_2d(y,x) + 2.0
    if(gray_index.eq.2.) then
      gray_index = 0. ; to get actual white because our color table is flaky
    end if 
    ; Color squares
    res_poly@gsFillColor = gray_index ; should auto round
    dum1(n) = gsn_add_polygon(wks5, plot, xp, yp, res_poly)
    dum2(n) = gsn_add_polyline(wks5, plot, xp, yp, res_poly)
    res_txt@txBackgroundFillColor = gray_index ;"white"
    text_1 = "mean:~C~"+sprintf("%5.2f",mean_2d(y,x))+" "+var1@units
    dum3(n) = gsn_add_text(wks5, plot, text_1, xp(0)+.5, yp(0)+.5, res_txt)
    delete(text_1)

    n = n+1
  end do 
end do
  
; Finally - make plot
  draw(plot)
  frame(wks5)
  print("converting plot 5 to png")
  convert_cmd = "convert -density 300 "+fout5+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout5+".png"
  system(convert_cmd)

delete(title)
delete(plot)
delete(dum1)
delete(dum2)
delete(dum3)
delete(fudg)

end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 6 - Nodes of median value
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot6").and.(plot6))then
  print("Plot 6 - median node values")
  fout6 = varcode+"_median_values_"+datatitle1
  title = nx_input+"x"+ny_input+" pattern median: "+vartitle1+" - "+datatitle1+"~C~Net Avg Median: "+sprintf("%5.2f",median_net)+" "+var1@units
  res_blank@tiMainString                   = title

  wks6 = gsn_open_wks("ps",fout6)
  gsn_define_colormap(wks6, "redscale2")  ;"gsdtol")

  ; make data into som size for plotting
  median_2d = onedtond(median, (/ny_node,nx_node/))
  median_2d = median_2d(::-1,:)

; Begin plotting:    
  plot = new(1, graphic)
  dum1  = new((/nnode/),graphic)
  dum2  = new((/nnode/),graphic)
  dum3  = new((/nnode/),graphic)

  plot = gsn_blank_plot(wks6,res_blank)

  ; Get grey scales(same used for all data sets)
  maxofmedian = max(median_2d)
  minofmedian = min(median_2d)
  fudg = maxofmedian*fudgpc  ; give ourselves a % buffer so colors are within limits
  if (maxofmedian.ne.0) then
    slope = (10.-2.)/((maxofmedian+fudg) - (minofmedian-fudg))
;      slope = (32. - 2.) / ((maxofmaxima+fudg) - (minofmaxima-fudg))  ; use 32 because there are 32 colors
  else
    slope = 0
  end if

; loop through each node to plot
n = 0
do y = 0, ny_node - 1
  do x = 0, nx_node - 1 
    xp = xx + x
    yp = yy + y  
    ; variable 1
    gray_index = slope * median_2d(y,x) + 2.0
    if(gray_index.eq.2.) then
      gray_index = 0. ; to get actual white because our color table is flaky
    end if 
    ; Color squares
    res_poly@gsFillColor = gray_index ; should auto round
    dum1(n) = gsn_add_polygon(wks6, plot, xp, yp, res_poly)
    dum2(n) = gsn_add_polyline(wks6, plot, xp, yp, res_poly)
    res_txt@txBackgroundFillColor = gray_index ;"white"
    text_1 = "median:~C~"+sprintf("%5.2f",median_2d(y,x))+" "+var1@units
    dum3(n) = gsn_add_text(wks6, plot, text_1, xp(0)+.5, yp(0)+.5, res_txt)
    delete(text_1)

    n = n+1
  end do 
end do
  
; Finally - make plot
  draw(plot)
  frame(wks6)
  print("converting plot 6 to png")
  convert_cmd = "convert -density 300 "+fout6+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout6+".png"
  system(convert_cmd)

delete(title)
delete(plot)
delete(dum1)
delete(dum2)
delete(dum3)
delete(fudg)

end if

print("Completed all extremes plots for "+varcode)
print("Good job!")
;;;;;;;;;;;;;;;;;;;;;; END script
end
