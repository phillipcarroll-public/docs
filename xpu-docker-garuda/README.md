# Setup Docker Intel IPEX Containers For Pytorch

XPU/XE kernel drivers should already be installed.

### Install Docker on Arch Based Garuda

This is probably already installed via the Garuda Setup Assistant, just check `Docker`

If you have not selected this go ahead and do so now, you will need to reboot once `Docker` is installed.

Test with: `sudo docker run hello-world`

We have two things to do, create our Dockerfile which we will use to create our own image extended from the official intel repo. Then we will run our setup script which will create our script we will use to execute and open the jupyter lab environment. 

This will create a folder, our storage volume which will be used as the `/jupyter` working directory from within the container. 

We will generate the Dockerfile in our build script but I have a copy in this same folder: <a href="Dockerfile">Dockerfile</a>

Our build script: <a href="intel-xpu-build.sh">intel-xpu-build.sh</a>

This script will perform the following:

- Create folder/s: `~/XPU/jupyter`
- Create Dockerfile in: `~/XPU/Dockerfile`
- Create Docker image
- Create run script in: `~/XPU/xpu-ipex-torch-docker.sh`
- You should now be able to start the container with: `bash ~/XPU/xpu-ipex-torch-docker.sh`