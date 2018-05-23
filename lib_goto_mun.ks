//parameter tgt_orb_lan, tgt_orb_inc, tgt_orb_pop, tgt_orb_apo, tgt_orb_per.
////////////////////////////////////////////////
////////////////////////////////////////////////


//============================================
//================ parameters ================

set etrtySpeed to 300.
set paramTgtBody to Body("Mun").
set paramTgtApoapsis to 5000.

//============================================

SAS OFF.
RCS OFF.

//==========================================================================================
//==================================== functions ===========================================
//==========================================================================================
//==========================================================================================

function TuneNodeOrbit {
	DECLARE PARAMETER pManeuver.
	DECLARE PARAMETER pTgtApoapsis.
	
	until (pManeuver:orbit:apoapsis >= pTgtApoapsis) {
		set pManeuver:PROGRADE to pManeuver:PROGRADE + 0.1.
	}
	until (pManeuver:orbit:apoapsis <= pTgtApoapsis) {
		set pManeuver:PROGRADE to pManeuver:PROGRADE - 0.1.
	}
}

function FindBestPrograde4Apo {
	DECLARE PARAMETER pManeuver.
	DECLARE PARAMETER pTgtPlanetApoapsis.
	
	set currDiffApo to abs(N1:orbit:NEXTPATCH:APOAPSIS - pTgtPlanetApoapsis).
	set prevDiffApo to currDiffApo.
	
	until (currDiffApo > prevDiffApo) {
		set pManeuver:PROGRADE to pManeuver:PROGRADE + 0.1.
		set prevDiffApo to currDiffApo.
		if (N1:orbit:HASNEXTPATCH=true) {
			set currDiffApo to abs(N1:orbit:NEXTPATCH:APOAPSIS - pTgtPlanetApoapsis).
		}
	}
	until (currDiffApo > prevDiffApo) {
		set pManeuver:PROGRADE to pManeuver:PROGRADE - 0.1.
		set prevDiffApo to currDiffApo.
		if (N1:orbit:HASNEXTPATCH=true) {
			set currDiffApo to abs(N1:orbit:NEXTPATCH:APOAPSIS - pTgtPlanetApoapsis).
		}
	}
}

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

function calcOrbitTransitImpulse {
	DECLARE PARAMETER tgtBody.
	DECLARE PARAMETER tgtApo.

	//set tgtBody to Body("Mun").
	//set tgtApo to 10000.

	SET N1 TO NODE(TIME:SECONDS+10, 0, 0, 0).
	ADD N1.

	set N1:PROGRADE to 900.
	print "... start node : +10 sec, prograde: 850".

	print "... find start time".

	set minDiffApo to 100000000.
	until (N1:orbit:HASNEXTPATCH=true and N1:orbit:NEXTPATCH:Body = tgtBody and minDiffApo < 10000) {
		set N1:eta to N1:eta + 1.
		TuneNodeOrbit(N1, tgtBody:apoapsis).
		if (N1:orbit:HASNEXTPATCH){
			//FindBestPrograde4Apo(N1, tgtApo).
			set minDiffApo to abs(N1:orbit:NEXTPATCH:PERIAPSIS - tgtApo).
			//print minDiffApo + "(" + N1:orbit:NEXTPATCH:PERIAPSIS + ")".
		}
	}

	until (minDiffApo < 10000) {
		set N1:eta to N1:eta + 0.2.
		TuneNodeOrbit(N1, tgtBody:apoapsis).
		if (N1:orbit:HASNEXTPATCH){
			//FindBestPrograde4Apo(N1, tgtApo).
			set minDiffApo to abs(N1:orbit:NEXTPATCH:PERIAPSIS - tgtApo).
			//print minDiffApo + "(" + N1:orbit:NEXTPATCH:PERIAPSIS + ")".
		}
	}
	print "... eta tune result: minDiffApo= " + minDiffApo + "(" + N1:orbit:NEXTPATCH:PERIAPSIS + ")" .
	return N1.
}


function calculateOrbitEntryNode {
	DECLARE PARAMETER pOrbit.
	// set pOrbit to N1:orbit.

	print "... calclate stop impulse.".
	set periapsTime to ( pOrbit:NEXTPATCHETA + pOrbit:NEXTPATCH:NEXTPATCHETA) /2.
	SET N2 TO NODE(TIME:SECONDS+periapsTime, 0, 0, 0).
	ADD N2.
	print "... fast finding".
	until ( N2:orbit:HASNEXTPATCH=false) {
		set N2:PROGRADE to N2:PROGRADE-1.
	}
	print "... accurate finding".
	/// Find minimum possible APO-PERI diff.
	set diffApoPer to abs(N2:orbit:APOAPSIS -  N2:orbit:PERIAPSIS).
	set prevDiff to diffApoPer.
	until ( diffApoPer > prevDiff ) {
		set N2:PROGRADE to N2:PROGRADE-0.05.
		
		set prevDiff to diffApoPer.
		set diffApoPer to abs(N2:orbit:APOAPSIS -  N2:orbit:PERIAPSIS).
	}
	return N2.
}

//==========================================================================================
//==========================================================================================


print " === Stage 1 (remove all nodes) ================= ".

until (HASNODE=false){
	remove nextnode.
}

print " === Stage 2 (acceleration to transit orbit) ================= ".

print "..... compute Maneuver 1".
set N1 to calcOrbitTransitImpulse( paramTgtBody, paramTgtApoapsis ).

print "..... prepare for Maneuver 1".
set needTimeToBurn to GetNeedTime4Burn(N1).
LOCK STEERING TO N1:BURNVECTOR.

print "..... wait for Maneuver 1 wait until: " + (N1:ETA - (needTimeToBurn/2)).
print ".....     burnTime: " + needTimeToBurn.

wait until (N1:ETA - (needTimeToBurn/2)) < 0 .
print "..... burning Maneuver 1, burnTime: " + needTimeToBurn.
LOCK THROTTLE TO 1.
wait until N1:BURNVECTOR:MAG < 5.
LOCK THROTTLE TO 0.1.
wait until N1:BURNVECTOR:MAG < 0.1.
LOCK THROTTLE TO 0.
UNLOCK STEERING.

print "..... maneuver is over, remove executed node".
remove N1.

print " === Stage 3 (transit to target orbit) ================= ".

print "..... compute Maneuver 1".
set N2 to calculateOrbitEntryNode(ship:orbit).


print "..... prepare for Maneuver 2".
set needTimeToBurn to GetNeedTime4Burn(N2).
LOCK STEERING TO N2:BURNVECTOR.

print "..... wait for Maneuver 2".
wait until (N2:ETA - (needTimeToBurn/2)) < 0 .

print "..... burning Maneuver 2".
LOCK THROTTLE TO 1.
wait until N2:BURNVECTOR:MAG < 5.
LOCK THROTTLE TO 0.1.
wait until N2:BURNVECTOR:MAG < 0.2.
//wait needTimeToBurn.
LOCK THROTTLE TO 0.
UNLOCK STEERING.
remove N2.


print "iddle".

