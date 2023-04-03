#! /bin/tcsh
#################################################
# PROGRAM DESCRIPTION: This script creates seaasonal averages of RACM files
# INPUT DATA: 
# OUTPUT DATA: 
# CREATOR: Alice DuVivier - April 2012
#################################################
# this should be set for the type of files processed
set tag = 'era_i'
cd ./era_i
set dir_in = './'

echo 'Starting selection process:'
echo 'Loading files'
##############
# Choose Files
##############
set years = ('1997' '1998' '1999' '2000' '2001' '2002' '2003' '2004' '2005' '2006' '2007')
set seasons = ('NDJFM')

##############
# start loops
set y = 1
while($y <= 11)  # set for the number of years you need to process
    set yy = $years[$y]

echo 'Processing winter average for '$yy
##############
# Set files names
##############

    @ y0 = ($yy - 1)  #fancy math to get previous year's Dec.1
    set fname0 = $dir_in'met_em-'$y0'-11-cf.nc'
    set fname1 = $dir_in'met_em-'$y0'-12-cf.nc'
    set fname2 = $dir_in'met_em-'$yy'-01-cf.nc'
    set fname3 = $dir_in'met_em-'$yy'-02-cf.nc'
    set fname4 = $dir_in'met_em-'$yy'-03-cf.nc'
    
    echo $fname0
    echo $fname1
    echo $fname2
    echo $fname3
    echo $fname4

##############
# use NCO to get seasonal averages
##############
set fout = 'wrf-'$yy'-NDJFM.'$tag'.nc'
    #echo $fout

ncea $fname0 $fname1 $fname2 $fname3 $fname4 $fout

@ y++
end

