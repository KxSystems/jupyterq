# JupyterQ



Jupyter kernel for kdb+. Features include

-   syntax highlighting for q
-   code completion for q keywords, `.z`/`.h`/`.Q`/`.j` namespace functions, and user-defined variables
-   code help for q keywords and basic help (display and type information) for user-defined objects
-   script-like execution of code (multiline input)
-   inline display of charts created using `embedPy` and `matplotlib`
-   console stdout/stderr capture and display in notebooks
-   inline loading and saving of scripts into and from notebook cells


## Requirements

- kdb+ ≥ v3.5 64-bit
- Python ≥ 3.5
- [embedPy](https://github.com/KxSystems/embedPy)


## Overview

You can either

-   install JupyterQ to run on your local machine; or
-   download or build a Docker image in which to run JupyterQ

There are two ways to install JupyterQ on your local machine:

1.  download and install a release
1.  install with Conda – recommended if you are already using Anaconda Python


## Install on local machine

<a id='download-and-install-a-release'></a>
### Download and install a release

1.  Make sure you have installed [embedPy](https://github.com/KxSystems/embedPy)

1.  Download a release archive from the [releases](../../releases/latest) page, and unzip it.

1.  Install the required Python packages with Pip or Conda

    ```bash
    # pip
    pip install -r requirements.txt
    # conda
    conda install --file requirements.txt
    ```

1. Ensure `QHOME` is set and you have a working version of q in your `PATH`. Note that Jupyter will not pick up Bash aliases when starting q: the location of the q executable needs to be in your `PATH`.

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

1.  [Download and install](https://conda.io/docs/user-guide/install/download.html) either the full Anaconda distribution or Miniconda for Python3.

2.  Use Conda to install JupyterQ and its dependencies

    ```bash
    conda install -c kx jupyterq
    ```

3. Ensure you can run q _before_ running JupyterQ for the first time. You may need to obtain an on-demand licence

  ```bash
  q
  …
  q)\\
  ```
---
**_NOTE_**

If installing on a system which already has kdb+ we recommended installing JupyterQ, embedPy and the conda packaged version of kdb+ in a conda environment, this can be done using the following steps

```
// create a new environment and install jupyterq and its dependancies
> conda create -n jupyterqenv -c kx jupyterq
// move into the new environment where jupyterq can be run
> conda activate jupyterqenv
```

It should be noted that in this case JupyterQ, embedPy and the conda installed kdb can only be run from this activated environment.

---   
## Running after install

To run the Jupyter console

```bash
jupyter console --kernel=qpk
```

To run the example notebook

```bash
jupyter notebook kdb+Notebooks.ipynb
```


## Run a Docker image

If you have [Docker installed](https://www.docker.com/community-edition) you can alternatively run:

```bash
docker run -it --name myjupyterq -p 8888:8888 kxsys/jupyterq
```

Now point your browser at <http://localhost:8888/notebooks/kdb%2BNotebooks.ipynb>.

For subsequent runs, you will not be prompted to redo the license setup when calling:

```bash
docker start -ai myjupyterq
```

To change the port or use the image to run your own notebooks, see the Docker [README](docker/README.md#runoptions).

See [instructions regarding headless/presets](https://github.com/KxSystems/embedPy/blob/master/docker/README.md#headlesspresets).

See [build instructions for the image](docker/README.md).


## Using notebooks

See the notebook `kdb+Notebooks.ipynb` for full interactive examples and explanation. (It should be legible on GitHub.)


## Documentation

See documentation on the [JupyterQ](https://code.kx.com/v2/ml/jupyterq/) homepage.
