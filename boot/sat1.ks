CLEARSCREEN.
PRINT "Scrpt sat1".

PRINT "== sat prepare Scripts ==".

COPYPATH( "0:/init_sat.ks", "1:/" ). 
COPYPATH( "0:/lib_orb_mnv2.ks", "1:/" ). 
COPYPATH( "0:/lib_goto_mun.ks", "1:/" ). 
COPYPATH( "0:/engine_land.ks", "1:/" ). 
COPYPATH( "0:/execute_nodes.ks", "1:/" ). 
COPYPATH( "0:/boot/mbr_sat_1.ks", "1:/" ). 

set CORE:BOOTFILENAME to "execute_nodes.ks".
reboot.
