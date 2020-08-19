ARG BASE_CONTAINER=ucsdets/datahub-base-notebook:dev
FROM $BASE_CONTAINER

LABEL maintainer="UC San Diego ITS/ETS <ets-consult@ucsd.edu>"

USER root

###########################
# Requested for DSC170 WI20
RUN apt-get -qq install -y \
	libproj-dev proj-data proj-bin libgeos-dev libspatialindex-dev \
	graphviz

# Install ESRI-managed package
COPY pip-requirements.txt /tmp
RUN pip install --no-cache-dir -r /tmp/pip-requirements.txt --use-feature=2020-resolver

RUN python -m arcgis.install
RUN jupyter nbextension enable widgetsnbextension --py --sys-prefix
RUN jupyter nbextension enable arcgis --py --sys-prefix

COPY /arcgis_test.ipynb /home/jovyan
RUN chown -R $NB_UID /home/jovyan

USER $NB_UID