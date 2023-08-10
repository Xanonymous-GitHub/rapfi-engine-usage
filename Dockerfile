# Builder Stage
FROM alpine:edge as builder

# Install necessary packages using apk add
RUN apk update && apk add \
    cmake \
    g++ \
    git \
    libtbb-dev \
    make \
    linux-headers

# Working directory setup
WORKDIR /app

# Clone the repository
RUN git clone https://github.com/dhbloo/rapfi.git . \
    && git submodule update --init --recursive --force && git submodule sync

# Build process
RUN cd Rapfi \
    && mkdir build  \
    && cd build  \
    && cmake .. -DCMAKE_BUILD_TYPE=Release \
    && make

FROM alpine:edge
LABEL author="xanonymous"

RUN apk update \
    && apk upgrade \
    && apk add --no-cache openssl libtbb \
    && rm -rf /var/cache/apk/* \
    && addgroup -S rapfi \
    && adduser -S rapfi -G rapfi --no-create-home --shell /bin/false --disabled-password

WORKDIR /app

# Copy necessary files from builder stage with specified owner
COPY --from=builder --chown=rapfi:rapfi /app/Rapfi/build/pbrain-rapfi /app/rapfi
COPY --from=builder --chown=rapfi:rapfi /app/Networks/mix7nnue /app/Networks/classical ./config.toml /app/

USER rapfi
CMD ["/app/rapfi"]
