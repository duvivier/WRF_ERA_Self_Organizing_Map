#! /bin/tcsh -f

# Script to create node average netcdf files
# This is specific to my som study but could be modified fairly easily
# Alice DuVivier- July 2013
#################################################
##############
# USER INPUTS
##############
# split up the visual file into all three data sets
set nx_input = 7
set ny_input = 5
set master_vals = 'winds0.01_rlen1000000_r4'

# 3 combinations possible:
# list of possible resolutions/dates/hours to make figures for
set dateres1 = ('wrf10_200511_200703_6h' 'wrf50_200511_200703_6h')
set dateres1b = ('wrf50_200511_200703_6h' 'era_i_200511_200703_6h')

set type = 1  
# 1 = correct fluxes
# 2 = nodeavg fluxes

##############
# Choose Variables
##############
# list what variable(s) you want the ncl script to output
# from T_eta0 there is not an era_i variable to compare with (yet)
set varcode  = ('LH' 'SH' 'LH_frac' 'SH_frac' 'TurbFlx' 'Tgrad' 'T_2m' 'T_sfc' 'qgrad' 'q_2m' 'q_sfc' 'U10')

##############
# start data type loop
##############                                        
set zero = '0'
set s = 1
while ($s <= 2) # season loop (max: 2)

set datatitle1  = $dateres1[$s]
set datatitle1b = $dateres1b[$s]

# Directory paths and creation
set maindir = '/data3/duvivier/SOM/' # go from scripts file back to the data files

set outdir = $maindir'analysis/figures/'$nx_input'x_'$ny_input'y/'$datatitle1'-vs-'$datatitle1b'/fluxes-fracice-case'$type'/'

mkdir -p $outdir

echo 'Now running for '$outdir

##############
# start variable loop
##############
set q = 6
while ($q <= 12) # var loop (max:11)

##############
# Input into ncl
##############
        echo 'Processing average for '$varcode[$q]' '$datatitle1' and '$datatitle1b
   ncl 'nx_input           = "'$nx_input'"'\
       'ny_input           = "'$ny_input'"' \
       'master_vals        = "'$master_vals'"' \
       'type               = "'$type'"'\
       'datatitle1         = "'$datatitle1'"' \
       'datatitle1b        = "'$datatitle1b'"' \
       'varcode            = "'$varcode[$q]'"' \
       /data3/duvivier/SOM/analysis/flux_compare/som_diff_all_terms_fluxes_fracice.ncl

	   mv *.png $outdir
	   rm *.ps
	
@ q ++
end
@ s ++
end
