#!/bin/bash


IMG_DIR=~/Pictures/slideshow

# in seconds
SLEEP_TIMER=400

while true; do
    for image in "$IMG_DIR"/*; do
        ~/Apps/Scripts/swww img "$image" --transition-step 60 --transition-fps 60 --transition-type center
        sleep $SLEEP_TIMER
    done
done

