# Third-Party Components

This repository vendors several upstream projects and scripts. Keep this manifest
in sync whenever sources are updated so licenses and provenance stay clear.

## Packaged applications

| Component | Source | Revision | License | Notes |
|-----------|--------|----------|---------|-------|
| **awrit** | https://github.com/chase/awrit | tag `awrit-native-rs-2.0.3` | BSD-3-Clause | Terminal Chromium renderer; packaged via `pkgs.neg.awrit`. |
| **fancy-cat** | https://github.com/freref/fancy-cat | tag `v0.5.0` | AGPL-3.0-or-later | Kitty PDF viewer; build wraps MuPDF and bundles Zig deps via cache priming. |
| **libvaxis** | https://github.com/rockorager/libvaxis | commit `f6be46dbda3633dcfe20beb0d62e7f18f5ab7121` (MIT) | MIT | Zig dependency vendored through fancy-cat build cache. |
| **fzwatch** | https://github.com/freref/fzwatch | commit `cb462430687059e09c638cccf1cadfebeaef018a` | MIT | Zig dependency vendored through fancy-cat build cache. |
| **fastb64z** | https://github.com/freref/fastb64z | commit `3defc5d33162670c28e42af073cf9bc003017da6` | MIT | Zig dependency vendored through fancy-cat build cache. |
| **zigimg** | https://github.com/ivanstepanovftw/zigimg | commit `d7b7ab0ba0899643831ef042bd73289510b39906` | MIT | Zig dependency vendored through fancy-cat build cache. |
| **zg** | https://codeberg.org/chaten/zg | commit `749197a3f9d25e211615960c02380a3d659b20f9` | MIT | Zig dependency vendored through fancy-cat build cache. |

## Kitty kittens & scripts

| Component | Source | Revision | License | Notes |
|-----------|--------|----------|---------|-------|
| **kitty-kitten-search** (`search.py`, `scroll_mark.py`) | https://github.com/trygveaa/kitty-kitten-search | commit `992c1f3d220dc3e1ae18a24b15fcaf47f4e61ff8` | *No license declared upstream* | Live incremental search kitten; update scripts when upstream changes and verify licensing. |
| **extrakto-kitty** (`extrakto_kitty.py`) | https://github.com/dawsers/extrakto-kitty | commit `a5371bc7969570719038b2095409e23c7ceb9a89` | *No license declared upstream* | FZF-based selector kitten; derived from laktak/extrakto. |

If a new component is added (or a commit changes), append a row or update the
entry and ensure the applicable LICENSE file ships alongside any vendored
source when required by the upstream license.
