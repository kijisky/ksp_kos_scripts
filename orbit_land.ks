PRINT "== Landing burn. (down to spd 1000) ===============".
PRINT "             entryBurn Longitude: " + ship:longitude.
PRINT "             wait: spd 1000".
LOCK STEERING TO retrograde.
LOCK THROTTLE TO 0.1.
wait 15.
LOCK THROTTLE TO 1.
WAIT UNTIL ship:VELOCITY:SURFACE:MAG < 1000 or SHIP:LIQUIDFUEL < 1.

PRINT "== Landing...  ===============".
PRINT " .... turn angines off".
PRINT " .... turn rcs off".
PRINT " .... turn airbreak on".
PRINT "      wait: alt: 20k".
RCS OFF.
LOCK THROTTLE TO 0.
BRAKES ON.


WAIT UNTIL SHIP:ALTITUDE < 20000.
PRINT "== deploy Shutes...  ===============".
PRINT "      wait: velocity < 20".
CHUTES ON.


WAIT UNTIL ship:VELOCITY:SURFACE:MAG < 20.
PRINT "== speed 20 m/s...  ===============".
PRINT " .... turn rcs on".
PRINT " .... turn gears on".
PRINT "      wait: velocity < 1".
GEAR ON.


WAIT UNTIL ship:VELOCITY:SURFACE:MAG < 1.
PRINT "lading Longitude: " + ship:longitude.

RCS OFF.
LOCK STEERING TO HEADING(0,90).

PRINT "programm is over...".