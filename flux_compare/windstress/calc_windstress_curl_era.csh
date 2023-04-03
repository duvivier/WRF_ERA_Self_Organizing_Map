#!/bin/tcsh -f

#
# Script to rename a bunch of files in a directory
#
###########################################################################
echo 'Loading files'
# must run from directory with the files in it!!

foreach wrfout_file(`ls -1 met_em-*.nc`)
    
    set fname1 = `echo $wrfout_file | cut -c1-26`
    echo $fname1
    echo $wrfout_file

   ncl 'fname1             = "'$fname1'"'\
       /data3/duvivier/SOM/analysis/flux_compare/windstress/calc_windstress_curl_add.ncl

end

echo "Complete!"





