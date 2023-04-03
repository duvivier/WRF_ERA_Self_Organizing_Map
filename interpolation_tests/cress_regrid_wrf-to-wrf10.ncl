;***************************************
; PROGRAM DESCRIPTION: This NCL script regrids curvilinear WRf output
;                      from any domain to a 10km WRF domain using 
;                      a Cressman Weighting scheme
; INPUT DATA: WRF geo_em.d01.nc files for 10km grid spacing and another spacing
; OUTPUT DATA: two text files of indicies and weights for interpolation,
;              a plot of the terrain of each WRF domain and the difference
; Note: No cshell is written to loop this. Inputs are specified manually below.
; CREATOR: Alice DuVivier - February 2011
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************

begin
; MANUAL INPUTS
; (area of influence for weighting)
cressrad      = 45.  ; cressman radius in km (50->10km)

; inputs for file
dir1 = "/data3/duvivier/SOM/DATA/era_i/200701/"
dir2 = "/data3/duvivier/SOM/DATA/WRF10/200701/"
outdir = "./"
fname1 = "met_em-2007-01-01_00.era_i.cf"  ;"wrf-2007-01-01_00.green50.cf"     ; file with original grid
fname2 = "wrf-2007-01-01_00.green10.cf"     ; file with grid to interpolate to
title1 = "era_i" ;"WRF50"
title2 = "WRF10"

; BEGIN SCRIPT
; Check for input information:
  if(.not.any(isvar("dir1").and.isvar("dir2") \
              .and.isvar("fname1").and.isvar("fname2") \
              .and.isvar("title1").and.isvar("title2") \
              )) then
    print("Can't find all input information!")
  end if

; set outdir and fout names
outdir = "./"
fout   = outdir+"weightings_"+title1+"_to_"+title2
print("Interpolating from "+title1+" to  "+title2)

;;;;;;;;;;
; add data
;;;;;;;;;;

; Load lower resolution topography:
  f1 = addfile(dir1 + fname1 + ".nc","r")
  lat2d_1 = f1->lat
  lon2d_1 = f1->lon 
  lat1d_1 = ndtooned(lat2d_1)       ; convert arrays to 1D
  lon1d_1 = ndtooned(lon2d_1)

; Load higher resolution info lat/lon
  f2 = addfile(dir2 + fname2 + ".nc","r")
  lat2d_2 = f2->lat
  lon2d_2 = f2->lon
  lat1d_2 = ndtooned(lat2d_2)       ; convert arrays to 1D
  lon1d_2 = ndtooned(lon2d_2)

  ; get dimensions
  dims_2 = dimsizes(lat2d_2)       ; get lat/lon dimensions from second domain
  n_sn = dims_2(0)                 ; get south/north points
  n_we = dims_2(1)                 ; get west/east points
  n_tot = n_sn*n_we                ; get total number of points in high res domain

;;;;;;;;;;
; regrid the first file to second file resolution
;;;;;;;;;;

; create weights and appropriate indicies for Cressman interpolation
  max_indices = 5                          ; maximum number of points that can be included in weighted avg 
  interp_ind = new((/n_tot,max_indices/), "integer")  ; make array to put index values in
  interp_ind!0 = "old_index"                          ; name the dimensions of the array
  interp_ind!1 = "new_indices"
  interp_wgt = new((/n_tot,max_indices/), "float")    ; make array for weights
  interp_wgt!0 = "old_index"
  interp_wgt!1 = "new_weightings"

; run loop
  index = 0          ; set first index
do i = 0, n_tot-1

 ; get great circle distance between the different grids in km
  dist = gc_latlon(lat1d_2(i),lon1d_2(i),lat1d_1,lon1d_1,2,4) 
 ; if the great circle yields some NaNs (topography related, etc)
  if (any(isnan_ieee(dist))) then       
    nreplacements = num(isnan_ieee(dist))  ; find index of NaN
    replace_ieeenan(dist,0.,0)             ; replace the NaN with 0
    print("replaced "+nreplacements+" NaN(s) with 0 at i = "+i) ; print that there were replacements made
  end if

   ; If the minimum radius is greater than the cressman radius then it won't work (all points outside sphere of influence.)
  if (min(dist).gt.cressrad) then        
    print("Minimum distance is greater than Cressman radius at i " + i) 
    print("Continuing on to next grid point")
  else
    indicies = ind(dist.lt.cressrad)    ; find the indicies where the distance is within the cressman radius
    weight = (cressrad^2 - dist(indicies)^2) / (cressrad^2 + dist(indicies)^2)  ; give each index a weight
  ; save calculated indicies and weighting factors for future use
    n_indicies = dimsizes(indicies)
    interp_ind(i,0:n_indicies-1) = (/indicies/)  ; put the indicies into an array to save
    interp_wgt(i,0:n_indicies-1) = (/weight/)    ; put the weights into an array to save
    delete(indicies)
    delete(weight)
  end if

  ; counter
  if(i%100.eq.0) then
    print("created weighting "+i+" of "+n_tot)
  end if
  index = index + 1                             ; increase the index
end do


;;;;;;  
; write weights and indices files
;;;;;; 
print("Writing out weightings")
 
weightout = addfile(fout+".nc","c")
weightout->interp_ind = interp_ind
weightout->interp_wgt = interp_wgt
fileatts = True
fileatts@title = "Weightings for 50km to 10km regridding."
fileatts@cressrad = cressrad
fileattdef(weightout,fileatts)

; Write weights and indices to text files
;  fout1   = outdir+"indicies_"+title1+"_to_"+title2      ; MAKES 1D ARRAY OF indicies and weights
;  fout2   = outdir+"weights_"+title1+"_to_"+title2
;  asciiwrite(fout1+".txt",interp_ind)  ; write indices to text file
;  asciiwrite(fout2+".txt",interp_wgt)  ; write weights to text file

;;;;;;;;;;;;;;;;;;;;;; END script
end
