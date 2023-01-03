#!/bin/sh

IN=$(xrandr | grep "eDP" | grep " connected" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/")
EXT=$(xrandr | grep "HDMI" | grep " connected" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/")

if (xrandr | grep "$EXT disconnected"); then
	xrandr --output $EXT --off --output $IN --auto --dpi 120
else
	xrandr --output $IN --off --output $EXT --auto --mode 3840x2160 --rate 144 --dpi 100
fi
