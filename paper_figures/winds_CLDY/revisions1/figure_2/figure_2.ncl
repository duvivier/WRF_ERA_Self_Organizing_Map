; Plot SOM nodes created by som_pak.
;
; Alice DuVivier - March 2014

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin
infile = "winds0.01_rlen2500000_r4.cod"
nx_node = 7
ny_node = 5
nnode = nx_node * ny_node
indir = "/vardar/data3/duvivier/SOM/training/som_75/"+nx_node+"x_"+ny_node+"y/"

print("Loading data...")
f1 = addfile("/vardar/data3/duvivier/SOM/DATA/wrf10/200511/wrf-2005-11-01_00.green10.cf.nc","r")
lat2d = f1->lat
lon2d = f1->lon
lat1D = ndtooned(lat2d)
lon1D = ndtooned(lon2d)
dims = dimsizes(lat2d)
n_sn = dims(0)
n_we = dims(1)
n_tot = n_sn * n_we


topo_2d = f1->Z_sfc
topo_2d@_FillValue = -999.
topo = ndtooned(topo_2d)
topo@_FillValue = -999.

; narrow down the values where I want winds 
; whole domain
 topo_1 = where(topo.lt.50 .and. lat1D.gt.56. .and. lat1D.lt.70. .and. lon1D.gt.-50. .and. lon1D.lt.-20., 1, 0)

; remove box out to sea
 topo_2 = where(topo.lt.50 .and. lat1D.gt.56. .and. lat1D.lt.64. .and. lon1D.gt.-25. .and. lon1D.lt.-20., 0, 1)

; combine topo arrays
 topo_fin = topo_1*topo_2
 topo = where(topo_fin .gt.0, topo, topo@_FillValue)

nsomcol = num(.not.ismissing(topo))
topoind = ind(.not.ismissing(topo))

som_header = readAsciiHead(indir+infile,1)
delim = " "
nsomcol2 = stringtoint(str_get_field(som_header,1,delim))
if (nsomcol.ne.nsomcol2/2) then
  print("Columns in SOM file do not match valid values in topography file!")
  exit
end if

som_nomissing = readAsciiTable(indir+infile, nsomcol2, "float", 1) ; 1 = skip header
somdims = dimsizes(som_nomissing)
if (nnode.ne.somdims(0)) then
  print("Input .cod file has incorrect number of nodes!")
  exit
end if

u_som_nomissing = som_nomissing(:,0:nsomcol2/2-1)
v_som_nomissing = som_nomissing(:,nsomcol2/2:nsomcol2-1)

; create array for entire domain, but only put data below 500 m into array
u_som = new((/nnode, n_tot/), "float")
v_som = new((/nnode, n_tot/), "float")
do n = 0, nnode - 1
  u_som(n,topoind) = u_som_nomissing(n,:)
  v_som(n,topoind) = v_som_nomissing(n,:)
end do


outstring = flt2string(nx_node*1.0)+"x_"+flt2string(ny_node*1.0)+"y_"
outfile = "./winds_figure_2"

; ready to plot!
wks = gsn_open_wks("ps",outfile)
gsn_define_colormap(wks,"MPL_BuPu")
gsn_merge_colormaps(wks,"MPL_BuPu",(/"cyan3","blue3","red","gold","forestgreen","darkorange","deeppink3","brown"/))

; Graphics options:
resources                         = True

resources@gsnFrame                = False
resources@gsnDraw                 = False
resources@gsnAddCyclic            = False
resources@gsnMaximize             = True 


resources@lbLabelBarOn            = False

resources@gsnSpreadColors         = True
resources@gsnSpreadColorStart     = 2
resources@gsnSpreadColorEnd       = 129
resources@gsnScalarContour        = True

resources@mpProjection            = "Stereographic" 
resources@mpCenterLonF            = -35.
resources@mpCenterLatF            = 63.
resources@mpLimitMode             = "LatLon"
resources@mpMinLatF               = 56.
resources@mpMaxLatF               = 70.
resources@mpMinLonF               = -52. ;-54.
resources@mpMaxLonF               = -23. ;-20. ;-15.
resources@mpGeophysicalLineColor  = "black"
resources@mpGeophysicalLineThicknessF = 0.75
resources@mpOutlineOn              = True
resources@mpFillOn                 = False
resources@mpOutlineBoundarySets    = "AllBoundaries"

resources@tiMainFontHeightF       = 0.03   
 
resources@cnFillOn                = True
resources@cnLinesOn               = False
resources@cnInfoLabelOn           = False  
resources@cnMissingValFillColor   = "gray85"
resources@cnMissingValFillPattern = 0 
resources@cnMissingValPerimOn     = True
resources@cnMissingValPerimColor  = "black"
resources@cnLevelSelectionMode    = "ManualLevels"    ; set manual contour
resources@cnMinLevelValF          = 0.0             ; set min contour level specified above
resources@cnMaxLevelValF          = 20.             ; set max contour level specified above
resources@cnLevelSpacingF         = 1.             ; set contour spacing specified above

resources@vcGlyphStyle = "LineArrow"
resources@vcRefMagnitudeF = 1.0
resources@vcRefLengthF = 0.01
resources@vcMonoLineArrowColor = True
resources@vcLineArrowColor = "black"
resources@vcMinDistanceF = 0.07
resources@vcRefAnnoOn = False

; set resources for near-gale force (>13m/s)overlay
  res_gale                            = True               ; reset options
  res_gale@gsnLeftString              = ""
  res_gale@gsnRightString             = ""
  res_gale@gsnFrame                   = False             ; Do not draw plot 
  res_gale@gsnDraw                    = False             ; Do not advance fr
  res_gale@cnInfoLabelOn              = False             ; Turn off info on contours at bottom
  res_gale@cnFillOn                   = False             ; turn on filled contours
  res_gale@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  res_gale@cnMinLevelValF             = 0.                ; set min contour level specified above
  res_gale@cnMaxLevelValF             = 13.0              ; set max contour level specified above
  res_gale@cnLevelSpacingF            = 13.0              ; set contour spacing specified above
  res_gale@cnLinesOn                  = True              ; contour lines specified above
  res_gale@cnLineLabelsOn             = True             ; line labels on specified above
  res_gale@cnLineColor                = "black"
  res_gale@cnLineThicknessF           = 2.0
  res_gale@tiXAxisOn                  = False
  res_gale@tiYAxisOn                  = False

; label lat/lon
lat_t = 69.0
lon_t = -40.5
txres                             = True
txres@txFontHeightF               = 0.08
txres@txFontThicknessF            = 2.0

; Actual data section:

plot = new(nnode, graphic)
xpos = 0
ypos = 0

do n = 0, nnode-1

; code for adding group colored perimeters
  resources@mpPerimOn = True
  resources@mpPerimLineThicknessF = 8.0

  if (n.eq.0.or.n.eq.1.or.n.eq.7)then
    resources@mpPerimLineColor = "forestgreen"
  end if
  if (n.eq.2.or.n.eq.8.or.n.eq.9.or.n.eq.16.or.n.eq.17) then
    resources@mpPerimLineColor = "gold"
  end if
  if (n.eq.3.or.n.eq.4.or.n.eq.10.or.n.eq.11.or.n.eq.18.or.n.eq.19) then
    resources@mpPerimLineColor = "deeppink3"
  end if
  if (n.eq.5.or.n.eq.6.or.n.eq.12.or.n.eq.13.or.n.eq.20)
    resources@mpPerimLineColor = "cyan3"
  end if
  if (n.eq.14.or.n.eq.21.or.n.eq.28.or.n.eq.29)
    resources@mpPerimLineColor = "darkorange"
  end if
  if (n.eq.15.or.n.eq.22.or.n.eq.23.or.n.eq.30)
    resources@mpPerimLineColor = "brown"
  end if
  if (n.eq.24.or.n.eq.25.or.n.eq.31.or.n.eq.32)
    resources@mpPerimLineColor = "blue3"
  end if
  if (n.eq.26.or.n.eq.27.or.n.eq.33.or.n.eq.34)
    resources@mpPerimLineColor = "red"
  end if

  print("Plotting graph "+n+" ("+xpos+","+ypos+")")
  u_som2d   = onedtond(u_som(n,:),(/n_sn,n_we/))
  u_som2d@lat2d = lat2d
  u_som2d@lon2d = lon2d
  v_som2d   = onedtond(v_som(n,:),(/n_sn,n_we/))
  v_som2d@lat2d = lat2d
  v_som2d@lon2d = lon2d

  som2d = (/sqrt((u_som2d*u_som2d)+(v_som2d*v_som2d))/)
  som2d@lat2d = lat2d
  som2d@lon2d = lon2d

  cplot = gsn_csm_vector_scalar_map(wks,u_som2d,v_som2d,som2d,resources)
  cplot2 = gsn_csm_contour(wks,som2d,res_gale)
  overlay(cplot,cplot2)
  dum = new(1,graphic)
  dum = gsn_add_text(wks,cplot, "("+xpos+","+ypos+")", lon_t, lat_t, txres)
  plot(n) = cplot


; Update xpos and ypos for next time through:
  xpos = xpos + 1
  if (xpos.eq.nx_node) then
    xpos = 0
    ypos = ypos + 1
  end if

end do

print("Paneling...")

res_pan                       = True ; panel resources
;res_pan@txString              = "Master SOM of near surface winds and pattern groups"
;res_pan@txFontHeightF         = 0.015 ; title font height
res_pan@gsnPaperOrientation   = "landscape" ; landscape mode
res_pan@gsnPanelYWhiteSpacePercent = 4        ; Add white space b/w plots.
res_pan@gsnPanelXWhiteSpacePercent = 4        ; Add white space b/w plots.
res_pan@gsnMaximize           = True ; make it big
res_pan@gsnPanelLabelBar      = True ; common label bar
res_pan@lbTitleString         = "m s-1"
res_pan@lbTitlePosition       = "right"
res_pan@lbLabelAutoStride     = "true"
res_pan@lbLabelFontHeightF    = 0.01
res_pan@lbTitleJust           = "CenterLeft"
res_pan@lbTitleFontHeightF    = 0.015 
res_pan@lbTitleDirection      = "Across"
res_pan@pmLabelBarWidthF      = 0.99 ;0.75
res_pan@pmLabelBarHeightF     = 0.09

gsn_panel(wks,plot,(/ny_node, nx_node/),res_pan)

  delete(wks)
  system("convert -trim -border 10 -bordercolor white -density 300 "+  \
         "-rotate -90 -trim -border 10 "+outfile+".ps "+outfile+".png")


end

