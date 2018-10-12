#!/bin/sh

file=$1

gdal_translate -ot Int16 -b 1 -a_nodata -9999 -a_srs "EPSG:4326" $1 1.tif
gdalwarp -s_srs "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +pm=-360" -t_srs "EPSG:4326" 1.tif 2.tif
gdal_merge.py -o 3.tif 1.tif 2.tif
mv 3.tif ${1}.tif
# gdalwarp -r cubicspline -tr 20000 20000 -t_srs "EPSG:3857" 3.tif ${1}__tmp.tif
rm -f [0-9].tif

