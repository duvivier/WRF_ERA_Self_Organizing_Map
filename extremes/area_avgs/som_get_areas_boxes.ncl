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
  nx_input = "7"
  ny_input = "5"
  varcode = "SH"
  percentile = "max"
  datatitle1 = "wrf10_200511_200703_6h"
  datatitle2 = "wrf50_200511_200703_6h"
  datatitle3 = "era_i_200511_200703_6h"
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
title3_ch  = stringtocharacter(datatitle3)
title3_sub = title3_ch(0:4)
tag_3 = chartostring(title3_sub)

; set input directory and file name strings
dir1 = "/data3/duvivier/SOM/analysis/extremes/node_avgs/extremes-fracice/"

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
    cntype              = "RasterFill"        ; type of fill for contours 
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
    cntype              = "RasterFill"        ; type of fill for contours 
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
    cntype              = "RasterFill"        ; type of fill for contours 
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
    cntype              = "RasterFill"        ; type of fill for contours 
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
    cntype              = "RasterFill"        ; type of fill for contours 
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
    cntype              = "RasterFill"        ; type of fill for contours 
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
    clev2               =  2.
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
    cntype              = "RasterFill"        ; type of fill for contours 
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
    cntype              = "RasterFill"        ; type of fill for contours 
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
    cntype              = "RasterFill"        ; type of fill for contours 
    spreadstart1        = 2                 ; start at color
    spreadend1          = 35                ; end at color
    spreadstart2        = 37                ; start at color
    spreadend2          = 142               ; end at color
    colormap            = "SOM_wind_table"
  end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Data Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; point lat and lons
lats = (/58.5, 59.75, 64.5, 67.8/)
lons = (/-44.5, -41.5, -35.5, -21.0/)
locs = (/"CF1", "CF2", "DSS", "DSN"/)
n_locs = dimsizes(locs)

;;;;;;;;;;
; Load net averages
;;;;;;;;;;
  dum = new((/1/),"float")
  fill = dum@_FillValue

; net avgs
  fname1 = "net_"+datatitle1+"-extremes-fracice"
  fname2 = "net_"+datatitle2+"-extremes-fracice"
  fname3 = "net_"+datatitle3+"-extremes-fracice"

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

  ; get indices of data at chosen locations
  inds_1 = new((/n_locs,2/),"integer")
  inds_2 = new((/n_locs,2/),"integer")
  do i = 0, n_locs -1
    indices = getind_latlon2d(lat2d_1,lon2d_1,lats(i),lons(i))
    inds_1(i,:) = indices
    delete(indices)
    indices = getind_latlon2d(lat2d_2,lon2d_2,lats(i),lons(i))
    inds_2(i,:) = indices
    delete(indices)
  end do

  ; get the lat/lon that WRF has at that point
  WRF_lats_1 = new((/n_locs/),"float")
  WRF_lons_1 = new((/n_locs/),"float")
  WRF_lats_2 = new((/n_locs/),"float")
  WRF_lons_2 = new((/n_locs/),"float")
  do j = 0,n_locs-1
    WRF_lats_1(j) = lat2d_1({south_north|inds_1(j,0)},{west_east|inds_1(j,1)})
    WRF_lons_1(j)= lon2d_1({south_north|inds_1(j,0)},{west_east|inds_1(j,1)})
    WRF_lats_2(j) = lat2d_2({south_north|inds_2(j,0)},{west_east|inds_2(j,1)})
    WRF_lons_2(j)= lon2d_2({south_north|inds_2(j,0)},{west_east|inds_2(j,1)})    
  end do

  ; get indices and lat/lon for boxes around point
  WRF_lats_1_box_all = new((/n_locs, 15, 15/),"float")
  WRF_lons_1_box_all = new((/n_locs, 15, 15/),"float")
  WRF_lats_2_box_all = new((/n_locs, 3, 3/),"float")
  WRF_lons_2_box_all = new((/n_locs, 3, 3/),"float")
  do j = 0,n_locs-1
    sn_start = inds_1(j,0)-7
    sn_end = inds_1(j,0)+7
    we_start = inds_1(j,1)-7
    we_end = inds_1(j,1)+7
    WRF_lats_1_box_all(j,:,:) = lat2d_1({south_north|sn_start:sn_end},{west_east|we_start:we_end})
    WRF_lons_1_box_all(j,:,:) = lon2d_1({south_north|sn_start:sn_end},{west_east|we_start:we_end})
    delete(sn_start)
    delete(sn_end)
    delete(we_start)
    delete(we_end)
    sn_start = inds_2(j,0)-1
    sn_end = inds_2(j,0)+1
    we_start = inds_2(j,1)-1
    we_end = inds_2(j,1)+1
    WRF_lats_2_box_all(j,:,:) = lat2d_2({south_north|sn_start:sn_end},{west_east|we_start:we_end})
    WRF_lons_2_box_all(j,:,:) = lon2d_2({south_north|sn_start:sn_end},{west_east|we_start:we_end})
    delete(sn_start)
    delete(sn_end)
    delete(we_start)
    delete(we_end)
  end do
  ; make lats/lons 1d array
  WRF_lats_1_box = ndtooned(WRF_lats_1_box_all)
  WRF_lons_1_box = ndtooned(WRF_lons_1_box_all)
  WRF_lats_2_box = ndtooned(WRF_lats_2_box_all)
  WRF_lons_2_box = ndtooned(WRF_lons_2_box_all)

  ; load the variables
  var1_net = f1->$invar1$(:,:)
  var1_net@_FillValue = fill
  var1_net@units = "W m-2"
  var2_net = f2->$invar1$(:,:)
  var2_net@_FillValue = fill
  var3_net = f3->$invar1$(:,:)
  var3_net@_FillValue = fill

  seaice_1_avg  = f1->SeaIce_avg(:,:)
  seaice_1_avg@_FillValue = fill
  seaice_2_avg  = f2->SeaIce_avg(:,:)
  seaice_2_avg@_FillValue = fill
  seaice_3_avg  = f2->SeaIce_avg(:,:)
  seaice_3_avg@_FillValue = fill

print("Loaded variables from all files")

;;;;;;;;;;
; Interpolate to WRF10 size (if needed)
;;;;;;;;;;
;if (tag_1 .eq. "wrf10" .and. tag_2 .ne. "wrf10")then
;  print("Interpolating between resolutions")
;  ; Make arrays we'll need in interpolation
;  var2_net_new = new((/n_sn_1,n_we_1/),"float") 
;  var2_net_tmp_1d  = new((/n_tot_1/),"float")
;  seaice_2_avg_new = new((/n_sn_1,n_we_1/),"float") 
;  seaice_2_avg_tmp_1d  = new((/n_tot_1/),"float")
;  var3_net_new = new((/n_sn_1,n_we_1/),"float") 
;  var3_net_tmp_1d  = new((/n_tot_1/),"float")
;  seaice_3_avg_new = new((/n_sn_1,n_we_1/),"float") 
;  seaice_3_avg_tmp_1d  = new((/n_tot_1/),"float")
  
;  var2_net_1d = ndtooned(var2_net(:,:))
;  seaice_2_avg_1d = ndtooned(seaice_2_avg(:,:))
;  var3_net_1d = ndtooned(var3_net(:,:))
;  seaice_3_avg_1d = ndtooned(seaice_3_avg(:,:))
;  do i = 0, n_tot_1 - 1
;    indices_all = interp_ind(i,:)
;    n_indices = num(.not.ismissing(indices_all))
;    if (n_indices .ne. 0.0) then
;      indices = indices_all(0:n_indices-1)
;      weight_all = interp_wgt(i,:)
;      weight = weight_all(0:n_indices-1)
;      var2_net_tmp_1d(i) = sum(var2_net_1d(indices)*weight/sum(weight))
;      seaice_2_avg_tmp_1d(i) = sum(seaice_2_avg_1d(indices)*weight/sum(weight))
;      var3_net_tmp_1d(i) = sum(var3_net_1d(indices)*weight/sum(weight))
;      seaice_3_avg_tmp_1d(i) = sum(seaice_3_avg_1d(indices)*weight/sum(weight))
;      delete(indices)
;      delete(weight)
;    end if
;  end do
;    ; redimensionalize
;  var2_net_new(:,:) = onedtond(var2_net_tmp_1d,(/n_sn_1,n_we_1/))
;  seaice_2_avg_new(:,:) = onedtond(seaice_2_avg_tmp_1d,(/n_sn_1,n_we_1/))
;  var3_net_new(:,:) = onedtond(var3_net_tmp_1d,(/n_sn_1,n_we_1/))
;  seaice_3_avg_new(:,:) = onedtond(seaice_3_avg_tmp_1d,(/n_sn_1,n_we_1/))
  
;  delete(var2_net)
;  var2_net = var2_net_new
;  delete(var2_net_new)
;  copy_VarMeta(var1_net, var2_net)
;  var2_net@_FillValue = fill
;  delete(seaice_2_avg)
;  seaice_2_avg = seaice_2_avg_new
;  delete(seaice_2_avg_new)
;  copy_VarMeta(seaice_1_avg, seaice_2_avg)
;  seaice_2_avg@_FillValue = fill
;  delete(var3_net)
;  var3_net = var3_net_new
;  delete(var3_net_new)
;  copy_VarMeta(var1_net, var3_net)
;  var3_net@_FillValue = fill
;  delete(seaice_3_avg)
;  seaice_3_avg = seaice_3_avg_new
;  delete(seaice_3_avg_new)
;  copy_VarMeta(seaice_1_avg, seaice_3_avg)
;  seaice_3_avg@_FillValue = fill
;end if

  ; mask terrain - focus on ocean
  var1_net = where(z_sfc_1 .lt. 50., var1_net, var1_net@_FillValue)
  var2_net = where(z_sfc_2 .lt. 50., var2_net, var2_net@_FillValue)
  var3_net = where(z_sfc_2 .lt. 50., var3_net, var3_net@_FillValue)
  seaice_1_avg = where(z_sfc_1 .lt. 50., seaice_1_avg, seaice_1_avg@_FillValue)
  seaice_2_avg = where(z_sfc_2 .lt. 50., seaice_2_avg, seaice_2_avg@_FillValue)
  seaice_3_avg = where(z_sfc_2 .lt. 50., seaice_3_avg, seaice_3_avg@_FillValue)

  ; mask lat/lons - focus on S. Greenland region
  var1_net = where(lat2d_1 .gt. 55. .and. lat2d_1 .lt. 71. .and. lon2d_1 .lt. -19. .and. lon2d_1 .gt. -55., var1_net, var1_net@_FillValue)
  var2_net = where(lat2d_2 .gt. 55. .and. lat2d_2 .lt. 71. .and. lon2d_2 .lt. -19. .and. lon2d_2 .gt. -55., var2_net, var2_net@_FillValue)
  var3_net = where(lat2d_2 .gt. 55. .and. lat2d_2 .lt. 71. .and. lon2d_2 .lt. -19. .and. lon2d_2 .gt. -55., var3_net, var3_net@_FillValue)
  seaice_1_avg = where(lat2d_1 .gt. 55. .and. lat2d_1 .lt. 71. .and. lon2d_1 .lt. -19. .and. lon2d_1 .gt. -55., seaice_1_avg, seaice_1_avg@_FillValue)
  seaice_2_avg = where(lat2d_2 .gt. 55. .and. lat2d_2 .lt. 71. .and. lon2d_2 .lt. -19. .and. lon2d_2 .gt. -55., seaice_2_avg, seaice_2_avg@_FillValue)
  seaice_3_avg = where(lat2d_2 .gt. 55. .and. lat2d_2 .lt. 71. .and. lon2d_2 .lt. -19. .and. lon2d_2 .gt. -55., seaice_3_avg, seaice_3_avg@_FillValue)

;;;;;;;;;;
;  calculate differences
;;;;;;;;;;
  var1_net@lat2d = lat2d_1
  var1_net@lon2d = lon2d_1
  var2_net@lat2d = lat2d_2
  var2_net@lon2d = lon2d_2
  var3_net@lat2d = lat2d_2
  var3_net@lon2d = lon2d_2
  seaice_1_avg@lat2d = lat2d_1
  seaice_1_avg@lon2d = lon2d_1
  seaice_2_avg@lat2d = lat2d_2
  seaice_2_avg@lon2d = lon2d_2
  seaice_3_avg@lat2d = lat2d_2
  seaice_3_avg@lon2d = lon2d_2

  print(vartest+" "+datatitle1+" net: "+min(var1_net)+"  max: "+max(var1_net)) 
  print(vartest+" "+datatitle2+" net: "+min(var2_net)+"  max: "+max(var2_net)) 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Processing all graphs for "+vartest)
; create plots!
; plot 1 - 3 panel comparing fluxes with 6h and nodeavg
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 1 - 3 panel of net fluxes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot1").and.(plot1))then  ; if plotting is turned on
  print("Plot 1 - Net fluxes and differences")
  fout1   = vartest+"_"+tag_1+"_"+tag_2+"_200511_200703_6h_net_box"

  wks1 = gsn_open_wks("ps" ,fout1)
  additional_colors = (/"gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks1,colormap,additional_colors)
  plot = new(3, graphic)

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

; set resources for sea ice overlay
  res_ice2                            = res_ice               ; reset options
  res_ice2@cnMinLevelValF             = 0.                ; set min contour level specified above
  res_ice2@cnMaxLevelValF             = 0.85              ; set max contour level specified above
  res_ice2@cnLevelSpacingF            = 0.85              ; set contour spacing specified above
  res_ice2@cnLineColor                = "gray85"
  res_ice2@cnLineThicknessF           = 2.0
  res_ice2@cnLineDashPattern          = 6

; set poly marker resources for locations
   polyres1                         = True
   polyres1@gsMarkerIndex           = 16               ; polymarker style (16 = solid dot)
   polyres1@gsMarkerSizeF           = 1.5               ; polymarker size
   polyres1@gsMarkerColor           = "black"          ; polymarker color

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
  opts@lbLabelBarOn               = False
  ;opts@lbLabelStride              = stride1
  ;opts@pmLabelBarOrthogonalPosF   = -0.01             ; move label bar closer
  ;opts@pmLabelBarHeightF          = 0.075             ; set height of labelbar
  

  title = datatitle1
  opts@tiMainString               = title            ; title string specified from cshell
  cplot0  = gsn_csm_contour_map(wks1,var1_net,opts)
  cplot0b = gsn_csm_contour(wks1,seaice_1_avg,res_ice)
  overlay(cplot0,cplot0b)
  cplot0c = gsn_csm_contour(wks1,seaice_1_avg,res_ice2)
  overlay(cplot0,cplot0c)
  ; add in poly markers 
  dum1 = new(1, graphic)
  dum1 = gsn_add_polymarker(wks1, cplot0, WRF_lons_1, WRF_lats_1, polyres1)
  dum2 = new(1, graphic)
  dum2 = gsn_add_polymarker(wks1, cplot0, WRF_lons_2_box, WRF_lats_2_box, polyres1)
  plot(0) = cplot0
  delete(title)

  title = datatitle2
  opts@tiMainString               = title            ; title string specified from cshell
  cplot1  = gsn_csm_contour_map(wks1,var2_net,opts)
  cplot1b = gsn_csm_contour(wks1,seaice_2_avg,res_ice)
  overlay(cplot1,cplot1b)
  cplot1c = gsn_csm_contour(wks1,seaice_2_avg,res_ice2)
  overlay(cplot1,cplot1c)
  ; add in poly markers 
  dum3 = new(1, graphic)
  dum3 = gsn_add_polymarker(wks1, cplot1, WRF_lons_2, WRF_lats_2, polyres1) 
  dum4 = new(1, graphic)
  dum4 = gsn_add_polymarker(wks1, cplot1, WRF_lons_2_box, WRF_lats_2_box, polyres1)
  plot(1) = cplot1
  delete(title)

  title = datatitle3
  opts@tiMainString               = title            ; title string specified from cshell
  cplot2  = gsn_csm_contour_map(wks1,var3_net,opts)
  cplot2b = gsn_csm_contour(wks1,seaice_3_avg,res_ice)
  overlay(cplot2,cplot2b)
  cplot2c = gsn_csm_contour(wks1,seaice_3_avg,res_ice2)
  overlay(cplot2,cplot2c)
  ; add in poly markers 
  dum5 = new(1, graphic)
  dum5 = gsn_add_polymarker(wks1, cplot2, WRF_lons_2, WRF_lats_2, polyres1) 
  dum6 = new(1, graphic)
  dum6 = gsn_add_polymarker(wks1, cplot2, WRF_lons_2_box, WRF_lats_2_box, polyres1)
  plot(2) = cplot2
  delete(title)

delete(opts)

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
title_fin = vartitle1 + " (W m-2) - star = target lat/lon"

  res_pan                            = True
  res_pan@txString                   = title_fin        ; main title
  res_pan@txFontHeightF              = 0.017
  res_pan@gsnPaperOrientation        = "landscape"      ; landscape mode
  res_pan@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  res_pan@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  res_pan@gsnPanelScalePlotIndex     = 1
  res_pan@gsnMaximize                = True	       ; fill the page
  res_pan@gsnPanelLabelBar           = True
  res_pan@lbTitleString              = var3_net@units
  res_pan@lbTitlePosition            = "right"
  res_pan@lbLabelStride              = stride1
  res_pan@lbLabelFontHeightF         = 0.01
  res_pan@lbTitleJust                = "CenterLeft"
  res_pan@lbTitleFontHeightF         = 0.01
  res_pan@lbTitleDirection           = "Across"
  
  gsn_panel(wks1,(/plot/),(/1,3/),res_pan)               ; create final panel plot


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

print("Completed all plots for "+vartest)
print("Good job!")
;;;;;;;;;;;;;;;;;;;;;; END script
end
