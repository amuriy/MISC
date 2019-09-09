#!/bin/sh

# rm -rf /tmp/aopa
# mkdir /tmp/aopa
# cd /tmp/aopa

# wget http://aopa.ru/maps/root_v02.kmz
# unzip root_v02.kmz

# mkdir kml && cd kml
# cat ../doc.kml | grep -Po 'http(s?)://[^ \"()\<>]*.kmz' \
#     | while read link; do
#     wget $link
# done

# for kmz in *.kmz; do
#     dir=$(basename $kmz .kmz)
#     mkdir $dir
#     mv $kmz ${dir}/
#     cd $dir
#     unzip $kmz
#     cd -
# done

# rm -f /tmp/aopa/doc.kml


## 
# find /tmp/aopa/ -name "*.sqlite" | xargs rm -f

find /tmp/aopa/ -name "*.kml" | grep 199_v02 | while read kml; do
    kml_date=$(grep 'Дата обработки:' $kml \
		      | sed -e 's/<tr><td><b>//g' \
			    -e 's/<\/b><\/td><td>//g' \
			    -e 's/<\/td><\/tr>//g' \
		      | cut -d':' -f2-3)
    echo "$kml_date" > /tmp/kml_date

    name=$(echo $kml | cut -d'/' -f5)
    dirname=$(dirname $kml)
    sqlite="$dirname/$name.sqlite"
#     # flyr=$(ogrinfo -q -ro -so $kml | perl -pe 's/^[^ ]+ //g and s/ \([^()]+\)$//g' | head -n1)
#     flyr='A228'
#     ogr2ogr -f SQLite -nln $name $sqlite $kml "$flyr" --config "OGR_FORCE_ASCII NO"
    

#     ogrinfo -q -ro -so $kml \
#     	| perl -pe 's/^[^ ]+ //g and s/ \([^()]+\)$//g' | sed '1d' \
#     	| while read lyr; do
#     	ogr2ogr -append -f SQLite -nln $name $sqlite $kml "$lyr" --config "OGR_FORCE_ASCII NO"
#     done


#     sql=/tmp/${RANDOM}.sql
#     export PGPASSWORD=''

#     echo "DO \$\$
#     DECLARE
#     tables CURSOR FOR
#        SELECT tablename
#        FROM pg_tables
#        WHERE schemaname = 'is_aopa'
#        AND tablename LIKE 'tmp__%' ;
#   BEGIN
#     FOR table_record IN tables LOOP
#     EXECUTE 'DROP TABLE ' || 'is_aopa.' || '\"' || table_record.tablename || '\"'  ;
#     END LOOP;
#  END\$\$; " > $sql

#     psql --host=localhost --username=postgres --dbname=bpd_postgis_dev --file="$sql" > /dev/null 2>&1

#     #### разбиение SQLite-базы на shp-файлы по типу геометрии
#     for geom in POINT LINESTRING POLYGON; do
#     	shp="$dirname/${name}_${geom}.shp"
#     	ogr2ogr -skipfailures -f "ESRI Shapefile" "$shp" "$sqlite" -nlt "$geom" -lco ENCODING=UTF-8 # > /dev/null 2>&1
# 	ogr2ogr -skipfailures -f "ESRI Shapefile" "$shp" "$sqlite" -nlt "$geom" -lco ENCODING=UTF-8 # > /dev/null 2>&1

#     	if0=$(ogrinfo -al -so "$shp" | grep Feat | cut -d':' -f2 | sed 's/ //g')
#     	if [ $if0 != "0" ]; then	
#     	    tbl="tmp__${name}_${geom}"
#     	    echo $tbl
#     	    ogr2ogr -skipfailures -f "PostgreSQL" PG:"host=localhost user=postgres password='' dbname=bpd_postgis_dev" \
#     	    	    -lco SCHEMA="is_aopa" -nln "$tbl" -nlt "PROMOTE_TO_MULTI" "$shp" \
#     	    	    -lco GEOMETRY_NAME=shape -lco OVERWRITE=YES \
# 		    -lco ENCODING=UTF-8
#     	fi
	
	
#     done
    
done


# #### заливка из врЕменных таблиц в geoMulty* с формированием атрибутов в XML
# sql=/tmp/${RANDOM}.sql
# export PGPASSWORD=''

# echo 'truncate table "is_aopa"."geoMultyPoint2" restart identity ;' > $sql

# kml_date=$(cat /tmp/kml_date)

# echo "INSERT INTO \"is_aopa\".\"geoMultyPoint2\"
#     (id, name, class_id, attributes, shape)
# SELECT
#     ogc_fid as id,
#     \"name\" as name,
#     'aopa__tmp__vt_v02_point',

#     XMLPARSE (CONTENT '<attributes>'
# 	|| case when \"name\" is null then '' else '<attribute name=\"name\" alias=\"Наименование\" type=\"String\">' || \"name\" || '</attribute>' end 
# 	|| case when \"descriptio\" is null then '' else '<attribute name=\"descriptio\" alias=\"Описание\" type=\"String\">' || \"descriptio\" || '</attribute>' end 
# 	|| case when \"coord1\" is null then '' else '<attribute name=\"coord1\" alias=\"Координаты (1)\" type=\"String\">' || \"coord1\" || '</attribute>' end 
# 	|| case when \"coord2\" is null then '' else '<attribute name=\"coord2\" alias=\"Координаты (2)\" type=\"String\">' || \"coord2\" || '</attribute>' end 
# 	|| case when \"freq\" is null then '' else '<attribute name=\"freq\" alias=\"Частота\" type=\"String\">' || \"freq\" || '</attribute>' end 
# 	|| case when \"rptype\" is null then '' else '<attribute name=\"rptype\" alias=\"Тип\" type=\"String\">' || \"rptype\" || '</attribute>' end 
# 	|| case when \"declinatio\" is null then '' else '<attribute name=\"declinatio\" alias=\"Магнитное склонение\" type=\"String\">' || \"declinatio\" || '</attribute>' end 
# 	|| case when \"airac\" is null then '' else '<attribute name=\"airac\" alias=\"AIRAC цикл\" type=\"String\">' || \"airac\" || '</attribute>' end 
# || '<attribute name=\"kml_date\" alias=\"Дата обработки\" type=\"String\">' || '$kml_date' || '</attribute>' 
# || '</attributes>') as attributes,

#     ST_Multi(shape) as shape

# FROM \"is_aopa\".\"tmp__vt_v02_point\" ; " >> $sql


# psql --host=localhost --username=postgres --dbname=bpd_postgis_dev --file="$sql" # > /dev/null 2>&1


# sql=/tmp/${RANDOM}.sql
# export PGPASSWORD=''

# echo 'truncate table "is_aopa"."geoMultyPolygon2" restart identity ;' > $sql

# kml_date=$(cat /tmp/kml_date)


echo "update is_aopa.tmp__199_v02_polygon 
set subtype = 'ZC' 
where "name" like '%ЗОНАЛЬНЫЙ ЦЕНТР%'" \
    | psql --host=localhost --username=postgres --dbname=bpd_postgis_dev # > /dev/null 2>&1


# echo "INSERT INTO \"is_aopa\".\"geoMultyPolygon2\"
#     (id, name, class_id, attributes, shape)
# SELECT
#     ogc_fid as id,
#     \"name\" as name,
#     'aopa__tmp__199_v02_polygon',

#     XMLPARSE (CONTENT '<attributes>'
# 	|| case when \"name\" is null then '' else '<attribute name=\"name\" alias=\"Наименование\" type=\"String\">' || \"name\" || '</attribute>' end 
# 	|| case when \"descriptio\" is null then '' else '<attribute name=\"descriptio\" alias=\"Описание\" type=\"String\">' || \"descriptio\" || '</attribute>' end 
# 	|| case when \"coord1\" is null then '' else '<attribute name=\"coord1\" alias=\"Координаты (1)\" type=\"String\">' || \"coord1\" || '</attribute>' end 
# 	|| case when \"coord2\" is null then '' else '<attribute name=\"coord2\" alias=\"Координаты (2)\" type=\"String\">' || \"coord2\" || '</attribute>' end 
# 	|| case when \"freq\" is null then '' else '<attribute name=\"freq\" alias=\"Частота\" type=\"String\">' || \"freq\" || '</attribute>' end 
# 	|| case when \"rptype\" is null then '' else '<attribute name=\"rptype\" alias=\"Тип\" type=\"String\">' || \"rptype\" || '</attribute>' end 
# 	|| case when \"declinatio\" is null then '' else '<attribute name=\"declinatio\" alias=\"Магнитное склонение\" type=\"String\">' || \"declinatio\" || '</attribute>' end 
# 	|| case when \"airac\" is null then '' else '<attribute name=\"airac\" alias=\"AIRAC цикл\" type=\"String\">' || \"airac\" || '</attribute>' end 
# || '<attribute name=\"kml_date\" alias=\"Дата обработки\" type=\"String\">' || '$kml_date' || '</attribute>' 
# || '</attributes>') as attributes,

#     ST_Multi(shape) as shape

# FROM \"is_aopa\".\"tmp__199_v02_polygon\" ; " >> $sql


# psql --host=localhost --username=postgres --dbname=bpd_postgis_dev --file="$sql" # > /dev/null 2>&1
    

    








# insert into "geoMultyPolygon2"
# (shape,id,class_id)
# VALUES
# ((SELECT
#   ST_Union (a.shape, b.shape)
#   from
#   is_aopa.tmp__199_v02_polygon a,
#   is_aopa.tmp__199_v02_polygon b
#   where
#   a."name" like '%САНКТ-ПЕТЕРБУРГ ЗОНАЛЬНЫЙ ЦЕНТР%'
#   and b."name" like '%САНКТ-ПЕТЕРБУРГ ЗОНАЛЬНЫЙ ЦЕНТР%'
#   and a.ogc_fid <> b.ogc_fid
#   limit 1),
#  (SELECT floor(random() * 100000 + 1)::int),
#  'aopa__tmp__199_v02_polygon')
# ;




