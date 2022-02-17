# Mirage Unreal CI/CD Image

You can use this image to build your Unreal Project to Android.

# Build image

Go to base folder. Clone "Unreal Engine" from github. Start to build base image.

`docker buildx build -t "ue4-mirage:4.27.2" --build-arg "BASEIMAGE=nvidia/opengl:1.0-glvnd-devel-ubuntu18.04" --build-arg "GIT_REPO=https://github.com/EpicGames/UnrealEngine.git" --build-arg "GIT_BRANCH=4.27.2-release" --build-arg "BUILD_DDC=true" --build-arg "EXCLUDE_DEBUG=0" --build-arg "EXCLUDE_TEMPLATES=0" --build-arg "SOURCE_LOCATION=./UnrealEngine" --build-arg "UE4CLI_VERSION=ue4cli" --build-arg "CONAN_UE4CLI_VERSION=conan-ue4cli" --load .`

Then go to root folder. Build builder image

`docker build -t mirage-unreal-builder .`

# Run Builder

Copy your project in a folder. Create folder named dist. Run instance.

`docker run -vunreal-project:/tmp/project:rw -vdist:/tmp/project/dist:rw mirage-unreal-builder`

# Credit

Base image's Dockerfile taken from https://github.com/adamrehn/ue4-docker
