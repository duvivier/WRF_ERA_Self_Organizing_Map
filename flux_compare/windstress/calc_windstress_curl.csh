#!/bin/tcsh -f

#
# Script to rename a bunch of files in a directory
#
###########################################################################
set tag = 'era_i'

#tag = era_i, set wrfout_file = 'met_em'
#tag = wrf10 or wrf50, set wrfout_file = 'wrf'

echo 'Loading files'

set dir_in = '/data3/duvivier/SOM/analysis/flux_compare/'$tag'_coare_flux/coare_fluxes-sst/'

foreach wrfout_file(`ls -1 `$dir_in`met_em-*.nc`)
    
    #echo "Day:"$wrfout_file
    set year = `echo $wrfout_file | cut -c5-8`
    set month = `echo $wrfout_file | cut -c9-10`
    set day = `echo $wrfout_file | cut -c11-12`
    set hour = `echo $wrfout_file | cut -c13-14`
    set outfile = 'wrf-'$year'-'$month'-'$day'-'$hour'.nc'

    echo $outfile

    cp $wrfout_file $outfile

#ncl 'file_in="'{$wrfout_file}'"' 'file_out="'{$outfile}'"' \


end

rm *20070*.nc

echo "Complete!"





