CLEARSCREEN.
PRINT "Scrpt sat1".

PRINT "== sat prepare Scripts ==".

COPYPATH( "0:/init_sat.ks", "1:/" ). 
COPYPATH( "0:/lib_orb_mnv2.ks", "1:/" ). 
switch to 1.

PRINT "== ActionGroup AG1 for start init ==".

wait until AG1.

print "=== init sat ===".
RUNPATH("init_sat.ks").


print "idle.".
