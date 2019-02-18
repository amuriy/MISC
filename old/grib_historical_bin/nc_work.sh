#!/bin/sh

rm -f ./.tmp*.tif

gdal_translate NETCDF:"$1":precip ./.tmp1.tif
gdalwarp -q -s_srs "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +pm=-360" \
    	 -t_srs "EPSG:4326" ./.tmp1.tif ./.tmp2.tif
gdal_merge.py -o  ./.tmp3.tif ./.tmp1.tif  ./.tmp2.tif 
gdalwarp -q -te -180 -90 180 90 ./.tmp3.tif $(basename $1 .nc).tif

rm -f ./.tmp*.tif
