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


# find /tmp/aopa/ -name "*.sqlite" | grep -v ad_v02 | xargs rm -f

find /tmp/aopa/ -name "*.kml" | grep -v ad_v02 | grep vt_v02 | while read kml; do
    name=$(echo $kml | cut -d'/' -f5)
    dirname=$(dirname $kml)
    sqlite="$dirname/$name.sqlite"
    flyr=$(ogrinfo -q -ro -so $kml | perl -pe 's/^[^ ]+ //g and s/ \([^()]+\)$//g' | head -n1)
    ogr2ogr -f SQLite -nln $name $sqlite $kml "$flyr"

    ogrinfo -q -ro -so $kml \
	| perl -pe 's/^[^ ]+ //g and s/ \([^()]+\)$//g' | sed '1d' \
	| while read lyr; do
	ogr2ogr -append -f SQLite -nln $name $sqlite $kml "$lyr"
    done
done
    

# ogr2ogr -skipfailures -f "ESRI Shapefile" /tmp/aopa/kml/vt_v02/vt_v02_lin.shp  /tmp/aopa/kml/vt_v02/vt_v02.sqlite -nlt LINESTRING
# ogr2ogr -f "ESRI Shapefile" /tmp/aopa/kml/vt_v02/vt_v02_pnt.shp  /tmp/aopa/kml/vt_v02/vt_v02.sqlite -nlt POINT -where "GEOMETRY='POINT'" -geomfield GEOMETRY
# ogr2ogr -f "ESRI Shapefile" /tmp/aopa/kml/vt_v02/vt_v02_pnt.shp  /tmp/aopa/kml/vt_v02/vt_v02.sqlite -nlt POINT -where "OGR_GEOMETRY='POINT Z'"




## Стабильные слои
# ob1904_v02.kmz - Коммуникационные башни (во всех слоях по регионам)
# 199_v02.kmz - Зоны и районы

