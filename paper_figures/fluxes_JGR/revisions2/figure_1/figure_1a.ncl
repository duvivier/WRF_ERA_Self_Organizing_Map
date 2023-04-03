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
f1 = addfile("/data3/duvivier/RACM/DATA/geo_em/geo_em.50km.nc","r")

hgt = f1->HGT_M(0,:,:)
lat2d = f1->XLAT_M(0,:,:)
lon2d = f1->XLONG_M(0,:,:)

; mask low level terrain so it plots normally
hgt = where(hgt .gt. 10.0 .and. hgt .lt. 50.0, 50.5, hgt)
hgt = where(hgt .lt. 0.0, 1.0, hgt)

dims = dimsizes(lat2d)     ; get lat/lon dimensions from second domain
n_sn = dims(0)              ; get south/north points
n_we = dims(1)              ; get west/east points
n_tot = n_sn*n_we               ; get total number of points in high res domain

hgt@lat2d = lat2d
hgt@lon2d = lon2d

; set outdir and fout names
outdir = "./"
fout   = outdir+"winds_figure_1a"

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
  res@mpCenterLonF                = -114.             ; set the center lat/lon
  res@mpCenterLatF                = 90.               
 
  res@mpGridAndLimbOn             = True              ; Turn on lat/lon grid
  res@mpGridLineDashPattern       = 2                 ; Change dash pattern
  res@mpFillOn                    = True              ; Enables map fill
  res@mpGeophysicalLineColor      = "black"           ; Color of continents
  res@mpGeophysicalLineThicknessF = 0.75              ; Make continents thinner

  res@cnLinesOn                   = False             ; no contour lines
  res@cnLineLabelsOn              = False             ; don't want labels
  res@cnFillMode                  = "AreaFill"
  res@lbLabelFontHeightF          = 0.015              ; label bar font size

; set line res to show box
  lnres                            = True
   lnres@gsLineThicknessF          = 2.0
   lnres@gsLineColor               = "black"

;;;;;;;;;;;;;
; Plot 0 - terrain
;;;;;;;;;;;;;
  opts                            = res               ; reset options
  opts@mpLimitMode                 = "Corners"	      ; how to zoom in on map
  opts@mpLeftCornerLatF            = lat2d(0,0)     ; set the lat/lon sides
  opts@mpLeftCornerLonF            = lon2d(0,0)
  opts@mpRightCornerLatF           = lat2d(n_sn-1,n_we-1) ;- 2
  opts@mpRightCornerLonF           = lon2d(n_sn-1,n_we-1)

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
  ;opts@tiMainString               = "Terrain Height (m) and SOM training area"  ; title string 
  ;opts@tiMainFontHeightF          = 0.014
  ;opts@tiMainFontThicknessF       = 1.5
  opts@lbLabelBarOn                = True
  opts@lbLabelStride              = stride1
  opts@lbTitleString              = "m"
  opts@lbTitlePosition            = "Right"
  opts@pmLabelBarOrthogonalPosF   = -0.01             ; move label bar closer
  opts@pmLabelBarHeightF          = 0.075             ; set height of labelbar
      
  cplot0 = gsn_csm_contour_map(wks, hgt, opts)      ; create second plot

  ;dum1 = new(1, graphic)      ; make dummy variable
  ;dum1 = gsn_add_polyline(wks,cplot0,(/-25.0, 0.0/), (/56.0, 82.0/), lnres)
  
  ;dum2 = new(1, graphic)      ; make dummy variable
  ;dum2 = gsn_add_polyline(wks,cplot0,(/0.0, -90.0/), (/82.0, 82.0/), lnres)

  ;dum3 = new(1, graphic)      ; make dummy variable
  ;dum3 = gsn_add_polyline(wks,cplot0,(/-90.0, -50.0/), (/82.0, 56.0/), lnres)

  ;dum4 = new(1, graphic)      ; make dummy variable
  ;dum4 = gsn_add_polyline(wks,cplot0,(/-50.0, -25.0/), (/56.0, 56.0/), lnres)

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
  
  convert_cmd = "convert -density 300 "+fout+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout+".png"

  system(convert_cmd)

; delete all variables and resources
  delete(wks)
  delete(plot)
  delete(additional_colors)
  delete(convert_cmd)
  delete(res)
  delete(pnlres)
  delete(opts)

;;;;;;;;;;;;;;;;;;;;;; END script
end
