# ARG usage in FROMs has to go up here in global

ARG embedpy_img=kxsys/embedpy:1.1-docker

####

FROM debian:9 AS base

# do not clean here, its cleaned later!
RUN apt-get update \
	&& apt-get -yy update

####

FROM $embedpy_img AS embedpy

####

FROM continuumio/miniconda3 AS anaconda

#FROM base AS anaconda
#
## https://docs.anaconda.com/anaconda/install/hashes/Anaconda3-5.1.0-Linux-x86_64.sh-hash
#ARG anaconda_version=5.1.0
#ARG anaconda_url=https://repo.continuum.io/archive/Anaconda3-${anaconda_version}-Linux-x86_64.sh
#ARG anaconda_md5=966406059cf7ed89cc82eb475ba506e5
#ARG anaconda_sha256=7e6785caad25e33930bc03fac4994a434a21bc8401817b7efa28f53619fa9c29
#
#RUN apt-get -yy --no-install-recommends install curl ca-certificates bzip2 \
#	&& apt-get clean \
#	&& find /var/lib/apt/lists -type f -delete
#
#RUN curl -f -L --compressed -o /tmp/anaconda.sh ${anaconda_url} \
#	&& test $(cat /tmp/anaconda.sh | md5sum -    | awk '{ print $1 }') = ${anaconda_md5} \
#	&& test $(cat /tmp/anaconda.sh | sha256sum - | awk '{ print $1 }') = ${anaconda_sha256} \
#	&& /bin/sh /tmp/anaconda.sh -b -p /opt/conda \
#	&& rm /tmp/anaconda.sh
#
#RUN source /opt/conda/etc/profile.d/conda.sh

####

FROM base

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

RUN apt-get -yy --no-install-recommends install unzip rlwrap python3 libpython3.5 runit libgl1-mesa-glx \
	&& apt-get clean \
	&& find /var/lib/apt/lists -type f -delete

RUN passwd -d root
RUN useradd -s /bin/bash -U -m kx
COPY docker/profile /etc/profile.d/kx.sh
COPY docker/env /opt/kx/.env

ENV QHOME=/opt/kx/q
ENV PATH=$PATH:/opt/kx/q/l64 \
	LD_LIBRARY_PATH=${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}/opt/conda/lib

RUN mkdir -p $QHOME/l64

COPY --from=embedpy /opt/kx/embedPy /opt/kx/embedPy
RUN ln -s -t /opt/kx/q/l64 /opt/kx/embedPy/p.so \
	&& ln -s -t /opt/kx/q /opt/kx/embedPy/p.q /opt/kx/embedPy/p.k

COPY --from=anaconda /opt/conda /opt/conda

COPY . /opt/kx/jupyterq
RUN chown -R kx:kx /opt/kx/jupyterq
RUN find /opt/kx/jupyterq -maxdepth 1 -type f -name 'jupyterq_*.q' | xargs ln -s -t /opt/kx/q \
	&& ln -s -t /opt/kx/q /opt/kx/jupyterq/kxpy \
	&& ln -s -t /opt/kx/q/l64 /opt/kx/jupyterq/lib/l64/jupyterq.so

COPY docker/init /init

RUN . /opt/conda/etc/profile.d/conda.sh \
	&& conda install --file /opt/kx/jupyterq/requirements.txt

USER kx

RUN . /opt/conda/etc/profile.d/conda.sh \
	&& conda activate base \
	&& jupyter kernelspec install --user --name=qpk /opt/kx/jupyterq/kernelspec \
	&& jupyter trust /opt/kx/jupyterq/kdb+Notebooks.ipynb

# remove token auth
RUN mkdir ~/.jupyter \
	&& echo "c.NotebookApp.token = u''" > ~/.jupyter/jupyter_notebook_config.py

USER root

ENTRYPOINT ["/init"]
CMD . /opt/conda/etc/profile.d/conda.sh \
	&& conda activate base \
	&& printf "\npoint your browser at http://127.0.0.1:%s/notebooks/kdb%%2BNotebooks.ipynb\n\n" $PORT \
	&& exec jupyter notebook --notebook-dir=/opt/kx/jupyterq --ip='0.0.0.0' --port=$PORT --no-browser
