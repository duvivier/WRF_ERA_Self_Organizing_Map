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
; 2005-2007 era_i, wrf50, and wrf10
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
; wrf10
  datatitle_3 = "wrf10_200511_200703"
  datefile_3 = "/data3/duvivier/SOM/training/dates/"+datatitle_3+"_dates.txt"
  visfile_3  = "/data3/duvivier/SOM/training/som_"+nx_input+ny_input+"/master/"+datatitle_3+"_"+master_vals+".vis"
  dum = stringtochar(datatitle_3)
  dum1 = dum(0:4)
  tag_3 = chartostring(dum1)
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
; wrf 10km
  dates_3 = ndtooned(readAsciiTable(datefile_3,1,"string",0)) ; ignores no rows
  ndates_3 = dimsizes(dates_3)
  dateschar_3 = stringtochar(dates_3)
  sdateym_3 = chartostring(dateschar_3(:,0:5))
  sdatehrs_3 = chartostring(dateschar_3(:,8:9))
  vis_3 = new((/ndates_3,3/),integer)
  vis_3 = readAsciiTable(visfile_3,3,"integer",1) ; ignores first row

;;;;;;;;;;
; Get just dates we want
;;;;;;;;;;
  hrs_6 = (/"00","06","12","18"/)
  ym_sub = (/"200511","200512","200601","200602","200603","200611","200612","200701","200702","200703"/)
;;;;;;;;;;
; Loop through plotting options
;;;;;;;;;;
  ; era interim - just need to narrow down years/months
  dateind_1 = ind(sdateym_1.eq.ym_sub(0).or.sdateym_1.eq.ym_sub(1).or.sdateym_1.eq.ym_sub(2).or.sdateym_1.eq.ym_sub(3).or.sdateym_1.eq.ym_sub(4).or.sdateym_1.eq.ym_sub(5).or.sdateym_1.eq.ym_sub(6).or.sdateym_1.eq.ym_sub(7).or.sdateym_1.eq.ym_sub(8).or.sdateym_1.eq.ym_sub(9))
  visall_1 = vis_1(dateind_1,:)
  ndates_1 = dimsizes(visall_1(:,0))

  ; wrf 50km - narrow down years/months/hours
  dateind_2 = ind(sdateym_2.eq.ym_sub(0).or.sdateym_2.eq.ym_sub(1).or.sdateym_2.eq.ym_sub(2).or.sdateym_2.eq.ym_sub(3).or.sdateym_2.eq.ym_sub(4).or.sdateym_2.eq.ym_sub(5).or.sdateym_2.eq.ym_sub(6).or.sdateym_2.eq.ym_sub(7).or.sdateym_2.eq.ym_sub(8).or.sdateym_2.eq.ym_sub(9))
  visall_2_tmp = vis_2(dateind_2,:)
  sdatehrs_tmp = sdatehrs_2(dateind_2)
  delete(dateind_2)
  dateind_2 = ind(sdatehrs_tmp.eq.hrs_6(0).or.sdatehrs_tmp.eq.hrs_6(1).or.sdatehrs_tmp.eq.hrs_6(2).or.sdatehrs_tmp.eq.hrs_6(3))
  visall_2 = visall_2_tmp(dateind_2,:)
  ndates_2 = dimsizes(visall_2(:,0))
  delete(sdatehrs_tmp)
  delete(visall_2_tmp)

  ; wrf 10km - just narrow down hours
  dateind_3 = ind(sdatehrs_3.eq.hrs_6(0).or.sdatehrs_3.eq.hrs_6(1).or.sdatehrs_3.eq.hrs_6(2).or.sdatehrs_3.eq.hrs_6(3))
  visall_3 = vis_3(dateind_3,:) ; get only every 6 hours
  ndates_3 = dimsizes(visall_3(:,0))

  ; set output information
  fout  = "figure_3b"
  title = "b. 2005-2007 ERA-I group frequency and differences (WRF50 - ERA-I) & (WRF10 - ERA-I)"

;;;;;;;;;;
; Calculate frequencies for each data type
;;;;;;;;;;
; Calculate node counts and frequencies for comparison of interest
  nx_node = stringtoint(nx_input)
  ny_node = stringtoint(ny_input)
; Calculate group counts and frequencies
  nx_group = 4
  ny_group = 2
  ngroup = nx_group*ny_group  ; 8 groups total

; variable 1
  groupfreq_1     = new((/ngroup/),"float") 
  groupcount_1    = new((/ngroup/),"integer") 
; variable_2
  groupfreq_2     = new((/ngroup/),"float") 
  groupcount_2    = new((/ngroup/),"integer") 
; variable_3
  groupfreq_3     = new((/ngroup/),"float") 
  groupcount_3    = new((/ngroup/),"integer") 

; set default check values
  check1 = 0
  check2 = 0
  check3 = 0
  xpos = 0
  ypos = 0
  n = 0

;;;;;;;;;;
; Get group frequencies
;;;;;;;;;;
; loop through each group
do g = 0,ngroup - 1
  ; For each group, set the node values to load in
  ; group1: Nodes("0,0" "1,0" "0,1")
  if (g .eq. 0) then
    dateindices_1 = ind((visall_1(:,0).eq.0.and.visall_1(:,1).eq.0).or.(visall_1(:,0).eq.1.and.visall_1(:,1).eq.0).or.(visall_1(:,0).eq.0.and.visall_1(:,1).eq.1))
    dateindices_2 = ind((visall_2(:,0).eq.0.and.visall_2(:,1).eq.0).or.(visall_2(:,0).eq.1.and.visall_2(:,1).eq.0).or.(visall_2(:,0).eq.0.and.visall_2(:,1).eq.1))
    dateindices_3 = ind((visall_3(:,0).eq.0.and.visall_3(:,1).eq.0).or.(visall_3(:,0).eq.1.and.visall_3(:,1).eq.0).or.(visall_3(:,0).eq.0.and.visall_3(:,1).eq.1))
  end if
  ; group2: Nodes("2,0" "1,1" "2,1" "2,2" "3,2")
  if (g .eq. 1) then
    dateindices_1 = ind((visall_1(:,0).eq.2.and.visall_1(:,1).eq.0).or.(visall_1(:,0).eq.1.and.visall_1(:,1).eq.1).or.(visall_1(:,0).eq.2.and.visall_1(:,1).eq.1).or.(visall_1(:,0).eq.2.and.visall_1(:,1).eq.2).or.(visall_1(:,0).eq.3.and.visall_1(:,1).eq.2))
    dateindices_2 = ind((visall_2(:,0).eq.2.and.visall_2(:,1).eq.0).or.(visall_2(:,0).eq.1.and.visall_2(:,1).eq.1).or.(visall_2(:,0).eq.2.and.visall_2(:,1).eq.1).or.(visall_2(:,0).eq.2.and.visall_2(:,1).eq.2).or.(visall_2(:,0).eq.3.and.visall_2(:,1).eq.2))
    dateindices_3 = ind((visall_3(:,0).eq.2.and.visall_3(:,1).eq.0).or.(visall_3(:,0).eq.1.and.visall_3(:,1).eq.1).or.(visall_3(:,0).eq.2.and.visall_3(:,1).eq.1).or.(visall_3(:,0).eq.2.and.visall_3(:,1).eq.2).or.(visall_3(:,0).eq.3.and.visall_3(:,1).eq.2))
  end if
  ; group3: Nodes("3,0" "4,0" "3,1" "4,1" "4,2" "5,2")
  if (g .eq. 2) then
    dateindices_1 = ind((visall_1(:,0).eq.3.and.visall_1(:,1).eq.0).or.(visall_1(:,0).eq.4.and.visall_1(:,1).eq.0).or.(visall_1(:,0).eq.3.and.visall_1(:,1).eq.1).or.(visall_1(:,0).eq.4.and.visall_1(:,1).eq.1).or.(visall_1(:,0).eq.4.and.visall_1(:,1).eq.2).or.(visall_1(:,0).eq.5.and.visall_1(:,1).eq.2))
    dateindices_2 = ind((visall_2(:,0).eq.3.and.visall_2(:,1).eq.0).or.(visall_2(:,0).eq.4.and.visall_2(:,1).eq.0).or.(visall_2(:,0).eq.3.and.visall_2(:,1).eq.1).or.(visall_2(:,0).eq.4.and.visall_2(:,1).eq.1).or.(visall_2(:,0).eq.4.and.visall_2(:,1).eq.2).or.(visall_2(:,0).eq.5.and.visall_2(:,1).eq.2))
    dateindices_3 = ind((visall_3(:,0).eq.3.and.visall_3(:,1).eq.0).or.(visall_3(:,0).eq.4.and.visall_3(:,1).eq.0).or.(visall_3(:,0).eq.3.and.visall_3(:,1).eq.1).or.(visall_3(:,0).eq.4.and.visall_3(:,1).eq.1).or.(visall_3(:,0).eq.4.and.visall_3(:,1).eq.2).or.(visall_3(:,0).eq.5.and.visall_3(:,1).eq.2))
  end if
  ; group4: Nodes("5,0" "6,0" "5,1" "6,1" "6,2")
  if (g .eq. 3) then
    dateindices_1 = ind((visall_1(:,0).eq.5.and.visall_1(:,1).eq.0).or.(visall_1(:,0).eq.6.and.visall_1(:,1).eq.0).or.(visall_1(:,0).eq.5.and.visall_1(:,1).eq.1).or.(visall_1(:,0).eq.6.and.visall_1(:,1).eq.1).or.(visall_1(:,0).eq.6.and.visall_1(:,1).eq.2))
    dateindices_2 = ind((visall_2(:,0).eq.5.and.visall_2(:,1).eq.0).or.(visall_2(:,0).eq.6.and.visall_2(:,1).eq.0).or.(visall_2(:,0).eq.5.and.visall_2(:,1).eq.1).or.(visall_2(:,0).eq.6.and.visall_2(:,1).eq.1).or.(visall_2(:,0).eq.6.and.visall_2(:,1).eq.2))
    dateindices_3 = ind((visall_3(:,0).eq.5.and.visall_3(:,1).eq.0).or.(visall_3(:,0).eq.6.and.visall_3(:,1).eq.0).or.(visall_3(:,0).eq.5.and.visall_3(:,1).eq.1).or.(visall_3(:,0).eq.6.and.visall_3(:,1).eq.1).or.(visall_3(:,0).eq.6.and.visall_3(:,1).eq.2))
  end if
  ; group5: Nodes("0,2" "0,3" "0,4" "1,4")
  if (g .eq. 4) then
    dateindices_1 = ind((visall_1(:,0).eq.0.and.visall_1(:,1).eq.2).or.(visall_1(:,0).eq.0.and.visall_1(:,1).eq.3).or.(visall_1(:,0).eq.0.and.visall_1(:,1).eq.4).or.(visall_1(:,0).eq.1.and.visall_1(:,1).eq.4))
    dateindices_2 = ind((visall_2(:,0).eq.0.and.visall_2(:,1).eq.2).or.(visall_2(:,0).eq.0.and.visall_2(:,1).eq.3).or.(visall_2(:,0).eq.0.and.visall_2(:,1).eq.4).or.(visall_2(:,0).eq.1.and.visall_2(:,1).eq.4))
    dateindices_3 = ind((visall_3(:,0).eq.0.and.visall_3(:,1).eq.2).or.(visall_3(:,0).eq.0.and.visall_3(:,1).eq.3).or.(visall_3(:,0).eq.0.and.visall_3(:,1).eq.4).or.(visall_3(:,0).eq.1.and.visall_3(:,1).eq.4))
  end if
  ; group6: Nodes("1,2" "1,3" "2,3" "2,4")
  if (g .eq. 5) then
    dateindices_1 = ind((visall_1(:,0).eq.1.and.visall_1(:,1).eq.2).or.(visall_1(:,0).eq.1.and.visall_1(:,1).eq.3).or.(visall_1(:,0).eq.2.and.visall_1(:,1).eq.3).or.(visall_1(:,0).eq.2.and.visall_1(:,1).eq.4))
    dateindices_2 = ind((visall_2(:,0).eq.1.and.visall_2(:,1).eq.2).or.(visall_2(:,0).eq.1.and.visall_2(:,1).eq.3).or.(visall_2(:,0).eq.2.and.visall_2(:,1).eq.3).or.(visall_2(:,0).eq.2.and.visall_2(:,1).eq.4))
    dateindices_3 = ind((visall_3(:,0).eq.1.and.visall_3(:,1).eq.2).or.(visall_3(:,0).eq.1.and.visall_3(:,1).eq.3).or.(visall_3(:,0).eq.2.and.visall_3(:,1).eq.3).or.(visall_3(:,0).eq.2.and.visall_3(:,1).eq.4))
  end if
  ; group7: Nodes("3,3" "4,3" "3,4" "4,4")
  if (g .eq. 6) then
    dateindices_1 = ind((visall_1(:,0).eq.3.and.visall_1(:,1).eq.3).or.(visall_1(:,0).eq.4.and.visall_1(:,1).eq.3).or.(visall_1(:,0).eq.3.and.visall_1(:,1).eq.4).or.(visall_1(:,0).eq.4.and.visall_1(:,1).eq.4))
    dateindices_2 = ind((visall_2(:,0).eq.3.and.visall_2(:,1).eq.3).or.(visall_2(:,0).eq.4.and.visall_2(:,1).eq.3).or.(visall_2(:,0).eq.3.and.visall_2(:,1).eq.4).or.(visall_2(:,0).eq.4.and.visall_2(:,1).eq.4))
    dateindices_3 = ind((visall_3(:,0).eq.3.and.visall_3(:,1).eq.3).or.(visall_3(:,0).eq.4.and.visall_3(:,1).eq.3).or.(visall_3(:,0).eq.3.and.visall_3(:,1).eq.4).or.(visall_3(:,0).eq.4.and.visall_3(:,1).eq.4))
  end if
  ; group8: Nodes("5,3" "6,3" "5,4" "6,4")
  if (g .eq. 7) then
    dateindices_1 = ind((visall_1(:,0).eq.5.and.visall_1(:,1).eq.3).or.(visall_1(:,0).eq.6.and.visall_1(:,1).eq.3).or.(visall_1(:,0).eq.5.and.visall_1(:,1).eq.4).or.(visall_1(:,0).eq.6.and.visall_1(:,1).eq.4))
    dateindices_2 = ind((visall_2(:,0).eq.5.and.visall_2(:,1).eq.3).or.(visall_2(:,0).eq.6.and.visall_2(:,1).eq.3).or.(visall_2(:,0).eq.5.and.visall_2(:,1).eq.4).or.(visall_2(:,0).eq.6.and.visall_2(:,1).eq.4))
    dateindices_3 = ind((visall_3(:,0).eq.5.and.visall_3(:,1).eq.3).or.(visall_3(:,0).eq.6.and.visall_3(:,1).eq.3).or.(visall_3(:,0).eq.5.and.visall_3(:,1).eq.4).or.(visall_3(:,0).eq.6.and.visall_3(:,1).eq.4))
  end if
        
  ; This is the data for this group:
  ; variable 1
  if (all(ismissing(dateindices_1))) then
    group_ndates_1 = 0
    groupfreq_1(g) = 0
    groupcount_1(g) = 0
  end if
  if (.not.all(ismissing(dateindices_1))) then
    group_ndates_1 = dimsizes(dateindices_1)
    groupfreq_1(g) = (int2flt(group_ndates_1)/int2flt(ndates_1))*100.
    groupcount_1(g) = group_ndates_1
  end if
  check1 = check1 + group_ndates_1  ; make sure all dates are counted
  ; variable 2
  if (all(ismissing(dateindices_2))) then
    group_ndates_2 = 0
    groupfreq_2(g) = 0
    groupcount_2(g) = 0
  end if
  if (.not.all(ismissing(dateindices_2))) then
    group_ndates_2 = dimsizes(dateindices_2)
    groupfreq_2(g) = (int2flt(group_ndates_2)/int2flt(ndates_2))*100.
    groupcount_2(g) = group_ndates_2
  end if
  check2 = check2 + group_ndates_2  ; make sure all dates are counted
  ; variable 3
  if (all(ismissing(dateindices_3))) then
    group_ndates_3 = 0
    groupfreq_3(g) = 0
    groupcount_3(g) = 0
  end if
  if (.not.all(ismissing(dateindices_3))) then
    group_ndates_3 = dimsizes(dateindices_3)
    groupfreq_3(g) = (int2flt(group_ndates_3)/int2flt(ndates_3))*100.
    groupcount_3(g) = group_ndates_3
  end if
  check3 = check3 + group_ndates_3  ; make sure all dates are counted

   n = n + 1
   delete(dateindices_1)
   delete(dateindices_2)
   delete(dateindices_3)
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
if (check3.ne.ndates_3) then
 print("Error.  Number of dates is not equal to total number of indices.")
 print("Num. dates: "+ndates_3+"   Tot indices: "+check3)
end if

;;;;;;;;;;
; Calculate if frequencies are statistically different
;;;;;;;;;;
; make new array to plot
test_stat_group_2 = new((/ngroup/),double)
test_stat_group_2 = 0.
freq_diff_group_2 = groupfreq_2 - groupfreq_1 ; get difference in frequencies
test_stat_num_2 = freq_diff_group_2/100.
nf1 = groupfreq_1/100.  ; convert from % to just ratio
nf2 = groupfreq_2/100.
test_stat_den_2 = sqrt((nf2*(1-nf2)/ndates_2) + (nf1*(1-nf1)/ndates_1))
test_stat_den_2 = where(test_stat_den_2.eq.0,test_stat_den_2@_FillValue,test_stat_den_2) ; set 0 to missing to avoid divide by zero error
test_stat_group_2 = test_stat_num_2/test_stat_den_2
test_stat_group_2 = where(ismissing(test_stat_group_2),0,test_stat_group_2)

; make new array to plot
test_stat_group_3 = new((/ngroup/),double)
test_stat_group_3 = 0.
freq_diff_group_3 = groupfreq_3 - groupfreq_1 ; get difference in frequencies
test_stat_num_3 = freq_diff_group_3/100.
nf1 = groupfreq_1/100.  ; convert from % to just ratio
nf3 = groupfreq_3/100.
test_stat_den_3 = sqrt((nf3*(1-nf3)/ndates_3) + (nf1*(1-nf1)/ndates_1))
test_stat_den_3 = where(test_stat_den_3.eq.0,test_stat_den_3@_FillValue,test_stat_den_3) ; set 0 to missing to avoid divide by zero error
test_stat_group_3 = test_stat_num_3/test_stat_den_3
test_stat_group_3 = where(ismissing(test_stat_group_3),0,test_stat_group_3)

; statistical significance meanings:
; if test_stat .gt. 2.58 then it's 95% statistically significant
; if test_stat .ge. 1.96 and .lt. 2.58 then it's 95% statistically significant
; if test_stat .ge. 1.645 and .lt. 1.96 then it's 95% statistically significant
; NOTE: the same is true in reverse for negative values of these numbers

;;;;;;;;;;
; Set array size for group plot
;;;;;;;;;;
; make new arrays
nodefreq_1  = new((/nx_group, ny_group/),"float")
nodecount_1 = new((/nx_group, ny_group/),"integer")
nodefreq_2  = new((/nx_group, ny_group/),"float")
nodecount_2 = new((/nx_group, ny_group/),"integer")
nodefreq_3  = new((/nx_group, ny_group/),"float")
nodecount_3 = new((/nx_group, ny_group/),"integer")
test_stat_2   = new((/nx_group, ny_group/),"double")
freq_diff_2   = new((/nx_group, ny_group/),"float")
test_stat_3   = new((/nx_group, ny_group/),"double")
freq_diff_3   = new((/nx_group, ny_group/),"float")

; assign data to new arrays
nodefreq_1(:,0)  = groupfreq_1(0:nx_group-1)
nodefreq_1(:,1)  = groupfreq_1(nx_group:ngroup-1)
nodecount_1(:,0) = groupcount_1(0:nx_group-1)
nodecount_1(:,1) = groupcount_1(nx_group:ngroup-1)
nodefreq_2(:,0)  = groupfreq_2(0:nx_group-1)
nodefreq_2(:,1)  = groupfreq_2(nx_group:ngroup-1)
nodecount_2(:,0) = groupcount_2(0:nx_group-1)
nodecount_2(:,1) = groupcount_2(nx_group:ngroup-1)
nodefreq_3(:,0)  = groupfreq_2(0:nx_group-1)
nodefreq_3(:,1)  = groupfreq_2(nx_group:ngroup-1)
nodecount_3(:,0) = groupcount_2(0:nx_group-1)
nodecount_3(:,1) = groupcount_2(nx_group:ngroup-1)
test_stat_2(:,0)   = test_stat_group_2(0:nx_group-1)
test_stat_2(:,1)   = test_stat_group_2(nx_group:ngroup-1)
freq_diff_2(:,0)   = freq_diff_group_2(0:nx_group-1)
freq_diff_2(:,1)   = freq_diff_group_2(nx_group:ngroup-1)
test_stat_3(:,0)   = test_stat_group_3(0:nx_group-1)
test_stat_3(:,1)   = test_stat_group_3(nx_group:ngroup-1)
freq_diff_3(:,0)   = freq_diff_group_3(0:nx_group-1)
freq_diff_3(:,1)   = freq_diff_group_3(nx_group:ngroup-1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Plotting the som frequencies")
; Create the frequency plot
  wks = gsn_open_wks("ps",fout)
  gsn_define_colormap(wks,"gsdtol")
  gsn_reverse_colormap(wks)
  colors = gsn_retrieve_colormap(wks) ; load fixed map into "colors"
  additional_colors = (/"forestgreen", "blue", "red", "lightblue", "pink"/)
  gsn_merge_colormaps(wks,colors,additional_colors)

; Get max frequencies
  maxnodefreq_1 = max(nodefreq_1)
  print("Max node frequency for "+tag_1+": "+max(nodefreq_1))
  maxnodefreq_2 = max(nodefreq_2)
  print("Max node frequency for "+tag_2+": "+max(nodefreq_2))
  maxnodefreq_3 = max(nodefreq_3)
  print("Max node frequency for "+tag_3+": "+max(nodefreq_3))
  maxnodefreq = maxnodefreq_1
  minnodefreq = 0.

  ; reverse rows for plotting
  nodefreq_1     = nodefreq_1(:,::-1)
  nodecount_1    = nodecount_1(:,::-1)
  nodefreq_2     = nodefreq_2(:,::-1)
  nodecount_2    = nodecount_2(:,::-1)
  nodefreq_3     = nodefreq_3(:,::-1)
  nodecount_3    = nodecount_3(:,::-1)
  test_stat_2 = test_stat_2(:,::-1)
  freq_diff_2 = freq_diff_2(:,::-1)
  test_stat_3 = test_stat_3(:,::-1)
  freq_diff_3 = freq_diff_3(:,::-1)

; Begin plotting:    
  plot = new(1, graphic)
  dum1  = new((/ngroup/),graphic)
  dum2  = new((/ngroup/),graphic)
  dum3  = new((/ngroup/),graphic)
  dum4  = new((/ngroup/),graphic)
  dum5  = new((/ngroup/),graphic)

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
  res_blank@tiMainFontHeightF              = 0.01
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
  res_txt@txFontHeightF = 0.0275 ;0.013
  res_txt@txFont = 22
  res_txt@txFontColor = "white" ;"black"

; loop through each node to plot
  n = 0
  do y = 0, ny_group - 1
    do x = 0, nx_group - 1
      xp = xx + x
      yp = yy + y
          
      ; Get grey scales(same used for all data sets)
      if (maxnodefreq.ne.0) then
        slope = (32. - 2.) / (maxnodefreq - minnodefreq)  ; use 32 because there are 32 colors
      else
        slope = 0
      end if
      ; variable 1
      gray_index_1 = slope * nodefreq_1(x,y) + 2.
      if(gray_index_1.eq.2.) then
        gray_index_1 = 0. ; to get actual white because our color table is flaky
      end if
      ;; variable 2 --> gray scale if needed...
      ;gray_index_2 = slope * nodefreq_2(x,y) + 2.
      ;if(gray_index_2.eq.2.) then
      ;  gray_index_2 = 0. ; to get actual white because our color table is flaky
      ;end if
      
      ; Color squares
      res_poly@gsFillColor = gray_index_1 ; "white" should auto round
      dum1(n) = gsn_add_polygon(wks, plot, xp, yp, res_poly)
      dum2(n) = gsn_add_polyline(wks, plot, xp, yp, res_poly)

      ; Frequency text:
      res_txt1 = res_txt
      res_txt1@txBackgroundFillColor = gray_index_1 ;"white" "black"
      text_1 = "ERA-I:~C~ "+sprintf("%5.2f",nodefreq_1(x,y))+"%"
      dum3(n) = gsn_add_text(wks, plot, text_1, xp(0)+.5, yp(0)+.75, res_txt1)
      delete(text_1)

      res_txt2 = res_txt
      res_txt2@txFontColor = "black"
      delete(res_txt2@txFontHeightF)
      res_txt2@txFontHeightF = 0.02 ;0.016
      ;; information if NOT statistical significance plotted
      ; res_txt2@txBackgroundFillColor = gray_index_2
      ; text_2 = title_2+":~C~ "+sprintf("%5.2f",nodefreq_2(x,y))+"%"
      ;; get background colors for statistical significance
        res_txt2@txBackgroundFillColor = "white"
      if(test_stat_2(x,y).ge. 0.0).and.(test_stat_2(x,y).lt.1.96) then
        res_txt2@txBackgroundFillColor = "pink"
        res_txt2@txFontColor = "black"
      end if
      if(test_stat_2(x,y).ge.1.96) then
        res_txt2@txBackgroundFillColor = "red"
        res_txt2@txFontColor = "black"
      end if
      if(test_stat_2(x,y).lt. 0.0).and.(test_stat_2(x,y).gt.-1.96) then
        res_txt2@txBackgroundFillColor = "lightblue"
        res_txt2@txFontColor = "black"
      end if
      if(test_stat_2(x,y).le.-1.96) then
        res_txt2@txBackgroundFillColor = "blue"
        res_txt2@txFontColor = "white"
      end if
      text_2 = "WRF50:"+sprintf("%5.2f",freq_diff_2(x,y))+"%"
      dum4(n) = gsn_add_text(wks, plot, text_2, xp(0)+.5, yp(0)+.4, res_txt2)   
      delete(text_2)
          
      res_txt3 = res_txt
      res_txt3@txFontColor = "black"
      delete(res_txt3@txFontHeightF)
      res_txt3@txFontHeightF = 0.02 ;0.016
      ;; information if NOT statistical significance plotted
      ; res_txt2@txBackgroundFillColor = gray_index_2
      ; text_2 = title_2+":~C~ "+sprintf("%5.2f",nodefreq_2(x,y))+"%"
      ;; get background colors for statistical significance
        res_txt3@txBackgroundFillColor = "white"
      if(test_stat_3(x,y).ge. 0.0).and.(test_stat_3(x,y).lt.1.96) then
        res_txt3@txBackgroundFillColor = "pink"
        res_txt3@txFontColor = "black"
      end if
      if(test_stat_3(x,y).ge.1.96) then
        res_txt3@txBackgroundFillColor = "red"
        res_txt3@txFontColor = "black"
      end if
      if(test_stat_3(x,y).lt. 0.0).and.(test_stat_3(x,y).gt.-1.96) then
        res_txt3@txBackgroundFillColor = "lightblue"
        res_txt3@txFontColor = "black"
      end if
      if(test_stat_3(x,y).le.-1.96) then
        res_txt3@txBackgroundFillColor = "blue"
        res_txt3@txFontColor = "white"
      end if
      text_3 = "WRF10:"+sprintf("%5.2f",freq_diff_3(x,y))+"%"
      dum5(n) = gsn_add_text(wks, plot, text_3, xp(0)+.5, yp(0)+.2, res_txt3)   
      delete(text_3)

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
