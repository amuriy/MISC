#!/bin/sh

cleanup()
{
    rm -rf ./grib_work_tmp/
}

exitprocedure()
{
    echo ""
    echo "User break!"
    cleanup
    exit 1
}
trap "exitprocedure" 2 3 15

maketmp()
{
    if [ ! -d ./grib_work_tmp/ ]; then
	mkdir ./grib_work_tmp/
    fi
    meta='./grib_work_tmp/gdalinfo.meta'
    if [ ! -e "$meta" ]; then
	gdalinfo $file > $meta 2>/dev/null
    fi
}

grib_check()
{
    if_grib=$(cat ./grib_work_tmp/gdalinfo.meta | grep 'Driver:' | grep 'GRIB')
    if [ -z "$if_grib" ]; then
	echo 'Выбранный файл не является GRIB-файлом либо повреждён!'
	cleanup	
	exit 1
    fi
}


info()
{
    maketmp
    grib_check

    export LC_ALL=ru_RU.UTF-8

    cat ./grib_work_tmp/gdalinfo.meta | grep GRIB_VALID_TIME \
	| grep -oh '[0-9]*' \
	| while read i; do date -u -d@$i '+%Y-%m-%d %H:%M:%S'; done \
	| sort | uniq | sed 's/00 /00\n/g' > ./grib_work_tmp/date_utc       
    cat ./grib_work_tmp/gdalinfo.meta | grep GRIB_VALID_TIME \
	| grep -oh '[0-9]*' \
	| while read i; do date -d@$i '+%Y-%m-%d %H:%M:%S'; done \
	| sort | uniq | sed 's/00 /00\n/g' > ./grib_work_tmp/date0
    cat ./grib_work_tmp/date0 | while read i; do
	d=$(date --date="$i" '+%Y%m%d%H') 
	echo $i | sed "s/$i/$d/ " > ./grib_work_tmp/date1
    done
}

data_list()
{
    cat ./grib_work_tmp/gdalinfo.meta |  grep -B5 -A2 'GRIB_ELEMENT' \
	| while read meta; do

	var=$(echo $meta | grep 'GRIB_ELEMENT' | cut -d'=' -f2 | tr '[:upper:]' '[:lower:]')
	band=$(echo $meta | grep 'Band' | cut -d' ' -f2)
	elev=$(echo $meta | grep 'Description' | cut -d'=' -f2)

	case "$elev" in
    	    ' 0[-] RESERVED(10) (Reserved)')
    		elev='all'
    		;;
    	    ' 0[-] EATM')
    		elev='all'
    		;;
    	    ' 0[-] SFC')
    		elev='surf'
    		;;
    	    ' 2[m] HTGL')
    		elev='2m'
    		;;
    	    ' 10[m] HTGL')
    		elev='10m'
    		;;	
    	    ' 100[m] HTGL')
    		elev='100m'
    		;;
    	    ' 15000[Pa] ISBL')
    		elev='150mb'
    		;;
    	    ' 20000[Pa] ISBL')
    		elev='200mb'
    		;;
    	    ' 25000[Pa] ISBL')
    		elev='250mb'
    		;;
    	    ' 30000[Pa] ISBL')
    		elev='300mb'
    		;;
    	    ' 40000[Pa] ISBL')
    		elev='400mb'
    		;;
    	    ' 50000[Pa] ISBL')
    		elev='500mb'
    		;;
    	    ' 60000[Pa] ISBL')
    		elev='600mb'
    		;;
    	    ' 70000[Pa] ISBL')
    		elev='700mb'
    		;;
    	    ' 80000[Pa] ISBL')
    		elev='800mb'
    		;;
    	    ' 85000[Pa] ISBL')
    		elev='850mb'
    		;;
    	    ' 90000[Pa] ISBL')
    		elev='900mb'
    		;;
    	    ' 92500[Pa] ISBL')
    		elev='925mb'
    		;;
    	    ' 95000[Pa] ISBL')
    		elev='950mb'
    		;;
    	    ' 97500[Pa] ISBL')
    		elev='975mb'
    		;;
	esac

	if [ "$var" != '' ]; then
    	    echo "$var" >> ./grib_work_tmp/vars
	fi
	if [ "$band" != '' ]; then
    	    echo "$band" >> ./grib_work_tmp/bands
	fi
	if [ "$elev" != '' ]; then
    	    echo "$elev" >> ./grib_work_tmp/elevs
	fi

    done

    paste -d' ' ./grib_work_tmp/vars \
	  ./grib_work_tmp/elevs ./grib_work_tmp/bands \
	| grep -v 'tmp 2m'> ./grib_work_tmp/all.txt 
}

make_tifs()
{
    var=$1
    band=$2
    elev=$3

    tifname=$var'_'$elev'_'$date1'.tif'

    case "$var" in
	'crain'|'csnow'|'prate'|'pres')
	    ot='Float64'
	    ;;
	*)
    	    ot='Int16'
    	    ;;	    
    esac

#gdal_translate -q -co "COMPRESS=PACKBITS" -co "TILED=YES" -ot $ot -b $band -a_srs "EPSG:4326" $file $tmpdir/temp1.tif # > /dev/null 2>&1    
    # -ot $ot -b $band -a_nodata -9999 -a_srs "EPSG:4326" \

    gdal_translate -q -co "COMPRESS=PACKBITS" -co "TILED=YES" \
    		   -ot $ot -b $band -a_srs "EPSG:4326" $file $tmpdir/temp1.tif  > /dev/null 2>&1
    gdalwarp -q -s_srs "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +pm=-360" \
    	     -t_srs "EPSG:4326" $tmpdir/temp1.tif $tmpdir/temp2.tif  > /dev/null 2>&1
    gdal_merge.py -q -o $tmpdir/temp3.tif $tmpdir/temp1.tif $tmpdir/temp2.tif > /dev/null 2>&1
    # gdalwarp -q -r cubicspline -tr 20000 20000 -t_srs "EPSG:3857" $tmpdir/temp3.tif $tmpdir/$tifname > /dev/null 2>&1
    # gdalwarp -q -r cubicspline -tr 0.25 0.25 -te -180 -90 180 90 $tmpdir/temp3.tif $tmpdir/$tifname > /dev/null 2>&1
    gdalwarp -q -r cubicspline -tr 0.25 0.25 $tmpdir/temp3.tif $tmpdir/$tifname > /dev/null 2>&1
}




proc_wind()
{
    find $tmpdir -type f -name "*grd*.tif" | cut -d'/' -f3 | cut -d'_' -f2 | sed 's/.tif//' \
    	| sort | uniq | while read elev; do
    	u_tif=$(find $tmpdir -type f -name "ugrd_${elev}_${date1}.tif")
    	v_tif=$(find $tmpdir -type f -name "vgrd_${elev}_${date1}.tif")
	
    	gdal_calc.py -A "$u_tif" -B "$v_tif" --outfile="${outdir}/wind_speed_${elev}_${date1}.tif" --calc="sqrt(A*A+B*B)" > /dev/null 2>&1
	
    	if [ "$elev" = '10m' ]; then
	    cp "$outdir/wind_speed_${elev}_${date1}.tif" "$tmpdir/speed.tif"	    
    	    python $bin_dir/wind_dir.py "$u_tif" "$v_tif" "$tmpdir/direct.tif" > /dev/null 2>&1
    	fi
    done
}


proc_temper()
{
    shp="$tmpdir/towns_timezones.shp"
    csv="$tmpdir/towns1.csv"

    ogr2ogr -f "ESRI Shapefile" -sql "SELECT ST_Intersection(A.geometry, B.geometry) AS geometry, A.*, B.ZONE as time_zone FROM towns_odkb A, timezone B WHERE ST_Intersects(A.geometry, B.geometry)" -dialect SQLITE $shp "$data_dir/shp"  -nln towns_timezone -lco ENCODING=UTF-8
    
    if_tmp_surf=$(ls $tmpdir/tmp_surf_${date1}.tif > /dev/null 2>&1)
    if [ $(echo $?) = 0 ]; then
	tmp_surf=$(find $tmpdir -type f -name "tmp_surf_${date1}.tif") 
	python $bin_dir/extract_values.py -q $shp $tmp_surf
	
	ogr2ogr -f "CSV" -lco GEOMETRY=AS_WKT $csv $shp
	sed -i '1d' $csv
    fi
}


proc_precip_zones()
{
    find $tmpdir -type f -name "*crain*.tif" -o -name "*csnow*.tif" | cut -d'/' -f3 | cut -d'_' -f2 | sed 's/.tif//' \
    	| sort | uniq | while read elev; do
	
    	snow_tif=$(find $tmpdir -type f -name "csnow_${elev}_${date1}.tif")
	snow_tif2=$tmpdir/snow.tif
	gdal_translate -ot Int16 $snow_tif $snow_tif2 > /dev/null 2>&1
    	rain_tif=$(find $tmpdir -type f -name "crain_${elev}_${date1}.tif")
	rain_tif2=$tmpdir/rain.tif	
	gdal_translate -ot Int16 $rain_tif $rain_tif2 > /dev/null 2>&1
	
    	gdal_calc.py -A "$rain_tif" -B "$snow_tif" --outfile="${outdir}/precip_zones_${elev}_${date1}.tif" --calc="1*logical_or(A>=0.5, B>=0.5)" > /dev/null 2>&1

	shp="$tmpdir/precip.shp"
	csv="$tmpdir/precip.csv"
	csv2="$tmpdir/precip2.csv"	
	csv3="$tmpdir/towns2.csv"

	ogr2ogr -f "ESRI Shapefile" $shp "$data_dir/shp/towns_odkb.shp" -lco ENCODING=UTF-8

	python $bin_dir/extract_values.py -q $shp $rain_tif2
	python $bin_dir/extract_values.py -q $shp $snow_tif2
	
	ogr2ogr -f "CSV" -lco GEOMETRY=AS_WKT $csv $shp
	sed -i '1d' $csv
	cat $csv | cut -d',' -f5,6 > $csv2
	paste -d',' $tmpdir/towns1.csv $csv2 > $csv3

    done
}


proc_cloud()
{
    find $tmpdir -type f -name "*tcdc*.tif" | cut -d'/' -f3 | cut -d'_' -f2 | sed 's/.tif//' \
    	| sort | uniq | while read elev; do
	
    	cloud_tif=$(find $tmpdir -type f -name "tcdc_${elev}_${date1}.tif")

	shp="$tmpdir/cloud.shp"
	csv="$tmpdir/cloud.csv"
	csv2="$tmpdir/cloud2.csv"

	ogr2ogr -f "ESRI Shapefile" $shp "$data_dir/shp/towns_odkb.shp" -lco "ENCODING=UTF-8"

	python $bin_dir/extract_values.py -q $shp $cloud_tif
	
	ogr2ogr -f "CSV" -lco GEOMETRY=AS_WKT $csv $shp
	sed -i '1d' $csv
	cat $csv | cut -d',' -f5 > $csv2

	paste -d',' $tmpdir/towns2.csv $csv2 > $tmpdir/towns_full.csv
    done    
}


proc_cloud_base()
{
    tmp_tif=$(find $tmpdir -type f -name "tmp_surf_${date1}.tif")
    dpt_tif=$(find $tmpdir -type f -name "dpt_2m_${date1}.tif")

    gdal_calc.py -A "$tmp_tif" -B "$dpt_tif" --outfile="${outdir}/cloud_base_${elev}_${date1}.tif" --calc="(A-B)*208" > /dev/null 2>&1
}

proc_prate()
{
    prate_tif=$(find $tmpdir -type f -name "prate_surf_${date1}.tif")
    gdal_calc.py -A "$prate_tif" --outfile="${outdir}/prate_surf_${date1}.tif" --calc="(A*3600)" > /dev/null 2>&1
}

proc_icec()
{
    icec_tif=$(find $tmpdir -type f -name "icec_surf_${date1}.tif")
    gdalwarp -q -r cubicspline -tr 0.10 0.10 $icec_tif "${outdir}/icec_surf_${date1}.tif" > /dev/null 2>&1
}

proc_pres()
{
    pres_tif=$(find $tmpdir -type f -name "pres_surf_${date1}.tif")
    gdal_calc.py -A "$pres_tif" --outfile="${outdir}/pres_surf_${date1}.tif" --calc="A/100" > /dev/null 2>&1
}

proc_storm()
{
    cape_tif=$(find $tmpdir -type f -name "cape_surf_${date1}.tif")
    gdal_calc.py --type 'Int16' -A "$cape_tif" --outfile="${outdir}/storm_surf_${date1}.tif" --calc="1*(A>1500)" --NoDataValue=0 > /dev/null 2>&1
}

proc_fog()
{
    cloudbase_tif=$(find $outdir -type f -name "cloud_base_*${date1}.tif")
    rh_tif=$(find $outdir -type f -name "rh_2m_${date1}.tif")
    vis_tif=$(find $outdir -type f -name "vis_surf_${date1}.tif")
    gdal_calc.py --type 'Int16' -A "$cloudbase_tif" -B "$rh_tif" -C "$vis_tif" --outfile="${outdir}/fog_surf_${date1}.tif" --calc="1*logical_and(A<10,B>98,C<500)" --NoDataValue=0 > /dev/null 2>&1
}

proc_hurr()
{
    wind_tif=$(find $outdir -type f -name "wind_speed_10m_${date1}.tif")
    gdal_calc.py --type 'Int16' -A "$wind_tif" --outfile="${outdir}/hurr_surf_${date1}.tif" --calc="1*(A>=30)" --NoDataValue=0 > /dev/null 2>&1
}

towns_weather()
{
    csv="$tmpdir/towns_full.csv"
    sql="$tmpdir/towns_full.sql"
    csv2="$tmpdir/towns_full_coor.csv"
    
    hour=$(echo $date0 | cut -d' ' -f2)
    
    case "$hour" in
    	'06:00:00'|'09:00:00'|'12:00:00'|'15:00:00'|'18:00:00')
    	    daytime='day'
    	    ;;
    	*)
    	    daytime='night'
    	    ;;
    esac    

    cat $csv | while read line; do

	geom=$(echo $line | cut -d',' -f1 | sed 's+"++g')
	adm=$(echo $line | cut -d',' -f2)
	name=$(echo $line | cut -d',' -f3)
	pop=$(echo $line | cut -d',' -f4)
	tz=$(echo $line | cut -d',' -f5)
	temper=$(echo $line | cut -d',' -f6)
	rain=$(echo $line | cut -d',' -f7)
	snow=$(echo $line | cut -d',' -f8)
	cloud=$(echo $line | cut -d',' -f9)
	
	echo "INSERT INTO is_grib.grib_towns_odkb_weather (shape,admin_leve,name,population,time_data,time_zone,temper,rain,snow,cloud) 
VALUES (ST_GeomFromText('$geom','4326'),'$adm','$name',$pop,'$date0','$tz',$temper,$rain,$snow,$cloud) ;" >> $sql
    done

    echo "update is_grib.grib_towns_odkb_weather set time_zone = (time_zone || ' hour') where time_zone not like '%hour%' ; " >> $sql
    echo "update is_grib.grib_towns_odkb_weather set local_time = time_data + cast(time_zone as interval) ;" >> $sql

    
    echo "update is_grib.grib_towns_odkb_weather set daytime =
case when 
date_part('hour',local_time) between 21 and 23 
or date_part('hour',local_time) between 0 and 5 
then 'night' 
else 'day'
end
; " >> $sql

    export PGPASSWORD='Prime#52'
    psql --host=172.24.2.192 --username=bpd_owner --dbname=bpd_postgis_dev --file=$sql # > /dev/null 2>&1
}


index_tables()
{
    ls $outdir | cut -d'_' -f1 | sort | uniq \
	| while read var; do
	case "$var" in
    	    'tmp')
    		name='temper'
    		;;
	    'apcp06')
		name='precip'
		;;
	    'wind')
		name='wind'
		;;
	    'tcdc')
		name='cloud'
		;;
	    'precip')
	    	name='precip_zones'
	    	;;
	    'icec')
		name='icec'
		;;
	    'dpt')
		name='dew'
		;;
	    'cloud')
		name='cloud_base'
		;;
	    'prate')
		name='prate'
		;;
	    'pres')
		name='pres'
		;;
	    'rh')
		name='rh'
		;;
	    'vis')
		name='vis'
		;;
	    'storm')
		name='storm'
		;;
	    'fog')
		name='fog'
		;;
	    'gust')
		name='gust'
		;;
	    'hurr')
		name='hurr'
		;;
	    'cfrzr')
		name='frain'
		;;  	    
	esac

	shp="$tmpdir/grib_${name}_${date1}_time_index.shp"
	csv="$tmpdir/grib_${name}_${date1}_time_index.csv"
	sql="$tmpdir/grib_${name}_${date1}_time_index.sql"

	# gdaltindex -t_srs "EPSG:3857" $shp $outdir/${var}_*_${date1}* > /dev/null 2>&1
	gdaltindex $shp $outdir/${var}_*_${date1}* > /dev/null 2>&1
	ogr2ogr -f "CSV" -lco "GEOMETRY=AS_WKT" -lco "SEPARATOR=SEMICOLON" $csv $shp
	
	sed -i '1d' $csv

	cat $csv | while read line; do
	    geom=$(echo $line | cut -d';' -f1 | sed 's+"++g')
	    loc='/gip/data/grib/'$(echo $line | sed "s+${outdir}\/++" | cut -d';' -f2)

	    echo $loc
	    
	    echo "INSERT INTO is_grib.grib_${name}_time_index (shape,location,time_data) 
VALUES (ST_GeomFromText('$geom','4326'),'$loc','$date0') ;" >> $sql
	done

	echo "update gip.layer set timefield = 'time_data=0000-00-00/9999-30-31' where namefull like '%grib%'" >> $sql
	
	export PGPASSWORD='Prime#52'
	psql --host=172.24.2.192 --username=bpd_owner --dbname=bpd_postgis_dev --file=$sql > /dev/null 2>&1
	
    done    
}



## main
if [ -z "$*" ]; then
    usage
    exit 1
fi

bin_dir="$(dirname $0)"
data_dir="$HOME/Desktop/GRIB/data"
file=$1
outdir=$2

if [ -z "$outdir" ]; then
    outdir=$(pwd)
fi
if [ ! -d "$outdir" ]; then   
    mkdir "$outdir"
fi    

info
data_list

tmpdir='./grib_work_tmp/'
date1=$(cat $tmpdir/date1 | head -n1)
date0=$(cat $tmpdir/date0 | head -n1)
date_utc=$(cat $tmpdir/date_utc | head -n1)

# echo $date_utc

cat $tmpdir/all.txt | grep -E 'tmp|grd|apcp06|crain|csnow|tcdc|icec|dpt|prate|pres|rh|vis|cape|gust' | while read line; do
    
    var=$(echo $line | cut -d' ' -f1)
    elev=$(echo $line | cut -d' ' -f2)
    band=$(echo $line | cut -d' ' -f3)

    if [ "$elev" = "surf" -o "$elev" = "2m" -o "$elev" = "10m" -o "$elev" = "all"  ]; then
    	make_tifs $var $band $elev
    fi
done

# if_temper=$(ls $tmpdir/*tmp* > /dev/null 2>&1)
# if [ $(echo $?) = 0 ]; then    
#     proc_temper
# fi

# if_precip_zones=$(ls $tmpdir/*crain* > /dev/null 2>&1)
# if [ $(echo $?) = 0 ]; then    
#     proc_precip_zones
# fi

# if_cloud=$(ls $tmpdir/*tcdc* > /dev/null 2>&1)
# if [ $(echo $?) = 0 ]; then    
#     proc_cloud
# fi

# find $tmpdir -type f -name "*tmp*.tif" -exec cp -f "{}" $outdir \;
# find $tmpdir -type f -name "*apcp*.tif" -exec cp -f "{}" $outdir \;
# find $tmpdir -type f -name "*icec*.tif" -exec cp -f "{}" $outdir \;
# find $tmpdir -type f -name "*dpt*.tif" -exec cp -f "{}" $outdir \;
# find $tmpdir -type f -name "*tcdc*.tif" -exec cp -f "{}" $outdir \;
# find $tmpdir -type f -name "*prate*.tif" -exec cp -f "{}" $outdir \;
# find $tmpdir -type f -name "*rh_2m*.tif" -exec cp -f "{}" $outdir \;
# find $tmpdir -type f -name "*vis*.tif" -exec cp -f "{}" $outdir \;
# find $tmpdir -type f -name "*gust*.tif" -exec cp -f "{}" $outdir \;
# # # find $tmpdir -type f -name "*cfrzr*.tif" -exec cp -f "{}" $outdir \;

# if_wind=$(ls $tmpdir/*grd* > /dev/null 2>&1)
# if [ $(echo $?) = 0 ]; then    
#     proc_wind
# fi

# proc_cloud_base
# proc_prate
# proc_pres
# proc_storm
# proc_fog
# proc_hurr
index_tables
# towns_weather

## cleanup and exit
cleanup
exit 0
