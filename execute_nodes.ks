SAS OFF.
RCS OFF.

//==========================================================================================
//==================================== functions ===========================================
//==========================================================================================
//==========================================================================================

function GetNeedTime4Burn{
	DECLARE PARAMETER pManeuver.
	set deltav to pManeuver:DELTAV:MAG.
	
	list engines in engList.
	set e to engList[0].
	set needTime to deltav / ( e:maxthrust / ship:mass).

	print " . . . . . . GetNeedTime4Burn".
	print "               maxthrust " + e:maxthrust.
	print "               deltav    " + deltav.
	print "               mass      " + ship:mass.
	print "               needTime  " + needTime.
	return needTime.	
}

//==========================================================================================
//==========================================================================================


print " === Execute maneuver nodes ================= ".

until (HASNODE = false) {
	set N1 to NEXTNODE.
	set needTimeToBurn to GetNeedTime4Burn(N1).
	LOCK STEERING TO N1:BURNVECTOR.
	
	print "..... prepare for Maneuver 1".
	print "..... wait for Maneuver 1 wait until: " + (N1:ETA - (needTimeToBurn/2)).
	print ".....     burnTime: " + needTimeToBurn.
	
	wait until (N1:ETA - (needTimeToBurn/2)) < 0 .
	print "..... burning Maneuver 1, burnTime: " + needTimeToBurn.
	LOCK THROTTLE TO 1.
	wait until N1:BURNVECTOR:MAG < 5.
	LOCK THROTTLE TO 0.1.
	wait until N1:BURNVECTOR:MAG < 0.2.
	LOCK THROTTLE TO 0.
	UNLOCK STEERING.

	remove nextnode.
}


print "iddle".
