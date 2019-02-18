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
	  ./grib_work_tmp/elevs ./grib_work_tmp/bands > ./grib_work_tmp/all.txt
	# | grep -v 'tmp 2m'> ./grib_work_tmp/all.txt    
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
    	    # ogr2ogr -f "ESRI Shapefile" "$tmpdir/grid_1.shp" "$data_dir/shp/grid_1.shp"
	    ogr2ogr -f "ESRI Shapefile" "$tmpdir/grid_2.shp" "$data_dir/shp/grid_2.shp"	    
	    
	    cp "$outdir/wind_speed_${elev}_${date1}.tif" "$tmpdir/speed.tif"
	    
    	    python $bin_dir/wind_dir.py "$u_tif" "$v_tif" "$tmpdir/direct.tif" > /dev/null 2>&1
	    
    	    # python $bin_dir/extract_values.py -q "$tmpdir/grid_1.shp" "$tmpdir/speed.tif" > /dev/null 2>&1
    	    # python $bin_dir/extract_values.py -q "$tmpdir/grid_1.shp" "$tmpdir/direct.tif" > /dev/null 2>&1
    	    python $bin_dir/extract_values.py -q "$tmpdir/grid_2.shp" "$tmpdir/speed.tif" > /dev/null 2>&1
    	    python $bin_dir/extract_values.py -q "$tmpdir/grid_2.shp" "$tmpdir/direct.tif" > /dev/null 2>&1	    

    	    # shp="$tmpdir/grid_1.shp"
    	    # csv="$tmpdir/grid_1.csv"
    	    # sql="$tmpdir/grid_1.sql"
	    
    	    # ogr2ogr -f "CSV" -lco GEOMETRY=AS_WKT $csv $shp
    	    # sed -i '1d' $csv

    	    # cat $csv | while read line; do
    	    # 	shape=$(echo $line | cut -d',' -f1 | sed 's/\"//g')
    	    # 	speed=$(echo $line | cut -d',' -f3)
    	    # 	direct=$(echo $line | cut -d',' -f4)

    	    # 	echo "INSERT INTO is_grib.grib_wind_speed_dir (shape,speed,direct,time_data) VALUES (ST_GeomFromText('$shape','4326'),'$speed','$direct','$date0' ;" >> $sql

    	    # done

    	    # sed -i -e 's/\,''\,/\,NULL\,/g' -e 's/;/);/g' $sql
	    
    	    # echo 'UPDATE is_grib.grib_wind_speed_dir SET speed_kn = speed * 1.943844 ;' >> $sql
	    
    	    # echo "UPDATE is_grib.grib_wind_speed_dir set rhumb = 'Ю' where (direct >= -22.5 and direct < 22.5) ;
    	    # UPDATE is_grib.grib_wind_speed_dir set rhumb = 'ЮЗ' where (direct >= 22.5 and direct < 67.5) ;
    	    # UPDATE is_grib.grib_wind_speed_dir set rhumb = 'З' where (direct >= 67.5 and direct < 112.5) ;
    	    # UPDATE is_grib.grib_wind_speed_dir set rhumb = 'СЗ' where (direct >= 112.5 and direct < 157.5) ;
    	    # UPDATE is_grib.grib_wind_speed_dir set rhumb = 'С' where direct >= 157.5 ;
    	    # UPDATE is_grib.grib_wind_speed_dir set rhumb = 'С' where direct < -157.5 ;
    	    # UPDATE is_grib.grib_wind_speed_dir set rhumb = 'СВ' where (direct >= -157.5 and direct < -112.5) ;
    	    # UPDATE is_grib.grib_wind_speed_dir set rhumb = 'В' where (direct >= -112.5 and direct < -67.5) ;
    	    # UPDATE is_grib.grib_wind_speed_dir set rhumb = 'ЮВ' where (direct >= -67.5 and direct < -22.5) ;
    	    # UPDATE is_grib.grib_wind_speed_dir set speed_ms = speed ;
    	    # UPDATE is_grib.grib_wind_speed_dir set speed_kn_raw = speed_kn ;
    	    # UPDATE is_grib.grib_wind_speed_dir set rhumb = null where speed_kn <= 2 ;
    	    # UPDATE is_grib.grib_wind_speed_dir set speed_ms = round(speed, 1), speed_kn = round(speed_kn_raw, 1) ;
            # UPDATE is_grib.grib_wind_speed_dir set  rhumb = concat('➡ ',rhumb) where rhumb = 'З' ;
            # UPDATE is_grib.grib_wind_speed_dir set  rhumb = concat('⬅ ',rhumb) where rhumb = 'В' ;
            # UPDATE is_grib.grib_wind_speed_dir set  rhumb = concat('⬇ ',rhumb) where rhumb = 'С' ;
            # UPDATE is_grib.grib_wind_speed_dir set  rhumb = concat('⬆ ',rhumb) where rhumb = 'Ю' ;
            # UPDATE is_grib.grib_wind_speed_dir SET  rhumb = concat('⬊ ',rhumb) where rhumb = 'СЗ' ;
            # UPDATE is_grib.grib_wind_speed_dir SET  rhumb = concat('⬈ ',rhumb) where rhumb = 'ЮЗ' ;
            # UPDATE is_grib.grib_wind_speed_dir SET  rhumb = concat('⬋ ',rhumb) where rhumb = 'СВ' ;
            # UPDATE is_grib.grib_wind_speed_dir SET  rhumb = concat('⬉ ',rhumb) where rhumb = 'ЮВ' ;
            # UPDATE is_grib.grib_wind_speed_dir SET name = 'Направление и скорость ветра' ; " >> $sql

    	    # export PGPASSWORD='Prime#52'
    	    # psql --host=172.24.2.192 --username=bpd_owner --dbname=bpd_postgis_dev --file=$sql # > /dev/null 2>&1


	    shp="$tmpdir/grid_2.shp"
    	    csv="$tmpdir/grid_2.csv"
    	    sql="$tmpdir/grid_2.sql"
	    
    	    ogr2ogr -f "CSV" -lco GEOMETRY=AS_WKT $csv $shp
    	    sed -i '1d' $csv

	    # echo "TRUNCATE TABLE is_grib.grib_wind_speed_dir2  RESTART IDENTITY ;" > $sql
	    
    	    cat $csv | while read line; do
    	    	shape=$(echo $line | cut -d',' -f1 | sed 's/\"//g')
    	    	speed=$(echo $line | cut -d',' -f3)
    	    	direct=$(echo $line | cut -d',' -f4)
		
    	    	echo "INSERT INTO is_grib.grib_wind_speed_dir2 (shape,speed,direct,time_data) VALUES (ST_GeomFromText('$shape','4326'),'$speed','$direct','$date0' ;" >> $sql

    	    done

    	    sed -i -e 's/\,''\,/\,NULL\,/g' -e 's/;/);/g' $sql
	    
    	    echo 'UPDATE is_grib.grib_wind_speed_dir2 SET speed_kn = speed * 1.943844 ;' >> $sql
	    
    	    echo "UPDATE is_grib.grib_wind_speed_dir2 set rhumb = 'Ю' where (direct >= -22.5 and direct < 22.5) ;
    	    UPDATE is_grib.grib_wind_speed_dir2 set rhumb = 'ЮЗ' where (direct >= 22.5 and direct < 67.5) ;
    	    UPDATE is_grib.grib_wind_speed_dir2 set rhumb = 'З' where (direct >= 67.5 and direct < 112.5) ;
    	    UPDATE is_grib.grib_wind_speed_dir2 set rhumb = 'СЗ' where (direct >= 112.5 and direct < 157.5) ;
    	    UPDATE is_grib.grib_wind_speed_dir2 set rhumb = 'С' where direct >= 157.5 ;
    	    UPDATE is_grib.grib_wind_speed_dir2 set rhumb = 'С' where direct < -157.5 ;
    	    UPDATE is_grib.grib_wind_speed_dir2 set rhumb = 'СВ' where (direct >= -157.5 and direct < -112.5) ;
    	    UPDATE is_grib.grib_wind_speed_dir2 set rhumb = 'В' where (direct >= -112.5 and direct < -67.5) ;
    	    UPDATE is_grib.grib_wind_speed_dir2 set rhumb = 'ЮВ' where (direct >= -67.5 and direct < -22.5) ;
    	    UPDATE is_grib.grib_wind_speed_dir2 set speed_ms = speed ;
    	    UPDATE is_grib.grib_wind_speed_dir2 set speed_kn_raw = speed_kn ;
    	    UPDATE is_grib.grib_wind_speed_dir2 set rhumb = null where speed_kn <= 2 ;
    	    UPDATE is_grib.grib_wind_speed_dir2 set speed_ms = round(speed, 1), speed_kn = round(speed_kn_raw, 1) ;
            UPDATE is_grib.grib_wind_speed_dir2 set  rhumb = concat('➡ ',rhumb) where rhumb = 'З' ;
            UPDATE is_grib.grib_wind_speed_dir2 set  rhumb = concat('⬅ ',rhumb) where rhumb = 'В' ;
            UPDATE is_grib.grib_wind_speed_dir2 set  rhumb = concat('⬇ ',rhumb) where rhumb = 'С' ;
            UPDATE is_grib.grib_wind_speed_dir2 set  rhumb = concat('⬆ ',rhumb) where rhumb = 'Ю' ;
            UPDATE is_grib.grib_wind_speed_dir2 SET  rhumb = concat('⬊ ',rhumb) where rhumb = 'СЗ' ;
            UPDATE is_grib.grib_wind_speed_dir2 SET  rhumb = concat('⬈ ',rhumb) where rhumb = 'ЮЗ' ;
            UPDATE is_grib.grib_wind_speed_dir2 SET  rhumb = concat('⬋ ',rhumb) where rhumb = 'СВ' ;
            UPDATE is_grib.grib_wind_speed_dir2 SET  rhumb = concat('⬉ ',rhumb) where rhumb = 'ЮВ' ;
            UPDATE is_grib.grib_wind_speed_dir2 SET name = 'Направление и скорость ветра' ; " >> $sql

    	    export PGPASSWORD='Prime#52'
    	    psql --host=172.24.2.192 --username=bpd_owner --dbname=bpd_postgis_dev --file=$sql > /dev/null 2>&1
    	fi
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

cat ./grib_work_tmp/all.txt | grep -E 'grd' | while read line; do
    
    var=$(echo $line | cut -d' ' -f1)
    elev=$(echo $line | cut -d' ' -f2)
    band=$(echo $line | cut -d' ' -f3)

    if [ "$elev" = "surf" -o "$elev" = "2m" -o "$elev" = "10m" -o "$elev" = "all"  ]; then
    	make_tifs $var $band $elev
    fi
done


if_wind=$(ls $tmpdir/*grd* > /dev/null 2>&1)
if [ $(echo $?) = 0 ]; then    
    proc_wind
fi


## cleanup and exit
cleanup
exit 0



