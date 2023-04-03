#! /bin/tcsh -f

# Script to create node average netcdf files
# This is specific to my som study but could be modified fairly easily
# Alice DuVivier- July 2013
#################################################
##############
# USER INPUTS
##############
# 3 combinations possible:
# list of possible resolutions/dates/hours to make figures for
set dateres1 = ('wrf10_200511_200703_6h' 'wrf10_200511_200703_6h' \
                'wrf50_200511_200703_6h')

set dateres1b = ('wrf50_200511_200703_6h' 'era_i_200511_200703_6h' \
                 'era_i_200511_200703_6h')

##############
# Choose Variables
##############
# list what variable(s) you want the ncl script to output
# from T_eta0 there is not an era_i variable to compare with (yet)
set varcode  = ( 'SLP_anom_diff' 'SLP_diff' 'U10_field_diff' 'U10_speed_diff' \
		 'T_sfc_diff' 'T_2m_diff' 'q_2m_diff' \
                 'LH_diff' 'SH_diff' 'TurbFlx_diff' \
		 'SW_net_diff' 'LW_net_diff' 'RadFlx_diff' \
                 'NetFlx_diff' 'precip_tot_diff')

##############
# start data type loop
##############                                        
set zero = '0'
set s = 1
while ($s <= 3) # season loop (max: 3)

set datatitle1  = $dateres1[$s]
set datatitle1b = $dateres1b[$s]

# Directory paths and creation
set maindir = '/data3/duvivier/SOM/' # go from scripts file back to the data files
set outdir = $maindir'analysis/figures/winter_avg_diffs/'$datatitle1'-vs-'$datatitle1b'/'
mkdir -p $outdir

echo 'Now running for '$outdir

##############
# start variable loop
##############
set q = 1
while ($q <= 15) # var loop (max:15)

##############
# Input into ncl
##############
        echo 'Processing average for '$varcode[$q]' '$datatitle1' and '$datatitle1b
   ncl 'datatitle1         = "'$datatitle1'"' \
       'datatitle1b        = "'$datatitle1b'"' \
       'varcode            = "'$varcode[$q]'"' \
       /data3/duvivier/SOM/analysis/avgs_compared/som_avg_diffs.ncl

	   mv *.png $outdir
	   rm *.ps
	
@ q ++
end
@ s ++
end
