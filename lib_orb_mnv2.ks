parameter tgt_orb_lan, tgt_orb_inc, tgt_orb_pop, tgt_orb_apo, tgt_orb_per.
////////////////////////////////////////////////
////////////////////////////////////////////////

on AG1 {
	
	set orbLAN to ship:orbit:LONGITUDEOFASCENDINGNODE - BODY:ROTATIONANGLE .
	if (orbLAN > 180) {
		set orbLAN to orbLAN - 360.
	}
	if (orbLAN < -180) {
		set orbLAN to orbLAN + 360.
	}

	print "======================".
	print "== lat:   " + ship:latitude.
	print "== lon:   " + ship:longitude.
	print "== o:LAN: " + orbLAN.
	print "== o:INC: " + ship:orbit:INCLINATION.
	print "== o:APO: " + ship:orbit:APOAPSIS.
	print "== o:PER: " + ship:orbit:PERIAPSIS.
	print "======================".
	return true.
}


print " ================ orbital maneuvering ================= ".
print "   going to orbit".
print "       Longitude of AccNode: " + tgt_orb_lan.
print "       Inclination         : " + tgt_orb_inc.
print "       Param of periapsis  : " + tgt_orb_pop.
print "       Apoapsis altitude   : " + tgt_orb_apo.
print "       Periapsis altitude  : " + tgt_orb_per.

SAS OFF.
RCS OFF.



//==========================================================================================
//==================================== functions ===========================================
//==========================================================================================
//==========================================================================================

function longitudeCorrected{
	DECLARE PARAMETER pLongitude.
	set L0 to pLongitude - BODY:ROTATIONANGLE .
	if (L0 > 180) {
		set L0 to L0 - 360.
	}
	if (L0 < -180) {
		set L0 to L0 + 360.
	}
	return L0.
}

function wait4longitude{
	DECLARE PARAMETER pLongitude.
	
	set L1 to longitudeCorrected(pLongitude - 1).
	set L2 to longitudeCorrected(pLongitude + 1).
	print "..... wait for longitude [" + L1 + " - "  + L2 + "] (current: " + ship:longitude +")".

	until ship:LONGITUDE > L1 and ship:LONGITUDE < L2 {
		set L1 to longitudeCorrected(pLongitude - 1).
		set L2 to longitudeCorrected(pLongitude + 1).
		wait 0.1.
	}
}

function inclinationEquals {
	DECLARE PARAMETER tgt_orb_lan.
	DECLARE PARAMETER tgt_orb_inc.
	
	set diffLan to abs(ship:orbit:LONGITUDEOFASCENDINGNODE - tgt_orb_lan).
	set diffInc to abs(ship:orbit:INCLINATION - tgt_orb_inc).
	print "________ diffLan " + diffLan.
	print "________ diffInc " + diffInc.
	return (diffLan < 2 and diffInc < 1).	
}

function changeInclination{
	DECLARE PARAMETER tgtInclination.
	
	if (ship:ORBIT:INCLINATION > tgtInclination) {
		lock steering to VCRS(ship:velocity:orbit, ship:orbit:body:position).
		//LOCK STEERING TO normal.
	} else {
		lock steering to VCRS(ship:orbit:body:position, ship:velocity:orbit).
		//LOCK STEERING TO antinormal.
	}

	print "..... give it time to trun the ship".
	wait 5. 
	
	print "..... burn!".
	LOCK THROTTLE TO 1.
	wait until abs(ship:ORBIT:INCLINATION - tgtInclination) < 1.
	
	set minInclAgnle to abs(ship:ORBIT:INCLINATION - tgtInclination).
	print "..... tune. From " + minInclAgnle.
	LOCK THROTTLE TO 0.2.
	until abs(ship:ORBIT:INCLINATION - tgtInclination) > minInclAgnle {
		set minInclAgnle to abs(ship:ORBIT:INCLINATION - tgtInclination).
	}
	print "..... final " + abs(ship:ORBIT:INCLINATION - tgtInclination).
	
	print "..... ok. unlock controls".
	LOCK THROTTLE TO 0.
	return.
}

function orbChangeSetOposeNodeTo {
	DECLARE PARAMETER tgtAlt.
	
	print "..... orbChangeSetOposeNodeTo ( " + tgtAlt.
	set altAccur to 1000.
	set alt1 to tgtAlt - altAccur.
	set alt2 to tgtAlt + altAccur.
	
	set timeToApo to min( ETA:apoapsis, ship:orbit:period - ETA:apoapsis).
	set timeToPer to min( ETA:periapsis, ship:orbit:period - ETA:periapsis).
	
	
	if (timeToApo > timeToPer) {
		print "..... we at periapsis".
		set oposeAltitude to ship:orbit:apoapsis.
	} else {
		print "..... we at apoapsis".
		set oposeAltitude to ship:orbit:periapsis.
	}
	
	
	set oposeNodeDiff to (oposeAltitude - tgtAlt).
	print ".....  currentAlt-targetAlt = " + oposeNodeDiff.
	if (oposeNodeDiff > 0) {
		print "..... opose Node to high, go down".
		lock steering to retrograde .
	}
	if (oposeNodeDiff < 0) {
		print "..... opose Node to low, go up".
		lock steering to prograde.
	}
	
	print ".....  engines on".
	print ".....  wait until one of (apoapsis/periapsis) move close to target Alt".
	LOCK THROTTLE TO 1.
	wait until ( SHIP:PERIAPSIS > alt1 and SHIP:PERIAPSIS < alt2 ) OR ( SHIP:APOAPSIS > alt1 and SHIP:APOAPSIS < alt2).
	
	print ".....  tune".
	LOCK THROTTLE TO 0.2.
	if ( SHIP:PERIAPSIS > alt1 and SHIP:PERIAPSIS < alt2 ){
		set minDiff to abs( SHIP:PERIAPSIS - tgtAlt ).
		until abs( SHIP:PERIAPSIS - tgtAlt ) > minDiff {
			set minDiff to abs( SHIP:PERIAPSIS - tgtAlt ).
		}
	}
	if ( SHIP:APOAPSIS > alt1 and SHIP:APOAPSIS < alt2 ){
		set minDiff to abs( SHIP:APOAPSIS - tgtAlt ).
		until abs( SHIP:APOAPSIS - tgtAlt ) > minDiff {
			set minDiff to abs( SHIP:APOAPSIS - tgtAlt ).
		}
	}
	LOCK THROTTLE TO 0.
	
	print ".....  maneuver is over".
	return.
}


//==========================================================================================
//==========================================================================================




print " === Stage 1 (do incl = 0) ================= ".

print "..... current orbit inclination = "  + ship:ORBIT:INCLINATION .

if (inclinationEquals(tgt_orb_lan, tgt_orb_inc) or ship:ORBIT:INCLINATION < 0.2) {
	print "..... no need to change. ".
} else {
	/// steer normal to speed
	wait4longitude(ship:ORBIT:LONGITUDEOFASCENDINGNODE -2 ).
	changeInclination(0).
}


print " === Stage 2 (do target inclination) ================= ".

if (inclinationEquals(tgt_orb_lan, tgt_orb_inc) or tgt_orb_inc < 0.1) {
	print "... inclination  =" + tgt_orb_inc + " no need to change. ".
} else {
	/// steer normal to speed
	wait4longitude(tgt_orb_lan - 2).
	changeInclination(tgt_orb_inc).
}


print " === Stage 3 (transit to radial orbit) ================= ".

print "..... equalize APO & PER".
if abs(SHIP:PERIAPSIS - SHIP:apoapsis) > 100 {
	
	print "      wait for apoapsis <5 (" + eta:apoapsis.
	lock steering to prograde.
	wait until eta:apoapsis < 5.
	LOCK THROTTLE TO 1.

	//wait until abs(SHIP:PERIAPSIS - SHIP:apoapsis) < 5000.
	set minDiff to abs(SHIP:PERIAPSIS - SHIP:apoapsis).
	print "..... tune APO-PER diff from : " + abs(SHIP:PERIAPSIS - SHIP:apoapsis).
	LOCK THROTTLE TO 0.2.
	until abs(SHIP:PERIAPSIS - SHIP:apoapsis) > minDiff {
		set minDiff to abs(SHIP:PERIAPSIS - SHIP:apoapsis).
	}
	print "..... best value : " + abs(SHIP:PERIAPSIS - SHIP:apoapsis).

	print "..... at radial orbit!".
	LOCK THROTTLE TO 0.
} else {
	print "..... APO & PER near equal".
}

print " === Stage 4 (go to target orbit) ================= ".


print " ==== Stage 4a (apoapsis) ================= ".

print "..... wait for ".

set tgtApoapsisLong to tgt_orb_lan + tgt_orb_pop.
wait4longitude(tgtApoapsisLong -5 ).
orbChangeSetOposeNodeTo(tgt_orb_apo ).


print " ==== Stage 4a (periapsis) ================= ".

set tgtPeriapsisLong to tgt_orb_lan + tgt_orb_pop + 180.
wait4longitude(tgtPeriapsisLong -5 ).
orbChangeSetOposeNodeTo(tgt_orb_per ).

print " ==== Maneuvering is over ================= ".
print "iddle".

