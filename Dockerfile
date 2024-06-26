FROM ubuntu:23.04

# Stop ubuntu-20 interactive options.
ENV DEBIAN_FRONTEND noninteractive

# Stop script if any individual command fails.
RUN set -e

# Define LLVM version.
ENV llvm_version=16.0.0

# Define home directory
ENV HOME=/home/SVF-tools

# Define dependencies.
ENV lib_deps="cmake g++ gcc git zlib1g-dev libncurses5-dev libtinfo5 build-essential libssl-dev libpcre2-dev zip vim libzstd-dev"
ENV build_deps="wget xz-utils git gdb tcl python-is-python3"

# Fetch dependencies.
RUN apt-get update --fix-missing
RUN apt-get install -y $build_deps $lib_deps

# Fetch and build SVF source.
RUN echo "Downloading LLVM and building SVF to " ${HOME}
WORKDIR ${HOME}
RUN git clone "https://github.com/SVF-tools/SVF.git"
WORKDIR ${HOME}/SVF
RUN echo "Building SVF ..."
RUN bash ./build.sh

# Export SVF, llvm, z3 paths
ENV PATH=${HOME}/SVF/Release-build/bin:$PATH
ENV PATH=${HOME}/SVF/llvm-$llvm_version.obj/bin:$PATH
ENV SVF_DIR=${HOME}/SVF
ENV LLVM_DIR=${HOME}/SVF/llvm-$llvm_version.obj
ENV Z3_DIR=${HOME}/SVF/z3.obj
RUN ln -s ${Z3_DIR}/bin/libz3.so ${Z3_DIR}/bin/libz3.so.4

# Fetch and build Software-Security-Analysis
WORKDIR ${HOME}
RUN git clone "https://github.com/SVF-tools/Software-Security-Analysis.git"
WORKDIR ${HOME}/Software-Security-Analysis
RUN echo "Building SVF-Teaching example ..."
RUN cmake -DCMAKE_BUILD_TYPE=MinSizeRel .
RUN make -j8
