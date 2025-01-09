FROM ubuntu:23.10

##### 
## Image Configuration
#####

ENV PYTHON_VERSION="3.10.0"
ENV TZ="Europe/Berlin"

# increase java heap size for dataflow analysis
ENV JAVA_OPTS="-Xmx24G"

# set timezone
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# switch default shell from /bin/sh to /bin/bash to be able to use source
SHELL ["/bin/bash", "-c"]

##### 
## Tool Setup
#####

## Install dev dependencies

RUN apt update && \
    apt install -y git openjdk-17-jdk curl unzip locales

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8

# python
RUN apt-get install -y wget build-essential gdb lcov pkg-config \
    libbz2-dev libffi-dev libgdbm-dev libgdbm-compat-dev liblzma-dev \
    libncurses5-dev libreadline6-dev libsqlite3-dev libssl-dev \
    lzma lzma-dev tk-dev uuid-dev zlib1g-dev
RUN wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz && \
    tar -xf Python-${PYTHON_VERSION}.tar.xz && \
    cd Python-${PYTHON_VERSION} && \
    ./configure --enable-optimizations && \
    make -j 8 && \
    make install && \
    ln -s /usr/local/bin/python3 /usr/bin/python && \
    ln -s /usr/local/bin/pip3 /usr/bin/pip


##### 
## Application Setup
#####

WORKDIR /glove
COPY . /glove