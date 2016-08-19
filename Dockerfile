FROM ubuntu:16.04
MAINTAINER Jim Lawton

RUN apt-get -y update
#RUN apt-get -y upgrade

RUN apt-get -y install git
RUN apt-get -y install build-essential
RUN apt-get -y install make
RUN apt-get -y install g++
RUN apt-get -y install python
RUN apt-get -y install libncurses5
RUN apt-get -y install libncurses5-dev

# Graphical dependencies.
#RUN apt-get -y install wx-common
#RUN apt-get -y install libwxgtk3.0-dev
#RUN apt-get -y install liballegro4-dev
#RUN apt-get -y install libsdl2-2.0
#RUN apt-get -y install libsdl2-dev

# Use this to clone directly from Github.
#RUN git clone https://github.com/rburkey2005/virtualagc

# Use this to build a copy of the current directory. 
RUN mkdir /virtualagc
COPY . /virtualagc

RUN cd virtualagc && make clean
RUN cd virtualagc && make yaLEMAP yaAGC yaAGS yaYUL missions corediffs
