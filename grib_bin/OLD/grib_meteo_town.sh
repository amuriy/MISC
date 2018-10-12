#!/bin/sh

shp='/home/amuriy/Desktop/GRIB/data/grib/12.04.2018/towns.shp'
csv='/home/amuriy/Desktop/GRIB/data/grib/12.04.2018/towns.csv'
sql='/home/amuriy/Desktop/GRIB/data/grib/12.04.2018/towns.sql'

rm -f $csv 
rm -f $sql

# convert SHP to CSV
ogr2ogr -f "CSV" -lco GEOMETRY=AS_WKT $csv $shp
# remove header from CSV
sed -i '1d' $csv

## DO IT
# create table in DB
echo 'drop table "IS_STUFF".osm_towns_rus2 ;' > $sql
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

cat $csv | while read line; do
    geom=$(echo $line | cut -d';' -f1 | sed 's/\"//g')
    adm=$(echo $line | cut -d';' -f2)
    name=$(echo $line | cut -d';' -f3)
    pop=$(echo $line | cut -d';' -f4)    
    f1=$(echo $line | cut -d';' -f6)
    f2=$(echo $line | cut -d';' -f7)
    f3=$(echo $line | cut -d';' -f8)
    
    echo "INSERT INTO \"IS_STUFF\".osm_towns_rus2 (shape,admin_leve,name,population,time_data,temper) 
VALUES (ST_GeomFromText('$geom','4326'),'$adm','$name',$pop,'2018-04-12 15:00:00',$f1) ;" >> $sql
    echo "INSERT INTO \"IS_STUFF\".osm_towns_rus2 (shape,admin_leve,name,population,time_data,temper) 
VALUES (ST_GeomFromText('$geom','4326'),'$adm','$name',$pop,'2018-04-13 15:00:00',$f2) ;" >> $sql
    echo "INSERT INTO \"IS_STUFF\".osm_towns_rus2 (shape,admin_leve,name,population,time_data,temper) 
VALUES (ST_GeomFromText('$geom','4326'),'$adm','$name',$pop,'2018-04-14 15:00:00',$f3) ;" >> $sql     
done

sed -i 's/\,''\,/\,NULL\,/g' $sql

export PGPASSWORD='Prime#52'
psql --host=172.24.2.192 --username=bpd_owner --dbname=bpd_postgis_dev --file=$sql > /dev/null 2>&1 

