#! /bin/csh -f

echo 'Time: ' `/bin/date -u +'%m/%d/%Y %T'`

#################################################
# Post processes WRF output and includes only
# eta level variables
#################################################
set dir_in = '/data3/duvivier/SOM/analysis/flux_compare/wrf10_coare_fluxes/orig_files/'
set dir_out = '/data3/duvivier/SOM/analysis/flux_compare/wrf10_coare_fluxes/coare_fluxes/'

set q = 1
foreach wrfout_file (`ls -1 $dir_in`)

    echo "Let's go for: "$wrfout_file

    ### BE SURE TO CHANGE THE CUT VALUES FOR YOUR CASENAME ###
    set fname1  = `echo $wrfout_file | cut -c1-25`

    ncl 'fname1="'{$fname1}'"' \
        'dir_in="'{$dir_in}'"' \
        'dir_out="'{$dir_out}'"'  \
        /data3/duvivier/SOM/analysis/flux_compare/make_wrf10_singletime_fluxes_coare.ncl

end

