FROM ubuntu:20.04 as builder

ENV BRANCH=rvv-intrinsic
ENV ISA=rv64imafdcv_zfh
ENV RISCV=/opt/riscv

RUN apt-get update
RUN apt-get install -y autoconf automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev
RUN apt-get install -y git

RUN git clone https://github.com/riscv/riscv-gnu-toolchain
WORKDIR riscv-gnu-toolchain
RUN git checkout $BRANCH && git submodule update --init --recursive
RUN ./configure --with-arch=$ISA --prefix=$RISCV && make -j`nproc` && make -j`nproc` linux

##########################################
FROM ubuntu:20.04

ENV RISCV=/opt/riscv
ENV PATH=$RISCV/bin:$PATH
WORKDIR /work

RUN apt-get update && apt-get install -y autoconf automake curl gawk build-essential bison flex texinfo libtool

COPY --from=builder $RISCV $RISCV

CMD riscv64-unknown-elf-gcc -v
