;***************************************
; PROGRAM DESCRIPTION: This script plots single panel plots of 
;                      diagnostic variables
; INPUT DATA: WRF output or RACM-WRF output post processed with wrfout-to-cf.ncl
;             and then made into yearly seasonal mean files
; OUTPUT DATA: One Panel plot of specified variable
; Note: This can be looped with 01_wrfsinglepanel_akd_seasonal.csh 
;       to evaluate at multiple hours or variables
; CREATOR: Matt Higgins
;          Modified by Alice DuVivier - April 2012
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
;  varcode = "U10_field_diff"
;  datatitle1 = "wrf50_200511_200703_6h"
;  datatitle1b = "era_i_200511_200703_6h"
  ;; options: "wrf10_200511_200703_3h""wrf10_200511_200703_6h"
  ;; "wrf50_200511_200703_3h" "wrf50_200511_200703_6h" 
  ;; "wrf50_199701_200712_3h" "wrf50_199701_200712_6h"
  ;; "era_i_200511_200703_6h" "era_i_199701_200712_6h" 
; ******************************************************

; BEGIN SCRIPT
print("Creating node average plot for: "+varcode)
dir1 = "/data3/duvivier/SOM/training/som_"+nx_input+ny_input+"/master/node_avgs/"

; set outdir and fout names
outdir = "./"
fout   = varcode+"_"+datatitle1+"_"+datatitle1b+"_node_diff"

; get tag to let us know if it needs interpolation
title1_ch  = stringtocharacter(datatitle1)
title1_sub = title1_ch(0:4)
tag1 = chartostring(title1_sub)
title1b_ch  = stringtocharacter(datatitle1b)
title1b_sub = title1b_ch(0:4)
tag1b = chartostring(title1b_sub)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Set preferences for vartypes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; add each variable set in the c-shell 'varcode' and assign it a title and other necessary information
; Which variables need to be loaded?
if (varcode.eq."SLP_diff") then
  vartitle1 = "Average Sea Level Pressure"
  invar1 = "slp_avg"
  vartype = "2d"
  cmaptype = "pressure"
  zoom = True
end if
if (varcode.eq."SLP_anom_diff") then
  vartitle1 = "Average Sea Level Pressure Anomaly"
  invar1 = "slp_anom_avg"
  vartype = "2d"
  cmaptype = "press_anom"
  zoom = True
end if
if (varcode.eq."T_sfc_diff") then
  vartitle1 = "Average Surface Temperature"
  invar1 = "T_sfc_avg"
  vartype = "2d"
  cmaptype = "temperature"
  zoom = True
end if
if (varcode.eq."T_2m_diff") then
  vartitle1 = "Average Temperature at 2m"
  invar1 = "T_2m_avg"
  vartype = "2d"
  cmaptype = "temperature"
  zoom = True
end if
if (varcode.eq."Tgrad_2m_diff") then
  vartitle1 = "Average Temperature gradient (sfc-2m)"
  invar1 = "T_sfc_avg"
  invar2 = "T_2m_avg"
  vartype = "2d"
  cmaptype = "temp_grad"
  zoom2 = True
  load2 = True
  Tgrad = True
end if
if (varcode.eq."Tgrad_eta0_diff") then
  vartitle1 = "Average Temperature gradient (sfc-eta0)"
  invar1 = "T_sfc_avg"
  invar2 = "T_eta0_avg"
  vartype = "2d"
  cmaptype = "temp_grad"
  zoom2 = True
  load2 = True
  Tgrad = True
end if
if (varcode.eq."q_2m_diff") then
  vartitle1 = "Average mixing ratio at 2m"
  invar1 = "q_2m_avg"
  vartype = "2d"
  cmaptype = "mix_rad"
  zoom = True
  pcnt_diff = True
end if
if (varcode.eq."qgrad_2m_diff") then
  vartitle1 = "Average Mixing Ratio gradient (sfc-2m)"
  invar1 = "T_sfc_avg"
  invar2 = "q_2m_avg"
  vartype = "2d"
  cmaptype = "mix_grad"
  zoom2 = True
  load2 = True
  qgrad = True
end if
if (varcode.eq."qgrad_eta0_diff") then
  vartitle1 = "Average Mixing Ratio gradient (sfc-eta0)"
  invar1 = "T_sfc_avg"
  invar2 = "q_eta0_avg"
  vartype = "2d"
  cmaptype = "mix_grad"
  zoom2 = True
  load2 = True
  qgrad = True
end if
if (varcode.eq."precip_tot_diff") then
  vartitle1 = "Average Total Precipitation"
  invar1 = "precip_tot_avg"
  vartype = "2d"
  cmaptype = "precip"
  zoom2 = True
  pcnt_diff = True
end if
if (varcode.eq."U10_field_diff") then
  vartitle1 = "Average Wind Field at 10m"
  invar1 = "u_10m_tr_avg"
  invar2 ="v_10m_tr_avg"
  vartype = "2d"
  cmaptype = "wind"
  find_field = True
  zoom2 = True
  load2 = True
end if
if (varcode.eq."U10_speed_diff") then
  vartitle1 = "Average Wind Speed at 10m"
  invar1 = "ws_10m_avg"
  vartype = "2d"
  cmaptype = "wind"
  zoom2 = True
end if
if (varcode.eq."U0_diff") then
  vartitle1 = "Average Wind Speed at eta0"
  invar1 = "u_tr_eta0_avg"
  invar2 ="v_tr_eta0_avg"
  vartype = "2d"
  cmaptype = "wind"
  find_speed = True
  zoom2 = True
  load2 = True
end if
if (varcode.eq."WSC_diff") then
  vartitle1 = "Average Wind Stress Curl"
  invar1 = "wsc_avg"
  vartype = "2d"
  cmaptype = "wsc"
  zoom2 = True
end if
if (varcode.eq."SH_diff") then
  vartitle1 = "Average Sensible Heat Flux at Sur"
  invar1 = "SHFlx_avg"
  vartype = "2d"
  cmaptype = "flux"
  zoom2 = True
end if
if (varcode.eq."LH_diff") then
  vartitle1 = "Average Latent Heat Flux at Sur"
  invar1 = "LHFlx_avg"
  vartype = "2d"
  cmaptype = "flux"
  zoom2 = True
end if
if (varcode.eq."SWUS_diff") then
  vartitle1 = "Average Shortwave up at surface"
  invar1 = "SW_u_avg"
  vartype = "2d"
  cmaptype = "radflux"
  zoom2 = True
end if
if (varcode.eq."SWDS_diff") then
  vartitle1 = "Average Shortwave down at surface"
  invar1 = "SW_d_avg"
  vartype = "2d"
  cmaptype = "radflux"
  zoom2 = True
end if
if (varcode.eq."LWUS_diff") then
  vartitle1 = "Average Longwave up at surface"
  invar1 = "LW_u_avg"
  vartype = "2d"
  cmaptype = "radflux"
  zoom2 = True
end if
if (varcode.eq."LWDS_diff") then
  vartitle1 = "Average Longwave down at surface"
  invar1 = "LW_d_avg"
  vartype = "2d"
  cmaptype = "radflux"
  zoom2 = True
end if
if (varcode.eq."TurbFlx_diff") then
  vartitle1 = "Average Net Turbulent Flux at Sur (LH+SH)"
  invar1 = "LHFlx_avg"
  invar2 = "SHFlx_avg"
  vartype = "2d"
  cmaptype = "netflux"
  zoom2 = True
  load2 = True
  netflx = True
end if
if (varcode.eq."RadFlx_diff") then
  vartitle1 = "Average Net Radiative Flux at Sur (SWU-SWD+LSU-LWD)"
  invar1 = "SW_u_avg"
  invar2 = "SW_d_avg"
  invar3 = "LW_u_avg"
  invar4 = "LW_d_avg"
  vartype = "2d"
  cmaptype = "radflux"
  zoom2 = True
  load4 = True
  netflx = True
end if
if (varcode.eq."NetFlx_diff") then
  vartitle1 = "Average Net Flux at Sur (Rad+Turb: + up)"
  invar1 = "SW_u_avg"
  invar2 = "SW_d_avg"
  invar3 = "LW_u_avg"
  invar4 = "LW_d_avg"
  invar5 = "SHFlx_avg"
  invar6 = "LHFlx_avg"
  vartype = "2d"
  cmaptype = "netflux"
  zoom2 = True
  load6 = True
  netflx = True
end if

; Set the contour interval for each input variable   
; set contour limits manually:
  if (cmaptype.eq."pressure") then
    cmin1               = -20.
    cmax1               = 20.
    clev1               = 2.
    stride1             = 2                  ; label stride
    plotlines           = False              ; lines for reg plot
    cntype              = "AreaFill"
    spreadstart1        = 2                  ; start at color
    spreadend1          = 102                ; end at color
    colormap            = "slp_anoms.dave"
  end if
  if (cmaptype.eq."press_anom") then
    cmin1               = -20.
    cmax1               = 20.
    clev1               = 2.
    stride1             = 2                  ; label stride
    plotlines           = False              ; lines for reg plot
    cntype              = "AreaFill"
    spreadstart1        = 2                  ; start at color
    spreadend1          = 102                ; end at color
    colormap            = "BlWhRe"
  end if
  if (cmaptype.eq."temperature") then
    cmin1               = -5.
    cmax1               = 5.
    clev1               = 0.5
    stride1             = 2                 ; label stride
    plotlines           = False              ; lines for reg plot
    cntype              = "AreaFill"         ; type of contour fill
    spreadstart1        = 67                 ; start at color
    spreadend1          = 107                ; end at color
    colormap            = "temp64_anoms.dave"
  end if
  if (cmaptype.eq."temp_grad") then
    cmin1               = -5.
    cmax1               = 5.
    clev1               = 0.5
    stride1             = 2                 ; label stride
    plotlines           = False              ; lines for reg plot
    cntype              = "AreaFill"         ; type of contour fill
    spreadstart1        = 67                 ; start at color
    spreadend1          = 107                ; end at color
    colormap            = "temp64_anoms.dave"
  end if
  if (cmaptype.eq."mix_rad") then
    cmin1               = -100. ;-2.5E-3
    cmax1               = 100. ;2.5E-3
    clev1               = 10. ;2.5E-4
    stride1             = 2                 ; label stride
    plotlines           = False              ; lines for reg plot
    cntype              = "AreaFill"      ; type of contour fill
    spreadstart1        = 2                 ; start at color
    spreadend1          = 103                ; end at color
    colormap            = "BrownBlue"
  end if
  if (cmaptype.eq."mix_grad") then
    cmin1               = -2.5E-3
    cmax1               = 2.5E-3
    clev1               = 2.5E-4
    stride1             = 2                 ; label stride
    plotlines           = False              ; lines for reg plot
    cntype              = "AreaFill"      ; type of contour fill
    spreadstart1        = 2                 ; start at color
    spreadend1          = 103                ; end at color
    colormap            = "BrownBlue"
  end if
  if (cmaptype.eq."wind") then
    cmin1               = -20.
    cmax1               = 20.
    clev1               = 2.
    stride1             = 1                 ; label stride
    plotlines           = False              ; lines for reg plot
    cntype              = "AreaFill"
    spreadstart1        = 2                 ; start at color
    spreadend1          = 102                ; end at color
    colormap            = "BlWhRe"
  end if
  if (cmaptype.eq."wsc") then
    cmin1               = -1.
    cmax1               = 1.
    clev1               = 1.0E-1
    stride1             = 2                 ; label stride
    plotlines           = False              ; lines for reg plot
    cntype              = "AreaFill"
    spreadstart1        = 2                 ; start at color
    spreadend1          = 102                ; end at color
    colormap            = "BlWhRe"
  end if
  if (cmaptype.eq."ustar") then
    cmin1               = 0.
    cmax1               = 1.5
    clev1               = 0.1
    stride1             = 1                 ; label stride
    plotlines           = False              ; lines for reg plot
    cntype              = "AreaFill"
    spreadstart1        = 2                 ; start at color
    spreadend1          = 35                ; end at color
    colormap            = "wind_color_table_SOM"
  end if
  if (cmaptype.eq."precip") then
    cmin1               =  -100. ;-2.5E-4
    cmax1               =  100.  ;2.5E-4
    clev1               =  10.   ;2.5E-5
    stride1             = 2                 ; label stride
    plotlines           = False             ; lines for reg plot
    cntype              = "AreaFill"        ; type of contour fill
    spreadstart1        = 2                ; start at color
    spreadend1          = 102               ; end at color
    colormap            = "BrownBlue"
  end if
  if (cmaptype.eq."ice") then
    cmin1               =  0.
    cmax1               =  0.15
    clev1               =  0.15
    stride1             = 1                 ; label stride
    plotlines           = False             ; lines for reg plot
    cntype              = "AreaFill"        ; type of contour fill
    spreadstart1        = 51                ; start at color
    spreadend1          = 103               ; end at color
    colormap            = "BrownBlue"
  end if
  if (cmaptype.eq."flux") then
    cmin1               =  -150.
    cmax1               =  150.
    clev1               =  10.
    stride1             = 2                 ; label stride
    stride2             = 2                 ; label stride diff plot
    plotlines           = False              ; lines for reg plot
    cntype              = "AreaFill"      ; type of fill for contours 
    spreadstart1        = 2                 ; start at color
    spreadend1          = 250               ; end at color
    colormap            = "BlueYellowRed_mod"
  end if
  if (cmaptype.eq."netflux") then
    cmin1               =  -600.
    cmax1               =  600.
    clev1               =  40.
    stride1             = 2                 ; label stride
    stride2             = 2                 ; label stride diff plot
    plotlines           = False              ; lines for reg plot
    cntype              = "AreaFill"      ; type of fill for contours 
    spreadstart1        = 2                 ; start at color
    spreadend1          = 250               ; end at color
    colormap            = "BlueYellowRed_mod"
  end if
  if (cmaptype.eq."radflux") then
    cmin1               =  -100.
    cmax1               =  100.
    clev1               =  10.
    stride1             = 2                 ; label stride
    plotlines           = False              ; lines for reg plot
    cntype              = "AreaFill"
    spreadstart1        = 2                 ; start at color
    spreadend1          = 250               ; end at color
    colormap            = "BlueYellowRed_mod"
  end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Data Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;
; load in node averages
;;;;;;;;;;
; Load in lat/lon to get information for WRF10 domain
  fname0 = "node_0x_0y_"+datatitle1
  f0 = addfile(dir1 + fname0 + ".nc","r")
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
  fname0b = "node_0x_0y_"+datatitle1b
  f0b = addfile(dir1 + fname0b + ".nc","r")
  lat2d_1b = f0b->lat
  lon2d_1b = f0b->lon
  z_sfc_1b = f0b->Z_sfc
  delete(fname0b)
  delete(f0b)

  dims = dimsizes(lat2d_1b)     ; get lat/lon dimensions
  n_sn_1b = dims(0)              ; get south/north points
  n_we_1b = dims(1)              ; get west/east points
  n_tot_1b = n_sn_1b*n_we_1b              ; get total number of points in high res domain
  delete(dims)

  ; get weights and indicies for regridding (WRF50 and era weightings are identical)
  weightin = addfile("/data3/duvivier/SOM/DATA/weightings_WRF50_to_WRF10.nc","r")
  interp_ind = weightin->interp_ind
  interp_wgt = weightin->interp_wgt

  ; Calculate node counts and frequencies for comparison of interest
  nx_node = stringtoint(nx_input)
  ny_node = stringtoint(ny_input)
  nnode = nx_node*ny_node

  ; create all-node array for node average variable
  if (invar1.eq."q_eta0_avg" .or. invar1.eq."T_eta0_avg") then
    var1 = new((/nnode,n_sn_1,n_we_1/),"double")
    var1b = new((/nnode,n_sn_1b,n_we_1b/),"double")
  else ;(every other variable)
    var1 = new((/nnode,n_sn_1,n_we_1/),"float")
    var1b = new((/nnode,n_sn_1b,n_we_1b/),"float")
  end if
  fill = var1@_FillValue

; create variables for other combinations
  if (isvar("load2").and.(load2))
    if (invar2.eq."q_eta0_avg" .or. invar2.eq."T_eta0_avg") then
      var2 = new((/nnode,n_sn_1,n_we_1/),"double") 
      var2b = new((/nnode,n_sn_1b,n_we_1b/),"double")
    else   
      var2 = new((/nnode,n_sn_1,n_we_1/),"float") 
      var2b = new((/nnode,n_sn_1b,n_we_1b/),"float")
    end if
  end if
  if (isvar("load4").and.(load4))
    var2 = new((/nnode,n_sn_1,n_we_1/),"float")
    var2b = new((/nnode,n_sn_1b,n_we_1b/),"float")   
    var3 = new((/nnode,n_sn_1,n_we_1/),"float")
    var3b = new((/nnode,n_sn_1b,n_we_1b/),"float") 
    var4 = new((/nnode,n_sn_1,n_we_1/),"float") 
    var4b = new((/nnode,n_sn_1b,n_we_1b/),"float") 
  end if
  if (isvar("load6").and.(load6))
    var2 = new((/nnode,n_sn_1,n_we_1/),"float")
    var2b = new((/nnode,n_sn_1b,n_we_1b/),"float")    
    var3 = new((/nnode,n_sn_1,n_we_1/),"float") 
    var3b = new((/nnode,n_sn_1b,n_we_1b/),"float")
    var4 = new((/nnode,n_sn_1,n_we_1/),"float")
    var4b = new((/nnode,n_sn_1b,n_we_1b/),"float") 
    var5 = new((/nnode,n_sn_1,n_we_1/),"float")
    var5b = new((/nnode,n_sn_1b,n_we_1b/),"float")
    var6 = new((/nnode,n_sn_1,n_we_1/),"float") 
    var6b = new((/nnode,n_sn_1b,n_we_1b/),"float") 
  end if
  if (isvar("qgrad").and.(qgrad))then
    slp = new((/nnode,n_sn_1,n_we_1/),"float")
    slpb = new((/nnode,n_sn_1b,n_we_1b/),"float")
  end if
  ; make sea ice var - overlay with everything
  seaice = new((/nnode,n_sn_1,n_we_1/),"float")

n = 0
; loop through each node
do y = 0, ny_node - 1
 do x = 0, nx_node - 1
  print("node: "+x+","+y)

  fname1 = "node_"+x+"x_"+y+"y_"+datatitle1
  f1 = addfile(dir1 + fname1 + ".nc","r")
  var1(n,:,:) = f1->$invar1$(south_north|:,west_east|:)

  fname1b = "node_"+x+"x_"+y+"y_"+datatitle1b
  f1b = addfile(dir1 + fname1b + ".nc","r")
  var1b(n,:,:) = f1b->$invar1$(south_north|:,west_east|:)

  if (isvar("load2").and.(load2)) then
    var2(n,:,:)  = f1->$invar2$(south_north|:,west_east|:)
    var2b(n,:,:) = f1b->$invar2$(south_north|:,west_east|:)
  end if
  if (isvar("load4").and.(load4)) then
    var2(n,:,:) = f1->$invar2$(south_north|:,west_east|:)
    var2b(n,:,:) = f1b->$invar2$(south_north|:,west_east|:)
    var3(n,:,:) = f1->$invar3$(south_north|:,west_east|:)
    var3b(n,:,:) = f1b->$invar3$(south_north|:,west_east|:)
    var4(n,:,:) = f1->$invar4$(south_north|:,west_east|:)
    var4b(n,:,:) = f1b->$invar4$(south_north|:,west_east|:)
  end if
  if (isvar("load6").and.(load6)) then
    var2(n,:,:) = f1->$invar2$(south_north|:,west_east|:)
    var2b(n,:,:) = f1b->$invar2$(south_north|:,west_east|:)
    var3(n,:,:) = f1->$invar3$(south_north|:,west_east|:)
    var3b(n,:,:) = f1b->$invar3$(south_north|:,west_east|:)
    var4(n,:,:) = f1->$invar4$(south_north|:,west_east|:)
    var4b(n,:,:) = f1b->$invar4$(south_north|:,west_east|:)
    var5(n,:,:) = f1->$invar5$(south_north|:,west_east|:)
    var5b(n,:,:) = f1b->$invar5$(south_north|:,west_east|:)
    var6(n,:,:) = f1->$invar6$(south_north|:,west_east|:)
    var6b(n,:,:) = f1b->$invar6$(south_north|:,west_east|:)
  end if
  if (isvar("qgrad").and.(qgrad))then
    slp(n,:,:) = f1->slp_avg(south_north|:,west_east|:)
    slpb(n,:,:) = f1b->slp_avg(south_north|:,west_east|:)
  end if
  seaice(n,:,:) = f1->SeaIce_avg(south_north|:,west_east|:)

  ; mask terrain - focus on ocean
  var1(n,:,:) = where(z_sfc_1 .lt. 500., var1(n,:,:), var1@_FillValue)
  var1b(n,:,:) = where(z_sfc_1b .lt. 500., var1b(n,:,:), var1b@_FillValue)

  ; delete vars to use in next loop
  delete(fname1)
  delete(f1)
  delete(fname1b)
  delete(f1b)

  n = n+1
 end do
end do
delete(n)

print("Loaded variables from both files")

;;;;;;;;;;
; manipulate arrays as needed - post interpolation
;;;;;;;;;;
print("Manipulating vars as needed")
if (isvar("netflx").and.(netflx))then
  if (isvar("load2").and.(load2))then
    var1 = var1+var2  ; LH+SH
    delete(var2)
    var1@long_name = "Net turbulent fluxes"
    var1b = var1b+var2b
    delete(var2b)
  end if
  if (isvar("load4").and.(load4))then
    var1 = var1-var2+var3-var4 ;SWU-SWD+LWU-LWD
    delete(var2)
    delete(var3)
    delete(var4)
    var1@long_name = "Net radiative fluxes"
    var1b = var1b-var2b+var3b-var4b
    delete(var2b)
    delete(var3b)
    delete(var4b)
  end if
  if (isvar("load6").and.(load6))then
    var1 = (var1-var2+var3-var4)+var5+var6 ;(SWU-SWD+LWU-LWD)+SHFlx+LHFlx
    delete(var2)
    delete(var3)
    delete(var4)
    delete(var5)
    delete(var6)
    var1@long_name = "Net surface fluxes"
    var1b = (var1b-var2b+var3b-var4b)+var5b+var6b ;(SWU-SWD+LWU-LWD)+SHFlx+LHFlx
    delete(var2b)
    delete(var3b)
    delete(var4b)
    delete(var5b)
    delete(var6b)
  end if
  var1@units = "W m-2"
end if
if (isvar("find_field").and.(find_field)) then
  ; find wind speed using vectors
  var1 = sqrt(var1^2+var2^2)
  var1b = sqrt(var1b^2+var2b^2)
  var1@long_name = "Net Wind Field"
  var1@standard_name = "Wind Field"
  delete(var2)
  delete(var2b)
end if
if (isvar("convert_to_C").and.(convert_to_C)) then
  var1 = var1 - 273.15
  var1b = var1b - 273.15
  var1@units = "C"
end if
if (isvar("Tgrad").and.(Tgrad)) then
  if (invar2.eq."T_eta0_avg") then ; WRF files need type conversion
    tmp2 = doubletofloat(var2)
    delete(var2)
    var2 = tmp2
    delete(tmp2)
    tmp2b = doubletofloat(var2b)
    delete(var2b)
    var2b = tmp2b
    delete(tmp2b)
  end if
  if (tag1b.eq."era_i") then ;ERA-I files have sfc temp in C
    var1b = var1b-273.15 
    var1b@units = "degC"
  end if
  var1 = var1 - var2
  var1@units = "C"
  delete(var2)
  var1b = var1b-var2b
  delete(var2b)
end if
if (isvar("qgrad").and.(qgrad)) then
  if (invar2.eq."q_eta0_avg") then ; WRF files need type conversion
    tmp2 = doubletofloat(var2)
    delete(var2)
    var2 = tmp2
    delete(tmp2)
    tmp2b = doubletofloat(var2b)
    delete(var2b)
    var2b = tmp2b
    delete(tmp2b)
  end if
    ; calculate surface saturation mixing ratio
  var1  = var1-273.15  ; convert sfc temp to Celsius (okay for both wrf and era)
  satvp = 0.6112*exp((17.67*var1)/(243.5+var1))*10.0 ; Saturation vap. press in hPa    
  satmr = 0.622*(satvp/(slp-satvp)) ; Saturation mixing ratio in kg/kg
  delete(var1)
  var1 = satmr
  delete(satvp)
  delete(satmr)
  ; now calculate gradient  
  var1 = var1 - var2
  var1@units = "kg kg-1"
  delete(var2)
  ; calculate surface saturation mixing ratio
  var1b  = var1b-273.15  ; convert sfc temp to Celsius
  satvp = 0.6112*exp((17.67*var1b)/(243.5+var1b))*10.0 ; Saturation vap. press in hPa    
  satmr = 0.622*(satvp/(slpb-satvp)) ; Saturation mixing ratio in kg/kg
  delete(var1b)
  var1b = satmr
  delete(satvp)
  delete(satmr)
  ; now calculate gradient  
  var1b = var1b - var2b
  var1b@units = "kg kg-1"
  delete(var2b)
end if

;;;;;;;;;;
; Interpolate to WRF10 size (if needed)
;;;;;;;;;;
if (tag1 .eq. "wrf10" .and. tag1b .ne. "wrf10")then
  print("Interpolating between resolutions")
  ; Make arrays we'll need in interpolation
  var1b_new = new((/nnode,n_sn_1,n_we_1/),"float") 
  var1b_tmp_1d  = new((/n_tot_1/),"float")

  do n = 0, nnode - 1
    var1b_1d = ndtooned(var1b(n,:,:))
    do i = 0, n_tot_1 - 1
      indices_all = interp_ind(i,:)
      n_indices = num(.not.ismissing(indices_all))
      if (n_indices .ne. 0.0) then
        indices = indices_all(0:n_indices-1)
        weight_all = interp_wgt(i,:)
        weight = weight_all(0:n_indices-1)
        var1b_tmp_1d(i) = sum(var1b_1d(indices)*weight/sum(weight))
        delete(indices)
        delete(weight)
      end if
    end do
    ; redimensionalize
    var1b_new(n,:,:) = onedtond(var1b_tmp_1d,(/n_sn_1,n_we_1/))
    ; counter
    print("created node avg "+n+" of "+nnode)
  end do

  delete(var1b)
  var1b = var1b_new
  delete(var1b_new)
  copy_VarMeta(var1, var1b)
  copy_VarCoords(var1,var1b)
  var1b@_FillValue = fill
end if

;;;;;;;;;;
; Find difference
;;;;;;;;;;
; for precip and mixing ratio fields, make %diff field instead
if (isvar("pcnt_diff").and.(pcnt_diff)) then
  ; moisture variables - % diff
  test = new((/1/),"float")
  var1@_FillValue = test(0)
  var1 = where(var1.eq.0.,var1@_FillValue,var1) ; deal with zero denom    
  diff = ((var1 - var1b)/var1b)*100.
  vartitle1 = "% Difference in "+vartitle1+"~C~ ("+datatitle1+" - "+datatitle1b+")/"+datatitle1b

else 
  diff = var1 - var1b
  vartitle1 = "Difference in "+vartitle1+"~C~ ("+datatitle1+" - "+datatitle1b+")"
end if

; assign lat/lon info
diff@lat2d = lat2d_1
diff@lon2d = lon2d_1

; seaice from first data file to overlay
seaice@lat2d = lat2d_1
seaice@lon2d = lon2d_1

; prints together the variable title (set above for each type of data) with title1 (defined in cshell as the wrf or met info) and the max and min values
  print(vartitle1+" min: "+min(diff)+"  max: "+max(diff)) 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; create plots!
print("Processing som node average graphs for "+varcode)

  wks = gsn_open_wks("ps" ,fout)
  additional_colors = (/"gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks,colormap,additional_colors)
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
 
  if (isvar("zoom").and.(zoom))then
    res@mpLimitMode                 = "LatLon"	     ; how to zoom in on map
    res@mpMinLatF                   = 56.              ; set the minimum latitude 
    res@mpMaxLatF                   = 72.              ; set the maximum latitude 
    res@mpMinLonF                   = -54.0            ; set the minimum longitude 
    res@mpMaxLonF                   = -15.0            ; set the maximum longitude 
  end if
  if (isvar("zoom2").and.(zoom2))then
    res@mpLimitMode                 = "LatLon"	     ; how to zoom in on map
    res@mpMinLatF                   = 56.              ; set the minimum latitude 
    res@mpMaxLatF                   = 70.              ; set the maximum latitude 
    res@mpMinLonF                   = -54.0            ; set the minimum longitude 
    res@mpMaxLonF                   = -20.0            ; set the maximum longitude 
  end if

  ; set contour information
  res@cnFillMode                 = cntype
  res@cnFillOn                   = True              ; turn on filled contours
  res@gsnSpreadColors            = True              ; use full colormap
  res@gsnSpreadColorStart        = spreadstart1      ; start at color specified for each variable above
  res@gsnSpreadColorEnd          = spreadend1        ; end at color specified above
  res@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  res@cnMinLevelValF             = cmin1             ; set min contour level specified above
  res@cnMaxLevelValF             = cmax1             ; set max contour level specified above
  res@cnLevelSpacingF            = clev1             ; set contour spacing specified above
  res@cnLinesOn                  = plotlines         ; contour lines specified above
  res@cnLineLabelsOn             = plotlines         ; line labels on specified above
  res@cnMissingValFillColor      = "gray85"          ; missing value color
  res@cnMissingValFillPattern    = 0                 ; fill in
  res@cnMissingValPerimOn        = True
  res@cnMissingValPerimColor     = "black"
  res@lbLabelBarOn               = False             ; have single label bar

; set resources for sea ice overlay
  res2                            = True               ; reset options
  res2@gsnLeftString              = ""
  res2@gsnRightString             = ""
  res2@gsnFrame                   = False             ; Do not draw plot 
  res2@gsnDraw                    = False             ; Do not advance fr
  res2@cnInfoLabelOn              = False             ; Turn off info on contours at bottom
  res2@cnFillOn                   = False             ; turn on filled contours
  res2@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  res2@cnMinLevelValF             = 0.                ; set min contour level specified above
  res2@cnMaxLevelValF             = 0.15              ; set max contour level specified above
  res2@cnLevelSpacingF            = 0.15              ; set contour spacing specified above
  res2@cnLinesOn                  = True              ; contour lines specified above
  res2@cnLineLabelsOn             = False             ; line labels on specified above
  res2@cnLineThicknessF           = 1.5
  res2@tiXAxisOn                  = False
  res2@tiYAxisOn                  = False
 
xpos = 0
ypos = 0

do n = 0, nnode-1
  print("Plotting graph "+n+" ("+xpos+","+ypos+")")
  diff_2d = diff(n,:,:)
  seaice_2d = seaice(n,:,:)

  res@gsnLeftString = "("+xpos+","+ypos+")"  ; (this changes)
  res@gsnLeftStringParallelPosF = 0.02 ; scoot it in just a bit as well

  cplot  = gsn_csm_contour_map(wks,diff_2d,res)
  cplot2 = gsn_csm_contour(wks,seaice_2d,res2)
  overlay(cplot,cplot2)
  plot(n) = cplot
;  plot(n) = gsn_csm_contour_map(wks,diff_2d,res)

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
title_fin = "Node "+vartitle1

res_pan                       = True ; panel resources
res_pan@txString              = title_fin
res_pan@txFontHeightF         = 0.015 ; title font height
res_pan@gsnPaperOrientation   = "landscape" ; landscape mode
res_pan@gsnMaximize           = True ; make it big
res_pan@gsnPanelLabelBar      = True ; common label bar
res_pan@lbTitleString         = var1@units
res_pan@lbTitlePosition       = "right"
res_pan@lbLabelStride         = stride1
;res_pan@lbLabelAutoStride     = "true"
res_pan@lbLabelFontHeightF    = 0.01
res_pan@lbTitleJust           = "CenterLeft"
res_pan@lbTitleFontHeightF    = 0.01 
res_pan@lbTitleDirection      = "Across"

;  pnlres@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
;  pnlres@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.


gsn_panel(wks,plot,(/ny_node, nx_node/),res_pan)

print("converting to png")
; convert to png
  convert_cmd = "convert -density 300 "+fout+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout+".png"

  system(convert_cmd)

;;;;;;;;;;;;;;;;;;;;;; END script
end
