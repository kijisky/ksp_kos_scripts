PRINT "init sattelete subprogramm (v-0.1 by kijisky)".

LOCK THROTTLE TO 0.
RCS OFF.
lock steering to prograde.

print "..... wait 10 sec before start init procedure".
wait 10.

PRINT "=== Init Steps =========================".

PRINT "..... activate RTLongAntenna2".
SET P TO SHIP:PARTSNAMED("RTLongAntenna2")[0].
SET M to p:GETMODULE("ModuleRTAntenna").
M:DOACTION("activate", true).

//PRINT "..... activate HighGainAntenna5".
//SET P TO SHIP:PARTSNAMED("HighGainAntenna5")[0].
//SET M to p:GETMODULE("ModuleRTAntenna").
//M:DOACTION("activate", true).
//M:SETFIELD("target", "Mission Control").
//M:SETFIELD("target", "sat-com-2-keosatC").


PRINT "..... deploy solar panels".
PANELS ON.

PRINT "..... activate engine".
set THROTTLE to 0.
LOCK THROTTLE TO 0.
unlock THROTTLE.
unlock steering.
set e to ship:partsnamedpattern("engine")[0].
e:activate().


PRINT "..... set default bootfile ".
set CORE:bootfilename to "execute_nodes.ks".

PRINT "=== init program is over".


