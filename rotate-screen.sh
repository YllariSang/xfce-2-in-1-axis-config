#!/bin/bash

DISPLAY_ID="eDP-1"
TOUCHPAD="SYNA3602:00 0911:5288 Touchpad"
TOUCHSCREEN="7"
MATRIX="Coordinate Transformation Matrix"

SENSOR_DATA=$(timeout 0.3s monitor-sensor | grep -E "orientation|tilt" | tail -n 1)

if [[ "$SENSOR_DATA" == *"orientation changed:"* ]]; then
    ORIENTATION=$(echo "$SENSOR_DATA" | awk -F': ' '{print $2}')
    TILT="vertical" # Default assumption for active orientation change
elif [[ "$SENSOR_DATA" == *"tilt changed:"* ]]; then
    TILT=$(echo "$SENSOR_DATA" | awk -F': ' '{print $2}')
    ORIENTATION=$(timeout 0.1s monitor-sensor | grep -m 1 "orientation:" | sed -E 's/.*orientation: ([a-z\-]+).*/\1/')
else
    ORIENTATION=$(echo "$SENSOR_DATA" | sed -E 's/.*orientation: ([a-z\-]+).*/\1/')
    TILT=$(echo "$SENSOR_DATA" | sed -E 's/.*tilt: ([a-z\-]+).*/\1/')
fi

[ -z "$ORIENTATION" ] && ORIENTATION="normal"
[ -z "$TILT" ] && TILT="vertical"

if [[ "$TILT" == "face-down" || "$TILT" == "face-up" ]]; then
    exit 0
fi

case "$ORIENTATION" in
    "normal")
        xrandr --output "$DISPLAY_ID" --rotate normal
        xinput set-prop "$TOUCHPAD" "$MATRIX" 1 0 0 0 1 0 0 0 1
        xinput set-prop "$TOUCHSCREEN" "$MATRIX" 1 0 0 0 1 0 0 0 1
        ;;
    "bottom-up")
        xrandr --output "$DISPLAY_ID" --rotate inverted
        xinput set-prop "$TOUCHPAD" "$MATRIX" -1 0 1 0 -1 1 0 0 1
        xinput set-prop "$TOUCHSCREEN" "$MATRIX" -1 0 1 0 -1 1 0 0 1
        ;;
    "right-up")
        xrandr --output "$DISPLAY_ID" --rotate left
        xinput set-prop "$TOUCHPAD" "$MATRIX" 0 -1 1 1 0 0 0 0 1
        xinput set-prop "$TOUCHSCREEN" "$MATRIX" 0 -1 1 1 0 0 0 0 1
        ;;
    "left-up")
        xrandr --output "$DISPLAY_ID" --rotate right
        xinput set-prop "$TOUCHPAD" "$MATRIX" 0 1 0 -1 0 1 0 0 1
        xinput set-prop "$TOUCHSCREEN" "$MATRIX" 0 1 0 -1 0 1 0 0 1
        ;;
esac
