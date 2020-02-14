from sys import argv
import math
import sph

fn = argv[1]
line = fn
lat1, lon1, azi, dist = map(float, line.split(" "))
lat1 = math.radians(lat1)
lon1 = math.radians(lon1)
azi = math.radians(azi)
dist = dist / sph.a_e
lat2, lon2 = sph.direct(lat1, lon1, dist, azi)
dist, azi2 = sph.inverse(lat2, lon2, lat1, lon1)
print (math.degrees(lat2), math.degrees(lon2), math.degrees(azi2))