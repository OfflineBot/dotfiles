#!/bin/bash
~/Apps/Scripts/swww img ~/Pictures/slideshow/abstract.jpg --transition-step 100 --transition-fps 60

SLEEP_TIMER=100

while true; do
    ~/Apps/Scripts/swww img ~/Pictures/slideshow/abstract.jpg --transition-step 50 --transition-fps 60 --transition-type center
    sleep $SLEEP_TIMER
    ~/Apps/Scripts/swww img ~/Pictures/slideshow/red_city.png --transition-step 50 --transition-fps 60 --transition-type center
    sleep $SLEEP_TIMER
    ~/Apps/Scripts/swww img ~/Pictures/slideshow/snow_area.jpg --transition-step 50 --transition-fps 60 --transition-type center
    sleep $SLEEP_TIMER
done

