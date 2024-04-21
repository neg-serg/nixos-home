{pkgs, ...}: {
  home.packages = with pkgs; [
    capstone
    ddrescue
    ext4magic
    extundelete
    ghidra-bin
    p0f
    pdf-parser
    python39Packages.binwalk # Tool library for analyzing binary blobs and executable code
    python39Packages.distorm3
    sleuthkit
    volatility
  ];
}
