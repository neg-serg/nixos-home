# Third-Party Components

This repository vendors several upstream projects and scripts. Keep this manifest
in sync whenever sources are updated so licenses and provenance stay clear.

## Packaged applications

| Component | Source | Revision | License | Notes |
|-----------|--------|----------|---------|-------|
| **awrit** | https://github.com/chase/awrit | tag `awrit-native-rs-2.0.3` | BSD-3-Clause | Terminal Chromium renderer; packaged via `pkgs.neg.awrit`. |

## Kitty kittens & scripts

| Component | Source | Revision | License | Notes |
|-----------|--------|----------|---------|-------|
| **kitty-kitten-search** (`search.py`, `scroll_mark.py`) | https://github.com/trygveaa/kitty-kitten-search | commit `992c1f3d220dc3e1ae18a24b15fcaf47f4e61ff8` | *No license declared upstream* | Live incremental search kitten; update scripts when upstream changes and verify licensing. |

If a new component is added (or a commit changes), append a row or update the
entry and ensure the applicable LICENSE file ships alongside any vendored
source when required by the upstream license.
