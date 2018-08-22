# jupyterq
Jupyter kernel for kdb+. Features include

- Syntax Highlighting for q
- Code completion for q keywords, .z/.h/.Q/.j namespace functions, and user defined variables
- Code help for q keywords and basic help (display and type information) for user defined objects
- script like execution of code (mulitline input)
- Inline display of charts created using embedPy and matplotlib
- console stdout/stderr capture and display in notebooks
- Inline loading and saving of scripts into and from notebook cells


## Requirements
- kdb+>= v3.5 64-bit
- Python >= 3.5
- [embedPy](https://github.com/KxSystems/embedPy)

## Overview

You can either

*   Install jupyterq to run on your local machine; or
*   Download or build a Docker image in which to run jupyterq

There are two ways to install jupyterq on your local machine:

1.  Download and install a release

1.  Install with Conda - recommended if you are already using Anaconda Python

## Install on local machine

### Download and install a release

1. Make sure you have installed [embedPy](https://github.com/KxSystems/embedPy)

1. Download a release archive from the [releases](../../releases/latest) page, and unzip it.

1. Install the required Python packages with

   pip

   ```bash
   pip install -r requirements.txt
   ```

   or with conda

   ```bash
   conda install --file requirements.txt
   ```


1. Ensure QHOME is set and you have a working version of q in your PATH, note that jupyter will not pick up bash aliases when starting q, the location of the q executable needs to be in your PATH.

1. Run the install script

    Linux/macOS

    ```bash
      ./install.sh
    ```
    Windows
    ```
     install.bat
    ```

### Install with Conda

1. [Download and install](https://conda.io/docs/user-guide/install/download.html) either the full Anaconda distribution or Miniconda for Python3.

2. Use the `conda` to install jupyterq and it's dependencies

```bash
conda install -c kx jupyterq
```

3. Ensure you can run q *before* running jupyterq for the first time, you may need to generate an on demand licence

```bash
q
...
q)\\
```

## Running after install

To run the jupyter console
```
jupyter console --kernel=qpk
```
To run the example notebook
```
jupyter notebook kdb+Notebooks.ipynb
```

## Run a Docker Image

If you have [Docker installed](https://www.docker.com/community-edition) you can alternatively run:

    docker run -it -p 8888:8888 --name myjupyterq kxsys/jupyterq

Now point your browser at http://localhost:8888/notebooks/kdb%2BNotebooks.ipynb.

For subsequent runs, you will not be prompted to redo the license setup when calling:

    docker start -ai myjupyterq

**N.B.** [instructions regarding headless/presets are available](https://github.com/KxSystems/embedPy/docker/README.md#headlesspresets)

**N.B.** [build instructions for the image are available](docker/README.md)

## Using notebooks

See the notebook kdb+Notebooks.ipynb for full interactive examples and explanation, it should be viewable on github.


## Documentation

Documentation is available on the [jupyterq](https://code.kx.com/q/ml/jupyterq/) homepage.
