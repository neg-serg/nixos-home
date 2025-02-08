{pkgs, ...}: {
  home.packages = with pkgs; [
    capstone
    ddrescue
    ext4magic
    extundelete
    ghidra-bin
    p0f
    pdf-parser
    # master.binwalk # Tool library for analyzing binary blobs and executable code
    distorm3
    sleuthkit
    # volatility
  ];
}
