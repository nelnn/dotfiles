#!/bin/bash

export PATH="/opt/homebrew/bin:/usr/bin:/bin:$PATH"
workspaces=$(rift-cli query workspaces 2>/dev/null) || exit 0
args=()
while IFS=$'\t' read -r index visible active; do
  args+=(--set "rift.$index" "drawing=$visible" "background.drawing=$active")
done < <(printf '%s' "$workspaces" | jq -r '
  group_by(.index)[] |
  [.[0].index,
   (if any(.[]; .is_active or .window_count > 0) then "on" else "off" end),
   (if any(.[]; .is_active) then "on" else "off" end)] | @tsv
')
# Rebuild app icons only when Rift sends a workspace/window event.
args+=(--remove '/rift_app\..*/')
previous_index=""
while IFS=$'\t' read -r index bundle; do
  [ -z "$bundle" ] && continue
  if [ "$index" != "$previous_index" ]; then
    previous="rift.$index"
    previous_index="$index"
  fi
  item="rift_app.$index.$bundle"
  printf -v quoted_bundle '%q' "$bundle"
  args+=(--add item "$item" left
    --set "$item" icon.drawing=off label.drawing=off width=20
      padding_left=1 padding_right=1 background.color=0x00000000
      "background.image=app.$bundle" background.image.scale=0.5
      "click_script=open -b $quoted_bundle"
    --move "$item" after "$previous")
  previous="$item"
done < <(printf '%s' "$workspaces" | jq -r '
  group_by(.index)[] | select(any(.[]; .is_active or .window_count > 0)) |
  .[0].index as $index |
  ([.[].windows[]?.bundle_id | select(. != null and . != "")] | unique)[] |
  [$index, .] | @tsv
')
if ((${#args[@]})); then
  sketchybar "${args[@]}"
fi
