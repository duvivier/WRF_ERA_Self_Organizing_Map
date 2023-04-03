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
;  varcode = "U10"
;  percentile = "50"
;  datatitle1  = "wrf50_200511_200703_6h"
;  datatitle2 = "era_i_200511_200703_6h"
 ;; options: "wrf10_200511_200703_6h" "wrf50_200511_200703_6h" "era_i_200511_200703_6h"
; ******************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Set which plots to print out
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  vartest = varcode+"_"+percentile
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Processing all graphs for "+vartest)
; create plots!
plot1  = True ; plot 1 - 3 panel comparing fluxes with 6h and nodeavg
plot2  = True ; plot 3 - nodes with dataset1 percentile values
plot3  = True ; plot 4 - nodes with dataset2 percentile values
plot4  = True ; plot 6 - nodes with difference 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; BEGIN SCRIPT
print("Calculating why averages differ for: "+vartest)

; get tag to let us know if it needs interpolation
title1_ch  = stringtocharacter(datatitle1)
title1_sub = title1_ch(0:4)
tag_1 = chartostring(title1_sub)
title2_ch  = stringtocharacter(datatitle2)
title2_sub = title2_ch(0:4)
tag_2 = chartostring(title2_sub)

; set input directory and file name strings
dir1 = "/data3/duvivier/SOM/analysis/extremes/node_avgs/"

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
; add each variable set in the c-shell 'vartest' and assign it a title and other necessary information
if (vartest.eq."LH_max") then
  vartitle1 = "Maximum COARE Latent Heat Flux at surface"
  invar1 = "lhflx_max"
  vartype = "2d"
  cmaptype = "lh_max"
  zoom2 = True
end if
if (vartest.eq."LH_99") then
  vartitle1 = "99th percentile COARE Latent Heat Flux at surface"
  invar1 = "lhflx_99"
  vartype = "2d"
  cmaptype = "lh_max"
  zoom2 = True
end if
if (vartest.eq."LH_95") then
  vartitle1 = "95th percentile COARE Latent Heat Flux at surface"
  invar1 = "lhflx_95"
  vartype = "2d"
  cmaptype = "lh_mid"
  zoom2 = True
end if
if (vartest.eq."LH_90") then
  vartitle1 = "90th percentile COARE Latent Heat Flux at surface"
  invar1 = "lhflx_90"
  vartype = "2d"
  cmaptype = "lh_mid"
  zoom2 = True
end if
if (vartest.eq."LH_75") then
  vartitle1 = "75th percentile COARE Latent Heat Flux at surface"
  invar1 = "lhflx_75"
  vartype = "2d"
  cmaptype = "lh_low"
  zoom2 = True
end if
if (vartest.eq."LH_50") then
  vartitle1 = "50th percentile COARE Latent Heat Flux at surface"
  invar1 = "lhflx_50"
  vartype = "2d"
  cmaptype = "lh_low"
  zoom2 = True
end if
if (vartest.eq."SH_max") then
  vartitle1 = "Maximum COARE Sensible Heat Flux at surface"
  invar1 = "shflx_max"
  vartype = "2d"
  cmaptype = "sh_max"
  zoom2 = True
end if
if (vartest.eq."SH_99") then
  vartitle1 = "99th percentile COARE Sensible Heat Flux at surface"
  invar1 = "shflx_99"
  vartype = "2d"
  cmaptype = "sh_max"
  zoom2 = True
end if
if (vartest.eq."SH_95") then
  vartitle1 = "95th percentile COARE Sensible Heat Flux at surface"
  invar1 = "shflx_95"
  vartype = "2d"
  cmaptype = "sh_mid"
  zoom2 = True
end if
if (vartest.eq."SH_90") then
  vartitle1 = "90th percentile COARE Sensible Heat Flux at surface"
  invar1 = "shflx_90"
  vartype = "2d"
  cmaptype = "sh_mid"
  zoom2 = True
end if
if (vartest.eq."SH_75") then
  vartitle1 = "75th percentile COARE Sensible Heat Flux at surface"
  invar1 = "shflx_75"
  vartype = "2d"
  cmaptype = "sh_low"
  zoom2 = True
end if
if (vartest.eq."SH_50") then
  vartitle1 = "50th percentile COARE Sensible Heat Flux at surface"
  invar1 = "shflx_50"
  vartype = "2d"
  cmaptype = "sh_low"
  zoom2 = True
end if
if (vartest.eq."U10_max") then
  vartitle1 = "Maximum Windspeed at 10m"
  invar1 = "ws_10m_max"
  vartype = "2d"
  cmaptype = "ws_max"
  zoom2 = True
end if
if (vartest.eq."U10_99") then
  vartitle1 = "99th percentile Windspeed at 10m"
  invar1 = "ws_10m_99"
  vartype = "2d"
  cmaptype = "ws_max"
  zoom2 = True
end if
if (vartest.eq."U10_95") then
  vartitle1 = "95th percentile Windspeed at 10m"
  invar1 = "ws_10m_95"
  vartype = "2d"
  cmaptype = "ws_mid"
  zoom2 = True
end if
if (vartest.eq."U10_90") then
  vartitle1 = "90th percentile Windspeed at 10m"
  invar1 = "ws_10m_90"
  vartype = "2d"
  cmaptype = "ws_mid"
  zoom2 = True
end if
if (vartest.eq."U10_75") then
  vartitle1 = "75th percentile Windspeed at 10m"
  invar1 = "ws_10m_75"
  vartype = "2d"
  cmaptype = "ws_low"
  zoom2 = True
end if
if (vartest.eq."U10_50") then
  vartitle1 = "50th percentile Windspeed at 10m"
  invar1 = "ws_10m_50"
  vartype = "2d"
  cmaptype = "ws_low"
  zoom2 = True
end if

; Set the contour interval for each input variable   
; set contour limits manually:
  if (cmaptype.eq."lh_max") then
    cmin1               =  0.               ; for net avgs
    cmax1               =  600.
    clev1               =  30.
    stride1             =  2                ; label stride
    cmin2               = -200.             ; for net diffs
    cmax2               =  200.
    clev2               =  10.
    stride2             =  2                ; label stride diff plot
    cmin4               =  0.               ; for node avgs
    cmax4               =  600.
    clev4               =  30.
    stride4             =  2                ; label stride for diff plot 
    cmin5               =  -300.            ; for node diffs
    cmax5               =  300.
    clev5               =  20.
    stride5             =  2                ; label stride diff plot
    plotlines           = False             ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"        ; type of fill for contours 
    spreadstart1        = 127               ; start at color
    spreadend1          = 250               ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 250               ; end at color
    colormap            = "BlueYellowRed_mod"
  end if
  if (cmaptype.eq."lh_mid") then
    cmin1               =  0.               ; for net avgs
    cmax1               =  350.
    clev1               =  25.
    stride1             =  2                ; label stride
    cmin2               = -100.             ; for net diffs
    cmax2               =  100.
    clev2               =  10.
    stride2             = 2                 ; label stride diff plot
    cmin4               = 0.                ; for node avgs
    cmax4               = 600.
    clev4               = 30.
    stride4             = 4                 ; label stride for diff plot 
    cmin5               = -200.             ; for node diffs
    cmax5               =  200.
    clev5               =  10.
    stride5             = 2                 ; label stride diff plot
    plotlines           = False             ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"        ; type of fill for contours 
    spreadstart1        = 127               ; start at color
    spreadend1          = 250               ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 250               ; end at color
    colormap            = "BlueYellowRed_mod"
  end if
  if (cmaptype.eq."lh_low") then
    cmin1               =  0.               ; for net avgs
    cmax1               =  200.
    clev1               =  10.
    stride1             =  2                ; label stride
    cmin2               = -100.             ; for net diffs
    cmax2               =  100.
    clev2               =  10.
    stride2             = 2                 ; label stride diff plot
    cmin4               = 0.                ; for node avgs
    cmax4               = 400.
    clev4               = 20.
    stride4             = 2                 ; label stride for diff plot 
    cmin5               = -150.             ; for node diffs
    cmax5               =  150.
    clev5               =  10.
    stride5             = 2                 ; label stride diff plot
    plotlines           = False             ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"        ; type of fill for contours 
    spreadstart1        = 127               ; start at color
    spreadend1          = 250               ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 250               ; end at color
    colormap            = "BlueYellowRed_mod"
  end if
  if (cmaptype.eq."sh_max") then
    cmin1               =  0.               ; for net avgs
    cmax1               =  600.
    clev1               =  30.
    stride1             =  2                ; label stride
    cmin2               = -300.             ; for net diffs
    cmax2               =  300.
    clev2               =  20.
    stride2             =  2                ; label stride diff plot
    cmin4               =  0.               ; for node avgs
    cmax4               =  600.
    clev4               =  30.
    stride4             =  2                ; label stride for diff plot 
    cmin5               =  -300.            ; for node diffs
    cmax5               =  300.
    clev5               =  20.
    stride5             =  2                ; label stride diff plot
    plotlines           = False             ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"        ; type of fill for contours 
    spreadstart1        = 127               ; start at color
    spreadend1          = 250               ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 250               ; end at color
    colormap            = "BlueYellowRed_mod"
  end if
  if (cmaptype.eq."sh_mid") then
    cmin1               =  0.               ; for net avgs
    cmax1               =  400.
    clev1               =  20.
    stride1             =  2                ; label stride
    cmin2               = -200.             ; for net diffs
    cmax2               =  200.
    clev2               =  10.
    stride2             = 2                 ; label stride diff plot
    cmin4               = 0.                ; for node avgs
    cmax4               = 600.
    clev4               = 30.
    stride4             = 2                 ; label stride for diff plot 
    cmin5               = -250.             ; for node diffs
    cmax5               =  250.
    clev5               =  10.
    stride5             = 2                 ; label stride diff plot
    plotlines           = False             ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"        ; type of fill for contours 
    spreadstart1        = 127               ; start at color
    spreadend1          = 250               ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 250               ; end at color
    colormap            = "BlueYellowRed_mod"
  end if
  if (cmaptype.eq."sh_low") then
    cmin1               =  0.               ; for net avgs
    cmax1               =  200.
    clev1               =  10.
    stride1             =  2                ; label stride
    cmin2               = -150.             ; for net diffs
    cmax2               =  150.
    clev2               =  10.
    stride2             = 2                 ; label stride diff plot
    cmin4               = 0.                ; for node avgs
    cmax4               = 400.
    clev4               = 20.
    stride4             = 2                 ; label stride for diff plot 
    cmin5               = -150.             ; for node diffs
    cmax5               =  150.
    clev5               =  10.
    stride5             = 2                 ; label stride diff plot
    plotlines           = False             ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"        ; type of fill for contours 
    spreadstart1        = 127               ; start at color
    spreadend1          = 250               ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 250               ; end at color
    colormap            = "BlueYellowRed_mod"
  end if
  if (cmaptype.eq."ws_max") then
    cmin1               =  20.               ; for net avgs
    cmax1               =  40.
    clev1               =  1.
    stride1             =  2                ; label stride
    cmin2               = -20.              ; for net diffs
    cmax2               =  20.
    clev2               =  1.
    stride2             =  2                ; label stride diff plot
    cmin4               =  0.               ; for node avgs
    cmax4               =  40.
    clev4               =  2.
    stride4             =  2                ; label stride for diff plot 
    cmin5               =  -20.             ; for node diffs
    cmax5               =  20.
    clev5               =  2.
    stride5             =  2                ; label stride diff plot
    plotlines           = False             ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"        ; type of fill for contours 
    spreadstart1        = 2                 ; start at color
    spreadend1          = 35                ; end at color
    spreadstart2        = 37                ; start at color
    spreadend2          = 142               ; end at color
    colormap            = "SOM_wind_table"
  end if
  if (cmaptype.eq."ws_mid") then
    cmin1               =  0.               ; for net avgs
    cmax1               =  30.
    clev1               =  2.
    stride1             =  2                ; label stride
    cmin2               = -20.              ; for net diffs
    cmax2               =  20.
    clev2               =  2.
    stride2             =  2                ; label stride diff plot
    cmin4               =  0.               ; for node avgs
    cmax4               =  30.
    clev4               =  2.
    stride4             =  2                ; label stride for diff plot 
    cmin5               =  -20.             ; for node diffs
    cmax5               =  20.
    clev5               =  2.
    stride5             =  2                ; label stride diff plot
    plotlines           = False             ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"        ; type of fill for contours 
    spreadstart1        = 2                 ; start at color
    spreadend1          = 35                ; end at color
    spreadstart2        = 37                ; start at color
    spreadend2          = 142               ; end at color
    colormap            = "SOM_wind_table"
  end if
  if (cmaptype.eq."ws_low") then
    cmin1               =  0.               ; for net avgs
    cmax1               =  20.
    clev1               =  2.
    stride1             =  2                ; label stride
    cmin2               = -14.              ; for net diffs
    cmax2               =  14.
    clev2               =  1.
    stride2             =  2                ; label stride diff plot
    cmin4               =  0.               ; for node avgs
    cmax4               =  30.
    clev4               =  2.
    stride4             =  2                ; label stride for diff plot 
    cmin5               =  -20.             ; for node diffs
    cmax5               =  20.
    clev5               =  2.
    stride5             =  2                ; label stride diff plot
    plotlines           = False             ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"        ; type of fill for contours 
    spreadstart1        = 2                 ; start at color
    spreadend1          = 35                ; end at color
    spreadstart2        = 37                ; start at color
    spreadend2          = 142               ; end at color
    colormap            = "SOM_wind_table"
  end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Data Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;
; load in node averages
;;;;;;;;;;
  fname0 = "node_0x_0y_"+datatitle1+"-extremes"
; Load in lat/lon to get information for WRF10 domain
  f0 = addfile(dir1+fname0+".nc","r")
  lat2d_1 = f0->lat
  lon2d_1 = f0->lon
  z_sfc_1 = f0->Z_sfc
  delete(fname0)
  delete(f0)

  dims = dimsizes(lat2d_1)     ; get lat/lon dimensions
  n_sn_1 = dims(0)              ; get south/north points
  n_we_1 = dims(1)              ; get west/east points
  n_tot_1 = n_sn_1*n_we_1              ; get total number of points in high res domain
  delete(dims)

; Load in lat/lon to get information for WRF10 domain
  fname0b = "node_0x_0y_"+datatitle2+"-extremes"
; Load in lat/lon to get information for WRF10 domain
  f0b = addfile(dir1+fname0b+".nc","r")
  lat2d_2 = f0b->lat
  lon2d_2 = f0b->lon
  z_sfc_2 = f0b->Z_sfc
  delete(fname0b)
  delete(f0b)

  dims = dimsizes(lat2d_2)     ; get lat/lon dimensions
  n_sn_2 = dims(0)              ; get south/north points
  n_we_2 = dims(1)              ; get west/east points
  n_tot_2 = n_sn_2*n_we_2              ; get total number of points in high res domain
  delete(dims)

  ; get weights and indicies for regridding (WRF50 and era weightings are identical)
  weightin = addfile("/data3/duvivier/SOM/DATA/weightings_WRF50_to_WRF10.nc","r")
  interp_ind = weightin->interp_ind
  interp_wgt = weightin->interp_wgt

  ; create all-node array for node average variable
  var1 = new((/nnode,n_sn_1,n_we_1/),"float")
  var2 = new((/nnode,n_sn_2,n_we_2/),"float")
  fill = var1@_FillValue

  ; make sea ice var - overlay with everything
  seaice_1 = new((/nnode,n_sn_1,n_we_1/),"float")
  seaice_2 = new((/nnode,n_sn_2,n_we_2/),"float")

;;;;;;;;;;
; Load in actual data for analysis
;;;;;;;;;;
n = 0
; loop through each node
do y = 0, ny_node - 1
 do x = 0, nx_node - 1
  print("node: "+x+","+y)

  ; get node file names (load all from same file)
  fname1 = "node_"+x+"x_"+y+"y_"+datatitle1+"-extremes"
  fname2 = "node_"+x+"x_"+y+"y_"+datatitle2+"-extremes"
  f1 = addfile(dir1+fname1+".nc","r")
  f2 = addfile(dir1+fname2+".nc","r")

  ; load variables
  var1(n,:,:) = f1->$invar1$(:,:)
  var2(n,:,:) = f2->$invar1$(:,:)
  seaice_1(n,:,:) = f1->SeaIce_avg(:,:)

  ; mask terrain - focus on ocean
  var1(n,:,:) = where(z_sfc_1 .lt. 50., var1(n,:,:), var1@_FillValue)
  var2(n,:,:) = where(z_sfc_2 .lt. 50., var2(n,:,:), var2@_FillValue)

  ; mask lat/lons - focus on S. Greenland region
  var1(n,:,:) = where(lat2d_1 .gt. 55. .and. lat2d_1 .lt. 71. .and. lon2d_1 .lt. -19. .and. lon2d_1 .gt. -55., var1(n,:,:), var1@_FillValue)
  var2(n,:,:) = where(lat2d_2 .gt. 55. .and. lat2d_2 .lt. 71. .and. lon2d_2 .lt. -19. .and. lon2d_2 .gt. -55., var2(n,:,:), var2@_FillValue)

  ; delete vars to use in next loop
  delete(fname1)
  delete(f1)
  delete(fname2)
  delete(f2)
  n = n+1
 end do
end do
delete(n)

print("Loaded "+varcode+" from both files")

;;;;;;;;;;
; Interpolate to WRF10 size (if needed)
;;;;;;;;;;
if (tag_1 .eq. "wrf10" .and. tag_2 .ne. "wrf10")then
  print("Interpolating between resolutions")
  ; Make arrays we'll need in interpolation
  var2_new = new((/nnode,n_sn_1,n_we_1/),"float") 
  var2_tmp_1d  = new((/n_tot_1/),"float")
  seaice_2_new = new((/nnode,n_sn_1,n_we_1/),"float") 
  seaice_2_tmp_1d  = new((/n_tot_1/),"float")

  do n = 0, nnode - 1
    var2_1d = ndtooned(var2(n,:,:))
    seaice_2_1d = ndtooned(seaice_2(n,:,:))
    do i = 0, n_tot_1 - 1
      indices_all = interp_ind(i,:)
      n_indices = num(.not.ismissing(indices_all))
      if (n_indices .ne. 0.0) then
        indices = indices_all(0:n_indices-1)
        weight_all = interp_wgt(i,:)
        weight = weight_all(0:n_indices-1)
        var2_tmp_1d(i) = sum(var2_1d(indices)*weight/sum(weight))
        seaice_2_tmp_1d(i) = sum(seaice_2_1d(indices)*weight/sum(weight))
        delete(indices)
        delete(weight)
      end if
    end do
    ; redimensionalize
    var2_new(n,:,:) = onedtond(var2_tmp_1d,(/n_sn_1,n_we_1/))
    seaice_2_new(n,:,:) = onedtond(seaice_2_tmp_1d,(/n_sn_1,n_we_1/))

   ; counter
  print("created node avg "+n+" of "+nnode)
end do

  delete(var2)
  var2 = var2_new
  delete(var2_new)
  copy_VarMeta(var1, var2)
  copy_VarCoords(var1,var2)
  var2@_FillValue = fill
  delete(seaice_2)
  seaice_2 = seaice_2_new
  delete(seaice_2_new)
  copy_VarMeta(seaice_1, seaice_2)
  copy_VarCoords(seaice_1,seaice_2)
  seaice_2@_FillValue = fill
end if

;;;;;;;;;;
; Find difference and probability
;;;;;;;;;;
; find difference
diff = var1 - var2
title_diff = "Difference: ("+datatitle1+" - "+datatitle2+")"

; assign lat/lon info
var1@lat2d = lat2d_1
var1@lon2d = lon2d_1
var2@lat2d = lat2d_1
var2@lon2d = lon2d_1
diff@lat2d = lat2d_1
diff@lon2d = lon2d_1
seaice_1@lat2d = lat2d_1
seaice_1@lon2d = lon2d_1
seaice_2@lat2d = lat2d_1
seaice_2@lon2d = lon2d_1

; prints together the variable title (set above for each type of data) with title1 (defined in cshell as the wrf or met info) and the max and min values
  print(vartest+" "+datatitle1+" nodes: "+min(var1)+"  max: "+max(var1)) 
  print(vartest+" "+datatitle2+" nodes: "+min(var2)+"  max: "+max(var2)) 
  print("Diff min: "+min(diff)+"  max: "+max(diff)) 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Use net average files to calculate difference
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;
; Load net averages
;;;;;;;;;;
; net avgs
  fname1 = "net_"+datatitle1+"-extremes"
  fname2 = "net_"+datatitle2+"-extremes"
  f1 = addfile(dir1+fname1+".nc","r")
  f2 = addfile(dir1+fname2+".nc","r")

  ; load the variables
  var1_net = f1->$invar1$(:,:)
  var1_net@_FillValue = fill
  var2_net = f2->$invar1$(:,:)
  var2_net@_FillValue = fill

  ; mask terrain - focus on ocean
  var1_net = where(z_sfc_1 .lt. 50., var1_net, var1_net@_FillValue)
  var2_net = where(z_sfc_2 .lt. 50., var2_net, var2_net@_FillValue)

  ; mask lat/lons - focus on S. Greenland region
  var1_net = where(lat2d_1 .gt. 55. .and. lat2d_1 .lt. 71. .and. lon2d_1 .lt. -19. .and. lon2d_1 .gt. -55., var1_net, var1_net@_FillValue)
  var2_net = where(lat2d_2 .gt. 55. .and. lat2d_2 .lt. 71. .and. lon2d_2 .lt. -19. .and. lon2d_2 .gt. -55., var2_net, var2_net@_FillValue)

  seaice_1_avg  = f1->SeaIce_avg(:,:)
  seaice_2_avg  = f2->SeaIce_avg(:,:)

print("Loaded variables from both files")

;;;;;;;;;;
; Interpolate to WRF10 size (if needed)
;;;;;;;;;;
if (tag_1 .eq. "wrf10" .and. tag_2 .ne. "wrf10")then
  print("Interpolating between resolutions")
  ; Make arrays we'll need in interpolation
  var2_net_new = new((/n_sn_1,n_we_1/),"float") 
  var2_net_tmp_1d  = new((/n_tot_1/),"float")
  seaice_2_avg_new = new((/n_sn_1,n_we_1/),"float") 
  seaice_2_avg_tmp_1d  = new((/n_tot_1/),"float")
    
  var2_net_1d = ndtooned(var2_net(:,:))
  seaice_2_avg_1d = ndtooned(seaice_2_avg(:,:))
  do i = 0, n_tot_1 - 1
    indices_all = interp_ind(i,:)
    n_indices = num(.not.ismissing(indices_all))
    if (n_indices .ne. 0.0) then
      indices = indices_all(0:n_indices-1)
      weight_all = interp_wgt(i,:)
      weight = weight_all(0:n_indices-1)
      var2_net_tmp_1d(i) = sum(var2_net_1d(indices)*weight/sum(weight))
      seaice_2_avg_tmp_1d(i) = sum(seaice_2_avg_1d(indices)*weight/sum(weight))
      delete(indices)
      delete(weight)
    end if
  end do
    ; redimensionalize
  var2_net_new(:,:) = onedtond(var2_net_tmp_1d,(/n_sn_1,n_we_1/))
  seaice_2_avg_new(:,:) = onedtond(seaice_2_avg_tmp_1d,(/n_sn_1,n_we_1/))
  
  delete(var2_net)
  var2_net = var2_net_new
  delete(var2_net_new)
  copy_VarMeta(var1_net, var2_net)
  var2_net@_FillValue = fill
  delete(seaice_2_avg)
  seaice_2_avg = seaice_2_avg_new
  delete(seaice_2_avg_new)
  copy_VarMeta(seaice_1_avg, seaice_2_avg)
  seaice_2_avg@_FillValue = fill
end if

;;;;;;;;;;
;  calculate differences
;;;;;;;;;;
  diff_net = var1_net - var2_net   ; dataset1 fluxes calc'ed with dataset 2 winds - dataset1 fluxes

  var1_net@lat2d = lat2d_1
  var1_net@lon2d = lon2d_1
  var2_net@lat2d = lat2d_1
  var2_net@lon2d = lon2d_1
  diff_net@lat2d = lat2d_1
  diff_net@lon2d = lon2d_1
  seaice_1_avg@lat2d = lat2d_1
  seaice_1_avg@lon2d = lon2d_1
  seaice_2_avg@lat2d = lat2d_1
  seaice_2_avg@lon2d = lon2d_1

  print(vartest+" "+datatitle1+" net: "+min(var1_net)+"  max: "+max(var1_net)) 
  print(vartest+" "+datatitle2+" net: "+min(var2_net)+"  max: "+max(var2_net)) 
  print("Net Diff min: "+min(diff_net)+"  max: "+max(diff_net)) 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Processing all graphs for "+vartest)
; create plots!
; plot 1 - 3 panel comparing fluxes with 6h and nodeavg
; plot 2 - nodes with datatitle1 percentiles
; plot 3 - nodes with datatitle2 percentiles
; plot 4 - nodes with diff 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 1 - 3 panel of net fluxes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot1").and.(plot1))then  ; if plotting is turned on
  print("Plot 1 - Net fluxes and differences")
  fout1   = vartest+"_"+tag_1+"_"+tag_2+"_200511_200703_6h_net"

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

  title = datatitle1
  opts@tiMainString               = title            ; title string specified from cshell
  cplot0  = gsn_csm_contour_map(wks1,var1_net,opts)
  cplot0b = gsn_csm_contour(wks1,seaice_1_avg,res_ice)
  overlay(cplot0,cplot0b)
  plot(0) = cplot0
  delete(title)

  title = datatitle2
  opts@tiMainString               = title            ; title string specified from cshell
  cplot1  = gsn_csm_contour_map(wks1,var2_net,opts)
  cplot2 = gsn_csm_contour(wks1,seaice_2_avg,res_ice)
  overlay(cplot1,cplot2)
  plot(1) = cplot1
  delete(title)

delete(opts)
;;;;;;;;;;;;;
; Make difference plot
;;;;;;;;;;;;;
  opts                            = res
  opts@gsnRightString             = ""
  opts@gsnLeftString              = ""
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

  title = "difference: "+tag_1 +" - "+tag_2
  opts@tiMainString               = title             ; set title for difference plot
  cplot2  = gsn_csm_contour_map(wks1,diff_net,opts)
  cplot2c = gsn_csm_contour(wks1,seaice_1_avg,res_ice)
  overlay(cplot2,cplot2c)
  plot(2) = cplot2
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
; Plot 2 - nodes with net flux values
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot2").and.(plot2))then  ; if plotting is turned on
print("Plot 2 - node fluxes")
fout2   = vartest+"_"+tag_1+"_200511_200703_6h_nodes"

  wks2 = gsn_open_wks("ps" ,fout2)
  additional_colors = (/"black","gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks2,colormap,additional_colors)
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
  res@gsnSpreadColorStart        = spreadstart1      ; start at color specified for each variable above
  res@gsnSpreadColorEnd          = spreadend1        ; end at color specified above
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

  cplot  = gsn_csm_contour_map(wks2,var1_2d,res)
  cplot2 = gsn_csm_contour(wks2,seaice_1_2d,res_ice)
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
title_fin = "Node "+vartitle1+": "+datatitle1

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

gsn_panel(wks2,(/plot/),(/ny_node, nx_node/),res_pan)


  print("converting plot 2 to png")
; convert to png 
  convert_cmd = "convert -density 300 "+fout2+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout2+".png"

  system(convert_cmd)

  ;delete(res)
  ;delete(res_ice)
  ;delete(res_pan)
  delete(title_fin)
  delete(additional_colors)
  delete(plot)
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 3 - Winter averages for nodes - variable 1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot3").and.(plot4))then  ; if plotting is turned on
print("Plot 3 - node fluxes")
fout3   = vartest+"_"+tag_2+"_200511_200703_6h_nodes"
  wks3 = gsn_open_wks("ps" ,fout3)
  additional_colors = (/"black","gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks3,colormap,additional_colors)
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

  cplot  = gsn_csm_contour_map(wks3,var2_2d,res)
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
title_fin = "Node "+vartitle1+": "+datatitle2

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

gsn_panel(wks3,(/plot/),(/ny_node, nx_node/),res_pan)


  print("converting plot 3 to png")
; convert to png 
  convert_cmd = "convert -density 300 "+fout3+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout3+".png"

  system(convert_cmd)

  delete(res)
  delete(res_ice)
  delete(res_pan)
  delete(title_fin)
  delete(additional_colors)
  delete(plot)
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 4 - nodes with net flux values
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot4").and.(plot4))then  ; if plotting is turned on
print("Plot 4 - node fluxes")
fout4   = vartest+"_"+tag_2+"_200511_200703_6h_nodes_diff"

  wks4 = gsn_open_wks("ps" ,fout4)
  additional_colors = (/"black","gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks4,colormap,additional_colors)
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
  res@gsnSpreadColorStart        = spreadstart2      ; start at color specified for each variable above
  res@gsnSpreadColorEnd          = spreadend2        ; end at color specified above
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
 
xpos = 0
ypos = 0

do n = 0, nnode-1
  ;print("Plotting graph "+n+" ("+xpos+","+ypos+")")
  diff_2d = diff(n,:,:)
  seaice_1_2d = seaice_1(n,:,:)

  ; get avg difference and max absolute difference/%difference
  res@gsnRightString              = ""
  res@gsnLeftString               = ""
  res@gsnCenterString = "("+xpos+","+ypos+")"  ; (this changes)
  ;res@gsnCenterStringParallelPosF = 0.02 ; scoot it in just a bit as well

  cplot  = gsn_csm_contour_map(wks4,diff_2d,res)
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
title_fin = "Node "+vartitle1+" difference: "+tag_1+" - "+tag_2

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

gsn_panel(wks4,(/plot/),(/ny_node, nx_node/),res_pan)


  print("converting plot 4 to png")
; convert to png 
  convert_cmd = "convert -density 300 "+fout4+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 254 -depth 8 "+fout4+".png"

  system(convert_cmd)

  delete(res)
  delete(res_ice)
  delete(res_pan)
  delete(title_fin)
  delete(additional_colors)
  delete(plot)
end if

print("Completed all plots for "+vartest)
print("Good job!")
;;;;;;;;;;;;;;;;;;;;;; END script
end
