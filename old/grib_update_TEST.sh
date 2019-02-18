#!/bin/bash

## set vars
# today="$(date +%Y%m%d)00"

h_now=$(date --date="$(date) - 16 hours" '+%H' | sed 's/0//')
# h_now=$(date --date="$(date)" '+%H' | sed 's/0//')

(("$h_now">=2 && "$h_now"<=7)) && h0=18 && today="$(date --date="$(date) - 1 day" '+%Y%m%d'18)" 
(("$h_now">=8 && "$h_now"<=13)) && h0=0 && today="$(date '+%Y%m%d'00)" 
(("$h_now">=14 && "$h_now"<=20)) && h0=6 && today="$(date '+%Y%m%d'06)" 
(("$h_now">=21 && "$h_now"<24)) && h0=12 && today="$(date '+%Y%m%d'12)" 
(("$h_now">=0 && "$h_now"<=1)) && h0=12 && today="$(date '+%Y%m%d'12)" 

# h0=6 # start hour
h1=12 # forecast hours (384 in 16 days)
h2=3 # forecast frequency (3 h/6 h)
bin_dir='/home/amuriy/Desktop/GRIB/mchs_work/bin'
# params='TMP:PRATE:APCP:CRAIN:CSNOW:UGRD:VGRD:ICEC:DPT:VIS:TCDC:PRES:GUST:RH:CFRZR:CAPE surface:2_m_above_ground:10_m_above_ground:100_m_above_ground:975_mb:950_mb:925_mb:900_mb:850_mb:800_mb:700_mb:600_mb:500_mb:400_mb:300_mb:250_mb:200_mb:150_mb:entire_atmosphere'
params='APCP surface'
dload_dir='/home/amuriy/Desktop/GRIB/mchs_work/grib'
tif_dir='/home/amuriy/Desktop/GRIB/mchs_work/tif'

echo    $bin_dir/get_gfs.pl data $today $h0 $h1 $h2 $params $dload_dir #  > /dev/null 2>&1 &

## download GRIB files
grib_dload()
{
    if [ ! -d "$dload_dir" ]; then
        mkdir $dload_dir
    else
        find $dload_dir -type f -exec rm -f {} \;
    fi    
    $bin_dir/get_gfs.pl data $today $h0 $h1 $h2 $params $dload_dir #  > /dev/null 2>&1 &
}
