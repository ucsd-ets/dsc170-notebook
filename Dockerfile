# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
ARG BASE_CONTAINER=ucsdets/scipy-ml-notebook:2019.4.6
FROM $BASE_CONTAINER

LABEL maintainer="UC San Diego ITS/ETS <ets-consult@ucsd.edu>"

USER root

ENV http_proxy=http://web.ucsd.edu:3128
ENV https_proxy=http://web.ucsd.edu:3128

###########################
# Requested for DSC170 WI20
RUN apt-get update && apt-get -qq install -y \
	libproj-dev proj-data proj-bin libgeos-dev libspatialindex-dev \
	graphviz

# Conda > 4.7.10 required for arcgis
RUN conda install conda==4.8.0 -y 

# Install ESRI-managed package
RUN conda install -c esri arcgis==1.7.0 -y 

# nbgrader
RUN conda install nbgrader && conda clean -tipsy && \
	jupyter nbextension install --symlink --sys-prefix --py nbgrader && \
	jupyter nbextension enable --sys-prefix --py nbgrader && \
	jupyter serverextension enable --sys-prefix --py nbgrader && \
	jupyter nbextension disable --sys-prefix formgrader/main --section=tree && \
	jupyter serverextension disable --sys-prefix nbgrader.server_extensions.formgrader && \
	jupyter nbextension disable --sys-prefix create_assignment/main && \
	pip install ipywidgets && \
	jupyter nbextension enable --sys-prefix --py widgetsnbextension && \
	jupyter nbextension install --sys-prefix --py arcgis && \
	jupyter nbextension enable --sys-prefix --py arcgis

# hacked local version of nbresuse to show GPU activity
RUN pip install --no-cache-dir git+https://github.com/agt-ucsd/nbresuse.git && \
	jupyter serverextension enable --sys-prefix --py nbresuse && \
	jupyter nbextension install --sys-prefix --py nbresuse && \
	jupyter nbextension enable --sys-prefix --py nbresuse

## NOTE: cartopy requires PROJ < 6 (4.9.3, provided by OS 'apt-get ')
## graphviz and rasterio PROJ >= 6 (provided by conda-forge)
## So cartopy must be installed before graphviz/rasterio!

COPY pip-requirements.txt /tmp
RUN pip install --no-cache-dir -r /tmp/pip-requirements.txt  && \
	fix-permissions $CONDA_DIR 

# Must happen after "pip install" above - cartopy must link against PROJ 4.x
RUN conda install -c conda-forge rasterio graphviz

USER $NB_UID

