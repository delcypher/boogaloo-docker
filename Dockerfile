FROM ubuntu:14.04
MAINTAINER Dan Liew <daniel.liew@imperial.ac.uk>

# Add PPA for Z3 4.3.2
# FIXME: We shouldn't be using GPUVerify's PPA
RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com C504E590 && \
    echo 'deb http://ppa.launchpad.net/delcypher/gpuverify-smt/ubuntu trusty main' > /etc/apt/sources.list.d/smt.list && \
    apt-get update

# Setup Z3
RUN apt-get -y install z3=4.3.2-0~trusty1

# Mercurial and a proper text editor
RUN apt-get -y --no-install-recommends install mercurial ca-certificates vim

# FIXME: This pulls in lots of depdencies, not sure we need them all
RUN apt-get -y install cabal-install

RUN useradd -m boogaloo
USER boogaloo
WORKDIR /home/boogaloo


# Build haskell Z3 bindings
RUN hg clone https://bitbucket.org/nadiapolikarpova/z3-haskell && \
    cd z3-haskell && \
    cabal update

# We need to patch this fork the Z3 bindings because
# it tries to use mtl-2.2.1 but that is in conflict with
# Boogaloo's dependencies
# FIXME: Z3's haskell bindings warn against using mtl-2.1
#        we should fix Boogaloo's dependencies instead
ADD z3-haskell.patch /home/boogaloo/z3-haskell/
RUN cd /home/boogaloo/z3-haskell/ && \
    hg update 5f4ab5bc3b2d3af8f9db0f08fe07b77ee2bbb86d && \
    hg import --no-commit z3-haskell.patch && \
    cabal install

# Build Boogaloo
RUN hg clone https://bitbucket.org/nadiapolikarpova/boogaloo && \
    cd boogaloo && \
    hg update f8ac7985ff661278435c9cabc5ca5dce749c50bb
ADD boogaloo.patch /home/boogaloo/boogaloo/
# FIXME: We need to patch Boogaloo because it will try to download
# a different version of Z3 (rather than what we just built) if we
# don't specify the version of Z3 precisely
RUN cd boogaloo && \
    hg import --no-commit boogaloo.patch && \
    cabal install

# Run Boogaloo tests
RUN cd boogaloo && \
    ghc Tests.hs && \
    ./Tests

# Put Boogaloo in PATH
RUN echo 'PATH=/home/boogaloo/.cabal/bin:$PATH' >> ~/.bashrc
