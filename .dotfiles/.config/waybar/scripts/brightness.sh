#!/bin/bash

MAX_BRIGHTNESS=$(cat /sys/class/backlight/amdgpu_bl1/max_brightness)
CURRENT_BRIGHTNESS=$(cat /sys/class/backlight/amdgpu_bl1/brightness)

BRIGHTNESS_PERCENT=$(echo "scale=2; 100 * $CURRENT_BRIGHTNESS / $MAX_BRIGHTNESS" | bc)

echo "$BRIGHTNESS_PERCENT%"
