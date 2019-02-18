#!/bin/sh

reg_path='/home/kal'
txtdir='/home/kal/txt'

tif=$1

for reg in region1; do
    cropfile="${reg_path}/${reg}.shp"
    tifname0=$(basename $tif .tif)_${reg}_0.tif
    tifname=$(basename $tif .tif)_${reg}.tif
    
    gdalwarp -cutline $cropfile -crop_to_cutline $tif $txtdir/$tifname0 -dstalpha > /dev/null 2>&1
    nodata=$(gdalinfo -stats txt/$tifname0 | grep 'NoData' | head -n1 | cut -d'=' -f2)
    
    if [ -z "$nodata" ]; then
    	gdalwarp -dstnodata 0 $txtdir/$tifname0 $txtdir/$tifname > /dev/null 2>&1
    else
    	gdalwarp -srcnodata $nodata -dstnodata 0 $txtdir/$tifname0 $txtdir/$tifname > /dev/null 2>&1
    fi

    txtname=$(basename $tifname .tif).txt
    gdalinfo -stats $txtdir/$tifname | grep 'STATISTICS_MEAN' | cut -d'=' -f2 | head -n1 | sed 's/32767/0/' > $txtdir/$txtname
done

# rm -f $txtdir/*region*.tif*
