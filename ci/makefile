ifeq ($(platform),l64)
 CNDPLAT := linux-64
 CNDURL  := https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
 RMRPATH := patchelf --remove-rpath
 RELPLAT := linux
else
 CNDPLAT := osx-64
 CNDURL  := https://repo.continuum.io/miniconda/Miniconda3-latest-MacOSX-x86_64.sh
 RMRPATH := install_name_tool -delete_rpath @loader_path/../../lib
 RELPLAT := osx
endif
P ?= $(HOME)/.gitlab-runner
CNDENV := jupyterq_bld_$(platform)
CNDCHN ?= kx/label/dev -c kx
#prereqs
conda: $(P)/miniconda/
$(P)/miniconda/:
	wget $(CNDURL) -O miniconda.sh
	bash miniconda.sh -b -p $(P)/miniconda
	. "$(P)/miniconda/etc/profile.d/conda.sh" && \
	hash -r && \
	conda config --set always_yes yes --set changeps1 no && \
	conda update -q conda && \
	conda install -q conda-build
#tests
test:
	ci/conda_test.sh $(P) $(platform) $(CNDENV)

#release and deploy
l64/ghrelease:
	gpg -d --batch $(P)/ghtoken.gpg |gh auth login --with-token
	gh release create -d -p -R KxSystems/jupyterq --generate-notes $(CI_COMMIT_TAG) jupyterq_*-$(CI_COMMIT_TAG).tgz

$(platform)/conda: conda
	ci/conda.sh $(P) $(CNDENV) $(CNDCHN)
l64/docker:
	docker build -t kxsys/jupyterq:latest -f docker/Dockerfile .
	docker tag kxsys/jupyterq:latest kxsys/jupyterq:$(CI_COMMIT_TAG)
	#echo $(DOCKER_PASSWORD)|docker login --username $(DOCKER_USERNAME) --password-stdin && docker push kxsys/jupyterq:latest && docker push kxsys/jupyterq:$(CI_COMMIT_TAG)
$(platform)/github:
	tar czf jupyterq_$(RELPLAT)-$(CI_COMMIT_TAG).tgz jupyterq*.q install.sh requirements.txt README.md LICENSE kxpy kernelspec examples kdb+Notebooks.ipynb [ml]64/jupyterq.so
