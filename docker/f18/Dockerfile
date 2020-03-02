#
# Compilation of f18 and llvm
# author: clementval

FROM ubuntu:18.04

ENV HTTP_PROXY "http://10.40.10.2:3142"
ENV HTTPS_PROXY "http://10.40.10.2:3142"

# Update APT
RUN echo "Acquire::http::Proxy \"http://10.40.10.2:3142\";" > /etc/apt/apt.conf
RUN apt-get update

# Install packages
RUN apt-get install -y ninja-build git build-essential python3-pip python3-dev \
    wget libssl-dev python2.7 python-pip

# Install latest CMake
RUN apt-get install -y apt-transport-https ca-certificates gnupg \ 
    software-properties-common
COPY kiteware.key .
RUN apt-key add kiteware.key
RUN apt-add-repository 'deb https://apt.kitware.com/ubuntu/ bionic main'
RUN apt-get update
RUN apt-get install -y cmake

# Check version of installed packages
RUN echo "Ninja version: $(ninja --version)"
RUN echo "Git version: $(git --version)"
RUN echo "CMake version: $(cmake --version)"
RUN echo "GCC version: $(gcc --version)"

# Build LLVM + MLIR
RUN git clone --depth 1 https://github.com/llvm/llvm-project.git
RUN mkdir llvm-project/build || exit 1
RUN cd llvm-project/build && LDFLAGS="-fuse-ld=gold" cmake -GNinja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=../install -DLLVM_TARGETS_TO_BUILD=host \
    -DLLVM_ENABLE_PROJECTS="mlir" ../llvm
RUN cd llvm-project/build && ninja

# Build f18
RUN git clone --depth 1 https://github.com/flang-compiler/f18.git
RUN mkdir f18/build || exit 1
RUN cd f18/build && env CXXFLAGS="-UNDEBUG" LDFLAGS="-fuse-ld=gold" cmake \
    -GNinja -DCMAKE_BUILD_TYPE=Release .. \ 
    -DLLVM_DIR=/llvm-project/build/lib/cmake/llvm \
    -DCMAKE_INSTALL_PREFIX=../install
RUN cd f18/build && ninja
RUN cd f18/build && ninja check-all