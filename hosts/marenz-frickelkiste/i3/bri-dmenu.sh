#!/usr/bin/env zsh
echo -n "min\n20\n100\n200\nmax" | dmenu | awk '$1=="min" {$1=1} $1=="max" {$1=255} $1<=255 && $1>0 {print($1)}' > /sys/class/backlight/amdgpu_bl0/brightness
