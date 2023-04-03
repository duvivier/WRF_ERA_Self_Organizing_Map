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
;fname1 = "wrf-2006-01-03_18.green10"
;dir_in = "./"
; ******************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; BEGIN SCRIPT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;
; Find data type and then get directories from this. 
;;;;;;;;;;
   ; get tag telling us what type of data it is:
   tmp_ch = stringtochar(fname1)
   tag = chartostring(tmp_ch(0:2))
   if (tag .eq. "wrf")then
     res = chartostring(tmp_ch(23:24))
   end if
   delete(tmp_ch)

   ; get directories based on tag
   if (tag .eq. "wrf")then
     if (res .eq. "50")then
       dir_in_orig = "/data3/duvivier/SOM/analysis/flux_compare/wrf50_coare_fluxes/orig_files/"
       dir_in_flux = "/data3/duvivier/SOM/analysis/flux_compare/wrf50_coare_fluxes/coare_fluxes-sst/"
       dx = 50.0*1000.0  ; grid spacing in m
     end if
     if (res .eq. "10") then
       dir_in_orig = "/data3/duvivier/SOM/analysis/flux_compare/wrf10_coare_fluxes/orig_files/"
       dir_in_flux = "/data3/duvivier/SOM/analysis/flux_compare/wrf10_coare_fluxes/coare_fluxes-sst/"
       dx = 10.0*1000.0  ; grid spacing in m
     end if
   end if
   if (tag .eq. "met")then
     dir_in_orig = "/data3/duvivier/SOM/analysis/flux_compare/era_i_coare_fluxes/orig_files/"
     dir_in_flux = "/data3/duvivier/SOM/analysis/flux_compare/era_i_coare_fluxes/coare_fluxes-sst/"
     dx = 50.0*1000.0    ; grid spacing in m
   end if

;;;;;;;;;
; load files and data needed
;;;;;;;;;;
   print("Loading wind and flux files and data")
   ; load files that are needed
   if (tag .eq. "wrf")then
     f1_orig = addfile(dir_in_orig+fname1+".cf.nc","r")
   end if
   if (tag .eq. "met")then
     f1_orig = addfile(dir_in_orig+fname1+".cf.nc","r")
   end if
   f1_flux = addfile(dir_in_flux+fname1+"-coare-sst.nc","w")

   ;f1_orig = addfile(dir_in+fname1+".cf.nc","r")
   ;f1_flux = addfile(dir_in+fname1+"-coare-sst.nc","w")

   ; load data needed
   lat2d = f1_orig->lat
   lon2d = f1_orig->lon
   u_10m_tr = f1_orig->u_10m_tr(0,:,:)
   v_10m_tr = f1_orig->v_10m_tr(0,:,:)
   delete(f1_orig)
   tau = f1_flux->tau

   fill = new((/1/),"float")

;;;;;;;;;
; Calculate grid winds
;;;;;;;;;;
print("Calculating grid winds from earth winds")
; We need grid winds because we're using these to find the u/v components
; of windstress (tau) and then doing finite differences with these across
; grid cells. To get grid winds from earth-relative winds, we're going to 
; reverse original rotation from grid to true winds. Follows RASM method:
; tv = (lon2d - stand_lon)*rpd
; u_earth = (u_grid*cos(tv))+(v_grid*sin(tv))
; v_earth = (v_grid*cos(tv))-(u_grid*sin(tv))
; so...
; u_grid = (u_earth*cos(tv))-(v_earth*sin(tv))
; v_grid = (v_earth*cos(tv))+(u_earth*sin(tv))

; set constants
   rpd = 3.14159265/180.
   stand_lon = -114.0   ; this is from the geo_em file for WRF data
   tv = (lon2d - stand_lon)*rpd
   sintv = sin(tv)
   costv = cos(tv)
; do calculations for grid winds
   u_grid = (u_10m_tr*costv)-(v_10m_tr*sintv)
   v_grid = (v_10m_tr*costv)+(u_10m_tr*sintv)
   copy_VarMeta(u_10m_tr, u_grid)
   u_grid@long_name = "u-component at 10m (grid relative)"
   copy_VarMeta(v_10m_tr, v_grid)
   v_grid@long_name = "v-component at 10m (grid relative)"
   
;;;;;;;;;
; Calculate tau components
;;;;;;;;;;
print("Calculating tau_x and tau_y components")
; We need the components of tau for the curl calculation. We have u_grid,
; v_grid, and tau (magnitude), so we can back these out. Use the following
; equations for calculation from basic trigonometry:
; theta = tan-1(v_grid/u_grid)=tan-1(tau_y/tau_x)
; tau_x = tau*cos(theta)
; tau_y = tau*sin(theta)

; do calculations for tau components
  u_grid = where(u_grid .eq. 0.0, fill, u_grid)
  theta = atan(v_grid/u_grid)
  taux = tau * cos(theta)
  tauy = tau * sin(theta)

;;;;;;;;;
; Calculate curl of tau
;;;;;;;;;;
print("Calculating windstress curl")
; Do this by looping through points and doing finite differences. We can't do 
; curl over edge points, so skip these. 
dims = dimsizes(u_grid)
dims_ns = dims(0)   ;y dimension on grid!
dims_we = dims(1)   ;x dimension on grid!

curl_tau = new((/dims_ns,dims_we/),"float")
dum = new((/1/),"float")
fill = dum

do i = 1, dims_we -2            ; loop x dimension, skip edge points!
  do j = 1, dims_ns -2          ; loop y dimension, skip edge points!
    diff_tauy = (tauy(j,i+1)-tauy(j,i-1))/(2*dx)  ; over x dimension
    diff_taux = (taux(j+1,i)-taux(j-1,i))/(2*dx)  ; over y dimension
    curl_tau(j,i) = diff_tauy - diff_taux
    delete(diff_tauy)
    delete(diff_taux)
  end do
end do
copy_VarMeta(tau, curl_tau)
curl_tau@_FillValue = fill
curl_tau@units = "N m-3"
curl_tau@standard_name = "curl_sfc_stress"
curl_tau@long_name = "Wind stress curl"

;;;;;;;;;
; Write wind stress curl to flux file
;;;;;;;;;;
print("Writing wind stress curl")
f1_flux ->curl_tau = curl_tau

print("Done!")
;;;;;;;;;;;;;;;;;;;;;; END script
end
