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
dir1 = "/data3/duvivier/SOM/analysis/fourpanel/data/seasonal_avgs/"
dir2 = "/data3/duvivier/SOM/analysis/fourpanel/data/seasonal_avgs/"
title1 = "era_i"
title2 = "wrf50"
year = "1997-2007"
seas = "NDJFM"
varcode = "SLP"

; set if this is a zoomed plot or the whole domain
zoom = False
whole_dom = True

; BEGIN SCRIPT
print("Running Four panel for " + title1 + " and " + title2)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Set preferences for vartypes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; add each variable set in the c-shell 'varcode' and assign it a title and other necessary information
; Which variables need to be loaded?
 if (varcode.eq."SLP") then
    vartitle1 = "Sea Level Pressure"
    invar1 = "slp"
    vartype = "2d"
    cmaptype = "pressure"
 end if
  if (varcode.eq."Z850") then
    vartitle1 = "Z at 850 mb"
    invar1 = "Z_p"
    preslev = 850
    vartype = "3d"
    cmaptype = "geopotential_low"
  end if
 if (varcode.eq."Z700") then
    vartitle1 = "Z at 700 mb"
    invar1 = "Z_p"
    preslev = 700
    vartype = "3d"
    cmaptype = "geopotential_low_mid"
  end if
  if (varcode.eq."Z500") then
    vartitle1 = "Z at 500 mb"
    invar1 = "Z_p"
    preslev = 500
    vartype = "3d"
    cmaptype = "geopotential_mid"
  end if
  if (varcode.eq."Z300") then
    vartitle1 = "Z at 300 mb"
    invar1 = "Z_p"
    preslev = 300
    vartype = "3d"
    cmaptype = "geopotential_high"
  end if
  if (varcode.eq."T_sfc") then
    vartitle1 = "Temperature at surface"
    invar1 = "T_sfc"
    invar2 = "T_sfc"
    vartype = "2d"
    cmaptype = "temperature"
    convert_to_C = True
  end if
  if (varcode.eq."T2m") then
    vartitle1 = "Temperature at 2 m"
    invar1 = "T_2m"
    vartype = "2d"
    cmaptype = "temperature"
  end if
  if (varcode.eq."T850") then
    vartitle1 = "Temperature at 850 mb"
    invar1 = "T_p"
    preslev = 850
    vartype = "3d"
    cmaptype = "temperature"
    convert_to_C = True
  end if
  if (varcode.eq."T700") then
    vartitle1 = "Temperature at 700 mb"
    invar1 = "T_p"
    preslev = 700
    vartype = "3d"
    cmaptype = "temperature"
    convert_to_C = True
  end if
  if (varcode.eq."T500") then
    vartitle1 = "Temperature at 500 mb"
    invar1 = "T_p"
    preslev = 500
    vartype = "3d"
    cmaptype = "temperature"
    convert_to_C = True
  end if
  if (varcode.eq."T300") then
    vartitle1 = "Temperature at 300 mb"
    invar1 = "T_p"
    preslev = 300
    vartype = "3d"
    cmaptype = "temperature"
    convert_to_C = True
  end if
  if (varcode.eq."Q2m") then
    vartitle1 = "Mixing Ratio at 2 m"
    invar1 = "q_2m"
    vartype = "2d"
    cmaptype = "mix_rad"
    pcnt_diff = True
  end if
  if (varcode.eq."Q850") then
    vartitle1 = "Mixing Ratio at 850 mb"
    invar1 = "q_p"
    preslev = 850
    vartype = "3d"
    cmaptype = "mix_rad_mid"
    pcnt_diff = True
  end if
  if (varcode.eq."Q700") then
    vartitle1 = "Mixing Ratio at 700 mb"
    invar1 = "q_p"
    preslev = 700
    vartype = "3d"
    cmaptype = "mix_rad_mid"
    pcnt_diff = True
  end if
  if (varcode.eq."Q500") then
    vartitle1 = "Mixing Ratio at 500 mb"
    invar1 = "q_p"
    preslev = 500
    vartype = "3d"
    cmaptype = "mix_rad_mid"
    pcnt_diff = True
  end if
  if (varcode.eq."Q300") then
    vartitle1 = "Mixing Ratio at 300 mb"
    invar1 = "q_p"
    preslev = 300
    vartype = "3d"
    cmaptype = "mix_rad_mid"
    pcnt_diff = True
  end if
  if (varcode.eq."precip") then
    vartitle1 = "Precipitation"
    if(title1.eq."era_i")then
      invar0 = "PrecipRate" ; ERA_I has different precip name
    end if
    invar1 = "precip_g"
    invar2 = "precip_c"    ; WRF needs to sum grid and convective precip
    vartype = "2d"
    cmaptype = "precip"
    pcnt_diff = True
    load_two = True
    load_latlon = True
  end if
  if (varcode.eq."U0") then
    vartitle1 = "Wind Speed at lowest eta level"
    invar1 = "u_tr_eta0"
    invar11 ="v_tr_eta0"
    vartype = "2d"
    cmaptype = "wind"
    find_speed = True
  end if
  if (varcode.eq."ustar") then
    vartitle1 = "friction velocity (ustar)"
    invar1 = "u_star"
    vartype = "2d"
    cmaptype = "ustar"
  end if
  if (varcode.eq."SH") then
    vartitle1 = "Sensible Heat Flux at Sur"
    invar1 = "SHFlx"
    vartype = "2d"
    cmaptype = "flux"
    overlay_c = True
  end if
  if (varcode.eq."LH") then
    vartitle1 = "Latent Heat Flux at Sur"
    invar1 = "LHFlx"
    vartype = "2d"
    cmaptype = "flux"
    overlay_c = True
  end if
  if (varcode.eq."SWUS") then
    vartitle1 = "Shortwave up at surface"
    invar1 = "rsus"
    vartype = "2d"
    cmaptype = "swflux"
    deaccum = True
    load_latlon = True
  end if
  if (varcode.eq."SWDS") then
    vartitle1 = "Shortwave down at surface"
    invar1 = "rsds"
    vartype = "2d"
    cmaptype = "swflux"
    deaccum = True
    load_latlon = True
  end if
  if (varcode.eq."LWUS") then
    vartitle1 = "Longwave up at surface"
    invar1 = "rlus"
    vartype = "2d"
    cmaptype = "lwflux"
    deaccum = True
    load_latlon = True
  end if
  if (varcode.eq."LWDS") then
    vartitle1 = "Longwave down at surface"
    invar1 = "rlds"
    vartype = "2d"
    cmaptype = "lwflux"
    deaccum = True
    load_latlon = True
  end if
  if (varcode.eq."SWUT") then
    vartitle1 = "Shortwave up at TOA"
    invar1 = "rsut"
    vartype = "2d"
    cmaptype = "swflux"
    deaccum = True
    load_latlon = True
  end if
  if (varcode.eq."SWDT") then
    vartitle1 = "Shortwave down at TOA"
    invar1 = "rsdt"
    vartype = "2d"
    cmaptype = "swflux"
    deaccum = True
    load_latlon = True
  end if
  if (varcode.eq."LWUT") then
    vartitle1 = "Longwave up at TOA"
    invar1 = "rlut"
    vartype = "2d"
    cmaptype = "lwflux"
    deaccum = True
    load_latlon = True
  end if
  if (varcode.eq."LWDT") then
    vartitle1 = "Longwave down at TOA"
    invar1 = "rldt"
    vartype = "2d"
    cmaptype = "lwflux"
    deaccum = True
    load_latlon = True
  end if
  if (varcode.eq."LWP") then
    vartitle1 = "Liquid Water Path - total column integrated"
    invar1 = "LWP"
    vartype = "2d"
    cmaptype = "water_path"
    pcnt_diff = True
  end if
  if (varcode.eq."IWP") then
    vartitle1 = "Ice Water Path - total column integrated"
    invar1 = "IWP"
    vartype = "2d"
    cmaptype = "water_path"
    pcnt_diff = True
  end if
  if (varcode.eq."TWP") then
    vartitle1 = "Total Water Path - total column integrated"
    invar1 = "IWP"
    invar2 = "LWP"
    vartype = "2d"
    cmaptype = "water_path"
    pcnt_diff = True
    load_two = True
  end if
  if (varcode.eq."PW") then
    vartitle1 = "Precipitable Water - total column integrated"
    invar1 = "PW"
    vartype = "2d"
    cmaptype = "precip_water"
    pcnt_diff = True
  end if
  if (varcode.eq."LWP_low") then
    vartitle1 = "Liquid Water Path - low integrated"
    invar1 = "LWP_low"
    vartype = "2d"
    cmaptype = "water_path"
    pcnt_diff = True
  end if
  if (varcode.eq."IWP_low") then
    vartitle1 = "Ice Water Path - low integrated"
    invar1 = "IWP_low"
    vartype = "2d"
    cmaptype = "water_path_sm"
    pcnt_diff = True
  end if
  if (varcode.eq."TWP_low") then
    vartitle1 = "Total Water Path - low integrated"
    invar1 = "IWP_low"
    invar2 = "LWP_low"
    vartype = "2d"
    cmaptype = "water_path"
    pcnt_diff = True
    load_two = True
  end if
  if (varcode.eq."PW_low") then
    vartitle1 = "Precipitable Water - low integrated"
    invar1 = "PW_low"
    vartype = "2d"
    cmaptype = "precip_water"
    pcnt_diff = True
  end if
  if (varcode.eq."LWP_mid") then
    vartitle1 = "Liquid Water Path - mid integrated"
    invar1 = "LWP_mid"
    vartype = "2d"
    cmaptype = "water_path"
    pcnt_diff = True
  end if
  if (varcode.eq."IWP_mid") then
    vartitle1 = "Ice Water Path - mid integrated"
    invar1 = "IWP_mid"
    vartype = "2d"
    cmaptype = "water_path"
    pcnt_diff = True
  end if
  if (varcode.eq."TWP_mid") then
    vartitle1 = "Total Water Path - mid integrated"
    invar1 = "IWP_mid"
    invar2 = "LWP_mid"
    vartype = "2d"
    cmaptype = "water_path"
    pcnt_diff = True
    load_two = True
  end if
  if (varcode.eq."PW_mid") then
    vartitle1 = "Precipitable Water - mid integrated"
    invar1 = "PW_mid"
    vartype = "2d"
    cmaptype = "precip_water"
    pcnt_diff = True
  end if
  if (varcode.eq."LWP_top") then
    vartitle1 = "Liquid Water Path - top integrated"
    invar1 = "LWP_top"
    vartype = "2d"
    cmaptype = "water_path"
    pcnt_diff = True
  end if
  if (varcode.eq."IWP_top") then
    vartitle1 = "Ice Water Path - top integrated"
    invar1 = "IWP_top"
    vartype = "2d"
    cmaptype = "water_path_sm"
    pcnt_diff = True
  end if
  if (varcode.eq."TWP_top") then
    vartitle1 = "Total Water Path - top integrated"
    invar1 = "IWP_top"
    invar2 = "LWP_top"
    vartype = "2d"
    cmaptype = "water_path_sm"
    pcnt_diff = True
    load_two = True
  end if
  if (varcode.eq."PW_top") then
    vartitle1 = "Precipitable Water - top integrated"
    invar1 = "PW_top"
    vartype = "2d"
    cmaptype = "precip_water_sm"
    pcnt_diff = True
  end if

; Set the contour interval for each input variable   
; set contour limits manually:
  if (cmaptype.eq."pressure") then
    cmin1               = 920
    cmax1               = 1064.
    clev1               = 2.
    cmin2               = -10.
    cmax2               = 10.
    clev2               = 1.
    clevd               = clev1*2
    stride1             = 4                 ; label stride
    stride2             = 2                 ; label stride for diff plot
    plotlines           = True              ; lines for reg plot
    difflines           = False              ; lines for diff plot
    cntype              = "AreaFill"
    spreadstart1        = 2                 ; start at color
    spreadend1          = 74                ; end at color
    spreadstart2        = 76                ; start at color
    spreadend2          = 129               ; end at color
    colormap            = "slp_anoms.dave"
  end if
 if (cmaptype.eq."geopotential_low") then
    cmin1               = 900.
    cmax1               = 1740.
    clev1               = 30.
    cmin2               = -200.
    cmax2               = 200.
    clev2               = 15.
    clevd               = clev1*2
    stride1             = 8                 ; label stride
    stride2             = 4
    plotlines           = True              ; lines for reg plot
    difflines           = True              ; lines for diff plot
    cntype              = "AreaFill"
    spreadstart1        = 2                 ; start at color
    spreadend1          = 65                ; end at color
    spreadstart2        = 67                ; start at color
    spreadend2          = 118               ; end at color
    colormap            = "z500_anoms.dave"
  end if
 if (cmaptype.eq."geopotential_low_mid") then
    cmin1               = 2500.
    cmax1               = 3500.
    clev1               = 30.
    cmin2               = -200.
    cmax2               = 200.
    clev2               = 15.
    clevd               = clev1*2
    stride1             = 8                 ; label stride
    stride2             = 4
    plotlines           = True              ; lines for reg plot
    difflines           = True              ; lines for diff plot
    cntype              = "AreaFill"
    spreadstart1        = 2                 ; start at color
    spreadend1          = 65                ; end at color
    spreadstart2        = 67                ; start at color
    spreadend2          = 118               ; end at color
    colormap            = "z500_anoms.dave"
  end if
  if (cmaptype.eq."geopotential_mid") then
    cmin1               = 4500.
    cmax1               = 6100.
    clev1               = 25.
    cmin2               = -150.
    cmax2               = 150.
    clev2               = 10.
    clevd               = clev1*2
    stride1             = 8                 ; label stride
    stride2             = 2                 ; label stride diff plot
    plotlines           = True              ; lines for reg plot
    difflines           = True              ; lines for diff plot
    cntype              = "AreaFill"        ; type of contour fill
    spreadstart1        = 2                 ; start at color
    spreadend1          = 65                ; end at color
    spreadstart2        = 67                ; start at color
    spreadend2          = 118               ; end at color
    colormap            = "z500_anoms.dave"
  end if
 if (cmaptype.eq."geopotential_high") then
   cmin1                = 7500.
    cmax1               = 10600.
    clev1               = 40.
    cmin2               = -150.
    cmax2               = 150.
    clev2               = 10.
    clevd               = clev1*2
    stride1             = 8                 ; label stride
    stride2             = 2                 ; label stride for diff plot
    plotlines           = True              ; lines for reg plot
    difflines           = True              ; lines for diff plot
    cntype              = "AreaFill"        ; type of contour fill
    spreadstart1        = 2                 ; start at color
    spreadend1          = 65                ; end at color
    spreadstart2        = 67                ; start at color
    spreadend2          = 118               ; end at color
    colormap            = "z500_anoms.dave"
  end if
  if (cmaptype.eq."temperature") then
    cmin1               = -60.
    cmax1               = 20.
    clev1               = 4.
    cmin2               = -10.
    cmax2               = 10.
    clev2               = 2.
    clevd               = clev1
    stride1             = 4                 ; label stride
    stride2             = 2                 ; label stride diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False              ; lines for diff plot
    cntype              = "AreaFill"      ; type of contour fill
    spreadstart1        = 2                 ; start at color
    spreadend1          = 65                ; end at color
    spreadstart2        = 67                ; start at color
    spreadend2          = 106 
    colormap            = "temp64_anoms.dave"
  end if
  if (cmaptype.eq."mix_rad") then
    cmin1               =  0.
    cmax1               =  0.04
    clev1               =  0.002
    cmin2               =  -100.
    cmax2               =  100.
    clev2               =  10.
    clevd               = clev1
    stride1             = 4                 ; label stride
    stride2             = 2                 ; label stride diff plot
    plotlines           = True              ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"        ; type of contour fill
    spreadstart1        = 51                ; start at color
    spreadend1          = 103               ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 103               ; end at color
    colormap            = "BrownBlue"
  end if
  if (cmaptype.eq."mix_rad_mid") then
    cmin1               =  0.
    cmax1               =  0.0016
    clev1               =  0.0002
    cmin2               =  -100.
    cmax2               =  100.
    clev2               =  10.
    clevd               = clev1
    stride1             = 4                 ; label stride
    stride2             = 2                 ; label stride diff plot
    plotlines           = True              ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"        ; type of contour fill
    spreadstart1        = 51                ; start at color
    spreadend1          = 103               ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 103               ; end at color
    colormap            = "BrownBlue"
  end if
  if (cmaptype.eq."water_path") then
    cmin1               =  0.
    cmax1               =  0.005
    clev1               =  0.0005
    cmin2               =  -150.
    cmax2               =  150.
    clev2               =  10.
    clevd               = clev1
    stride1             = 2                 ; label stride
    stride2             = 2                 ; label stride diff plot
    plotlines           = True              ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"        ; type of contour fill
    spreadstart1        = 51                ; start at color
    spreadend1          = 103               ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 103               ; end at color
    colormap            = "BrownBlue"
  end if
  if (cmaptype.eq."water_path_sm") then
    cmin1               =  0.
    cmax1               =  0.0005
    clev1               =  0.0001
    cmin2               =  -150.
    cmax2               =  150.
    clev2               =  10.
    clevd               = clev1
    stride1             = 2                 ; label stride
    stride2             = 2                 ; label stride diff plot
    plotlines           = True              ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"        ; type of contour fill
    spreadstart1        = 51                ; start at color
    spreadend1          = 103               ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 103               ; end at color
    colormap            = "BrownBlue"
  end if
  if (cmaptype.eq."precip_water") then
    cmin1               =  0.
    cmax1               =  0.5
    clev1               =  0.05
    cmin2               =  -100.
    cmax2               =  100.
    clev2               =  10.
    clevd               = clev1
    stride1             = 2                 ; label stride
    stride2             = 2                 ; label stride diff plot
    plotlines           = True              ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"        ; type of contour fill
    spreadstart1        = 51                ; start at color
    spreadend1          = 103               ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 103               ; end at color
    colormap            = "BrownBlue"
  end if
  if (cmaptype.eq."precip_water_sm") then
    cmin1               =  0.
    cmax1               =  0.05
    clev1               =  0.005
    cmin2               =  -100.
    cmax2               =  100.
    clev2               =  10.
    clevd               = clev1
    stride1             = 2                 ; label stride
    stride2             = 2                 ; label stride diff plot
    plotlines           = True              ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"        ; type of contour fill
    spreadstart1        = 51                ; start at color
    spreadend1          = 103               ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 103               ; end at color
    colormap            = "BrownBlue"
  end if
  if (cmaptype.eq."flux") then
    cmin1               =  -50.
    cmax1               =  50.
    clev1               =  10.
    cmin2               = -50.
    cmax2               =  50.
    clev2               =  10.
    clevd               = clev1*2
    stride1             = 2                 ; label stride
    stride2             = 2                 ; label stride diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"      ; type of fill for contours 
    spreadstart1        = 2                 ; start at color
    spreadend1          = 254               ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 254               ; end at color
    colormap            = "BlueYellowRed"
    cminO               =  -400.            ; set overlay information
    cmaxO               =  400.
    clevO               =  50.
    strideO             = 2
    plotlinesO          = True
  end if
  if (cmaptype.eq."wind") then
    cmin1               = 0.
    cmax1               = 14.
    clev1               = 2.
    cmin2               = -10.
    cmax2               = 10.
    clev2               = 2.
    clevd               = clev1*2
    stride1             = 2                 ; label stride
    stride2             = 2                 ; label stride for diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False              ; lines for diff plot
    cntype              = "AreaFill"
    spreadstart1        = 2                 ; start at color
    spreadend1          = 21                ; end at color
    spreadstart2        = 23                ; start at color
    spreadend2          = 45                ; end at color
    colormap            = "winds.alice"
  end if
  if (cmaptype.eq."ustar") then
    cmin1               = 0.
    cmax1               = 1.
    clev1               = 0.05
    cmin2               = -0.5
    cmax2               = 0.5
    clev2               = 0.05
    clevd               = clev1*2
    stride1             = 2                 ; label stride
    stride2             = 2                 ; label stride for diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False              ; lines for diff plot
    cntype              = "AreaFill"
    spreadstart1        = 2                 ; start at color
    spreadend1          = 21                ; end at color
    spreadstart2        = 23                ; start at color
    spreadend2          = 45                ; end at color
    colormap            = "winds.alice"
  end if
  if (cmaptype.eq."precip") then
    cmin1               =  0.
    cmax1               =  300.
    clev1               =  25.
    cmin2               = -100.
    cmax2               =  100.
    clev2               =  10.
    clevd               =  clev1*2
    stride1             = 4                 ; label stride
    stride2             = 2                 ; label stride diff plot 
    plotlines           = False             ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"        ; type of contour fill
    spreadstart1        = 51                ; start at color
    spreadend1          = 103               ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 103               ; end at color
    colormap            = "BrownBlue"
  end if
  if (cmaptype.eq."lwflux") then
    cmin1               =  -400.
    cmax1               =  400.
    clev1               =  25.
    cmin2               = -200.
    cmax2               =  200.
    clev2               =  10.
    clevd               = clev1*2
    stride1             = 2                 ; label stride
    stride2             = 4
    plotlines           = False              ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"
    spreadstart1        = 2                 ; start at color
    spreadend1          = 102               ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 102               ; end at color
    colormap            = "BlWhRe"
  end if
  if (cmaptype.eq."swflux") then
    cmin1               =  -400.
    cmax1               =  400.
    clev1               =  25.
    cmin2               = -400.
    cmax2               =  400.
    clev2               =  20.
    clevd               = clev1*2
    stride1             = 2                 ; label stride
    stride2             = 4
    plotlines           = False              ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"
    spreadstart1        = 2                 ; start at color
    spreadend1          = 102               ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 102               ; end at color
    colormap            = "BlWhRe"
  end if


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Data Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; get names from input
date1 = year+"-"+seas

; need the deaccumulated file if precipiation or radiation
if (isvar("load_latlon").and.(load_latlon)) then ; deaccumulated variables
   if (title1.eq."era_i") then
     fname1 = "wrf-"+date1+"-flux."+title1
   else
     fname1 = "wrf-"+date1+"-deacc."+title1
   end if
   fname2 = "wrf-"+date1+"-deacc."+title2
 else
   fname1 = "wrf-"+date1+"."+title1
   fname2 = "wrf-"+date1+"."+title2
 end if
 if(isvar("invar0"))then
   fname1 = "wrf-"+date1+"."+title1
 end if

; set outdir and fout names
outdir = "./"
fout   = outdir+varcode+"_"+title1+"_"+title2+"_"+date1

;;;;;;;;;;
; load in two wrf files
;;;;;;;;;;
; Load in first file to compare
f1 = addfile(dir1 + fname1 + ".nc","r")

; Load in second file to compare.
f2 = addfile(dir2 + fname2 + ".nc","r")

; Load 2d lat and lon arrays
  ; deaccumulated vars have zero lat/lon fields. 
  ; need to read in lat/lon array from the "normal" variable file
if (isvar("load_latlon").and.(load_latlon)) then ; deaccumulated variables
  f0 = addfile(dir2+"wrf-"+date1+"."+title2+".nc","r")
  lat2d_1 = f0->lat
  lon2d_1 = f0->lon
  delete(f0)
else
  lat2d_1 = f1->lat
  lon2d_1 = f1->lon
  Z_sfc = f1->Z_sfc
end if
  
  dims_2 = dimsizes(lat2d_1)     ; get lat/lon dimensions from second domain
  n_sn = dims_2(0)              ; get south/north points
  n_we = dims_2(1)              ; get west/east points
  n_tot = n_sn*n_we              ; get total number of points in high res domain
  nlat = n_sn                   ; used in plots
  nlon = n_we                   ; used in plots

;;;;;;;;;;
; load in wrf variables
;;;;;;;;;;
  print("Loading "+title1)
; 2d vars:
  if (vartype.eq."2d") then
    if (isvar("load_two").and.(load_two)) then  ; needs multiple vars
      if(isvar("invar0"))then
        var1 = f1->$invar0$(south_north|:,west_east|:)
      else
        var1_a= f1->$invar1$(time|0,south_north|:,west_east|:)
        var1_b = f1->$invar2$(time|0,south_north|:,west_east|:)
        var1 = var1_a + var1_b
        copy_VarMeta(var1_a, var1)
        delete(var1_a)
        delete(var1_b)
      end if
    else
      if(title1.eq."era_i" )then ; era_i has different time dimensioning
        if(isvar("deaccum").and.(deaccum))then
          var1 = f1->$invar1$(time|0,south_north|:,west_east|:)
        else
          var1 = f1->$invar1$(time|0,south_north|:,west_east|:)
        end if
      else
        var1 = f1->$invar1$(time|0,south_north|:,west_east|:)
      end if
    end if
    if (isvar("find_speed").and.(find_speed))then
      var11 = f1->$invar11$(time|0,south_north|:,west_east|:)
    end if
  end if

  ; Get second file's variable info
  print("Loading "+title2)
  if (vartype.eq."2d") then
    if (isvar("load_two").and.(load_two)) then  ; needs multiple vars
      var2_a= f2->$invar1$(time|0,south_north|:,west_east|:)
      var2_b = f2->$invar2$(time|0,south_north|:,west_east|:)
      var2 = var2_a + var2_b
      copy_VarMeta(var2_a, var2)
      delete(var2_a)
      delete(var2_b)
    else
      var2 = f2->$invar1$(time|0,south_north|:,west_east|:)  ; no time information
    end if
    if (isvar("find_speed").and.(find_speed))then  ; wind needs v component
      var22 = f2->$invar11$(time|0,south_north|:,west_east|:)
    end if
  end if

; 3d vars:
  if (vartype.eq."3d") then
    print("Loading "+title1)
    if(title1.eq."era_i")then ; era_i has different time dimensioning
      var1 = f1->$invar1$({pressure|preslev},south_north|:,west_east|:)
    else
      var1 = f1->$invar1$(time|0,{pressure|preslev},south_north|:,west_east|:)
    end if
  end if

  ; Get second file's variable info
  if (vartype.eq."3d") then
    print("Loading "+title2)
    var2 = f2->$invar1$(time|0,{pressure|preslev},south_north|:,west_east|:)
    delete(preslev) ; delete the pressure level
  end if

print("Loaded variables")
;;;;;;;;;;
; manipulate arrays as needed - post interpolation
;;;;;;;;;;
if (isvar("deaccum").and.(deaccum)) then
  if(title1.ne."era_i")then
    var1 = var1/nsec
  end if
  var2 = var2/nsec
  var1@units = "W m-2"
  var2@units = "W m-2"
end if
if (isvar("convert_to_C").and.(convert_to_C)) then
  var1 = var1 - 273.15
  var2 = var2 - 273.15
  var1@units = "C"
  var2@units = "C"
end if
if (varcode .eq. "LH" .and. title1 .eq. "era_i")then
  var1 = -var1
end if
if (varcode .eq. "SH" .and. title1 .eq. "era_i")then
  var1 = -var1
end if
if (isvar("find_speed").and.(find_speed)) then
  ; Find difference information
  u_diff = var2 - var1
  v_diff = var22 - var11
  u_diff@lat2d = lat2d_1
  u_diff@lon2d = lon2d_1
  v_diff@lat2d = lat2d_1
  v_diff@lon2d = lon2d_1
  ; Rename winds to plot them as vectors
  var1_vec = var1         
  var11_vec = var11
  var2_vec = var2
  var22_vec = var22 
  var1_vec@lat2d = lat2d_1
  var1_vec@lon2d = lon2d_1
  var11_vec@lat2d = lat2d_1
  var11_vec@lon2d = lon2d_1
  var2_vec@lat2d = lat2d_1
  var2_vec@lon2d = lon2d_1
  var22_vec@lat2d = lat2d_1
  var22_vec@lon2d = lon2d_1
  ; find wind speed
  var1 = sqrt(var1^2+var11^2)
  var2 = sqrt(var2^2+var22^2)
  var1@long_name = "Net Wind Speed"
  var1@standard_name = "Wind Speed"
  copy_VarMeta(var1,var2)
end if

; prints together the variable title (set above for each type of data) with title1 (defined in cshell as the wrf or met info) and the max and min values
  print(vartitle1+" "+title1+" min: "+min(var1)+"  max: "+max(var1)) 
  print(vartitle1+" "+title2+" min: "+min(var2)+"  max: "+max(var2))

; assign 2d lat and lon attributes for plotting:
  var1@lat2d  = lat2d_1
  var1@lon2d  = lon2d_1
  var2@lat2d  = lat2d_1
  var2@lon2d  = lon2d_1

  fill = new((/1/),"float")

; mask out terrain
  var1 = where(Z_sfc .gt. 100.0, fill, var1)
  var2 = where(Z_sfc .gt. 100.0, fill, var2)
  var1@_FillValue = fill
  var2@_FillValue = fill

; create difference file
; for precip and mixing ratio fields, make %diff field instead
  if (isvar("pcnt_diff").and.(pcnt_diff)) then
    ; moisture variables - % diff
    test = new((/1/),"float")
    var1@_FillValue = test(0)
    var1 = where(var1.eq.0.,var1@_FillValue,var1) ; deal with zero denom    
    diff = ((var2 - var1)/var1)*100.
    copy_VarMeta(var2,diff)
    title3 = "%diff: ("+title2+" - "+title1+")/"+title1 
  else 
    ; just regular difference field
    diff = var2 - var1
    copy_VarMeta(var2,diff)
    title3 = title2+" - "+title1 
  end if

  print(vartitle1+" diff min: "+min(diff)+"      max: "+max(diff))
  print("Irminger diff:"+diff(89,220))
  print("Coast diff: "+diff(91,213))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
  print("Processing four panel graphs for "+varcode+" "+date1)

  wks = gsn_open_wks("ps" ,fout)
  additional_colors = (/"gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks,colormap,additional_colors)

  plot = new(4, graphic)

; update titles to remove underscores:
  title1 = str_sub_str(title1,"_"," ")
  title2 = str_sub_str(title2,"_"," ")

;;;;;;;;;;;;;
; Set resources used for all plots
;;;;;;;;;;;;

  res                             = True              ; plot mods desired
  ;res@gsnRightString              = ""
  res@gsnLeftString               = ""
  res@gsnFrame                    = False             ; Do not draw plot 
  res@gsnDraw                     = False             ; Do not advance fr
  res@gsnAddCyclic                = False             ; regional - not cyclic 
  res@mpProjection                = "Stereographic"   ; map projection
  res@mpCenterLonF                = -114.             ; set the center lat/lon
  res@mpCenterLatF                = 90.               
  
 if (isvar("whole_dom").and.(whole_dom))then
  res@mpLimitMode                 = "Corners"
  res@mpLeftCornerLatF            = lat2d_1(0,0)        ; set the lat/lon sides
  res@mpLeftCornerLonF            = lon2d_1(0,0)
  res@mpRightCornerLatF           = lat2d_1(nlat-1,nlon-1)
  res@mpRightCornerLonF           = lon2d_1(nlat-1,nlon-1)
 end if

 if (isvar("zoom").and.(zoom))then
  res@mpLimitMode                 = "LatLon"	      ; how to zoom in on map
  res@mpMinLatF                   = 56.              ; set the minimum latitude 
  res@mpMaxLatF                   = 68.              ; set the maximum latitude 
  res@mpMinLonF                   = -55.0            ; set the minimum longitude 
  res@mpMaxLonF                   = -18.0            ; set the maximum longitude 
 end if

  res@mpGridAndLimbOn             = True              ; Turn on lat/lon grid
  res@mpGridLineDashPattern       = 2                 ; Change dash pattern
  res@mpFillOn                    = True              ; Enables map fill
  res@mpGeophysicalLineColor      = "black"     ; Color of continents
  res@mpGeophysicalLineThicknessF = 1.5              ; Make continents thinner

; set vector resources if it's a wind plot
   if (isvar("find_speed").and.(find_speed)) then
   vcres                            = True
   vcres@gsnRightString             = ""
   vcres@gsnLeftString              = ""
   vcres@gsnFrame                   = False             ; Do not draw plot 
   vcres@gsnDraw                    = False             ; Do not advance fr
   vcres@gsnAddCyclic               = False             ; regional - not cyclic 
   vcres@vcGlyphStyle               = "LineArrow"
   vcres@vcRefMagnitudeF            = 10.               ; set vector reference magnitude
   vcres@vcRefLengthF               = 0.03              ; length of vector (larger = longer)
   vcres@vcMinDistanceF             = 0.04              ; vector spacing (smaller = more dense)
   vcres@vcLineArrowThicknessF      = 1.0               ; thickness of vector arrows (larger = bolder)
   ;vcres@vcFillArrowsOn             = False             ; get rid of the filled vectors
  
; vector legend placement
  vcres@vcRefAnnoOrthogonalPosF    = -0.02              ; vector vertical legend placement
  vcres@vcRefAnnoParallelPosF      = 0.95               ; vector horizontal legend placement
  vcres@vcRefAnnoString1           = "Wind Speed"      ; label vector legend top string
  vcres@vcRefAnnoString1On         = True              ; turn on top vector label string
  vcres@vcRefAnnoString2           = "10 m/s"          ; label vector legend bottom string
  vcres@vcRefAnnoString2On         = True              ; turn on bottom vector label string

  end if
  
; set resources for overlay plot for LH and SH figures
 if (isvar("overlay_c").and.(overlay_c))then
   res2                            = True               ; reset options
   res2@gsnLeftString              = ""
   res2@gsnRightString             = ""
   res2@gsnFrame                   = False             ; Do not draw plot 
   res2@gsnDraw                    = False             ; Do not advance fr
   res2@cnInfoLabelOn              = False             ; Turn off info on contours at bottom
   res2@cnFillOn                   = False              ; turn on filled contours
   res2@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
   res2@cnMinLevelValF             = cminO             ; set min contour level specified above
   res2@cnMaxLevelValF             = cmaxO             ; set max contour level specified above
   res2@cnLevelSpacingF            = clevO             ; set contour spacing specified above
   res2@cnLinesOn                  = plotlinesO        ; contour lines specified above
   res2@cnLineLabelsOn             = plotlinesO        ; line labels on specified above
 end if

;;;;;;;;;;;;;
; Plot 1 - overlay contours
;;;;;;;;;;;;;
  title0 = title1+" and "+title2            

  opts                            = res               ; set resources for plot 1 to be same as specified above
  opts@cnLineColor                = "red"
  opts@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  opts@cnMinLevelValF             = cmin1             ; set min contour level. designated above for each variable of interest
  opts@cnMaxLevelValF             = cmax1             ; set max contour level. designated above
  opts@cnLevelSpacingF            = clevd           ; set contour spacing. designated above
  opts@tiMainString               = title0            ; set title for plot. designated above as both input names
  opts@tiMainFontHeightF          = 0.013
  opts@cnInfoLabelOn              = False
  opts@cnLineLabelFontColor       = opts@cnLineColor  ; set the contour labels to be the same as the contour line color
  opts@cnLineLabelBackgroundColor = "Transparent"     ; set the background behind contour labels to be transparent

; Plot 1 (overlay)
  opts2                            = opts             ; set options for the second contour set to be the same
  opts2@cnLineColor                = "blue"           ; specify second contour to be diff. color
  opts2@cnLineLabelFontColor       = opts2@cnLineColor
  opts2@gsnRightString             = ""

; reset and deletion options to prevent overwrites and warnings for overlay:
  delete(opts2@tiMainString)
  delete(opts2@mpProjection)
  delete(opts2@mpLimitMode)
  delete(opts2@mpCenterLonF)
  delete(opts2@mpCenterLatF)
  delete(opts2@mpGridAndLimbOn)
  delete(opts2@mpFillOn)
  delete(opts2@mpGridLineDashPattern)
  delete(opts2@mpGeophysicalLineColor)
  delete(opts2@mpGeophysicalLineThicknessF)
if (isvar("whole_dom").and.(whole_dom))then
  delete(opts2@mpLeftCornerLonF)
  delete(opts2@mpLeftCornerLatF)
  delete(opts2@mpRightCornerLatF)
  delete(opts2@mpRightCornerLonF)
end if
if (isvar("zoom").and.(zoom))then
  delete(opts2@mpMaxLonF)
  delete(opts2@mpMinLonF)
  delete(opts2@mpMaxLatF)
  delete(opts2@mpMinLatF)
end if

  cplot1 = gsn_csm_contour_map(wks,var1,opts)  ; create plot of first contours
  cplot1b = gsn_csm_contour(wks,var2,opts2)    ; create plot of second contours
  overlay(cplot1,cplot1b)                       ; overlay contour 2 on contour 1. overlay plot wil have title cplot1
  plot(0) = cplot1                              ; make panel section of this plot
  delete(opts)
  delete(opts2)

; legend resources- for plot 1 overlay
  lgres                    = True
  lgres@lgLineColors       = (/"red","blue"/)   ; make the colors for the legend
  lgres@lgMonoDashIndex    = True               ; sets both contour lines to same dash type
  lgres@lgAutoManage       = False              ; false allows me to set the legend directly
  lgres@vpWidthF           = 0.30               ; width of legend (NDC)
  lgres@vpHeightF          = 0.05               ; height of legend (NDC)
  lgres@lgLineDashSegLenF  = 0.01
  lgres@lgLabelFontHeightF = 0.03
  lgres@lgLineLabelStrings = (/"", ""/)         ; take of any automatic line labels
  lbid = gsn_create_legend(wks,2,(/title1, title2/),lgres)         ; create legend

; annotate first plot by adding legend
  amres                    = True
  amres@amParallelPosF     = 0.25	        ; move legend to the right
  amres@amOrthogonalPosF   = 0.60               ; move the legend down
  annoid1 = gsn_add_annotation(plot(0),lbid,amres)   ; add legend to plot

;;;;;;;;;;;;;
; Plot 2 - fname1
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
  opts@tiMainString               = title1            ; title string specified from cshell
  opts@tiMainFontHeightF          = 0.013
  opts@lbLabelStride              = stride1
  opts@pmLabelBarOrthogonalPosF   = -0.01             ; move label bar closer
  opts@pmLabelBarHeightF          = 0.075             ; set height of labelbar
  
  ;plot(1) = gsn_csm_contour_map(wks, var1, opts)      ; create second plot
  
  cplot2 = gsn_csm_contour_map(wks, var1, opts)      ; create second plot
  if (isvar("find_speed").and.(find_speed)) then
    cplot2b = gsn_csm_vector(wks, var1_vec, var11_vec, vcres)
    overlay(cplot2,cplot2b)
  end if
  if (isvar("overlay_c").and.(overlay_c))then
    cplot2b = gsn_csm_contour(wks, var1, res2)
    overlay(cplot2, cplot2b)
  end if
  plot(1) = cplot2                              ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 4 - fname2
;;;;;;;;;;;;;

; keep options the same as the for second plot because same field plotted
; make plot 4 next because options are the same
  opts@tiMainString               = title2            ; rename title for plot

  cplot4 = gsn_csm_contour_map(wks, var2, opts)      ; create fourth plot
  if (isvar("find_speed").and.(find_speed)) then
    cplot4b = gsn_csm_vector(wks, var2_vec, var22_vec, vcres)
    overlay(cplot4,cplot4b)
  end if
  if (isvar("overlay_c").and.(overlay_c))then
    cplot4b = gsn_csm_contour(wks, var2, res2)
    overlay(cplot4, cplot4b)
  end if
  plot(3) = cplot4                              ; make panel section of this plot
  delete(opts)


;;;;;;;;;;;;;
; Plot 3 - difference 
;;;;;;;;;;;;; 

  opts                            = res
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
  opts@tiMainString               = title3            ; set title for difference plot (title2-title1)
  opts@tiMainFontHeightF          = 0.013
  opts@lbLabelStride              = stride2
  opts@pmLabelBarOrthogonalPosF   = -0.01             ; move label bar closer
  opts@pmLabelBarHeightF          = 0.075

  cplot3 = gsn_csm_contour_map(wks, diff, opts)      ; create third plot
  plot(2) = cplot3                              ; make panel section of this plot

 ;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
   title5 = date1+" "+vartitle1+": "+title1+" and "+title2  

  pnlres                            = True
  pnlres@txString                   = title5           ; set title for whole panel plot. specified above     
  pnlres@txFontHeightF              = 0.02
  pnlres@gsnPaperOrientation        = "landscape"      ; landscape mode
  pnlres@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelScalePlotIndex     = 1
  pnlres@gsnMaximize                = True	       ; fill the page
  gsn_panel(wks,(/plot/),(/2,2/),pnlres)               ; create final panel plot
  
  convert_cmd = "convert -density 300 "+fout+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout+".png"

  system(convert_cmd)

;;;;;;;;;;;;;;;;;;;;;; END script
end
