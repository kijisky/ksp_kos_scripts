PRINT "init sattelete subprogramm (v-0.1 by kijisky)".

PRINT "=== Step1: calculations =========================".


	PRINT "    activate RTLongAntenna2".
	SET P TO SHIP:PARTSNAMED("RTLongAntenna2")[0].
	SET M to p:GETMODULE("ModuleRTAntenna").
	M:DOACTION("activate", true).

	PRINT "    activate HighGainAntenna5".
	SET P TO SHIP:PARTSNAMED("HighGainAntenna5")[0].
	SET M to p:GETMODULE("ModuleRTAntenna").
	M:DOACTION("activate", true).
	M:SETFIELD("target", "Mission Control").
	//M:SETFIELD("target", "sat-com-2-keosatC").


PRINT "    deploy solar panels".
PANELS ON.

PRINT "    activate engine".
LOCK THROTTLE TO 0.
set e to ship:partsnamedpattern("engine")[0].
e:activate().

PRINT "=== program is over".


