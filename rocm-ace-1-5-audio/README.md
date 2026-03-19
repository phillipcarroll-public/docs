# Ace 1.5 Audio/Music Generation on ROCm w/ Radeon AI 9700 32GB

Clone or download ACE 1.5: `git clone https://github.com/ace-step/ACE-Step-1.5.git` or `https://github.com/ace-step/ACE-Step-1.5/releases/`

Exact ACE 1.5 as needed

Create a ROCm 7.2 venv environment

Activate the venv, open the ace folder: `pip install -r requirements-rocm.txt`

In this file: `C:\PATH\VENVNAME\Lib\site-packages\vector_quantize_pytorch\lookup_free_quantization.py`

Comment out: `#from torch.distributed import nn as dist_nn`

Or it will error out and never start the backend.

Start gradio rocm: `start_gradio_ui_rocm.bat`

This will download models/things and ultimately provide you a localhost/loopback link to the UI.



