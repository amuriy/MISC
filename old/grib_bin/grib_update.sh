#!/bin/sh

## set vars
# date_mon="$(date -dlast-monday +%Y%m%d)00" # monday of current week
# date_sun="$(date -dsunday +%Y%m%d)00" # sunday of current week (end of week)
today="$(date +%Y%m%d)00"
h1=168 # forecast hours (168 in week)
h2=6 # forecast frequency (6 h)
bin_dir='/home/amuriy/Desktop/GRIB/bin'
params='TMP:PRATE:APCP:CRAIN:CSNOW:UGRD:VGRD:ICEC:DPT:VIS:TCDC:PRES:GUST:RH:CFRZR:CAPE surface:2_m_above_ground:10_m_above_ground:100_m_above_ground:975_mb:950_mb:925_mb:900_mb:850_mb:800_mb:700_mb:600_mb:500_mb:400_mb:300_mb:250_mb:200_mb:150_mb:entire_atmosphere'
# dload_dir="/home/amuriy/Desktop/GRIB/data/grib/TEST/${date_mon}_${date_sun}"
dload_dir="/home/amuriy/Desktop/GRIB/data/grib/TEST/grib"
tif_dir="/home/amuriy/Desktop/GRIB/data/grib/TEST/tif"

# ## download GRIB files
# if [ ! -d "$dload_dir" ]; then
#     mkdir $dload_dir
# else
#     rm -rf $dload_dir/*
# fi

# $bin_dir/misc/get_gfs.pl data $today 0 $h1 $h2 $params $dload_dir # > /dev/null 2>&1 &

# ##DB and TIF's cleanup
# if [ ! -d $tif_dir ]; then
#     mkdir $tif_dir
# else
#     rm -rf $tif_dir/*
# fi

export PGPASSWORD='Prime#52'
sql="$bin_dir/batch_truncate_tables.sql"
psql --host=172.24.2.192 --username=bpd_owner --dbname=bpd_postgis_dev --file=$sql > /dev/null 2>&1

# ## GRIB processing
# iter 1
ls $dload_dir/gfs.* | while read file; do
    echo $file
    $bin_dir/grib_proc1.sh $file $tif_dir
done

# ## copy TIF files to remote server
# ssh root@172.24.2.130 'rm -rf  /gip/data/grib/*'
# rsync -av $tif_dir/* root@172.24.2.130:/gip/data/grib/

# # iter 2
# ls $dload_dir/gfs.* | while read file; do
#     echo $file
#     $bin_dir/grib_proc2.sh $file $tif_dir
# done
