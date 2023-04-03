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

# 3 combinations possible:
# list of possible resolutions/dates/hours to make figures for
set dateres1 = ('wrf10_200511_200703_6h' 'wrf10_200511_200703_6h' \
                'wrf50_200511_200703_6h')

set dateres2 = ('wrf50_200511_200703_6h' 'era_i_200511_200703_6h' \
                 'era_i_200511_200703_6h')

##############
# Choose Variables
##############
# list what variable(s) you want the ncl script to output
# from T_eta0 there is not an era_i variable to compare with (yet)
set varcode  = ( 'LH' 'SH' 'U10' )
set percentiles = ( 'max' '99' '95' '90' '75' '50')

##############
# start data type loop
##############                                        
set zero = '0'
set s = 1
while ($s <= 3) # season loop (max: 2)

set datatitle1  = $dateres1[$s]
set datatitle2 = $dateres2[$s]

# Directory paths and creation
set maindir = '/data3/duvivier/SOM/' # go from scripts file back to the data files

set outdir = $maindir'analysis/figures/'$nx_input'x_'$ny_input'y/extremes/'$datatitle1'-vs-'$datatitle2'/'

mkdir -p $outdir

echo 'Now running for '$outdir

##############
# start variable loop
##############
set q = 1
while ($q <= 3) # var loop (max:3)

set p = 1
while ($p <= 6) # percentile loop (max: 6)

set percentile = $percentiles[$p]

##############
# Input into ncl
##############
        echo 'Processing average for '$varcode[$q]' '$datatitle1' and '$datatitle2
   ncl 'nx_input           = "'$nx_input'"'\
       'ny_input           = "'$ny_input'"' \
       'datatitle1         = "'$datatitle1'"' \
       'datatitle2        = "'$datatitle2'"' \
       'varcode            = "'$varcode[$q]'"' \
       'percentile         = "'$percentile'"' \
       /data3/duvivier/SOM/analysis/extremes/som_percentiles_compare.ncl

	   mv *.png $outdir
	   rm *.ps
@ p ++
end	
@ q ++
end
@ s ++
end
