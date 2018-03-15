#!/bin/sh

usage()
{
    echo "Использование: $(basename $0) [-i] [-p] [-h] GRIB-file
   [-i] - вывод информации о файле
   [-p] - обработка данных
   [-h] - вывод справки "
}

cleanup()
{
    rm -rf ./tmp/
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
    if [ ! -d ./tmp/ ]; then
	mkdir ./tmp/
    fi
    meta='./tmp/gdalinfo.meta'
    if [ ! -e "$meta" ]; then
	gdalinfo $file > $meta 2>/dev/null
    fi
}

grib_check()
{
    if_grib=$(cat ./tmp/gdalinfo.meta | grep 'Driver:' | grep 'GRIB')
    if [ -z "$if_grib" ]; then
	echo 'Выбранный файл не является GRIB-файлом!'
	cleanup	
	exit 1
    fi
}

info()
{
    maketmp
    grib_check

    export LC_ALL=ru_RU.UTF-8
    
    echo 'Информация о файле'
    echo '==================\n'

    size=$(ls -sh $file | cut -d' ' -f1)
    echo "Размер файла: $size"
    echo '------------------\n'    

    echo 'Разрешение растра (град.):\n'
    cat ./tmp/gdalinfo.meta | grep 'Pixel Size' | cut -d'=' -f2 \
	| cut -d',' -f1 | sed -e 's/(//' -e 's/ //' | awk '{printf "%.2f\n", $1}'
    echo '------------------\n'
    
    echo 'Дата(ы) выпуска прогноза:\n'
    cat ./tmp/gdalinfo.meta | grep GRIB_REF_TIME  \
	| grep -oh '[0-9]*' \
	| while read i; do date -d@$i; done | sort | uniq
    echo '------------------\n'

    echo 'Дата(ы) прогноза:\n'
    cat ./tmp/gdalinfo.meta | grep GRIB_VALID_TIME \
	| grep -oh '[0-9]*' \
	| while read i; do date -d@$i; done | sort | uniq
    echo '------------------\n'

    echo 'Перечень данных:\n'
    cat ./tmp/gdalinfo.meta | grep GRIB_COMMENT \
    	| sort | uniq | cut -d'=' -f2
    echo '------------------\n'



}

find_data()
{
    # Канал с температурой
    tmp_band=$(cat ./tmp/gdalinfo.meta | grep -B7 -A2 'GRIB_ELEMENT=TMP' \
		      | grep -B1 'SFC\=\"Ground or water surface\"' \
		      | head -n1 | cut -d' ' -f2)
    if [ -z "$tmp_band"  ]; then
	tmp_band=$(cat ./tmp/gdalinfo.meta | grep -B7 -A2 'GRIB_ELEMENT=TMP' \
			  | grep -B1 'HTGL\=\"Specified height level above ground\"' \
			  | head -n1 | cut -d' ' -f2)
    fi

    echo "Температура [C] на уровне 2 м над поверхностью: канал $tmp_band \n"
    echo $tmp_band > ./tmp/tmp_band    

    # Канал с влажностью воздуха?
    
}




proc()
{
    maketmp
    grib_check
    find_data

    echo 'Обработка данных GRIB'
    echo '---------------------\n'
    
    echo "Температура [C] на уровне 2 м над поверхностью: канал $tmp_band \n"        
    tmp_band=$(cat ./tmp/tmp_band)

    gdal_translate -q -ot Int16 -r bilinear \
    		   -co "COMPRESS=PACKBITS" -co "TILED=YES"  \
    		   -b $tmp_band -a_nodata -9999 -a_srs "EPSG:4326" \
    		   $file ./tmp/tmp1.tif
    gdalwarp -q -ot Int16 -s_srs "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +pm=-360" \
    	     -t_srs "EPSG:4326" ./tmp/tmp1.tif ./tmp/tmp2.tif
    gdal_merge.py -q -o ./tmp/tmp3.tif ./tmp/tmp1.tif ./tmp/tmp2.tif
    gdalwarp -q -dstnodata -9999 -te -180 -90 180 90 ./tmp/tmp3.tif ./tmp/tmp.tif
    gdaladdo -q --config COMPRESS_OVERVIEW DEFLATE ./tmp/tmp.tif 2 4 8 16

    mv ./tmp/tmp.tif tmp.tif

    # extract_values.py /home/amuriy/Desktop/osm_towns_rus.shp ./tmp/tmp.tif
    
}

## main
if [ -z "$*" ]; then
    usage
    exit 1
fi

while getopts "i:p:h" opt; do
    case $opt in
	i)  file=$OPTARG
	    info ;;
	p)  file=$OPTARG
	    proc ;;
	h) usage ;;
	*) usage ;;
    esac
done




## cleanup and exit
cleanup
exit 0



