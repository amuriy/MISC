#!/bin/sh

gwc_dir='/opt/geoserver-2.10.2/data_dir/gwc/test_sld_Vmap0'
mapcache_dir='/tmp/template-test/test'
grid='EPSG_4326'

chown -R amuriy:users $mapcache_dir

find $gwc_dir -maxdepth 1 -type d | grep $grid  | while read path; do
    dir=$(echo $path | rev | cut -d'/' -f1 | rev)
    echo $dir
    mkdir -p $mapcache_dir/$dir
    find $path -name "*.png" -exec cp -rf "{}" $mapcache_dir/$dir \;
done

find $mapcache_dir -type d | grep 'EPSG_' | while read i; do
    x=$(echo $i | sed 's/0*\([0-9]\)/\1/g')
    mv -f $i $x
done

find $mapcache_dir -type f -name '*.png' | while read i; do
    x=$(echo $i | sed 's/0*\([0-9]\)/\1/g')
    mv -f $i $x
done

