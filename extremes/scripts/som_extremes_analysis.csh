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

# list of possible resolutions/dates/hours to make figures for
set dateres1 = ('wrf10_200511_200703_6h' 'wrf50_200511_200703_6h' \
                'era_i_200511_200703_6h')

##############
# Choose Variables
##############
# list what variable(s) you want the ncl script to output
set varcode  = ( 'U10' 'Tgrad' 'qgrad' \
		 'SH' 'LH' 'TurbFlx' \
		 'U_eta0' 'Tgrad_eta0' 'qgrad_eta0' \
                 'SH_eta0' 'LH_eta0' 'TurbFlx_eta0' \
                 'SH_nodeavgs' 'LH_nodeavgs' \
                 'SH_native' 'LH_native')
		                  
##############
# start data type loop
##############                                        
set zero = '0'
set s = 1
while ($s <= 3) # season loop (max: 3)

set datatitle1  = $dateres1[$s]

# Directory paths and creation
set maindir = '/data3/duvivier/SOM/' # go from scripts file back to the data files

set outdir = $maindir'analysis/figures/'$nx_input'x_'$ny_input'y/extremes/from_nodeavgs/'$datatitle1'/'

mkdir -p $outdir

echo 'Now running for '$outdir

##############
# start variable loop
##############
set q = 1
while ($q <= 16) # var loop (max:16)

##############
# Input into ncl
##############
        echo 'Processing average for '$varcode[$q]' '$datatitle1
   ncl 'nx_input           = "'$nx_input'"'\
       'ny_input           = "'$ny_input'"' \
       'datatitle1         = "'$datatitle1'"' \
       'varcode            = "'$varcode[$q]'"' \
       /data3/duvivier/SOM/analysis/flux_compare/som_extremes.ncl

	   mv *.png $outdir
	   rm *.ps
	
@ q ++
end
@ s ++
end
