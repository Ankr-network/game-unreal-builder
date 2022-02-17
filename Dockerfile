FROM ue4-mirage:4.27.2

RUN sudo apt-get install libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 libbz2-1.0:i386 wget default-jre openjdk-17-jre unzip

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

RUN mkdir /tmp/project && sudo chown ue4.ue4 /tmp/project -R

ADD entrypoint.sh /entrypoint.sh
RUN sudo chown ue4.ue4 /entrypoint.sh && sudo chmod +x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]