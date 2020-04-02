# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
ARG BASE_CONTAINER=ucsdets/scipy-ml-notebook:2019.4.6
FROM $BASE_CONTAINER

LABEL maintainer="UC San Diego ITS/ETS <ets-consult@ucsd.edu>"

USER root

#ENV http_proxy=http://web.ucsd.edu:3128
#ENV https_proxy=http://web.ucsd.edu:3128

###########################
# Requested for DSC170 WI20
RUN apt-get update && apt-get -qq install -y \
	libproj-dev proj-data proj-bin libgeos-dev libspatialindex-dev \
	graphviz

# Install ESRI-managed package
# Conda > 4.7.10 required for arcgis
RUN conda upgrade conda -y --no-pin && \
	conda install -c esri arcgis==1.8.0 -y 

RUN jupyter nbextension enable arcgis --py --sys-prefix

RUN chown -R $NB_UID /home/jovyan

COPY pip-requirements.txt /tmp
RUN pip install --no-cache-dir -r /tmp/pip-requirements.txt  && \
        fix-permissions $CONDA_DIR

USER $NB_UID

