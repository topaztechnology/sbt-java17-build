FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

ARG JAVA_VERSION=17.0.3+7-0ubuntu0.20.04.1
ARG PYTHON_VERSION=3.8.10-0ubuntu1~20.04.5

# Java
RUN \
  apt-get update && \
  apt-get -qy upgrade && \
  apt-get -qy install curl zip gnupg nano bash jq git build-essential perl ruby xsltproc openjdk-17-jdk=${JAVA_VERSION} && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

# OpenBLAS
ARG OPENBLAS_VERSION=0.3.20
ARG OPENBLAS_FLAGS="USE_OPENMP=0 NO_LAPACK=0 MAJOR_VERSION=3 NO_AFFINITY=1 DYNAMIC_ARCH=1 USE_HEAP_ALLOC=1"
ARG OPENBLAS_CFLAGS=-O2

RUN \
  apt update && \
  apt -qy install gfortran && \
  curl -L "https://github.com/xianyi/OpenBLAS/releases/download/v${OPENBLAS_VERSION}/OpenBLAS-${OPENBLAS_VERSION}.tar.gz" | tar zx -C /tmp && \
  make -C "/tmp/OpenBLAS-${OPENBLAS_VERSION}" "${OPENBLAS_FLAGS}" CFLAGS="${OPENBLAS_CFLAGS}" PREFIX=/usr && \
  make -C "/tmp/OpenBLAS-${OPENBLAS_VERSION}" "${OPENBLAS_FLAGS}" PREFIX=/usr install && \
  rm -r "/tmp/OpenBLAS-${OPENBLAS_VERSION}" && \
  apt clean && \
  rm -rf /var/lib/apt/lists/* && \
  ln -s /usr/lib/libopenblas.so /usr/lib/libblas.so && \
  ln -s /usr/lib/libopenblas.so /usr/lib/libblas.so.3 && \
  ln -s /usr/lib/libopenblas.so /usr/lib/liblapack.so && \
  ln -s /usr/lib/libopenblas.so /usr/lib/liblapack.so.3

# Python & JEP
ARG JEP_VERSION=4.0.3
ARG NUMPY_VERSION=1.23.0
ARG SCIPY_VERSION=1.8.1

ENV PYTHONPATH=/usr/local/lib/python3.8/dist-packages

RUN \
  apt update && \
  apt -qy upgrade && \
  apt -qy install python3.8-minimal=${PYTHON_VERSION} python3-pip python3.8-dev=${PYTHON_VERSION} && \
  pip3 install numpy==${NUMPY_VERSION} scipy==${SCIPY_VERSION} && \
  pip3 install jep==${JEP_VERSION} && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Chrome
RUN \
  curl -sL https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
  echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list && \
  apt-get update && \
  apt-get -qy install google-chrome-stable && \
  rm -rf /var/lib/apt/lists/*

ENV CHROME_BIN /usr/bin/google-chrome-stable

SHELL ["/bin/bash", "-ic"]

RUN \
  curl -Ls https://git.io/sbt > /usr/bin/sbt && \
  chmod 0755 /usr/bin/sbt

ARG SBT_VERSION=1.6.2
ARG SCALA_VERSION=2.13.8

RUN \
  # Cache sbt and scala jars
  mkdir -p /root/cache/project && \
  mkdir -p /root/cache/src/main/scala && \
  echo "sbt.version=${SBT_VERSION}" > /root/cache/project/build.properties && \
  touch /root/cache/src/main/scala/Cache.scala && \
  echo -e "name := \"cache\"\n\nversion := \"1.0\"\n\nscalaVersion := \"${SCALA_VERSION}\"\n" > /root/cache/build.sbt && \
  cd /root/cache && \
  sbt -v clean compile && \
  rm -r /root/cache
