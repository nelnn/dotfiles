#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/bin:/bin:$PATH"
if [ "$SENDER" = mouse.exited.global ]; then
  sketchybar --set stats popup.drawing=off
elif [ "$SENDER" = mouse.clicked ]; then
  sketchybar --set stats popup.drawing=on --set stats.cpu label="Sampling CPU…"
  sample=$(top -l 2 -s 1 -n 0 2>/dev/null)
  cpu=$(printf '%s' "$sample" | grep 'CPU usage:' | tail -1)
  sketchybar --set stats.cpu "label=${cpu:-CPU unavailable}"
fi
