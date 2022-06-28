#!/usr/bin/env zsh
echo -n "min\n100\n500\nmax" | dmenu | awk '$1=="min" {$1=1} $1=="max" {$1=4794} $1<=4794 && $1>0 {print($1)}' > /sys/class/backlight/intel_backlight/brightness
