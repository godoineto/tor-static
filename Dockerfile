FROM ghcr.io/lu4p/cgo-cross:master

# Install build dependencies
RUN apk add --no-cache \
    tor \
    upx \
    wget \
    git \
    go \
    autoconf \
    automake \
    libtool \
    pkg-config \
    perl \
    bash

# Set up workspace
RUN mkdir -p /go/pkg/mod/github.com/cretz
WORKDIR /go/pkg/mod/github.com/cretz

# Clone tor-static with submodules
# Using https to avoid SSH key issues in Docker build
RUN git clone --recursive https://github.com/godoineto/tor-static.git tor-static && \
    cd tor-static && \
    git checkout master

WORKDIR /go/pkg/mod/github.com/cretz/tor-static

# Build all dependencies using build.go (this takes a while)
RUN echo "Building Tor 0.4.7.9 and dependencies..." && \
    go run build.go build-all 2>&1 | tail -100