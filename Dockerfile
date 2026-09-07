FROM golang:1.26-alpine

# Install build dependencies for cross-compilation
RUN apk add --no-cache \
    tor \
    upx \
    wget \
    git \
    gcc \
    musl-dev \
    autoconf \
    automake \
    libtool \
    pkgconfig \
    perl \
    bash \
    make

# Install MinGW for Windows cross-compilation
RUN apk add --no-cache \
    mingw-w64-gcc \
    mingw-w64-headers \
    mingw-w64-binutils || echo "Warning: MinGW not available in Alpine, Windows build may fail"

# Set up workspace
RUN mkdir -p /go/pkg/mod/github.com/cretz
WORKDIR /go/pkg/mod/github.com/cretz

# Clone tor-static with submodules (but NOT recursive to skip Rust subdeps)
# The Rust submódule has URL redirect issues, but we don't need it for static C compilation
RUN git clone https://github.com/godoineto/tor-static.git tor-static && \
    cd tor-static && \
    git checkout master && \
    git config --global url."https://".insteadOf git:// && \
    git submodule update --init --depth 1 openssl libevent zlib xz tor || true

WORKDIR /go/pkg/mod/github.com/cretz/tor-static

# Build all dependencies using build.go (this takes a while)
RUN echo "Building Tor 0.4.7.9 and dependencies..." && \
    go run build.go build-all 2>&1 | tail -100