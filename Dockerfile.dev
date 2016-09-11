FROM jlawton/virtualagc
MAINTAINER Jim Lawton

# Use this to clone directly from Github.
#RUN git clone https://github.com/rburkey2005/virtualagc

# Use this to build a copy of the current directory. 
RUN mkdir /virtualagc
COPY . /virtualagc

RUN cd virtualagc && make clean
RUN cd virtualagc && DEV_BUILD=yes make yaLEMAP yaAGC yaAGS yaYUL missions corediffs
