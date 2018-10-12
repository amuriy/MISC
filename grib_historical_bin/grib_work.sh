#!/bin/bash

cleanup()
{
    tmpdir="tmp_${file}"
    rm -rf $tmpdir
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
    tmpdir="tmp_${file}"
    if [ ! -d $tmpdir ]; then
	mkdir -p $tmpdir
    fi
    meta="$tmpdir/gdalinfo.meta"
    if [ ! -e "$meta" ]; then
	gdalinfo $file | grep -v 'NoData' > $meta 2>/dev/null
    fi    
}

grib_check()
{
    if_grib=$(cat $tmpdir/gdalinfo.meta | grep 'Driver:' | grep 'GRIB')
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

    cat $tmpdir/gdalinfo.meta | grep GRIB_VALID_TIME \
	| grep -oh '[0-9]*' \
	| while read i; do date -u -d@$i '+%Y-%m-%d %H:%M:%S'; done \
	| sort | uniq | sed 's/00 /00\n/g' > $tmpdir/date_utc       
    cat $tmpdir/gdalinfo.meta | grep GRIB_VALID_TIME \
	| grep -oh '[0-9]*' \
	| while read i; do date -d@$i '+%Y-%m-%d %H:%M:%S'; done \
	| sort | uniq | sed 's/00 /00\n/g' > $tmpdir/date0
    cat $tmpdir/date0 | while read i; do
	d=$(date --date="$i" '+%Y%m%d%H') 
	echo $i | sed "s/$i/$d/ " > $tmpdir/date1
    done
}

data_list()
{
    cat $tmpdir/gdalinfo.meta | grep -B4 -A2 'GRIB_ELEMENT' \
	| while read meta; do
	var=$(echo $meta | grep 'GRIB_ELEMENT' | cut -d'=' -f2 | tr '[:upper:]' '[:lower:]')
	band=$(echo $meta | grep 'Band' | cut -d' ' -f2)
	elev=$(echo $meta | grep 'Description' | cut -d'=' -f2)

	case "$elev" in
	    ' 0[-] 0DEG')
		elev='0deg'
		;;
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

	echo $var $band $elev >> $tmpdir/all_0.txt
		
    done

    cat $tmpdir/all_0.txt | sed '/^$/d' | sed -n '3~3p' > $tmpdir/vars
    cat $tmpdir/all_0.txt | sed '/^$/d' | sed -n '2~3p' > $tmpdir/elevs
    cat $tmpdir/all_0.txt | sed '/^$/d' | sed -n '1~3p' > $tmpdir/bands
    
    paste -d'|' $tmpdir/vars \
    	  $tmpdir/elevs $tmpdir/bands \
    	| grep -v 'tmp|2m' > $tmpdir/all.txt

}

make_tifs()
{
    var=$1
    band=$2
    elev=$3

    tifname=$var'_'$elev'_'$date1'.tif'
    
    case "$var" in
	'crain'|'csnow'|'prate'|'pres'|'apcp03')
	    ot='Float64'
	    ;;
	*)
    	    ot='Int16'
    	    ;;	    
    esac

    gdal_translate -q -co "COMPRESS=PACKBITS" -co "TILED=YES" \
    		   -ot $ot -b $band -a_srs "EPSG:4326" $file $tmpdir/temp1.tif  > /dev/null 2>&1
    gdalwarp -q -s_srs "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +pm=-360" \
    	     -t_srs "EPSG:4326" $tmpdir/temp1.tif $tmpdir/temp2.tif  > /dev/null 2>&1
    gdal_merge.py -q -o $tmpdir/temp3.tif $tmpdir/temp1.tif $tmpdir/temp2.tif > /dev/null 2>&1

    gdalwarp -q -te -180 -90 180 90 $tmpdir/temp3.tif $tmpdir/$tifname > /dev/null 2>&1    

}

proc_wind()
{
    find $tmpdir -type f -name "*grd*.tif" | cut -d'/' -f3 | cut -d'_' -f2 | sed 's/.tif//' \
    	| sort | uniq | while read elev; do
    	u_tif=$(find $tmpdir -type f -name "ugrd_${elev}_${date1}.tif")
    	v_tif=$(find $tmpdir -type f -name "vgrd_${elev}_${date1}.tif")

	echo $u_tif $v_tif
	
    	gdal_calc.py -A "$u_tif" -B "$v_tif" --outfile="${outdir}/wind_speed_${elev}_${date1}.tif" --calc="sqrt(A*A+B*B)" > /dev/null 2>&1
	python $bin_dir/wind_dir.py "$u_tif" "$v_tif" "${outdir}/wind_direct_${elev}_${date1}.tif" > /dev/null 2>&1	
    done

}
proc_pres()
{
    pres_tif=$(find $tmpdir -type f -name "pres_surf_${date1}.tif")
    gdal_calc.py -A "$pres_tif" --outfile="${outdir}/pres_surf_${date1}.tif" --calc="A/100" > /dev/null 2>&1
}


## main
if [ -z "$*" ]; then
    exit 1
fi

bin_dir="$(dirname $0)"
file=$1
outdir=$2

# echo $file

if [ -z "$outdir" ]; then
    outdir=$(pwd)
fi
if [ ! -d "$outdir" ]; then   
    mkdir "$outdir"
fi    

info
data_list

tmpdir="tmp_${file}"
date1=$(cat $tmpdir/date1 | head -n1)
date0=$(cat $tmpdir/date0 | head -n1)
date_utc=$(cat $tmpdir/date_utc | head -n1)

# echo $date0

cat $tmpdir/all.txt | grep -E 'tmp|grd|apcp03|tcdc|dpt|pres|rh|vis|cape|gust|snod|hgt' | while read line; do
    var=$(echo $line | cut -d'|' -f1)
    elev=$(echo $line | cut -d'|' -f2)
    band=$(echo $line | cut -d'|' -f3)
    
    if [ "$elev" = "surf" -o "$elev" = "2m" -o "$elev" = "10m" -o "$elev" = "all" -o "$elev" = "0deg" ]; then
    	make_tifs $var $band $elev
    fi
done

find $tmpdir -type f -name "*tmp*.tif" -exec cp -f "{}" $outdir \;
find $tmpdir -type f -name "*apcp*.tif" -exec cp -f "{}" $outdir \;
find $tmpdir -type f -name "*dpt*.tif" -exec cp -f "{}" $outdir \;
find $tmpdir -type f -name "*tcdc*.tif" -exec cp -f "{}" $outdir \;
find $tmpdir -type f -name "*rh_2m*.tif" -exec cp -f "{}" $outdir \;
find $tmpdir -type f -name "*gust*.tif" -exec cp -f "{}" $outdir \;
find $tmpdir -type f -name "*cape*.tif" -exec cp -f "{}" $outdir \;
find $tmpdir -type f -name "*snod*.tif" -exec cp -f "{}" $outdir \;
find $tmpdir -type f -name "*hgt_0deg*.tif" -exec cp -f "{}" $outdir \;

if_wind=$(ls $tmpdir/*grd* > /dev/null 2>&1)
if [ $(echo $?) = 0 ]; then    
    proc_wind
fi

proc_pres


## cleanup and exit
cleanup
exit 0



