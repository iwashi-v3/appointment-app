FROM dart:stable AS base

WORKDIR /frontend

RUN apt update && apt upgrade -y
RUN apt install -y clang cmake ninja-build pkg-config libgtk-3-dev
RUN dart pub global activate fvm

ARG FLUTTER_VERSION=3.38.0
ARG PATH=/root/.pub-cache/bin:$PATH
RUN fvm doctor
RUN fvm install ${FLUTTER_VERSION} && fvm use --force ${FLUTTER_VERSION}
RUN fvm flutter config --enable-web --enable-android --enable-ios
#RUN fvm flutter config --enable-web --enable-linux-desktop --enable-macos-desktop --enable-windows-desktop \
#                       --enable-android --enable-ios --enable-fuchsia
RUN fvm global ${FLUTTER_VERSION}
RUN fvm flutter doctor

ENV FVM_ROOT=/root/.pub-cache
ENV PATH="${PATH}:/root/fvm/default/bin:${FVM_ROOT}/bin"
RUN echo 'export PATH="${PATH}:/root/fvm/default/bin:${FVM_ROOT}/bin"' > ~/.bash_profile