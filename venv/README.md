# Venv or Conda Environments

Just a place to keep venv commands, I have been using conda for running multiple python environments on windows/linux. However, venv is built into python and does not require an external installation. 

### Setup a multi-python environment based on version

- Install the versions of python you need
    - ie 3.10, 3.13 etc...
- Specify the version you need when creating the venv

```bash
python -3.10 -m venv project_a
```

Or

```bash
python -3.12 -m venv project_b
```

### Venv's live in a folder where you create them

When you create an environment `python -m venv new_py_env` it will create a folder for this environment. Everything about this venv is contained in those files, if you want to remove that environment you simply delete the folder.

After creating the venv you need to jump into the environment by activating it: `source new_py_env/bin/activate`

### Install packages

Use pip or whls to install things like normal.

### Exiting the environment

Use `deactivate`

### Removing the environment

Just `deactivate` and delete the venv's folder.

### Save custom environments

Use `pip freeze > requirements.txt` to save all specific versions. 