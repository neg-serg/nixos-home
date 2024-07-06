{...}: {
  programs.atuin = {
    enable = true;
    # I *despise* this hijacking of the up key, even though I use Ctrl-p
    flags = ["--disable-up-arrow"];
    settings = {
      update_check = false; # The package is managed by Nix
      style = "compact"; # I don't care for the fancy display
      search_mode = "skim"; # Get closer to fzf's fuzzy search
      show_preview = true; # Show long command lines at the bottom
      enter_accept = false; # I like being able to edit my commands
    };
  };
}
