# Builder Stage
FROM alpine:edge as builder

# Install necessary packages using apk add
RUN apk update && apk add \
    cmake \
    g++ \
    curl \
    unzip \
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

# Final Stage
FROM alpine:edge
LABEL author="xanonymous"

# Copy necessary files from builder stage
COPY --from=builder /app/Rapfi/build/pbrain-rapfi /app/rapfi
COPY --from=builder /app/Networks/config-example/config.toml /app/config.toml
COPY --from=builder /app/Networks/mix7nnue /app
COPY --from=builder /app/Networks/classical /app

# Install necessary packages using apk add
RUN apk update && apk add --no-cache \
    libtbb-dev \
    linux-headers \
    && sed -i 's/default_thread_num = 1/default_thread_num = 0/g' /app/config.toml

# Set default command to execute
CMD ["/app/rapfi"]
