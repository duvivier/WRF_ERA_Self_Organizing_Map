; This NCL script plots an average or anomaly for each node for
; a particular variable in a SOM.  It also plots the differences 
; in average or anomaly per node between two runs of interest.
;
; 9 Oct 2008 - Matt Higgins
; 5 Mar 2011 - Matt Higgins
;
; Edits: Melissa A. Nigro
; August 2011

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

; ******************************************************
  var   = "slp"  ; slp, 10m_wind, Z_p, wind_p, wind_e, pg, cf ,advec
  level = ""  ; 0=1000 mb, 1=950mb, 2=900mb, 3=850mb, 4=700mb, 5=500mb, 6=300mb
  levelstr = ""
  anom_tag    = "anom" ; anom or avg
  startyearmonth   = 200810
  endyearmonth     = 201009
  yearmonth = (/"200810","200811","200812","200901","200902","200903","200904","200905","200906","200907","200908","200909","200910","200911","200912","201001","201002","201003","201004","201005","201006","201007","201008","201009"/)
  f1_type     = "wrf"
  f1_descrip  = "data"
  nx_input = "6"
  ny_input = "4"
  a_input = "0.005"
  l_input = "1000000"
  r_input = "2"
; ******************************************************
; Figure out correct input and output files based on above information.
  outfile    = nx_input+"x_"+ny_input+"y/som_plots/"+anom_tag+"/"+var+level+"_"+anom_tag+"_"+nx_input+"x_"+ny_input+"y_"+a_input+"_rlen"+l_input+"_r"+r_input
  outdata    = "som_data/"+var+level+"_"+anom_tag+"_"+nx_input+"x_"+ny_input+"y_"+a_input+"_rlen"+l_input+"_r"+r_input

  plottitle1 = ""
  var_title = var
  if (var.eq."slp") then
    var_title = "SLP"
  end if
  if (var.eq."pg") then
    var_title = "PGF"
  end if
  if (var.eq."10m_wind") then
    var_title = "10 m Wind"
  end if
  if (anom_tag.eq."anom") then
    anom_title = "Anomalies"
  end if
  if (anom_tag.eq."avg") then
    anom_title = "Average"
  end if
  datatitle1 = "WRF"
if (var.ne."10m_wind".and.var.ne."wind_p".and.var.ne."wind_e".and.var.ne."pg".and.var.ne."cf".and.var.ne."advec") then
  datafile1 = "som_extract_plotting/"+anom_tag+"/"+f1_type+"_"+f1_descrip+"_"+startyearmonth+"_"+endyearmonth+"_"+var+level+".dat"
else 
  if (var.eq."10m_wind") then
  u_datafile1 = "som_extract_plotting/"+anom_tag+"/"+f1_type+"_"+f1_descrip+"_"+startyearmonth+"_"+endyearmonth+"_u_10m.dat"
  v_datafile1 = "som_extract_plotting/"+anom_tag+"/"+f1_type+"_"+f1_descrip+"_"+startyearmonth+"_"+endyearmonth+"_v_10m.dat"
  end if
  if (var.eq."wind_p") then
  u_datafile1 = "som_extract_plotting/"+anom_tag+"/"+f1_type+"_"+f1_descrip+"_"+startyearmonth+"_"+endyearmonth+"_u_"+level+".dat"
  v_datafile1 = "som_extract_plotting/"+anom_tag+"/"+f1_type+"_"+f1_descrip+"_"+startyearmonth+"_"+endyearmonth+"_v_"+level+".dat"
  end if
  if (var.eq."wind_e") then
  u_datafile1 = "som_extract_plotting/"+anom_tag+"/"+f1_type+"_"+f1_descrip+"_"+startyearmonth+"_"+endyearmonth+"_u_e_"+level+".dat"
  v_datafile1 = "som_extract_plotting/"+anom_tag+"/"+f1_type+"_"+f1_descrip+"_"+startyearmonth+"_"+endyearmonth+"_v_e_"+level+".dat"
  end if
  if (var.eq."pg") then
  u_datafile1 = "som_extract_plotting/"+anom_tag+"/"+f1_type+"_"+f1_descrip+"_"+startyearmonth+"_"+endyearmonth+"_u_pg.dat"
  v_datafile1 = "som_extract_plotting/"+anom_tag+"/"+f1_type+"_"+f1_descrip+"_"+startyearmonth+"_"+endyearmonth+"_v_pg.dat"
  end if
  if (var.eq."cf") then
  u_datafile1 = "som_extract_plotting/"+anom_tag+"/"+f1_type+"_"+f1_descrip+"_"+startyearmonth+"_"+endyearmonth+"_u_cf.dat"
  v_datafile1 = "som_extract_plotting/"+anom_tag+"/"+f1_type+"_"+f1_descrip+"_"+startyearmonth+"_"+endyearmonth+"_v_cf.dat"
  end if
  if (var.eq."advec") then
  u_datafile1 = "som_extract_plotting/"+anom_tag+"/"+f1_type+"_"+f1_descrip+"_"+startyearmonth+"_"+endyearmonth+"_u_advec.dat"
  v_datafile1 = "som_extract_plotting/"+anom_tag+"/"+f1_type+"_"+f1_descrip+"_"+startyearmonth+"_"+endyearmonth+"_v_advec.dat"
  end if
end if
    datefile1 = "./dates/"+startyearmonth+"_"+endyearmonth+"_dates.txt" 
    visfile1  = nx_input+"x_"+ny_input+"y/visual/"+f1_type+"_"+f1_descrip+"_"+startyearmonth+"_"+endyearmonth+"_"+nx_input+"x_"+ny_input+"y_"+a_input+"_rlen"+l_input+"_r"+r_input+".vis" 
  plottitle1 = var_title+" "+anom_title
  print(plottitle1+"")


  nx_node = 6
  ny_node = 4
  nnode = nx_node * ny_node
  print("Loading data...")
  f1 = addfile("/data3/marichar/wrf_15km/inner/200810/2008100100-f012-cf-inner-SOM.nc", "r")
  lat2d = f1->lat
  lon2d = f1->lon
  lat1d = ndtooned(lat2d)
  lon1d = ndtooned(lon2d)
  dims = dimsizes(lat2d)
  n_sn = dims(0)        ; nx_grid
  n_we = dims(1)        ; ny_grid
  n_tot = n_sn * n_we   ; ncol

 
if (var.ne."10m_wind".and.var.ne."wind_p".and.var.ne."wind_e".and.var.ne."pg".and.var.ne."cf".and.var.ne."advec") then
 som_header = readAsciiHead(datafile1,1)
else 
 som_header = readAsciiHead(u_datafile1,1)
end if

 delim = " "
 ncol = stringtoint(str_get_field(som_header,1,delim))
  if (ncol.ne.n_tot) then
    print("data mixup!")
    exit
  end if

  print("Now is a good time for a cup of coffee.")

if (var.ne."10m_wind".and.var.ne."wind_p".and.var.ne."wind_e".and.var.ne."pg".and.var.ne."cf".and.var.ne."advec") then
  data1 = readAsciiTable(datafile1,ncol,"float",1)
if (var.ne."pg".and.var.ne."cf".and.var.ne."pot_df") then
  data1@_FillValue = -999
else
  data1@_FillValue = -9999
end if
  nsizes = dimsizes(data1)
  ndates1 = nsizes(0)
else
  u_data1 = readAsciiTable(u_datafile1,ncol,"float",1)
  v_data1 = readAsciiTable(v_datafile1,ncol,"float",1)
if (var.ne."pg".and.var.ne."cf".and.var.ne."advec") then
  u_data1@_FillValue = -999999
  v_data1@_FillValue = -999999
else
  u_data1@_FillValue = -9999
  v_data1@_FillValue = -9999
end if
  nsizes = dimsizes(u_data1)
  ndates1 = nsizes(0)
end if

  topo_2d = f1->Z_sfc
if (var.ne."pg".and.var.ne."cf".and.var.ne."advec") then
  topo_2d@_FillValue = -999
else
  topo_2d@_FillValue = -9999
end if
  topo_2d@lat2d = lat2d
  topo_2d@lon2d = lon2d
  topo = ndtooned(topo_2d)
if (var.ne."pg".and.var.ne."cf".and.var.ne."advec") then
  topo@_FillValue = -999
else
  topo@_FillValue = -9999
end if

  if (var.eq."slp") then
    colormap = "BlWhRe"
    unit = "hPa"
    cmin1 = -20.
    cmax1 = 20.
    clev1 = 1.
  end if
  if (var.eq."pot_df") then
    colormap = "geopotential_color_table_SOM"
    unit = "K"
    cmin1 = -30.
    cmax1 = 30.
    clev1 = 5.
  end if
  if (var.eq."Z_p") then
    colormap = "geopotential_color_table_SOM"
    unit = "m"
   if (level.eq.1) then
    cmin1 = 100.
    cmax1 = 500.
   end if
   if (level.eq.4) then
    cmin1 = 2350.
    cmax1 = 2850.
   end if
    clev1 = 15.
   if (anom_tag.eq."anom") then
    cmin1 = -100.
    cmax1 = 100.
    clev1 = 5.
   end if
    plottitle1 = datatitle1+" "+var_title+" "+levelstr+" "+anom_title
  end if
  if (var.eq."10m_wind") then
    colormap = "wind_color_table_SOM"
    unit = "ms-1"
  end if
  if (var.eq."wind_p".or.var.eq."wind_e") then
    colormap = "wind_color_table_SOM"
    unit = "ms-1"
    plottitle1 = datatitle1+" "+var_title+" "+levelstr+" "+anom_title
  end if
  if (var.eq."pg".or.var.eq."cf".or.var.eq."advec") then
    colormap = "precip_11lev_mod"
    unit  = "ms-2"
    cmin1 = 0.
    if (var.eq."pg") then
    cmax1 = 0.0035
    clev1 = 0.0005
    else
    cmax1 = 0.002
    clev1 = 0.0005
    end if
  end if

  ; Bring in visual file that places each date at a given node
  print("Loading SOM visual data.")
  vis1 = new((/ndates1,3/),integer)
  vis1 = readAsciiTable(visfile1,3,"integer",1)

  print("Loading dates.")
  dates1 = ndtooned(readAsciiTable(datefile1,1,"string",0))
;  dates1 = readAsciiTable(datefile1,1,"string",0)
  dateschar1 = stringtochar(dates1)
  sdatemonths1 = chartostring(dateschar1(:,4:5))

sizes_cf = dimsizes(lat2d)
nx_grid_cf = sizes_cf(0)
ny_grid_cf = sizes_cf(1)


  print("Done loading.  Setting graphics options.")


  wks = gsn_open_wks("ps",outfile)
if (var.eq."slp") then
  gsn_merge_colormaps(wks,colormap,(/"gray","red","orange","blue","green","purple"/))
else
  gsn_merge_colormaps(wks,colormap,(/"red","orange","blue","green","purple"/))
end if

; Graphic options:
 resources                             = True
 resources@gsnMaximize                 = True
 resources@gsnFrame                    = False
 resources@gsnDraw                     = False
 resources@gsnAddCyclic                = False
 resources@mpProjection                = "Stereographic"
if (var.ne."10m_wind".and.var.ne."wind_p".and.var.ne."wind_e".and.var.ne."pg".and.var.ne."cf".and.var.ne."advec") then
 resources@mpLimitMode                 = "Corners"
 resources@mpLeftCornerLatF            = lat2d(0,0)
 resources@mpLeftCornerLonF            = lon2d(0,0)
 resources@mpRightCornerLatF           = lat2d(n_sn-1,n_we-1)
 resources@mpRightCornerLonF           = lon2d(n_sn-1,n_we-1)
 resources@mpCenterLonF                = 180.
 resources@mpCenterLatF                = -90.
else
 resources@mpLimitMode             = "Points"
 resources@mpCenterLonF            = -180.
 resources@mpCenterLatF            = -85.
 resources@mpLeftPointLatF         = -78.
 resources@mpLeftPointLonF         = 160.
 resources@mpRightPointLatF        = -78.
 resources@mpRightPointLonF        = -145.
 resources@mpTopPointLatF          = -77.
 resources@mpTopPointLonF          = 180.
 resources@mpBottomPointLatF       = -87.
 resources@mpBottomPointLonF       = 180.
end if
 resources@mpGeophysicalLineColor      = "black"
 resources@mpGeophysicalLineThicknessF = 0.75
 resources@mpOutlineOn                 = False
 resources@mpFillOn                    = False

 resources@cnFillOn                    = True
 resources@cnMissingValFillColor       = -1
 resources@cnLineLabelsOn              = False
 resources@cnInfoLabelOn               = False

 resources@tiMainFontHeightF           = 0.03
 resources@lbLabelBarOn                = False

 resources@gsnSpreadColors             = True
 resources@cnLinesOn                   = False
 resources@gsnSpreadColorEnd           = -7
if (var.ne."10m_wind".and.var.ne."wind_p".and.var.ne."wind_e") then
 resources@cnLevelSelectionMode = "ManualLevels"
 resources@cnLevelSpacingF      = clev1
 resources@cnMaxLevelValF       = cmax1
 resources@cnMinLevelValF       = cmin1
else
 resources@cnLevelSelectionMode = "ExplicitLevels"
 if (var.eq."10m_wind".or.(var.eq."wind_e".and.level.eq.0)) then
 resources@cnLevels = (/0.5,1,1.5,2,2.5,3,3.5,4,4.5,5,5.5,6,6.5,7,7.5,8,8.5,9,9.5,10,10.5,11,11.5,12,12.5,13,13.5,14,14.5,15,15.5,16,16.5,17,17.5,18/)
 end if
 if (var.eq."wind_p".or.(var.eq."wind_e".and.level.ne.0)) then
 resources@cnLevels = (/0.5,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,26,27,28,29,30/)
 end if
 resources@gsnScalarContour = True
 resources@vcGlyphStyle = "LineArrow"
 resources@vcRefMagnitudeF = 1.0
 resources@vcRefLengthF = 0.01
 resources@vcMonoLineArrowColor = True
 resources@vcLineArrowColor = "black"
 resources@vcMinDistanceF = 0.05
 resources@vcRefAnnoOn = False
end if
 resources@tfDoNDCOverlay = False

 topores = True
 topores@gsnMaximize    = True
 topores@gsnAddCyclic   = False
 topores@gsnFrame       = False
 topores@gsnDraw        = False
; topores@gsnPaperOrientation = "landscape"
 topores@cnLinesOn      = True
 topores@cnFillOn       = False
 topores@cnLineLabelsOn = False
 topores@cnLineColor    = "gray"
 topores@cnInfoLabelOn  = False
 topores@tiXAxisOn      = False
 topores@tiYAxisOn      = False
; topores@cnInfoLabelString = "CONTOUR by $CIU$"
 topores@tfDoNDCOverlay = False

 topores@tiMainOn       = False
 topores@gsnLeftString  = ""
 topores@gsnRightString = ""

 nodestring       = new(n_tot,"string") ; this is used for a double check

    check1 = 0
    check2 = 0
    xpos = 0
    ypos = 0
    n = 0

      visall1 = vis1 ; get 'em all
      ndates1 = dimsizes(visall1(:,0))
 
    plot1 = new(nnode, graphic)
    dum1  = new(nnode, graphic)


if (var.ne."10m_wind".and.var.ne."wind_p".and.var.ne."wind_e".and.var.ne."pg".and.var.ne."cf".and.var.ne."advec") then
    var_data1 = new(ncol,"float")
    avg_data1 = new(ncol,"float")
    ; to keep all data for NetCDF output at end of program
    avg1_allnodes    = new((/nnode,n_sn,n_we/),"float") 
else
    u_var_data1 = new(ncol,"float")
    v_var_data1 = new(ncol,"float")
    u_avg_data1 = new(ncol,"float")
    v_avg_data1 = new(ncol,"float")
    ; to keep all data for NetCDF output at end of program
    u_avg1_allnodes = new((/nnode,n_sn,n_we/),"float")
    v_avg1_allnodes = new((/nnode,n_sn,n_we/),"float")
end if

    nptused1  = new(ncol, "integer")
    

    do y = 0, ny_node - 1
      do x = 0, nx_node - 1

print("node"+x+","+y)

; These are the dates for this particular node:

        dateindices1 = ind(visall1(:,0).eq.x.and.(visall1(:,1).eq.y))
        
; This is the data for this node:

if (var.ne."10m_wind".and.var.ne."wind_p".and.var.ne."wind_e".and.var.ne."pg".and.var.ne."cf".and.var.ne."advec") then
        if (all(ismissing(dateindices1))) then
          node_data1   = new(n_tot, "float")
          node_ndates1 = 0
        end if
        if (.not.all(ismissing(dateindices1))) then
          node_data1 = data1(dateindices1,:)
          node_ndates1 = dimsizes(dateindices1)
        end if


; Check to make sure all dates are accounted.
        check1 = check1 + node_ndates1


; Need to do some checks to make sure we actually have two dimensional data:
        rank1 = dimsizes(dimsizes(node_data1))
        if (rank1.eq.1) then
          node_data1_temp = conform_dims((/1,n_tot/),node_data1,1)
          delete(node_data1)
          node_data1 = node_data1_temp
          delete(node_data1_temp)
        end if

        node_data1!0 = "dates"
        node_data1!1 = "cords"
        if (var.ne."pg") then
        node_data1@_FillValue = -999999
        else
        node_data1@_FillValue = -9999
        end if
  
; calculate averages and variance
        if (node_ndates1.ne.0) then
          stat2(node_data1(cords|:,dates|:),avg_data1,var_data1,nptused1)
        end if


        avg2d1 = onedtond(avg_data1,(/n_sn,n_we/))
        avg2d1@lat2d = lat2d
        avg2d1@lon2d = lon2d
        if (var.ne."pg".and.var.ne."cf") then
        avg2d1@_FillValue = -999999
        else
        avg2d1@_FillValue = -9999
        end if


if (var.eq."slp") then
 avg2d1 = where(topo_2d.gt.500,avg2d1@_FillValue,avg2d1)
end if
        
        print("("+x+","+y+") "+f1_type+" "+f1_descrip+": min is "+min(avg2d1)+" max is "+max(avg2d1)+" with n = "+node_ndates1)

        resources@gsnRightString = "["+xpos+","+ypos+"]"  ; (this changes)
        nodestring(n) = resources@gsnRightString ; for reference
        resources@gsnRightStringParallelPosF = 0.98 ; scoot it in just a bit
        resources@gsnRightStringFontHeightF  = 0.03
        resources@gsnLeftStringParallelPosF = 0.02 ; scoot it in just a bit as well
        resources@gsnLeftString = round(min(avg2d1),3)+"/" + round(max(avg2d1),3)+" "+unit
        resources@gsnLeftStringFontHeightF  = 0.03
;        resources@gsnCenterString = "n = "+node_ndates1
        
resources@mpPerimOn = True
resources@mpPerimLineThicknessF = 7.0

if (n.eq.0.or.n.eq.1.or.n.eq.2.or.n.eq.3.or.n.eq.6.or.n.eq.7.or.n.eq.12.or.n.eq.13.or.n.eq.18) then

resources@mpPerimLineColor = "red"

end if

if (n.eq.4.or.n.eq.5) then

resources@mpPerimLineColor = "orange"

end if

if (n.eq.8.or.n.eq.9.or.n.eq.10.or.n.eq.16) then

resources@mpPerimLineColor = "blue"

end if

if (n.eq.11.or.n.eq.17.or.n.eq.22.or.n.eq.23) then

resources@mpPerimLineColor = "green"

end if

if (n.eq.14.or.n.eq.15.or.n.eq.19.or.n.eq.20.or.n.eq.21) then

resources@mpPerimLineColor = "purple"

end if

        plot1(n) = gsn_csm_contour_map(wks,avg2d1,resources)
        ploto = gsn_csm_contour(wks,topo_2d,topores)
        overlay(plot1(n),ploto)

;; Add polymarker for Prince Olav Mountains

;polyres = True
;polyres@gsMarkerIndex = 7
;polyres@gsMarkerSizeF = 10.
;polyres@gsMarkerThicknessF = 4.0
;polyres@gsMarkerColor = "black"

;dum1(n) = gsn_add_polymarker(wks,plot1(n),190.,-85.,polyres)

else
        if (all(ismissing(dateindices1))) then
          u_node_data1   = new(n_tot, "float")
          v_node_data1   = new(n_tot, "float")
          node_ndates1 = 0
        end if
        if (.not.all(ismissing(dateindices1))) then
          u_node_data1 = u_data1(dateindices1,:)
          v_node_data1 = v_data1(dateindices1,:)
          node_ndates1 = dimsizes(dateindices1)
        end if

print("made arrays")

; Check to make sure all dates are accounted.
        check1 = check1 + node_ndates1


; Need to do some checks to make sure we actually have two dimensional data:
        rank1 = dimsizes(dimsizes(u_node_data1))
        if (rank1.eq.1) then
          u_node_data1_temp = conform_dims((/1,n_tot/),u_node_data1,1)
          v_node_data1_temp = conform_dims((/1,n_tot/),v_node_data1,1)
          delete(u_node_data1)
          delete(v_node_data1)
          u_node_data1 = u_node_data1_temp
          v_node_data1 = v_node_data1_temp
          delete(u_node_data1_temp)
          delete(v_node_data1_temp)
        end if

print("changed rank")

        u_node_data1!0 = "dates"
        u_node_data1!1 = "cords"
        if (var.ne."pg") then
        u_node_data1@_FillValue = -999999
        else
        u_node_data1@_FillValue = -9999
        end if
        v_node_data1!0 = "dates"
        v_node_data1!1 = "cords"     
        if (var.ne."pg") then
        v_node_data1@_FillValue = -999999  
        else
        v_node_data1@_FillValue = -9999
        end if

; calculate averages and variance
        if (node_ndates1.ne.0) then
          stat2(u_node_data1(cords|:,dates|:),u_avg_data1,u_var_data1,nptused1)
          stat2(v_node_data1(cords|:,dates|:),v_avg_data1,v_var_data1,nptused1)
        end if

print("got average")

        u_avg2d1 = onedtond(u_avg_data1,(/n_sn,n_we/))
        u_avg2d1@lat2d = lat2d
        u_avg2d1@lon2d = lon2d
        if (var.ne."pg") then
        u_avg2d1@_FillValue = -999999
        else
        u_avg2d1@_FillValue = -9999
        end if
        v_avg2d1 = onedtond(v_avg_data1,(/n_sn,n_we/))
        v_avg2d1@lat2d = lat2d
        v_avg2d1@lon2d = lon2d
        if (var.ne."pg") then
        v_avg2d1@_FillValue = -999999
        else
        v_avg2d1@_FillValue = -9999
        end if
        ws_avg2d1 = (/sqrt((u_avg2d1*u_avg2d1)+(v_avg2d1*v_avg2d1))/)
        ws_avg2d1@lat2d = lat2d
        ws_avg2d1@lon2d = lon2d
        if (var.ne."pg") then
        ws_avg2d1@_FillValue = -999999
        else
        ws_avg2d1@_FillValue = -9999
        end if

print("got magnitude")

if (var.eq."10m_wind") then
 u_avg2d1 = where(topo_2d.gt.200.or.lat2d.gt.-78.or.(lon2d.gt.-145.and.lon2d.lt.0),u_avg2d1@_FillValue,u_avg2d1)
 v_avg2d1 = where(topo_2d.gt.200.or.lat2d.gt.-78.or.(lon2d.gt.-145.and.lon2d.lt.0),v_avg2d1@_FillValue,v_avg2d1)
 ws_avg2d1 = where(topo_2d.gt.200.or.lat2d.gt.-78.or.(lon2d.gt.-145.and.lon2d.lt.0),ws_avg2d1@_FillValue,ws_avg2d1)
end if

; u_avg2d1 = where(topo_2d.gt.700.or.lat2d.gt.-78.,u_avg2d1@_FillValue,u_avg2d1)
; v_avg2d1 = where(topo_2d.gt.700.or.lat2d.gt.-78.,v_avg2d1@_FillValue,v_avg2d1)
; ws_avg2d1 = where(topo_2d.gt.700.or.lat2d.gt.-78.,ws_avg2d1@_FillValue,ws_avg2d1)

print("set missing values")
        
        print("("+x+","+y+") "+f1_type+" "+f1_descrip+": min is "+min(ws_avg2d1)+" max is "+max(ws_avg2d1)+" with n = "+node_ndates1)

        resources@gsnRightString = "["+xpos+","+ypos+"]"  ; (this changes)
        nodestring(n) = resources@gsnRightString ; for reference
        resources@gsnRightStringParallelPosF = 0.98 ; scoot it in just a bit
        resources@gsnRightStringFontHeightF  = 0.03
        resources@gsnLeftStringParallelPosF = 0.02 ; scoot it in just a bit as well
        resources@gsnLeftString = round(min(ws_avg2d1),3)+"/" + round(max(ws_avg2d1),3)+" "+unit
        resources@gsnLeftStringFontHeightF   = 0.03
;        resources@gsnCenterString = "n = "+node_ndates1
 
resources@mpPerimOn = True
resources@mpPerimLineThicknessF = 7.0

if (n.eq.0.or.n.eq.1.or.n.eq.2.or.n.eq.3.or.n.eq.6.or.n.eq.7.or.n.eq.12.or.n.eq.13.or.n.eq.18) then

resources@mpPerimLineColor = "red"

end if

if (n.eq.4.or.n.eq.5) then

resources@mpPerimLineColor = "orange"

end if

if (n.eq.8.or.n.eq.9.or.n.eq.10.or.n.eq.16) then

resources@mpPerimLineColor = "blue"

end if

if (n.eq.11.or.n.eq.17.or.n.eq.22.or.n.eq.23) then

resources@mpPerimLineColor = "green"

end if

if (n.eq.14.or.n.eq.15.or.n.eq.19.or.n.eq.20.or.n.eq.21) then

resources@mpPerimLineColor = "purple"

end if


if (var.ne."pg".and.var.ne."cf".and.var.ne."advec") then
        plot1(n) = gsn_csm_vector_scalar_map(wks,u_avg2d1,v_avg2d1,ws_avg2d1,resources)
else
        plot1(n) = gsn_csm_contour_map(wks,ws_avg2d1,resources)
end if

        ploto = gsn_csm_contour(wks,topo_2d,topores)
        overlay(plot1(n),ploto)

;; Add polymarker for Prince Olav Mountains

;polyres = True
;polyres@gsMarkerIndex = 7
;polyres@gsMarkerSizeF = 10.
;polyres@gsMarkerThicknessF = 4.0
;polyres@gsMarkerColor = "black"

;dum1(n) = gsn_add_polymarker(wks,plot1(n),190.,-85.,polyres)

;print("made plot(n)")

end if

; Save our data for later output:
  if (var.ne."10m_wind".and.var.ne."wind_p".and.var.ne."wind_e".and.var.ne."pg".and.var.ne."cf".and.var.ne."advec") then
    avg1_allnodes(n,:,:)   = avg2d1(:,:)
  else
    u_avg1_allnodes(n,:,:) = u_avg2d1(:,:)
    v_avg1_allnodes(n,:,:) = v_avg2d1(:,:)
  end if

; Update xpos and ypos for next time through:
        xpos = xpos + 1
        if (xpos.eq.nx_node) then
          xpos = 0
          ypos = ypos + 1
        end if
        n = n + 1

        delete(dateindices1)
   if (var.ne."10m_wind".and.var.ne."wind_p".and.var.ne."wind_e".and.var.ne."pg".and.var.ne."cf".and.var.ne."advec") then
        delete(node_data1)
   else
        delete(u_node_data1)
        delete(v_node_data1)
   end if

      end do
    end do

    print("Creating final plot.")

    res_pan                     = True   ; panel resources
    res_pan@txFontHeightF       = 0.015   ; title font height
    res_pan@gsnPaperOrientation = "landscape" ; landscape mode
    res_pan@gsnMaximize         = True   ; make it big
    res_pan@gsnPanelLabelBar    = True   ; common label bar
    res_pan@lbLabelFontHeightF  = 0.01  ; make label bar fonts smaller
    res_pan@lbTitleString      = unit
    res_pan@lbTitlePosition    = "right"
    res_pan@lbLabelAutoStride  = "true"
    res_pan@lbLabelFontHeightF = 0.01
    res_pan@lbTitleJust        = "CenterLeft"
    res_pan@lbTitleFontHeightF = 0.01 
    res_pan@lbTitleDirection   = "Across"
    res_pan@gsnPanelXWhiteSpacePercent = 3.0
    res_pan@gsnPanelYWhiteSpacePercent = 3.0

;    res_pan@txString = plottitle1+"" 
    gsn_panel(wks,plot1,(/ny_node, nx_node/),res_pan)

draw(plot1)

    print("Done!  Nice job - the plot looks great.")
    
    if (check1.ne.ndates1) then
      print("Error.  Number of dates is not equal to total number of indices.")
      print("Num. dates: "+ndates1+"   Tot indices: "+check1)
    end if


    if (isvar("dateind1")) then
      delete(dateind1)
    end if


  print("Outputing averaged data to NetCDF.")

if (var.ne."10m_wind".and.var.ne."wind_p".and.var.ne."wind_e".and.var.ne."pg".and.var.ne."cf".and.var.ne."advec") then

  avg1_allnodes@long_name = f1_type+" "+f1_descrip
  avg1_allnodes@units = unit
  avg1_allnodes@lat2d = lat2d
  avg1_allnodes@lon2d = lon2d

  fout = addfile(outdata+".nc","c")
  fileAtt = True
  fileAtt@creation_dates = systemfunc("date")
  fileAtt@author = "Melissa Nigro"
  fileattdef(fout,fileAtt)

  fout->avg1_allnodes = avg1_allnodes

else
 
  u_avg1_allnodes@long_name = f1_type+" "+f1_descrip
  u_avg1_allnodes@units = unit
  u_avg1_allnodes@lat2d = lat2d
  u_avg1_allnodes@lon2d = lon2d

  v_avg1_allnodes@long_name = f1_type+" "+f1_descrip
  v_avg1_allnodes@units = unit
  v_avg1_allnodes@lat2d = lat2d
  v_avg1_allnodes@lon2d = lon2d

  u_fout = addfile(outdata+"_u.nc","c")
  u_fileAtt = True
  u_fileAtt@creation_dates = systemfunc("date")
  u_fileAtt@author = "Melissa Nigro"
  fileattdef(u_fout,u_fileAtt)

  u_fout->u_avg1_allnodes = u_avg1_allnodes
 
  v_fout = addfile(outdata+"_v.nc","c")
  v_fileAtt = True
  v_fileAtt@creation_dates = systemfunc("date")
  v_fileAtt@author = "Melissa Nigro"
  fileattdef(v_fout,v_fileAtt)

  v_fout->v_avg1_allnodes = v_avg1_allnodes
 
end if

end