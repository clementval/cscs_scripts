FROM ubuntu:18.04

# Update APT
RUN apt-get update

# Install packages
RUN apt-get install -y ninja-build
RUN apt-get install -y git
RUN apt-get install -y build-essential
RUN apt-get install -y python3-pip python3-dev
RUN apt-get install -y wget

# Install OpenSSL
RUN apt-get install -y libssl-dev

# Install latest CMake
RUN apt-get install -y apt-transport-https ca-certificates gnupg software-properties-common
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | apt-key add -
RUN apt-add-repository 'deb https://apt.kitware.com/ubuntu/ bionic main'
RUN apt-get update
RUN apt-get install -y cmake
#RUN wget https://cmake.org/files/v3.16/cmake-3.16.2.tar.gz
#RUN tar -xzvf cmake-3.16.2.tar.gz
#RUN cd cmake-3.16.2 && ./bootstrap && make -j && make install

# Check version of installed packages
RUN echo "Ninja version: $(ninja --version)"
RUN git --version
RUN cmake --version
RUN gcc --version

# Clone repository
RUN mkdir workspace
RUN cd workspace || exit 1
RUN git clone --depth 1 https://github.com/flang-compiler/f18-llvm-project.git -b mono
RUN git clone --depth 1 https://github.com/schweitzpgi/f18.git -b mono
RUN cd f18-llvm-project && ln -s ../f18/ flang && cd ..
RUN mkdir build
RUN cd build || exit 1
RUN pwd
RUN cmake ../f18-llvm-project/llvm -DCMAKE_BUILD_TYPE=RelWithDebInfo -DLLVM_TARGETS_TO_BUILD=X86 -DLLVM_ENABLE_PROJECTS="flang;mlir" -DCMAKE_CXX_STANDARD=17 -DLLVM_BUILD_TOOLS=ON -DLLVM_INSTALL_UTILS=ON
RUN make -j
