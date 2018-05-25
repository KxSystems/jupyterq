# ARG usage in FROMs has to go up here in global

ARG embedpy_img=kxsys/embedpy:latest

####

FROM $embedpy_img AS embedpy

# do not clean here, its cleaned later!
# no upgrade either as it comes from embedPy
RUN apt-get update

####

FROM embedpy AS juypterq

RUN apt-get -yy --option=Dpkg::options::=--force-unsafe-io --no-install-recommends install \
		build-essential \
	&& apt-get clean \
	&& find /var/lib/apt/lists -type f -delete

COPY makefile.in requirements.txt *.q *.p *.ipynb /opt/kx/jupyterq/
COPY src/c/ /opt/kx/jupyterq/src/c/
COPY src/include/ /opt/kx/jupyterq/src/include/
COPY kxpy/ /opt/kx/jupyterq/kxpy/
COPY kernelspec/ /opt/kx/jupyterq/kernelspec/

RUN make -f makefile.in -C /opt/kx/jupyterq jupyterq

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

RUN apt-get -yy --option=Dpkg::options::=--force-unsafe-io --no-install-recommends install \
		libgl1-mesa-glx \
	&& apt-get clean \
	&& find /var/lib/apt/lists -type f -delete

COPY --from=juypterq /opt/kx/jupyterq /opt/kx/jupyterq
RUN chown kx:kx /opt/kx/jupyterq /opt/kx/jupyterq/kdb+Notebooks.ipynb
RUN find /opt/kx/jupyterq -maxdepth 1 -type f -name 'jupyterq_*.q' | xargs ln -s -t /opt/kx/q \
	&& ln -s -t /opt/kx/q /opt/kx/jupyterq/kxpy \
	&& ln -s -t /opt/kx/q/l64 /opt/kx/jupyterq/l64/jupyterq.so

USER kx

RUN . /opt/conda/etc/profile.d/conda.sh \
	&& conda activate kx \
	&& conda install nomkl \
	&& conda install --file /opt/kx/jupyterq/requirements.txt \
	&& conda clean -y --all \
	&& jupyter kernelspec install --user --name=qpk /opt/kx/jupyterq/kernelspec \
	&& jupyter trust /opt/kx/jupyterq/kdb+Notebooks.ipynb

# remove token auth
RUN mkdir ~/.jupyter \
	&& echo "c.NotebookApp.token = u''" > ~/.jupyter/jupyter_notebook_config.py

USER root

ENTRYPOINT ["/init"]
CMD ["/bin/sh", "-l", "-c", "printf '\npoint your browser at http://127.0.0.1:%s/notebooks/kdb%%2BNotebooks.ipynb\n\n' $PORT && exec jupyter notebook --notebook-dir=/opt/kx/jupyterq --ip='0.0.0.0' --port=$PORT --no-browser"]
