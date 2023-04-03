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
set dateres = ('wrf10_200511_200703_3h' 'wrf10_200511_200703_6h' \
                'wrf50_200511_200703_3h' 'wrf50_200511_200703_6h' \
                'wrf50_199701_200712_3h' 'wrf50_199701_200712_6h' \
                'era_i_200511_200703_6h' 'era_i_199701_200712_6h')

##############
# Choose Variables
##############
# list what variable(s) you want the ncl script to output
# from WSC there is not an era_i variable to compare with (yet)#13
set varcode  = ('SLP' 'SLP_anom' 'SLP_anom_var'\
		 'T_sfc' 'T_2m' 'q_2m' 'U10_speed' 'U10_field' \
		 'T_sfc_var' 'T_2m_var' 'q_2m_var' 'U10_var' \
		 'Tgrad_2m' 'qgrad_2m' \
		 'WSC' 'UST' 'LH' 'SH' 'LH_var' 'SH_var'\
		 'precip_tot' 'precip_froz' 'precip_tot_var'\
		 'TurbFlx' 'RadFlx' 'NetFlx'\
		 'SWDS' 'SWUS' 'LWDS' 'LWUS' \
		 'SWDS_var' 'SWUS_var' 'LWDS_var' 'LWUS_var' \
		 'T_eta0' 'q_eta0' 'U0' 'U0_var' \
		 'Tgrad_eta0' 'qgrad_eta0' 'seaice')

##############
# start data type loop
##############                                        
set zero = '0'
set s = 1
while ($s <= 6) # season loop (max: 8)

set datatitle1 = $dateres[$s]

# Directory paths and creation
set maindir = '/data3/duvivier/SOM/' # go from scripts file back to the data files
set outdir = $maindir'analysis/figures/node_avgs/'$nx_input'x_'$ny_input'y/'$datatitle1'/'
mkdir -p $outdir

echo 'Now running for '$outdir

##############
# start variable loop
##############
set q = 1
while ($q <= 24) # var loop (max:40)

##############
# Input into ncl
##############
        echo 'Processing average for '$varcode[$q]' '$datatitle1
   ncl 'nx_input           = "'$nx_input'"'\
       'ny_input           = "'$ny_input'"' \
       'datatitle1         = "'$datatitle1'"' \
       'varcode            = "'$varcode[$q]'"' \
       /data3/duvivier/SOM/analysis/node_avgs/som_node_avgs.ncl

	   mv *.png $outdir
	   rm *.ps
	
@ q ++
end
@ s ++
end
