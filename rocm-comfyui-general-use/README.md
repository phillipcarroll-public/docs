# Comfy UI Easy Setup Radeon AI 9700 Win 11

Download ComfyUI latest: <a href="https://github.com/Comfy-Org/ComfyUI/releases">https://github.com/Comfy-Org/ComfyUI/releases</a>

Extract ComfyUI

Late Feb 2026 ROCm 7.2 WHLs: <a href="https://repo.radeon.com/rocm/windows/.rocm-rel-7.2_a/">https://repo.radeon.com/rocm/windows/.rocm-rel-7.2_a/</a>

Note if these pips fail check the link above for a name change, updated file etc...

```
python -m pip install "https://repo.radeon.com/rocm/windows/.rocm-rel-7.2_a/rocm_sdk_core-7.2.0.dev0-py3-none-win_amd64.whl"
python -m pip install "https://repo.radeon.com/rocm/windows/.rocm-rel-7.2_a/rocm_sdk_devel-7.2.0.dev0-py3-none-win_amd64.whl"
python -m pip install "https://repo.radeon.com/rocm/windows/.rocm-rel-7.2_a/rocm_sdk_libraries_custom-7.2.0.dev0-py3-none-win_amd64.whl"
python -m pip install "https://repo.radeon.com/rocm/windows/.rocm-rel-7.2_a/rocm-7.2.0.dev0.tar.gz"
python -m pip install "https://repo.radeon.com/rocm/windows/.rocm-rel-7.2_a/torch-2.9.1+rocmsdk20260116-cp312-cp312-win_amd64.whl"
python -m pip install "https://repo.radeon.com/rocm/windows/.rocm-rel-7.2_a/torchvision-0.24.1+rocmsdk20260116-cp312-cp312-win_amd64.whl"
python -m pip install "https://repo.radeon.com/rocm/windows/.rocm-rel-7.2_a/torchaudio-2.9.0+rocmsdk20251116-cp312-cp312-win_amd64.whl"
python -m pip install "https://repo.radeon.com/rocm/windows/.rocm-rel-7.2_a/torchaudio-2.9.1%2Brocmsdk20260116-cp312-cp312-win_amd64.whl"
```

Create your conda env with python 3.12: `conda create -n comfyuirocm python=3.12 -y`

Navigate to your extracted ComfyUI folder and run: `run_amd_gpu.bat`