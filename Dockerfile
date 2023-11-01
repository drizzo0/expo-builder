# Use the official Ubuntu 22.04 base image
FROM ubuntu:jammy-20220531

# Set the maintainer label
LABEL maintainer="Daniele <d.rizzo0@icloud.com>"

# Set environment variables for configuration
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV NDK_HOME=/opt/android-ndk-r21e
ENV ANDROID_HOME=/opt/Android
ENV NODE_VERSION=16.18.1
ENV NPM_VERSION=v8.1.2
ENV NVM_DIR=/root/.nvm
ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}"
ENV SSL_FOLDER=/opt/ssl
ENV WATCHMAN_FOLDER=/opt/watchman

# Installing everything we neet with apt
RUN apt update && apt install -y build-essential curl wget unzip openjdk-11-jdk openssl git

# Creating all folders
RUN mkdir -p $NDK_HOME && \
    mkdir -p $ANDROID_HOME && \
    mkdir -p $WATCHMAN_FOLDER && \
    mkdir -p $SSL_FOLDER && \
    mkdir -p /usr/local/var && \
    mkdir -p /usr/local/var/run && \
    mkdir -p /usr/local/var/run/watchman

# Download and extract Android NDK r21e
RUN cd /opt/android-ndk-r21e && \
    curl -LO https://dl.google.com/android/repository/android-ndk-r21e-linux-x86_64.zip && \
    unzip -q android-ndk-r21e-linux-x86_64.zip && \
    rm android-ndk-r21e-linux-x86_64.zip

# Install Node - Yarn - EAS
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
RUN npm install --global yarn
RUN npm install --global eas-cli

# Install watchman
RUN cd $WATCHMAN_FOLDER && \
    curl -LO https://github.com/facebook/watchman/releases/download/v2023.10.30.00/watchman-v2023.10.30.00-linux.zip && \
    unzip -q watchman-v2023.10.30.00-linux.zip && \
    mv watchman-v2023.10.30.00-linux/bin/* /usr/bin/ && \
    mv watchman-v2023.10.30.00-linux/lib/* /usr/local/lib/ && \
    rm -rf $WATCHMAN_FOLDER

#Install openssl needed for watchman
RUN cd $SSL_FOLDER && \
    wget https://www.openssl.org/source/openssl-1.1.1o.tar.gz && \
    tar -zxf openssl-1.1.1o.tar.gz && cd openssl-1.1.1o && \
    ./config && make && make install && \
    cp $SSL_FOLDER/openssl-1.1.1o/libcrypto.so.1.1 /usr/lib/x86_64-linux-gnu/ && \
    rm -rf $SSL_FOLDER

RUN cd $ANDROID_HOME && \
    wget "https://dl.google.com/android/repository/commandlinetools-linux-7302050_latest.zip" -O commandlinetools.zip && \
    unzip -q commandlinetools.zip && \
    rm commandlinetools.zip && \
    cd $ANDROID_HOME/cmdline-tools/bin && \
    yes | ./sdkmanager "platforms;android-33" --sdk_root=$ANDROID_HOME && \
    yes | ./sdkmanager "build-tools;34.0.0" --sdk_root=$ANDROID_HOME

WORKDIR /root/

CMD ["/bin/bash"]
