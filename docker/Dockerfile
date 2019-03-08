# ARG usage in FROMs has to go up here in global

ARG embedpy_img=kxsys/embedpy:latest

####

FROM $embedpy_img AS embedpy
FROM embedpy AS juypterq

RUN apt-get update \
	&& apt-get -yy --option=Dpkg::options::=--force-unsafe-io --no-install-recommends install build-essential \
	&& apt-get clean \
	&& find /var/lib/apt/lists -type f -delete

COPY build/makefile requirements.txt *.q *.p *.ipynb /opt/kx/jupyterq/
COPY jupyterq_licensemgr/ /opt/kx/jupyterq/jupyterq_licensemgr/
COPY src/c/ /opt/kx/jupyterq/src/c/
COPY kxpy/ /opt/kx/jupyterq/kxpy/
COPY kernelspec/ /opt/kx/jupyterq/kernelspec/
COPY examples/ /opt/kx/jupyterq/examples/

RUN make -C /opt/kx/jupyterq jupyterq

####

FROM embedpy

ARG port=8888
ENV PORT=${port}
EXPOSE ${port}/tcp

ARG VCS_REF=dev
ARG BUILD_DATE=dev

LABEL	org.label-schema.schema-version="1.0" \
	org.label-schema.name=jupyterq \
	org.label-schema.description="Jupyter kernel for kdb+" \
	org.label-schema.vendor="Kx" \
	org.label-schema.license="Apache-2.0" \
	org.label-schema.url="https://code.kx.com/q/ml/jupyterq/" \
	org.label-schema.version="${VERSION:-dev}" \
	org.label-schema.vcs-url="https://github.com/KxSystems/jupyterq.git" \
	org.label-schema.vcs-ref="$VCS_REF" \
	org.label-schema.build-date="$BUILD_DATE" \
	org.label-schema.docker.cmd="docker run -v `pwd`/q:/tmp/q -p $PORT:$PORT kxsys/jupyterq"

COPY --from=juypterq /opt/kx/jupyterq /opt/kx/jupyterq
RUN chown kx:kx /opt/kx/jupyterq /opt/kx/jupyterq/examples/kdb+Notebooks.ipynb
RUN find /opt/kx/jupyterq -maxdepth 1 -type f -name 'jupyterq_*.q' | xargs ln -s -t /opt/kx/q \
	&& ln -s -t /opt/kx/q /opt/kx/jupyterq/kxpy \
	&& ln -s -t /opt/kx/q/l64 /opt/kx/jupyterq/l64/jupyterq.so

RUN apt-get update \
	&& apt-get -yy --option=Dpkg::options::=--force-unsafe-io --no-install-recommends install xinetd libgl1-mesa-glx \
	&& apt-get clean \
	&& find /var/lib/apt/lists -type f -delete

USER kx

RUN . /opt/conda/etc/profile.d/conda.sh \
	&& conda activate kx \
	&& conda install nomkl \
	&& conda install --file /opt/kx/jupyterq/requirements.txt \
	&& conda clean -y --all

USER root

RUN chown -R kx:kx /opt/kx/jupyterq/jupyterq_licensemgr

USER kx

RUN . /opt/conda/etc/profile.d/conda.sh \
	&& conda activate kx \
	&& cd /opt/kx/jupyterq/jupyterq_licensemgr \
	&& python setup.py build \
	&& pip install --user --no-deps .

# remove token auth
RUN mkdir -p ~/.jupyter \
	&& echo "c.NotebookApp.token = u''" > ~/.jupyter/jupyter_notebook_config.py

RUN . /opt/conda/etc/profile.d/conda.sh \
	&& conda activate kx \
	&& jupyter kernelspec install --user --name=qpk /opt/kx/jupyterq/kernelspec \
	&& jupyter nbextension install --user --py jupyterq_licensemgr \
	&& jupyter nbextension enable --user --py jupyterq_licensemgr \
	&& jupyter serverextension enable --py jupyterq_licensemgr \
	&& jupyter trust /opt/kx/jupyterq/examples/kdb+Notebooks.ipynb

USER root
COPY docker/init /init
RUN chmod 0755 /init


## Create new Entry folders
## Notebooks, Data & Scripts can all be mounted to these folders

ARG nbroot=/jqnotebooks
ARG nbdata=/jqdata
ARG nbscripts=/jqscripts

ENV NBROOT=${nbroot}
ENV NBDATA=${nbdata}
ENV NBSCRIPTS=${nbscipts}

VOLUME ${nbroot} ${nbdata} ${nbscripts}

ENTRYPOINT ["/init"]
