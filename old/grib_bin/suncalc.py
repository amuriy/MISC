import sys
import csv
from Sun import Sun

infile = sys.argv[1]

with open(infile) as myFile:

            date = open('%s'+'/date_utc', "r") % tmpdir
        print file.read()

    
    reader = csv.reader(myFile)
    for row in reader:
        y = [l.split(' ') for l in ' '.join(row).split(' ')][0]
        y = ''.join(map(str, y))
        x = [l.split(' ') for l in ' '.join(row).split(' ')][1]
        x = ''.join(map(str, x))

        coords = {'longitude' : float(y), 'latitude' : float(x)}
        
        sun = Sun()
        sunrise = sun.getSunriseTime( coords )['decimal']
        sunset = sun.getSunsetTime( coords )['decimal']

        # print sunrise, sunset

        hours = int(sunrise)
        minutes = (sunrise*60) % 60
        seconds = (sunrise*3600) % 60

        print('Sunrise:' "%d:%02d:%02d" % (hours, minutes, seconds))
        
        hours = int(sunset)
        minutes = (sunset*60) % 60
        seconds = (sunset*3600) % 60

        print('Sunset:' "%d:%02d:%02d" % (hours, minutes, seconds))
        
