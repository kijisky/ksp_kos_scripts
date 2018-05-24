set start_longitude to ship:longitude.
set entryburn_longitude to ship:longitude - 18.5.

print "init calculations".
print "   start LONG:" + start_longitude.
print "   entry LONG:" + entryburn_longitude.

run orbit_start.ks.


PRINT "== Landing : turning retrograde. (10 sec) ======================".
PRINT "             wait: entrybutn point : long:" + entryburn_longitude.
wait until ship:longitude > entryburn_longitude-1 and  ship:longitude < entryburn_longitude+1.

run orbit_land.ks.
