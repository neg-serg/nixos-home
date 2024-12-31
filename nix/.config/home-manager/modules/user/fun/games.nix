{pkgs, stable, ...}: {
  home.packages = with pkgs; [
    abuse # classic side-scrolling shooter customizable with LISP
    airshipper # for veloren voxel game
    angband # roguelike
    stable.brogue # roguelike
    crawl # roguelike
    crawlTiles # roguelike
    endless-sky # space exploration game
    fheroes2 # free heroes 2 implementation
    gnuchess # GNU chess engine
    gzdoom # open-source doom
    jazz2 # open source reimplementation of classic Jazz Jackrabbit 2 game
    nethack # roguelike
    stable.openmw # Unofficial open source engine reimplementation of the game Morrowind
    shattered-pixel-dungeon # roguelike
    # unnethack # roguelike
    xaos # smooth fractal explorer
  ];
}
