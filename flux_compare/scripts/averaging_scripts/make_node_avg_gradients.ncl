;***************************************
; PROGRAM DESCRIPTION: This script plots frequency information for
;                      a SOM trained with three data sets
; INPUT DATA: SOM date and visual files for three data types
; OUTPUT DATA: One  plot of frequency comparisons
; CREATOR: Matt Higgins(Oct 2008), Melissa Nigro (Aug 2011)
;          Modified by Alice DuVivier - April 2012
; NOTE: To see full WRF YSU surface layer calculations see
;       flux_compare_wrf-vic-noah.ncl
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
  p = 1  ; wrf10 2005-2007 6hrly
;  p = 3  ; wrf50 2005-2007 6hrly
;  p = 6  ; erai 2005-2007 6hrly
; ******************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; BEGIN SCRIPT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Running SOM frequency plot")
;;;;;;;;;;
; set input file information
;;;;;;;;;;
; wrf10 data
if (p .eq. 1) then
  datatitle_1 = "wrf10_200511_200703"
  tag_0 = "wrf10"
  tag_1 = "wrf"
  tag_2 = "green10"
end if
; wrf50 data
if (p .eq. 3) then
  datatitle_1 = "wrf50_199701_200712"
  tag_0 = "wrf50"
  tag_1 = "wrf"
  tag_2 = "green50"
end if
; era_i data
if (p .eq. 6) then
  datatitle_1 = "era_i_199701_200712"
  tag_0 = "era_i"
  tag_1 = "met_em"
  tag_2 = "era_i"
end if
  datefile_1 = "/data3/duvivier/SOM/training/dates/"+datatitle_1+"_dates.txt"
  visfile_1  = "/data3/duvivier/SOM/training/som_"+nx_input+ny_input+"/master/"+datatitle_1+"_"+master_vals+".vis"

;;;;;;;;;;
; Load information for each file type
;;;;;;;;;;
; Dates from data array index and visual file that places each date at a given node
print("Loading dates and SOM visual data")
dates_1 = ndtooned(readAsciiTable(datefile_1,1,"string",0)) ; ignores no rows
ndates_1 = dimsizes(dates_1)
dateschar_1 = stringtochar(dates_1)
yearmonth = chartostring(dateschar_1(:,0:5))
yy = chartostring(dateschar_1(:,0:3))
mm = chartostring(dateschar_1(:,4:5))
dd = chartostring(dateschar_1(:,6:7))
hh = chartostring(dateschar_1(:,8:9))

vis_1 = new((/ndates_1,3/),integer)
vis_1 = readAsciiTable(visfile_1,3,"integer",1) ; ignores first row

; create filenames array
files_1 = new((/ndates_1/),string)
if (p .eq. 6 ) then  ; if it's era_i for the short period need the flux files (don't have other flux files yet)
  files_1 = "/data3/duvivier/SOM/DATA/"+tag_0+"/"+yearmonth+"/"+tag_1+"-"+yy+"-"+mm+"-"+dd+"_"+hh+"."+tag_2+".all.cf.nc"
else
  files_1 = "/data3/duvivier/SOM/DATA/"+tag_0+"/"+yearmonth+"/"+tag_1+"-"+yy+"-"+mm+"-"+dd+"_"+hh+"."+tag_2+".cf.nc"
end if

delete(ndates_1)

;;;;;;;;;;
; Get just dates we want
;;;;;;;;;;
  hr_sub = (/"00","06","12","18"/)
  ym_sub = (/"200511","200512","200601","200602","200603","200611","200612","200701","200702","200703"/)
;;;;;;;;;;
; Loop through plotting options
;;;;;;;;;;
if (p .eq. 1)
  print("2005-2007 wrf10 6hrly")
  dateind_1 = ind(hh.eq.hr_sub(0) .or. hh.eq.hr_sub(1) .or. hh.eq.hr_sub(2) .or. hh.eq.hr_sub(3))
  visall_1 = vis_1(dateind_1,:)
  filesall_1 = files_1(dateind_1)
  fout = "wrf10_200511_200703_6h-gradients"
end if
if (p .eq. 3)
  print("2005-2007 wrf50 6hrly")
  dateind_1 = ind(yearmonth.eq.ym_sub(0) .or. yearmonth.eq.ym_sub(1) .or. yearmonth.eq.ym_sub(2) .or. yearmonth.eq.ym_sub(3) .or. yearmonth.eq.ym_sub(4) .or. yearmonth.eq.ym_sub(5) .or. yearmonth.eq.ym_sub(6) .or. yearmonth.eq.ym_sub(7) .or. yearmonth.eq.ym_sub(8) .or. yearmonth.eq.ym_sub(9))
  visall_1_tmp = vis_1(dateind_1,:)
  filesall_1_tmp = files_1(dateind_1)
  hh_tmp = hh(dateind_1)
  delete(dateind_1)
  dateind_1 = ind(hh_tmp.eq.hr_sub(0) .or. hh_tmp.eq.hr_sub(1) .or. hh_tmp.eq.hr_sub(2) .or. hh_tmp.eq.hr_sub(3))
  visall_1 = visall_1_tmp(dateind_1,:)
  filesall_1 = filesall_1_tmp(dateind_1)
  delete(visall_1_tmp)
  delete(filesall_1_tmp)
  delete(hh_tmp)
  fout = "wrf50_200511_200703_6h-gradients"
end if
if (p .eq. 6)
  print("2005-2007 era_i 6hrly")
  dateind_1 = ind(yearmonth.eq.ym_sub(0) .or. yearmonth.eq.ym_sub(1) .or. yearmonth.eq.ym_sub(2) .or. yearmonth.eq.ym_sub(3) .or. yearmonth.eq.ym_sub(4) .or. yearmonth.eq.ym_sub(5) .or. yearmonth.eq.ym_sub(6) .or. yearmonth.eq.ym_sub(7) .or. yearmonth.eq.ym_sub(8) .or. yearmonth.eq.ym_sub(9))
  visall_1 = vis_1(dateind_1,:)
  filesall_1 = files_1(dateind_1)
  fout = "era_i_200511_200703_6h-gradients"
end if

ndates_1 = dimsizes(filesall_1)

;;;;;;;;;;
; Calculate averages data
;;;;;;;;;;
; Calculate node counts and frequencies for comparison of interest
  nx_node = stringtoint(nx_input)
  ny_node = stringtoint(ny_input)
  nnode = nx_node*ny_node

  fill = new((/1/),"float")

; Set constants
   zu = 10.          ; Height of wind measurement
   zt = 2.           ; Height of temperature measurement
   zq = 2.           ; Height of moisture measurement
   zi = 600.         ; Height of PBL (taken from COARE algorithm for assumed height)
   Rgas = 287.1      ; Dry gas constant J/(kg*K)
   cpa = 1004.67     ; Specific heat at constant pressure J/(kg*K) 
   Beta = 1.2        ; Constant from COARE algorithm
   von = 0.4         ; Von Karman constant (unitless)
   c1=0.0052790414   ; constant for gravity calculations
   c2=0.0000232718   ; constant for gravity calculations
   c3=0.0000001262   ; constant for gravity calculations
   c4=0.0000000007   ; constant for gravity calculations
   tdk = 273.16      ; conversion between K and C

check1 = 0
n = 0
;;;;;;;;;
; calculate Node averages for flux variables
;;;;;;;;;;
; loop through each node
do y = 0, ny_node - 1
 do x = 0, nx_node - 1

   print("node: "+x+","+y)
  ; These are the dates for this particular node:
   dateindices_1 = ind(visall_1(:,0).eq.x.and.(visall_1(:,1).eq.y))
   if (.not.all(ismissing(dateindices_1))) then
     files_sub = filesall_1(dateindices_1)
   else
     print("All files missing for node")
   end if

  ; Load files that correspond to this node
   dim_files = dimsizes(files_sub)
   node_files = addfiles(files_sub,"r")

  ; Create new file that corresponds to this node for averages/variances
   fout_node = "node_"+x+"x_"+y+"y_"+fout
   node_avg = addfile("./"+fout_node+".nc","c")

  ; files that do not need to be averaged
   wrf = addfile(files_sub(0),"r")
   Z_sfc = wrf->Z_sfc
   lat = wrf->lat
   lon = wrf->lon

  ; write to new average file
   node_avg ->lat = lat
   print("latitude")
   node_avg ->lon = lon
   print("longitude") 
   node_avg ->Z_sfc = Z_sfc
   print("Terrain height")
   ;if (tag_1 .eq. "wrf") then
   ;  LandMask = wrf->LandMask(south_north|: , west_east|we_st:we_ed)
   ;  node_avg ->LandMask = LandMask
   ;  delete(LandMask)
   ;end if
   delete(wrf)
   ;delete(lat)
   delete(lon)
   delete(Z_sfc)

  ; Calculate gravity based on latitude
   dum=sin(lat*(3.14159/180.));
   grav = 9.7803267715*(1+c1*dum^2+c2*dum^4+c3*dum^6+c4*dum^8)
   node_avg ->grav = grav
   delete(dum)
   delete(lat)

  ; write the number of files going into the average for later statistical tests
   node_avg ->number_dates = dim_files

  ; Go through each type of surface variable and calculate average and variance
  ;; Sea Ice Concentration
   SeaIce = addfiles_GetVar(node_files,files_sub,"SeaIce")
   SeaIce_avg = dim_avg_n_Wrap(SeaIce,0)
   SeaIce_var = dim_variance_n_Wrap(SeaIce,0)
   node_avg ->SeaIce_avg = SeaIce_avg
   node_avg ->SeaIce_var = SeaIce_var
   print("Seaice")
   delete(SeaIce) 
   delete(SeaIce_avg)
   delete(SeaIce_var)

;;;;;;;;;
; Do FLUX CALCULATIONS
;;;;;;;;;
  ;; winds at 10m
   u_10m = addfiles_GetVar(node_files,files_sub,"u_10m_tr")
   v_10m = addfiles_GetVar(node_files,files_sub,"v_10m_tr")
   u = sqrt(u_10m^2 + v_10m^2)
   copy_VarMeta(u_10m, u)
   delete(u_10m)
   delete(v_10m)
   u@long_name = "10m wind speed"
   wspd_10m_avg = dim_avg_n_Wrap(u,0)
   wspd_10m_var = dim_variance_n_Wrap(u,0)
   node_avg ->wspd_10m_avg = wspd_10m_avg
   node_avg ->wspd_10m_var = wspd_10m_var
   print("10m wind speed")
   delete(u)
   delete(wspd_10m_avg)
   delete(wspd_10m_var)

  ;; Load surface and 2m variables
   P  = addfiles_GetVar(node_files,files_sub,"p_sfc")
   ts = addfiles_GetVar(node_files,files_sub,"T_sfc")
   ts = ts - tdk
   ts@units = "C"
   t  = addfiles_GetVar(node_files,files_sub,"T_2m")
   if (tag_1 .eq. "met_em")then
   else
     t = t - tdk
     t@units = "C"
   end if
   q = addfiles_GetVar(node_files,files_sub,"q_2m")
   q = q*1000. 
   q@units = "g/kg"

;;;;;;;;;
; Set Constants and Calculate variables that use WRF info
;;;;;;;;;;
; Calculate variables from WRF vars
  ; surface saturated mixing ratio
   es = 6.112*exp(17.502*ts/(ts+240.97))*0.98*(1.007+3.46E-6*P)
   qs = es*621.97/(P-0.378*es)
   copy_VarMeta(q, qs)
   delete(es)

;;;;;;;;;
; Write variables at sfc and 2m
;;;;;;;;;;

  ;; Pressure at surface
   P_sfc_avg = dim_avg_n_Wrap(P,0)
   P_sfc_var = dim_variance_n_Wrap(P,0)
   node_avg ->P_sfc_avg = P_sfc_avg
   node_avg ->P_sfc_var = P_sfc_var  
   print("Pressure at surface")
   delete(P)
   delete(P_sfc_avg)
   delete(P_sfc_var)

  ;; Temperature gradient and sfc and 2m variables
   T_grad = (ts - t)
   copy_VarMeta(t,T_grad)
   T_grad@long_name = "Temperature gradient (sfc - 2m)"
   T_grad@standard_name = "Temp_grad"
   T_grad_avg = dim_avg_n_Wrap(T_grad,0)
   T_grad_var = dim_variance_n_Wrap(T_grad,0)   
   node_avg ->T_grad_avg = T_grad_avg
   node_avg ->T_grad_var = T_grad_var
   print("Temperature gradient")
   delete(T_grad) 
   delete(T_grad_avg)
   delete(T_grad_var)
   T_sfc_avg = dim_avg_n_Wrap(ts,0)
   T_sfc_var = dim_variance_n_Wrap(ts,0)
   node_avg ->T_sfc_avg = T_sfc_avg
   node_avg ->T_sfc_var = T_sfc_var  
   T_2m_avg = dim_avg_n_Wrap(t,0)
   T_2m_var = dim_variance_n_Wrap(t,0)
   node_avg ->T_2m_avg = T_2m_avg
   node_avg ->T_2m_var = T_2m_var
   print("Temperature at surface and 2m")
   delete(ts)
   delete(t)
   delete(T_sfc_avg)
   delete(T_sfc_var)
   delete(T_2m_avg)
   delete(T_2m_var)

  ;; Mixing Ratio gradient and sfc and 2m variables
   q_grad = (qs - q)
   copy_VarMeta(qs,q_grad)
   q_grad@long_name = "Mixing Ratio gradient (sfc - 2m)"
   q_grad@standard_name = "Mix_Rad_grad"
   q_grad_avg = dim_avg_n_Wrap(q_grad,0)
   q_grad_var = dim_variance_n_Wrap(q_grad,0)   
   node_avg ->q_grad_avg = q_grad_avg
   node_avg ->q_grad_var = q_grad_var
   print("Mixing Ratio gradient")
   delete(q_grad) 
   delete(q_grad_avg)
   delete(q_grad_var)
   q_sfc_avg = dim_avg_n_Wrap(qs,0)
   q_sfc_var = dim_variance_n_Wrap(qs,0)
   node_avg ->q_sfc_avg = q_sfc_avg
   node_avg ->q_sfc_var = q_sfc_var  
   q_2m_avg = dim_avg_n_Wrap(q,0)
   q_2m_var = dim_variance_n_Wrap(q,0)
   node_avg ->q_2m_avg = q_2m_avg
   node_avg ->q_2m_var = q_2m_var
   print("Mixing Ratio at surface and 2m")
   delete(qs)
   delete(q)
   delete(q_sfc_avg)
   delete(q_sfc_var)
   delete(q_2m_avg)
   delete(q_2m_var)

  ;; add up total number of days
  check1 = check1 + dim_files
  n = n + 1

  ;; delete variables to use again
  delete(fout_node)
  delete(node_avg)
  delete(dim_files)
  delete(node_files)
  delete(dateindices_1)
  delete(files_sub)

 end do
end do

; Check the dates and print error messages if calculation fails
if (check1.ne.ndates_1) then
 print("Error.  Number of dates is not equal to total number of indices.")
 print("Num. dates: "+ndates_1+"   Tot indices: "+check1)
end if

;;;;;;;;;;;;;;;;;;;;;; END script
end
