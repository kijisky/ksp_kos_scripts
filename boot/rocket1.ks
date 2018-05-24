CLEARSCREEN.
PRINT "Scrpt rocket1".

PRINT "== Scripts loading".

switch to 0.
COPYPATH( "0:/orbit3.ks", "1:/" ). 
COPYPATH( "0:/orbit_start.ks", "1:/" ). 
COPYPATH( "0:/orbit_land.ks", "1:/" ). 

PRINT " .... 20 secs for start ".
wait 10.
PRINT " .... 10 secs for start ".
wait 5.
PRINT " .... 5 ".
wait 1.
PRINT " .... 4 ".
wait 1.
PRINT " .... 3 ".
wait 1.
PRINT " .... 2 ".
wait 1.
PRINT " .... 1 ".
wait 1.

RUNPATH("orbit3.ks").

when AG1 then {
	PRINT "Run starting sequence".
	PRESERVE.
}