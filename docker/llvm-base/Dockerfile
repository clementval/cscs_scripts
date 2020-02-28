FROM ubuntu:18.04

# Update APT
RUN echo "Acquire::http::Proxy \"http://10.40.10.2:3142\";" > /etc/apt/apt.conf
RUN apt-get update

# Install packages
RUN apt-get install -y ninja-build git build-essential python3-pip python3-dev \
    wget libssl-dev

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

# Clone repository
RUN mkdir workspace
RUN cd workspace || exit 1
RUN git clone --depth 1 https://github.com/flang-compiler/f18-llvm-project.git \
    -b mono
RUN git clone --depth 1 https://github.com/schweitzpgi/f18.git -b mono
RUN cd f18-llvm-project && ln -s ../f18/ flang && cd ..
RUN mkdir build
RUN cd build || exit 1
RUN pwd
RUN cmake ../f18-llvm-project/llvm -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DLLVM_TARGETS_TO_BUILD=X86 -DLLVM_ENABLE_PROJECTS="flang;mlir" \
    -DCMAKE_CXX_STANDARD=17 -DLLVM_BUILD_TOOLS=ON -DLLVM_INSTALL_UTILS=ON
RUN make -j
