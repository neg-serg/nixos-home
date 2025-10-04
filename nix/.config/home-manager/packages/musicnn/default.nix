{
  lib,
  python3Packages,
}:
python3Packages.buildPythonPackage rec {
  pname = "musicnn";
  version = "0.1.0";

  src = python3Packages.fetchPypi {
    inherit pname version;
    hash = "sha256-Z0zMH7Y45olPmRl8/CeUuQ2WREKS6ijO3ult4PdMSr0=";
  };

  pyproject = true;
  build-system = [ python3Packages.setuptools ];

  postPatch = ''
    substituteInPlace setup.py \
      --replace "tensorflow>=1.14" "tensorflow>=2.0.0" \
      --replace "numpy<1.17,>=1.14.5" "numpy>=1.14.5"
  '';

  propagatedBuildInputs = with python3Packages; [
    librosa
    tensorflow
    numpy
  ];

  doCheck = false;
  pythonImportsCheck = [ "musicnn" ];

  meta = {
    description = "Pre-trained convolutional networks for music tagging";
    homepage = "https://github.com/jordipons/musicnn";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [];
  };
}
