# /usr/bin/env bash
set -e

echo "init conda for this shell"
eval "$('conda' 'shell.bash' 'hook' 2> /dev/null)"

ENV=$1
shift

echo "activate conda env $ENV"
conda activate $ENV

echo "Run command:" "$@"
"$@"