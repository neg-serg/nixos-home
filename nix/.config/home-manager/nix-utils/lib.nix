rec {
	binaryName = drv:
		drv.meta.mainProgram 
		or drv.pname 
		or (builtins.head (builtins.splitVersion drv.name));

	programPath = drv: "${drv}/bin/${binaryName drv}";

	mkApp = drv: {
		type = "app";
		program = programPath drv;
	};
}
