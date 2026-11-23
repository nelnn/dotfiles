#!/bin/bash

export PATH="/opt/homebrew/bin:/usr/bin:/bin:$PATH"
workspaces=$(rift-cli query workspaces 2>/dev/null) || exit 0
args=()
seen_visible=false
while IFS=$'\t' read -r index visible active; do
  color=0xff00cc33
  [ "$active" = "on" ] && color=0xffffcc00
  separator=off
  if [ "$visible" = "on" ]; then
    $seen_visible && separator=on
    seen_visible=true
  fi
  args+=(--set "rift_sep.$index" "drawing=$separator"
    --set "rift.$index" "drawing=$visible" background.drawing=off "icon.color=$color")
done < <(printf '%s' "$workspaces" | jq -r '
  group_by(.index)[] |
  [.[0].index,
   (if any(.[]; .is_active or .window_count > 0) then "on" else "off" end),
   (if any(.[]; .is_active) then "on" else "off" end)] | @tsv
')
# Resolve all app names in one IPC query, rather than launching AppleScript per app.
applications=$(rift-cli query applications 2>/dev/null) || applications='[]'
# Show app names beside each workspace, without app icons.
args+=(--remove '/rift_app\..*/')
previous_index=""
while IFS=$'\t' read -r index bundle active name; do
  [ -z "$bundle" ] && continue
  if [ "$index" != "$previous_index" ]; then
    previous="rift.$index"
    previous_index="$index"
  fi
  [ -n "$name" ] || name="$bundle"
  case "$name" in
    Ghostty) name="T" ;;
    Chromium) name="web" ;;
  esac
  color=0xff00cc33
  [ "$active" = "true" ] && color=0xffffcc00
  item="rift_app.$index.$bundle"
  printf -v quoted_bundle '%q' "$bundle"
  args+=(--add item "$item" left
    --set "$item" icon.drawing=off "label=$name"
      label.font="SF Mono:Regular:12.0" "label.color=$color"
      padding_left=1 padding_right=1 label.padding_left=2 label.padding_right=2
      background.drawing=off
      "click_script=open -b $quoted_bundle"
    --move "$item" after "$previous")
  previous="$item"
done < <(printf '%s' "$workspaces" | jq -r --argjson apps "$applications" '
  ($apps | map({key: .bundle_id, value: .name}) | from_entries) as $names |
  group_by(.index)[] | select(any(.[]; .is_active or .window_count > 0)) |
  .[0].index as $index | any(.[]; .is_active) as $active |
  ([.[].windows[]?.bundle_id | select(. != null and . != "")] | unique)[] |
  [$index, ., $active, ($names[.] // .)] | @tsv
')
if ((${#args[@]})); then
  sketchybar "${args[@]}"
fi
