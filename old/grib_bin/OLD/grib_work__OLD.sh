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
    
    echo 'Информация о файле'
    echo '==================\n'

    size=$(ls -sh $file | cut -d' ' -f1)
    echo "Размер файла: $size"
    echo '------------------\n'

    bands=$(cat ./grib_work_tmp/gdalinfo.meta | grep 'Band' | wc -l)
    echo "Число каналов: $bands"
    echo '------------------\n'        

    echo 'Разрешение растра (град.):\n'
    cat ./grib_work_tmp/gdalinfo.meta | grep 'Pixel Size' | cut -d'=' -f2 \
	| cut -d',' -f1 | sed -e 's/(//' -e 's/ //' | awk '{printf "%.2f\n", $1}'
    echo '------------------\n'
    
    echo 'Дата(ы) выпуска прогноза:\n'
    date0=$(cat ./grib_work_tmp/gdalinfo.meta | grep GRIB_REF_TIME \
		   | grep -oh '[0-9]*' \
		   | while read i; do date -d@$i '+%Y-%m-%d %H:%M:%S'; done | sort | uniq)
    echo $date0
    echo '------------------\n'

    echo 'Дата(ы) прогноза:\n'
    cat ./grib_work_tmp/gdalinfo.meta | grep GRIB_VALID_TIME \
	| grep -oh '[0-9]*' \
	| while read i; do date -d@$i '+%Y-%m-%d %H:%M:%S'; done \
	| sort | uniq | sed 's/00 /00\n/g' | tee ./grib_work_tmp/date1
    cat ./grib_work_tmp/date1 | while read i; do
	d=$(date --date="$i" '+%Y-%m-%d_%H%M%S')
	sed -i "s/$i/$d/ " ./grib_work_tmp/date1
    done
    echo '------------------\n'    
    
    # echo 'Перечень данных:\n'
    # cat ./grib_work_tmp/gdalinfo.meta | grep GRIB_COMMENT \
    # 	| sort | uniq | cut -d'=' -f2
    # echo '------------------\n'

    echo 'Перечень высотных уровней:\n'
    cat ./grib_work_tmp/gdalinfo.meta | grep Description | sort | uniq | sed 's/  Description = //'
    echo '------------------\n'
}


find_data()
{
    echo "Список необходимых данных:"
    echo '------------------\n'
    
    ## TMP
    tmp_band=$(cat ./grib_work_tmp/gdalinfo.meta | grep -B7 -A2 'GRIB_ELEMENT=TMP' \
		      | grep -B1 'SFC\=\"Ground or water surface\"' \
		      | head -n1 | cut -d' ' -f2)
    if [ -z "$tmp_band"  ]; then
	tmp_band=$(cat ./grib_work_tmp/gdalinfo.meta | grep -B7 -A2 'GRIB_ELEMENT=TMP' \
			  | grep -B1 'HTGL\=\"Specified height level above ground\"' \
			  | head -n1 | cut -d' ' -f2)
    fi
    if [ -z "$tmp_band"  ]; then
	echo "Температура воздуха (TMP): данные не найдены \n" 
    else
	echo "Температура воздуха (TMP): канал $tmp_band \n" 
	echo $tmp_band > ./grib_work_tmp/tmp_band
    fi

    ## PRATE
    prate_band=$(cat ./grib_work_tmp/gdalinfo.meta | grep -B7 -A2 'GRIB_ELEMENT=PRATE' \
		      | grep -B1 'SFC\=\"Ground or water surface\"' \
		      | head -n1 | cut -d' ' -f2)
    if [ -z "$prate_band" ]; then
	echo "Средняя интенсивность осадков (PRATE): данные не найдены \n"
    else

    	echo "Средняя интенсивность осадков (PRATE): канал $prate_band \n"
	echo $prate_band > ./grib_work_tmp/prate_band
    fi

    ## APCP03 
    precip_band=$(cat ./grib_work_tmp/gdalinfo.meta | grep -B4 -A2 'GRIB_ELEMENT=APCP' \
		      | head -n1 | cut -d' ' -f2)
    if [ -z "$precip_band" ]; then
	echo "Количество осадков (APCP): данные не найдены \n"
    else
	echo "Количество осадков (APCP): канал $precip_band \n"
	echo $precip_band > ./grib_work_tmp/precip_band
    fi   

    ## CRAIN
    crain_band=$(cat ./grib_work_tmp/gdalinfo.meta | grep -B4 -A2 'GRIB_ELEMENT=CRAIN' \
		      | head -n1 | cut -d' ' -f2)
    if [ -z "$crain_band" ]; then
	echo "Зоны жидких осадков (CRAIN): данные не найдены \n"
    else
	echo "Зоны жидких осадков (CRAIN): канал $crain_band \n"
	echo $crain_band > ./grib_work_tmp/crain_band
    fi   

    ## CSNOW
    csnow_band=$(cat ./grib_work_tmp/gdalinfo.meta | grep -B4 -A2 'GRIB_ELEMENT=CSNOW' \
		      | head -n1 | cut -d' ' -f2)
    if [ -z "$csnow_band" ]; then
	echo "Зоны твёрдых осадков (CSNOW): данные не найдены \n"
    else
	echo "Зоны твёрдых осадков (CSNOW): канал $csnow_band \n"
	echo $csnow_band > ./grib_work_tmp/csnow_band
    fi
    
    ## UGRD
    ugrd_band=$(cat ./grib_work_tmp/gdalinfo.meta | grep -B4 -A2 'GRIB_ELEMENT=UGRD' \
		      | grep -B1 '10\[m\] HTGL="Specified height level above ground"'\
		      | head -n1 | cut -d' ' -f2)
    if [ -z "$ugrd_band" ]; then
	echo "U-компонента ветра (UGRD): данные не найдены \n"
    else
	echo "U-компонента ветра (UGRD): канал $ugrd_band \n"
	echo $ugrd_band > ./grib_work_tmp/ugrd_band
    fi
    
    ## VGRD
    vgrd_band=$(cat ./grib_work_tmp/gdalinfo.meta | grep -B4 -A2 'GRIB_ELEMENT=VGRD' \
		       | grep -B1 '10\[m\] HTGL="Specified height level above ground"'\
		       | head -n1 | cut -d' ' -f2)
    if [ -z "$vgrd_band" ]; then
	echo "V-компонента ветра (VGRD): данные не найдены \n"
    else
	echo "V-компонента ветра (VGRD): канал $vgrd_band \n"
	echo $vgrd_band > ./grib_work_tmp/vgrd_band
    fi   

    ## ICEC
    icec_band=$(cat ./grib_work_tmp/gdalinfo.meta | grep -B4 -A2 'GRIB_ELEMENT=ICEC' \
		      | head -n1 | cut -d' ' -f2)
    if [ -z "$icec_band" ]; then
	echo "Покрытие льдами (ICEC): данные не найдены \n"
    else
	echo "Покрытие льдами (ICEC): канал $icec_band \n"
	echo $icec_band > ./grib_work_tmp/icec_band
    fi   

    ## DPT
    dpt_band=$(cat ./grib_work_tmp/gdalinfo.meta | grep -B4 -A2 'GRIB_ELEMENT=DPT' \
		      | head -n1 | cut -d' ' -f2)
    if [ -z "$dpt_band" ]; then
	echo "Точка росы (DPT): данные не найдены \n"
    else
	echo "Точка росы (DPT): канал $dpt_band \n"
	echo $dpt_band > ./grib_work_tmp/dpt_band
    fi

    ## VIS
    vis_band=$(cat ./grib_work_tmp/gdalinfo.meta | grep -B4 -A2 'GRIB_ELEMENT=VIS' \
		      | head -n1 | cut -d' ' -f2)
    if [ -z "$vis_band" ]; then
	echo "Горизонтальная видимость (VIS): данные не найдены \n"
    else
	echo "Горизонтальная видимость (VIS): канал $vis_band \n"
	echo $vis_band > ./grib_work_tmp/vis_band
    fi

    ## TCDC
    tcdc_band=$(cat ./grib_work_tmp/gdalinfo.meta | grep -B4 -A2 'GRIB_ELEMENT=TCDC' \
		      | grep -B1 'Reserved' \
		      | head -n1 | cut -d' ' -f2)    
    if [ -z "$tcdc_band" ]; then
	echo "Облачность (TCDC): данные не найдены \n"
    else
	echo "Облачность (TCDC): канал $tcdc_band \n"
	echo $tcdc_band > ./grib_work_tmp/tcdc_band
    fi     
    
    ## PRES
    pres_band=$(cat ./grib_work_tmp/gdalinfo.meta | grep -B7 -A2 'GRIB_ELEMENT=PRES' \
		      | grep -B1 'SFC\=\"Ground or water surface\"' \
		      | head -n1 | cut -d' ' -f2)
    if [ -z "$pres_band" ]; then
	echo "Атмосферное давление (PRES): данные не найдены \n"
    else
	echo "Атмосферное давление (PRES): канал $pres_band \n"
	echo $pres_band > ./grib_work_tmp/pres_band
    
    fi

    ## GUST
    gust_band=$(cat ./grib_work_tmp/gdalinfo.meta | grep -B7 -A2 'GRIB_ELEMENT=GUST' \
		      | grep -B1 'SFC\=\"Ground or water surface\"' \
		      | head -n1 | cut -d' ' -f2)
    if [ -z "$gust_band" ]; then
	echo "Шквал (GUST): данные не найдены \n"
    else
	echo "Шквал (GUST): канал $gust_band \n"
	echo $gust_band > ./grib_work_tmp/gust_band
    
    fi
    
    

    
    
}


proc()
{    
    info
    find_data

    # grid_lyr=$(ogrinfo $grid_shp | tail -n1 | cut -d' ' -f2)
    # grid_tmp='./grib_work_tmp/tmp.shp'
    # ogr2ogr -dialect SQLite $grid_tmp $grid_shp \
    # 	    -sql "select geometry from ${grid_lyr}"
    # ogr2ogr -overwrite $grid_shp $grid_tmp

    # towns_lyr=$(ogrinfo $towns_shp | tail -n1 | cut -d' ' -f2)
    # towns_tmp='./grib_work_tmp/tmp2.shp'
    # ogr2ogr -dialect SQLite $towns_tmp $towns_shp \
    # 	    -sql "select geometry from ${towns_lyr}"
    # ogr2ogr -overwrite $towns_shp $towns_tmp


    fullpath=$(readlink -f $file)    
    tif_dir=$(dirname $fullpath)/$(basename $file)__tif
    
    if [ ! -d $tif_dir ]; then
    	mkdir $tif_dir
    fi

    echo 'Обработка данных GRIB'
    echo '=====================\n'
    
    date1=$(cat ./grib_work_tmp/date1 | head -n1)
    grib_name=$(basename $file)

    echo "Температура воздуха"
    echo '-------------------\n'

    echo "Получение растра температуры..."
    echo ""

    if [ ! -f ./grib_work_tmp/tmp_band ]; then
    	echo "Данные не найдены! Завершение работы.\n"
    	cleanup
    	exit 1
    fi	
    
    tmp_band=$(cat ./grib_work_tmp/tmp_band)
    
    gdal_translate -q -co "COMPRESS=PACKBITS" -co "TILED=YES" \
    		   -ot Int16 -b $tmp_band -a_nodata -9999 -a_srs "EPSG:4326" \
    		   $file ./grib_work_tmp/tmp1.tif
    gdalwarp -q -s_srs "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +pm=-360" \
    	     -t_srs "EPSG:4326" ./grib_work_tmp/tmp1.tif ./grib_work_tmp/tmp2.tif
    gdal_merge.py -q -o ./grib_work_tmp/tmp3.tif ./grib_work_tmp/tmp1.tif ./grib_work_tmp/tmp2.tif
    gdalwarp -q -r cubicspline -tr 0.25 0.25 ./grib_work_tmp/tmp3.tif ./grib_work_tmp/tmp4.tif
    
    temper_tif="${tif_dir}/temper_${date1}.tif"
    cp -f ./grib_work_tmp/tmp4.tif $temper_tif
    echo "Растр: $temper_tif"

    echo ""
    echo "Извлечение данных в точках городов..."
    echo ""
    bin/extract_values.py -q $towns_shp $temper_tif > /dev/null 2>&1
    field=$(ogrinfo -al -so $towns_shp | tail -n1 | cut -d':' -f1)
    echo SHP-файл: "$towns_shp"\; поле: "$field"
    echo ""
    echo ""

    
    echo ""
    echo "Загрузка данных в БД..."
    echo ""
    
    shp=$grid_shp
    sql='./grib_work_tmp/wind.sql'
    csv='./grib_work_tmp/wind.csv'


echo '
CREATE TABLE "IS_STUFF".osm_towns_rus2
(
  objectid serial NOT NULL,
  shape geometry(Point,4326),
  admin_leve character varying(254),
  name character varying(254),
  population integer,
  time_data timestamp(0) without time zone,
  temper double precision,
  CONSTRAINT osm_towns_rus2_pkey PRIMARY KEY (objectid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE "IS_STUFF".osm_towns_rus2
  OWNER TO bpd_owner;
GRANT SELECT ON TABLE "IS_STUFF".osm_towns_rus2 TO "BPD_READERS";
GRANT ALL ON TABLE "IS_STUFF".osm_towns_rus2 TO bpd_owner; ' >> $sql

    




    
    echo '=====================\n'
    
    echo "Скорость и направление ветра"
    echo '----------------------------\n'
    echo "Получение растров U- и V-компонент ветра..."
    echo ""


    if [ ! -f ./grib_work_tmp/ugrd_band ] || [ ! -f ./grib_work_tmp/vgrd_band ]; then
    	echo "Данные не найдены! Завершение работы.\n"
    	cleanup
    	exit 1
    fi	
    
    ugrd_band=$(cat ./grib_work_tmp/ugrd_band)
    vgrd_band=$(cat ./grib_work_tmp/vgrd_band)

    gdal_translate -q -co "COMPRESS=PACKBITS" -co "TILED=YES" \
    		   -ot Int16 -b $ugrd_band -a_nodata -9999 -a_srs "EPSG:4326" \
    		   $file ./grib_work_tmp/ugrd1.tif
    gdalwarp -q -s_srs "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +pm=-360" \
    	     -t_srs "EPSG:4326" ./grib_work_tmp/ugrd1.tif ./grib_work_tmp/ugrd2.tif
    gdal_merge.py -q -o ./grib_work_tmp/ugrd3.tif \
    		  ./grib_work_tmp/ugrd1.tif ./grib_work_tmp/ugrd2.tif
    gdalwarp -q -r cubicspline -tr 0.25 0.25  \
    	     ./grib_work_tmp/ugrd3.tif ./grib_work_tmp/ugrd4.tif

    gdal_translate -q -co "COMPRESS=PACKBITS" -co "TILED=YES" \
    		   -ot Int16 -b $vgrd_band -a_nodata -9999 -a_srs "EPSG:4326" \
    		   $file ./grib_work_tmp/vgrd1.tif
    gdalwarp -q -s_srs "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +pm=-360" \
    	     -t_srs "EPSG:4326" ./grib_work_tmp/vgrd1.tif ./grib_work_tmp/vgrd2.tif
    gdal_merge.py -q -o ./grib_work_tmp/vgrd3.tif \
    		  ./grib_work_tmp/vgrd1.tif ./grib_work_tmp/vgrd2.tif
    gdalwarp -q -r cubicspline -tr 0.25 0.25 \
    	     ./grib_work_tmp/vgrd3.tif ./grib_work_tmp/vgrd4.tif

    # wind speed
    gdal_calc.py --quiet -A ./grib_work_tmp/ugrd4.tif -B ./grib_work_tmp/vgrd4.tif \
    		 --outfile=./grib_work_tmp/speed.tif \
    		 --calc="sqrt(A*A+B*B)" > /dev/null 2>&1

    speed_tif="$tif_dir/wspeed_${date1}.tif"
    cp -f ./grib_work_tmp/speed.tif $speed_tif
    echo "Растр скорости ветра: $speed_tif"
    
    # wind direct
    direct_tif="$tif_dir/wdirect_${date1}.tif"
    sed -i "s+fileName1 =.*+fileName1 = \'\.\/grib_work_tmp\/ugrd4.tif\'+g" bin/wind_dir.py
    sed -i "s+fileName2 =.*+fileName2 = \'\.\/grib_work_tmp\/vgrd4.tif\'+g" bin/wind_dir.py
    sed -i "s+outFile =.*+outFile = '$direct_tif'+g" bin/wind_dir.py

    python bin/wind_dir.py

    echo "Растр направления ветра: $direct_tif"
    
    echo ""
    echo "Извлечение данных по сетке..."
    echo ""
    bin/extract_values.py -q $grid_shp $speed_tif $direct_tif > /dev/null 2>&1
    field=$(ogrinfo -al -so $grid_shp | tail -n2 | grep wspeed | cut -d':' -f1)
    echo SHP-файл: "$grid_shp"\; поле: "$field"
    echo ""
    echo ""
    
    
    if [ -f ./grib_work_tmp/pres_band ]; then
	echo "Атмосферное давление"
	echo '----------------------------\n'	
    	pres_band=$(cat ./grib_work_tmp/pres_band)
    	gdal_translate -q -co "COMPRESS=PACKBITS" -co "TILED=YES" \
    		       -b $pres_band -a_nodata -9999 -a_srs "EPSG:4326" \
    		       $file ./grib_work_tmp/pres1.tif
    	gdalwarp -q -s_srs "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +pm=-360" \
    		 -t_srs "EPSG:4326" ./grib_work_tmp/pres1.tif ./grib_work_tmp/pres2.tif
    	gdal_merge.py -q -o ./grib_work_tmp/pres3.tif \
    		      ./grib_work_tmp/pres1.tif ./grib_work_tmp/pres2.tif
    	gdalwarp -q -r cubicspline -tr 0.25 0.25  \
    		 ./grib_work_tmp/pres3.tif ./grib_work_tmp/pres4.tif    
    	gdal_calc.py -A ./grib_work_tmp/pres4.tif --outfile=./grib_work_tmp/pres5.tif --calc="A/100"
    	pres_tif="$tif_dir/pres_${date1}.tif"
    	cp -f ./grib_work_tmp/pres5.tif $pres_tif
    	echo "Растр атмосферного давления: $pres_tif"
    fi

    if [ -f ./grib_work_tmp/prate_band ]; then
	echo "Средняя интенсивность осадков"
	echo '----------------------------\n'	
	prate_band=$(cat ./grib_work_tmp/prate_band)
	gdal_translate -q -co "COMPRESS=PACKBITS" -co "TILED=YES" \
    		       -b $prate_band -a_nodata -9999 -a_srs "EPSG:4326" \
    		       $file ./grib_work_tmp/prate1.tif
	gdalwarp -q -s_srs "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +pm=-360" \
    		 -t_srs "EPSG:4326" ./grib_work_tmp/prate1.tif ./grib_work_tmp/prate2.tif
	gdal_merge.py -q -o ./grib_work_tmp/prate3.tif \
    		      ./grib_work_tmp/prate1.tif ./grib_work_tmp/prate2.tif
	gdalwarp -q -r cubicspline -tr 0.25 0.25  \
    		 ./grib_work_tmp/prate3.tif ./grib_work_tmp/prate4.tif    
	gdal_calc.py --quiet -A ./grib_work_tmp/prate4.tif --outfile=./grib_work_tmp/prate5.tif --calc="(A*3600)"
	prate_tif="$tif_dir/prate_${date1}.tif"
	cp -f ./grib_work_tmp/prate5.tif $prate_tif
	echo "Растр средней интенсивности осадков: $prate_tif"
    fi
    

    if [ -f ./grib_work_tmp/precip_band ]; then
	echo "Количество осадков за 3 часа"
	echo '----------------------------\n'	
	precip_band=$(cat ./grib_work_tmp/precip_band)
	gdal_translate -q -co "COMPRESS=PACKBITS" -co "TILED=YES" \
    		       -b $precip_band -a_nodata -9999 -a_srs "EPSG:4326" \
    		       $file ./grib_work_tmp/precip1.tif
	gdalwarp -q -s_srs "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +pm=-360" \
    		 -t_srs "EPSG:4326" ./grib_work_tmp/precip1.tif ./grib_work_tmp/precip2.tif
	gdal_merge.py -q -o ./grib_work_tmp/precip3.tif \
    		      ./grib_work_tmp/precip1.tif ./grib_work_tmp/precip2.tif
	gdalwarp -q -r cubicspline -tr 0.25 0.25  \
    		 ./grib_work_tmp/precip3.tif ./grib_work_tmp/precip4.tif    
	gdal_calc.py --quiet -A ./grib_work_tmp/precip4.tif --outfile=./grib_work_tmp/precip5.tif --calc="(A*3600)"
	precip_tif="$tif_dir/precip_${date1}.tif"
	cp -f ./grib_work_tmp/precip5.tif $precip_tif
	echo "Растр количества осадков за 3 часа: $precip_tif"
    fi

    
    if [ -f ./grib_work_tmp/crain_band ] && [ -f ./grib_work_tmp/csnow_band ]; then
	echo "Зоны осадков"
	echo '----------------------------\n'	
	precip_band=$(cat ./grib_work_tmp/precip_band)
	gdal_translate -q -co "COMPRESS=PACKBITS" -co "TILED=YES" \
    		       -b $precip_band -a_nodata -9999 -a_srs "EPSG:4326" \
    		       $file ./grib_work_tmp/precip1.tif
	gdalwarp -q -s_srs "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +pm=-360" \
    		 -t_srs "EPSG:4326" ./grib_work_tmp/precip1.tif ./grib_work_tmp/precip2.tif
	gdal_merge.py -q -o ./grib_work_tmp/precip3.tif \
    		      ./grib_work_tmp/precip1.tif ./grib_work_tmp/precip2.tif
	gdalwarp -q -r cubicspline -tr 0.25 0.25  \
    		 ./grib_work_tmp/precip3.tif ./grib_work_tmp/precip4.tif    
	gdal_calc.py --quiet -A ./grib_work_tmp/precip4.tif --outfile=./grib_work_tmp/precip5.tif --calc="(A*3600)"
	precip_tif="$tif_dir/precip_${date1}.tif"
	cp -f ./grib_work_tmp/precip5.tif $precip_tif
	echo "Растр количества осадков за 3 часа: $precip_tif"
    fi

    
    
    







    # echo "Ледовая кромка"

    # echo "Точка росы"

    # echo "Горизонтальная видимость"



    # echo "Облачность"

    # echo "Нижняя граница облачности"
    

    


    # echo '=====================\n'        
    # echo "Создаём индесные таблицы для временнЫх растровых данных"
    # echo '-------------------------------------------------------\n'
        
    # index_sql='./grib_work_tmp/index_tables.sql'
    # rm -f $index_sql
    
    # for var in cloud cloud_base dew fog frain gust \
    # 		     hurr icec magn prate precip precip_zones \
    # 		     pres rh storm temper vis waves; do
    # 	echo "
    # CREATE TABLE \"IS_TEST\".grib_"$var"_time_index
    # (
    # 	objectid serial NOT NULL,
    # 	shape geometry(Polygon,4326),
    # 	location character varying(254),
    # 	time_data timestamp(0) without time zone DEFAULT now(),
    # 	CONSTRAINT grib_"$var"_time_index_pkey PRIMARY KEY (objectid)
    # )
    # WITH (
    # 	OIDS=FALSE
    # );
    # ALTER TABLE \"IS_TEST\".grib_"$var"_time_index
    # OWNER TO \"BPD_OWNERS\";
    # GRANT ALL ON TABLE \"IS_TEST\".grib_"$var"_time_index TO \"BPD_OWNERS\";
    # GRANT SELECT ON TABLE \"IS_TEST\".grib_"$var"_time_index TO \"BPD_READERS\"; " >> $index_sql
    # done

    # export PGPASSWORD='Prime#52'
    # psql -w --host=172.24.2.192 --username=bpd_owner \
    # 	 --dbname=bpd_postgis_dev --file=$index_sql
    


    
    
    

    


    
    

    
}

## main
if [ -z "$*" ]; then
    usage
    exit 1
fi

grid_shp='/home/amuriy/Desktop/GRIB/data/shp/grid_1.shp'
towns_shp='/home/amuriy/Desktop/GRIB/data/shp/towns.shp'

while getopts "i:p:h" opt; do
    case $opt in
	i)  file=$OPTARG
	    info
	    find_data ;;
	p)  file=$OPTARG
	    proc ;;
	h) usage ;;
	*) usage ;;
    esac
done




## cleanup and exit
cleanup
exit 0



