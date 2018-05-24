function deployPayload{
	DECLARE PARAMETER pCpuTagName.
	set pCpu to ship:partstagged(pCpuTagName).
	set mCpu to pCpu[0]:getmodule("kOSProcessor").	
	
	set mCpu:bootfilename to "init_sat.ks".
	mCpu:activate().
}


set FLIGHT_PLAN to list(
	list("alt",     0,  100,   0),
	list("alt",  3000,  200,   5),
	list("alt",  5000,  300,  10),
	list("alt", 10000,  400,  15),
	list("alt", 12000,  500,  20),
	list("alt", 20000, 1500,  40),
	list("alt", 30000, 2000,  70),
	list("apo", 80000,  100,  80),
	list("eta",    15, 2200,  90),
	list("per", 70000,    0,   0)
).

RCS OFF.
SET thrott TO 1.
SET tgt_speed to 100.




WHEN STAGE:SOLIDFUEL = 0 THEN {
    STAGE.
	set thrott to 1.
}


when thrott < 1 AND ship:VELOCITY:SURFACE:MAG < tgt_speed THEN {
	set thrott to thrott + 0.02.
	PRESERVE.
	wait 0.
}
when thrott > 0 AND ship:VELOCITY:SURFACE:MAG > tgt_speed THEN {
	set thrott to thrott - 0.02.
	PRESERVE.
	wait 0.
}
LOCK THROTTLE TO thrott.


CLEARSCREEN.
PRINT "Scrpt  orbit v-0.2 ".
PRINT "(1st stage + boosters)".


PRINT "===== Start ================".
STAGE.
wait 1.

PRINT "... plan execution programm .......".



FOR step in FLIGHT_PLAN {         
  set step_wait to step[0].
  set step_val to step[1].
  
  RCS OFF.
  PRINT "wait for " + step_wait + " :: " + step_val.
  if (step_wait = "alt") {
	  WAIT UNTIL SHIP:ALTITUDE > step_val.
  }
  if (step_wait = "spd") {
	  WAIT UNTIL ship:VELOCITY:SURFACE:MAG > step_val.
  }
  if (step_wait = "apo") {
	  WAIT UNTIL SHIP:ORBIT:APOAPSIS  > step_val.
  }
  if (step_wait = "eta") {
	  WAIT UNTIL ETA:APOAPSIS < step_val.
  }
  if (step_wait = "per") {
	  WAIT UNTIL SHIP:PERIAPSIS > step_val.
  }  
  set step_speed to step[2].
  set step_angle to step[3].
  SET tgt_speed to step_speed.
  LOCK STEERING TO HEADING(0,90) + R(0,0-step_angle,0).

  PRINT " ===== STEP " + step_wait + " = " + step_val.
  PRINT "       spd: "+step_speed+" , angle: " + step_angle.
}.  


PRINT "== Orbiting. ".
PRINT "==  launch is over      ====================== ".
SET tgt_speed to 0.
LOCK THROTTLE TO 0.
unlock THROTTLE.


PRINT "== Deploy Payload".

deployPayload("command").
RCS ON.
STAGE.
SET SHIP:CONTROL:FORE to -1.
WAIT 1.
SET SHIP:CONTROL:FORE to 0.
WAIT 5.

PRINT "== Turning rocket. (10 sec)".
LOCK STEERING TO HEADING(0,90).