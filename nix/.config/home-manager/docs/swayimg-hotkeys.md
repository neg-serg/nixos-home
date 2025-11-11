# swayimg Custom Hotkeys

Custom bindings for swayimg live in `modules/media/images/swayimg/conf/bindings.conf` and call
`~/.local/bin/swayimg-actions.sh`. The tables below list every non-default shortcut that runs this
helper script. Unless noted otherwise, the bindings act on the file that is currently highlighted in
the given mode.

## Viewer Mode

| Key | Script action | Effect |
| --- | ------------- | ------ |
| `Ctrl+1` | `wall-mono` | Convert the current image to two colors and send it to `swww` as the wallpaper. |
| `Ctrl+2` | `wall-fill` | Scale/crop the image to fill the monitor (center crop) and set it as wallpaper. |
| `Ctrl+3` | `wall-full` | Same as `wall-fill`; retained for muscle memory. |
| `Ctrl+4` | `wall-tile` | Render a screen-sized tiled pattern from the image and set it as wallpaper. |
| `Ctrl+5` | `wall-center` | Center the image on the wallpaper canvas with black borders. |
| `Ctrl+w` | `wall-cover` | Cover the monitor with the image (crop as needed) and set it as wallpaper. |
| `Ctrl+c` | `cp` | Copy the file into a directory picked via the rofi prompt. |
| `c` | `copyname` | Copy the absolute file path to the clipboard and show `pic-notify` when available. |
| `Ctrl+d`, `d` | `mv … $HOME/trash/1st-level/pic` | Move the file into the staged trash folder. |
| `v` | `mv` | Move the file into a directory selected via the rofi prompt. |
| `Ctrl+comma` | `rotate-left` | Rotate the file 270° using ImageMagick (`mogrify`). |
| `Ctrl+less` | `rotate-ccw` | Rotate the file 90° counter-clockwise. |
| `Ctrl+period` | `rotate-right` | Rotate the file 90° clockwise. |
| `Ctrl+slash` | `rotate-180` | Rotate the file 180°. |
| `r` | `repeat` | Replay the last `mv`/`cp` destination (uses the cached directory recorded by `proc`). |

## Gallery Mode

| Key | Script action | Effect |
| --- | ------------- | ------ |
| `c` | `copyname` | Copy the highlighted file’s absolute path to the clipboard. |
| `Ctrl+c` | `cp` | Copy the highlighted file into a rofi-selected directory. |
| `Ctrl+d`, `d` | `mv … $HOME/trash/1st-level/pic` | Send the highlighted file to the staged trash. |
| `r` | `repeat` | Repeat the previous `mv`/`cp` to its cached destination. |
| `v` | `mv` | Move the highlighted file via a rofi prompt. |
| `Ctrl+comma` | `rotate-left` | Rotate the highlighted file 270°. |
| `Ctrl+less` | `rotate-ccw` | Rotate the highlighted file 90° counter-clockwise. |
| `Ctrl+period` | `rotate-right` | Rotate the highlighted file 90° clockwise. |
| `Ctrl+slash` | `rotate-180` | Rotate the highlighted file 180°. |
| `Ctrl+1` | `wall-mono` | Push the highlighted image to `swww` in monochrome mode. |
| `Ctrl+2` | `wall-fill` | Fill the monitor with the highlighted image and set it as wallpaper. |
| `Ctrl+3` | `wall-full` | Alias for `wall-fill`. |
| `Ctrl+4` | `wall-tile` | Tile the highlighted image and set it as wallpaper. |
| `Ctrl+5` | `wall-center` | Center the highlighted image on the wallpaper canvas. |
| `Ctrl+w` | `wall-cover` | Cover the monitor with the highlighted image and set it as wallpaper. |

## Slideshow Mode

| Key | Script action | Effect |
| --- | ------------- | ------ |
| `Ctrl+d` | `mv … $HOME/trash/1st-level/pic` | Move the current slide into the staged trash folder. |

### Notes

- All file moves/copies are blocked on VCS directories by `_is_vcs_path` to keep repo trees intact.
- Wallpaper helpers rely on `swww`. The script starts the daemon on demand and serializes calls via
  a lock directory so multiple instances do not collide.
