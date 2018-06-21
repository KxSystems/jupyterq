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
- kdb+>=? v3.5 64-bit
- Anaconda Python >= 3.5
- [embedPy](https://github.com/KxSystems/embedPy)


## Build and Installation

After you have installed embedPy install the Python dependencies with 

pip
```bash
pip install -r requirements.txt
```
or with conda
```bash
conda install --file requirements.txt
```
### Download

Download the appropriate release archive from the [releases](../../releases/latest) page.


### Linux/Mac

Ensure QHOME is set and you have a working version of q in your PATH, and run

```bash
./install.sh
```

### Windows
Ensure QHOME is set and you have a working version of q in your PATH, and run

```
install.bat
```

Jupyter console, notebook and QtConsole should work, Jupyter lab has not been tested

### Mac
On mac there seem to be issues with MKL when using in embedded python mode e.g. (https://github.com/ContinuumIO/anaconda-issues/issues/6423)

If you have a similar issue using Anaconda Python, the command below may resolve the issue.

```conda install nomkl```

### Docker

If you have [Docker installed](https://www.docker.com/community-edition) you can alternatively run:

    docker run -it -p 8888:8888 --name myjupyterq kxsys/jupyterq

Now point your browser at http://localhost:8888/notebooks/kdb%2BNotebooks.ipynb.

For subsequent runs, you will not be prompted to redo the license setup when calling:

    docker start -ai myjupyterq

**N.B.** [instructions regarding headless/presets are available](https://github.com/KxSystems/embedPy/docker/README.md#headlesspresets)

**N.B.** [build instructions for the image are available](docker/README.md)

## Running after install

To run the jupyter console
```
jupyter console --kernel=qpk
```
To run the example notebook
```
jupyter notebook kdb+Notebooks.ipynb
```


## Using notebooks

See the notebook kdb+Notebooks.ipynb for full interactive examples and explanation, it should be viewable on github.


## Documentation

Documentation is available on the [jupyterq](https://code.kx.com/q/ml/jupyterq/) homepage.
