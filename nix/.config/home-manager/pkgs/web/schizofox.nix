{inputs, ...}: {
  imports = [inputs.schizofox.homeManagerModule];
  programs.schizofox = {
    enable = true;
    theme = {
      font = "Iosevka Medium";
      colors = { background-darker = "181825"; background = "1e1e2e"; foreground = "cdd6f4"; };
    };

    search = rec {
      defaultSearchEngine = "Searxng";
      removeEngines = ["Bing" "Amazon.com" "eBay" "Twitter" "Wikipedia" "LibRedirect" "DuckDuckGo"];
      searxUrl = "https://search.notashelf.dev";
      searxQuery = "${searxUrl}/search?q={searchTerms}&categories=general";
      addEngines = [{
          Name = "Searxng";
          Description = "Decentralized search engine";
          Alias = "sx";
          Method = "GET";
          URLTemplate = "${searxQuery}";
      }];
    };

    security = {
      sanitizeOnShutdown = false;
      sandbox = true;
      noSessionRestore = false;
      userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:106.0) Gecko/20100101 Firefox/106.0";
    };

    misc = {
      drm.enable = true;
      disableWebgl = false;
      bookmarks = [{
          # Title = "Nyx";
          # URL = "https://github.com/NotAShelf/nyx";
          # Placement = "toolbar";
          # Folder = "Github";
      }];
    };

    extensions = {
      simplefox.enable = true;
      darkreader.enable = true;
      extraExtensions = let mkUrl = name: "https://addons.mozilla.org/firefox/downloads/latest/${name}/latest.xpi"; in {
        "uBlock0@raymondhill.net".install_url = mkUrl "ublock-origin"; # Ublock
        "flagfox".install_url = mkUrl "flagfox"; # Flagfox
        "{036a55b4-5e72-4d05-a06c-cba2dfcc134a}".install_url = mkUrl "traduzir-paginas-web"; # TWP - Translate Web Pages
        "{17165bd9-9b71-4323-99a5-3d4ce49f3d75}".install_url = mkUrl "export-tabs-urls-and-titles"; # Export Tabs URLs
        "{1be309c5-3e4f-4b99-927d-bb500eb4fa88}".install_url = mkUrl "augmented-steam"; # Augmented Steam
        "{1d87690d-2783-4eea-ac00-6b83a6d5948b}".install_url = mkUrl "solid-black-theme"; # Solid Black Theme
        # Runet Censorship Bypass
        "{290ce447-2abb-4d96-8384-7256dd4a1c43}".install_url = mkUrl "%D0%BE%D0%B1%D1%85%D0%BE%D0%B4-%D0%B1%D0%BB%D0%BE%D0%BA%D0%B8%D1%80%D0%BE%D0%B2%D0%BE%D0%BA-%D1%80%D1%83%D0%BD%D0%B5%D1%82%D0%B0";
        "{2e5ff8c8-32fe-46d0-9fc8-6b8986621f3c}".install_url = mkUrl "search_by_image"; # Search by Image
        "{60f82f00-9ad5-4de5-b31c-b16a47c51558}".install_url = mkUrl "cookie-quick-manager"; # Cookie Quick Manager
        "{72bd91c9-3dc5-40a8-9b10-dec633c0873f}".install_url = mkUrl "enhanced-github"; # Enhanced GitHub
        "{a250ed19-05b9-4486-b2c3-535044766b8c}".install_url = mkUrl "hide-scrollbars"; # hide-scrollbars
        # Free music downloader for VK | VKD
        "{a8fff5e8-00c2-455a-9958-d8cd10f8206d}".install_url = mkUrl "%D1%81%D0%BA%D0%B0%D1%87%D0%B0%D1%82%D1%8C-%D0%BC%D1%83%D0%B7%D1%8B%D0%BA%D1%83-%D1%81-%D0%B2%D0%BA-vkd";
        "{ae424048-7af4-4e8f-acfa-f016f8e9f4b4}".install_url = mkUrl "return-youtube-dislike"; # KellyC Show YouTube Dislikes
        "{b9acf540-acba-11e1-8ccb-001fd0e08bd4}".install_url = mkUrl "easy-youtube-video-download"; # Easy Youtube Video Downloader Express
        "@setupvpncom".install_url = mkUrl "setupvpn"; # SetupVPN - Lifetime Free VPN
        "github-forks-addon@musicallyut.in".install_url = mkUrl "lovely-forks"; # Lovely Forks
        "jid1-93WyvpgvxzGATw@jetpack".install_url = mkUrl "to-google-translate"; # To Google Translate
        "tridactyl.vim@cmcaine.co.uk".install_url = mkUrl "tridactyl-vim"; # Tridactyl
        "sponsorBlocker@ajay.app".install_url = mkUrl "sponsorblock"; # SponsorBlock
        "{a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad}".install_rul = mkUrl "refined-github-"; # Refined Github
      };
    };
  };
}
