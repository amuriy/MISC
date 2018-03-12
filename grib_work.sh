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
    if_grib=$(cat ./tmp/gdalinfo.meta | head \
		     | grep 'Driver:' | grep 'GRIB')
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

    echo 'Разрешение растра:\n'
    cat ./tmp/gdalinfo.meta | grep 'Pixel Size' | cut -d'=' -f2 \
	| cut -d',' -f1 | sed -e 's/(//' -e 's/ //' | awk '{printf "%.2f\n", $1}'
    echo '------------------\n'
    
    echo 'Дата выпуска прогноза:\n'
    cat ./tmp/gdalinfo.meta | grep GRIB_REF_TIME  \
	| grep -oh '[0-9]*' \
	| while read i; do date -d@$i; done | uniq
    echo '------------------\n'

    echo 'Дата(ы) прогноза:\n'
    cat ./tmp/gdalinfo.meta | grep GRIB_VALID_TIME \
	| grep -oh '[0-9]*' \
	| while read i; do date -d@$i; done | uniq
    echo '------------------\n'

    echo 'Перечень данных:\n'
    # cat ./tmp/gdalinfo.meta | grep GRIB_COMMENT \
    # 	| sort | uniq | cut -d'=' -f2
    # echo '------------------\n'

    cat ./tmp/gdalinfo.meta | grep -B7 -A2 'GRIB_SHORT_NAME=2-HTGL' \
	| while read i; do
	b=$(echo $i | grep Band)
	x=$(echo $i | grep GRIB_VALID_TIME | grep -oh '[0-9]*' \
		   | while read i; do date -d@$i; done)
	echo $b $x; done | uniq
    
}

proc()
{
    maketmp
    grib_check

    echo 'Обработка данных GRIB'
    echo '---------------------\n'

    # tmp_band=
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



