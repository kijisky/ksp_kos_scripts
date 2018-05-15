//============================================
//================ parameters ================

set etrtySpeed to 300.

//============================================

function calcVelocityForAltitude{
	DECLARE PARAMETER pAltitude.
	// set pAltitude to ship:ALTITUDE.
	// set pVelocity to ship:VELOCITY:SURFACE:MAG.
	
	set calcThrust to e:maxthrust * 0.7.
	set radius to body:RADIUS.
	set gravForce to (ship:MASS * BODY:mu) / (radius * radius).
	set meanEngineForce to calcThrust - gravForce.
	
	/// v = a*t
	/// S = a * (t*t) / 2
	/// v = sqrt( 2 * S * a )
	///   a = F / m
	if (pAltitude < 0) {
		set pAltitude to 0.
	}
	set tgtSpeed to SQRT( 2 * pAltitude * meanEngineForce / ship:mass ).
	return tgtSpeed.
}

function gravEngineThrust {
	set radius to body:RADIUS + ship:ALTITUDE.
	set gravForce to (ship:MASS * BODY:mu) / (radius * radius).
	
	set gravThrust to gravForce / e:maxthrust.
	return gravThrust.
}

function printDiagnosticInfo{
	print "------------ DIAG ------------".
	print "... altitude   : " + floor(ALT:RADAR).
	print "... velocity   : " + floor(ship:VELOCITY:SURFACE:MAG).
	print "... v-speed : " + floor(ship:VERTICALSPEED).
	print "... h-speed : " + floor(GROUNDSPEED).
	print "... longitude  : " + ship:longitude.
	print "------------------------------".
	
}

function printLandingInfoString{
	set alt1    to floor(ALT:RADAR).
	set vel1    to floor(ship:VELOCITY:SURFACE:MAG).
	set calcSpd to floor(calcVelocityForAltitude(ALT:RADAR)).
	print "..... alt: " +alt1+ ", spd: ," +vel1+ "  calcSpd:" +calcSpd.
}

function calcLandingLonDelta{
	set vParabolaParam to 76.
	set dLon to SQRT( ALT:RADAR / vParabolaParam).
	return dLon.
}

//============================================
//============================================
list engines in engList.
set e to engList[0].



PRINT "====== HOVER SLAP SUBPROGRAMM ===========".

printDiagnosticInfo().

PRINT "====== SATAGE 1 (calculations) ===========".

PRINT "====== SATAGE 2 (wait until entry point) ===========".

print "..... entry point going to be now... no calc".

PRINT "====== SATAGE 3 (entry burn) ===========".

if (ship:VELOCITY:SURFACE:MAG > etrtySpeed) {
	lock steering to retrograde .
	print "..... steer-retrograde, wait for orientation".
	wait 5.
	print "..... do entry burn".
	LOCK THROTTLE TO 1.
	wait until ship:VELOCITY:SURFACE:MAG < etrtySpeed.
	LOCK THROTTLE TO 0.
}

PRINT "====== SATAGE 4 (wait until suicide burn) ===========".


set lastDiff to 10000.
until calcVelocityForAltitude(ALT:RADAR) < ship:VELOCITY:SURFACE:MAG {
	set curDiff to calcVelocityForAltitude(ALT:RADAR) - ship:VELOCITY:SURFACE:MAG.
	if abs(lastDiff / curDiff ) > 2 {
		set lastDiff to curDiff.
		printLandingInfoString().
	}
	wait 0.
}
printLandingInfoString().

PRINT "====== SATAGE 5 (suicide burn) ===========".

printDiagnosticInfo().
print "... predict landing longitude: " + (ship:longitude + calcLandingLonDelta()).

print "..... gear on".
print "..... steering retrograde".



GEAR ON.
set th to 0.
LOCK THROTTLE TO th.
lock steering to retrograde.

//until ship:VELOCITY:SURFACE:MAG < 10 {
until abs(GROUNDSPEED) < 1 {

	//set curVelDiff to ( 0 - calcVelocityForAltitude(ALT:RADAR - 10) - ship:VERTICALSPEED).
	set curVelDiff to  ship:VELOCITY:SURFACE:MAG - calcVelocityForAltitude(ALT:RADAR - 10).
	
	if abs(curVelDiff) < 1 {
		set th to gravEngineThrust().
	}
	set th to gravEngineThrust() + curVelDiff / 5.
	wait 0.1.
}


PRINT "====== SATAGE 6 (hover) ===========".

PRINT "..... stop burn".


PRINT "====== SATAGE 7 (land) ===========".

PRINT "..... HOVER done, do vertical land".

LOCK STEERING TO (-1) * SHIP:VELOCITY:SURFACE.
PRINT "..... down to 3m at 3m/s".
until ALT:RADAR < 3 {
	set th to gravEngineThrust() -  ( (ship:VERTICALSPEED + 3) / 5).
	wait 0.
}
PRINT "..... down to 1 m at 1m/s".
until ALT:RADAR < 1 {
	set th to gravEngineThrust() -  ( (ship:VERTICALSPEED + 1) / 5).
	wait 0.
}


PRINT "..... turn off engine ".
PRINT "..... clam down procedure.".
LOCK STEERING TO HEADING(0,90).
LOCK THROTTLE TO 0.
wait 5.
PRINT "..... steering = kill".
LOCK STEERING TO "kill".
wait 1.
PRINT "..... unlock steering".
UNLOCK STEERING.
wait 1.
PRINT "..... steering = kill".
LOCK STEERING TO "kill".
wait 1.

PRINT "..... unlock steering".
UNLOCK STEERING.

PRINT "..... at the ground. unlock controls.".
UNLOCK THROTTLE.

printDiagnosticInfo().
PRINT "idle".