P=$1;platform=$2;CNDENV=$3
set -e
. "$P/miniconda/etc/profile.d/conda.sh"
conda create -n $CNDENV && conda activate $CNDENV
conda install -c kx/label/dev kdb
conda install -c kx/label/dev embedpy
cp $platform/jupyterq.so .
export QLIC=$P
pip install -qqq -r requirements.txt
pip install -qqq -r tests/requirements.txt
./install.sh 
tests/test.sh
conda deactivate && conda env remove -n $CNDENV

