#!/bin/sh

cat ESAT_ETM_NOPAN_297509__4000-6000.txt \
    | while read link; do
    echo $link
    file=$(echo $link | cut -d'/' -f6)

    # if [ "$link" ]

    xdotool windowactivate $(xdotool search --name "Mozilla Firefox" | head -1)
    xdotool key ctrl+l
    xdotool type "$link"
    xdotool key Return
    xdotool windowactivate $(xdotool search --name "Opening" | head -1)
    # xdotool windowactivate $(xdotool search --name "Opening" | head -1)    
    # xdotool getmouselocation --shell
    xdotool mousemove 1519 629
    sleep 5
    xdotool click 1
    # xdotool getmouselocation --shell
    xdotool mousemove 1222 817
    sleep 5  
    xdotool click 1

    sed -i "/${file}/s/^/#/g" ESAT_ETM_NOPAN_297509__4000-6000.txt
    
    sleep 400



    # limit=5
    # dloads=$(ls *.part  | wc -l)
    # while [ 
    
    # break
    
done


