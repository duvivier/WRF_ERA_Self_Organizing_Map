;***************************************
; PROGRAM DESCRIPTION: This script plots frequency information for
;                      a SOM trained with three data sets
; INPUT DATA: SOM date and visual files for three data types
; OUTPUT DATA: One  plot of frequency comparisons
; CREATOR: Matt Higgins(Oct 2008), Melissa Nigro (Aug 2011)
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
  nx_input = "7"
  ny_input = "5"
  master_vals = "winds0.01_rlen1000000_r4"
; 1997-2007 era_i vs. wrf50 6hrly
; ******************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; BEGIN SCRIPT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Running SOM frequency plot")
;;;;;;;;;;
; set input file information
;;;;;;;;;;
; era interim
  datatitle_1 = "era_i_199701_200712"
  datefile_1 = "/data3/duvivier/SOM/training/dates/"+datatitle_1+"_dates.txt"
  visfile_1  = "/data3/duvivier/SOM/training/som_"+nx_input+ny_input+"/master/"+datatitle_1+"_"+master_vals+".vis"
  dum = stringtochar(datatitle_1)
  dum1 = dum(0:4)
  tag_1 = chartostring(dum1)
  delete(dum)
  delete(dum1)
; wrf50
  datatitle_2 = "wrf50_199701_200712"
  datefile_2 = "/data3/duvivier/SOM/training/dates/"+datatitle_2+"_dates.txt"
  visfile_2  = "/data3/duvivier/SOM/training/som_"+nx_input+ny_input+"/master/"+datatitle_2+"_"+master_vals+".vis"
  dum = stringtochar(datatitle_2)
  dum1 = dum(0:4)
  tag_2 = chartostring(dum1)
  delete(dum)
  delete(dum1)

;;;;;;;;;;
; Load information for each file type
;;;;;;;;;;
; Dates from data array index and visual file that places each date at a given node
print("Loading dates and SOM visual data")
; era interim
  dates_1 = ndtooned(readAsciiTable(datefile_1,1,"string",0)) ; ignores no rows
  ndates_1 = dimsizes(dates_1)
  dateschar_1 = stringtochar(dates_1)
  sdateym_1 = chartostring(dateschar_1(:,0:5))
  sdatehrs_1 = chartostring(dateschar_1(:,8:9))
  vis_1 = new((/ndates_1,3/),integer)
  vis_1 = readAsciiTable(visfile_1,3,"integer",1) ; ignores first row
; wrf 50km
  dates_2 = ndtooned(readAsciiTable(datefile_2,1,"string",0)) ; ignores no rows
  ndates_2 = dimsizes(dates_2)
  dateschar_2 = stringtochar(dates_2)
  sdateym_2 = chartostring(dateschar_2(:,0:5))
  sdatehrs_2 = chartostring(dateschar_2(:,8:9))
  vis_2 = new((/ndates_2,3/),integer)
  vis_2 = readAsciiTable(visfile_2,3,"integer",1) ; ignores first row

;;;;;;;;;;
; Load in NAO indices
;;;;;;;;;;
NAOfile = "/data3/duvivier/SOM/analysis/frequency/NAO_indices_monthly.txt"
NAO = readAsciiTable(NAOfile,2,"float",1)
xlabel_dates = NAO(:,0)
times = dimsizes(xlabel_dates)
dates = ispan(0,times-1,1)
deltax = dates/10.

;;;;;;;;;;
; Get just dates we want
;;;;;;;;;;
  hrs_6 = (/"00","06","12","18"/)

  print("1997-2007 era_i vs. wrf50 6hrly")
  ; era interim - just need to narrow down years/months
  visall_1 = vis_1
  ndates_1 = dimsizes(visall_1(:,0))
  yrmon_1 = sdateym_1

  ; wrf 50km - narrow down hours to only 6hrs
  dateind_2 = ind(sdatehrs_2.eq.hrs_6(0).or.sdatehrs_2.eq.hrs_6(1).or.sdatehrs_2.eq.hrs_6(2).or.sdatehrs_2.eq.hrs_6(3))
  visall_2 = vis_2(dateind_2,:)
  ndates_2 = dimsizes(visall_2(:,0))
  yrmon_2 = sdateym_2(dateind_2)

  ; set output information
  fout  = "figure_3c"
  title = "c. 1997-2007 ERA-I and WRF50 correlation with NAO monthly index"

;;;;;;;;;;
; Calculate frequencies for each data type
;;;;;;;;;;
; get arrays for months and years
yrmons = (/"199701","199702","199703","199711","199712","199801","199802","199803","199811","199812","199901","199902","199903","199911","199912","200001","200002","200003","200011","200012","200101","200102","200103","200111","200112","200201","200202","200203","200211","200212","200301","200302","200303","200311","200312","200401","200402","200403","200411","200412","200501","200502","200503","200511","200512","200601","200602","200603","200611","200612","200701","200702","200703","200711","200712"/)

; Calculate node counts and frequencies for comparison of interest
  nx_node = stringtoint(nx_input)
  ny_node = stringtoint(ny_input)
; Calculate group counts and frequencies
  nx_group = 4
  ny_group = 2
  ngroup = nx_group*ny_group  ; 8 groups total

; variable 1
  groupfreq_1     = new((/ngroup,times/),"float") 
  groupcount_1    = new((/ngroup,times/),"integer") 
; variable_2
  groupfreq_2     = new((/ngroup,times/),"float") 
  groupcount_2    = new((/ngroup,times/),"integer") 
; correlations
  corr = new((/ngroup,2/),"float")
  corr_sig = new((/ngroup,2/),"float")

; set default check values
  check1 = 0
  check2 = 0
  n = 0
;;;;;;;;;;
; Get group frequencies
;;;;;;;;;;
; loop through each group and year/month
do g = 0,ngroup - 1
  do ym = 0, times -1 
  ; For each group, set the node values to load in for that year/month
  ; group1: Nodes("0,0" "1,0" "0,1")
  if (g .eq. 0) then
    dateindices_1 = ind((visall_1(:,0).eq.0.and.visall_1(:,1).eq.0).or.(visall_1(:,0).eq.1.and.visall_1(:,1).eq.0).or.(visall_1(:,0).eq.0.and.visall_1(:,1).eq.1).and.yrmon_1.eq.yrmons(ym))
    dateindices_2 = ind((visall_2(:,0).eq.0.and.visall_2(:,1).eq.0).or.(visall_2(:,0).eq.1.and.visall_2(:,1).eq.0).or.(visall_2(:,0).eq.0.and.visall_2(:,1).eq.1).and.yrmon_2.eq.yrmons(ym))
  end if
  ; group2: Nodes("2,0" "1,1" "2,1" "2,2" "3,2")
  if (g .eq. 1) then
    dateindices_1 = ind((visall_1(:,0).eq.2.and.visall_1(:,1).eq.0).or.(visall_1(:,0).eq.1.and.visall_1(:,1).eq.1).or.(visall_1(:,0).eq.2.and.visall_1(:,1).eq.1).or.(visall_1(:,0).eq.2.and.visall_1(:,1).eq.2).or.(visall_1(:,0).eq.3.and.visall_1(:,1).eq.2).and.yrmon_1.eq.yrmons(ym))
    dateindices_2 = ind((visall_2(:,0).eq.2.and.visall_2(:,1).eq.0).or.(visall_2(:,0).eq.1.and.visall_2(:,1).eq.1).or.(visall_2(:,0).eq.2.and.visall_2(:,1).eq.1).or.(visall_2(:,0).eq.2.and.visall_2(:,1).eq.2).or.(visall_2(:,0).eq.3.and.visall_2(:,1).eq.2).and.yrmon_2.eq.yrmons(ym))
  end if
  ; group3: Nodes("3,0" "4,0" "3,1" "4,1" "4,2" "5,2")
  if (g .eq. 2) then
    dateindices_1 = ind((visall_1(:,0).eq.3.and.visall_1(:,1).eq.0).or.(visall_1(:,0).eq.4.and.visall_1(:,1).eq.0).or.(visall_1(:,0).eq.3.and.visall_1(:,1).eq.1).or.(visall_1(:,0).eq.4.and.visall_1(:,1).eq.1).or.(visall_1(:,0).eq.4.and.visall_1(:,1).eq.2).or.(visall_1(:,0).eq.5.and.visall_1(:,1).eq.2).and.yrmon_1.eq.yrmons(ym))
    dateindices_2 = ind((visall_2(:,0).eq.3.and.visall_2(:,1).eq.0).or.(visall_2(:,0).eq.4.and.visall_2(:,1).eq.0).or.(visall_2(:,0).eq.3.and.visall_2(:,1).eq.1).or.(visall_2(:,0).eq.4.and.visall_2(:,1).eq.1).or.(visall_2(:,0).eq.4.and.visall_2(:,1).eq.2).or.(visall_2(:,0).eq.5.and.visall_2(:,1).eq.2).and.yrmon_2.eq.yrmons(ym))
  end if
  ; group4: Nodes("5,0" "6,0" "5,1" "6,1" "6,2")
  if (g .eq. 3) then
    dateindices_1 = ind((visall_1(:,0).eq.5.and.visall_1(:,1).eq.0).or.(visall_1(:,0).eq.6.and.visall_1(:,1).eq.0).or.(visall_1(:,0).eq.5.and.visall_1(:,1).eq.1).or.(visall_1(:,0).eq.6.and.visall_1(:,1).eq.1).or.(visall_1(:,0).eq.6.and.visall_1(:,1).eq.2).and.yrmon_1.eq.yrmons(ym))
    dateindices_2 = ind((visall_2(:,0).eq.5.and.visall_2(:,1).eq.0).or.(visall_2(:,0).eq.6.and.visall_2(:,1).eq.0).or.(visall_2(:,0).eq.5.and.visall_2(:,1).eq.1).or.(visall_2(:,0).eq.6.and.visall_2(:,1).eq.1).or.(visall_2(:,0).eq.6.and.visall_2(:,1).eq.2).and.yrmon_2.eq.yrmons(ym))
  end if
  ; group5: Nodes("0,2" "0,3" "0,4" "1,4")
  if (g .eq. 4) then
    dateindices_1 = ind((visall_1(:,0).eq.0.and.visall_1(:,1).eq.2).or.(visall_1(:,0).eq.0.and.visall_1(:,1).eq.3).or.(visall_1(:,0).eq.0.and.visall_1(:,1).eq.4).or.(visall_1(:,0).eq.1.and.visall_1(:,1).eq.4).and.yrmon_1.eq.yrmons(ym))
    dateindices_2 = ind((visall_2(:,0).eq.0.and.visall_2(:,1).eq.2).or.(visall_2(:,0).eq.0.and.visall_2(:,1).eq.3).or.(visall_2(:,0).eq.0.and.visall_2(:,1).eq.4).or.(visall_2(:,0).eq.1.and.visall_2(:,1).eq.4).and.yrmon_2.eq.yrmons(ym))
  end if
  ; group6: Nodes("1,2" "1,3" "2,3" "2,4")
  if (g .eq. 5) then
    dateindices_1 = ind((visall_1(:,0).eq.1.and.visall_1(:,1).eq.2).or.(visall_1(:,0).eq.1.and.visall_1(:,1).eq.3).or.(visall_1(:,0).eq.2.and.visall_1(:,1).eq.3).or.(visall_1(:,0).eq.2.and.visall_1(:,1).eq.4).and.yrmon_1.eq.yrmons(ym))
    dateindices_2 = ind((visall_2(:,0).eq.1.and.visall_2(:,1).eq.2).or.(visall_2(:,0).eq.1.and.visall_2(:,1).eq.3).or.(visall_2(:,0).eq.2.and.visall_2(:,1).eq.3).or.(visall_2(:,0).eq.2.and.visall_2(:,1).eq.4).and.yrmon_2.eq.yrmons(ym))
  end if
  ; group7: Nodes("3,3" "4,3" "3,4" "4,4")
  if (g .eq. 6) then
    dateindices_1 = ind((visall_1(:,0).eq.3.and.visall_1(:,1).eq.3).or.(visall_1(:,0).eq.4.and.visall_1(:,1).eq.3).or.(visall_1(:,0).eq.3.and.visall_1(:,1).eq.4).or.(visall_1(:,0).eq.4.and.visall_1(:,1).eq.4).and.yrmon_1.eq.yrmons(ym))
    dateindices_2 = ind((visall_2(:,0).eq.3.and.visall_2(:,1).eq.3).or.(visall_2(:,0).eq.4.and.visall_2(:,1).eq.3).or.(visall_2(:,0).eq.3.and.visall_2(:,1).eq.4).or.(visall_2(:,0).eq.4.and.visall_2(:,1).eq.4).and.yrmon_2.eq.yrmons(ym))
  end if
  ; group8: Nodes("5,3" "6,3" "5,4" "6,4")
  if (g .eq. 7) then
    dateindices_1 = ind((visall_1(:,0).eq.5.and.visall_1(:,1).eq.3).or.(visall_1(:,0).eq.6.and.visall_1(:,1).eq.3).or.(visall_1(:,0).eq.5.and.visall_1(:,1).eq.4).or.(visall_1(:,0).eq.6.and.visall_1(:,1).eq.4).and.yrmon_1.eq.yrmons(ym))
    dateindices_2 = ind((visall_2(:,0).eq.5.and.visall_2(:,1).eq.3).or.(visall_2(:,0).eq.6.and.visall_2(:,1).eq.3).or.(visall_2(:,0).eq.5.and.visall_2(:,1).eq.4).or.(visall_2(:,0).eq.6.and.visall_2(:,1).eq.4).and.yrmon_2.eq.yrmons(ym))
  end if
        
  ; This is the data for this group:
  ; variable 1
  if (all(ismissing(dateindices_1))) then
    group_ndates_1 = 0
    groupfreq_1(g,ym) = 0
    groupcount_1(g,ym) = 0
  end if
  if (.not.all(ismissing(dateindices_1))) then
    group_ndates_1 = dimsizes(dateindices_1)
    groupfreq_1(g,ym) = (int2flt(group_ndates_1)/int2flt(ndates_1))*100.
    groupcount_1(g,ym) = group_ndates_1
  end if
  check1 = check1 + group_ndates_1  ; make sure all dates are counted
  ; variable 2
  if (all(ismissing(dateindices_2))) then
    group_ndates_2 = 0
    groupfreq_2(g,ym) = 0
    groupcount_2(g,ym) = 0
  end if
  if (.not.all(ismissing(dateindices_2))) then
    group_ndates_2 = dimsizes(dateindices_2)
    groupfreq_2(g,ym) = (int2flt(group_ndates_2)/int2flt(ndates_2))*100.
    groupcount_2(g,ym) = group_ndates_2
  end if
  check2 = check2 + group_ndates_2  ; make sure all dates are counted
   delete(dateindices_1)
   delete(dateindices_2)
 end do

   ; Calculate correlation
   corr(g,0) = escorc(NAO(:,1),groupfreq_1(g,:))
   corr_sig(g,0) = rtest(corr(g,0),times,0)
   corr(g,1) = escorc(NAO(:,1),groupfreq_2(g,:))
   corr_sig(g,1) = rtest(corr(g,1),times,0)
end do

; Check the dates and print error messages if calculation fails
if (check1.ne.ndates_1) then
 print("Error.  Number of dates is not equal to total number of indices.")
 print("Num. dates: "+ndates_1+"   Tot indices: "+check1)
end if
if (check2.ne.ndates_2) then
 print("Error.  Number of dates is not equal to total number of indices.")
 print("Num. dates: "+ndates_2+"   Tot indices: "+check2)
end if

; statistical significance meanings:
siglvl = 0.05     ; 95% significance
; if corr_sig .ge. siglvl then it's significant correlation

;;;;;;;;;;
; Set array size for group plot
;;;;;;;;;;
; make new arrays
corr_1   = new((/nx_group, ny_group/),"float")
corr_sig_1   = new((/nx_group, ny_group/),"float")
corr_2   = new((/nx_group, ny_group/),"float")
corr_sig_2   = new((/nx_group, ny_group/),"float")

; assign data to new arrays
corr_1(:,0)   = corr(0:nx_group-1,0)
corr_1(:,1)   = corr(nx_group:ngroup-1,0)
corr_sig_1(:,0)   = corr_sig(0:nx_group-1,0)
corr_sig_1(:,1)   = corr_sig(nx_group:ngroup-1,0)
corr_2(:,0)   = corr(0:nx_group-1,1)
corr_2(:,1)   = corr(nx_group:ngroup-1,1)
corr_sig_2(:,0)   = corr_sig(0:nx_group-1,1)
corr_sig_2(:,1)   = corr_sig(nx_group:ngroup-1,1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Plotting the som frequencies")
; Create the frequency plot
  wks = gsn_open_wks("ps",fout)
  gsn_define_colormap(wks,"gsdtol")
  gsn_reverse_colormap(wks)
  colors = gsn_retrieve_colormap(wks) ; load fixed map into "colors"
  additional_colors = (/"blue", "red", "lightblue", "pink"/)
  gsn_merge_colormaps(wks,colors,additional_colors)

  ; reverse rows for plotting
  corr_1     = corr_1(:,::-1)
  corr_sig_1 = corr_sig_1(:,::-1)
  corr_2     = corr_2(:,::-1)
  corr_sig_2 = corr_sig_2(:,::-1)

; Begin plotting:    
  plot = new(1, graphic)
  dum1  = new((/ngroup/),graphic)
  dum2  = new((/ngroup/),graphic)
  dum3  = new((/ngroup/),graphic)
  dum4  = new((/ngroup/),graphic)
  dum5  = new((/ngroup/),graphic)
  dum6  = new((/ngroup/),graphic)

; Resources for blank plot:
  res_blank                                = True
  res_blank@gsnFrame                       = False  ; do not frame yet (so we can panel)
  res_blank@gsnDraw                        = False   ; do not draw yet (so we can panel)
  res_blank@gsnMaximize                    = True
  res_blank@trXMinF                        = 0
  res_blank@trXMaxF                        = nx_group
  res_blank@trYMinF                        = 0
  res_blank@trYMaxF                        = ny_group
  res_blank@vpWidthF                       = 0.6           ; this is default
  res_blank@vpHeightF                      = 0.6*ny_group / nx_group  ; set height so each node is square
  res_blank@tiMainFontHeightF              = 0.0125
  res_blank@tiMainPosition                 = "Left"
  res_blank@tiMainJust                     = "centerleft"
  res_blank@tmEqualizeXYSizes              = True    ; Equal sizes for tick labels
  res_blank@tmXBMajorLengthF               = 0.0      ; effectively turn off tick marks
  res_blank@tmYLMajorLengthF               = 0.0      ; effectively turn off tick marks
  res_blank@tmXBMode                       = "Explicit"
  ;res_blank@tmXBLabels                     = ispan(0,nx_group-1,1)+""            ; tick marks
  res_blank@tmXBValues                     = fspan(0, nx_group-1, nx_group) + 0.5 ; position for tick labels
  res_blank@tmYLMode                       = "Explicit"
  ;res_blank@tmYLLabels                     = ispan(ny_group-1,0,1)+""            ; backwards tick marks
  res_blank@tmYLValues                     = fspan(0, ny_group-1, ny_group) + 0.5 ; position for tick labels
  res_blank@tmXBLabelFontHeightF           = res_blank@tiMainFontHeightF
  ;res_blank@tiXAxisString                  = "SOM Pattern"
  ;res_blank@tiYAxisString                  = "SOM Pattern"
  res_blank@tiXAxisFontHeightF             = 0.01
  res_blank@tiYAxisFontHeightF             = 0.01
  res_blank@tiMainString                   = title

  plot = gsn_blank_plot(wks,res_blank)

; Add in squares:
  xx = (/0., 0., 1., 1., 0./)
  yy = (/0., 1., 1., 0., 0./)

; Polygon resources for color shading:
  res_poly = True
; Text resources for count and freq:
  res_txt = True
  res_txt@txFontHeightF = 0.0275 ;0.015
  res_txt@txFont = 22
  res_txt@BackgroundFillColor = "white"
  res_txt@txFontColor = "black"

; loop through each node to plot
  n = 0
  do y = 0, ny_group - 1
    do x = 0, nx_group - 1
      xp = xx + x
      yp = yy + y
                
      ; Color squares
      res_poly@gsFillColor = "white"
      dum1(n) = gsn_add_polygon(wks, plot, xp, yp, res_poly)
      dum2(n) = gsn_add_polyline(wks, plot, xp, yp, res_poly)

      ; ERA NAO correlation text:
      ; red/dark blue are significantly correlated
      ; pink/light blue are not significantly correlated but show sign of correlation
      res_txt1 = res_txt
      if(corr_1(x,y) .gt. 0.0 .and. corr_sig_1(x,y) .ge. siglvl) then
        res_txt1@txBackgroundFillColor = "red"
        ;res_txt1@txFontColor = "red"
      end if
      if(corr_1(x,y) .gt. 0.0 .and. corr_sig_1(x,y) .lt. siglvl) then
        res_txt1@txBackgroundFillColor = "pink"
        ;res_txt1@txFontColor = "pink"
      end if
      if(corr_1(x,y) .lt. 0.0 .and. corr_sig_1(x,y) .ge. siglvl) then
        res_txt1@txBackgroundFillColor = "blue"
        ;res_txt1@txFontColor = "blue"
      end if
      if(corr_1(x,y) .lt. 0.0 .and. corr_sig_1(x,y) .lt. siglvl) then
        res_txt1@txBackgroundFillColor = "lightblue"
        ;res_txt1@txFontColor = "lightblue"
      end if
      text_1 = "ERA-I:"
      text_2 = sprintf("%5.2f",corr_1(x,y))
      dum3(n) = gsn_add_text(wks, plot, text_1, xp(0)+.5, yp(0)+.85, res_txt)
      dum4(n) = gsn_add_text(wks, plot, text_2, xp(0)+.5, yp(0)+.65, res_txt1)
      delete(text_1)

      res_txt2 = res_txt
      if(corr_2(x,y) .gt. 0.0 .and. corr_sig_2(x,y) .ge. siglvl) then
        res_txt2@txBackgroundFillColor = "red"
        ;res_txt2@txFontColor = "red"
      end if
      if(corr_2(x,y) .gt. 0.0 .and. corr_sig_2(x,y) .lt. siglvl) then
        res_txt2@txBackgroundFillColor = "pink"
        ;res_txt2@txFontColor = "pink"
      end if
      if(corr_2(x,y) .lt. 0.0 .and. corr_sig_2(x,y) .ge. siglvl) then
        res_txt2@txBackgroundFillColor = "blue"
        ;res_txt2@txFontColor = "blue"
      end if
      if(corr_2(x,y) .lt. 0.0 .and. corr_sig_2(x,y) .lt. siglvl) then
        res_txt2@txBackgroundFillColor = "lightblue"
        ;res_txt2@txFontColor = "lightblue"
      end if
      text_3 = "WRF50:"
      text_4 = sprintf("%5.2f",corr_2(x,y))
      dum5(n) = gsn_add_text(wks, plot, text_3, xp(0)+.5, yp(0)+.4, res_txt)
      dum6(n) = gsn_add_text(wks, plot, text_4, xp(0)+.5, yp(0)+.2, res_txt2)
      delete(text_2)

      n = n + 1
    end do ; square for each node
  end do ; square for each node
  
; Finally - make plot
draw(plot)
frame(wks)

convert_cmd = "convert -density 300 "+fout+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout+".png"
system(convert_cmd)

;;;;;;;;;;;;;;;;;;;;;; END script
end
