#!/bin/tcsh -f

#
# Script to rename a bunch of files in a directory
#
###########################################################################


echo 'Loading files'

set dir_in = './'
set dir_out = './'

foreach group_flux_file(`ls -1 group*.nc`)
    
    #echo "Day:"$group_flux_file
    set data = `echo $group_flux_file | cut -c7-30`

    set wind_file = 'group_'$data'-uvwind.nc'

    echo $group_flux_file
    echo $wind_file

   ncks --append ./uvwind/$wind_file $group_flux_file


end

echo "Complete!"





