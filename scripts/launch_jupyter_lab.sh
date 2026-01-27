#!/usr/bin/env bash
#export JUPYTER_NOTEBOOK_DIR="/path/to/your/notebooks"
set -e

VENV_ACTIVATE="$HOME/jupyter/bin/activate"
: "${JUPYTER_NOTEBOOK_DIR:?set JUPYTER_NOTEBOOK_DIR to the notebook directory}"

source "$VENV_ACTIVATE"
cd "$JUPYTER_NOTEBOOK_DIR"
exec jupyter lab "$@"
