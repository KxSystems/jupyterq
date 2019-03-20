usage=\
"Usage:\n\tdoit.sh [repodir]

\tbuilds conda package, set NOTEST in env to skip tests during conda build (faster)
"

if [ $# -lt 1 ]
then
	printf "$usage" >&2
	exit 1
elif [ ! -d $1 ]
then
	printf "$1 doesn't exist\n\n$usage" >&2
	exit 1
fi

: "${JUPYTERQ_VERSION:=local_dev}"
[ -z "$NOTEST" ] && export QLIC="${QLIC:=$QHOME}"

JUPYTERQ_REQS=$(paste -sd "|" $1/requirements.txt)

export JUPYTERQ_REQS
export JUPYTERQ_VERSION
export QLIC

set -x
if [ ! -z "$QLIC" ]
then
	conda build -c kx --no-long-test-prefix $1/conda-recipe
else
	conda build -c kx --no-test conda-recipe
fi
