The instructions below are for building your own Docker image. A prebuilt Docker image is available on Docker Cloud, if you only want to run the jupyterq image then install Docker and [read the instructions on the main page](../README.md#docker) on how to do this.

## Preflight

You will need [Docker installed](https://www.docker.com/community-edition) on your workstation; make sure it is a recent version.

Check out a copy of the project with:

    git clone https://github.com/KxSystems/jupyterq.git

## Building

To build the project locally you run:

    docker build -t jupyterq -f docker/Dockerfile .

Once built, you should have a local `jupyterq` image, you can run the following to use it:

    docker run --rm -it -p 8888:8888 jupyterq


**N.B.** if you wish to use an alternative source for [embedPy](https://github.com/KxSystems/embedPy) then you can append `--build-arg embedpy_img=embedpy` to your argument list.

Other build arguments are supported and you should browse the `Dockerfile` to see what they are.


# Deploy

[travisCI](https://travis-ci.org/) is configured to monitor when tags of the format `/^[0-9]+\./` are added to the [GitHub hosted project](https://github.com/KxSystems/jupyterq), a corresponding Docker image is generated and made available on [Docker Cloud](https://cloud.docker.com/)

This is all done server side as the resulting image is large.

To do a deploy, you simply tag and push your releases as usual:

    git push
    git tag 0.7
    git push --tag


## Run Options

These options apply both to a locally build image if you have one or the `kxsys/jupyterq` image

To change the port the container exposes the notebook server on:

    docker run --rm -it -p 9000:9000 -e PORT=9000 kxsys/jupyterq

You can use the image to run your own JupyterQ notebooks without building another docker image, the directory with your notebooks should be mounted in the container at /jqnotebooks.

For example if your notebooks are on the host machine in a directory `examples`, then:

On Windows

    docker run -it -p 8888:8888 -v %cd%\examples:/jqnotebooks kxsys/jupyterq

Or on Mac / Linux

    docker run -it -p 8888:8888 -v $(pwd)/examples:/jqnotebooks kxsys/jupyterq


## Related Links

 * [Docker](https://docker.com)
     * [`Dockerfile`](https://docs.docker.com/engine/reference/builder/)
