#!/usr/bin/env bash

if command -v feh &>/dev/null; then
  feh --no-fehbg \
    --bg-fill ~/.config/wallpapers/bg2.jpg \
    --bg-fill ~/.config/wallpapers/bg.jpg
fi
