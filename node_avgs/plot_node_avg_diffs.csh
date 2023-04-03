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

# 8 combinations possible:
# list of possible resolutions/dates/hours to make figures for
set dateres1 = ('wrf10_200511_200703_3h' 'wrf10_200511_200703_6h' \
                'wrf10_200511_200703_3h' 'wrf50_200511_200703_3h' \
                'wrf50_200511_200703_3h' 'wrf50_200511_200703_6h' \
                'wrf50_199701_200712_3h' \
                'wrf10_200511_200703_6h' 'wrf50_200511_200703_6h' \
                'wrf50_199701_200712_6h' 'era_i_200511_200703_6h' )

set dateres1b = ('wrf50_200511_200703_3h' 'wrf50_200511_200703_6h' \
                 'wrf10_200511_200703_6h' 'wrf50_200511_200703_6h' \
                 'wrf50_199701_200712_3h' 'wrf50_199701_200712_6h' \
                 'wrf50_199701_200712_6h' \
                 'era_i_200511_200703_6h' 'era_i_200511_200703_6h' \
                 'era_i_199701_200712_6h' 'era_i_199701_200712_6h' )

##############
# Choose Variables
##############
# list what variable(s) you want the ncl script to output
# from T_eta0 there is not an era_i variable to compare with (yet)
set varcode  = ( 'SLP_anom_diff' 'SLP_diff' 'U10_field_diff' 'U10_speed_diff'\
		 'T_sfc_diff' 'T_2m_diff' 'q_2m_diff' \
                 'Tgrad_2m_diff' 'qgrad_2m_diff' \
		 'U0_diff' 'Tgrad_eta0_diff' 'qgrad_eta0_diff' \
		 'precip_tot_diff' 'WSC_diff' 'LH_diff' 'SH_diff' \
		 'SWUS_diff' 'SWDS_diff' 'LWUS_diff' 'LWDS_diff' \
                 'TurbFlx_diff' 'RadFlx_diff' 'NetFlx_diff' )

##############
# start data type loop
##############                                        
set zero = '0'
set s = 1
while ($s <= 11) # season loop (max: 11) 8 for no era

set datatitle1  = $dateres1[$s]
set datatitle1b = $dateres1b[$s]

# Directory paths and creation
set maindir = '/data3/duvivier/SOM/' # go from scripts file back to the data files
set outdir = $maindir'analysis/figures/node_avgs/'$nx_input'x_'$ny_input'y/'$datatitle1'-vs-'$datatitle1b'/'
mkdir -p $outdir

echo 'Now running for '$outdir

##############
# start variable loop
##############
set q = 1
while ($q <= 22) # var loop (max:22)

##############
# Input into ncl
##############
        echo 'Processing average for '$varcode[$q]' '$datatitle1' and '$datatitle1b
   ncl 'nx_input           = "'$nx_input'"'\
       'ny_input           = "'$ny_input'"' \
       'datatitle1         = "'$datatitle1'"' \
       'datatitle1b        = "'$datatitle1b'"' \
       'varcode            = "'$varcode[$q]'"' \
       /data3/duvivier/SOM/analysis/node_avgs/som_node_avg_diffs.ncl

	   mv *.png $outdir
	   rm *.ps
	
@ q ++
end
@ s ++
end
