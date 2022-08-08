#!/usr/bin/env zsh
echo "night\nday" | dmenu | awk '$1=="night" {$1="1:1:0.4"} $1=="day" {$1="1:1:1"} {printf("xrandr --output eDP1 --gamma "); print($1)}' | sh > /dev/null 2> /dev/null
