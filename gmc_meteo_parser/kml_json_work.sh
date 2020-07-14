#!/usr/bin/env bash

source config

tmpdir="./tmp$$"
mkdir $tmpdir

sql=$tmpdir/pol.sql

kml_pol_insert()
{
    case $1 in
	'SE')	    
	    echo "INSERT INTO \"is_grib\".\"gmc_se_pol_izo_kml\"(
        id, name, shape, label, value, class_id, tessellate, extrude, visibility)
    SELECT  id, '*', ST_Multi(shape), name, name::real, '*' as class_id, tessellate, extrude, visibility
    FROM $2" > $sql
}


## KML work
cd $kml_dir

find . -iname "*KML*" | cut -d'_' -f5 | sort | uniq | grep -E -v '^$' \
    | while read data_type; do
    max_date=$(find . -iname "*${data_type}*" | cut -d'_' -f1 | uniq | sort -r | head -n1 | sed 's+./++')
    if [[ $data_type == "SE" ]]; then
	find . -iname "*${data_type}*"  \
	    | while read kml_file; do
	    echo $kml_file
	    echo ""
	    
	    kml_lyr=$(basename $kml_file .KML)
	    echo kml_lyr $kml_lyr
	    echo ""

	    echo max_date $max_date
	    echo ""

	    if_lyr=$(ogrinfo $kml_file | grep '1:')
	    if [[ $(echo $?) = 0 ]]; then
		
		echo --- KML not empty ---
		echo ""
		
		data_time=$(cat $kml_file | grep -A1 'ObservationTime' | grep value \
				| sort | uniq | grep -oPm1 "(?<=<value>)[^<]+" )
		# | awk '{print gensub(/(..)\.(..)\.(....)/,"\\3-\\2-\\1",1)}')

		echo data_time  $data_time
		echo ""
		
		ogr2ogr -a_srs EPSG:4326 -f "PostgreSQL" \
			PG:"host=$db_host port=5432 dbname=$db_name user=$db_user password=$db_pass" \
			-lco SCHEMA=$db_schema -lco OVERWRITE=YES $kml_file -nln $kml_lyr -overwrite  # > /dev/null 2>&1
	       		
		
	    else

		echo KML empty
		
	    fi


	done

	
    fi

    
	

done


## JSON work



\rm -rf $tmpdir
