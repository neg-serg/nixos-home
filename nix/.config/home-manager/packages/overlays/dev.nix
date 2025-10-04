_final: prev: let
  inherit (_final.lib) getDev getLib;
  tommath = _final.libtommath;
  tommathDev = getDev tommath;
  tommathLib = getLib tommath;
  tcl86 = prev.tcl-8_6;
  tk86 = prev.tk-8_6;
in {
  # Targeted fix via reusable helper: tigervnc needs autoreconf.
  tigervnc = _final.neg.functions.withAutoreconf prev.tigervnc;

  python311Packages = prev.python311Packages.overrideScope (self: super: {
    tkinter = (super.tkinter.override {
      tcl = tcl86;
      tk = tk86;
    }).overrideAttrs (old: {
      buildInputs = (old.buildInputs or []) ++ [ tommath ];
      NIX_CFLAGS_COMPILE = (old.NIX_CFLAGS_COMPILE or "") + " -I${tommathDev}/include";
      NIX_LDFLAGS = (old.NIX_LDFLAGS or "") + " -L${tommathLib}/lib -ltommath";
    });
  });

  # Reserved for development/toolchain overlays
  neg = {};
}
