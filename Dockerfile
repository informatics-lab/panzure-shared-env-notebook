
FROM jupyterhub/singleuser

#####################################################################
# Root                                                              #
#####################################################################

USER root

# Install system packages
RUN apt-get update -y && apt-get install -y \
    vim \
    less \
    sudo \
    ssh \
    jq


# Add USER to sudo
RUN echo "$USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/notebook
RUN sed -ri "s#Defaults\s+secure_path=\"([^\"]+)\"#Defaults secure_path=\"\1:$CONDA_DIR/bin\"#" /etc/sudoers

# Add prepare script for copying examples dir to single user homespaces.
COPY prepare_homespace.sh /usr/bin/prepare_homespace.sh
RUN chmod +x /usr/bin/prepare_homespace.sh

#####################################################################
# User                                                              #
#####################################################################

USER $USER


# # Install jupyter server extentions.
SHELL ["/bin/bash", "-c"]
RUN jupyter labextension install --dev-build=False \
    @jupyterlab/hub-extension \
    @jupyter-widgets/jupyterlab-manager \
    @jupyter-widgets/jupyterlab-sidecar \
    @pyviz/jupyterlab_pyviz \
    dask-labextension \
    jupyterlab_bokeh \
    jupyter-leaflet

# pepare script added above in the root commands section.
ENTRYPOINT ["/usr/bin/prepare_homespace.sh"]            