# This file was generated by ue4-docker version 0.0.96 with the following options:
# 
# - combine: true
# - excluded_components: {"ddc": false, "debug": false, "templates": false}
# 
# This Dockerfile combines the steps for the following images:
# 
# - ue4-build-prerequisites
# - ue4-source
# - ue4-minimal
# - ue4-full

ARG BASEIMAGE
FROM ${BASEIMAGE} as prerequisites

# Add a sentinel label so we can easily identify all derived images, including intermediate images
LABEL com.adamrehn.ue4-docker.sentinel="1"

# Disable interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Add the "display" driver capability for NVIDIA GPUs
# (This also allows us to run the Editor from an interactive container by bind-mounting the host system's X11 socket)
ENV NVIDIA_DRIVER_CAPABILITIES ${NVIDIA_DRIVER_CAPABILITIES},display

# Install our build prerequisites
RUN apt-get update && apt-get install -y --no-install-recommends \
		build-essential \
		ca-certificates \
		curl \
		git \
		git-lfs \
		python3 \
		python3-dev \
		python3-pip \
		shared-mime-info \
		software-properties-common \
		sudo \
		tzdata \
		unzip \
		xdg-user-dirs \
		zip  libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 libbz2-1.0:i386 default-jre openjdk-17-jre wget && \ 
		# Top line added
	rm -rf /var/lib/apt/lists/* && echo '' && echo 'RUN directive complete. Docker will now commit the filesystem layer to disk.' && echo 'Note that for large filesystem layers this can take quite some time.' && echo 'Performing filesystem layer commit...' && echo ''

# Install the X11 runtime libraries required by CEF so we can cook Unreal Engine projects that use the WebBrowserWidget plugin
# (Starting in Unreal Engine 5.0, we need these installed before creating an Installed Build to prevent cooking failures related to loading the Quixel Bridge plugin)
RUN apt-get update && apt-get install -y --no-install-recommends \
			libasound2 \
			libatk1.0-0 \
			libatk-bridge2.0-0 \
			libcairo2 \
			libfontconfig1 \
			libfreetype6 \
			libglu1 \
			libnss3 \
			libnspr4 \
			libpango-1.0-0 \
			libpangocairo-1.0-0 \
			libsm6 \
			libxcomposite1 \
			libxcursor1 \
			libxi6 \
			libxrandr2 \
			libxrender1 \
			libxss1 \
			libxtst6 \
			libxv1 \
			x11-xkb-utils \
			xauth \
			xfonts-base \
			xkb-data && \
	rm -rf /var/lib/apt/lists/* && echo '' && echo 'RUN directive complete. Docker will now commit the filesystem layer to disk.' && echo 'Note that for large filesystem layers this can take quite some time.' && echo 'Performing filesystem layer commit...' && echo ''

# Disable the default "lecture" message the first time a user runs a command using sudo
RUN echo 'Defaults lecture="never"' >> /etc/sudoers && echo '' && echo 'RUN directive complete. Docker will now commit the filesystem layer to disk.' && echo 'Note that for large filesystem layers this can take quite some time.' && echo 'Performing filesystem layer commit...' && echo ''

# Unreal refuses to run as the root user, so create a non-root user with no password and allow them to run commands using sudo
RUN useradd --create-home --home /home/ue4 --shell /bin/bash --uid 1000 ue4 && \
	passwd -d ue4 && \
	usermod -a -G audio,video,sudo ue4 && echo '' && echo 'RUN directive complete. Docker will now commit the filesystem layer to disk.' && echo 'Note that for large filesystem layers this can take quite some time.' && echo 'Performing filesystem layer commit...' && echo ''
USER ue4

# Enable Git Large File Storage (LFS) support
RUN git lfs install && echo '' && echo 'RUN directive complete. Docker will now commit the filesystem layer to disk.' && echo 'Note that for large filesystem layers this can take quite some time.' && echo 'Performing filesystem layer commit...' && echo ''

FROM prerequisites as source

# Enable verbose output for steps that patch files?
ARG VERBOSE_OUTPUT=0

# Copy the Unreal Engine source code from the host system
ARG SOURCE_LOCATION
COPY ${SOURCE_LOCATION} /home/ue4/UnrealEngine

# Apply our bugfix patches to broken Engine releases such as 4.25.4
# (Make sure we do this before the post-clone setup steps are run)
COPY --chown=ue4:ue4 patch-broken-releases.py /tmp/patch-broken-releases.py
RUN python3 /tmp/patch-broken-releases.py /home/ue4/UnrealEngine $VERBOSE_OUTPUT && echo '' && echo 'RUN directive complete. Docker will now commit the filesystem layer to disk.' && echo 'Note that for large filesystem layers this can take quite some time.' && echo 'Performing filesystem layer commit...' && echo ''

# Run post-clone setup steps, ensuring our package lists are up to date since Setup.sh doesn't call `apt-get update`
WORKDIR /home/ue4
RUN wget https://redirector.gvt1.com/edgedl/android/studio/ide-zips/4.0.2.0/android-studio-ide-193.6821437-linux.tar.gz
RUN tar xvf android-studio-ide-193.6821437-linux.tar.gz
RUN wget https://dl.google.com/android/repository/commandlinetools-linux-8092744_latest.zip
RUN unzip commandlinetools-linux-8092744_latest.zip
RUN mkdir /home/ue4/Android/Sdk/ -p
RUN mv cmdline-tools /home/ue4/Android/Sdk/cmdline-tools


RUN /home/ue4/Android/Sdk/cmdline-tools/bin/sdkmanager --update --sdk_root=/home/ue4/Android/Sdk/
RUN yes | /home/ue4/Android/Sdk/cmdline-tools/bin/sdkmanager --licenses --sdk_root=/home/ue4/Android/Sdk/
RUN /home/ue4/Android/Sdk/cmdline-tools/bin/sdkmanager --sdk_root=/home/ue4/Android/Sdk/ platform-tools "platforms;android-29" "build-tools;29.0.3" "cmake;3.10.2.4988404" "ndk;21.4.7075529"

RUN /home/ue4/UnrealEngine/Engine/Extras/Android/SetupAndroid.sh

# When running without BuildKit, we use the `-no-cache` flag to disable caching of dependency data in `.git/ue4-gitdeps`, saving disk space
WORKDIR /home/ue4/UnrealEngine
RUN sudo chown ue4.ue4 /home/ue4/UnrealEngine -R
RUN sudo apt-get update && \
	./Setup.sh -no-cache && \
	sudo rm -rf /var/lib/apt/lists/* && echo '' && echo 'RUN directive complete. Docker will now commit the filesystem layer to disk.' && echo 'Note that for large filesystem layers this can take quite some time.' && echo 'Performing filesystem layer commit...' && echo ''

# The linker bundled with UE4.20.0 onwards chokes on system libraries built with newer compilers,
# so redirect the bundled clang to use the system linker instead
COPY --chown=ue4:ue4 linker-fixup.py /tmp/linker-fixup.py
RUN python3 /tmp/linker-fixup.py /home/ue4/UnrealEngine/Engine/Extras/ThirdPartyNotUE/SDKs/HostLinux/Linux_x64 `which ld` && echo '' && echo 'RUN directive complete. Docker will now commit the filesystem layer to disk.' && echo 'Note that for large filesystem layers this can take quite some time.' && echo 'Performing filesystem layer commit...' && echo ''

# Remove the sample `XXX` example platform code, since this breaks builds from 4.24.0 onwards
# (For details of what this is, see: <https://forums.unrealengine.com/unreal-engine/announcements-and-releases/1617783-attention-platform-changes-ahead>)
RUN rm -r -f /home/ue4/UnrealEngine/Engine/Platforms/XXX && echo '' && echo 'RUN directive complete. Docker will now commit the filesystem layer to disk.' && echo 'Note that for large filesystem layers this can take quite some time.' && echo 'Performing filesystem layer commit...' && echo ''

# Apply our bugfix patches to UnrealBuildTool (UBT)
COPY --chown=ue4:ue4 patch-ubt.py /tmp/patch-ubt.py
RUN python3 /tmp/patch-ubt.py /home/ue4/UnrealEngine/Engine/Source/Programs/UnrealBuildTool && echo '' && echo 'RUN directive complete. Docker will now commit the filesystem layer to disk.' && echo 'Note that for large filesystem layers this can take quite some time.' && echo 'Performing filesystem layer commit...' && echo ''

FROM source as builder

# Set the changelist number in Build.version to ensure our Build ID is generated correctly
ARG CHANGELIST
COPY set-changelist.py /tmp/set-changelist.py
RUN python3 /tmp/set-changelist.py /home/ue4/UnrealEngine/Engine/Build/Build.version $CHANGELIST && echo '' && echo 'RUN directive complete. Docker will now commit the filesystem layer to disk.' && echo 'Note that for large filesystem layers this can take quite some time.' && echo 'Performing filesystem layer commit...' && echo ''

# Remove the .git directory to disable UBT `git status` calls and speed up the build process
RUN rm -rf /home/ue4/UnrealEngine/.git && echo '' && echo 'RUN directive complete. Docker will now commit the filesystem layer to disk.' && echo 'Note that for large filesystem layers this can take quite some time.' && echo 'Performing filesystem layer commit...' && echo ''

# Enable the OpenGL RHI for Engine versions where it is present but deprecated
COPY enable-opengl.py /tmp/enable-opengl.py
RUN python3 /tmp/enable-opengl.py /home/ue4/UnrealEngine/Engine/Config/BaseEngine.ini && echo '' && echo 'RUN directive complete. Docker will now commit the filesystem layer to disk.' && echo 'Note that for large filesystem layers this can take quite some time.' && echo 'Performing filesystem layer commit...' && echo ''

COPY patch-filters-xml.py /tmp/patch-filters-xml.py
RUN python3 /tmp/patch-filters-xml.py /home/ue4/UnrealEngine/Engine/Build/InstalledEngineFilters.xml && echo '' && echo 'RUN directive complete. Docker will now commit the filesystem layer to disk.' && echo 'Note that for large filesystem layers this can take quite some time.' && echo 'Performing filesystem layer commit...' && echo ''

# Patch the default settings in InstalledEngineBuild.xml and increase the output verbosity of the DDC generation step
COPY patch-build-graph.py /tmp/patch-build-graph.py
RUN python3 /tmp/patch-build-graph.py /home/ue4/UnrealEngine/Engine/Build/InstalledEngineBuild.xml /home/ue4/UnrealEngine/Engine/Build/Build.version && echo '' && echo 'RUN directive complete. Docker will now commit the filesystem layer to disk.' && echo 'Note that for large filesystem layers this can take quite some time.' && echo 'Performing filesystem layer commit...' && echo ''

# Ensure UBT is built before we create the Installed Build, since Build.sh explicitly sets the
# target .NET framework version, whereas InstalledEngineBuild.xml just uses the system default,
# which can result in errors when running the built UBT due to the wrong version being targeted
RUN ./Engine/Build/BatchFiles/Linux/Build.sh UnrealHeaderTool Linux Development -SkipBuild && echo '' && echo 'RUN directive complete. Docker will now commit the filesystem layer to disk.' && echo 'Note that for large filesystem layers this can take quite some time.' && echo 'Performing filesystem layer commit...' && echo ''

# Create an Installed Build of the Engine
WORKDIR /home/ue4/UnrealEngine
RUN ./Engine/Build/BatchFiles/RunUAT.sh BuildGraph -target="Make Installed Build Linux" -script=Engine/Build/InstalledEngineBuild.xml -set:HostPlatformOnly=true -set:WithDDC=true
RUN rm -R -f /home/ue4/UnrealEngine/LocalBuilds/InstalledDDC && echo '' && echo 'RUN directive complete. Docker will now commit the filesystem layer to disk.' && echo 'Note that for large filesystem layers this can take quite some time.' && echo 'Performing filesystem layer commit...' && echo ''

# Split out components (DDC, debug symbols, template projects) so they can be copied into the final container image as separate filesystem layers
COPY split-components.py /tmp/split-components.py
RUN python3 /tmp/split-components.py /home/ue4/UnrealEngine/LocalBuilds/Engine/Linux /home/ue4/UnrealEngine/Components && echo '' && echo 'RUN directive complete. Docker will now commit the filesystem layer to disk.' && echo 'Note that for large filesystem layers this can take quite some time.' && echo 'Performing filesystem layer commit...' && echo ''

# Ensure Client and Server targets have their `PlatformType` field set correctly in BaseEngine.ini
COPY fix-targets.py /tmp/fix-targets.py
RUN python3 /tmp/fix-targets.py /home/ue4/UnrealEngine/LocalBuilds/Engine/Linux/Engine/Config/BaseEngine.ini && echo '' && echo 'RUN directive complete. Docker will now commit the filesystem layer to disk.' && echo 'Note that for large filesystem layers this can take quite some time.' && echo 'Performing filesystem layer commit...' && echo ''

# Some versions of the Engine fail to include UnrealPak in the Installed Build, so copy it manually
RUN cp ./Engine/Binaries/Linux/UnrealPak ./LocalBuilds/Engine/Linux/Engine/Binaries/Linux/UnrealPak && echo '' && echo 'RUN directive complete. Docker will now commit the filesystem layer to disk.' && echo 'Note that for large filesystem layers this can take quite some time.' && echo 'Performing filesystem layer commit...' && echo ''

# Ensure the bundled toolchain included in 4.20.0 and newer is copied to the Installed Build
COPY --chown=ue4:ue4 copy-toolchain.py /tmp/copy-toolchain.py
RUN python3 /tmp/copy-toolchain.py /home/ue4/UnrealEngine && echo '' && echo 'RUN directive complete. Docker will now commit the filesystem layer to disk.' && echo 'Note that for large filesystem layers this can take quite some time.' && echo 'Performing filesystem layer commit...' && echo ''

# Copy the Installed Build into a clean image, discarding the source build
FROM prerequisites as minimal

# Copy the Installed Build files from the builder image
COPY --from=builder --chown=ue4:ue4 /home/ue4/UnrealEngine/LocalBuilds/Engine/Linux /home/ue4/UnrealEngine
COPY --from=builder --chown=ue4:ue4 /home/ue4/UnrealEngine/Components/DDC /home/ue4/UnrealEngine
COPY --from=builder --chown=ue4:ue4 /home/ue4/UnrealEngine/Components/DebugSymbols /home/ue4/UnrealEngine
COPY --from=builder --chown=ue4:ue4 /home/ue4/UnrealEngine/Components/TemplatesAndSamples /home/ue4/UnrealEngine
WORKDIR /home/ue4/UnrealEngine

# Add labels to the built image to identify which components (if any) were excluded from the build that it contains
LABEL com.adamrehn.ue4-docker.excluded.ddc=0 
LABEL com.adamrehn.ue4-docker.excluded.debug=0 
LABEL com.adamrehn.ue4-docker.excluded.templates=0 

# Perform first-run setup for Mono, UnrealBuildTool and AutomationTool, which makes it possible to build Unreal projects and plugins as users other than `ue4`
# (Note that this will only work with 4.26.0 and newer, older Engine versions will always require write access to `/home/ue4/UnrealEngine`)
# See the comments on this issue for details, including the need to ensure $HOME is set correctly: <https://github.com/adamrehn/ue4-docker/issues/141>
RUN ./Engine/Build/BatchFiles/Linux/Build.sh UnrealHeaderTool Linux Development -SkipBuild && \
	mkdir -p ./Engine/Programs/AutomationTool/Saved && \
	chmod a+rw ./Engine/Programs/AutomationTool/Saved && echo '' && echo 'RUN directive complete. Docker will now commit the filesystem layer to disk.' && echo 'Note that for large filesystem layers this can take quite some time.' && echo 'Performing filesystem layer commit...' && echo ''

# Enable Vulkan support for NVIDIA GPUs
USER root
RUN apt-get update && apt-get install -y --no-install-recommends libvulkan1 && \
	rm -rf /var/lib/apt/lists/* && \
	VULKAN_API_VERSION=`dpkg -s libvulkan1 | grep -oP 'Version: [0-9|\.]+' | grep -oP '[0-9|\.]+'` && \
	mkdir -p /etc/vulkan/icd.d/ && \
	echo \
	"{\
		\"file_format_version\" : \"1.0.0\",\
		\"ICD\": {\
			\"library_path\": \"libGLX_nvidia.so.0\",\
			\"api_version\" : \"${VULKAN_API_VERSION}\"\
		}\
	}" > /etc/vulkan/icd.d/nvidia_icd.json && echo '' && echo 'RUN directive complete. Docker will now commit the filesystem layer to disk.' && echo 'Note that for large filesystem layers this can take quite some time.' && echo 'Performing filesystem layer commit...' && echo ''
USER ue4

ARG UE4CLI_VERSION="ue4cli>=0.0.45"
ARG CONAN_UE4CLI_VERSION="conan-ue4cli>=0.0.27"
FROM source as conan
ARG UE4CLI_VERSION
ARG CONAN_UE4CLI_VERSION

# Install ue4cli and conan-ue4cli
USER root
RUN pip3 install --upgrade pip setuptools wheel && echo '' && echo 'RUN directive complete. Docker will now commit the filesystem layer to disk.' && echo 'Note that for large filesystem layers this can take quite some time.' && echo 'Performing filesystem layer commit...' && echo ''
RUN pip3 install "$UE4CLI_VERSION" "$CONAN_UE4CLI_VERSION" && echo '' && echo 'RUN directive complete. Docker will now commit the filesystem layer to disk.' && echo 'Note that for large filesystem layers this can take quite some time.' && echo 'Performing filesystem layer commit...' && echo ''
USER ue4

# Extract the third-party library details from UBT
RUN ue4 setroot /home/ue4/UnrealEngine && echo '' && echo 'RUN directive complete. Docker will now commit the filesystem layer to disk.' && echo 'Note that for large filesystem layers this can take quite some time.' && echo 'Performing filesystem layer commit...' && echo ''
RUN ue4 conan generate && echo '' && echo 'RUN directive complete. Docker will now commit the filesystem layer to disk.' && echo 'Note that for large filesystem layers this can take quite some time.' && echo 'Performing filesystem layer commit...' && echo ''

# Copy the generated Conan packages into a new image with our Installed Build
FROM minimal as full
ARG UE4CLI_VERSION
ARG CONAN_UE4CLI_VERSION

# Install CMake, ue4cli, conan-ue4cli, and ue4-ci-helpers
USER root
RUN apt-get update && apt-get install -y --no-install-recommends cmake && echo '' && echo 'RUN directive complete. Docker will now commit the filesystem layer to disk.' && echo 'Note that for large filesystem layers this can take quite some time.' && echo 'Performing filesystem layer commit...' && echo ''
RUN pip3 install --upgrade pip setuptools wheel && echo '' && echo 'RUN directive complete. Docker will now commit the filesystem layer to disk.' && echo 'Note that for large filesystem layers this can take quite some time.' && echo 'Performing filesystem layer commit...' && echo ''
RUN pip3 install "$UE4CLI_VERSION" "$CONAN_UE4CLI_VERSION" ue4-ci-helpers && echo '' && echo 'RUN directive complete. Docker will now commit the filesystem layer to disk.' && echo 'Note that for large filesystem layers this can take quite some time.' && echo 'Performing filesystem layer commit...' && echo ''
USER ue4

# Explicitly set the configuration directory for ue4cli
# (This prevents things from breaking when using CI/CD systems that override the $HOME environment variable)
ENV UE4CLI_CONFIG_DIR /home/ue4/.config/ue4cli

# Copy the Conan configuration settings and package cache from the previous build stage
COPY --from=conan --chown=ue4:ue4 /home/ue4/.conan /home/ue4/.conan

# Install conan-ue4cli (just generate the profile, since we've already copied the generated packages)
RUN ue4 setroot /home/ue4/UnrealEngine && echo '' && echo 'RUN directive complete. Docker will now commit the filesystem layer to disk.' && echo 'Note that for large filesystem layers this can take quite some time.' && echo 'Performing filesystem layer commit...' && echo ''
RUN ue4 conan generate --profile-only && echo '' && echo 'RUN directive complete. Docker will now commit the filesystem layer to disk.' && echo 'Note that for large filesystem layers this can take quite some time.' && echo 'Performing filesystem layer commit...' && echo ''

# Enable PulseAudio support
USER root
RUN apt-get install -y --no-install-recommends pulseaudio-utils && echo '' && echo 'RUN directive complete. Docker will now commit the filesystem layer to disk.' && echo 'Note that for large filesystem layers this can take quite some time.' && echo 'Performing filesystem layer commit...' && echo ''
COPY pulseaudio-client.conf /etc/pulse/client.conf
USER ue4
