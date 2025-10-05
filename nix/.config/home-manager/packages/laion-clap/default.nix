{
  lib,
  python3Packages,
}:
python3Packages.buildPythonPackage rec {
  pname = "laion_clap";
  version = "1.1.7";

  src = python3Packages.fetchPypi {
    inherit pname version;
    hash = "sha256-mrnFI2ueCUT2fWaF7yqcFIFOvRPA2GLH/gepu1ZgQ5c=";
  };

  pyproject = true;
  build-system = [ python3Packages.setuptools ];

  propagatedBuildInputs = with python3Packages; [
    numpy
    soundfile
    librosa
    torchlibrosa
    ftfy
    braceexpand
    webdataset
    wget
    wandb
    llvmlite
    scipy
    scikit-learn
    pandas
    h5py
    tqdm
    regex
    transformers
    progressbar
    torch
    torchaudio
    torchvision
  ];

  pythonRelaxDeps = [ "numpy" "scipy" "pandas" "torch" "torchaudio" "torchvision" ];

  doCheck = false;
  pythonImportsCheck = [ "laion_clap" ];

  meta = {
    description = "Contrastive Language-Audio Pretraining model from LAION";
    homepage = "https://github.com/LAION-AI/CLAP";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [];
  };
}
