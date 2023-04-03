;***************************************
; PROGRAM DESCRIPTION: This NCL script regrids curvilinear WRf output
;                      from any domain to a 10km WRF domain using 
;                      a Cressman Weighting scheme
; INPUT DATA: WRF geo_em.d01.nc files for 10km grid spacing and 100km spacing
; OUTPUT DATA: plot of the terrain at 10km and labels for locations,
;              difference plot of wrf100 and wrf10 terrain height along southeast coast.
; CREATOR: Alice DuVivier - March 2012
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************

begin
; MANUAL INPUTS
;;;;;;;;;;
; Load Data
;;;;;;;;;;
f1 = addfile("/vardar/data3/duvivier/SOM/DATA/wrf10/200511/wrf-2005-11-01_00.green10.cf.nc", "r")

hgt = f1->Z_sfc
lat2d = f1->lat
lon2d = f1->lon

dims = dimsizes(lat2d)     ; get lat/lon dimensions from second domain
n_sn = dims(0)              ; get south/north points
n_we = dims(1)              ; get west/east points
n_tot = n_sn*n_we               ; get total number of points in high res domain

hgt@lat2d = lat2d
hgt@lon2d = lon2d

; set outdir and fout names
outdir = "./"
fout   = outdir+"Greenland_thesis"

;;;;;;;;;;
; Plotting
;;;;;;;;;;
  wks = gsn_open_wks("ps" ,fout)

  additional_colors = (/"gray85","yellow", "purple", "red"/)
  gsn_merge_colormaps(wks,"terrain.alice",additional_colors)

  plot = new(1, graphic)


; Set the contour interval for terrain only plot
    cmin1               = 0.
    cmax1               = 3500.
    clev1               = 50.
    stride1             = 10                 ; label stride for terrain plot
    spreadstart1        = 1                  ; start at color
    spreadend1          = 100                ; end at color
   
; set resources used for all plots
  res                             = True              ; plot mods desired
  res@gsnRightString              = ""
  res@gsnLeftString               = ""
  res@gsnFrame                    = False             ; Do not draw plot 
  res@gsnDraw                     = False             ; Do not advance fr
  res@gsnAddCyclic                = False             ; regional - not cyclic 
  res@mpProjection                = "Stereographic"   ; map projection
  res@mpCenterLonF                = -35. ;-30.              ; set the center lat/lon  ---changed by akd for Greenland
  res@mpCenterLatF                = 70.               ; -----changed by akd for Greenland
 
  res@mpGridAndLimbOn             = True              ; Turn on lat/lon grid
  res@mpGridLineDashPattern       = 2                 ; Change dash pattern
  res@mpFillOn                    = True              ; Enables map fill
  res@mpGeophysicalLineColor      = "black"           ; Color of continents
  res@mpGeophysicalLineThicknessF = 2.5              ; Make continents thinner

  res@cnLinesOn                   = False             ; no contour lines
  res@cnLineLabelsOn              = False             ; don't want labels
  res@cnFillMode                  = "AreaFill"
  res@lbLabelFontHeightF          = 0.015              ; label bar font size

;;;;;;;;;;;;;
; Add stuff for cross section line
;;;;;;;;;;;;;
  ; Irminger Sea
  lat0 = 62.0
  lon0 = -31.
  ; Labrador Sea
  lat1 = 62.
  lon1 = -58.
  ; Greenland Sea
  lat2 = 75.
  lon2 = -10.
  ; Norwegian Sea
  lat3 = 67.
  lon3 = -3.
  ; Denmark Strait
  lat4 = 66.5
  lon4 = -27. 
  ; Cape Farewell
  lat5 = 60.0
  lon5 = -40.
  ; Geikie Plateau
  lat6 = 69.0
  lon6 = -24.
  ; Iceland
  lat7 = 65.0
  lon7 = -17.75
  ; Summit
  lat8 = 72.0
  lon8 = -39.
  ; Davis Strait
  lat9 = 67.0
  lon9 = -58.
  ; Baffin Bay
  lat10 = 73.0
  lon10 = -64.
  ; Greenland
  lat11 = 76.0
  lon11 = -39.

; set line res to show box
  lnres                            = True
   lnres@gsLineThicknessF          = 2.0
   lnres@gsLineColor               = "black"

; set text res to show start and end of cross section
   txres                           = True
   txres@txFontHeightF             = 0.013 
   txres@txFontThicknessF          = 2.0
   txres@txFont                    = 26

;;;;;;;;;;;;;
; Plot 0 - terrain
;;;;;;;;;;;;;
  opts                            = res               ; reset options
  opts@mpLimitMode                = "LatLon"
  opts@mpMinLatF                  = 56.0
  opts@mpMaxLatF                  = 80.0
  opts@mpMinLonF                  = -59.0
  opts@mpMaxLonF                  = -15.0

  opts@cnFillOn                   = True              ; turn on filled contours
  opts@gsnSpreadColors            = True              ; use full colormap
  opts@gsnSpreadColorStart        = spreadstart1      ; start at color specified for each variable above
  opts@gsnSpreadColorEnd          = spreadend1        ; end at color specified above
  opts@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  opts@cnMinLevelValF             = cmin1             ; set min contour level specified above
  opts@cnMaxLevelValF             = cmax1             ; set max contour level specified above
  opts@cnLevelSpacingF            = clev1             ; set contour spacing specified above
  opts@cnMissingValFillColor      = "gray85"          ; missing value color
  opts@cnMissingValFillPattern    = 0                 ; fill in
  opts@tiMainString               = "Terrain Height (m)"
  opts@tiMainFontHeightF          = 0.014
  opts@tiMainFontThicknessF       = 1.5
  opts@lbLabelBarOn               = True ;False
  opts@lbLabelStride              = stride1
  opts@pmLabelBarOrthogonalPosF   = -0.01             ; move label bar closer
  opts@pmLabelBarHeightF          = 0.075             ; set height of labelbar
      
  cplot0 = gsn_csm_contour_map(wks, hgt, opts)      ; create second plot

  dum0 = new(1,graphic)
  dum0 = gsn_add_text(wks, cplot0, "Irminger ~C~ Sea", lon0, lat0, txres)

  dum1 = new(1,graphic)
  dum1 = gsn_add_text(wks, cplot0, "Labrador ~C~ Sea", lon1, lat1, txres)

  dum2 = new(1,graphic)
  dum2 = gsn_add_text(wks, cplot0, "Greenland ~C~ Sea", lon2, lat2, txres)

  dum3 = new(1,graphic)
  dum3 = gsn_add_text(wks, cplot0, "Norwegian ~C~ Sea", lon3, lat3, txres)

  dum4 = new(1,graphic)
  dum4 = gsn_add_text(wks, cplot0, "Denmark ~C~  Strait", lon4, lat4, txres)

  dum5 = new(1,graphic)
  dum5 = gsn_add_text(wks, cplot0, "Cape ~C~  Farewell", lon5, lat5, txres)

  dum6 = new(1,graphic)
  dum6 = gsn_add_text(wks, cplot0, "Geikie ~C~ Plateau", lon6, lat6, txres)

  dum7 = new(1,graphic)
  dum7 = gsn_add_text(wks, cplot0, "Iceland", lon7, lat7, txres)

  dum8 = new(1,graphic)
  dum8 = gsn_add_text(wks, cplot0, "Summit", lon8, lat8, txres)

  dum9 = new(1,graphic)
  dum9 = gsn_add_text(wks, cplot0, "Davis~C~Strait", lon9, lat9, txres)

  dum10 = new(1,graphic)
  dum10 = gsn_add_text(wks, cplot0, "Baffin~C~Bay", lon10, lat10, txres)

  dum11 = new(1,graphic)
  dum11 = gsn_add_text(wks, cplot0, "Greenland", lon11, lat11, txres)

  plot(0) = cplot0                              ; make panel section of this plot

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
  pnlres                            = True
  ;pnlres@txString                   = title5           ; set title for whole panel plot. specified above     
  pnlres@txFontHeightF              = 0.013
  pnlres@gsnPaperOrientation        = "landscape"      ; landscape mode
  pnlres@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelScalePlotIndex     = 1
  pnlres@gsnMaximize                = True	       ; fill the page
  gsn_panel(wks,(/plot/),(/1,1/),pnlres)               ; create final panel plot
 
; Finally - make plot
 print("plot complete - converting "+fout+" to png")
  delete(wks)
  system("convert -trim -border 10 -bordercolor white -density 300 "+  \
         "-rotate -90 -trim -border 10 "+fout+".ps "+fout+".png")
 
;;;;;;;;;;;;;;;;;;;;;; END script
end
