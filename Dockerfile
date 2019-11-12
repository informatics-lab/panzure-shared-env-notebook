
FROM continuumio/miniconda3

ARG NB_USER="jovyan"
ARG NB_UID="1000"
ARG NB_GID="100"


#####################################################################
# Root                                                              #
#####################################################################

USER root


# make a 'data' dir to stick data in later.

CMD mkdir -p /data

#####################################################################
# Set up jovyan user                                                #
#####################################################################

# Configure environment
ENV SHELL=/bin/bash \
    NB_USER=$NB_USER \
    NB_UID=$NB_UID \
    NB_GID=$NB_GID


# Create NB_USER wtih name jovyan user with UID=1000 and in the 'users' group
# and make sure these dirs are writable by the `users` group.
RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER 


# Install system packages
RUN apt-get update -y && apt-get install -y \
    vim \
    less \
    sudo \
    ssh \
    jq


# Add USER to sudo
RUN echo "$NB_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/notebook
RUN sed -ri "s#Defaults\s+secure_path=\"([^\"]+)\"#Defaults secure_path=\"\1:$CONDA_DIR/bin\"#" /etc/sudoers

# Add prepare script for copying examples dir to single user homespaces.
COPY prepare_homespace.sh /usr/bin/prepare_homespace.sh
RUN chmod +x /usr/bin/prepare_homespace.sh

# Add script for running commands in/under a conda env.
COPY run_as_conda_env.sh /usr/bin/run_as_conda_env.sh
RUN chmod +x /usr/bin/run_as_conda_env.sh


# Create a space for dask workers to work
RUN mkdir /scratch 
RUN chgrp $NB_GID /scratch 
RUN chown $NB_USER /scratch 
RUN chmod g+w /scratch 

## TODO: remove this hack which is here because in our current config you run as root rather than jovyan
RUN rm -r /root
RUN ln -s /home/jovyan /root

#####################################################################
# User                                                              #
#####################################################################

USER $NB_USER

WORKDIR /home/$NB_USER


SHELL ["/bin/bash", "-c"]

# pepare script added above in the root commands section.
ENTRYPOINT ["/usr/bin/prepare_homespace.sh"]            