This project builds the Docker image.

## Related Links

 * [Docker](https://docker.com)
     * [`Dockerfile`](https://docs.docker.com/engine/reference/builder/)
     * [Automated Builds](https://docs.docker.com/docker-cloud/builds/automated-build/)
         * [Advanced options for Autobuild and Autotest](https://docs.docker.com/docker-cloud/builds/advanced/)

# Preflight

You will need [Docker installed](https://www.docker.com/community-edition) on your workstation; make sure it is a recent version as they are always breaking backwards compatibility.

Check out a copy of the project with:

    git clone https://github.com/KxSystems/jupyterq.git

# Deploy

[Docker Cloud](https://cloud.docker.com/) is configured to monitor when tags of the format `/^[0-9.]+/` are added to the [GitHub hosted project](https://github.com/KxSystems/jupyterq), a corresponding Docker image file is generated and made available.

This is all done server side as the resulting image is north of 2.5GB and uploading that sort of thing is likely to prompt the network team to Release the Kraken!

To do a deploy, you simply tag and push your releases as usual:

    git push
    git tag 0.7
    git push --tag

## First Time Configuration

 1. Log into [Docker Cloud](https://cloud.docker.com/)
 1. Create the new repository called `jupyterq`
 1. Go to the 'Builds' tab
 1. Set the 'Source Repository' to the GitHub account 'KxSystems' and project `jupyterq`
 1. Set the 'Build Rules' to:
       * **Source Type:** Tag
       * **Source:** `/^[0-9.]+/`
       * **Docker Tag:** `{sourceref}`
       * **Dockerfile location:** `docker/Dockerfile`
       * **Build Context:** `/`
       * **Autobuild:** enabled
       * **Build Caching:** disabled (Docker Cloud is *really* buggy, `nocache=1` as a build env may help)
 1. Click on the 'Save' button

If you prefer to not have Docker Cloud build on every tag push, you can alternatively:

 1. Under 'Build Rules' disable 'Autobuild'
 1. Click on 'Save'
 1. At the bottom of the configuration page under 'Build triggers', create a URL that you can use to fire off a build

You should now be able to call `curl` on the supplied URL to trigger the build, sparing you from having to log in to click a button.

# Build

To build locally the project you run:

    docker build -t jupyterq -f docker/Dockerfile .

**N.B.** if you wish to use an alternative source for [embedPy](https://github.com/KxSystems/embedPy) then you can append `--build-arg embedpy_img=embedpy` to your argument list.

Other build arguments are supported and you should browse the `Dockerfile` to see what they are, but note for Docker Cloud you will need to make sure they are also explicitly exported in [`docker/hooks/build`](hooks/build) too.

