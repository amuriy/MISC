#!/bin/sh

find txt/ -name "*speed*" | while read i; do x=$(echo "$i" | sed 's/wind_speed/wspeed/'); mv $i $x; done
find txt/ -name "*wind_direct*" | while read i; do x=$(echo "$i" | sed 's/wind_direct/wdirect/'); mv $i $x; done

dateform()
{
    file=$1
    date=$(echo $file | cut -d'_' -f3)
    Y=$(echo $date | cut -c1-4)
    m=$(echo $date | cut -c5-6)
    d=$(echo $date | cut -c7-8)
    H=$(echo $date | cut -c9-10)
    M='00'
    date1="$d/$m/$Y $H:$M"
    echo "$date1"
}


for reg in region1 ; do
    for var in apcp03 cape dpt gust hgt pres rh snod tcdc tmp wdirect wspeed; do
	outfile=${var}_${reg}.txt
	ls txt/*${reg}*.txt | grep $var | while read txt; do
	    date=$(dateform $txt)
	    num=$(cat $txt | awk '{$0=sprintf("%.2f",$0)}1')
	    echo $date, $num >> _out_/$outfile 
	done
    done
done
