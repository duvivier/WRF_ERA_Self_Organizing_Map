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
  master_vals = "winds0.01_rlen1000000_r4"
  datatitle1  = "wrf50_200511_200703_6h"
  datatitle1b = "era_i_200511_200703_6h"
  varcode = "PT_sfc"
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
plot1  = False ;True ; plot 1 - Frequency and frequency differences of all nodes (only needed once)
plot2  = True ; plot 2 - 6 panel of winter avgs, difference (w/stat sig), sum each term w/%contribution
plot3  = True ; plot 3 - 8 panel of groups' net % contribution
plot4  = False ;True ; plot 4 - 8 panel of groups' % contribution to net frequency
plot5  = False ;True ; plot 5 - 8 panel of groups' % contribution to net intrapattern
plot6  = False ;True ; plot 6 - 8 panel of groups' % contribution to net combined
plot7  = False ;True ; plot 7 - 24 panel of groups' % contribution to net, frequency, and intrapattern.
plot8  = False ;True ; plot 8 - % contribution of nodes to net difference - sum of terms - simple box plot
plot9  = False ;True ; plot 9 - % contribution of nodes to frequency net difference
plot10 = False ;True ; plot 10 - % contribution of nodes to intrapattern net difference
plot11 = False ;True ; plot 11 - % contribution of nodes to combined net difference
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; BEGIN SCRIPT
print("Calculating why averages differ for: "+varcode)

; get tag to let us know if it needs interpolation
title1_ch  = stringtocharacter(datatitle1)
title1_sub = title1_ch(0:4)
tag_1 = chartostring(title1_sub)
title1b_ch  = stringtocharacter(datatitle1b)
title1b_sub = title1b_ch(0:4)
tag_1b = chartostring(title1b_sub)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Calculate frequencies and change in frequencies
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;
; Load input files
;;;;;;;;;;
; Dates from data array index and visual file that places each date at a given node
print("Loading dates and SOM visual data")

if (tag_1 .eq. "wrf10")then
  datatitle_1 = "wrf10_200511_200703"
  plot_title1 = "WRF 10km"
  datefile_1 = "/data3/duvivier/SOM/training/dates/"+datatitle_1+"_dates.txt"
  visfile_1  = "/data3/duvivier/SOM/training/som_"+nx_input+ny_input+"/master/"+datatitle_1+"_"+master_vals+".vis"
end if
if (tag_1 .eq. "wrf50")then
  datatitle_1 = "wrf50_199701_200712"
  plot_title1 = "WRF 50km"
  datefile_1 = "/data3/duvivier/SOM/training/dates/"+datatitle_1+"_dates.txt"
  visfile_1  = "/data3/duvivier/SOM/training/som_"+nx_input+ny_input+"/master/"+datatitle_1+"_"+master_vals+".vis"
end if
if (tag_1b .eq. "era_i")then
  datatitle_1b = "era_i_199701_200712"
  plot_title1b = "ERA Interim"
  datefile_1b = "/data3/duvivier/SOM/training/dates/"+datatitle_1b+"_dates.txt"
  visfile_1b  = "/data3/duvivier/SOM/training/som_"+nx_input+ny_input+"/master/"+datatitle_1b+"_"+master_vals+".vis"
end if
if (tag_1b .eq. "wrf50")then
  datatitle_1b = "wrf50_199701_200712"
  plot_title1b = "WRF 50km"
  datefile_1b = "/data3/duvivier/SOM/training/dates/"+datatitle_1b+"_dates.txt"
  visfile_1b  = "/data3/duvivier/SOM/training/som_"+nx_input+ny_input+"/master/"+datatitle_1b+"_"+master_vals+".vis"
end if

;;;;;;;;;;
; Load information for two files
;;;;;;;;;;
; file1 - either wrf10 or wrf50
  dates_1 = ndtooned(readAsciiTable(datefile_1,1,"string",0)) ; ignores no rows
  ndates_1 = dimsizes(dates_1)
  dateschar_1 = stringtochar(dates_1)
  sdateym_1 = chartostring(dateschar_1(:,0:5))
  sdatehrs_1 = chartostring(dateschar_1(:,8:9))
  vis_1 = new((/ndates_1,3/),integer)
  vis_1 = readAsciiTable(visfile_1,3,"integer",1) ; ignores first row
; file1b - either wrf50 or era_i
  dates_1b = ndtooned(readAsciiTable(datefile_1b,1,"string",0)) ; ignores no rows
  ndates_1b = dimsizes(dates_1b)
  dateschar_1b = stringtochar(dates_1b)
  sdateym_1b = chartostring(dateschar_1b(:,0:5))
  sdatehrs_1b = chartostring(dateschar_1b(:,8:9))
  vis_1b = new((/ndates_1b,3/),integer)
  vis_1b = readAsciiTable(visfile_1b,3,"integer",1) ; ignores first row

;;;;;;;;;;
; Get just dates we want
;;;;;;;;;;
  hrs_6 = (/"00","06","12","18"/)
  ym_sub = (/"200511","200512","200601","200602","200603","200611","200612","200701","200702","200703"/)

;;;;;;;;;;
; Loop through plotting options
;;;;;;;;;;
if (tag_1 .eq. "wrf10")then     ; wrf 10km - just narrow down hours
  dateind_1 = ind(sdatehrs_1.eq.hrs_6(0).or.sdatehrs_1.eq.hrs_6(1).or.sdatehrs_1.eq.hrs_6(2).or.sdatehrs_1.eq.hrs_6(3))
  visall_1 = vis_1(dateind_1,:) ; get only every 6 hours
  ndates_1 = dimsizes(visall_1(:,0))
end if
if (tag_1 .eq. "wrf50")then     ; wrf 50km - narrow down years/months/hours
  dateind_1 = ind(sdateym_1.eq.ym_sub(0).or.sdateym_1.eq.ym_sub(1).or.sdateym_1.eq.ym_sub(2).or.sdateym_1.eq.ym_sub(3).or.sdateym_1.eq.ym_sub(4).or.sdateym_1.eq.ym_sub(5).or.sdateym_1.eq.ym_sub(6).or.sdateym_1.eq.ym_sub(7).or.sdateym_1.eq.ym_sub(8).or.sdateym_1.eq.ym_sub(9))
  visall_1_tmp = vis_1(dateind_1,:)
  sdatehrs_tmp = sdatehrs_1(dateind_1)
  delete(dateind_1)
  dateind_1 = ind(sdatehrs_tmp.eq.hrs_6(0).or.sdatehrs_tmp.eq.hrs_6(1).or.sdatehrs_tmp.eq.hrs_6(2).or.sdatehrs_tmp.eq.hrs_6(3))
  visall_1 = visall_1_tmp(dateind_1,:)
  ndates_1 = dimsizes(visall_1(:,0))
  delete(sdatehrs_tmp)
  delete(visall_1_tmp)
end if
if (tag_1b .eq. "era_i")then    ; era interim - just need to narrow down years/months
  dateind_1b = ind(sdateym_1b.eq.ym_sub(0).or.sdateym_1b.eq.ym_sub(1).or.sdateym_1b.eq.ym_sub(2).or.sdateym_1b.eq.ym_sub(3).or.sdateym_1b.eq.ym_sub(4).or.sdateym_1b.eq.ym_sub(5).or.sdateym_1b.eq.ym_sub(6).or.sdateym_1b.eq.ym_sub(7).or.sdateym_1b.eq.ym_sub(8).or.sdateym_1b.eq.ym_sub(9))
  visall_1b = vis_1b(dateind_1b,:)
  ndates_1b = dimsizes(visall_1b(:,0))
end if
if (tag_1b .eq. "wrf50")then     ; wrf 50km - narrow down years/months/hours
  dateind_1b = ind(sdateym_1b.eq.ym_sub(0).or.sdateym_1b.eq.ym_sub(1).or.sdateym_1b.eq.ym_sub(2).or.sdateym_1b.eq.ym_sub(3).or.sdateym_1b.eq.ym_sub(4).or.sdateym_1b.eq.ym_sub(5).or.sdateym_1b.eq.ym_sub(6).or.sdateym_1b.eq.ym_sub(7).or.sdateym_1b.eq.ym_sub(8).or.sdateym_1b.eq.ym_sub(9))
  visall_1b_tmp = vis_1b(dateind_1b,:)
  sdatehrs_tmp = sdatehrs_1b(dateind_1b)
  delete(dateind_1b)
  dateind_1b = ind(sdatehrs_tmp.eq.hrs_6(0).or.sdatehrs_tmp.eq.hrs_6(1).or.sdatehrs_tmp.eq.hrs_6(2).or.sdatehrs_tmp.eq.hrs_6(3))
  visall_1b = visall_1b_tmp(dateind_1b,:)
  ndates_1b = dimsizes(visall_1b(:,0))
  delete(sdatehrs_tmp)
  delete(visall_1b_tmp)
end if

;;;;;;;;;;
; Calculate frequencies for each data type
;;;;;;;;;;
; Calculate node counts and frequencies for comparison of interest
  nx_node = stringtoint(nx_input)
  ny_node = stringtoint(ny_input)
  nnode = nx_node*ny_node

; variable 1
  nodefreq_1   = new((/nx_node,ny_node/),"float") 
  freq_nodes_1     = new((/nnode/),"float") 
  nodecount_1    = new((/nnode/),"integer") 
; variable_1b
  nodefreq_1b   = new((/nx_node,ny_node/),"float") 
  freq_nodes_1b     = new((/nnode/),"float") 
  nodecount_1b    = new((/nnode/),"integer") 

; set default check values
  check1 = 0
  check1b = 0
  n = 0
; loop through each node
do y = 0, ny_node - 1
 do x = 0, nx_node - 1

  print("node: "+x+","+y)
  ; These are the dates for this particular node:
  dateindices_1 = ind(visall_1(:,0).eq.x.and.(visall_1(:,1).eq.y))
  dateindices_1b = ind(visall_1b(:,0).eq.x.and.(visall_1b(:,1).eq.y))
        
  ; Calculate frequencies
  ; variable 1
  if (all(ismissing(dateindices_1))) then
    node_ndates_1 = 0
    nodefreq_1(n) = 0
    nodecount_1(n) = 0
  end if
  if (.not.all(ismissing(dateindices_1))) then
    node_ndates_1 = dimsizes(dateindices_1)
    nodefreq_1(x,y) = (int2flt(node_ndates_1)/int2flt(ndates_1))*100.
    freq_nodes_1(n) = (int2flt(node_ndates_1)/int2flt(ndates_1))*100.
    nodecount_1(n) = node_ndates_1
  end if
  check1 = check1 + node_ndates_1  ; make sure all dates are counted
  ; variable 1b
  if (all(ismissing(dateindices_1b))) then
    node_ndates_1b = 0
    nodefreq_1b(n) = 0
    nodecount_1b(n) = 0
  end if
  if (.not.all(ismissing(dateindices_1b))) then
    node_ndates_1b = dimsizes(dateindices_1b)
    nodefreq_1b(x,y) = (int2flt(node_ndates_1b)/int2flt(ndates_1b))*100.
    freq_nodes_1b(n) = (int2flt(node_ndates_1b)/int2flt(ndates_1b))*100.
    nodecount_1b(n) = node_ndates_1b
  end if
  check1b = check1b + node_ndates_1b  ; make sure all dates are counted

   n = n + 1
   delete(dateindices_1)
   delete(dateindices_1b)
 end do
end do

; Check the dates and print error messages if calculation fails
if (check1.ne.ndates_1) then
 print("Error.  Number of dates is not equal to total number of indices.")
 print("Num. dates: "+ndates_1+"   Tot indices: "+check1)
end if
if (check1b.ne.ndates_1b) then
 print("Error.  Number of dates is not equal to total number of indices.")
 print("Num. dates: "+ndates_1b+"   Tot indices: "+check1b)
end if

;;;;;;;;;;
; Calculate if frequencies are statistically different
;;;;;;;;;;
; make new array to plot
test_stat = new((/nx_node,ny_node/),double)
test_stat = 0.
freq_diff = nodefreq_1 - nodefreq_1b ; get difference in frequencies
test_stat_num = freq_diff/100.
nf1 = nodefreq_1/100.  ; convert from % to just ratio
nf1b = nodefreq_1b/100.
test_stat_den = sqrt((nf1b*(1-nf1b)/ndates_1b) + (nf1*(1-nf1)/ndates_1))
test_stat_den = where(test_stat_den.eq.0,test_stat_den@_FillValue,test_stat_den) ; set 0 to missing to avoid divide by zero error
test_stat = test_stat_num/test_stat_den
test_stat = where(ismissing(test_stat),0,test_stat)

; statistical significance meanings:
; if test_stat .gt. 2.58 then it's 95% statistically significant
; if test_stat .ge. 1.96 and .lt. 2.58 then it's 95% statistically significant
; if test_stat .ge. 1.645 and .lt. 1.96 then it's 95% statistically significant
; NOTE: the same is true in reverse for negative values of these numbers

print("completed frequency calculations")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Calculate node differences
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;
; Set information for variable
;;;;;;;;;;
; add each variable set in the c-shell 'varcode' and assign it a title and other necessary information
if (varcode.eq."PT_sfc") then
  vartitle1 = "Avg Surface Potential Temp"
  invar1 = "T_sfc_avg"
  invar2 = "p_sfc_avg"
  vartype = "2d"
  cmaptype = "temperature"
  zoom = True
  convert_to_C = True
end if

; Set the contour interval for each input variable   
; set contour limits manually:
  if (cmaptype.eq."temperature")then
    cmin1               = -20.
    cmax1               = 10.
    clev1               = 2.
    stride1             = 2                 ; label stride
    cmin2               = -10.
    cmax2               = 10.
    clev2               = 1.0
    stride2             = 2                 ; label stride for diff plot
    cmin3               = -5.0
    cmax3               = 5.0
    clev3               = 0.5
    stride3             = 2                 ; label stride
    cmin4               = -1.0
    cmax4               = 1.0
    clev4               = 0.1
    stride4             = 2                 ; label stride for diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False              ; lines for diff plot
    cntype              = "AreaFill"
    spreadstart1        = 67                ; start at color
    spreadend1          = 106               ; end at color
    spreadstart2        = 67                ; start at color
    spreadend2          = 106               ; end at color
    spreadstart3        = 67                ; start at color
    spreadend3          = 106               ; end at color
    colormap            = "temp64_anoms.dave"
  end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Data Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dir1 = "/data3/duvivier/SOM/training/som_"+nx_input+ny_input+"/master/node_avgs/"

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

  ; create all-node array for node average variable
  var1 = new((/nnode,n_sn_1,n_we_1/),"float")
  var1b = new((/nnode,n_sn_1b,n_we_1b/),"float")
  fill = var1@_FillValue

; create variables for other combinations
  var2 = new((/nnode,n_sn_1,n_we_1/),"float")
  var2b = new((/nnode,n_sn_1b,n_we_1b/),"float") 
  ; make sea ice var - overlay with everything
  seaice_1 = new((/nnode,n_sn_1,n_we_1/),"float")
  seaice_1b = new((/nnode,n_sn_1b,n_we_1b/),"float")

;;;;;;;;;;
; Load in actual data for analysis
;;;;;;;;;;
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

  var2(n,:,:) = f1->$invar2$(south_north|:,west_east|:)
  var2b(n,:,:) = f1b->$invar2$(south_north|:,west_east|:)

  seaice_1(n,:,:) = f1->SeaIce_avg(south_north|:,west_east|:)
  seaice_1b(n,:,:) = f1b->SeaIce_avg(south_north|:,west_east|:)

  ; delete vars to use in next loop
  delete(fname1)
  delete(f1)
  delete(fname1b)
  delete(f1b)
  n = n+1
 end do
end do
delete(n)

print("Loaded "+varcode+" from both files")
;;;;;;;;;;
; manipulate arrays as needed - post interpolation
;;;;;;;;;;
; convert temperature to potential temperature
pot_temp = var1*((1000.0/var2)^0.286)
copy_VarMeta(var1, pot_temp)
pot_temp_b = var1b*((1000.0/var2b)^0.286)
copy_VarMeta(var1b, pot_temp_b)
delete(var1)
delete(var1b)
var1 = pot_temp
var1@long_name = "Potential Temperature at surface"
var1@standard_name = "Surface potential temp"
var1b = pot_temp_b
var1b@long_name = "Potential Temperature at surface"
var1b@standard_name = "Surface potential temp"
delete(pot_temp)
delete(pot_temp_b)

print("Manipulating vars as needed")
if (isvar("convert_to_C").and.(convert_to_C)) then
    var1 = var1 - 273.15
   if (varcode .eq. "T_sfc")then
     var1b = var1b - 273.15
   end if 
   if(varcode .eq. "T_2m" .and. tag_1b .ne. "era_i")then
     var1b = var1b -273.15
   end if
    var1@units = "C" 
end if
if (isvar("precip_convert").and.(precip_convert)) then
  var1 = var1*(60*60*3)
  if (tag_1b .eq. "era_i")then
    var1b = var1b*(60*60*3)* (60*60*3)  ; I accidentally divided by the #seconds twice for era_i. fix it here.   
  else
    var1b = var1b*(60*60*3)
  end if
  var1@units = "mm"
end if

;;;;;;;;;;
; Interpolate to WRF10 size (if needed)
;;;;;;;;;;
if (tag_1 .eq. "wrf10" .and. tag_1b .ne. "wrf10")then
  print("Interpolating between resolutions")
  ; Make arrays we'll need in interpolation
  var1b_new = new((/nnode,n_sn_1,n_we_1/),"float") 
  var1b_tmp_1d  = new((/n_tot_1/),"float")
  seaice_1b_new = new((/nnode,n_sn_1,n_we_1/),"float") 
  seaice_1b_tmp_1d  = new((/n_tot_1/),"float")

  do n = 0, nnode - 1
    var1b_1d = ndtooned(var1b(n,:,:))
    seaice_1b_1d = ndtooned(seaice_1b(n,:,:))
    do i = 0, n_tot_1 - 1
      indices_all = interp_ind(i,:)
      n_indices = num(.not.ismissing(indices_all))
      if (n_indices .ne. 0.0) then
        indices = indices_all(0:n_indices-1)
        weight_all = interp_wgt(i,:)
        weight = weight_all(0:n_indices-1)
        var1b_tmp_1d(i) = sum(var1b_1d(indices)*weight/sum(weight))
        seaice_1b_tmp_1d(i) = sum(seaice_1b_1d(indices)*weight/sum(weight))
        delete(indices)
        delete(weight)
      end if
    end do
    ; redimensionalize
    var1b_new(n,:,:) = onedtond(var1b_tmp_1d,(/n_sn_1,n_we_1/))
    seaice_1b_new(n,:,:) = onedtond(seaice_1b_tmp_1d,(/n_sn_1,n_we_1/))

   ; counter
    print("created node avg "+n+" of "+nnode)
  end do

  delete(var1b)
  var1b = var1b_new
  delete(var1b_new)
  copy_VarMeta(var1, var1b)
  copy_VarCoords(var1,var1b)
  var1b@_FillValue = fill
  delete(variance1b)
  delete(seaice_1b)
  seaice_1b = seaice_1b_new
  delete(seaice_1b_new)
  copy_VarMeta(seaice_1, seaice_1b)
  copy_VarCoords(seaice_1,seaice_1b)
  seaice_1b@_FillValue = fill
end if

print("Masking terrain - nodes")
n = 0
; loop through each node
;do n = 0, nnode - 1
;  ; mask terrain - focus on ocean
;  var1(n,:,:) = where(z_sfc_1 .lt. 10., var1(n,:,:), var1@_FillValue)
;  var1b(n,:,:) = where(z_sfc_1 .lt. 10., var1b(n,:,:), var1b@_FillValue)
;  seaice_1(n,:,:) = where(z_sfc_1 .lt. 10., seaice_1(n,:,:), seaice_1@_FillValue)
;  seaice_1b(n,:,:) = where(z_sfc_1 .lt. 10., seaice_1b(n,:,:), seaice_1b@_FillValue)

;  ; mask lat/lons - focus on S. Greenland region
;  var1(n,:,:) = where(lat2d_1 .gt. 55. .and. lat2d_1 .lt. 71. .and. lon2d_1 .lt. -19. .and. lon2d_1 .gt. -55., var1(n,:,:), var1@_FillValue)
;  var1b(n,:,:) = where(lat2d_1 .gt. 55. .and. lat2d_1 .lt. 71. .and. lon2d_1 .lt. -19. .and. lon2d_1 .gt. -55., var1b(n,:,:), var1b@_FillValue)
;  seaice_1(n,:,:) = where(lat2d_1 .gt. 55. .and. lat2d_1 .lt. 71. .and. lon2d_1 .lt. -19. .and. lon2d_1 .gt. -55., seaice_1(n,:,:), seaice_1@_FillValue)
;  seaice_1b(n,:,:) = where(lat2d_1 .gt. 55. .and. lat2d_1 .lt. 71. .and. lon2d_1 .lt. -19. .and. lon2d_1 .gt. -55., seaice_1b(n,:,:), seaice_1b@_FillValue)
;end do

;;;;;;;;;;
; Find difference
;;;;;;;;;;
  diff = var1 - var1b
  title_diff = "Diff: ("+datatitle1+" - "+datatitle1b+")"

; assign lat/lon info
var1@lat2d = lat2d_1
var1@lon2d = lon2d_1
var1b@lat2d = lat2d_1
var1b@lon2d = lon2d_1
diff@lat2d = lat2d_1
diff@lon2d = lon2d_1
seaice_1@lat2d = lat2d_1
seaice_1@lon2d = lon2d_1
seaice_1b@lat2d = lat2d_1
seaice_1b@lon2d = lon2d_1

; prints together the variable title (set above for each type of data) with title1 (defined in cshell as the wrf or met info) and the max and min values
  print(vartitle1+" min: "+min(diff)+"  max: "+max(diff)) 

;;;;;;;;;;
; Calculate statistical significance
;;;;;;;;;;
; Uses student's t-test. If the probability is less than 0.1 then we know at a 90% confidence level
; that the two means are statistically significant.
;prob = new((/nnode,n_sn_1,n_we_1/),"float")
;n = 0
;do n = 0, nnode - 1
;  prob(n,:,:) = 100.*(1. - ttest(var1(n,:,:),variance1(n,:,:),nodecount_1(n), var1b(n,:,:),variance1b(n,:,:),nodecount_1b(n), False, False))    
;end do

;prob@lat2d = lat2d_1
;prob@lon2d = lon2d_1

print("completed node calculations")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Calculate difference terms for analysis
; delta U = sigma (delta_freq*U + freq*delta_U + delta_freq*delta_U)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
var = var1b             ; era or wrf50 as control
freq = freq_nodes_1b/100.      ; era or wrf50 as control
delta_var = diff        ; var_1 - var_1b
delta_freq = (freq_nodes_1 - freq_nodes_1b)/100.     ; freq_1 - freq_1b

  ; Make arrays for each term for each node
  term1 = new((/nnode,n_sn_1,n_we_1/),"float")
  term1@_FillValue = fill
  term1_sum = new((/n_sn_1,n_we_1/),"float")
  term1_sum = 0.0
  term2 = new((/nnode,n_sn_1,n_we_1/),"float")
  term2@_FillValue = fill
  term2_sum = new((/n_sn_1,n_we_1/),"float")
  term2_sum = 0.0
  term3 = new((/nnode,n_sn_1,n_we_1/),"float")
  term3@_FillValue = fill
  term3_sum = new((/n_sn_1,n_we_1/),"float")
  term3_sum = 0.0
  winter_nodes_1 = new((/nnode,n_sn_1,n_we_1/),"float")
  winter_nodes_1b = new((/nnode,n_sn_1,n_we_1/),"float")
  winter_avg_1 = new((/n_sn_1,n_we_1/),"float")
  winter_avg_1 = 0.0
  winter_avg_1b = new((/n_sn_1,n_we_1/),"float")
  winter_avg_1b = 0.0
  seaice_nodes_1 = new((/nnode,n_sn_1,n_we_1/),"float")
  seaice_nodes_1b = new((/nnode,n_sn_1,n_we_1/),"float")
  seaice_avg_1 = new((/n_sn_1,n_we_1/),"float")
  seaice_avg_1 = 0.0
  seaice_avg_1b = new((/n_sn_1,n_we_1/),"float")
  seaice_avg_1b = 0.0

  ; Make arrays for each term for individual groups
  ;group1  = ("0" "1" "7")
  ;group2  = ("2" "8" "9" "16" "17")
  ;group3  = ("3" "4" "10" "11" "18" "19")
  ;group4  = ("5" "6" "12" "13" "20")
  ;group5  = ("14" "21" "28" "29")
  ;group6  = ("15" "22" "23" "30")
  ;group7  = ("24" "25" "31" "32")
  ;group8  = ("26" "27" "33" "34")

  term1_sum_group1 = new((/n_sn_1,n_we_1/),"float")
  term1_sum_group1 = 0.0
  term2_sum_group1 = new((/n_sn_1,n_we_1/),"float")
  term2_sum_group1 = 0.0
  term3_sum_group1 = new((/n_sn_1,n_we_1/),"float")
  term3_sum_group1 = 0.0
  term1_sum_group2 = new((/n_sn_1,n_we_1/),"float")
  term1_sum_group2 = 0.0
  term2_sum_group2 = new((/n_sn_1,n_we_1/),"float")
  term2_sum_group2 = 0.0
  term3_sum_group2 = new((/n_sn_1,n_we_1/),"float")
  term3_sum_group2 = 0.0
  term1_sum_group3 = new((/n_sn_1,n_we_1/),"float")
  term1_sum_group3 = 0.0
  term2_sum_group3 = new((/n_sn_1,n_we_1/),"float")
  term2_sum_group3 = 0.0
  term3_sum_group3 = new((/n_sn_1,n_we_1/),"float")
  term3_sum_group3 = 0.0
  term1_sum_group4 = new((/n_sn_1,n_we_1/),"float")
  term1_sum_group4 = 0.0
  term2_sum_group4 = new((/n_sn_1,n_we_1/),"float")
  term2_sum_group4 = 0.0
  term3_sum_group4 = new((/n_sn_1,n_we_1/),"float")
  term3_sum_group4 = 0.0
  term1_sum_group5 = new((/n_sn_1,n_we_1/),"float")
  term1_sum_group5 = 0.0
  term2_sum_group5 = new((/n_sn_1,n_we_1/),"float")
  term2_sum_group5 = 0.0
  term3_sum_group5 = new((/n_sn_1,n_we_1/),"float")
  term3_sum_group5 = 0.0
  term1_sum_group6 = new((/n_sn_1,n_we_1/),"float")
  term1_sum_group6 = 0.0
  term2_sum_group6 = new((/n_sn_1,n_we_1/),"float")
  term2_sum_group6 = 0.0
  term3_sum_group6 = new((/n_sn_1,n_we_1/),"float")
  term3_sum_group6 = 0.0
  term1_sum_group7 = new((/n_sn_1,n_we_1/),"float")
  term1_sum_group7 = 0.0
  term2_sum_group7 = new((/n_sn_1,n_we_1/),"float")
  term2_sum_group7 = 0.0
  term3_sum_group7 = new((/n_sn_1,n_we_1/),"float")
  term3_sum_group7 = 0.0
  term1_sum_group8 = new((/n_sn_1,n_we_1/),"float")
  term1_sum_group8 = 0.0
  term2_sum_group8 = new((/n_sn_1,n_we_1/),"float")
  term2_sum_group8 = 0.0
  term3_sum_group8 = new((/n_sn_1,n_we_1/),"float")
  term3_sum_group8 = 0.0

  do n = 0, nnode - 1
    ;Calculate each term for all nodes
    term1(n,:,:) = delta_freq(n)*var(n,:,:)
    term2(n,:,:) = freq(n)*delta_var(n,:,:)
    term3(n,:,:) = delta_freq(n)*delta_var(n,:,:)

    ; Do sums over various terms
    term1_sum(:,:) = term1_sum(:,:) + term1(n,:,:)
    term2_sum(:,:) = term2_sum(:,:) + term2(n,:,:)
    term3_sum(:,:) = term3_sum(:,:) + term3(n,:,:)

    ; Do sums over various terms for groups
    ;; group1 - northeastery flow
    if(n .eq. 0 .or. n .eq. 1 .or. n .eq. 7)then
      term1_sum_group1(:,:) = term1_sum_group1(:,:) + term1(n,:,:)
      term2_sum_group1(:,:) = term2_sum_group1(:,:) + term2(n,:,:)
      term3_sum_group1(:,:) = term3_sum_group1(:,:) + term3(n,:,:)
    end if
    ;; group2 - northeasterly flow in DSN
    if(n .eq. 2 .or. n .eq. 8 .or. n .eq. 9 .or. n .eq. 16 .or. n .eq. 17)then
      term1_sum_group2(:,:) = term1_sum_group2(:,:) + term1(n,:,:)
      term2_sum_group2(:,:) = term2_sum_group2(:,:) + term2(n,:,:)
      term3_sum_group2(:,:) = term3_sum_group2(:,:) + term3(n,:,:)
    end if
    ;; group3 - WTJ with barrier flow
    if(n .eq. 3 .or. n .eq. 4 .or. n .eq. 10 .or. n .eq. 11 .or. n .eq. 18 .or. n .eq. 19)then
      term1_sum_group3(:,:) = term1_sum_group3(:,:) + term1(n,:,:)
      term2_sum_group3(:,:) = term2_sum_group3(:,:) + term2(n,:,:)
      term3_sum_group3(:,:) = term3_sum_group3(:,:) + term3(n,:,:)
    end if
    ;; group4 - Strong WTJ with barrier flow
    if(n .eq. 5 .or. n .eq. 6 .or. n .eq. 12 .or. n .eq. 13 .or. n .eq. 20)then
      term1_sum_group4(:,:) = term1_sum_group4(:,:) + term1(n,:,:)
      term2_sum_group4(:,:) = term2_sum_group4(:,:) + term2(n,:,:)
      term3_sum_group4(:,:) = term3_sum_group4(:,:) + term3(n,:,:)
    end if
    ;; group5 - Strong ETJ
    if(n .eq. 14 .or. n .eq. 21 .or. n .eq. 28 .or. n .eq. 29)then
      term1_sum_group5(:,:) = term1_sum_group5(:,:) + term1(n,:,:)
      term2_sum_group5(:,:) = term2_sum_group5(:,:) + term2(n,:,:)
      term3_sum_group5(:,:) = term3_sum_group5(:,:) + term3(n,:,:)
    end if
    ;; group6 - ETJ
    if(n .eq. 15 .or. n .eq. 22 .or. n .eq. 23 .or. n .eq. 30)then
      term1_sum_group6(:,:) = term1_sum_group6(:,:) + term1(n,:,:)
      term2_sum_group6(:,:) = term2_sum_group6(:,:) + term2(n,:,:)
      term3_sum_group6(:,:) = term3_sum_group6(:,:) + term3(n,:,:)
    end if
    ;; group7 - southerly flow
    if(n .eq. 24 .or. n .eq. 25 .or. n .eq. 31 .or. n .eq. 32)then
      term1_sum_group7(:,:) = term1_sum_group7(:,:) + term1(n,:,:)
      term2_sum_group7(:,:) = term2_sum_group7(:,:) + term2(n,:,:)
      term3_sum_group7(:,:) = term3_sum_group7(:,:) + term3(n,:,:)
    end if
    ;; group8 - WTJ without barrier flow
    if(n .eq. 26 .or. n .eq. 27 .or. n .eq. 33 .or. n .eq. 34)then
      term1_sum_group8(:,:) = term1_sum_group8(:,:) + term1(n,:,:)
      term2_sum_group8(:,:) = term2_sum_group8(:,:) + term2(n,:,:)
      term3_sum_group8(:,:) = term3_sum_group8(:,:) + term3(n,:,:)
    end if

    ; Find winter net average
    winter_nodes_1(n,:,:)  = (freq_nodes_1(n)/100.) * var1(n,:,:)
    winter_nodes_1b(n,:,:) = (freq_nodes_1b(n)/100.) * var1b(n,:,:)    
    winter_avg_1 = winter_avg_1(:,:) + winter_nodes_1(n,:,:)
    winter_avg_1b = winter_avg_1b(:,:) + winter_nodes_1b(n,:,:)

    ; Find seaice winter net average
    seaice_nodes_1(n,:,:)  = (freq_nodes_1(n)/100.) * seaice_1(n,:,:)
    seaice_nodes_1b(n,:,:) = (freq_nodes_1b(n)/100.) * seaice_1b(n,:,:)    
    seaice_avg_1 = seaice_avg_1(:,:) + seaice_nodes_1(n,:,:)
    seaice_avg_1b = seaice_avg_1b(:,:) + seaice_nodes_1b(n,:,:)
  end do

  ; Find Winter net difference
  winter_diff = winter_avg_1 - winter_avg_1b
  winter_seaice_diff = seaice_avg_1 - seaice_avg_1b
  ; Do sums over various terms for why the difference exists
  nodes_sum_all = term1 + term2 + term3
  net_diff = term1_sum + term2_sum + term3_sum 

  ; Find the "net" difference for each group
  net_group1 = term1_sum_group1 + term2_sum_group1 + term3_sum_group1
  net_group2 = term1_sum_group2 + term2_sum_group2 + term3_sum_group2
  net_group3 = term1_sum_group3 + term2_sum_group3 + term3_sum_group3
  net_group4 = term1_sum_group4 + term2_sum_group4 + term3_sum_group4   
  net_group5 = term1_sum_group5 + term2_sum_group5 + term3_sum_group5
  net_group6 = term1_sum_group6 + term2_sum_group6 + term3_sum_group6
  net_group7 = term1_sum_group7 + term2_sum_group7 + term3_sum_group7
  net_group8 = term1_sum_group8 + term2_sum_group8 + term3_sum_group8

  ; assign lat/lon data for plotting
  var1@_FillValue = fill
  copy_VarMeta(var1,nodes_sum_all)
  copy_VarMeta(var1,term1)
  copy_VarMeta(var1,term2)
  copy_VarMeta(var1,term3)

  z_sfc_1@_FillValue = fill
  copy_VarMeta(z_sfc_1,net_diff)
  net_diff@lat2d = lat2d_1
  net_diff@lon2d = lon2d_1
  copy_VarMeta(net_diff,term1_sum)
  copy_VarMeta(net_diff,term2_sum)
  copy_VarMeta(net_diff,term3_sum)
  copy_VarMeta(net_diff,term1_sum_group1)
  copy_VarMeta(net_diff,term2_sum_group1)
  copy_VarMeta(net_diff,term3_sum_group1)
  copy_VarMeta(net_diff,net_group1)
  copy_VarMeta(net_diff,term1_sum_group2)
  copy_VarMeta(net_diff,term2_sum_group2)
  copy_VarMeta(net_diff,term3_sum_group2)
  copy_VarMeta(net_diff,net_group2)
  copy_VarMeta(net_diff,term1_sum_group3)
  copy_VarMeta(net_diff,term2_sum_group3)
  copy_VarMeta(net_diff,term3_sum_group3)
  copy_VarMeta(net_diff,net_group3)
  copy_VarMeta(net_diff,term1_sum_group4)
  copy_VarMeta(net_diff,term2_sum_group4)
  copy_VarMeta(net_diff,term3_sum_group4)
  copy_VarMeta(net_diff,net_group4)
  copy_VarMeta(net_diff,term1_sum_group5)
  copy_VarMeta(net_diff,term2_sum_group5)
  copy_VarMeta(net_diff,term3_sum_group5)
  copy_VarMeta(net_diff,net_group5)
  copy_VarMeta(net_diff,term1_sum_group6)
  copy_VarMeta(net_diff,term2_sum_group6)
  copy_VarMeta(net_diff,term3_sum_group6)
  copy_VarMeta(net_diff,net_group6)
  copy_VarMeta(net_diff,term1_sum_group7)
  copy_VarMeta(net_diff,term2_sum_group7)
  copy_VarMeta(net_diff,term3_sum_group7)
  copy_VarMeta(net_diff,net_group7)
  copy_VarMeta(net_diff,term1_sum_group8)
  copy_VarMeta(net_diff,term2_sum_group8)
  copy_VarMeta(net_diff,term3_sum_group8)
  copy_VarMeta(net_diff,net_group8)
  copy_VarMeta(net_diff,winter_avg_1)
  copy_VarMeta(net_diff,winter_avg_1b)
  copy_VarMeta(net_diff,winter_diff)
  copy_VarMeta(net_diff,winter_seaice_diff)
  copy_VarMeta(net_diff,seaice_avg_1)
  copy_VarMeta(net_diff,seaice_avg_1b)

  print("Completed calculations for assessing why differences exist")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Use net average files to calculate difference
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Load in lat/lon to get information for WRF10 domain
  f1 = addfile("/data3/duvivier/SOM/training/averages/all/net_avg_"+datatitle1+".nc","r")
  obs_1 = f1->number_dates

; Load in lat/lon to get information for WRF10 domain
  f1b = addfile("/data3/duvivier/SOM/training/averages/all/net_avg_"+datatitle1b+".nc","r")

  ; create all-node array for node average variable
  avg1 = new((/n_sn_1,n_we_1/),"float")
  avg1b = new((/n_sn_1b,n_we_1b/),"float")
  fill = var1@_FillValue

; create variables for other combinations
  avg2 = new((/n_sn_1,n_we_1/),"float") 
  avg2b = new((/n_sn_1b,n_we_1b/),"float")
   ; make sea ice var - overlay with everything
  avg_seaice_1 = new((/n_sn_1,n_we_1/),"float")
  avg_seaice_1b = new((/n_sn_1b,n_we_1b/),"float")

;;;;;;;;;;
; Load in actual data for analysis
;;;;;;;;;;
  avg1(:,:) = f1->$invar1$(south_north|:,west_east|:)
  avg1b(:,:) = f1b->$invar1$(south_north|:,west_east|:)
  avg2(:,:)  = f1->$invar2$(south_north|:,west_east|:)
  avg2b(:,:) = f1b->$invar2$(south_north|:,west_east|:)
  
  avg_seaice_1(:,:) = f1->SeaIce_avg(south_north|:,west_east|:)
  avg_seaice_1b(:,:) = f1b->SeaIce_avg(south_north|:,west_east|:)

  ; delete vars to use in next loop
  delete(f1)
  delete(f1b)

print("Loaded variables from both files")

;;;;;;;;;;
; manipulate arrays as needed - post interpolation
;;;;;;;;;;

pot_temp = avg1*((1000.0/avg2)^0.286)
copy_VarMeta(avg1, pot_temp)
pot_temp_b = avg1b*((1000.0/avg2b)^0.286)
copy_VarMeta(avg1b, pot_temp_b)
delete(avg1)
delete(avg1b)
avg1 = pot_temp
avg1@long_name = "Potential Temperature at surface"
avg1@standard_name = "Surface potential temp"
avg1b = pot_temp_b
avg1b@long_name = "Potential Temperature at surface"
avg1b@standard_name = "Surface potential temp"
delete(pot_temp)
delete(pot_temp_b)

; Convert both to C
avg1 = avg1 - 273.15
avg1@units = "C"
avg1b = avg1b - 273.15
avg1b@units = "C"

;;;;;;;;;;
; Interpolate to WRF10 size (if needed)
;;;;;;;;;;
if (tag_1 .eq. "wrf10" .and. tag_1b .ne. "wrf10")then
  print("Interpolating between resolutions")
  ; Make arrays we'll need in interpolation
  avg1b_new = new((/n_sn_1,n_we_1/),"float") 
  avg1b_tmp_1d  = new((/n_tot_1/),"float")
  avg_seaice_1b_new = new((/n_sn_1,n_we_1/),"float") 
  avg_seaice_1b_tmp_1d  = new((/n_tot_1/),"float")

    avg1b_1d = ndtooned(avg1b(:,:))
    avg_seaice_1b_1d = ndtooned(avg_seaice_1b(:,:))

    do i = 0, n_tot_1 - 1
      indices_all = interp_ind(i,:)
      n_indices = num(.not.ismissing(indices_all))
      if (n_indices .ne. 0.0) then
        indices = indices_all(0:n_indices-1)
        weight_all = interp_wgt(i,:)
        weight = weight_all(0:n_indices-1)
        avg1b_tmp_1d(i) = sum(avg1b_1d(indices)*weight/sum(weight))
        avg_seaice_1b_tmp_1d(i) = sum(avg_seaice_1b_1d(indices)*weight/sum(weight))
        delete(indices)
        delete(weight)
      end if
    end do
    ; redimensionalize
    avg1b_new(:,:) = onedtond(avg1b_tmp_1d,(/n_sn_1,n_we_1/))
    avg_seaice_1b_new(:,:) = onedtond(avg_seaice_1b_tmp_1d,(/n_sn_1,n_we_1/))

  delete(avg1b)
  delete(avg_seaice_1b)
  avg1b = avg1b_new
  avg_seaice_1b = avg_seaice_1b_new
  delete(avg1b_new)
  delete(avg_seaice_1b_new)
  copy_VarMeta(avg1, avg1b)
  copy_VarCoords(avg1,avg1b)
  copy_VarMeta(avg_seaice_1, avg_seaice_1b)
  copy_VarCoords(avg_seaice_1,avg_seaice_1b)
  avg1b@_FillValue = fill
  avg_seaice_1b@_FillValue = fill
end if

print("Masking terrain - net")
;  ; mask terrain - focus on ocean
;  avg1(:,:) = where(z_sfc_1 .lt. 10., avg1(:,:), avg1@_FillValue)
;  avg1b(:,:) = where(z_sfc_1 .lt. 10., avg1b(:,:), avg1b@_FillValue)
;  avg_seaice_1(:,:) = where(z_sfc_1 .lt. 10., avg_seaice_1(:,:), avg_seaice_1@_FillValue)
;  avg_seaice_1b(:,:) = where(z_sfc_1 .lt. 10., avg_seaice_1b(:,:), avg_seaice_1b@_FillValue)

;  ; mask lat/lons - focus on S. Greenland region
;  avg1(:,:) = where(lat2d_1 .gt. 55. .and. lat2d_1 .lt. 71. .and. lon2d_1 .lt. -19. .and. lon2d_1 .gt. -55., avg1(:,:), avg1@_FillValue)
;  avg1b(:,:) = where(lat2d_1 .gt. 55. .and. lat2d_1 .lt. 71. .and. lon2d_1 .lt. -19. .and. lon2d_1 .gt. -55., avg1b(:,:), avg1b@_FillValue)
;  avg_seaice_1(:,:) = where(lat2d_1 .gt. 55. .and. lat2d_1 .lt. 71. .and. lon2d_1 .lt. -19. .and. lon2d_1 .gt. -55., avg_seaice_1(:,:), avg_seaice_1@_FillValue)
;  avg_seaice_1b(:,:) = where(lat2d_1 .gt. 55. .and. lat2d_1 .lt. 71. .and. lon2d_1 .lt. -19. .and. lon2d_1 .gt. -55., avg_seaice_1b(:,:), avg_seaice_1b@_FillValue)

;;;;;;;;;;
; Find difference
;;;;;;;;;;
; for precip and mixing ratio fields, make %diff field instead
avg_diff = avg1 - avg1b
title_diff = "Diff: ("+datatitle1+" - "+datatitle1b+")"

; assign lat/lon info
avg1@lat2d = lat2d_1
avg1@lon2d = lon2d_1
avg1b@lat2d = lat2d_1
avg1b@lon2d = lon2d_1
avg_diff@lat2d = lat2d_1
avg_diff@lon2d = lon2d_1
avg_seaice_1@lat2d = lat2d_1
avg_seaice_1@lon2d = lon2d_1
avg_seaice_1b@lat2d = lat2d_1
avg_seaice_1b@lon2d = lon2d_1

; prints together the variable title (set above for each type of data) with title1 (defined in cshell as the wrf or met info) and the max and min values
  print(vartitle1+" min: "+min(avg_diff)+"  max: "+max(avg_diff)) 

;;;;;;;;;;
; Calculate statistical significance
;;;;;;;;;;
; Uses student's t-test. If the probability is less than 0.1 then we know at a 90% confidence level
; that the two means are statistically significant.

;avg_prob = 100.*(1. - ttest(avg1,avg_variance1,obs_1, avg1b,avg_variance1b,obs_1, False, False))
;avg_prob@lat2d = lat2d_1
;avg_prob@lon2d = lon2d_1

; make mask of points that are statistically significant at 95% level
;mask_95_prob = where(avg_prob .gt. 95. , 1, fill)

print("completed calculations with net avg files")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Processing all graphs for "+varcode)
; create plots!
; plot 1 - Frequency and frequency differences of all nodes (only needed once)
; plot 2 - 3 panel of winter average values and difference and % contribution terms
; plot 3  = 8 panel of groups' net % contribution
; plot 4  = 8 panel of groups' % contribution to net frequency
; plot 5  = 8 panel of groups' % contribution to net intrapattern
; plot 6  = 8 panel of groups' % contribution to net combined
; plot 7  = 24 panel of groups' % contribution to net, frequency, and intrapattern.
; plot 8  - % contribution of nodes to net difference - sum of terms - simple box plot
; plot 9  - % contribution of nodes to frequency net difference
; plot 10 - % contribution of nodes to intrapattern net difference
; plot 11 - % contribution of nodes to combined net difference
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; set outdir and fout names
outdir = "./"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 1 - Frequency differences
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot1").and.(plot1))then  ; if plotting is turned on
  print("Plot 1 - frequency differences")
  fout1 = "frequency_"+datatitle1+"-"+datatitle1b
  title_1 = tag_1b
  title_2 = tag_1+"-"+tag_1b
  title = nx_input+"x"+ny_input+" pattern frequency: 2005-2007 "+tag_1+" and "+tag_1b

  wks1 = gsn_open_wks("ps",fout1)
  gsn_define_colormap(wks1,"gsdtol")
  gsn_reverse_colormap(wks1)
  colors = gsn_retrieve_colormap(wks1) ; load fixed map into "colors"
  additional_colors = (/"forestgreen", "blue", "red", "lightblue", "pink"/)
  gsn_merge_colormaps(wks1,colors,additional_colors)

; Reverse rows(for plotting purposes) and get max frequencies
  nodefreq_1     = nodefreq_1(:,::-1)
  nodefreq_1b     = nodefreq_1b(:,::-1)
  ; reverse the statistical information as well
  test_stat = test_stat(:,::-1)
  freq_diff = freq_diff(:,::-1)

; Begin plotting:    
  plot = new(1, graphic)
  dum1  = new((/nnode/),graphic)
  dum2  = new((/nnode/),graphic)
  dum3  = new((/nnode/),graphic)
  dum4  = new((/nnode/),graphic)

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

  plot = gsn_blank_plot(wks1,res_blank)

; Add in squares:
  xx = (/0., 0., 1., 1., 0./)
  yy = (/0., 1., 1., 0., 0./)

; Polygon resources for color shading:
  res_poly = True
; Text resources for count and freq:
  res_txt = True
  res_txt@txFontHeightF = 0.0125 ;0.0085
  res_txt@txFont = 22
  res_txt@txFontColor = "white" ;"black"
; loop through each node to plot
n = 0
do y = 0, ny_node - 1
  do x = 0, nx_node - 1 
    xp = xx + x
    yp = yy + y  
    ; Get grey scales(same used for all data sets)
    maxnodefreq = max(nodefreq_1b)
    minnodefreq = 0.
    if (maxnodefreq.ne.0) then
      slope = (32. - 2.) / (maxnodefreq - minnodefreq)  ; use 32 because there are 32 colors
    else
      slope = 0
    end if
    ; variable 1
    gray_index = slope * nodefreq_1b(x,y) + 2.
    if(gray_index.eq.2.) then
      gray_index = 0. ; to get actual white because our color table is flaky
    end if 
    ; Color squares
    res_poly@gsFillColor = "white" ;gray_index ; should auto round
    dum1(n) = gsn_add_polygon(wks1, plot, xp, yp, res_poly)
    dum2(n) = gsn_add_polyline(wks1, plot, xp, yp, res_poly)
    ; Frequency text:
    res_txt1 = res_txt
    res_txt1@txBackgroundFillColor = gray_index ;"white" "black"
    text_1 = title_1+":~C~ "+sprintf("%5.2f",nodefreq_1b(x,y))+"%"
    dum3(n) = gsn_add_text(wks1, plot, text_1, xp(0)+.5, yp(0)+.75, res_txt1)
    delete(text_1)

    res_txt2 = res_txt
    res_txt2@txFontColor = "black"
    res_txt2@txBackgroundFillColor = "white"
    if(test_stat(x,y).ge.1.645).and.(test_stat(x,y).lt.1.96) then
      res_txt2@txBackgroundFillColor = "pink"
      res_txt2@txFontColor = "white"
    end if
    if(test_stat(x,y).ge.1.96) then
      res_txt2@txBackgroundFillColor = "red"
      res_txt2@txFontColor = "white"
    end if
    if(test_stat(x,y).le.-1.645).and.(test_stat(x,y).gt.-1.96) then
      res_txt2@txBackgroundFillColor = "lightblue"
      res_txt2@txFontColor = "white"
    end if
    if(test_stat(x,y).le.-1.96) then
      res_txt2@txBackgroundFillColor = "blue"
      res_txt2@txFontColor = "white"
    end if
    text_2 = title_2+":~C~ "+sprintf("%5.2f",freq_diff(x,y))+"%"
    dum4(n) = gsn_add_text(wks1, plot, text_2, xp(0)+.5, yp(0)+.25, res_txt2)   
    delete(text_2)
    n = n+1
  end do 
end do
  
; Finally - make plot
  draw(plot)
  frame(wks1)
  print("converting plot 1 to png")
  convert_cmd = "convert -density 300 "+fout1+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout1+".png"
  system(convert_cmd)

delete(res_blank)
delete(res_poly)
delete(res_txt)
delete(title_1)
delete(title_2)
delete(title)
delete(additional_colors)
delete(plot)

end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 2 - Winter averages and difference
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot2").and.(plot2))then  ; if plotting is turned on
print("Plot 2 - winter averages and difference")
fout2   = varcode+"_"+datatitle1+"_"+datatitle1b+"_winter_diff_and_terms"

  wks2 = gsn_open_wks("ps" ,fout2)
  additional_colors = (/"gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks2,colormap,additional_colors)
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
;;;;;;;;;;;;;
; Set resources for "normal" plots
;;;;;;;;;;;;
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
  opts@tiMainFontHeightF          = 0.015
  opts@lbLabelStride              = stride1
  opts@pmLabelBarOrthogonalPosF   = -0.01             ; move label bar closer
  opts@pmLabelBarHeightF          = 0.075             ; set height of labelbar

;;;;;;;;;;;;;
; Set resources for difference and term plots
;;;;;;;;;;;;
  optsd                            = res
  optsd@cnFillMode                 = cntype
  optsd@cnFillOn                   = True
  optsd@gsnSpreadColors            = True              ; use full colormap
  optsd@gsnSpreadColorStart        = spreadstart2      ; start at color specified above
  optsd@gsnSpreadColorEnd          = spreadend2        ; end at color specified above
  optsd@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  optsd@cnMinLevelValF             = cmin2             ; set min contour level specified above
  optsd@cnMaxLevelValF             = cmax2             ; set max contour level specified above
  optsd@cnLevelSpacingF            = clev2             ; set contour spacing specified above
  optsd@cnLinesOn                  = difflines         ; contour lines specified above
  optsd@cnLineLabelsOn             = difflines
  optsd@cnMissingValFillColor      = "gray85"          ; missing value color
  optsd@cnMissingValFillPattern    = 0                 ; fill in
  optsd@cnMissingValPerimOn        = True
  optsd@cnMissingValPerimColor     = "black"
  optsd@tiMainFontHeightF          = 0.015
  optsd@lbLabelBarOn               = True
  optsd@lbLabelStride              = stride2
  optsd@pmLabelBarOrthogonalPosF   = -0.01             ; move label bar closer
  optsd@pmLabelBarHeightF          = 0.075

;;;;;;;;;;;;;
; Set resources for seaice overlay
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
  res_ice@cnLineColor                = "black" ;"gray85"
  res_ice@cnLineThicknessF           = 2.0
  res_ice@tiXAxisOn                  = False
  res_ice@tiYAxisOn                  = False

; set resources for sea ice overlay
  res_ice2                            = res_ice               ; reset options
  res_ice2@cnMinLevelValF             = 0.                ; set min contour level specified above
  res_ice2@cnMaxLevelValF             = 0.85              ; set max contour level specified above
  res_ice2@cnLevelSpacingF            = 0.85              ; set contour spacing specified above
  res_ice2@cnLineColor                = "black" ;"gray85"
  res_ice2@cnLineThicknessF           = 2.0
  res_ice2@cnLineDashPattern          = 6

;;;;;;;;;;;;;
; Set resources for 95% significance overlay
;;;;;;;;;;;;
; set resources for 95% statistical significance overlay
  res_95                            = True               ; reset options
  res_95@gsnLeftString              = ""
  res_95@gsnRightString             = ""
  res_95@gsnFrame                   = False             ; Do not draw plot 
  res_95@gsnDraw                    = False             ; Do not advance fr
  res_95@cnInfoLabelOn              = False             ; Turn off info on contours at bottom
  res_95@lbLabelBarOn               = False             ; Turn off label bar
  res_95@cnFillOn                   = True              ; turn on filled contours
  res_95@cnMonoFillColor            = True
  res_95@cnMonoFillPattern          = False
  res_95@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  res_95@cnMinLevelValF             = 0.0              ; set min contour level specified above
  res_95@cnMaxLevelValF             = 95.              ; set max contour level specified above
  res_95@cnLevelSpacingF            = 95.0              ; set contour spacing specified above
;  res_95@cnFillPatterns             = (/17, -1, 17/)    ; stipling where not significant
  res_95@cnFillPatterns             = (/-1,-1,17/)      ; stipling where significant and above threshold

;;;;;;;;;;;;;
; Make plot 0  - average field var1
;;;;;;;;;;;;;
  opts@tiMainString               = plot_title1
  cplot0  = gsn_csm_contour_map(wks2,avg1,opts)
  cplot0b = gsn_csm_contour(wks2,seaice_avg_1,res_ice)
  overlay(cplot0,cplot0b)
  plot(0) = cplot0

;;;;;;;;;;;;;
; Make plot 1  - average field var1b
;;;;;;;;;;;;;    
  opts@tiMainString               = plot_title1b
  cplot1  = gsn_csm_contour_map(wks2,avg1b,opts)
  cplot1b = gsn_csm_contour(wks2,seaice_avg_1b,res_ice)
  overlay(cplot1,cplot1b)
  plot(1) = cplot1

;;;;;;;;;;;;;
; Make plot 2  - difference plot
;;;;;;;;;;;;;
  optsd@tiMainString               = "Difference: "+tag_1+" - "+tag_1b        ; set title for difference plot
  cplot2  = gsn_csm_contour_map(wks2,avg_diff,optsd)
  cplot2c = gsn_csm_contour(wks2,seaice_avg_1,res_ice)
  overlay(cplot2,cplot2c) 
  plot(2) = cplot2

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
title_fin = vartitle1 + " ("+var1@units+")"

  res_pan                            = True
  res_pan@txString                   = title_fin        ; main title
  res_pan@txFontHeightF              = 0.015
  res_pan@gsnPaperOrientation        = "landscape"      ; landscape mode
  res_pan@gsnPanelYWhiteSpacePercent = 2                ; Add white space b/w plots.
  res_pan@gsnPanelXWhiteSpacePercent = 2                ; Add white space b/w plots.
  res_pan@gsnPanelScalePlotIndex     = 1
  res_pan@gsnMaximize                = True	       ; fill the page
  gsn_panel(wks2,(/plot/),(/1,3/),res_pan)               ; create final panel plot


; Finally - make plot
  print("converting plot 2 to png")
  convert_cmd = "convert -density 300 "+fout2+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout2+".png"
  system(convert_cmd)
  delete(res)
  delete(res_ice)
  delete(res_pan)
  delete(title_fin)
  delete(additional_colors)
  delete(plot)
end if

return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 3 - Net difference and difference terms - group1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot3").and.(plot3))then  ; if plotting is turned on
print("Plot 3 - Groups and net difference")
fout3   = varcode+"_groups_net_difference-"+datatitle1+"_"+datatitle1b

  wks3 = gsn_open_wks("ps" ,fout3)
  additional_colors = (/"black","gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks3,colormap,additional_colors)
  plot = new(8, graphic)

;;;;;;;;;;;;;
; Set resources for variable plots
;;;;;;;;;;;;

  res                             = True              ; plot mods desired
  ;res@gsnRightString              = ""
  ;res@gsnLeftString               = ""               ; Set this in loop
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
  res@gsnSpreadColorStart        = spreadstart3      ; start at color specified for each variable above
  res@gsnSpreadColorEnd          = spreadend3        ; end at color specified above
  res@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  res@cnMinLevelValF             = cmin3             ; set min contour level specified above
  res@cnMaxLevelValF             = cmax3             ; set max contour level specified above
  res@cnLevelSpacingF            = clev3             ; set contour spacing specified above
  res@lbLabelStride              = stride3
  res@cnLinesOn                  = plotlines         ; contour lines specified above
  res@cnLineLabelsOn             = plotlines         ; line labels on specified above
  res@cnMissingValFillColor      = "gray85"          ; missing value color
  res@cnMissingValFillPattern    = 0                 ; fill in
  res@cnMissingValPerimOn        = True
  res@cnMissingValPerimColor     = "black"
  res@lbLabelBarOn               = False             ; single label bar for whole plot

;;;;;;;;;;;;;
; Make plot 0 - Group 1 contributions
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group1"
  opts@gsnRightString             = sprintf("%5.2f",group1_pcnt)+"%"
  cplot0  = gsn_csm_contour_map(wks3,net_group1,opts)
  plot(0) = cplot0
  delete(opts)

;;;;;;;;;;;;;
; Make plot1 - Group 2 contributions
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group2"
  opts@gsnRightString             = sprintf("%5.2f",group2_pcnt)+"%"
  cplot1  = gsn_csm_contour_map(wks3,net_group2,opts)
  plot(1) = cplot1
  delete(opts)

;;;;;;;;;;;;;
; Make plot 2 - Group 3 contributions
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group3"
  opts@gsnRightString             = sprintf("%5.2f",group3_pcnt)+"%"
  cplot0  = gsn_csm_contour_map(wks3,net_group3,opts)
  plot(2) = cplot0
  delete(opts)

;;;;;;;;;;;;;
; Make plot3 - Group 4 contributions
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group4"
  opts@gsnRightString             = sprintf("%5.2f",group4_pcnt)+"%"
  cplot1  = gsn_csm_contour_map(wks3,net_group4,opts)
  plot(3) = cplot1
  delete(opts)

;;;;;;;;;;;;;
; Make plot 4 - Group 5 contributions
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group5"
  opts@gsnRightString             = sprintf("%5.2f",group5_pcnt)+"%"
  cplot0  = gsn_csm_contour_map(wks3,net_group5,opts)
  plot(4) = cplot0
  delete(opts)

;;;;;;;;;;;;;
; Make plot5 - Group 6 contributions
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group6"
  opts@gsnRightString             = sprintf("%5.2f",group6_pcnt)+"%"
  cplot1  = gsn_csm_contour_map(wks3,net_group6,opts)
  plot(5) = cplot1
  delete(opts)

;;;;;;;;;;;;;
; Make plot 6 - Group 7 contributions
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group7"
  opts@gsnRightString             = sprintf("%5.2f",group7_pcnt)+"%"
  cplot0  = gsn_csm_contour_map(wks3,net_group7,opts)
  plot(6) = cplot0
  delete(opts)

;;;;;;;;;;;;;
; Make plot7 - Group 8 contributions
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group8"
  opts@gsnRightString             = sprintf("%5.2f",group8_pcnt)+"%"
  cplot1  = gsn_csm_contour_map(wks3,net_group8,opts)
  plot(7) = cplot1
  delete(opts)

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
title_fin = vartitle1 + " group contributions to net difference: "+tag_1+" and "+tag_1b

  res_pan                            = True
  res_pan@txString                   = title_fin        ; main title
  res_pan@txFontHeightF              = 0.0175
  res_pan@gsnPaperOrientation        = "landscape"      ; landscape mode
  res_pan@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  res_pan@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  res_pan@gsnPanelScalePlotIndex     = 1
  res_pan@gsnMaximize                = True	       ; fill the page
  res_pan@gsnPanelLabelBar           = True
  res_pan@lbTitleString              = var1@units
  res_pan@lbTitlePosition            = "right"
  res_pan@lbLabelStride              = stride1
  res_pan@lbLabelFontHeightF         = 0.01
  res_pan@lbTitleJust                = "CenterLeft"
  res_pan@lbTitleFontHeightF         = 0.01
  res_pan@lbTitleDirection           = "Across"
  gsn_panel(wks3,(/plot/),(/2,4/),res_pan)               ; create final panel plot

  print("converting plot 3 to png")
; convert to png 
  convert_cmd = "convert -density 300 "+fout3+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout3+".png"

  system(convert_cmd)

delete(res_pan)
delete(plot)
delete(additional_colors)
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 4 - Net difference and difference terms - group2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot4").and.(plot4))then  ; if plotting is turned on
print("Plot 4 - Groups and frequency terms")
fout4   = varcode+"_groups_frequency-"+datatitle1+"_"+datatitle1b

  wks4 = gsn_open_wks("ps" ,fout4)
  additional_colors = (/"black","gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks4,colormap,additional_colors)
  plot = new(8, graphic)

; keep previous resources except levels
  res@cnMinLevelValF             = cmin4             ; set min contour level specified above
  res@cnMaxLevelValF             = cmax4             ; set max contour level specified above
  res@cnLevelSpacingF            = clev4             ; set contour spacing specified above
  res@lbLabelStride              = stride4

;;;;;;;;;;;;;
; Make plot 0 - Group 1 contributions
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group1"
  opts@gsnRightString             = sprintf("%5.2f",term1_group1_pcnt)+"%"
  cplot0  = gsn_csm_contour_map(wks4,term1_sum_group1,opts)
  plot(0) = cplot0
  delete(opts)

;;;;;;;;;;;;;
; Make plot1 - Group 2 contributions
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group2"
  opts@gsnRightString             = sprintf("%5.2f",term1_group2_pcnt)+"%"
  cplot1  = gsn_csm_contour_map(wks4,term1_sum_group2,opts)
  plot(1) = cplot1
  delete(opts)

;;;;;;;;;;;;;
; Make plot 2 - Group 3 contributions
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group3"
  opts@gsnRightString             = sprintf("%5.2f",term1_group3_pcnt)+"%"
  cplot0  = gsn_csm_contour_map(wks4,term1_sum_group3,opts)
  plot(2) = cplot0
  delete(opts)

;;;;;;;;;;;;;
; Make plot3 - Group 4 contributions
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group4"
  opts@gsnRightString             = sprintf("%5.2f",term1_group4_pcnt)+"%"
  cplot1  = gsn_csm_contour_map(wks4,term1_sum_group4,opts)
  plot(3) = cplot1
  delete(opts)

;;;;;;;;;;;;;
; Make plot 4 - Group 5 contributions
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group5"
  opts@gsnRightString             = sprintf("%5.2f",term1_group5_pcnt)+"%"
  cplot0  = gsn_csm_contour_map(wks4,term1_sum_group5,opts)
  plot(4) = cplot0
  delete(opts)

;;;;;;;;;;;;;
; Make plot5 - Group 6 contributions
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group6"
  opts@gsnRightString             = sprintf("%5.2f",term1_group6_pcnt)+"%"
  cplot1  = gsn_csm_contour_map(wks4,term1_sum_group6,opts)
  plot(5) = cplot1
  delete(opts)

;;;;;;;;;;;;;
; Make plot 6 - Group 7 contributions
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group7"
  opts@gsnRightString             = sprintf("%5.2f",term1_group7_pcnt)+"%"
  cplot0  = gsn_csm_contour_map(wks4,term1_sum_group7,opts)
  plot(6) = cplot0
  delete(opts)

;;;;;;;;;;;;;
; Make plot7 - Group 8 contributions
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group8"
  opts@gsnRightString             = sprintf("%5.2f",term1_group8_pcnt)+"%"
  cplot1  = gsn_csm_contour_map(wks4,term1_sum_group8,opts)
  plot(7) = cplot1
  delete(opts)

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
title_fin = vartitle1 + " group contributions to net frequency term: "+tag_1+" and "+tag_1b

  res_pan                            = True
  res_pan@txString                   = title_fin        ; main title
  res_pan@txFontHeightF              = 0.0175
  res_pan@gsnPaperOrientation        = "landscape"      ; landscape mode
  res_pan@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  res_pan@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  res_pan@gsnPanelScalePlotIndex     = 1
  res_pan@gsnMaximize                = True	       ; fill the page
  res_pan@gsnPanelLabelBar           = True
  res_pan@lbTitleString              = var1@units
  res_pan@lbTitlePosition            = "right"
  res_pan@lbLabelStride              = stride1
  res_pan@lbLabelFontHeightF         = 0.01
  res_pan@lbTitleJust                = "CenterLeft"
  res_pan@lbTitleFontHeightF         = 0.01
  res_pan@lbTitleDirection           = "Across"
  gsn_panel(wks4,(/plot/),(/2,4/),res_pan)               ; create final panel plot

  print("converting plot 4 to png")
; convert to png 
  convert_cmd = "convert -density 300 "+fout4+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout4+".png"

  system(convert_cmd)

delete(res_pan)
delete(plot)
delete(additional_colors)
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 5 - Net difference and difference terms - group2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot5").and.(plot5))then  ; if plotting is turned on
print("Plot 5 - Groups and intrapattern terms")
fout5   = varcode+"_groups_intrapattern-"+datatitle1+"_"+datatitle1b

  wks5 = gsn_open_wks("ps" ,fout5)
  additional_colors = (/"black","gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks5,colormap,additional_colors)
  plot = new(8, graphic)

; keep previous resources

;;;;;;;;;;;;;
; Make plot 0 - Group 1 contributions
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group1"
  opts@gsnRightString             = sprintf("%5.2f",term2_group1_pcnt)+"%"
  cplot0  = gsn_csm_contour_map(wks5,term2_sum_group1,opts)
  plot(0) = cplot0
  delete(opts)

;;;;;;;;;;;;;
; Make plot1 - Group 2 contributions
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group2"
  opts@gsnRightString             = sprintf("%5.2f",term2_group2_pcnt)+"%"
  cplot1  = gsn_csm_contour_map(wks5,term2_sum_group2,opts)
  plot(1) = cplot1
  delete(opts)

;;;;;;;;;;;;;
; Make plot 2 - Group 3 contributions
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group3"
  opts@gsnRightString             = sprintf("%5.2f",term2_group3_pcnt)+"%"
  cplot0  = gsn_csm_contour_map(wks5,term2_sum_group3,opts)
  plot(2) = cplot0
  delete(opts)

;;;;;;;;;;;;;
; Make plot3 - Group 4 contributions
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group4"
  opts@gsnRightString             = sprintf("%5.2f",term2_group4_pcnt)+"%"
  cplot1  = gsn_csm_contour_map(wks5,term2_sum_group4,opts)
  plot(3) = cplot1
  delete(opts)

;;;;;;;;;;;;;
; Make plot 4 - Group 5 contributions
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group5"
  opts@gsnRightString             = sprintf("%5.2f",term2_group5_pcnt)+"%"
  cplot0  = gsn_csm_contour_map(wks5,term2_sum_group5,opts)
  plot(4) = cplot0
  delete(opts)

;;;;;;;;;;;;;
; Make plot5 - Group 6 contributions
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group6"
  opts@gsnRightString             = sprintf("%5.2f",term2_group6_pcnt)+"%"
  cplot1  = gsn_csm_contour_map(wks5,term2_sum_group6,opts)
  plot(5) = cplot1
  delete(opts)

;;;;;;;;;;;;;
; Make plot 6 - Group 7 contributions
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group7"
  opts@gsnRightString             = sprintf("%5.2f",term2_group7_pcnt)+"%"
  cplot0  = gsn_csm_contour_map(wks5,term2_sum_group7,opts)
  plot(6) = cplot0
  delete(opts)

;;;;;;;;;;;;;
; Make plot7 - Group 8 contributions
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group8"
  opts@gsnRightString             = sprintf("%5.2f",term2_group8_pcnt)+"%"
  cplot1  = gsn_csm_contour_map(wks5,term2_sum_group8,opts)
  plot(7) = cplot1
  delete(opts)

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
title_fin = vartitle1 + " group contributions to net intrapattern term: "+tag_1+" and "+tag_1b

  res_pan                            = True
  res_pan@txString                   = title_fin        ; main title
  res_pan@txFontHeightF              = 0.0175
  res_pan@gsnPaperOrientation        = "landscape"      ; landscape mode
  res_pan@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  res_pan@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  res_pan@gsnPanelScalePlotIndex     = 1
  res_pan@gsnMaximize                = True	       ; fill the page
  res_pan@gsnPanelLabelBar           = True
  res_pan@lbTitleString              = var1@units
  res_pan@lbTitlePosition            = "right"
  res_pan@lbLabelStride              = stride1
  res_pan@lbLabelFontHeightF         = 0.01
  res_pan@lbTitleJust                = "CenterLeft"
  res_pan@lbTitleFontHeightF         = 0.01
  res_pan@lbTitleDirection           = "Across"
  gsn_panel(wks5,(/plot/),(/2,4/),res_pan)               ; create final panel plot

  print("converting plot 5 to png")
; convert to png 
  convert_cmd = "convert -density 300 "+fout5+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout5+".png"

  system(convert_cmd)

delete(res_pan)
delete(plot)
delete(additional_colors)
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 6 - Net difference and difference terms - group2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot6").and.(plot6))then  ; if plotting is turned on
print("Plot 6 - Groups and combined terms")
fout6   = varcode+"_groups_combined-"+datatitle1+"_"+datatitle1b

  wks6 = gsn_open_wks("ps" ,fout6)
  additional_colors = (/"black","gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks6,colormap,additional_colors)
  plot = new(8, graphic)

; keep previous resources

;;;;;;;;;;;;;
; Make plot 0 - Group 1 contributions
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group1"
  opts@gsnRightString             = sprintf("%5.2f",term3_group1_pcnt)+"%"
  cplot0  = gsn_csm_contour_map(wks6,term3_sum_group1,opts)
  plot(0) = cplot0
  delete(opts)

;;;;;;;;;;;;;
; Make plot1 - Group 2 contributions
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group2"
  opts@gsnRightString             = sprintf("%5.2f",term3_group2_pcnt)+"%"
  cplot1  = gsn_csm_contour_map(wks6,term3_sum_group2,opts)
  plot(1) = cplot1
  delete(opts)

;;;;;;;;;;;;;
; Make plot 2 - Group 3 contributions
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group3"
  opts@gsnRightString             = sprintf("%5.2f",term3_group3_pcnt)+"%"
  cplot0  = gsn_csm_contour_map(wks6,term3_sum_group3,opts)
  plot(2) = cplot0
  delete(opts)

;;;;;;;;;;;;;
; Make plot3 - Group 4 contributions
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group4"
  opts@gsnRightString             = sprintf("%5.2f",term3_group4_pcnt)+"%"
  cplot1  = gsn_csm_contour_map(wks6,term3_sum_group4,opts)
  plot(3) = cplot1
  delete(opts)

;;;;;;;;;;;;;
; Make plot 4 - Group 5 contributions
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group5"
  opts@gsnRightString             = sprintf("%5.2f",term3_group5_pcnt)+"%"
  cplot0  = gsn_csm_contour_map(wks6,term3_sum_group5,opts)
  plot(4) = cplot0
  delete(opts)

;;;;;;;;;;;;;
; Make plot5 - Group 6 contributions
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group6"
  opts@gsnRightString             = sprintf("%5.2f",term3_group6_pcnt)+"%"
  cplot1  = gsn_csm_contour_map(wks6,term3_sum_group6,opts)
  plot(5) = cplot1
  delete(opts)

;;;;;;;;;;;;;
; Make plot 6 - Group 7 contributions
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group7"
  opts@gsnRightString             = sprintf("%5.2f",term3_group7_pcnt)+"%"
  cplot0  = gsn_csm_contour_map(wks6,term3_sum_group7,opts)
  plot(6) = cplot0
  delete(opts)

;;;;;;;;;;;;;
; Make plot7 - Group 8 contributions
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group8"
  opts@gsnRightString             = sprintf("%5.2f",term3_group8_pcnt)+"%"
  cplot1  = gsn_csm_contour_map(wks6,term3_sum_group8,opts)
  plot(7) = cplot1
  delete(opts)

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
title_fin = vartitle1 + " group contributions to net combined term: "+tag_1+" and "+tag_1b

  res_pan                            = True
  res_pan@txString                   = title_fin        ; main title
  res_pan@txFontHeightF              = 0.0175
  res_pan@gsnPaperOrientation        = "landscape"      ; landscape mode
  res_pan@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  res_pan@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  res_pan@gsnPanelScalePlotIndex     = 1
  res_pan@gsnMaximize                = True	       ; fill the page
  res_pan@gsnPanelLabelBar           = True
  res_pan@lbTitleString              = var1@units
  res_pan@lbTitlePosition            = "right"
  res_pan@lbLabelStride              = stride1
  res_pan@lbLabelFontHeightF         = 0.01
  res_pan@lbTitleJust                = "CenterLeft"
  res_pan@lbTitleFontHeightF         = 0.01
  res_pan@lbTitleDirection           = "Across"
  gsn_panel(wks6,(/plot/),(/2,4/),res_pan)               ; create final panel plot

  print("converting plot 6 to png")
; convert to png 
  convert_cmd = "convert -density 300 "+fout6+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout6+".png"

  system(convert_cmd)

delete(res_pan)
delete(plot)
delete(additional_colors)
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 7 - Group contributions (all)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot7").and.(plot7))then  ; if plotting is turned on
print("Plot 7 - Groups and all terms")
fout7   = varcode+"_groups_combined-"+datatitle1+"_"+datatitle1b

  wks7 = gsn_open_wks("ps" ,fout7)
  additional_colors = (/"black","gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks7,colormap,additional_colors)
  plot = new(24, graphic)

; keep previous resources except levels - use "net" values
  res@cnMinLevelValF             = cmin3             ; set min contour level specified above
  res@cnMaxLevelValF             = cmax3             ; set max contour level specified above
  res@cnLevelSpacingF            = clev3             ; set contour spacing specified above
  res@lbLabelStride              = stride3

;;;;;;;;;;;;;
; Make plot 0 - Group 1 contributions
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group1- net difference"
  opts@gsnRightString             = sprintf("%5.2f",group1_pcnt)+"%"
  cplot  = gsn_csm_contour_map(wks7,net_group1,opts)
  plot(0) = cplot
  delete(opts)

;;;;;;;;;;;;;
; Make plot1 - Group 2 contributions
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group2- net difference"
  opts@gsnRightString             = sprintf("%5.2f",group2_pcnt)+"%"
  cplot  = gsn_csm_contour_map(wks7,net_group2,opts)
  plot(1) = cplot
  delete(opts)

;;;;;;;;;;;;;
; Make plot 2 - Group 3 contributions
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group3- net difference"
  opts@gsnRightString             = sprintf("%5.2f",group3_pcnt)+"%"
  cplot  = gsn_csm_contour_map(wks7,net_group3,opts)
  plot(2) = cplot
  delete(opts)

;;;;;;;;;;;;;
; Make plot3 - Group 4 contributions
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group4- net difference"
  opts@gsnRightString             = sprintf("%5.2f",group4_pcnt)+"%"
  cplot  = gsn_csm_contour_map(wks7,net_group4,opts)
  plot(3) = cplot
  delete(opts)

;;;;;;;;;;;;;
; Make plot 4 - Group 5 contributions
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group5- net difference"
  opts@gsnRightString             = sprintf("%5.2f",group5_pcnt)+"%"
  cplot  = gsn_csm_contour_map(wks7,net_group5,opts)
  plot(4) = cplot
  delete(opts)

;;;;;;;;;;;;;
; Make plot5 - Group 6 contributions
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group6- net difference"
  opts@gsnRightString             = sprintf("%5.2f",group6_pcnt)+"%"
  cplot  = gsn_csm_contour_map(wks7,net_group6,opts)
  plot(5) = cplot
  delete(opts)

;;;;;;;;;;;;;
; Make plot 6 - Group 7 contributions
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group7- net difference"
  opts@gsnRightString             = sprintf("%5.2f",group7_pcnt)+"%"
  cplot  = gsn_csm_contour_map(wks7,net_group7,opts)
  plot(6) = cplot
  delete(opts)

;;;;;;;;;;;;;
; Make plot7 - Group 8 contributions
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group8- net difference"
  opts@gsnRightString             = sprintf("%5.2f",group8_pcnt)+"%"
  cplot  = gsn_csm_contour_map(wks7,net_group8,opts)
  plot(7) = cplot
  delete(opts)

;;;;;;;;;;;;;
; Make plot 0 - Group 1 contributions to net frequency term
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group1-net frequency term"
  opts@gsnRightString             = sprintf("%5.2f",term1_group1_pcnt)+"%"
  cplot  = gsn_csm_contour_map(wks7,term1_sum_group1,opts)
  plot(8) = cplot
  delete(opts)

;;;;;;;;;;;;;
; Make plot1 - Group 2 contributions to net frequency term
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group2-net frequency term"
  opts@gsnRightString             = sprintf("%5.2f",term1_group2_pcnt)+"%"
  cplot  = gsn_csm_contour_map(wks7,term1_sum_group2,opts)
  plot(9) = cplot
  delete(opts)

;;;;;;;;;;;;;
; Make plot 2 - Group 3 contributions to net frequency term
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group3-net frequency term"
  opts@gsnRightString             = sprintf("%5.2f",term1_group3_pcnt)+"%"
  cplot  = gsn_csm_contour_map(wks7,term1_sum_group3,opts)
  plot(10) = cplot
  delete(opts)

;;;;;;;;;;;;;
; Make plot3 - Group 4 contributions to net frequency term
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group4-net frequency term"
  opts@gsnRightString             = sprintf("%5.2f",term1_group4_pcnt)+"%"
  cplot  = gsn_csm_contour_map(wks7,term1_sum_group4,opts)
  plot(11) = cplot
  delete(opts)

;;;;;;;;;;;;;
; Make plot 4 - Group 5 contributions to net frequency term
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group5-net frequency term"
  opts@gsnRightString             = sprintf("%5.2f",term1_group5_pcnt)+"%"
  cplot  = gsn_csm_contour_map(wks7,term1_sum_group5,opts)
  plot(12) = cplot
  delete(opts)

;;;;;;;;;;;;;
; Make plot5 - Group 6 contributions to net frequency term
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group6-net frequency term"
  opts@gsnRightString             = sprintf("%5.2f",term1_group6_pcnt)+"%"
  cplot  = gsn_csm_contour_map(wks7,term1_sum_group6,opts)
  plot(13) = cplot
  delete(opts)

;;;;;;;;;;;;; 
; Make plot 6 - Group 7 contributions to net frequency term
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group7-net frequency term"
  opts@gsnRightString             = sprintf("%5.2f",term1_group7_pcnt)+"%"
  cplot  = gsn_csm_contour_map(wks7,term1_sum_group7,opts)
  plot(14) = cplot
  delete(opts)

;;;;;;;;;;;;;
; Make plot7 - Group 8 contributions to net frequency term
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group8-net frequency term"
  opts@gsnRightString             = sprintf("%5.2f",term1_group8_pcnt)+"%"
  cplot  = gsn_csm_contour_map(wks7,term1_sum_group8,opts)
  plot(15) = cplot
  delete(opts)

;;;;;;;;;;;;;
; Make plot 0 - Group 1 contributions to net intrapattern term
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group1-net intrapattern term"
  opts@gsnRightString             = sprintf("%5.2f",term1_group1_pcnt)+"%"
  cplot  = gsn_csm_contour_map(wks7,term1_sum_group1,opts)
  plot(16) = cplot
  delete(opts)

;;;;;;;;;;;;;
; Make plot1 - Group 2 contributions to net intrapattern term
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group2-net intrapattern term"
  opts@gsnRightString             = sprintf("%5.2f",term2_group2_pcnt)+"%"
  cplot  = gsn_csm_contour_map(wks7,term2_sum_group2,opts)
  plot(17) = cplot
  delete(opts)

;;;;;;;;;;;;;
; Make plot 2 - Group 3 contributions to net intrapattern term
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group3-net intrapattern term"
  opts@gsnRightString             = sprintf("%5.2f",term2_group3_pcnt)+"%"
  cplot  = gsn_csm_contour_map(wks7,term2_sum_group3,opts)
  plot(18) = cplot
  delete(opts)

;;;;;;;;;;;;;
; Make plot3 - Group 4 contributions to net intrapattern term
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group4-net intrapattern term"
  opts@gsnRightString             = sprintf("%5.2f",term2_group4_pcnt)+"%"
  cplot  = gsn_csm_contour_map(wks7,term2_sum_group4,opts)
  plot(19) = cplot
  delete(opts)

;;;;;;;;;;;;;
; Make plot 4 - Group 5 contributions to net intrapattern term
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group5-net intrapattern term"
  opts@gsnRightString             = sprintf("%5.2f",term2_group5_pcnt)+"%"
  cplot  = gsn_csm_contour_map(wks7,term2_sum_group5,opts)
  plot(20) = cplot
  delete(opts)

;;;;;;;;;;;;;
; Make plot5 - Group 6 contributions to net intrapattern term
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group6-net intrapattern term"
  opts@gsnRightString             = sprintf("%5.2f",term2_group6_pcnt)+"%"
  cplot  = gsn_csm_contour_map(wks7,term2_sum_group6,opts)
  plot(21) = cplot
  delete(opts)

;;;;;;;;;;;;; 
; Make plot 6 - Group 7 contributions to net intrapattern term
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group7-net intrapattern term"
  opts@gsnRightString             = sprintf("%5.2f",term2_group7_pcnt)+"%"
  cplot  = gsn_csm_contour_map(wks7,term2_sum_group7,opts)
  plot(22) = cplot
  delete(opts)

;;;;;;;;;;;;;
; Make plot7 - Group 8 contributions to net intrapattern term
;;;;;;;;;;;;;
  opts = res
  opts@gsnLeftString              = "Group8-net intrapattern term"
  opts@gsnRightString             = sprintf("%5.2f",term2_group8_pcnt)+"%"
  cplot  = gsn_csm_contour_map(wks7,term2_sum_group8,opts)
  plot(23) = cplot
  delete(opts)

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
title_fin = vartitle1 + " group contributions to net and net terms: "+tag_1+" and "+tag_1b

  res_pan                            = True
  res_pan@txString                   = title_fin        ; main title
  res_pan@txFontHeightF              = 0.012
  res_pan@gsnPaperOrientation        = "landscape"      ; landscape mode
  res_pan@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  res_pan@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  res_pan@gsnPanelScalePlotIndex     = 1
  res_pan@gsnMaximize                = True	       ; fill the page
  res_pan@gsnPanelLabelBar           = True
  res_pan@lbTitleString              = var1@units
  res_pan@lbTitlePosition            = "right"
  res_pan@lbLabelStride              = stride1
  res_pan@lbLabelFontHeightF         = 0.01
  res_pan@lbTitleJust                = "CenterLeft"
  res_pan@lbTitleFontHeightF         = 0.01
  res_pan@lbTitleDirection           = "Across"
  gsn_panel(wks7,(/plot/),(/6,4/),res_pan)               ; create final panel plot

  print("converting plot 7 to png")
; convert to png 
  convert_cmd = "convert -density 300 "+fout7+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 257 -depth 8 "+fout7+".png"

  system(convert_cmd)

delete(res_pan)
delete(plot)
delete(additional_colors)
delete(res)
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 8 - Percent difference for each node, sum of all terms
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot8").and.(plot8))then  ; if plotting is turned on
print("Plot 8 - Percent contribution of nodes")
fout8   = varcode+"_nodes_pcnt_contribution_all_terms_"+datatitle1+"_"+datatitle1b

  title = nx_input+"x"+ny_input+" pattern contribution to net difference: 2005-2007 "+tag_1+" and "+tag_1b
  wks8 = gsn_open_wks("ps",fout8)
  gsn_define_colormap(wks8, "BlueRed")

  ; make data into som size for plotting
  nodes_all_pcnt_plot = onedtond(nodes_all_pcnt, (/ny_node,nx_node/))
  ;; Reverse rows(for plotting purposes)
  ;nodes_all_pcnt_plot = nodes_all_pcnt_plot(:,::-1)
  ; Reverse columns(for plotting purposes)
  nodes_all_pcnt_plot = nodes_all_pcnt_plot(::-1,:)

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

  plot = gsn_blank_plot(wks8,res_blank)

; Add in squares:
  xx = (/0., 0., 1., 1., 0./)
  yy = (/0., 1., 1., 0., 0./)

; Polygon resources for color shading:
  res_poly = True
  res_poly@gsFillColor = "white" 
; Text resources for count and freq:
  res_txt = True
  res_txt@txFontHeightF = 0.01
  res_txt@txFont = 22
  res_txt@txFontColor = "black"

; get color scales for + and - contribution
  slope = 4./(max(abs(nodes_all_pcnt_plot))-0.0)
  color_indices = slope*nodes_all_pcnt_plot

; loop through each node to plot
n = 0
do y = 0, ny_node - 1
  do x = 0, nx_node - 1 
    xp = xx + x
    yp = yy + y 
 
    ; Draw boxes
    dum1(n) = gsn_add_polygon(wks8, plot, xp, yp, res_poly)
    dum2(n) = gsn_add_polyline(wks8, plot, xp, yp, res_poly)

    ; color ALL squares by influence
    color_index = color_indices(y,x)
    if(color_index .ge. 3.0)
      res_txt@txBackgroundFillColor = 9
    end if
    if(color_index .ge. 2.0 .and. color_index .lt. 3.0)
      res_txt@txBackgroundFillColor = 8
    end if
    if(color_index .ge. 1.0 .and. color_index .lt. 2.0)
      res_txt@txBackgroundFillColor = 7
    end if
    if(color_index .gt. 0.0 .and. color_index .lt. 1.0)
      res_txt@txBackgroundFillColor = 6
    end if
    if(color_index .eq. 0.0)
      res_txt@txBackgroundFillColor = "white"
    end if
    if(color_index .lt. 0.0 .and. color_index .gt. -1.0)
      res_txt@txBackgroundFillColor = 5
    end if
    if(color_index .lt. -1.0 .and. color_index .gt. -2.0)
      res_txt@txBackgroundFillColor = 4
    end if
    if(color_index .lt. -2.0 .and. color_index .gt. -3.0)
      res_txt@txBackgroundFillColor = 3
    end if
    if(color_index .lt. -3.0)
      res_txt@txBackgroundFillColor = 2
    end if

    text = "% of net mean~C~difference~C~"+sprintf("%5.2f",nodes_all_pcnt_plot(y,x))+"%"
    dum3(n) = gsn_add_text(wks8, plot, text, xp(0)+.5, yp(0)+.5, res_txt)   
    delete(text)
    delete(res_txt@txBackgroundFillColor)
    n = n+1
  end do 
end do
  
; Finally - make plot
  draw(plot)
  frame(wks8)
  print("converting plot 8 to png")
  convert_cmd = "convert -density 300 "+fout8+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout8+".png"
  system(convert_cmd)

delete(title)
delete(plot)

end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 9 - Percent difference for each node, sum of all terms
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot9").and.(plot9))then  ; if plotting is turned on
print("Plot 9 - Percent contribution of nodes to net frequency difference term")
fout9   = varcode+"_nodes_pcnt_contribution_frequency_"+datatitle1+"_"+datatitle1b

  title = nx_input+"x"+ny_input+" pattern contribution to frequency net difference: 2005-2007 "+tag_1+" and "+tag_1b
  wks9 = gsn_open_wks("ps",fout9)
  gsn_define_colormap(wks9, "BlueRed")

  ; make data into som size for plotting
  nodes_term1_pcnt_plot = onedtond(nodes_term1_pcnt, (/ny_node,nx_node/))
  ; Reverse columns(for plotting purposes)
  nodes_term1_pcnt_plot = nodes_term1_pcnt_plot(::-1,:)

; Begin plotting:    
  plot = new(1, graphic)
  dum1  = new((/nnode/),graphic)
  dum2  = new((/nnode/),graphic)
  dum3  = new((/nnode/),graphic)

; Change a few resources
  delete(res_blank@tiMainString)
  res_blank@tiMainString                   = title
  plot = gsn_blank_plot(wks9,res_blank)

; get color scales for + and - contribution
  delete(slope)
  delete(color_indices)
  slope = 4./(max(abs(nodes_term1_pcnt_plot))-0.0)
  color_indices = slope*nodes_term1_pcnt_plot

; loop through each node to plot
n = 0
do y = 0, ny_node - 1
  do x = 0, nx_node - 1 
    xp = xx + x
    yp = yy + y 
 
    ; Draw boxes
    dum1(n) = gsn_add_polygon(wks9, plot, xp, yp, res_poly)
    dum2(n) = gsn_add_polyline(wks9, plot, xp, yp, res_poly)

    ; color ALL squares by influence
    color_index = color_indices(y,x)
    if(color_index .ge. 3.0)
      res_txt@txBackgroundFillColor = 9
    end if
    if(color_index .ge. 2.0 .and. color_index .lt. 3.0)
      res_txt@txBackgroundFillColor = 8
    end if
    if(color_index .ge. 1.0 .and. color_index .lt. 2.0)
      res_txt@txBackgroundFillColor = 7
    end if
    if(color_index .gt. 0.0 .and. color_index .lt. 1.0)
      res_txt@txBackgroundFillColor = 6
    end if
    if(color_index .eq. 0.0)
      res_txt@txBackgroundFillColor = "white"
    end if
    if(color_index .lt. 0.0 .and. color_index .gt. -1.0)
      res_txt@txBackgroundFillColor = 5
    end if
    if(color_index .lt. -1.0 .and. color_index .gt. -2.0)
      res_txt@txBackgroundFillColor = 4
    end if
    if(color_index .lt. -2.0 .and. color_index .gt. -3.0)
      res_txt@txBackgroundFillColor = 3
    end if
    if(color_index .lt. -3.0)
      res_txt@txBackgroundFillColor = 2
    end if

    text = "% of net~C~frequency~C~term~C~"+sprintf("%5.2f",nodes_term1_pcnt_plot(y,x))+"%"
    dum3(n) = gsn_add_text(wks9, plot, text, xp(0)+.5, yp(0)+.5, res_txt)   
    delete(text)
    delete(res_txt@txBackgroundFillColor)
    n = n+1
  end do 
end do
  
; Finally - make plot
  draw(plot)
  frame(wks9)
  print("converting plot 9 to png")
  convert_cmd = "convert -density 300 "+fout9+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout9+".png"
  system(convert_cmd)

delete(title)
delete(plot)

end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 10 - Percent difference for each node to intrapattern term
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot10").and.(plot10))then  ; if plotting is turned on
print("Plot 10 - Percent contribution of nodes to net intrapattern difference term")
fout10   = varcode+"_nodes_pcnt_contribution_intrapattern_"+datatitle1+"_"+datatitle1b

  title = nx_input+"x"+ny_input+" pattern contribution to intrapattern net difference: 2005-2007 "+tag_1+" and "+tag_1b
  wks10 = gsn_open_wks("ps",fout10)
  gsn_define_colormap(wks10, "BlueRed")

  ; make data into som size for plotting
  nodes_term2_pcnt_plot = onedtond(nodes_term2_pcnt, (/ny_node,nx_node/))
  ; Reverse columns(for plotting purposes)
  nodes_term2_pcnt_plot = nodes_term2_pcnt_plot(::-1,:)

; Begin plotting:    
  plot = new(1, graphic)
  dum1  = new((/nnode/),graphic)
  dum2  = new((/nnode/),graphic)
  dum3  = new((/nnode/),graphic)

; Change a few resources
  delete(res_blank@tiMainString)
  res_blank@tiMainString                   = title
  plot = gsn_blank_plot(wks10,res_blank)

; get color scales for + and - contribution
  delete(slope)
  delete(color_indices)
  slope = 4./(max(abs(nodes_term2_pcnt_plot))-0.0)
  color_indices = slope*nodes_term2_pcnt_plot

; loop through each node to plot
n = 0
do y = 0, ny_node - 1
  do x = 0, nx_node - 1 
    xp = xx + x
    yp = yy + y 
 
    ; Draw boxes
    dum1(n) = gsn_add_polygon(wks10, plot, xp, yp, res_poly)
    dum2(n) = gsn_add_polyline(wks10, plot, xp, yp, res_poly)

    ; color ALL squares by influence
    color_index = color_indices(y,x)
    if(color_index .ge. 3.0)
      res_txt@txBackgroundFillColor = 9
    end if
    if(color_index .ge. 2.0 .and. color_index .lt. 3.0)
      res_txt@txBackgroundFillColor = 8
    end if
    if(color_index .ge. 1.0 .and. color_index .lt. 2.0)
      res_txt@txBackgroundFillColor = 7
    end if
    if(color_index .gt. 0.0 .and. color_index .lt. 1.0)
      res_txt@txBackgroundFillColor = 6
    end if
    if(color_index .eq. 0.0)
      res_txt@txBackgroundFillColor = "white"
    end if
    if(color_index .lt. 0.0 .and. color_index .gt. -1.0)
      res_txt@txBackgroundFillColor = 5
    end if
    if(color_index .lt. -1.0 .and. color_index .gt. -2.0)
      res_txt@txBackgroundFillColor = 4
    end if
    if(color_index .lt. -2.0 .and. color_index .gt. -3.0)
      res_txt@txBackgroundFillColor = 3
    end if
    if(color_index .lt. -3.0)
      res_txt@txBackgroundFillColor = 2
    end if

    text = "% of net~C~intrapattern~C~term~C~"+sprintf("%5.2f",nodes_term2_pcnt_plot(y,x))+"%"
    dum3(n) = gsn_add_text(wks10, plot, text, xp(0)+.5, yp(0)+.5, res_txt)   
    delete(text)
    delete(res_txt@txBackgroundFillColor)
    n = n+1
  end do 
end do
  
; Finally - make plot
  draw(plot)
  frame(wks10)
  print("converting plot 10 to png")
  convert_cmd = "convert -density 300 "+fout10+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout10+".png"
  system(convert_cmd)

delete(title)
delete(plot)

end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot 11 - Percent difference for each node to combined term
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("plot11").and.(plot11))then  ; if plotting is turned on
print("Plot 11 - Percent contribution of nodes to net combined difference term")
fout11   = varcode+"_nodes_pcnt_contribution_combined_"+datatitle1+"_"+datatitle1b

  title = nx_input+"x"+ny_input+" pattern contribution to combined net difference: 2005-2007 "+tag_1+" and "+tag_1b
  wks11 = gsn_open_wks("ps",fout11)
  gsn_define_colormap(wks11, "BlueRed")

  ; make data into som size for plotting
  nodes_term3_pcnt_plot = onedtond(nodes_term3_pcnt, (/ny_node,nx_node/))
  ; Reverse columns(for plotting purposes)
  nodes_term3_pcnt_plot = nodes_term3_pcnt_plot(::-1,:)

; Begin plotting:    
  plot = new(1, graphic)
  dum1  = new((/nnode/),graphic)
  dum2  = new((/nnode/),graphic)
  dum3  = new((/nnode/),graphic)

; Change a few resources
  delete(res_blank@tiMainString)
  res_blank@tiMainString                   = title
  plot = gsn_blank_plot(wks11,res_blank)

; get color scales for + and - contribution
  delete(slope)
  delete(color_indices)
  slope = 4./(max(abs(nodes_term3_pcnt_plot))-0.0)
  color_indices = slope*nodes_term3_pcnt_plot

; loop through each node to plot
n = 0
do y = 0, ny_node - 1
  do x = 0, nx_node - 1 
    xp = xx + x
    yp = yy + y 
 
    ; Draw boxes
    dum1(n) = gsn_add_polygon(wks11, plot, xp, yp, res_poly)
    dum2(n) = gsn_add_polyline(wks11, plot, xp, yp, res_poly)

    ; color ALL squares by influence
    color_index = color_indices(y,x)
    if(color_index .ge. 3.0)
      res_txt@txBackgroundFillColor = 9
    end if
    if(color_index .ge. 2.0 .and. color_index .lt. 3.0)
      res_txt@txBackgroundFillColor = 8
    end if
    if(color_index .ge. 1.0 .and. color_index .lt. 2.0)
      res_txt@txBackgroundFillColor = 7
    end if
    if(color_index .gt. 0.0 .and. color_index .lt. 1.0)
      res_txt@txBackgroundFillColor = 6
    end if
    if(color_index .eq. 0.0)
      res_txt@txBackgroundFillColor = "white"
    end if
    if(color_index .lt. 0.0 .and. color_index .gt. -1.0)
      res_txt@txBackgroundFillColor = 5
    end if
    if(color_index .lt. -1.0 .and. color_index .gt. -2.0)
      res_txt@txBackgroundFillColor = 4
    end if
    if(color_index .lt. -2.0 .and. color_index .gt. -3.0)
      res_txt@txBackgroundFillColor = 3
    end if
    if(color_index .lt. -3.0)
      res_txt@txBackgroundFillColor = 2
    end if

    text = "% of net~C~combined~C~term~C~"+sprintf("%5.2f",nodes_term3_pcnt_plot(y,x))+"%"
    dum3(n) = gsn_add_text(wks11, plot, text, xp(0)+.5, yp(0)+.5, res_txt)   
    delete(text)
    delete(res_txt@txBackgroundFillColor)
    n = n+1
  end do 
end do
  
; Finally - make plot
  draw(plot)
  frame(wks11)
  print("converting plot 11 to png")
  convert_cmd = "convert -density 300 "+fout11+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout11+".png"
  system(convert_cmd)

delete(title)
delete(plot)

end if

print("Completed all plots for "+varcode)
print("Good job!")
;;;;;;;;;;;;;;;;;;;;;; END script
end
