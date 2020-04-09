#! /usr/bin/env bash

#####
# This script sets up the basic user Jupyter home directory for use on Pangeo.
# Wholly duplicated from https://github.com/pangeo-data/helm-chart/blob/8eb9c1a78c9b27fd75c540b389d3bb2ca056e070/docker-images/notebook/prepare.sh.
#####


set -x

#########################
# Add example notebooks #
#########################

echo "Getting example notebooks..."
if [ -z "$EXAMPLES_GIT_URL" ]; then
    export EXAMPLES_GIT_URL=https://github.com/pangeo-data/pangeo-example-notebooks
fi
EXAMPLES_DIR="examples_and_docs"
rmdir examples &> /dev/null # deletes directory if empty, in favour of fresh clone
if [ ! -d "$EXAMPLES_DIR" ]; then
  git clone $EXAMPLES_GIT_URL $EXAMPLES_DIR
fi
cd $EXAMPLES_DIR
chmod -R 700 *.ipynb
git remote set-url origin $EXAMPLES_GIT_URL
git fetch origin
git reset --hard origin/master
git merge --strategy-option=theirs origin/master
if [ ! -f DONT_SAVE_ANYTHING_HERE.md ]; then
  echo "# Files in this directory should be treated as read-only"  > DONT_SAVE_ANYTHING_HERE.md
fi
chmod -R 400 *.ipynb
cd ..
chmod -R 500 $EXAMPLES_DIR
echo "Done"


#####################################
# Set up conda kernels 
#####################################
ENV_DIR="/envs/auto-build-envs"
LOCAL_ENV_DIR=~/my-conda-envs
echo "init conda for this shell"
eval "$('conda' 'shell.bash' 'hook' 2> /dev/null)"

if [ ! -f ~/.condarc ]; then
  mkdir -p ~/my-conda-envs
  conda config --add envs_dirs $ENV_DIR # Order important. The first will be the default.
  conda config --add envs_dirs /opt/anaconda/envs
  conda config --add envs_dirs $LOCAL_ENV_DIR
fi


#####################################
# Link to data dirs
#####################################
ln -s /datasets/ /home/jovyan/data

#####################################
# install Python kernels
#####################################

ORIG_CONDA_ENV=$CONDA_DEFAULT_ENV
KERNELS=$(jupyter kernelspec list --json  | jq -c '.kernelspecs | keys[] as $k | .[$k].spec.display_name' | tr '\n' ' ')
echo "Existing kernels: ${KERNELS}"
for ENV_PATH in ${ENV_DIR}/*; do 
  ENV=$(basename $ENV_PATH)
  K_NAME="Python (${ENV})"
  if [[ $KERNELS != *"\"${K_NAME}\""* ]]; then
    echo "$ENV doesn't exist as a Kernel. Create it."
    conda activate "${ENV_PATH}"
    python -m ipykernel install --user --name $ENV --display-name "Python ($ENV)" 
  fi
done

#####################################
# and copy pre-registered kernels
#####################################

cp -r /envs/pre-built-envs/kernels/* ~/.local/share/jupyter/kernels

#####################################
# activate the environment with jupyter lab in it 
#####################################
conda activate /envs/infrastructure/lab # TODO: this should be a env var or somehow less hard coded.



# #####################################
# # Update .ssh directory permissions #
# #####################################

# chmod -R 400 .ssh/id_rsa &> /dev/null


######################
# Run extra commands #
######################
$@