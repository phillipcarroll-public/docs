# Basic `uv` Usage

Alternative to `venv` and `miniconda` environments. Has the basics of venv with the added ability to specify an isolation python version and also create a miniature repo with all requirements with `uv init`

### Create a python environment

`uv venv <name> --python 3.12`

### Activate

`source <name>/bin/activate`

### Deactivate

`deactivate`

### Install packages

`uv pip install <some package>`

### Install `whl`'s

`uv pip install /path/to/your/downloaded_package.whl`
